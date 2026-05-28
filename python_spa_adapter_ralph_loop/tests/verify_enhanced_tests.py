#!/usr/bin/env python3
"""
Verification script to test enhanced parser test suite without pytest.
Runs a subset of the new tests to verify functionality.
"""

import sys
from pathlib import Path
import tempfile

# Add project paths
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT / 'spa'))
sys.path.insert(0, str(PROJECT_ROOT / 'scripts'))
sys.path.insert(0, str(PROJECT_ROOT / 'lib'))

from sysml_parser import (
    parse_sysml_to_json,
    parse_import_statement,
    resolve_import_path,
    has_imports,
    extract_package_name,
    extract_domain_comment,
    extract_view_metadata,
    extract_part_definitions,
    extract_ports_from_parts,
    extract_requirements,
    extract_compositions,
    load_with_imports
)


def test_empty_package():
    """Test parsing of minimal empty package"""
    print("Testing: Empty package handling...")
    empty = "package empty_arch { }"
    arch = parse_sysml_to_json(empty)
    assert arch['id'] == 'empty_arch', f"Expected 'empty_arch', got '{arch['id']}'"
    assert arch['blocks'] == [], f"Expected no blocks, got {arch['blocks']}"
    print("  ✓ Empty package test passed")


def test_alternative_connection_syntax():
    """Test alternative connection syntax"""
    print("Testing: Alternative connection syntax...")
    content = """package test {
    part def BlockA { port p1; }
    part def BlockB { port p2; }

    part system : BlockA {
        part b : BlockB;
        connect p1 to b.p2;
    }
}
"""
    arch = parse_sysml_to_json(content)
    assert len(arch['connectors']) == 1, f"Expected 1 connector, got {len(arch['connectors'])}"
    print("  ✓ Alternative connection syntax test passed")


def test_parse_import_statement():
    """Test import statement parsing"""
    print("Testing: Import statement parsing...")

    # Test file import
    line = 'import "model.sysml";'
    result = parse_import_statement(line)
    assert result == "model.sysml", f"Expected 'model.sysml', got '{result}'"

    # Test namespace import (should return None)
    line = 'import ScalarValues::*;'
    result = parse_import_statement(line)
    assert result is None, f"Expected None for namespace import, got '{result}'"

    print("  ✓ Import statement parsing test passed")


def test_has_imports():
    """Test import detection"""
    print("Testing: Import detection...")

    with_import = 'import "model.sysml";\npackage test {}'
    assert has_imports(with_import) is True, "Should detect file import"

    without_import = 'import ScalarValues::*;\npackage test {}'
    assert has_imports(without_import) is False, "Should not detect namespace import"

    print("  ✓ Import detection test passed")


def test_resolve_import_path():
    """Test import path resolution"""
    print("Testing: Import path resolution...")

    view_file = Path("/data/arch_001/views/bdd.sysml")
    import_target = "model.sysml"

    resolved = resolve_import_path(view_file, import_target)
    expected = Path("/data/arch_001/model.sysml")

    assert resolved == expected, f"Expected {expected}, got {resolved}"

    print("  ✓ Import path resolution test passed")


def test_view_metadata_extraction():
    """Test extraction of view metadata"""
    print("Testing: View metadata extraction...")

    content = """/*
    @viewType: BlockDefinitionDiagram
    @showPorts: true
    @context: test_arch::System
*/

package test_view {}
"""
    metadata = extract_view_metadata(content)

    assert metadata['viewType'] == 'BlockDefinitionDiagram', \
        f"Expected 'BlockDefinitionDiagram', got '{metadata.get('viewType')}'"
    assert metadata['showPorts'] is True, \
        f"Expected True, got {metadata.get('showPorts')}"
    assert metadata['context'] == 'test_arch::System', \
        f"Expected 'test_arch::System', got '{metadata.get('context')}'"

    print("  ✓ View metadata extraction test passed")


def test_multiplicity_parsing():
    """Test parsing of multiplicity specifications"""
    print("Testing: Multiplicity parsing...")

    content = """package test {
    part def Vehicle {
        part wheels : Wheel[4];
        part engine : Engine[1];
    }
    part def Wheel {}
    part def Engine {}
}
"""
    arch = parse_sysml_to_json(content)
    compositions = arch['compositions']

    wheel_comp = next((c for c in compositions if c['child'] == 'Wheel'), None)
    assert wheel_comp is not None, "Wheel composition not found"
    assert wheel_comp['multiplicity'] == '4', \
        f"Expected multiplicity '4', got '{wheel_comp['multiplicity']}'"

    print("  ✓ Multiplicity parsing test passed")


def test_unicode_handling():
    """Test Unicode character handling"""
    print("Testing: Unicode character handling...")

    content = """package unicode_test {
    // Architecture with Unicode: π Test
    // Domain: test

    part def System₀ {
        attribute temp°C : Real [1];
    }
}
"""
    arch = parse_sysml_to_json(content)
    assert arch['id'] == 'unicode_test', f"Expected 'unicode_test', got '{arch['id']}'"

    print("  ✓ Unicode handling test passed")


def test_untyped_ports():
    """Test parsing of untyped ports"""
    print("Testing: Untyped port parsing...")

    content = """package test {
    part def Block {
        port untypedPort;
    }
}
"""
    arch = parse_sysml_to_json(content)
    assert len(arch['proxy_ports']) == 1, f"Expected 1 port, got {len(arch['proxy_ports'])}"
    port = arch['proxy_ports'][0]
    assert port['name'] == 'untypedPort', f"Expected 'untypedPort', got '{port['name']}'"
    assert port['type'] == 'Port', f"Expected default type 'Port', got '{port['type']}'"

    print("  ✓ Untyped port parsing test passed")


def test_requirement_without_angle_brackets():
    """Test requirements without angle bracket syntax"""
    print("Testing: Requirement without angle brackets...")

    content = """package test {
    requirement REQ_001 {
        doc "Test requirement."
    }
}
"""
    arch = parse_sysml_to_json(content)
    assert len(arch['requirements']) == 1, f"Expected 1 requirement, got {len(arch['requirements'])}"
    req = arch['requirements'][0]
    assert req['id'] == 'REQ_001', f"Expected 'REQ_001', got '{req['id']}'"

    print("  ✓ Requirement without angle brackets test passed")


def test_deep_nesting():
    """Test deeply nested part definitions"""
    print("Testing: Deep nesting...")

    content = """package nested {
    part def Level1 {
        part level2a : Level2 {
            part level3a : Level3;
        }
    }
    part def Level2 { port p2; }
    part def Level3 { port p3; }
}
"""
    arch = parse_sysml_to_json(content)
    block_names = [b['name'] for b in arch['blocks']]
    assert 'Level1' in block_names, "Level1 not found"
    assert 'Level2' in block_names, "Level2 not found"
    assert 'Level3' in block_names, "Level3 not found"

    print("  ✓ Deep nesting test passed")


def test_load_with_imports_simple():
    """Test loading file with import"""
    print("Testing: Load with imports...")

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)

        # Create model file
        model_file = tmp_path / "model.sysml"
        model_file.write_text("""package test_model {
    part def BaseBlock {
        port basePort;
    }
}
""")

        # Create view file in views subdirectory
        view_dir = tmp_path / "views"
        view_dir.mkdir()
        view_file = view_dir / "view.sysml"
        view_file.write_text("""import "model.sysml";

package test_view {
    // View configuration
}
""")

        arch = load_with_imports(view_file)
        block_names = [b['name'] for b in arch['blocks']]
        assert 'BaseBlock' in block_names, f"BaseBlock from import not found. Blocks: {block_names}"

    print("  ✓ Load with imports test passed")


def test_circular_import_detection():
    """Test circular import detection"""
    print("Testing: Circular import detection...")

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)

        # Create model directory structure
        view_dir = tmp_path / "views"
        view_dir.mkdir()

        # Create circular imports - view imports itself through relative path
        file_a = view_dir / "a.sysml"
        file_b = view_dir / "b.sysml"

        # Use relative paths that work with the parser's resolution logic
        file_a.write_text('import "./b.sysml";\npackage a {}')
        file_b.write_text('import "./a.sysml";\npackage b {}')

        try:
            load_with_imports(file_a)
            assert False, "Should have raised ValueError for circular import"
        except ValueError as e:
            assert "Circular import" in str(e), f"Expected circular import error, got: {e}"

    print("  ✓ Circular import detection test passed")


def main():
    """Run verification tests"""
    print("\n" + "=" * 70)
    print("  Enhanced Parser Test Verification")
    print("=" * 70 + "\n")

    tests = [
        test_empty_package,
        test_alternative_connection_syntax,
        test_parse_import_statement,
        test_has_imports,
        test_resolve_import_path,
        test_view_metadata_extraction,
        test_multiplicity_parsing,
        test_unicode_handling,
        test_untyped_ports,
        test_requirement_without_angle_brackets,
        test_deep_nesting,
        test_load_with_imports_simple,
        test_circular_import_detection,
    ]

    passed = 0
    failed = 0

    for test_func in tests:
        try:
            test_func()
            passed += 1
        except Exception as e:
            print(f"  ✗ {test_func.__name__} failed: {e}")
            failed += 1

    print("\n" + "=" * 70)
    print("  VERIFICATION SUMMARY")
    print("=" * 70)
    print(f"  Total tests: {passed + failed}")
    print(f"  Passed: {passed}")
    print(f"  Failed: {failed}")

    if failed == 0:
        print("  Status: ALL VERIFICATION TESTS PASSED ✓")
        exit_code = 0
    else:
        print(f"  Status: {failed} TEST(S) FAILED ✗")
        exit_code = 1

    print("=" * 70 + "\n")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
