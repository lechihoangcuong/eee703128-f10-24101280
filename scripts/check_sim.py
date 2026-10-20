"""Reject missing/partial runs and errors; never use mere PASS text as proof."""
import csv
import json
import re
import sys
from pathlib import Path

kind, location = sys.argv[1:]
p = Path(location)
log = (p / "simulation.log").read_text(encoding="utf-8")
assert not re.search(r"^(FAIL|FATAL)", log, re.M), "Failure in simulator log"
assert (p / "compile_exit_code.txt").read_text().strip() == "0"
assert (p / "simulation_exit_code.txt").read_text().strip() == "0"
if kind == "core":
    matches = re.findall(r"SUMMARY cases=(\d+) failed_cases=(\d+) cycles=(\d+) checks=(\d+) errors=(\d+) seed=([A-F0-9]+) stress_resets=(\d+)", log)
    assert len(matches) == 1, "Missing/repeated core summary"
    cases, failed, cycles, checks, errors, seed, resets = matches[0]
    cases, failed, cycles, checks, errors, resets = map(int, (cases, failed, cycles, checks, errors, resets))
    rows = list(csv.DictReader((p / "case_results.csv").open()))
    case_rows = [r for r in rows if r["case_id"] != "SUMMARY"]
    assert cases == 1035 and len(case_rows) == cases
    assert len({r["case_id"] for r in case_rows}) == cases
    assert all(r["result"] == "PASS" and int(r["errors"]) == 0 for r in case_rows)
    # TB performs three final run-integrity checks after end_case().
    final_aggregate_checks = 3
    assert checks == sum(int(r["checks"]) for r in case_rows) + final_aggregate_checks
    summary_rows = [r for r in rows if r["case_id"] == "SUMMARY"]
    assert len(summary_rows) == 1 and int(summary_rows[0]["checks"]) == checks
    assert "ALL TESTS PASSED: F10 core" in log
    result = dict(cases=cases, failed_cases=failed, cycles=cycles, checks=checks, errors=errors,
                  final_aggregate_checks=final_aggregate_checks, seed=seed, stress_resets=resets)
else:
    matches = re.findall(r"WRAPPER_SUMMARY cases=(\d+) failed_cases=(\d+) checks=(\d+) errors=(\d+)", log)
    assert len(matches) == 1, "Missing/repeated wrapper summary"
    cases, failed, checks, errors = map(int, matches[0])
    rows = list(csv.DictReader((p / "wrapper_cases.csv").open()))
    assert cases == 11 and len(rows) == cases
    assert all(int(r["errors"]) == 0 for r in rows)
    assert checks == sum(int(r["checks"]) for r in rows)
    assert "WRAPPER_ALL_TESTS_PASSED" in log
    result = dict(cases=cases, failed_cases=failed, checks=checks, errors=errors)
assert failed == 0 and errors == 0 and checks > 0
result["status"] = "PASSED"
(p / "summary.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result))
