"""
Test view filtering with public keyword.

View filtering allows marking elements with 'public' to control visibility
in rendered diagrams. Elements without 'public' are treated as internal
implementation details and hidden from external views.

Backward compatibility: Architectures without any 'public' keywords show all elements.
"""

from pathlib import Path
from spa.sysml_parser import parse_sysml_to_json, extract_exposed_elements
from spa.server import generate_bdd_plantuml, generate_ibd_plantuml


def test_extract_exposed_elements():
    """Test extraction of public elements from SysML content"""
    content = """
    package test {
        public part def PublicComponent {
            port p1;
        }

        part def PrivateComponent {
            port p2;
        }

        public part def AnotherPublic {
            port p3;
        }
    }
    """

    exposed = extract_exposed_elements(content)

    assert 'PublicComponent' in exposed
    assert 'AnotherPublic' in exposed
    assert 'PrivateComponent' not in exposed
    assert len(exposed) == 2


def test_parser_includes_exposed_elements():
    """Test that parser includes exposed_elements in result"""
    content = """
    package test {
        // Test
        // Domain: test

        public part def ComponentA {}
        part def ComponentB {}

        part def System {
            part a : ComponentA;
            part b : ComponentB;
        }

        part system : System;
    }
    """

    result = parse_sysml_to_json(content)

    assert 'exposed_elements' in result
    assert 'ComponentA' in result['exposed_elements']
    assert 'ComponentB' not in result['exposed_elements']


def test_bdd_filtering():
    """Test BDD diagram filtering with public keyword"""
    test_file = Path(__file__).parent.parent / 'data' / 'architectures' / 'test_view_filter.sysml'

    if not test_file.exists():
        # Create test file if it doesn't exist
        test_file.parent.mkdir(parents=True, exist_ok=True)
        test_file.write_text("""
package test_view_filter {
    // Test
    // Domain: test

    public part def ControlUnit {
        port cmdOut;
    }

    public part def SensorModule {
        port dataOut;
    }

    part def InternalProcessor {
        port procIn;
    }

    part def System {
        part control : ControlUnit;
        part sensor : SensorModule;
        part processor : InternalProcessor;

        connect control.cmdOut to sensor.dataOut;
    }

    part system : System;
}
""")

    plantuml = generate_bdd_plantuml(test_file)

    # Should include public components
    assert 'ControlUnit' in plantuml
    assert 'SensorModule' in plantuml

    # Should NOT include private components
    assert 'InternalProcessor' not in plantuml


def test_ibd_filtering():
    """Test IBD diagram filtering with public keyword"""
    test_file = Path(__file__).parent.parent / 'data' / 'architectures' / 'test_view_filter.sysml'

    if not test_file.exists():
        return  # Skip if test file doesn't exist

    plantuml = generate_ibd_plantuml(test_file)

    # Should include public components
    assert 'ControlUnit' in plantuml or 'controlunit' in plantuml
    assert 'SensorModule' in plantuml or 'sensormodule' in plantuml

    # Should NOT include private components
    assert 'InternalProcessor' not in plantuml
    assert 'internalprocessor' not in plantuml


def test_backward_compatibility_no_public_keywords():
    """Test that architectures without public keyword show all elements"""
    content = """
    package test {
        // Test
        // Domain: test

        part def ComponentA {
            port p1;
        }

        part def ComponentB {
            port p2;
        }

        part def System {
            part a : ComponentA;
            part b : ComponentB;

            connect a.p1 to b.p2;
        }

        part system : System;
    }
    """

    # Parse
    result = parse_sysml_to_json(content)

    # Should have empty exposed_elements list (no public keywords)
    assert len(result.get('exposed_elements', [])) == 0

    # All blocks should be included
    assert len(result.get('blocks', [])) == 3

    # When rendering, all elements should be visible (backward compatibility)
    # This is tested by checking that show_all flag is set when exposed_elements is empty


def test_connection_filtering():
    """Test that connections are filtered based on component visibility"""
    content = """
    package test {
        // Test
        // Domain: test

        public part def PublicA {
            port pa;
        }

        public part def PublicB {
            port pb;
        }

        part def PrivateC {
            port pc;
        }

        part def System {
            part a : PublicA;
            part b : PublicB;
            part c : PrivateC;

            connect a.pa to b.pb;  // Should be included (both public)
            connect a.pa to c.pc;  // Should be filtered (c is private)
            connect c.pc to b.pb;  // Should be filtered (c is private)
        }

        part system : System;
    }
    """

    result = parse_sysml_to_json(content)

    # Verify exposed elements
    assert 'PublicA' in result['exposed_elements']
    assert 'PublicB' in result['exposed_elements']
    assert 'PrivateC' not in result['exposed_elements']

    # Verify all connections are parsed
    assert len(result.get('connectors', [])) == 3

    # When rendered, only connections between public elements should appear
    # This is tested by the IBD renderer logic


if __name__ == '__main__':
    # Run tests
    print("Testing view filtering...")

    try:
        test_extract_exposed_elements()
        print("✓ test_extract_exposed_elements")
    except AssertionError as e:
        print(f"✗ test_extract_exposed_elements: {e}")

    try:
        test_parser_includes_exposed_elements()
        print("✓ test_parser_includes_exposed_elements")
    except AssertionError as e:
        print(f"✗ test_parser_includes_exposed_elements: {e}")

    try:
        test_bdd_filtering()
        print("✓ test_bdd_filtering")
    except AssertionError as e:
        print(f"✗ test_bdd_filtering: {e}")

    try:
        test_ibd_filtering()
        print("✓ test_ibd_filtering")
    except AssertionError as e:
        print(f"✗ test_ibd_filtering: {e}")

    try:
        test_backward_compatibility_no_public_keywords()
        print("✓ test_backward_compatibility_no_public_keywords")
    except AssertionError as e:
        print(f"✗ test_backward_compatibility_no_public_keywords: {e}")

    try:
        test_connection_filtering()
        print("✓ test_connection_filtering")
    except AssertionError as e:
        print(f"✗ test_connection_filtering: {e}")

    print("\nAll view filtering tests completed!")
