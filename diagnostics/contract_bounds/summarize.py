"""Summarize measured diagnostics; cross-check CSV against actual VCD edges."""
from pathlib import Path
import csv
import hashlib
import json
import re
import sys

SOURCE = Path(__file__).resolve().parent
ROOT = SOURCE.parents[1]
HERE = Path(sys.argv[1]).resolve()
rows = list(csv.DictReader((HERE / "diagnostic_cases.csv").open()))
log = (HERE / "simulation.log").read_text()
match = re.search(r"DIAGNOSTIC_SUMMARY valid_cases=(\d+) unsupported_observations=(\d+) checks=(\d+) errors=(\d+)", log)
if not match:
    raise RuntimeError("missing completed diagnostic summary")
valid, unsupported, checks, errors = map(int, match.groups())
assert (valid, unsupported, errors) == (3, 1, 0) and checks > 0
assert (HERE / "compile_exit_code.txt").read_text().strip() == "0"
assert (HERE / "simulation_exit_code.txt").read_text().strip() == "0"
assert len(rows) == 4

codes = {}
events = {}
values = {}
depth = 0
at = 0
for line in (HERE / "f10_contract_bounds.vcd").open():
    line = line.strip()
    if line.startswith("$scope "):
        depth += 1
    elif line == "$upscope $end":
        depth -= 1
    elif line.startswith("$var ") and depth == 1:
        fields = line.split()
        if fields[4] in {"req", "ack", "done"}:
            codes[fields[3]] = fields[4]
            events[fields[4]] = []
    elif line.startswith("#"):
        at = int(line[1:])
    elif line and line[0] in "01xz" and line[1:] in codes:
        name = codes[line[1:]]
        previous = values.get(name)
        if previous in {"0", "1"} and line[0] in {"0", "1"} and previous != line[0]:
            assert at % 1000 == 0, "unexpected fractional ns edge"
            events[name].append((at // 1000, int(line[0])))
        values[name] = line[0]

for row in rows:
    for key in list(row):
        if key not in {"case_id", "classification"}:
            row[key] = int(row[key])
    assert (row["req_up_ns"], 1) in events["req"]
    assert (row["ack_up_ns"], 1) in events["ack"]
    assert (row["req_down_ns"], 0) in events["req"]
    assert (row["ack_down_ns"], 0) in events["ack"]
    assert (row["result_ns"], 1) in events["done"]
    assert row["result_ns"] - row["accepted_ns"] == 10 * row["latency_cycles"]
    if row["classification"] == "VALID_PEER":
        assert row["latency_cycles"] == 2 * max(1, row["N"]) + 1
        assert row["req_up_ns"] < row["ack_up_ns"] < row["req_down_ns"] < row["ack_down_ns"] < row["result_ns"]
    else:
        assert row["classification"] == "OBSERVED_UNSUPPORTED_PEER"
        assert row["ack_up_ns"] < row["ack_down_ns"] < row["req_down_ns"] < row["result_ns"]

digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
summary = {
    "status": "COMPLETED_EXPECTATIONS_MATCHED",
    "valid_peer_cases": valid,
    "unsupported_peer_observations": unsupported,
    "checks": checks,
    "errors": errors,
    "clock_period_ns": 10,
    "sample_delay_ns": 1,
    "vcd_edge_crosscheck": "matched all five recorded signal edges per experiment",
    "cases": rows,
    "original_suite_cases_unchanged": 1035,
    "limits": "Three supplemental legal-peer cases and one unsupported-peer observation. Not exhaustive input-sequence coverage or formal proof. Early ACK drop is not a valid-protocol PASS.",
    "sha256": {
        "core_rtl": digest(ROOT / "rtl/f10_handshake_controller.sv"),
        "diagnostic_tb": digest(SOURCE / "f10_contract_bounds_tb.sv"),
        "vcd": digest(HERE / "f10_contract_bounds.vcd"),
        "simulation_log": digest(HERE / "simulation.log"),
    },
}
(HERE / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps({key: summary[key] for key in ("status", "valid_peer_cases", "unsupported_peer_observations", "checks", "errors")}))
