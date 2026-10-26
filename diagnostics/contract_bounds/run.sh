#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
OUT="${F10_EVIDENCE_DIR:-evidence/local}/contract_bounds"
mkdir -p "$OUT"
date -u +%FT%TZ > "$OUT/run_started_utc.txt"
uname -a > "$OUT/environment.txt"
{ iverilog -V; vvp -V; python3 --version; } > "$OUT/tool_versions.txt" 2>&1
sha256sum rtl/f10_handshake_controller.sv diagnostics/contract_bounds/f10_contract_bounds_tb.sv diagnostics/contract_bounds/run.sh diagnostics/contract_bounds/summarize.py > "$OUT/source_sha256.txt"
printf '%s\n' 'timeout 30s iverilog -g2012 -Wall -s f10_contract_bounds_tb -o <out>/sim.vvp rtl/f10_handshake_controller.sv diagnostics/contract_bounds/f10_contract_bounds_tb.sv' '(cd <out>; timeout 10s vvp sim.vvp)' 'python3 diagnostics/contract_bounds/summarize.py <out>' > "$OUT/commands.txt"
set +e
timeout 30s iverilog -g2012 -Wall -s f10_contract_bounds_tb -o "$OUT/sim.vvp" rtl/f10_handshake_controller.sv diagnostics/contract_bounds/f10_contract_bounds_tb.sv > "$OUT/compile.log" 2>&1
STATUS=$?
set -e
printf '%s\n' "$STATUS" > "$OUT/compile_exit_code.txt"
[ "$STATUS" = 0 ] || { cat "$OUT/compile.log"; exit "$STATUS"; }
set +e
(cd "$OUT"; timeout 10s vvp sim.vvp > simulation.log 2>&1)
STATUS=$?
set -e
printf '%s\n' "$STATUS" > "$OUT/simulation_exit_code.txt"
date -u +%FT%TZ > "$OUT/run_finished_utc.txt"
cat "$OUT/simulation.log"
[ "$STATUS" = 0 ] || exit "$STATUS"
python3 diagnostics/contract_bounds/summarize.py "$OUT"
(cd "$OUT"; sha256sum f10_contract_bounds.vcd diagnostic_cases.csv simulation.log > evidence_sha256.txt)
rm -f -- "$OUT/sim.vvp"
