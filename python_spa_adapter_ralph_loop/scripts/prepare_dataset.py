#!/usr/bin/env python
import argparse, json
from pathlib import Path

ap = argparse.ArgumentParser()
ap.add_argument('pair_file', nargs='?', default='data/pairs/sample_pairs.json')
ap.add_argument('--out-dir', default='data/targets')
args = ap.parse_args()
records = json.loads(Path(args.pair_file).read_text(encoding='utf-8'))
out = Path(args.out_dir)
out.mkdir(parents=True, exist_ok=True)
files = {'train': (out / 'train.jsonl').open('w', encoding='utf-8'), 'validation': (out / 'validation.jsonl').open('w', encoding='utf-8')}
counts = {'train': 0, 'validation': 0}
try:
    for r in records:
        target_text = Path(r['target_path']).read_text(encoding='utf-8')
        # Determine format from target file extension
        target_path = Path(r['target_path'])
        if target_path.suffix.lower() == '.sysml':
            system_msg = 'Generate a SysML v2 architecture definition matching the user request.'
        else:
            system_msg = 'Generate a SysML-style architecture JSON artifact matching the user request.'

        item = {
            'messages': [
                {'role': 'system', 'content': system_msg},
                {'role': 'user', 'content': r['prompt']},
                {'role': 'assistant', 'content': target_text},
            ],
            'metadata': {'pair_id': r['id'], 'architecture_id': r['architecture_id'], 'target_path': r['target_path']}
        }
        split = r['metadata']['split']
        files[split].write(json.dumps(item) + '\n')
        counts[split] += 1
finally:
    for f in files.values(): f.close()
manifest = {'source_pair_file': args.pair_file, 'train_count': counts['train'], 'validation_count': counts['validation'], 'total_count': sum(counts.values()), 'format': 'chat_messages_jsonl'}
(out / 'manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
print(json.dumps(manifest))
