#!/usr/bin/env python
"""
Update pair files to reference .sysml architectures instead of .json
"""
import json
from pathlib import Path


def update_pair_file(pair_file: Path):
    """Update a single pair file to use .sysml references"""
    pairs = json.loads(pair_file.read_text(encoding='utf-8'))

    updated = False
    for pair in pairs:
        # Update target_path from .json to .sysml
        if 'target_path' in pair and pair['target_path'].endswith('.json'):
            pair['target_path'] = pair['target_path'].replace('.json', '.sysml')
            updated = True

        # Update target_format
        if 'target_format' in pair and pair['target_format'] == 'json':
            pair['target_format'] = 'sysml'
            updated = True

    if updated:
        pair_file.write_text(json.dumps(pairs, indent=2), encoding='utf-8')
        print(f'✓ Updated {pair_file.name}')
        return True
    else:
        print(f'- No changes needed for {pair_file.name}')
        return False


def main():
    pair_dir = Path('data/pairs')

    if not pair_dir.exists():
        print(f'Error: {pair_dir} does not exist')
        return 1

    pair_files = list(pair_dir.glob('*.json'))

    if not pair_files:
        print(f'No pair files found in {pair_dir}')
        return 0

    print(f'Updating {len(pair_files)} pair file(s)...\n')

    updated_count = 0
    for pair_file in sorted(pair_files):
        if update_pair_file(pair_file):
            updated_count += 1

    print(f'\nUpdated {updated_count}/{len(pair_files)} pair files')
    return 0


if __name__ == '__main__':
    exit(main())
