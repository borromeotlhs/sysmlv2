#!/usr/bin/env python
"""
Convert JSON IR architecture files to SysML v2 textual syntax (.sysml).

This script reads JSON architecture files and generates valid SysML v2 code
that can be validated with the SysML v2 Pilot Implementation.

This script now uses the reusable lib/sysml_generator.py module.

Usage:
    python3 scripts/json_to_sysml.py                    # Convert all JSON files
    python3 scripts/json_to_sysml.py --input data/architectures/arch_000001.json
    python3 scripts/json_to_sysml.py --output outputs/sysml/
"""
import json
import argparse
import sys
from pathlib import Path

# Add lib directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'lib'))

from sysml_generator import generate_sysml_from_dict


def convert_file(input_path: Path, output_dir: Path):
    """Convert a single JSON file to .sysml"""
    try:
        arch = json.loads(input_path.read_text(encoding='utf-8'))
        sysml_content = generate_sysml_from_dict(arch)

        # Output filename: arch_000001.json -> arch_000001.sysml
        output_file = output_dir / input_path.with_suffix('.sysml').name
        output_file.write_text(sysml_content, encoding='utf-8')

        print(f'✓ {input_path.name} -> {output_file.name}')
        return True

    except Exception as e:
        print(f'✗ {input_path.name}: {e}')
        return False


def main():
    parser = argparse.ArgumentParser(
        description='Convert JSON IR to SysML v2 textual syntax'
    )
    parser.add_argument(
        '--input',
        type=Path,
        help='Input JSON file or directory (default: data/architectures/)'
    )
    parser.add_argument(
        '--output',
        type=Path,
        default=Path('outputs/sysml'),
        help='Output directory for .sysml files (default: outputs/sysml/)'
    )

    args = parser.parse_args()

    # Determine input path
    if args.input:
        input_path = args.input
    else:
        input_path = Path('data/architectures')

    # Create output directory
    args.output.mkdir(parents=True, exist_ok=True)

    # Collect JSON files
    if input_path.is_file():
        json_files = [input_path]
    elif input_path.is_dir():
        json_files = sorted(input_path.glob('*.json'))
    else:
        print(f'Error: {input_path} does not exist')
        return 1

    if not json_files:
        print(f'No JSON files found in {input_path}')
        return 1

    # Convert files
    print(f'Converting {len(json_files)} files...')
    success = 0
    for json_file in json_files:
        if convert_file(json_file, args.output):
            success += 1

    print(f'\nConverted {success}/{len(json_files)} files to {args.output}')
    return 0 if success == len(json_files) else 1


if __name__ == '__main__':
    exit(main())
