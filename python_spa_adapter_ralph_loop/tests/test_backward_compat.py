#!/usr/bin/env python3
"""
Test backward compatibility - verify that monolithic .sysml files still work.
"""

import pytest
from pathlib import Path

from sysml_parser import parse_sysml_to_json, load_with_imports


@pytest.mark.validation
def test_monolithic_file():
    """Test that existing monolithic .sysml files still parse correctly"""
    # Load an existing architecture file
    arch_file = Path(__file__).parent.parent / "data/architectures/arch_000001.sysml"

    if not arch_file.exists():
        pytest.skip(f"File not found: {arch_file}")

    content = arch_file.read_text()

    # Parse without file_path (old way)
    result1 = parse_sysml_to_json(content)

    # Parse with file_path (new way, but no imports in file)
    result2 = parse_sysml_to_json(content, file_path=arch_file)

    # Results should be identical
    assert result1['id'] == result2['id'], "IDs differ between old and new parsing"
    assert result1['source'] == result2['source'], "Source differs between old and new parsing"
    assert len(result1['blocks']) == len(result2['blocks']), "Block count differs"


@pytest.mark.validation
@pytest.mark.slow
def test_multiple_architectures():
    """Test multiple existing architecture files"""
    arch_dir = Path(__file__).parent.parent / "data/architectures"
    sysml_files = list(arch_dir.glob("arch_*.sysml"))[:5]  # Test first 5

    if not sysml_files:
        pytest.skip("No architecture files found")

    for arch_file in sysml_files:
        content = arch_file.read_text()
        result = parse_sysml_to_json(content, file_path=arch_file)

        assert result['id'], f"{arch_file.name}: Missing ID"
        assert len(result['blocks']) > 0, f"{arch_file.name}: No blocks parsed"


@pytest.mark.validation
def test_new_import_feature():
    """Test new import feature with test files"""
    # Check if test example exists
    test_dir = Path(__file__).parent.parent / "test_import_example"
    if not test_dir.exists():
        pytest.skip("Test import example not found")

    bdd_file = test_dir / "views/bdd.sysml"
    if not bdd_file.exists():
        pytest.skip("BDD view file not found")

    result = load_with_imports(bdd_file)

    assert result['source'] == 'view', f"Expected 'view', got '{result['source']}'"
    assert 'view_metadata' in result, "Expected view_metadata in result"
    assert len(result['blocks']) > 0, "Expected blocks from imported model"
