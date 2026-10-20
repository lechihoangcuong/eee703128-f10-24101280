import json
import sys
from collections import Counter
from pathlib import Path

p, top = Path(sys.argv[1]), sys.argv[2]
module = json.loads((p / "design.json").read_text())["modules"][top]
types = Counter(cell["type"] for cell in module["cells"].values())
ff = sum(n for t, n in types.items() if "DFF" in t.upper())
latches = sum(n for t, n in types.items() if "LATCH" in t.upper())
assert ff > 0 and latches == 0, "Unexpected sequential structure"
result = dict(top=top, total_cells=len(module["cells"]), flip_flops=ff, latches=latches,
              combinational_cells=len(module["cells"])-ff-latches,
              cell_types=dict(sorted(types.items())),
              synthesis="Yosys generic, flattened; scope metadata excluded",
              limits="No PDK, mapped area, STA, power, layout, DRC or LVS result")
(p / "summary.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result))
