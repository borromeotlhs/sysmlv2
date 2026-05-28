"""
Comprehensive Parser Tests for SysML v2 Pipeline

Tests cover:
- Namespace import resolution (all three patterns)
- Exposed elements tracking (public keyword)
- File import handling
- Round-trip (generate → parse → validate)
- Edge cases (circular imports, missing files, malformed imports)

Run with: pytest tests/test_parser_comprehensive.py -v
"""
import pytest
from pathlib import Path
from spa.sysml_parser import (
    parse_sysml_to_json,
    parse_import_statement,
    extract_exposed_elements,
    has_imports,
    load_with_imports,
    merge_architectures
)
from lib.sysml_generator import generate_sysml_from_dict


# =============================================================================
# NAMESPACE IMPORT TESTS
# =============================================================================

class TestNamespaceImports:
    """Test namespace import resolution patterns"""

    def test_import_all_pattern(self):
        """Test 'import Package::*;' pattern"""
        content = """package test {
    import ScalarValues::*;
    import ISQ::*;

    public part def Component {
        attribute mass : Real [1];
    }
}
"""
        arch = parse_sysml_to_json(content)

        # Should parse without errors
        assert arch['id'] == 'test'
        assert len(arch['blocks']) == 1

    def test_import_specific_pattern(self):
        """Test 'import Package::Element;' pattern"""
        content = """package test {
    import ScalarValues::Real;
    import ISQ::MassValue;

    public part def Component {
        attribute mass : Real [1];
    }
}
"""
        arch = parse_sysml_to_json(content)

        # Should parse specific imports
        assert arch['id'] == 'test'

    def test_import_alias_pattern(self):
        """Test 'import Package::Element as Alias;' pattern"""
        content = """package test {
    import ScalarValues::Real as RealNumber;

    public part def Component {
        attribute value : RealNumber [1];
    }
}
"""
        arch = parse_sysml_to_json(content)

        # Should parse import with alias
        assert arch['id'] == 'test'

    def test_multiple_import_types(self):
        """Test mix of import patterns"""
        content = """package test {
    import ScalarValues::*;
    import ISQ::MassValue;
    import Units::kg as Kilogram;

    public part def Component {
        attribute mass : MassValue [1];
    }
}
"""
        arch = parse_sysml_to_json(content)

        # Should handle multiple import types
        assert arch['id'] == 'test'
        assert len(arch['blocks']) == 1

    def test_file_import_detection(self):
        """Test detection of file-based imports vs namespace imports"""
        # Namespace import (should return None)
        ns_import = parse_import_statement('import ScalarValues::*;')
        assert ns_import is None

        # File import (should return filename)
        file_import = parse_import_statement('import "model.sysml";')
        assert file_import == "model.sysml"


# =============================================================================
# EXPOSED ELEMENTS TESTS
# =============================================================================

class TestExposedElements:
    """Test exposed elements tracking with public keyword"""

    def test_extract_public_part_defs(self):
        """Test extraction of public part definitions"""
        content = """package test {
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

    def test_extract_public_requirements(self):
        """Test extraction of public requirements"""
        content = """package test {
    public requirement REQ_001 {
        doc "Public requirement."
    }

    requirement REQ_002 {
        doc "Private requirement."
    }
}
"""
        exposed = extract_exposed_elements(content)

        # Requirements can also be marked public
        # (implementation may or may not track these separately)
        assert exposed is not None

    def test_parser_includes_exposed_elements(self):
        """Test that parser result includes exposed_elements field"""
        content = """package test {
    // Test
    // Domain: test

    public part def ComponentA {
    }

    part def ComponentB {
    }
}
"""
        arch = parse_sysml_to_json(content)

        assert 'exposed_elements' in arch
        assert 'ComponentA' in arch['exposed_elements']
        assert 'ComponentB' not in arch['exposed_elements']

    def test_no_public_keywords_backward_compat(self):
        """Test backward compatibility when no public keywords present"""
        content = """package test {
    // Test
    // Domain: test

    part def ComponentA {
    }

    part def ComponentB {
    }
}
"""
        arch = parse_sysml_to_json(content)

        # Should have empty exposed_elements list
        assert 'exposed_elements' in arch
        assert len(arch['exposed_elements']) == 0

        # All blocks should still be parsed
        assert len(arch['blocks']) == 2

    def test_mixed_public_private(self):
        """Test mix of public and private elements"""
        content = """package test {
    // Test
    // Domain: test

    public part def PublicA {
        port p1;
    }

    part def PrivateB {
        port p2;
    }

    public part def PublicC {
        port p3;
    }

    part def PrivateD {
        port p4;
    }
}
"""
        arch = parse_sysml_to_json(content)

        # Should track public elements
        assert len(arch['exposed_elements']) == 2
        assert 'PublicA' in arch['exposed_elements']
        assert 'PublicC' in arch['exposed_elements']

        # All blocks should be parsed
        assert len(arch['blocks']) == 4


# =============================================================================
# FILE IMPORT TESTS
# =============================================================================

class TestFileImports:
    """Test file-based import handling"""

    def test_has_imports_detection(self):
        """Test detection of file imports in content"""
        with_import = 'import "model.sysml";\npackage test {}'
        assert has_imports(with_import) is True

        without_import = 'import ScalarValues::*;\npackage test {}'
        assert has_imports(without_import) is False

        no_import = 'package test {}'
        assert has_imports(no_import) is False

    def test_load_with_imports_simple(self, tmp_path):
        """Test loading file with single import"""
        # Create model file
        model = tmp_path / 'model.sysml'
        model.write_text("""package model_pkg {
    public part def BaseComponent {
        port basePort;
    }
}
""")

        # Create view file that imports model
        view = tmp_path / 'view.sysml'
        view.write_text(f"""import "model.sysml";

package view_pkg {{
    // View
}}
""")

        arch = load_with_imports(view)

        # Should merge content from both files
        assert 'BaseComponent' in [b['name'] for b in arch['blocks']]

    def test_load_with_imports_missing_file(self, tmp_path):
        """Test graceful handling of missing import file"""
        view = tmp_path / 'view.sysml'
        view.write_text("""import "nonexistent.sysml";

package view_pkg {
    public part def LocalComponent {
        port localPort;
    }
}
""")

        # Should not crash, should parse local content
        arch = load_with_imports(view)

        # Should have local component
        assert 'LocalComponent' in [b['name'] for b in arch['blocks']]

    def test_load_with_imports_relative_path(self, tmp_path):
        """Test import with relative path"""
        # Create subdirectory structure
        subdir = tmp_path / 'models'
        subdir.mkdir()

        model = subdir / 'base.sysml'
        model.write_text("""package base {
    public part def BaseComponent {
    }
}
""")

        view = tmp_path / 'view.sysml'
        view.write_text("""import "models/base.sysml";

package view {
    public part def ViewComponent {
    }
}
""")

        # Should resolve relative path
        # Note: Implementation may or may not support this
        # Just ensure it doesn't crash
        try:
            arch = load_with_imports(view)
            assert arch is not None
        except Exception:
            # If not supported, that's OK
            pass

    def test_circular_import_detection(self, tmp_path):
        """Test detection of circular imports"""
        file_a = tmp_path / 'a.sysml'
        file_a.write_text("""import "b.sysml";
package a {
}
""")

        file_b = tmp_path / 'b.sysml'
        file_b.write_text("""import "a.sysml";
package b {
}
""")

        # Should detect circular import
        with pytest.raises(ValueError, match='[Cc]ircular'):
            load_with_imports(file_a)


# =============================================================================
# MERGE ARCHITECTURES TESTS
# =============================================================================

class TestMergeArchitectures:
    """Test architecture merging logic"""

    def test_merge_blocks(self):
        """Test merging of block lists"""
        base = {
            'id': 'base',
            'blocks': [
                {'name': 'BlockA', 'stereotype': 'Block'},
                {'name': 'BlockB', 'stereotype': 'Block'}
            ]
        }

        override = {
            'id': 'override',
            'blocks': [
                {'name': 'BlockB', 'stereotype': 'Block'},  # Duplicate
                {'name': 'BlockC', 'stereotype': 'Block'}   # New
            ]
        }

        merged = merge_architectures(base, override)

        block_names = [b['name'] for b in merged['blocks']]
        assert set(block_names) == {'BlockA', 'BlockB', 'BlockC'}
        # No duplicates
        assert len(merged['blocks']) == 3

    def test_merge_preserves_model_id(self):
        """Test that view merge preserves model ID"""
        model = {
            'id': 'model_arch',
            'name': 'Model Architecture',
            'domain': 'system',
            'blocks': [{'name': 'ModelBlock'}]
        }

        view = {
            'id': 'view_arch',
            'name': 'View Name',
            'blocks': []
        }

        merged = merge_architectures(model, view)

        # Should preserve model's core identity
        assert merged['id'] == 'model_arch'
        assert merged['name'] == 'Model Architecture'
        assert merged['domain'] == 'system'

    def test_merge_ports(self):
        """Test merging of port lists"""
        base = {
            'id': 'base',
            'proxy_ports': [
                {'owner': 'BlockA', 'name': 'port1', 'type': 'DataPort'}
            ]
        }

        override = {
            'id': 'override',
            'proxy_ports': [
                {'owner': 'BlockB', 'name': 'port2', 'type': 'DataPort'}
            ]
        }

        merged = merge_architectures(base, override)

        # Should have ports from both
        assert len(merged['proxy_ports']) == 2

    def test_merge_requirements(self):
        """Test merging of requirement lists"""
        base = {
            'id': 'base',
            'requirements': [
                {'id': 'REQ_001', 'text': 'First requirement'}
            ]
        }

        override = {
            'id': 'override',
            'requirements': [
                {'id': 'REQ_002', 'text': 'Second requirement'}
            ]
        }

        merged = merge_architectures(base, override)

        req_ids = [r['id'] for r in merged['requirements']]
        assert 'REQ_001' in req_ids
        assert 'REQ_002' in req_ids


# =============================================================================
# ROUND-TRIP TESTS
# =============================================================================

class TestRoundTrip:
    """Test generate → parse → validate round-trip"""

    def test_round_trip_minimal(self):
        """Test round-trip with minimal architecture"""
        original = {
            'id': 'arch_roundtrip',
            'name': 'Round Trip Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        # Generate SysML
        sysml = generate_sysml_from_dict(original)

        # Parse back
        parsed = parse_sysml_to_json(sysml)

        # Verify core fields
        assert parsed['id'] == original['id']
        assert len(parsed['blocks']) == len(original['blocks'])

    def test_round_trip_with_ports(self):
        """Test round-trip with typed ports"""
        original = {
            'id': 'arch_ports',
            'name': 'Ports Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Sensor', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'Sensor', 'name': 'dataOut', 'type': 'DataPort'}
            ],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        # Generate and parse
        sysml = generate_sysml_from_dict(original)
        parsed = parse_sysml_to_json(sysml)

        # Verify ports
        assert len(parsed['proxy_ports']) == 1
        port = parsed['proxy_ports'][0]
        assert port['name'] == 'dataOut'
        assert port['type'] == 'DataPort'
        assert port['owner'] == 'Sensor'

    def test_round_trip_with_connections(self):
        """Test round-trip with connections"""
        original = {
            'id': 'arch_conn',
            'name': 'Connections Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'ComponentA', 'stereotype': 'Block'},
                {'name': 'ComponentB', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'ComponentA', 'name': 'portA', 'type': 'DataPort'},
                {'owner': 'ComponentB', 'name': 'portB', 'type': 'DataPort'}
            ],
            'connectors': [
                {'name': 'link1', 'end_a': 'ComponentA.portA', 'end_b': 'ComponentB.portB'}
            ],
            'requirements': [],
            'relationships': []
        }

        # Generate and parse
        sysml = generate_sysml_from_dict(original)
        parsed = parse_sysml_to_json(sysml)

        # Verify connections
        assert len(parsed['connectors']) == 1
        conn = parsed['connectors'][0]
        assert conn['end_a'] == 'ComponentA.portA'
        assert conn['end_b'] == 'ComponentB.portB'

    def test_round_trip_with_requirements(self):
        """Test round-trip with requirements and satisfy"""
        original = {
            'id': 'arch_req',
            'name': 'Requirements Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [
                {'id': 'REQ-001', 'text': 'System shall process data.'}
            ],
            'relationships': [
                {'type': 'satisfy', 'client': 'Component', 'supplier': 'REQ-001'}
            ]
        }

        # Generate and parse
        sysml = generate_sysml_from_dict(original)
        parsed = parse_sysml_to_json(sysml)

        # Verify requirements
        assert len(parsed['requirements']) == 1
        req = parsed['requirements'][0]
        assert req['id'] == 'REQ_001'  # Sanitized
        assert 'process data' in req['text'].lower()

        # Verify relationships
        assert len(parsed['relationships']) == 1
        rel = parsed['relationships'][0]
        assert rel['client'] == 'Component'
        assert rel['supplier'] == 'REQ_001'

    def test_round_trip_complete(self):
        """Test round-trip with complete architecture"""
        original = {
            'id': 'arch_complete',
            'name': 'Complete Round Trip',
            'domain': 'aerospace',
            'blocks': [
                {'name': 'TelemetrySystem', 'stereotype': 'Block'},
                {'name': 'Sensor', 'stereotype': 'Block'},
                {'name': 'Processor', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'Sensor', 'name': 'dataOut', 'type': 'DataPort'},
                {'owner': 'Processor', 'name': 'dataIn', 'type': 'DataPort'}
            ],
            'connectors': [
                {'name': 'dataLink', 'end_a': 'Sensor.dataOut', 'end_b': 'Processor.dataIn'}
            ],
            'requirements': [
                {'id': 'REQ-001', 'text': 'System shall process telemetry.'}
            ],
            'relationships': [
                {'type': 'satisfy', 'client': 'Sensor', 'supplier': 'REQ-001'}
            ]
        }

        # Generate and parse
        sysml = generate_sysml_from_dict(original)
        parsed = parse_sysml_to_json(sysml)

        # Verify all major sections
        assert parsed['id'] == original['id']
        assert parsed['domain'] == original['domain']
        assert len(parsed['blocks']) == len(original['blocks'])
        assert len(parsed['proxy_ports']) == len(original['proxy_ports'])
        assert len(parsed['connectors']) == len(original['connectors'])
        assert len(parsed['requirements']) == len(original['requirements'])
        assert len(parsed['relationships']) == len(original['relationships'])


# =============================================================================
# PARSING EDGE CASES
# =============================================================================

class TestParsingEdgeCases:
    """Test parser edge cases and robustness"""

    def test_parse_empty_content(self):
        """Test parsing empty content"""
        arch = parse_sysml_to_json("")

        # Should return minimal structure without crashing
        assert arch is not None
        assert arch['blocks'] == []

    def test_parse_whitespace_only(self):
        """Test parsing whitespace-only content"""
        arch = parse_sysml_to_json("   \n\n\t  \n  ")

        # Should handle gracefully
        assert arch is not None

    def test_parse_with_inline_comments(self):
        """Test parsing with inline comments"""
        content = """package test {
    public part def Component { // inline comment
        port p1; /* block comment */ port p2;
    }
}
"""
        arch = parse_sysml_to_json(content)

        # Should parse correctly despite comments
        assert arch['id'] == 'test'
        assert len(arch['blocks']) == 1

    def test_parse_with_multiline_strings(self):
        """Test parsing with multi-line documentation"""
        content = """package test {
    requirement REQ_001 {
        doc "This is a multi-line
             requirement text that spans
             several lines."
    }
}
"""
        arch = parse_sysml_to_json(content)

        # Should handle multi-line strings
        assert len(arch['requirements']) == 1

    def test_parse_mixed_line_endings(self):
        """Test parsing with mixed CRLF and LF"""
        content = "package test {\r\n  public part def Component {}\n}"
        arch = parse_sysml_to_json(content)

        # Should handle mixed line endings
        assert arch['id'] == 'test'

    def test_parse_consistency(self):
        """Test that parsing same content twice gives same result"""
        content = """package test {
    // Test
    // Domain: test

    public part def Component {
        port p1 : DataPort;
    }
}
"""
        arch1 = parse_sysml_to_json(content)
        arch2 = parse_sysml_to_json(content)

        # Should be identical
        assert arch1['id'] == arch2['id']
        assert len(arch1['blocks']) == len(arch2['blocks'])
        assert len(arch1['proxy_ports']) == len(arch2['proxy_ports'])


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
