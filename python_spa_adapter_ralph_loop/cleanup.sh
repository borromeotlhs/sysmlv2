#!/usr/bin/env bash
set -euo pipefail
if [ ! -f .ralph_pack.json ]; then
  echo "ERROR: .ralph_pack.json not found" >&2
  exit 1
fi
printf 'This will remove only owned deployable paths listed in .ralph_pack.json. Type DELETE to continue: '
read -r answer
if [ "$answer" != "DELETE" ]; then
  echo "Cleanup cancelled."
  exit 0
fi
python3 - <<'PY'
import json, shutil
from pathlib import Path
m=json.load(open('.ralph_pack.json'))
for raw in m['owned_paths']:
    p=Path(raw)
    if not p.exists():
        continue
    if p.is_dir():
        shutil.rmtree(p)
    else:
        p.unlink()
    print('removed', raw)
print('Cleanup complete. Preserved user/output data paths were not removed.')
PY
