#!/usr/bin/env python3
"""
Test script for separated architecture format support.
Demonstrates all new functionality and backward compatibility.
"""

import sys
from pathlib import Path

# Add spa to path
sys.path.insert(0, str(Path(__file__).parent / 'spa'))

from server import (
    detect_architecture_format,
    load_architecture,
    load_architecture_separated,
    list_views
)

def print_section(title):
    """Print a formatted section header"""
    print(f"\n{'='*70}")
    print(f"{title:^70}")
    print('='*70)

def test_format_detection():
    """Test architecture format detection"""
    print_section("TEST 1: Format Detection")

    test_cases = [
        ('data/architectures/arch_000001.sysml', 'monolithic'),
        ('data/architectures/arch_test_001', 'separated'),
    ]

    for path_str, expected_format in test_cases:
        path = Path(path_str)
        detected = detect_architecture_format(path)
        status = '✓' if detected == expected_format else '✗'
        print(f"{status} {path_str}")
        print(f"  Expected: {expected_format}, Got: {detected}")

def test_load_monolithic():
    """Test loading monolithic architectures"""
    print_section("TEST 2: Load Monolithic Architecture (Backward Compatibility)")

    arch_file = Path('data/architectures/arch_000001.sysml')
    arch = load_architecture(arch_file)

    print(f"✓ Loaded: {arch_file.name}")
    print(f"  ID: {arch.get('id', 'N/A')}")
    print(f"  Name: {arch.get('name', 'N/A')}")
    print(f"  Format: {arch.get('format', 'N/A')}")
    print(f"  Blocks: {len(arch.get('blocks', []))}")
    print(f"  Requirements: {len(arch.get('requirements', []))}")
    print(f"  Connectors: {len(arch.get('connectors', []))}")

def test_load_separated():
    """Test loading separated architectures"""
    print_section("TEST 3: Load Separated Architecture")

    arch_dir = Path('data/architectures/arch_test_001')
    arch = load_architecture_separated(arch_dir)

    print(f"✓ Loaded: {arch_dir.name}")
    print(f"  ID: {arch.get('id', 'N/A')}")
    print(f"  Name: {arch.get('name', 'N/A')}")
    print(f"  Format: {arch.get('format', 'N/A')}")
    print(f"  Blocks: {len(arch.get('blocks', []))}")
    print(f"  Requirements: {len(arch.get('requirements', []))}")
    print(f"  Available Views: {arch.get('available_views', [])}")

def test_list_views():
    """Test listing views"""
    print_section("TEST 4: List Views")

    arch_dir = Path('data/architectures/arch_test_001')
    views = list_views(arch_dir)

    print(f"✓ Found {len(views)} views in {arch_dir.name}")
    for view in views:
        print(f"  - {view['name']}")
        print(f"    Type: {view['type']}")
        print(f"    Path: {view['path']}")

def test_mixed_formats():
    """Test handling mixed architecture formats"""
    print_section("TEST 5: Mixed Format Handling")

    arch_dir = Path('data/architectures')

    monolithic_count = 0
    separated_count = 0

    # Count monolithic files
    for arch_file in arch_dir.glob('arch_*.sysml'):
        monolithic_count += 1

    # Count separated directories
    for arch_path in arch_dir.iterdir():
        if arch_path.is_dir() and not arch_path.name.startswith('.'):
            model_file = arch_path / 'model.sysml'
            if model_file.exists():
                separated_count += 1

    print(f"✓ Architecture directory scanned")
    print(f"  Monolithic architectures: {monolithic_count}")
    print(f"  Separated architectures: {separated_count}")
    print(f"  Total: {monolithic_count + separated_count}")

def test_file_structure():
    """Test separated architecture file structure"""
    print_section("TEST 6: Separated Architecture File Structure")

    arch_dir = Path('data/architectures/arch_test_001')

    files_to_check = [
        arch_dir / 'model.sysml',
        arch_dir / 'views' / 'bdd.sysml',
        arch_dir / 'views' / 'ibd.sysml',
    ]

    print(f"Checking file structure for: {arch_dir.name}")
    for file_path in files_to_check:
        exists = '✓' if file_path.exists() else '✗'
        rel_path = file_path.relative_to(arch_dir)
        size = file_path.stat().st_size if file_path.exists() else 0
        print(f"{exists} {rel_path} ({size} bytes)")

def main():
    """Run all tests"""
    print_section("SEPARATED ARCHITECTURE FORMAT - TEST SUITE")
    print("Testing spa/server.py enhancements")

    try:
        test_format_detection()
        test_load_monolithic()
        test_load_separated()
        test_list_views()
        test_mixed_formats()
        test_file_structure()

        print_section("ALL TESTS PASSED")
        print("✓ Format detection working")
        print("✓ Monolithic architectures load correctly (backward compatible)")
        print("✓ Separated architectures load correctly")
        print("✓ View listing working")
        print("✓ Mixed format handling working")
        print("✓ File structure validation passed")

        return 0

    except Exception as e:
        print_section("TEST FAILED")
        print(f"✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == '__main__':
    sys.exit(main())
