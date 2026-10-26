#!/usr/bin/env bash
# Generic Yosys evidence only; no PDK/area/STA/power/layout is implied.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
BASE="${F10_EVIDENCE_DIR:-evidence/local}/generic"
mkdir -p "$BASE"
RTL=(rtl/f10_handshake_controller.sv rtl/f10_tiny_tapeout_top.sv rtl/tt_um_24101280_f10.sv)
for KIND in core wrapper; do
    if [ "$KIND" = core ]; then TOP=f10_handshake_controller; else TOP=tt_um_24101280_f10; fi
    OUT="$BASE/$KIND"
    mkdir -p "$OUT"
    { date -u '+UTC %Y-%m-%dT%H:%M:%SZ'; command -v yosys; yosys -V; } > "$OUT/tool_versions.txt" 2>&1
    sha256sum "${RTL[@]}" scripts/run_synth.sh scripts/summarize_synth.py > "$OUT/source_sha256.txt"
    cat > "$OUT/synth.ys" <<EOF
read_verilog -sv ${RTL[*]}
hierarchy -check -top $TOP
synth -top $TOP -flatten
delete t:\$scopeinfo
check -assert
tee -o $OUT/stat.txt stat
write_json $OUT/design.json
write_verilog -noattr $OUT/netlist.v
EOF
    printf 'timeout 60s yosys -Q -s %s/synth.ys\n' "$OUT" > "$OUT/commands.txt"
    set +e
    timeout 60s yosys -Q -s "$OUT/synth.ys" > "$OUT/yosys.log" 2>&1
    STATUS=$?
    set -e
    printf '%s\n' "$STATUS" > "$OUT/exit_code.txt"
    [ "$STATUS" = 0 ] || { cat "$OUT/yosys.log"; exit "$STATUS"; }
    python3 scripts/summarize_synth.py "$OUT" "$TOP"
done
OUT="$BASE/lint"
mkdir -p "$OUT"
if command -v verilator > /dev/null; then
    verilator --version > "$OUT/tool_versions.txt"
    set +e
    timeout 30s verilator --lint-only -Wall -Wno-fatal --top-module tt_um_24101280_f10 "${RTL[@]}" > "$OUT/verilator.log" 2>&1
    STATUS=$?
    set -e
    printf '%s\n' "$STATUS" > "$OUT/exit_code.txt"
    [ "$STATUS" = 0 ] || { cat "$OUT/verilator.log"; exit "$STATUS"; }
else
    printf 'NOT_RUN: verilator unavailable\n' > "$OUT/verilator.log"
fi
