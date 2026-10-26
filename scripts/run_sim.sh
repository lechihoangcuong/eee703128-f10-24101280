#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
BASE="${F10_EVIDENCE_DIR:-evidence/local}/simulation"
mkdir -p "$BASE"
RTL=(rtl/f10_handshake_controller.sv rtl/f10_tiny_tapeout_top.sv rtl/tt_um_24101280_f10.sv)
for KIND in core wrapper; do
    if [ "$KIND" = core ]; then TOP=f10_tb_selfcheck; TB=tb/f10_tb_selfcheck.sv; else TOP=f10_wrapper_tb; TB=tb/f10_wrapper_tb.sv; fi
    OUT="$BASE/$KIND"
    mkdir -p "$OUT"
    { date -u '+UTC %Y-%m-%dT%H:%M:%SZ'; command -v iverilog vvp python3 timeout; iverilog -V; vvp -V; } > "$OUT/tool_versions.txt" 2>&1
    sha256sum "${RTL[@]}" "$TB" scripts/run_sim.sh scripts/check_sim.py > "$OUT/source_sha256.txt"
    printf 'timeout 30s iverilog -g2012 -Wall -s %s -o sim.vvp rtl/*.sv %s\ntimeout 60s vvp sim.vvp\n' "$TOP" "$TB" > "$OUT/commands.txt"
    set +e
    timeout 30s iverilog -g2012 -Wall -s "$TOP" -o "$OUT/sim.vvp" "${RTL[@]}" "$TB" > "$OUT/compile.log" 2>&1
    STATUS=$?
    set -e
    printf '%s\n' "$STATUS" > "$OUT/compile_exit_code.txt"
    [ "$STATUS" = 0 ] || { cat "$OUT/compile.log"; exit "$STATUS"; }
    set +e
    (cd "$OUT"; timeout 60s vvp sim.vvp > simulation.log 2>&1)
    STATUS=$?
    set -e
    printf '%s\n' "$STATUS" > "$OUT/simulation_exit_code.txt"
    cat "$OUT/simulation.log"
    [ "$STATUS" = 0 ] || exit "$STATUS"
    python3 scripts/check_sim.py "$KIND" "$OUT"
done
echo 'F10_SIMULATION_ALL_PASSED'
