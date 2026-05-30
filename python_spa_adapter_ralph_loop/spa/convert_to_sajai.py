#!/usr/bin/env python3
"""
Convert SysML v2 architectures to SAJAI format.

Usage:
    python convert_to_sajai.py input.sysml output.sajai
    python convert_to_sajai.py input.json output.sajai
    python convert_to_sajai.py --batch data/architectures_json/ spa/static/sample-data/
"""
import argparse
import json
import sys
from pathlib import Path

from sajai_generator import generate_sajai
from sysml_parser import parse_sysml_to_json


def convert_file(input_path: Path, output_path: Path) -> bool:
    """
    Convert a single file to SAJAI format.

    Args:
        input_path: Path to .sysml or .json file
        output_path: Path for output .sajai file

    Returns:
        True if successful, False otherwise
    """
    try:
        # Determine input format
        if input_path.suffix == '.sysml':
            # Parse .sysml file
            with open(input_path, 'r', encoding='utf-8') as f:
                content = f.read()
            sysml_ir = parse_sysml_to_json(content, input_path)
        elif input_path.suffix == '.json':
            # Load JSON IR directly
            with open(input_path, 'r', encoding='utf-8') as f:
                sysml_ir = json.load(f)
        else:
            print(f"Error: Unsupported input format: {input_path.suffix}")
            return False

        # Generate SAJAI
        sajai = generate_sajai(sysml_ir)

        # Write output
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(sajai, f, indent=2)

        print(f"Converted {input_path.name} -> {output_path.name}")
        print(f"  Scenes: {len(sajai['scenes'])}")
        for scene_name, scene in sajai['scenes'].items():
            print(f"    {scene_name}: {len(scene['parts'])} parts, "
                  f"{len(scene['ports'])} ports, {len(scene['connectors'])} connectors")

        return True

    except Exception as e:
        print(f"Error converting {input_path}: {e}")
        import traceback
        traceback.print_exc()
        return False


def convert_batch(input_dir: Path, output_dir: Path, pattern: str = '*.json') -> int:
    """
    Convert all matching files in a directory.

    Args:
        input_dir: Directory containing input files
        output_dir: Directory for output files
        pattern: Glob pattern for input files

    Returns:
        Number of files successfully converted
    """
    input_files = list(input_dir.glob(pattern))
    if not input_files:
        print(f"No files matching {pattern} found in {input_dir}")
        return 0

    success_count = 0
    for input_path in input_files:
        output_path = output_dir / f"{input_path.stem}.sajai"
        if convert_file(input_path, output_path):
            success_count += 1
        print()  # Blank line between files

    return success_count


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Convert SysML v2 architectures to SAJAI format for 3D visualization'
    )
    parser.add_argument(
        'input',
        type=Path,
        help='Input file (.sysml or .json) or directory for batch mode'
    )
    parser.add_argument(
        'output',
        type=Path,
        help='Output file (.sajai) or directory for batch mode'
    )
    parser.add_argument(
        '--batch',
        action='store_true',
        help='Batch mode: convert all files in input directory'
    )
    parser.add_argument(
        '--pattern',
        default='*.json',
        help='File pattern for batch mode (default: *.json)'
    )

    args = parser.parse_args()

    if args.batch:
        # Batch mode
        if not args.input.is_dir():
            print(f"Error: Input must be a directory in batch mode: {args.input}")
            sys.exit(1)

        if args.output.exists() and not args.output.is_dir():
            print(f"Error: Output must be a directory in batch mode: {args.output}")
            sys.exit(1)

        count = convert_batch(args.input, args.output, args.pattern)
        print(f"\nConverted {count} files")
        sys.exit(0 if count > 0 else 1)
    else:
        # Single file mode
        if not args.input.exists():
            print(f"Error: Input file not found: {args.input}")
            sys.exit(1)

        success = convert_file(args.input, args.output)
        sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
