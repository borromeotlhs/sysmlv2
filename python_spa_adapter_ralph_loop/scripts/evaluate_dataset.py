#!/usr/bin/env python
import json, sys
from pathlib import Path
for name in ['train.jsonl', 'validation.jsonl']:
    p = Path('data/targets') / name
    if not p.exists(): sys.exit(f'ERROR: missing {p}')
    count = 0
    for line in p.read_text(encoding='utf-8').splitlines():
        if not line.strip(): continue
        obj = json.loads(line)
        msgs = obj.get('messages')
        if not isinstance(msgs, list) or len(msgs) != 3: sys.exit(f'ERROR: bad messages in {p}')
        count += 1
    if count < 1: sys.exit(f'ERROR: no records in {p}')
print('dataset evaluation passed')
