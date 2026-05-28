#!/usr/bin/env python3
"""
Test script for import statement parsing functionality.
"""

import pytest
from pathlib import Path

from sysml_parser import (
    parse_import_statement,
    resolve_import_path,
    load_with_imports,
    extract_view_metadata,
    parse_sysml_to_json
)


@pytest.mark.parser
@pytest.mark.parametrize("line,expected", [
    ('import "model.sysml";', "model.sysml"),
    ('  import "model.sysml";  ', "model.sysml"),
    ('import "../model.sysml";', "../model.sysml"),
    ('import "views/bdd.sysml";', "views/bdd.sysml"),
    ('import arch_000001::*;', None),  # Namespace import, not file
    ('part def Test {', None),  # Not an import
])
def test_parse_import_statement(line, expected):
    """Test parsing import statements"""
    result = parse_import_statement(line)
    assert result == expected, f"'{line}' -> {result} (expected: {expected})"


@pytest.mark.parser
@pytest.mark.parametrize("import_target,expected_relative", [
    ("model.sysml", "model.sysml"),
    ("../model.sysml", "model.sysml"),
])
def test_resolve_import_path(import_target, expected_relative):
    """Test resolving import paths"""
    view_file = Path("/data/arch_001/views/bdd.sysml")
    expected = Path("/data/arch_001") / expected_relative
    result = resolve_import_path(view_file, import_target)
    assert result == expected, f"{import_target} -> {result} (expected: {expected})"


@pytest.mark.parser
def test_extract_view_metadata():
    """Test extracting view metadata from comments"""
    content = '''
    package test {
        comment /*
            @viewType: BlockDefinitionDiagram
            @showAttributes: true
            @showPorts: false
            @context: test::System
        */
    }
    '''

    result = extract_view_metadata(content)

    expected = {
        'viewType': 'BlockDefinitionDiagram',
        'showAttributes': True,
        'showPorts': False,
        'context': 'test::System'
    }

    assert result == expected, f"Metadata mismatch: {result} != {expected}"


@pytest.mark.parser
def test_load_model_file():
    """Test loading model file without imports"""
    model_path = Path(__file__).parent.parent / "test_import_example" / "model.sysml"

    if not model_path.exists():
        pytest.skip(f"Model file not found: {model_path}")

    result = parse_sysml_to_json(model_path.read_text(), file_path=model_path)

    assert result['id'] == 'test_arch_001', f"Expected 'test_arch_001', got '{result['id']}'"
    assert len(result['blocks']) == 4, f"Expected 4 blocks, got {len(result['blocks'])}"
    assert len(result['requirements']) == 2, f"Expected 2 requirements, got {len(result['requirements'])}"


@pytest.mark.parser
def test_load_with_imports():
    """Test loading view file with imports"""
    bdd_path = Path(__file__).parent.parent / "test_import_example" / "views" / "bdd.sysml"

    if not bdd_path.exists():
        pytest.skip(f"BDD view file not found: {bdd_path}")

    result = load_with_imports(bdd_path)

    assert result['id'] == 'test_arch_001', f"Expected 'test_arch_001', got '{result['id']}'"
    assert result['source'] == 'view', f"Expected 'view', got '{result['source']}'"
    assert len(result['blocks']) == 4, f"Expected 4 blocks, got {len(result['blocks'])}"
    assert 'view_metadata' in result, "Expected view_metadata in result"
    assert result['view_metadata'].get('viewType') == 'BlockDefinitionDiagram'


@pytest.mark.parser
def test_load_ibd_with_relative_import():
    """Test loading IBD view with relative import path"""
    ibd_path = Path(__file__).parent.parent / "test_import_example" / "views" / "ibd.sysml"

    if not ibd_path.exists():
        pytest.skip(f"IBD view file not found: {ibd_path}")

    result = load_with_imports(ibd_path)

    assert result['id'] == 'test_arch_001', f"Expected 'test_arch_001', got '{result['id']}'"
    assert result['source'] == 'view', f"Expected 'view', got '{result['source']}'"
    assert len(result['blocks']) == 4, f"Expected 4 blocks, got {len(result['blocks'])}"
    assert result['view_metadata'].get('viewType') == 'InternalBlockDiagram'
    assert result['view_metadata'].get('context') == 'test_arch_001::TestSystem'


@pytest.mark.parser
def test_circular_import_detection(tmp_path):
    """Test circular import detection"""
    # Create two files that import each other
    circular_dir = tmp_path / "circular"
    circular_dir.mkdir()

    file_a = circular_dir / "a.sysml"
    file_b = circular_dir / "b.sysml"

    file_a.write_text('import "b.sysml";\npackage a {}')
    file_b.write_text('import "a.sysml";\npackage b {}')

    with pytest.raises(ValueError, match="Circular import"):
        load_with_imports(file_a)
