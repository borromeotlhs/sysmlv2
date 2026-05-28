#!/usr/bin/env python3
"""
Test namespace import patterns in SysML v2 parser.

Tests three import patterns:
1. import PackageName::* (direct members only)
2. import PackageName::** (recursive, all nested)
3. import PackageName::*::** (hybrid, direct + nested)
"""

import sys
from pathlib import Path

# Add spa directory to path
sys.path.insert(0, str(Path(__file__).parent / 'spa'))

from sysml_parser import (
    parse_namespace_import,
    resolve_namespace_import,
    parse_sysml_to_json
)


def test_parse_namespace_import():
    """Test parsing of namespace import statements."""
    print("Testing parse_namespace_import()...")

    # Test direct import
    result = parse_namespace_import("import Systems::*;")
    assert result == {'package': 'Systems', 'pattern': 'direct'}, \
        f"Expected direct pattern, got {result}"
    print("  ✓ Direct import: import Systems::*")

    # Test recursive import
    result = parse_namespace_import("import Systems::**;")
    assert result == {'package': 'Systems', 'pattern': 'recursive'}, \
        f"Expected recursive pattern, got {result}"
    print("  ✓ Recursive import: import Systems::**")

    # Test hybrid import
    result = parse_namespace_import("import Systems::*::**;")
    assert result == {'package': 'Systems', 'pattern': 'hybrid'}, \
        f"Expected hybrid pattern, got {result}"
    print("  ✓ Hybrid import: import Systems::*::**")

    # Test non-namespace import
    result = parse_namespace_import('import "model.sysml";')
    assert result is None, f"Expected None for file import, got {result}"
    print("  ✓ File import returns None")

    # Test with whitespace
    result = parse_namespace_import("  import   Components::*  ;  ")
    assert result == {'package': 'Components', 'pattern': 'direct'}, \
        f"Expected direct pattern with whitespace, got {result}"
    print("  ✓ Handles whitespace correctly")

    print("✓ All parse_namespace_import() tests passed\n")


def test_resolve_namespace_import():
    """Test resolution of namespace imports to visible elements."""
    print("Testing resolve_namespace_import()...")

    # Create test architecture with nested structure
    arch = {
        'blocks': [
            {'name': 'PowerSystem', 'stereotype': 'Block'},
            {'name': 'CoolingSystem', 'stereotype': 'Block'},
            {'name': 'Battery', 'stereotype': 'Block'},
            {'name': 'Radiator', 'stereotype': 'Block'},
            {'name': 'Cell', 'stereotype': 'Block'}
        ],
        'compositions': [
            {'parent': 'PowerSystem', 'child': 'Battery', 'multiplicity': '1'},
            {'parent': 'CoolingSystem', 'child': 'Radiator', 'multiplicity': '1'},
            {'parent': 'Battery', 'child': 'Cell', 'multiplicity': '4'}
        ],
        'exposed_elements': ['PowerSystem', 'CoolingSystem']  # Public elements
    }

    # Test direct import (::*)
    visible = resolve_namespace_import('Systems', 'direct', arch)
    expected_direct = {'PowerSystem', 'CoolingSystem'}
    assert visible == expected_direct, \
        f"Direct import failed. Expected {expected_direct}, got {visible}"
    print("  ✓ Direct import (::*): returns only direct members")

    # Test recursive import (::**)
    visible = resolve_namespace_import('Systems', 'recursive', arch)
    expected_recursive = {'Battery', 'Radiator', 'Cell'}
    assert visible == expected_recursive, \
        f"Recursive import failed. Expected {expected_recursive}, got {visible}"
    print("  ✓ Recursive import (::**): returns all nested elements")

    # Test hybrid import (::*::**)
    visible = resolve_namespace_import('Systems', 'hybrid', arch)
    expected_hybrid = {'PowerSystem', 'CoolingSystem', 'Battery', 'Radiator', 'Cell'}
    assert visible == expected_hybrid, \
        f"Hybrid import failed. Expected {expected_hybrid}, got {visible}"
    print("  ✓ Hybrid import (::*::**): returns direct + nested elements")

    print("✓ All resolve_namespace_import() tests passed\n")


def test_full_parsing():
    """Test full parsing with namespace imports in SysML content."""
    print("Testing full parsing with namespace imports...")

    # Create test SysML content
    sysml_content = """
// Test Architecture with Namespace Imports
// Domain: aerospace

package TestArch {
    // Define a systems package structure
    public part def PowerSystem {
        part battery : Battery;
    }

    public part def CoolingSystem {
        part radiator : Radiator;
    }

    part def Battery {
        part cell : Cell[4];
    }

    part def Radiator {
        port inlet;
        port outlet;
    }

    part def Cell {
        port positive;
        port negative;
    }

    // Test consumer that imports Systems namespace
    public part def Vehicle {
        // This would import PowerSystem and CoolingSystem
        // import Systems::*;
        part powerSys : PowerSystem;
        part coolingSys : CoolingSystem;
    }
}
"""

    result = parse_sysml_to_json(sysml_content)

    # Verify basic parsing
    assert result['id'] == 'TestArch', f"Expected id 'TestArch', got {result['id']}"
    assert len(result['blocks']) == 6, f"Expected 6 blocks, got {len(result['blocks'])}"
    print("  ✓ Basic parsing works")

    # Verify exposed elements
    exposed = set(result['exposed_elements'])
    expected_exposed = {'PowerSystem', 'CoolingSystem', 'Vehicle'}
    assert exposed == expected_exposed, \
        f"Expected exposed {expected_exposed}, got {exposed}"
    print("  ✓ Public elements correctly identified")

    # Verify compositions
    assert len(result['compositions']) == 5, \
        f"Expected 5 compositions, got {len(result['compositions'])}"
    print("  ✓ Compositions correctly extracted")

    print("✓ All full parsing tests passed\n")


def test_namespace_import_in_content():
    """Test namespace imports embedded in SysML content."""
    print("Testing namespace imports in content...")

    sysml_content = """
package Systems {
    public part def PowerSystem {
        part battery : Battery;
    }

    public part def CoolingSystem {
        part radiator : Radiator;
    }

    part def Battery {
        port positive;
        port negative;
    }

    part def Radiator {
        port inlet;
        port outlet;
    }
}

package Application {
    import Systems::*;

    public part def Vehicle {
        part power : PowerSystem;
        part cooling : CoolingSystem;
    }
}
"""

    # Parse just the Systems package first
    systems_content = """
package Systems {
    public part def PowerSystem {
        part battery : Battery;
    }

    public part def CoolingSystem {
        part radiator : Radiator;
    }

    part def Battery {
        port positive;
        port negative;
    }

    part def Radiator {
        port inlet;
        port outlet;
    }
}
"""

    result = parse_sysml_to_json(systems_content)
    assert result['id'] == 'Systems', f"Expected 'Systems', got {result['id']}"
    print("  ✓ Systems package parsed")

    # Check exposed elements
    exposed = set(result['exposed_elements'])
    expected = {'PowerSystem', 'CoolingSystem'}
    assert exposed == expected, f"Expected {expected}, got {exposed}"
    print("  ✓ Public elements exposed correctly")

    # Parse application with namespace import
    app_content = """
package Application {
    import Systems::*;

    public part def Vehicle {
        part power : PowerSystem;
        part cooling : CoolingSystem;
    }
}
"""

    app_result = parse_sysml_to_json(app_content)
    assert app_result['id'] == 'Application', f"Expected 'Application', got {app_result['id']}"
    print("  ✓ Application package parsed")

    # Check namespace imports were tracked
    assert 'namespace_imports' in app_result, "namespace_imports field missing"
    ns_imports = app_result['namespace_imports']
    assert len(ns_imports) == 1, f"Expected 1 namespace import, got {len(ns_imports)}"
    assert ns_imports[0]['package'] == 'Systems', \
        f"Expected Systems package, got {ns_imports[0]['package']}"
    assert ns_imports[0]['pattern'] == 'direct', \
        f"Expected direct pattern, got {ns_imports[0]['pattern']}"
    print("  ✓ Namespace import tracked correctly")

    print("✓ All namespace import in content tests passed\n")


def run_all_tests():
    """Run all test suites."""
    print("=" * 60)
    print("SysML v2 Namespace Import Tests")
    print("=" * 60)
    print()

    try:
        test_parse_namespace_import()
        test_resolve_namespace_import()
        test_full_parsing()
        test_namespace_import_in_content()

        print("=" * 60)
        print("✓ ALL TESTS PASSED")
        print("=" * 60)
        return 0
    except AssertionError as e:
        print()
        print("=" * 60)
        print(f"✗ TEST FAILED: {e}")
        print("=" * 60)
        return 1
    except Exception as e:
        print()
        print("=" * 60)
        print(f"✗ ERROR: {e}")
        import traceback
        traceback.print_exc()
        print("=" * 60)
        return 1


if __name__ == '__main__':
    sys.exit(run_all_tests())
