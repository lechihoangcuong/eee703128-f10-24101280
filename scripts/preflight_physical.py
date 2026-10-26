"""Capture tool availability, distinct from an attempted physical flow."""
import datetime
import json
import os
import shutil
import subprocess
from pathlib import Path

out = Path(os.environ.get("F10_EVIDENCE_DIR", "evidence/local")) / "physical-preflight"
out.mkdir(parents=True, exist_ok=True)
names = ("librelane", "openroad", "sta", "magic", "klayout", "nix-shell", "docker")
result = {"utc": datetime.datetime.now(datetime.timezone.utc).isoformat(), "kind": "availability_preflight_only",
          "flow_attempted": False, "tools": {n: shutil.which(n) for n in names},
          "pdk_environment": {n: os.environ.get(n) for n in ("PDK_ROOT", "PDK", "STD_CELL_LIBRARY")}}
result["default_pdk_roots"] = {str(Path.home()/n): (Path.home()/n).exists() for n in (".ciel", ".volare")}
(out / "preflight.json").write_text(json.dumps(result, indent=2)+"\n")
lines = ["Physical tool preflight; this does NOT report a failed flow.", "UTC " + result["utc"]]
for name, location in result["tools"].items():
    lines.append(f"command -v {name}: {location or 'NOT_FOUND'}")
for name, value in result["pdk_environment"].items():
    lines.append(f"{name}={value if value is not None else 'UNSET'}")
for location, present in result["default_pdk_roots"].items():
    lines.append(f"directory {location}: {'EXISTS' if present else 'ABSENT'}")
lines.append("flow_attempted=false; CI physical run and its URL remain pending.")
(out / "preflight.log").write_text("\n".join(lines)+"\n")
print("\n".join(lines))
