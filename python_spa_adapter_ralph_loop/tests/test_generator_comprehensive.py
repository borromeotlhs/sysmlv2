"""
Comprehensive Generator Tests for SysML v2 Pipeline

Tests cover:
- Port type generation and typing
- Public keyword placement on all exposed elements
- Import statement generation
- System instance visibility
- Edge cases (no ports, no requirements, empty architectures)
- Attribute generation based on component types
- Requirement and satisfy relationship generation

Run with: pytest tests/test_generator_comprehensive.py -v
"""
import pytest
from pathlib import Path
from lib.sysml_generator import (
    generate_sysml_from_dict,
    sanitize_name,
    get_attributes_for_component
)


@pytest.fixture
def minimal_arch():
    """Minimal valid architecture dictionary"""
    return {
        'id': 'arch_test',
        'name': 'Test Architecture',
        'domain': 'test',
        'blocks': [
            {'name': 'System', 'stereotype': 'Block'}
        ],
        'proxy_ports': [],
        'connectors': [],
        'requirements': [],
        'relationships': []
    }


@pytest.fixture
def complete_arch():
    """Complete architecture with all elements"""
    return {
        'id': 'arch_complete',
        'name': 'Complete Test Architecture',
        'domain': 'aerospace',
        'blocks': [
            {'name': 'TelemetrySystem', 'stereotype': 'Block'},
            {'name': 'Sensor', 'stereotype': 'Block'},
            {'name': 'Processor', 'stereotype': 'Block'},
            {'name': 'PowerSupply', 'stereotype': 'Block'}
        ],
        'proxy_ports': [
            {'owner': 'Sensor', 'name': 'dataOut', 'type': 'DataPort'},
            {'owner': 'Processor', 'name': 'dataIn', 'type': 'DataPort'},
            {'owner': 'Processor', 'name': 'cmdOut', 'type': 'CommandPort'},
            {'owner': 'PowerSupply', 'name': 'powerOut', 'type': 'PowerPort'}
        ],
        'connectors': [
            {'name': 'dataLink', 'end_a': 'Sensor.dataOut', 'end_b': 'Processor.dataIn'},
            {'name': 'powerLink1', 'end_a': 'PowerSupply.powerOut', 'end_b': 'Sensor.dataOut'},
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
# UTILITY FUNCTION TESTS
# =============================================================================

class TestUtilityFunctions:
    """Test utility functions used by generator"""

    def test_sanitize_name_basic(self):
        """Test basic name sanitization"""
        assert sanitize_name('SimpleName') == 'SimpleName'
        assert sanitize_name('Name123') == 'Name123'
        assert sanitize_name('name_with_underscores') == 'name_with_underscores'

    def test_sanitize_name_special_chars(self):
        """Test sanitization of special characters"""
        assert sanitize_name('Name-With-Dashes') == 'Name_With_Dashes'
        assert sanitize_name('Name With Spaces') == 'Name_With_Spaces'
        assert sanitize_name('Name.With.Dots') == 'Name_With_Dots'
        assert sanitize_name('Name@Special#Chars!') == 'Name_Special_Chars_'

    def test_sanitize_name_unicode(self):
        """Test sanitization of Unicode characters"""
        assert sanitize_name('Nameαβγ') == 'Name___'
        assert sanitize_name('Component_°C') == 'Component__C'

    def test_get_attributes_processor(self):
        """Test attribute generation for processor components"""
        attrs = get_attributes_for_component('MissionComputer')
        assert 'processingPower' in ' '.join(attrs)
        assert 'memorySize' in ' '.join(attrs)

    def test_get_attributes_sensor(self):
        """Test attribute generation for sensor components"""
        attrs = get_attributes_for_component('SensorPayload')
        assert 'dataRate' in ' '.join(attrs)
        assert 'resolution' in ' '.join(attrs)

    def test_get_attributes_power(self):
        """Test attribute generation for power components"""
        attrs = get_attributes_for_component('PowerSupply')
        assert 'voltage' in ' '.join(attrs)
        assert 'current' in ' '.join(attrs)

    def test_get_attributes_comm(self):
        """Test attribute generation for communication components"""
        attrs = get_attributes_for_component('RadioTransceiver')
        assert 'frequency' in ' '.join(attrs)
        assert 'bandwidth' in ' '.join(attrs)

    def test_get_attributes_default(self):
        """Test attribute generation for generic components"""
        attrs = get_attributes_for_component('GenericComponent')
        assert 'mass' in ' '.join(attrs)
        assert 'power' in ' '.join(attrs)


# =============================================================================
# BASIC GENERATION TESTS
# =============================================================================

class TestBasicGeneration:
    """Test basic SysML generation from dictionaries"""

    def test_generate_minimal_architecture(self, minimal_arch):
        """Generate minimal valid architecture"""
        sysml = generate_sysml_from_dict(minimal_arch)

        # Check basic structure
        assert 'package arch_test {' in sysml
        assert 'import ScalarValues::*;' in sysml
        assert '// Test Architecture' in sysml
        assert '// Domain: test' in sysml
        assert 'public part def System {' in sysml
        assert '}' in sysml

    def test_generate_with_blocks(self):
        """Generate architecture with multiple blocks"""
        arch = {
            'id': 'arch_blocks',
            'name': 'Block Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'ComponentA', 'stereotype': 'Block'},
                {'name': 'ComponentB', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Should have all component definitions (not system, which goes in usage)
        assert 'public part def ComponentA {' in sysml
        assert 'public part def ComponentB {' in sysml
        assert 'public part def System {' in sysml

    def test_generate_package_name_sanitization(self):
        """Test package name is properly sanitized"""
        arch = {
            'id': 'arch-with-dashes',
            'name': 'Test',
            'domain': 'test',
            'blocks': [],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Package name should be sanitized
        assert 'package arch_with_dashes {' in sysml
        assert 'package arch-with-dashes {' not in sysml


# =============================================================================
# PORT GENERATION TESTS
# =============================================================================

class TestPortGeneration:
    """Test port type and port definition generation"""

    def test_generate_typed_ports(self):
        """Generate architecture with typed ports"""
        arch = {
            'id': 'arch_ports',
            'name': 'Port Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'Component', 'name': 'dataOut', 'type': 'DataPort'},
                {'owner': 'Component', 'name': 'cmdIn', 'type': 'CommandPort'}
            ],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Should generate port definitions
        assert 'public port def DataPort;' in sysml
        assert 'public port def CommandPort;' in sysml

        # Should generate ports with types
        assert 'port dataOut : DataPort;' in sysml
        assert 'port cmdIn : CommandPort;' in sysml

    def test_generate_untyped_ports(self):
        """Generate architecture with untyped ports"""
        arch = {
            'id': 'arch_untyped',
            'name': 'Untyped Port Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'Component', 'name': 'port1', 'type': None},
                {'owner': 'Component', 'name': 'port2', 'type': ''}
            ],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Should generate untyped ports
        assert 'port port1;' in sysml
        assert 'port port2;' in sysml

    def test_port_type_deduplication(self):
        """Port types should be deduplicated in definitions"""
        arch = {
            'id': 'arch_dedup',
            'name': 'Dedup Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'ComponentA', 'stereotype': 'Block'},
                {'name': 'ComponentB', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'ComponentA', 'name': 'port1', 'type': 'DataPort'},
                {'owner': 'ComponentA', 'name': 'port2', 'type': 'DataPort'},
                {'owner': 'ComponentB', 'name': 'port3', 'type': 'DataPort'}
            ],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Should only define DataPort once
        count = sysml.count('public port def DataPort;')
        assert count == 1


# =============================================================================
# PUBLIC KEYWORD TESTS
# =============================================================================

class TestPublicKeywords:
    """Test public keyword placement on exposed elements"""

    def test_public_on_requirements(self):
        """Requirements should have public keyword"""
        arch = {
            'id': 'arch_req',
            'name': 'Requirement Test',
            'domain': 'test',
            'blocks': [{'name': 'System', 'stereotype': 'Block'}],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [
                {'id': 'REQ-001', 'text': 'Test requirement.'}
            ],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)
        assert 'public requirement REQ_001 {' in sysml

    def test_public_on_port_definitions(self):
        """Port definitions should have public keyword"""
        arch = {
            'id': 'arch_portdef',
            'name': 'Port Def Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'Component', 'name': 'port1', 'type': 'DataPort'}
            ],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)
        assert 'public port def DataPort;' in sysml

    def test_public_on_part_definitions(self):
        """Part definitions should have public keyword"""
        arch = {
            'id': 'arch_partdef',
            'name': 'Part Def Test',
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

        sysml = generate_sysml_from_dict(arch)
        assert 'public part def Component {' in sysml
        assert 'public part def System {' in sysml

    def test_public_on_system_instance(self):
        """System instance should have public keyword"""
        arch = {
            'id': 'arch_inst',
            'name': 'Instance Test',
            'domain': 'test',
            'blocks': [
                {'name': 'MySystem', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)
        assert 'public part mysystem : MySystem;' in sysml


# =============================================================================
# IMPORT STATEMENT TESTS
# =============================================================================

class TestImportStatements:
    """Test import statement generation"""

    def test_import_scalar_values(self, minimal_arch):
        """ScalarValues should always be imported"""
        sysml = generate_sysml_from_dict(minimal_arch)
        assert 'import ScalarValues::*;' in sysml

    def test_import_placement(self, minimal_arch):
        """Import should come after package declaration"""
        sysml = generate_sysml_from_dict(minimal_arch)
        lines = sysml.split('\n')

        package_idx = next(i for i, line in enumerate(lines) if 'package' in line)
        import_idx = next(i for i, line in enumerate(lines) if 'import ScalarValues' in line)

        # Import should come after package
        assert import_idx > package_idx


# =============================================================================
# CONNECTION GENERATION TESTS
# =============================================================================

class TestConnectionGeneration:
    """Test connection statement generation"""

    def test_generate_connections(self):
        """Generate connection statements"""
        arch = {
            'id': 'arch_conn',
            'name': 'Connection Test',
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

        sysml = generate_sysml_from_dict(arch)

        # Should generate connect statement with lowercase instance names
        assert 'connect componenta.portA to componentb.portB;' in sysml

    def test_connection_instance_name_sanitization(self):
        """Connection instance names should be sanitized"""
        arch = {
            'id': 'arch_conn_san',
            'name': 'Connection Sanitize Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component-A', 'stereotype': 'Block'},
                {'name': 'Component-B', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'Component-A', 'name': 'portA', 'type': 'DataPort'},
                {'owner': 'Component-B', 'name': 'portB', 'type': 'DataPort'}
            ],
            'connectors': [
                {'name': 'link1', 'end_a': 'Component-A.portA', 'end_b': 'Component-B.portB'}
            ],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Should sanitize instance names in connections
        assert 'connect component_a.portA to component_b.portB;' in sysml


# =============================================================================
# REQUIREMENT GENERATION TESTS
# =============================================================================

class TestRequirementGeneration:
    """Test requirement and satisfy relationship generation"""

    def test_generate_requirements(self):
        """Generate requirement definitions"""
        arch = {
            'id': 'arch_req',
            'name': 'Requirement Test',
            'domain': 'test',
            'blocks': [{'name': 'System', 'stereotype': 'Block'}],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [
                {'id': 'REQ-001', 'text': 'System shall process data.'},
                {'id': 'REQ-002', 'text': 'System shall maintain power budget.'}
            ],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Should generate requirements
        assert 'public requirement REQ_001 {' in sysml
        assert 'doc "System shall process data."' in sysml
        assert 'public requirement REQ_002 {' in sysml
        assert 'doc "System shall maintain power budget."' in sysml

    def test_generate_satisfy_relationships(self):
        """Generate satisfy statements in part instances"""
        arch = {
            'id': 'arch_satisfy',
            'name': 'Satisfy Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component', 'stereotype': 'Block'}
            ],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [
                {'id': 'REQ-001', 'text': 'Test requirement.'}
            ],
            'relationships': [
                {'type': 'satisfy', 'client': 'Component', 'supplier': 'REQ-001'}
            ]
        }

        sysml = generate_sysml_from_dict(arch)

        # Should generate satisfy statement inside component instance
        assert 'part component : Component {' in sysml
        assert 'satisfy REQ_001;' in sysml

    def test_requirement_text_escaping(self):
        """Requirement text with quotes should be escaped"""
        arch = {
            'id': 'arch_escape',
            'name': 'Escape Test',
            'domain': 'test',
            'blocks': [{'name': 'System', 'stereotype': 'Block'}],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [
                {'id': 'REQ-001', 'text': 'System shall support "quoted" text.'}
            ],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Quotes should be escaped
        assert '\\"quoted\\"' in sysml


# =============================================================================
# EDGE CASE TESTS
# =============================================================================

class TestEdgeCases:
    """Test edge cases and boundary conditions"""

    def test_empty_architecture(self):
        """Generate architecture with no blocks"""
        arch = {
            'id': 'arch_empty',
            'name': 'Empty Test',
            'domain': 'test',
            'blocks': [],
            'proxy_ports': [],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Should still generate valid package
        assert 'package arch_empty {' in sysml
        assert 'import ScalarValues::*;' in sysml
        assert '}' in sysml

    def test_no_ports(self):
        """Generate architecture with blocks but no ports"""
        arch = {
            'id': 'arch_no_ports',
            'name': 'No Ports Test',
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

        sysml = generate_sysml_from_dict(arch)

        # Should generate component without ports
        assert 'public part def Component {' in sysml
        # Should still have attributes
        assert 'attribute' in sysml

    def test_no_requirements(self):
        """Generate architecture without requirements"""
        arch = {
            'id': 'arch_no_req',
            'name': 'No Requirements Test',
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

        sysml = generate_sysml_from_dict(arch)

        # Should generate valid architecture without requirements section
        assert 'public part def Component {' in sysml
        assert 'requirement' not in sysml

    def test_no_connections(self):
        """Generate architecture without connections"""
        arch = {
            'id': 'arch_no_conn',
            'name': 'No Connections Test',
            'domain': 'test',
            'blocks': [
                {'name': 'System', 'stereotype': 'Block'},
                {'name': 'Component', 'stereotype': 'Block'}
            ],
            'proxy_ports': [
                {'owner': 'Component', 'name': 'port1', 'type': 'DataPort'}
            ],
            'connectors': [],
            'requirements': [],
            'relationships': []
        }

        sysml = generate_sysml_from_dict(arch)

        # Should generate valid architecture without connections
        assert 'public part def Component {' in sysml
        assert 'port port1 : DataPort;' in sysml
        assert 'connect' not in sysml

    def test_complete_architecture(self, complete_arch):
        """Generate complete architecture with all elements"""
        sysml = generate_sysml_from_dict(complete_arch)

        # Should have all sections
        assert 'package arch_complete {' in sysml
        assert 'import ScalarValues::*;' in sysml
        assert '// Complete Test Architecture' in sysml
        assert '// Domain: aerospace' in sysml
        assert '// Requirements' in sysml
        assert '// Port Definitions' in sysml
        assert '// Component Definitions' in sysml
        assert '// System Definition' in sysml
        assert '// System Instance' in sysml
        assert '// Connections' in sysml

        # Verify specific elements
        assert 'public requirement REQ_001 {' in sysml
        assert 'public port def DataPort;' in sysml
        assert 'public part def Sensor {' in sysml
        assert 'satisfy REQ_001;' in sysml
        assert 'connect sensor.dataOut to processor.dataIn;' in sysml


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
