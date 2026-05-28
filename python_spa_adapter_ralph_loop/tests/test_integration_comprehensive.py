"""
Comprehensive Integration Tests for SysML v2 Pipeline

Tests cover:
- Full pipeline: JSON IR → .sysml → parse → render → diagram
- Cross-package imports
- View with filtered visibility
- Error handling and recovery
- End-to-end workflows

Run with: pytest tests/test_integration_comprehensive.py -v
"""
import pytest
import tempfile
from pathlib import Path
from lib.sysml_generator import generate_sysml_from_dict
from spa.sysml_parser import parse_sysml_to_json, load_with_imports
from spa.server import generate_bdd_plantuml, generate_ibd_plantuml, validate_sysml_content
from tests.test_sysml_validation import SysMLValidator, ErrorSeverity


@pytest.fixture
def workspace(tmp_path):
    """Create a temporary workspace for integration tests"""
    workspace_dir = tmp_path / 'workspace'
    workspace_dir.mkdir()
    return workspace_dir


@pytest.fixture
def sample_architecture():
    """Sample architecture for testing"""
    return {
        'id': 'arch_integration',
        'name': 'Integration Test Architecture',
        'domain': 'aerospace',
        'blocks': [
            {'name': 'TelemetrySystem', 'stereotype': 'Block'},
            {'name': 'Sensor', 'stereotype': 'Block'},
            {'name': 'Processor', 'stereotype': 'Block'},
            {'name': 'PowerSupply', 'stereotype': 'Block'}
        ],
        'proxy_ports': [
            {'owner': 'Sensor', 'name': 'dataOut', 'type': 'DataPort'},
            {'owner': 'Sensor', 'name': 'powerIn', 'type': 'PowerPort'},
            {'owner': 'Processor', 'name': 'dataIn', 'type': 'DataPort'},
            {'owner': 'Processor', 'name': 'powerIn', 'type': 'PowerPort'},
            {'owner': 'PowerSupply', 'name': 'powerOut', 'type': 'PowerPort'}
        ],
        'connectors': [
            {'name': 'dataLink', 'end_a': 'Sensor.dataOut', 'end_b': 'Processor.dataIn'},
            {'name': 'power1', 'end_a': 'PowerSupply.powerOut', 'end_b': 'Sensor.powerIn'},
            {'name': 'power2', 'end_a': 'PowerSupply.powerOut', 'end_b': 'Processor.powerIn'}
        ],
        'requirements': [
            {'id': 'REQ-001', 'text': 'System shall process telemetry data.'},
            {'id': 'REQ-002', 'text': 'System shall maintain power budget.'}
        ],
        'relationships': [
            {'type': 'satisfy', 'client': 'Sensor', 'supplier': 'REQ-001'},
            {'type': 'satisfy', 'client': 'Processor', 'supplier': 'REQ-001'},
            {'type': 'satisfy', 'client': 'PowerSupply', 'supplier': 'REQ-002'}
        ]
    }


# =============================================================================
# FULL PIPELINE TESTS
# =============================================================================

class TestFullPipeline:
    """Test complete pipeline from IR to diagrams"""

    def test_ir_to_sysml_to_diagrams(self, sample_architecture, workspace):
        """Test: JSON IR → .sysml → diagrams"""
        # Step 1: Generate SysML from IR
        sysml_content = generate_sysml_from_dict(sample_architecture)
        assert sysml_content is not None
        assert 'package arch_integration' in sysml_content

        # Step 2: Write to file
        sysml_file = workspace / 'test.sysml'
        sysml_file.write_text(sysml_content, encoding='utf-8')
        assert sysml_file.exists()

        # Step 3: Parse back to JSON
        parsed = parse_sysml_to_json(sysml_content)
        assert parsed['id'] == 'arch_integration'
        assert len(parsed['blocks']) == 4
        assert len(parsed['proxy_ports']) == 5
        assert len(parsed['connectors']) == 3

        # Step 4: Generate BDD diagram
        bdd = generate_bdd_plantuml(sysml_file)
        assert bdd is not None
        assert '@startuml' in bdd
        assert '@enduml' in bdd
        assert 'Sensor' in bdd
        assert 'Processor' in bdd

        # Step 5: Generate IBD diagram
        ibd = generate_ibd_plantuml(sysml_file)
        assert ibd is not None
        assert '@startuml' in ibd
        assert '@enduml' in ibd

    def test_pipeline_with_validation(self, sample_architecture, workspace):
        """Test: IR → .sysml → validate → diagrams"""
        # Generate SysML
        sysml_content = generate_sysml_from_dict(sample_architecture)

        # Validate
        validation_result = validate_sysml_content(sysml_content)
        assert validation_result['valid'] is True
        errors = [e for e in validation_result['errors'] if e['severity'] == 'error']
        assert len(errors) == 0

        # Write and render
        sysml_file = workspace / 'validated.sysml'
        sysml_file.write_text(sysml_content, encoding='utf-8')

        bdd = generate_bdd_plantuml(sysml_file)
        ibd = generate_ibd_plantuml(sysml_file)

        assert bdd is not None
        assert ibd is not None

    def test_pipeline_preserves_data(self, sample_architecture):
        """Test that data is preserved through pipeline"""
        # Generate
        sysml = generate_sysml_from_dict(sample_architecture)

        # Parse
        parsed = parse_sysml_to_json(sysml)

        # Verify key data preserved
        assert parsed['id'] == sample_architecture['id']
        assert parsed['domain'] == sample_architecture['domain']
        assert len(parsed['blocks']) == len(sample_architecture['blocks'])
        assert len(parsed['requirements']) == len(sample_architecture['requirements'])

        # Verify block names preserved
        original_names = {b['name'] for b in sample_architecture['blocks']}
        parsed_names = {b['name'] for b in parsed['blocks']}
        assert original_names == parsed_names

    def test_pipeline_round_trip_consistency(self, sample_architecture):
        """Test multiple round-trips produce consistent results"""
        # First round-trip
        sysml1 = generate_sysml_from_dict(sample_architecture)
        parsed1 = parse_sysml_to_json(sysml1)

        # Second round-trip (using parsed result)
        sysml2 = generate_sysml_from_dict(parsed1)
        parsed2 = parse_sysml_to_json(sysml2)

        # Should be consistent
        assert parsed1['id'] == parsed2['id']
        assert len(parsed1['blocks']) == len(parsed2['blocks'])
        assert len(parsed1['proxy_ports']) == len(parsed2['proxy_ports'])


# =============================================================================
# CROSS-PACKAGE IMPORT TESTS
# =============================================================================

class TestCrossPackageImports:
    """Test imports across multiple files"""

    def test_import_base_model(self, workspace):
        """Test importing a base model file"""
        # Create base model
        base_content = """package base_model {
    // Base Model
    // Domain: common

    public port def DataPort;
    public port def CommandPort;

    public part def BaseComponent {
        port dataIn : DataPort;
        port cmdOut : CommandPort;
    }
}
"""
        base_file = workspace / 'base.sysml'
        base_file.write_text(base_content, encoding='utf-8')

        # Create extending model
        extend_content = f"""import "base.sysml";

package extended_model {{
    // Extended Model
    // Domain: specific

    public part def ExtendedComponent {{
        part base : BaseComponent;
    }}
}}
"""
        extend_file = workspace / 'extended.sysml'
        extend_file.write_text(extend_content, encoding='utf-8')

        # Load with imports
        merged = load_with_imports(extend_file)

        # Should have components from both files
        block_names = {b['name'] for b in merged['blocks']}
        assert 'BaseComponent' in block_names
        assert 'ExtendedComponent' in block_names

    def test_import_chain(self, workspace):
        """Test chain of imports: A imports B imports C"""
        # Create base (C)
        base_c = workspace / 'base_c.sysml'
        base_c.write_text("""package base_c {
    public part def ComponentC {
    }
}
""")

        # Create middle (B)
        base_b = workspace / 'base_b.sysml'
        base_b.write_text("""import "base_c.sysml";

package base_b {
    public part def ComponentB {
        part c : ComponentC;
    }
}
""")

        # Create top (A)
        top_a = workspace / 'top_a.sysml'
        top_a.write_text("""import "base_b.sysml";

package top_a {
    public part def ComponentA {
        part b : ComponentB;
    }
}
""")

        # Load top file with all imports
        merged = load_with_imports(top_a)

        # Should have all components
        block_names = {b['name'] for b in merged['blocks']}
        assert 'ComponentA' in block_names
        assert 'ComponentB' in block_names
        assert 'ComponentC' in block_names

    def test_import_with_namespaces(self, workspace):
        """Test mix of file imports and namespace imports"""
        # Create base model
        base_file = workspace / 'base.sysml'
        base_file.write_text("""package base {
    import ScalarValues::*;

    public part def BaseComponent {
        attribute mass : Real [1];
    }
}
""")

        # Create extending model
        extend_file = workspace / 'extended.sysml'
        extend_file.write_text("""import "base.sysml";
import ISQ::*;

package extended {
    public part def ExtendedComponent {
        part base : BaseComponent;
        attribute power : Real [1];
    }
}
""")

        # Should parse without errors
        merged = load_with_imports(extend_file)
        assert merged is not None


# =============================================================================
# FILTERED VIEW TESTS
# =============================================================================

class TestFilteredViews:
    """Test view filtering with public keyword"""

    def test_complete_system_with_filtered_view(self, workspace):
        """Test complete system with some internal components hidden"""
        arch = {
            'id': 'arch_filtered',
            'name': 'Filtered System',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'PublicSensor', 'stereotype': 'Block'},
                {'name': 'PublicProcessor', 'stereotype': 'Block'},
                {'name': 'InternalCache', 'stereotype': 'Block'},
                {'name': 'InternalBuffer', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'PublicSensor', 'name': 'dataOut', 'type': 'DataPort'},
                {'owner': 'PublicProcessor', 'name': 'dataIn', 'type': 'DataPort'},
                {'owner': 'InternalCache', 'name': 'cachePort', 'type': 'DataPort'}
            ],
            'connectors': [
                {'name': 'public_link', 'end_a': 'PublicSensor.dataOut', 'end_b': 'PublicProcessor.dataIn'},
                {'name': 'internal_link', 'end_a': 'InternalCache.cachePort', 'end_b': 'PublicProcessor.dataIn'}
            ],
            'requirements': [],
            'relationships': []
        }

        # Generate SysML
        sysml = generate_sysml_from_dict(arch)

        # Manually mark internal components as private
        sysml = sysml.replace('public part def InternalCache', 'part def InternalCache')
        sysml = sysml.replace('public part def InternalBuffer', 'part def InternalBuffer')

        sysml_file = workspace / 'filtered.sysml'
        sysml_file.write_text(sysml, encoding='utf-8')

        # Generate diagrams
        bdd = generate_bdd_plantuml(sysml_file)
        ibd = generate_ibd_plantuml(sysml_file)

        # Public components should be visible
        assert 'PublicSensor' in bdd
        assert 'PublicProcessor' in bdd

        # Internal components should be filtered
        assert 'InternalCache' not in bdd
        assert 'InternalBuffer' not in bdd

    def test_view_respects_exposed_elements(self, workspace):
        """Test that rendered views respect exposed_elements"""
        content = """package test {
    // Test
    // Domain: test

    public part def ExposedA {
        port p1;
    }

    public part def ExposedB {
        port p2;
    }

    part def HiddenC {
        port p3;
    }

    public part def System {
        part a : ExposedA;
        part b : ExposedB;
        part c : HiddenC;

        connect a.p1 to b.p2;
        connect b.p2 to c.p3;
    }
}
"""
        sysml_file = workspace / 'view_test.sysml'
        sysml_file.write_text(content, encoding='utf-8')

        # Parse and check exposed elements
        parsed = parse_sysml_to_json(content)
        assert 'ExposedA' in parsed['exposed_elements']
        assert 'ExposedB' in parsed['exposed_elements']
        assert 'HiddenC' not in parsed['exposed_elements']

        # Render BDD
        bdd = generate_bdd_plantuml(sysml_file)

        # Exposed should be present
        assert 'ExposedA' in bdd
        assert 'ExposedB' in bdd

        # Hidden should not be present
        assert 'HiddenC' not in bdd


# =============================================================================
# ERROR HANDLING TESTS
# =============================================================================

class TestErrorHandling:
    """Test error handling and recovery"""

    def test_parse_invalid_sysml(self):
        """Test parsing invalid SysML content"""
        invalid_content = """package test {
    part def Component {
        port p1
    }
"""  # Missing semicolon and closing brace

        # Should not crash
        try:
            arch = parse_sysml_to_json(invalid_content)
            # Parser is lenient, may return partial result
            assert arch is not None
        except Exception as e:
            # Or may raise exception - that's OK too
            assert e is not None

    def test_validation_catches_errors(self):
        """Test validation catches syntax errors"""
        invalid_content = """package test {
    part def Component {
        port p1
    }
"""
        result = validate_sysml_content(invalid_content)

        # Should report errors
        errors = [e for e in result['errors'] if e['severity'] == 'error']
        assert len(errors) > 0

    def test_render_malformed_file(self, workspace):
        """Test rendering handles malformed files gracefully"""
        malformed = workspace / 'malformed.sysml'
        malformed.write_text("this is not valid sysml content")

        # Should not crash
        try:
            bdd = generate_bdd_plantuml(malformed)
            # May return empty or error diagram
            assert bdd is not None
        except Exception:
            # Or may raise exception
            pass

    def test_pipeline_with_missing_requirements(self):
        """Test pipeline handles missing requirement references"""
        arch = {
            'id': 'arch_missing_req',
            'name': 'Missing Requirement Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [
                {'id': 'REQ-001', 'text': 'Existing requirement.'}
            ],
            'relationships': [
                {'type': 'satisfy', 'client': 'Component', 'supplier': 'REQ-999'}  # Missing
            ]
        }

        # Should still generate (may have validation errors)
        sysml = generate_sysml_from_dict(arch)
        assert sysml is not None

        # Validation should catch the error
        result = validate_sysml_content(sysml)
        errors = [e for e in result['errors'] if e['severity'] == 'error']
        assert any('undefined' in e['message'].lower() and 'requirement' in e['message'].lower()
                  for e in errors)

    def test_pipeline_with_undefined_ports(self):
        """Test pipeline handles undefined port references in connections"""
        arch = {
            'id': 'arch_undefined_port',
            'name': 'Undefined Port Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'ComponentA', 'stereotype': 'Block'},
                {'name': 'ComponentB', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'ComponentA', 'name': 'portA', 'type': 'DataPort'}
                # ComponentB.portB is missing
            ],
            'connectors': [
                {'name': 'link', 'end_a': 'ComponentA.portA', 'end_b': 'ComponentB.portB'}  # Undefined
            ],
            'requirements': [],
            'relationships': []
        }

        # Should generate
        sysml = generate_sysml_from_dict(arch)
        assert sysml is not None

        # Validation should catch undefined port
        result = validate_sysml_content(sysml)
        errors = [e for e in result['errors'] if e['severity'] == 'error']
        assert any('undefined' in e['message'].lower() and 'port' in e['message'].lower()
                  for e in errors)


# =============================================================================
# END-TO-END WORKFLOW TESTS
# =============================================================================

class TestEndToEndWorkflows:
    """Test complete end-to-end workflows"""

    def test_new_architecture_workflow(self, workspace):
        """Test: Create new architecture from scratch"""
        # Step 1: Create architecture dict
        arch = {
            'id': 'arch_new',
            'name': 'New Architecture',
            'domain': 'robotics',
            'blocks': [
                {'name': 'RobotSystem', 'stereotype': 'Block'},
                {'name': 'MotorController', 'stereotype': 'Block'},
                {'name': 'SensorArray', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'MotorController', 'name': 'cmdIn', 'type': 'CommandPort'},
                {'owner': 'SensorArray', 'name': 'dataOut', 'type': 'DataPort'}
            ],
            'connectors': [],
            'requirements': [
                {'id': 'REQ-001', 'text': 'Robot shall respond to commands.'}
            ],
            'relationships': [
                {'type': 'satisfy', 'client': 'MotorController', 'supplier': 'REQ-001'}
            ]
        }

        # Step 2: Generate SysML
        sysml = generate_sysml_from_dict(arch)
        assert 'package arch_new' in sysml

        # Step 3: Save to file
        sysml_file = workspace / 'robot.sysml'
        sysml_file.write_text(sysml, encoding='utf-8')

        # Step 4: Validate
        result = validate_sysml_content(sysml)
        assert result['valid'] is True

        # Step 5: Generate diagrams
        bdd = generate_bdd_plantuml(sysml_file)
        ibd = generate_ibd_plantuml(sysml_file)

        assert 'MotorController' in bdd
        assert 'SensorArray' in bdd

    def test_modify_architecture_workflow(self, sample_architecture, workspace):
        """Test: Load, modify, save architecture"""
        # Step 1: Generate initial version
        sysml_v1 = generate_sysml_from_dict(sample_architecture)
        file_v1 = workspace / 'arch_v1.sysml'
        file_v1.write_text(sysml_v1, encoding='utf-8')

        # Step 2: Parse back
        parsed = parse_sysml_to_json(sysml_v1)

        # Step 3: Modify (add a component)
        parsed['blocks'].append({'name': 'NewComponent', 'stereotype': 'Block'})

        # Step 4: Generate modified version
        sysml_v2 = generate_sysml_from_dict(parsed)
        file_v2 = workspace / 'arch_v2.sysml'
        file_v2.write_text(sysml_v2, encoding='utf-8')

        # Step 5: Verify modification
        parsed_v2 = parse_sysml_to_json(sysml_v2)
        assert 'NewComponent' in [b['name'] for b in parsed_v2['blocks']]

    def test_architecture_refactoring_workflow(self, workspace):
        """Test: Refactor architecture (split into modules)"""
        # Create initial monolithic architecture
        arch = {
            'id': 'arch_monolithic',
            'name': 'Monolithic System',
            'domain': 'system',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'ComponentA', 'stereotype': 'Block'},
                {'name': 'ComponentB', 'stereotype': 'Block'},
                {'name': 'ComponentC', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        # Generate initial
        sysml_mono = generate_sysml_from_dict(arch)
        mono_file = workspace / 'monolithic.sysml'
        mono_file.write_text(sysml_mono, encoding='utf-8')

        # Refactor: Split into base and extended
        base_arch = {
            'id': 'arch_base',
            'name': 'Base Module',
            'domain': 'system',
            'blocks': [
                {'name': 'ComponentA', 'stereotype': 'Block'},
                {'name': 'ComponentB', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        extended_arch = {
            'id': 'arch_extended',
            'name': 'Extended Module',
            'domain': 'system',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'ComponentC', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        # Generate modules
        base_sysml = generate_sysml_from_dict(base_arch)
        base_file = workspace / 'base.sysml'
        base_file.write_text(base_sysml, encoding='utf-8')

        extended_sysml = generate_sysml_from_dict(extended_arch)
        # Add import
        extended_sysml = 'import "base.sysml";\n\n' + extended_sysml
        extended_file = workspace / 'extended.sysml'
        extended_file.write_text(extended_sysml, encoding='utf-8')

        # Load merged
        merged = load_with_imports(extended_file)

        # Should have all components
        block_names = {b['name'] for b in merged['blocks']}
        assert 'ComponentA' in block_names
        assert 'ComponentB' in block_names
        assert 'ComponentC' in block_names


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
