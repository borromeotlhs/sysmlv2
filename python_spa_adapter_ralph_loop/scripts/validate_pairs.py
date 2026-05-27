#!/usr/bin/env python
import argparse, json, sys
from pathlib import Path

ap = argparse.ArgumentParser()
ap.add_argument('pair_file', nargs='?', default='data/pairs/sample_pairs.json')
args = ap.parse_args()
path = Path(args.pair_file)
if not path.exists():
    sys.exit(f'ERROR: pair file not found: {path}')
records = json.loads(path.read_text(encoding='utf-8'))
if not isinstance(records, list) or not records:
    sys.exit('ERROR: pair file must be a non-empty JSON array')
ids = set()
splits = {'train': 0, 'validation': 0}
for n, r in enumerate(records, start=1):
    for k in ['id', 'architecture_id', 'prompt_id', 'prompt', 'target_path', 'target_format', 'metadata']:
        if k not in r:
            sys.exit(f'ERROR: record {n} missing {k}')
    if r['id'] in ids:
        sys.exit(f'ERROR: duplicate pair id {r["id"]}')
    ids.add(r['id'])
    if not str(r['prompt']).strip():
        sys.exit(f'ERROR: record {r["id"]} has empty prompt')
    target = Path(r['target_path'])
    if not target.exists():
        sys.exit(f'ERROR: target path not found for {r["id"]}: {target}')
    split = r.get('metadata', {}).get('split')
    if split not in splits:
        sys.exit(f'ERROR: invalid split for {r["id"]}: {split}')
    splits[split] += 1
print(f'pair validation passed: records={len(records)} train={splits["train"]} validation={splits["validation"]}')
