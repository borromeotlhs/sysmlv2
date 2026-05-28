#!/usr/bin/env python3
"""
Integration tests - test end-to-end workflows
"""

import pytest
import json
from pathlib import Path

from sysml_parser import parse_sysml_to_json


@pytest.mark.integration
def test_architecture_roundtrip(architecture_files_dir):
    """Test loading and parsing architecture files"""
    if not architecture_files_dir.exists():
        pytest.skip("Architecture directory not found")

    arch_files = list(architecture_files_dir.glob("arch_*.sysml"))[:3]
    if not arch_files:
        pytest.skip("No architecture files found")

    for arch_file in arch_files:
        content = arch_file.read_text()
        result = parse_sysml_to_json(content, file_path=arch_file)

        # Verify basic structure
        assert 'id' in result, f"{arch_file.name}: Missing ID"
        assert 'name' in result, f"{arch_file.name}: Missing name"
        assert 'blocks' in result, f"{arch_file.name}: Missing blocks"
        assert 'connectors' in result, f"{arch_file.name}: Missing connectors"
        assert 'requirements' in result, f"{arch_file.name}: Missing requirements"


@pytest.mark.integration
def test_pair_files(sample_pairs_file):
    """Test that pair files can be loaded"""
    if not sample_pairs_file.exists():
        pytest.skip(f"Pair file not found: {sample_pairs_file}")

    with open(sample_pairs_file, 'r') as f:
        pairs = json.load(f)

    assert isinstance(pairs, list), "Pairs should be a list"
    assert len(pairs) > 0, "Pairs should not be empty"

    for pair in pairs[:3]:  # Test first 3 pairs
        assert 'description' in pair, "Pair missing description"
        assert 'sysml' in pair, "Pair missing sysml"


@pytest.mark.integration
def test_sample_sysml_parsing(sample_sysml_content):
    """Test parsing sample SysML content from fixture"""
    result = parse_sysml_to_json(sample_sysml_content)

    assert result['id'] == 'test_arch_001'
    assert len(result['blocks']) == 3
    assert len(result['requirements']) == 1
    assert len(result['connectors']) == 1


@pytest.mark.integration
def test_temp_file_parsing(temp_sysml_file):
    """Test parsing from temporary file"""
    content = temp_sysml_file.read_text()
    result = parse_sysml_to_json(content, file_path=temp_sysml_file)

    assert result['id'] == 'test_arch_001'
    assert len(result['blocks']) > 0
