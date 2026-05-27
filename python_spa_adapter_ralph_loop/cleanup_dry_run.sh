#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
import json
m=json.load(open('.ralph_pack.json'))
print('Would remove owned deployable paths:')
for p in m['owned_paths']:
    print('  ' + p)
print('\nWould preserve:')
for p in m['preserved_paths']:
    print('  ' + p)
PY
