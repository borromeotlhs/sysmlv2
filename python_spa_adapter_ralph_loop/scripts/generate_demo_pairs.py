#!/usr/bin/env python
"""
Generate demo training pairs from .sysml architecture files.

This script parses .sysml files (primary source of truth) and generates
training pairs with placeholder prompts for human editing.

Legacy note: If .json files exist in data/architectures/, they are ignored.
Only .sysml files are used as the authoritative source.
"""
import json
from pathlib import Path

# Import SysML parser
try:
    from spa.sysml_parser import parse_sysml_to_json
except ImportError:
    import sys
    sys.path.insert(0, str(Path(__file__).parent.parent))
    from spa.sysml_parser import parse_sysml_to_json

arch_dir = Path('data/architectures')
out = Path('data/pairs/sample_pairs.json')
out.parent.mkdir(parents=True, exist_ok=True)
records = []

# PRIMARY SOURCE: Only scan for .sysml files (authoritative format)
# Legacy .json files in data/architectures/ are ignored
arch_files = list(arch_dir.glob('arch_*.sysml'))

if not arch_files:
    print(f'ERROR: No .sysml files found in {arch_dir}')
    print('Run scripts/generate_varied_architectures.py first')
    exit(1)

for idx, arch_path in enumerate(sorted(arch_files), start=1):
    # Parse .sysml to IR (in-memory only)
    arch = parse_sysml_to_json(arch_path.read_text(encoding='utf-8'))

    split = 'validation' if idx == 1 else 'train'
    records.append({
        'id': f'pair_{idx:06d}_human_editable_demo',
        'architecture_id': arch['id'],
        'prompt_id': f'prompt_{idx:06d}_human_editable_demo',
        'prompt': f'DEMO ONLY: write your real human-authored prompt for {arch["name"]}.',
        'target_path': str(arch_path).replace('\\', '/'),
        'target_format': 'sysml_v2_textual',
        'metadata': {'split': split, 'authoring_mode': 'demo_editable'}
    })
out.write_text(json.dumps(records, indent=2), encoding='utf-8')
print(f'Generated demo editable pair file with {len(records)} records at {out}')
print(f'Source: {len(records)} .sysml files from {arch_dir}')
