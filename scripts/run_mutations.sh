#!/usr/bin/env bash
# Deliberately broken fixtures, never implementation RTL. A caught mutant must FAIL.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
OUT="${F10_EVIDENCE_DIR:-evidence/local}/mutation_smoke"
mkdir -p "$OUT"
{ date -u +%FT%TZ; iverilog -V; vvp -V; } > "$OUT/tool_versions.txt" 2>&1
sha256sum rtl/f10_handshake_controller.sv tb/f10_tb_selfcheck.sv scripts/run_mutations.sh diagnostics/mutation_smoke/*/mutant_core.sv > "$OUT/source_sha256.txt"
printf 'mutant,compile_exit,simulation_exit,detected,classification\n' > "$OUT/results.csv"
FAILED=0
for NAME in off_by_one deadline_priority live_timeout_reload; do
    RUN="$OUT/$NAME"
    mkdir -p "$RUN"
    printf 'timeout 30s iverilog -g2012 -s f10_tb_selfcheck -o sim.vvp diagnostics/mutation_smoke/%s/mutant_core.sv tb/f10_tb_selfcheck.sv\ntimeout 30s vvp sim.vvp\n' "$NAME" > "$RUN/commands.txt"
    set +e
    timeout 30s iverilog -g2012 -s f10_tb_selfcheck -o "$RUN/sim.vvp" "diagnostics/mutation_smoke/$NAME/mutant_core.sv" tb/f10_tb_selfcheck.sv > "$RUN/compile.log" 2>&1
    C=$?
    set -e
    printf '%s\n' "$C" > "$RUN/compile_exit_code.txt"
    if [ "$C" -ne 0 ]; then
        printf '%s,%s,NA,NO,COMPILE_FAILED_NOT_A_DETECTION\n' "$NAME" "$C" >> "$OUT/results.csv"
        FAILED=1
        continue
    fi
    set +e
    (cd "$RUN"; timeout 30s vvp sim.vvp > simulation.log 2>&1)
    S=$?
    set -e
    printf '%s\n' "$S" > "$RUN/simulation_exit_code.txt"
    if [ "$S" -ne 0 ] && [ "$S" -ne 124 ] && [ "$S" -ne 137 ] && grep -q '^FAIL case=' "$RUN/simulation.log" && grep -q '^FATAL:' "$RUN/simulation.log"; then
        printf '%s,%s,%s,YES,INTENTIONAL_MUTANT_FAILURE_CAUGHT\n' "$NAME" "$C" "$S" >> "$OUT/results.csv"
    else
        printf '%s,%s,%s,NO,NOT_DETECTED_OR_INFRASTRUCTURE_FAILURE\n' "$NAME" "$C" "$S" >> "$OUT/results.csv"
        FAILED=1
    fi
    # The tiny FAIL CSV and full text log suffice; do not retain mutant binaries/VCD.
    rm -f -- "$RUN/sim.vvp" "$RUN/f10_core_selfcheck.vcd"
done
cat "$OUT/results.csv"
python3 - "$OUT" <<'PY'
import csv, json, sys
from pathlib import Path
p = Path(sys.argv[1])
rows = list(csv.DictReader((p/'results.csv').open()))
caught = sum(r['detected'] == 'YES' for r in rows)
summary = {'classification':'INTENTIONAL_MUTATION_SMOKE_ONLY', 'mutants':len(rows), 'caught':caught,
           'status':'ALL_THREE_CAUGHT' if len(rows)==3 and caught==3 else 'MUTATION_CHECK_FAILED',
           'results':rows, 'limits':'Three concrete intentionally broken fixtures; not total mutation coverage. FAIL/FATAL in these logs is expected, separate from original RTL PASS.'}
(p/'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
print(json.dumps(summary))
assert len(rows)==3 and caught==3
PY
exit "$FAILED"
