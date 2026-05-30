#!/usr/bin/env python3
"""Test script for SAJAI generator."""
import json
import sys
from pathlib import Path

# Add spa module to path
sys.path.insert(0, str(Path(__file__).parent))

from spa.sajai_generator import generate_sajai
from spa.sysml_parser import parse_sysml_to_json


def test_with_json_ir():
    """Test generator with JSON IR input."""
    # Load sample architecture
    json_path = Path(__file__).parent / 'data' / 'architectures_json' / 'arch_000001.json'

    if not json_path.exists():
        print(f"Error: {json_path} not found")
        return False

    with open(json_path, 'r', encoding='utf-8') as f:
        sysml_ir = json.load(f)

    print(f"Loaded architecture: {sysml_ir['id']}")
    print(f"  Blocks: {len(sysml_ir['blocks'])}")
    print(f"  Ports: {len(sysml_ir['proxy_ports'])}")
    print(f"  Connectors: {len(sysml_ir['connectors'])}")

    # Generate SAJAI
    sajai = generate_sajai(sysml_ir)

    print(f"\nGenerated SAJAI:")
    print(f"  Format: {sajai['format']}")
    print(f"  Version: {sajai['version']}")
    print(f"  Scenes: {len(sajai['scenes'])}")

    for scene_name, scene in sajai['scenes'].items():
        print(f"\n  Scene: {scene_name}")
        print(f"    Parts: {len(scene['parts'])}")
        print(f"    Ports: {len(scene['ports'])}")
        print(f"    Connectors: {len(scene['connectors'])}")

    # Save output
    output_path = Path(__file__).parent / 'spa' / 'static' / 'sample-data' / 'generated_test.sajai'
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(sajai, f, indent=2)

    print(f"\nSaved to: {output_path}")
    return True


def test_with_sysml_file():
    """Test generator with .sysml file input."""
    # Find a .sysml file
    sysml_dir = Path(__file__).parent / 'data' / 'architectures_sysml'

    if not sysml_dir.exists():
        print("No .sysml directory found, skipping this test")
        return True

    sysml_files = list(sysml_dir.glob('*.sysml'))
    if not sysml_files:
        print("No .sysml files found, skipping this test")
        return True

    sysml_path = sysml_files[0]
    print(f"\nTesting with .sysml file: {sysml_path.name}")

    # Parse .sysml to IR
    with open(sysml_path, 'r', encoding='utf-8') as f:
        sysml_content = f.read()

    sysml_ir = parse_sysml_to_json(sysml_content, sysml_path)

    # Generate SAJAI
    sajai = generate_sajai(sysml_ir)

    print(f"Generated {len(sajai['scenes'])} scenes from {sysml_path.name}")

    return True


if __name__ == '__main__':
    print("Testing SAJAI Generator\n" + "=" * 50)

    success = True

    print("\nTest 1: JSON IR input")
    print("-" * 50)
    if not test_with_json_ir():
        success = False

    print("\n\nTest 2: .sysml file input")
    print("-" * 50)
    if not test_with_sysml_file():
        success = False

    print("\n" + "=" * 50)
    if success:
        print("All tests passed!")
        sys.exit(0)
    else:
        print("Some tests failed")
        sys.exit(1)
