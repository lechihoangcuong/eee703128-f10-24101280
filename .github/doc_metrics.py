"""Summarize real LibreLane metrics without substituting fabricated zeros."""
import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--run-root", default="runs")
parser.add_argument("--out", required=True)
parser.add_argument("--require-final", action="store_true")
args = parser.parse_args()
root = Path(args.run_root)
files = sorted(root.glob("**/metrics.json")) if root.exists() else []
finals = [p for p in files if "final" in p.parts]
selected = sorted(finals or files, key=lambda p: (p.stat().st_mtime_ns, str(p)))[-1:]  # exact source retained below
metrics = json.loads(selected[0].read_text()) if selected else {}
# Preserve keys and units in the source instead of guessing renamed variables.
key_metrics = {k: v for k, v in metrics.items() if any(s in k.lower() for s in ("area", "setup", "hold", "drc", "lvs", "power", "wirelength", "count"))}
gds = sorted(p for p in root.glob("**/final/**/*.gds") if p.is_file() and p.stat().st_size > 0) if root.exists() else []
result = {"metrics_source": str(selected[0]) if selected else None,
          "metrics_source_is_final": bool(selected and "final" in selected[0].parts),
          "final_gds_files": [{"path": str(p), "bytes": p.stat().st_size} for p in gds],
          "observed_metrics": key_metrics,
          "limits": "Missing values remain absent/null. Final GDS existence alone does not prove clean DRC/LVS or timing closure."}
out = Path(args.out)
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(result, indent=2)+"\n")
print(json.dumps(result, indent=2))
if args.require_final and not (gds and selected and "final" in selected[0].parts):
    raise SystemExit("No nonempty FINAL GDS and FINAL metrics found; inspect physical logs. No success claim is made.")
