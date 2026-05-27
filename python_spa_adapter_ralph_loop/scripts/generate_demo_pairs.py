#!/usr/bin/env python
import json
from pathlib import Path

arch_dir = Path('data/architectures')
out = Path('data/pairs/sample_pairs.json')
out.parent.mkdir(parents=True, exist_ok=True)
records = []
for idx, arch_path in enumerate(sorted(arch_dir.glob('arch_*.json')), start=1):
    arch = json.loads(arch_path.read_text(encoding='utf-8'))
    split = 'validation' if idx == 1 else 'train'
    records.append({
        'id': f'pair_{idx:06d}_human_editable_demo',
        'architecture_id': arch['id'],
        'prompt_id': f'prompt_{idx:06d}_human_editable_demo',
        'prompt': f'DEMO ONLY: write your real human-authored prompt for {arch["name"]}.',
        'target_path': str(arch_path).replace('\\', '/'),
        'target_format': 'json',
        'metadata': {'split': split, 'authoring_mode': 'demo_editable'}
    })
out.write_text(json.dumps(records, indent=2), encoding='utf-8')
print(f'generated demo editable pair file with {len(records)} records at {out}')
