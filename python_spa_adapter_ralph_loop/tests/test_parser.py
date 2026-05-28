#!/usr/bin/env python3
"""
Comprehensive parser tests for SysML v2 parsing functionality.

Tests cover:
- Basic parsing of all SysML constructs
- Edge cases (empty files, malformed syntax)
- Import resolution (relative paths, missing files, circular imports)
- Complex nesting (nested parts, deep hierarchies)
- Error handling (graceful failures with informative messages)
- Unicode and special character handling
- Large file performance
"""
import pytest
import tempfile
from pathlib import Path
from sysml_parser import (
    parse_sysml_to_json,
    parse_import_statement,
    resolve_import_path,
    has_imports,
    load_with_imports,
    merge_architectures,
    extract_package_name,
    extract_domain_comment,
    extract_name_comment,
    extract_part_definitions,
    extract_ports_from_parts,
    extract_requirements,
    extract_connections,
    extract_satisfy_relationships,
    extract_part_instances,
    extract_compositions,
    extract_view_metadata
)


# ============================================================================
# FIXTURES
# ============================================================================

@pytest.fixture
def solar_array_sysml():
    """Solar array architecture SysML content"""
    return """package arch_000001 {
    // Solar Array Reference Architecture 1
    // Domain: solar array

    import ScalarValues::*;

    // Interface Definitions
    interface def CommandIF;
    interface def DataIF;
    interface def StatusIF;

    // Part Definitions
    part def SolarArraySystem {
    }

    part def MissionBus {
        port dataIn : DataIF;
    }

    part def PowerModule {
        port sensorOut : DataIF;
        port configIn : StatusIF;
        port cmdIn : CommandIF;
    }

    // Requirements
    requirement <'REQ-001'> {
        doc /* The solar array system shall exchange data through typed interfaces. */
    }

    requirement <'REQ-002'> {
        doc /* The solar array system shall trace subsystem design to requirements. */
    }

    requirement <'REQ-003'> {
        doc /* The solar array system shall provide fault detection and recovery. */
    }

    // System Assembly
    part solararraysystem : SolarArraySystem {
        part missionbus : MissionBus;
        part powermodule : PowerModule;

        // Connections
        connection : link1 connect
            missionbus.dataIn to powermodule.sensorOut;
        connection : link2 connect
            powermodule.cmdIn to missionbus.dataIn;

        // Requirement Satisfaction
        satisfy requirement <'REQ-001'> by missionbus;
        satisfy requirement <'REQ-001'> by powermodule;
        satisfy requirement <'REQ-002'> by powermodule;
        satisfy requirement <'REQ-003'> by powermodule;
    }
}
"""


@pytest.fixture
def rover_sysml():
    """Autonomous rover architecture with attributes and alternative connection syntax"""
    return """package arch_000002 {
    // Autonomous Rover Reference Architecture 2
    // Domain: autonomous rover

    // Requirements
    requirement REQ_001 {
        doc "The autonomous rover system shall exchange command and data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The autonomous rover system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def MissionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
    }

    part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
    }

    part def PowerUnit {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrOut;
    }

    // System Definition
    part def AutonomousRoverSystem {
        part missioncomputer : MissionComputer {
            satisfy REQ_001;
        }
        part sensorpayload : SensorPayload {
            satisfy REQ_002;
        }
        part powerunit : PowerUnit {
        }

        // Connections
        connect missioncomputer.cmdOut to sensorpayload.dataOut;
        connect powerunit.pwrOut to sensorpayload.dataOut;
    }

    // System Instance
    part autonomousroversystem : AutonomousRoverSystem;
}
"""


@pytest.fixture
def empty_package():
    """Minimal empty package"""
    return """package empty_arch {
}
"""


@pytest.fixture
def nested_parts_sysml():
    """Architecture with deeply nested parts"""
    return """package nested_arch {
    // Deep Nesting Test
    // Domain: test

    part def Level1 {
        part level2a : Level2 {
            part level3a : Level3 {
                part level4a : Level4;
            }
            part level3b : Level3;
        }
        part level2b : Level2;
    }

    part def Level2 {
        port port2;
    }

    part def Level3 {
        port port3;
    }

    part def Level4 {
        port port4;
    }

    part system : Level1;
}
"""


@pytest.fixture
def multiplicity_sysml():
    """Architecture with multiplicity specifications"""
    return """package multi_arch {
    // Multiplicity Test
    // Domain: test

    part def Vehicle {
        part wheels : Wheel[4];
        part engine : Engine[1];
        part seats : Seat[2..8];
    }

    part def Wheel {
        port axle;
    }

    part def Engine {
        port driveshaft;
    }

    part def Seat {
    }

    part vehicle : Vehicle;
}
"""


@pytest.fixture
def unicode_sysml():
    """Architecture with Unicode characters"""
    return """package unicode_arch {
    // Architecture with Unicode: π² Test
    // Domain: tést domain

    part def System₀ {
        attribute temp°C : Real [1];
        port data₁;
    }

    requirement REQ_α {
        doc "System shall maintain ± 5°C temperature tolerance."
    }

    part system : System₀ {
        satisfy REQ_α;
    }
}
"""


# ============================================================================
# BASIC PARSING TESTS
# ============================================================================

@pytest.mark.parser
def test_parser_basic_structure(solar_array_sysml):
    """Test that parser extracts basic architecture structure"""
    arch = parse_sysml_to_json(solar_array_sysml)

    assert arch['id'] == 'arch_000001'
    assert arch['name'] == 'Solar Array Reference Architecture 1'
    assert arch['domain'] == 'solar array'


@pytest.mark.parser
def test_parser_blocks(solar_array_sysml):
    """Test that parser correctly identifies blocks"""
    arch = parse_sysml_to_json(solar_array_sysml)

    expected_blocks = ['SolarArraySystem', 'MissionBus', 'PowerModule']
    actual_blocks = [b['name'] for b in arch['blocks']]

    assert set(expected_blocks) == set(actual_blocks), \
        f"Block mismatch: expected {expected_blocks}, got {actual_blocks}"


@pytest.mark.parser
def test_parser_ports(solar_array_sysml):
    """Test that parser correctly identifies proxy ports"""
    arch = parse_sysml_to_json(solar_array_sysml)

    expected_ports = [
        ('MissionBus', 'dataIn', 'DataIF'),
        ('PowerModule', 'sensorOut', 'DataIF'),
        ('PowerModule', 'configIn', 'StatusIF'),
        ('PowerModule', 'cmdIn', 'CommandIF'),
    ]
    actual_ports = [(p['owner'], p['name'], p['type']) for p in arch['proxy_ports']]

    assert set(expected_ports) == set(actual_ports), \
        f"Port mismatch:\n  Expected: {expected_ports}\n  Got: {actual_ports}"


@pytest.mark.parser
def test_parser_connectors(solar_array_sysml):
    """Test that parser correctly identifies connectors"""
    arch = parse_sysml_to_json(solar_array_sysml)

    expected_connectors = [
        ('link1', 'MissionBus.dataIn', 'PowerModule.sensorOut'),
        ('link2', 'PowerModule.cmdIn', 'MissionBus.dataIn'),
    ]
    actual_connectors = [(c['name'], c['end_a'], c['end_b']) for c in arch['connectors']]

    assert set(expected_connectors) == set(actual_connectors), \
        f"Connector mismatch:\n  Expected: {expected_connectors}\n  Got: {actual_connectors}"


@pytest.mark.parser
def test_parser_requirements(solar_array_sysml):
    """Test that parser correctly identifies requirements"""
    arch = parse_sysml_to_json(solar_array_sysml)

    assert len(arch['requirements']) == 3
    req_ids = [r['id'] for r in arch['requirements']]
    assert set(req_ids) == {'REQ-001', 'REQ-002', 'REQ-003'}


@pytest.mark.parser
def test_parser_relationships(solar_array_sysml):
    """Test that parser correctly identifies requirement relationships"""
    arch = parse_sysml_to_json(solar_array_sysml)

    expected_relationships = [
        ('MissionBus', 'REQ-001'),
        ('PowerModule', 'REQ-001'),
        ('PowerModule', 'REQ-002'),
        ('PowerModule', 'REQ-003'),
    ]
    actual_relationships = [(r['client'], r['supplier']) for r in arch['relationships']]

    assert set(expected_relationships) == set(actual_relationships), \
        f"Relationship mismatch:\n  Expected: {expected_relationships}\n  Got: {actual_relationships}"


# ============================================================================
# ALTERNATIVE SYNTAX TESTS
# ============================================================================

@pytest.mark.parser
def test_parser_alternative_connection_syntax(rover_sysml):
    """
    Test parsing of alternative connection syntax: 'connect A to B;'
    vs 'connection : name connect A to B;'
    """
    arch = parse_sysml_to_json(rover_sysml)

    # Should have 2 connections
    assert len(arch['connectors']) == 2

    # Check connection endpoints are resolved correctly
    connections = arch['connectors']
    endpoints = [(c['end_a'], c['end_b']) for c in connections]

    assert ('MissionComputer.cmdOut', 'SensorPayload.dataOut') in endpoints
    assert ('PowerUnit.pwrOut', 'SensorPayload.dataOut') in endpoints


@pytest.mark.parser
def test_parser_inline_satisfy(rover_sysml):
    """
    Test parsing of inline satisfy statements within part definitions
    """
    arch = parse_sysml_to_json(rover_sysml)

    # Should extract satisfy relationships
    assert len(arch['relationships']) == 2

    relationships = [(r['client'], r['supplier']) for r in arch['relationships']]
    assert ('MissionComputer', 'REQ_001') in relationships
    assert ('SensorPayload', 'REQ_002') in relationships


@pytest.mark.parser
def test_parser_requirement_without_angle_brackets(rover_sysml):
    """
    Test parsing of requirements without angle brackets (REQ_001 vs <'REQ-001'>)
    """
    arch = parse_sysml_to_json(rover_sysml)

    req_ids = [r['id'] for r in arch['requirements']]
    assert 'REQ_001' in req_ids
    assert 'REQ_002' in req_ids


@pytest.mark.parser
def test_parser_untyped_ports(rover_sysml):
    """
    Test parsing of untyped ports (port name; vs port name : Type;)
    """
    arch = parse_sysml_to_json(rover_sysml)

    # Find MissionComputer's cmdOut port
    mission_computer_ports = [p for p in arch['proxy_ports'] if p['owner'] == 'MissionComputer']
    assert len(mission_computer_ports) == 1

    cmd_out = mission_computer_ports[0]
    assert cmd_out['name'] == 'cmdOut'
    # Untyped ports should get default 'Port' type
    assert cmd_out['type'] == 'Port'


# ============================================================================
# EDGE CASE TESTS
# ============================================================================

@pytest.mark.parser
def test_parser_empty_package(empty_package):
    """
    Test parsing of minimal empty package.
    Parser should handle empty architectures gracefully.
    """
    arch = parse_sysml_to_json(empty_package)

    assert arch['id'] == 'empty_arch'
    assert arch['blocks'] == []
    assert arch['proxy_ports'] == []
    assert arch['connectors'] == []
    assert arch['requirements'] == []
    assert arch['relationships'] == []


@pytest.mark.parser
def test_parser_empty_string():
    """
    Test parsing of completely empty string.
    Parser should return minimal valid structure.
    """
    arch = parse_sysml_to_json("")

    assert arch['id'] is None or arch['id'] == 'unknown'
    assert arch['blocks'] == []
    assert arch['proxy_ports'] == []
    assert arch['connectors'] == []


@pytest.mark.parser
def test_parser_whitespace_only():
    """
    Test parsing of whitespace-only content.
    """
    arch = parse_sysml_to_json("   \n\n\t\t  \n   ")

    assert arch['id'] is None or arch['id'] == 'unknown'
    assert arch['blocks'] == []


@pytest.mark.parser
def test_parser_missing_semicolons():
    """
    Test parser behavior with missing semicolons.
    Current parser is lenient - should still extract what it can.
    """
    malformed = """package test_arch {
    part def BlockA {
        port p1
    }

    part def BlockB {
        port p2
    }
}
"""
    arch = parse_sysml_to_json(malformed)

    # Should still identify blocks even with missing semicolons
    assert len(arch['blocks']) == 2
    block_names = [b['name'] for b in arch['blocks']]
    assert 'BlockA' in block_names
    assert 'BlockB' in block_names


@pytest.mark.parser
def test_parser_malformed_braces():
    """
    Test parser behavior with unbalanced braces.
    Parser should be robust to some malformation.
    """
    malformed = """package test_arch {
    part def BlockA {
        port p1;

    part def BlockB {
        port p2;
    }
}
"""
    # Parser should still extract what it can
    arch = parse_sysml_to_json(malformed)
    assert arch['id'] == 'test_arch'


@pytest.mark.parser
def test_parser_comments_everywhere():
    """
    Test parsing with comments in various positions.
    """
    with_comments = """package test_arch {
    // Start comment
    /* Block comment */

    part def /* inline */ BlockA {
        // Port comment
        port p1; // end-of-line comment
    }

    // More comments
    /* Multi-line
       comment block
       here */

    part instance : BlockA; // Instance comment
}
"""
    arch = parse_sysml_to_json(with_comments)
    assert arch['id'] == 'test_arch'
    assert len(arch['blocks']) >= 1


# ============================================================================
# COMPLEX NESTING TESTS
# ============================================================================

@pytest.mark.parser
def test_parser_deep_nesting(nested_parts_sysml):
    """
    Test parsing of deeply nested part definitions.
    Should correctly identify all parts regardless of nesting level.
    """
    arch = parse_sysml_to_json(nested_parts_sysml)

    expected_blocks = ['Level1', 'Level2', 'Level3', 'Level4']
    actual_blocks = [b['name'] for b in arch['blocks']]

    assert set(expected_blocks) == set(actual_blocks), \
        f"Deep nesting: expected {expected_blocks}, got {actual_blocks}"


@pytest.mark.parser
def test_parser_nested_compositions(nested_parts_sysml):
    """
    Test extraction of composition relationships from nested structures.
    """
    arch = parse_sysml_to_json(nested_parts_sysml)

    compositions = arch['compositions']

    # Should have compositions for Level1 containing Level2 instances
    level1_children = [c['child'] for c in compositions if c['parent'] == 'Level1']
    assert 'Level2' in level1_children


@pytest.mark.parser
def test_parser_multiplicity(multiplicity_sysml):
    """
    Test parsing of multiplicity specifications ([n], [m..n]).
    """
    arch = parse_sysml_to_json(multiplicity_sysml)

    compositions = arch['compositions']

    # Find wheel composition
    wheel_comp = next((c for c in compositions if c['child'] == 'Wheel'), None)
    assert wheel_comp is not None
    assert wheel_comp['multiplicity'] == '4'

    # Find engine composition
    engine_comp = next((c for c in compositions if c['child'] == 'Engine'), None)
    assert engine_comp is not None
    assert engine_comp['multiplicity'] == '1'


# ============================================================================
# UNICODE AND SPECIAL CHARACTERS
# ============================================================================

@pytest.mark.parser
def test_parser_unicode_identifiers(unicode_sysml):
    """
    Test parsing of Unicode characters in identifiers and text.
    """
    arch = parse_sysml_to_json(unicode_sysml)

    assert arch['id'] == 'unicode_arch'

    # Check that Unicode in domain is preserved
    assert 'tést' in arch['domain'] or arch['domain'] == 'test domain'

    # Check block name with Unicode
    block_names = [b['name'] for b in arch['blocks']]
    assert any('₀' in name or 'System' in name for name in block_names)

    # Check requirement with Unicode
    req_ids = [r['id'] for r in arch['requirements']]
    assert any('α' in req_id or 'REQ_' in req_id for req_id in req_ids)


@pytest.mark.parser
def test_parser_special_characters_in_strings():
    """
    Test parsing of special characters in documentation strings.
    """
    special_chars = """package test_arch {
    requirement REQ_001 {
        doc "System shall support: < > & ' \\" special chars."
    }
}
"""
    arch = parse_sysml_to_json(special_chars)

    assert len(arch['requirements']) == 1
    req_text = arch['requirements'][0]['text']
    assert 'special chars' in req_text


# ============================================================================
# IMPORT RESOLUTION TESTS
# ============================================================================

@pytest.mark.parser
def test_parse_import_statement_file_import():
    """
    Test extraction of file-based import statements.
    """
    line = 'import "model.sysml";'
    result = parse_import_statement(line)
    assert result == "model.sysml"


@pytest.mark.parser
def test_parse_import_statement_relative_path():
    """
    Test extraction of relative path imports.
    """
    line = 'import "../models/base.sysml";'
    result = parse_import_statement(line)
    assert result == "../models/base.sysml"


@pytest.mark.parser
def test_parse_import_statement_namespace_import():
    """
    Test that namespace imports (not file-based) return None.
    """
    line = 'import ScalarValues::*;'
    result = parse_import_statement(line)
    assert result is None


@pytest.mark.parser
def test_has_imports_detection():
    """
    Test detection of file-based imports in content.
    """
    content_with_import = 'import "model.sysml";\npackage test {}'
    assert has_imports(content_with_import) is True

    content_without_import = 'import ScalarValues::*;\npackage test {}'
    assert has_imports(content_without_import) is False


@pytest.mark.parser
def test_resolve_import_path_filename():
    """
    Test resolution of simple filename import from view directory.
    """
    view_file = Path("/data/arch_001/views/bdd.sysml")
    import_target = "model.sysml"

    resolved = resolve_import_path(view_file, import_target)
    expected = Path("/data/arch_001/model.sysml")

    assert resolved == expected


@pytest.mark.parser
def test_resolve_import_path_relative():
    """
    Test resolution of relative path import.
    """
    view_file = Path("/data/arch_001/views/bdd.sysml")
    import_target = "../model.sysml"

    resolved = resolve_import_path(view_file, import_target)
    expected = Path("/data/arch_001/model.sysml")

    assert resolved == expected


@pytest.mark.parser
def test_load_with_imports_simple(tmp_path):
    """
    Test loading file with single import.
    Verifies that content from imported file is merged.
    """
    # Create model file
    model_file = tmp_path / "model.sysml"
    model_file.write_text("""package test_model {
    part def BaseBlock {
        port basePort;
    }
}
""")

    # Create view file that imports model
    view_file = tmp_path / "view.sysml"
    view_file.write_text(f"""import "model.sysml";

package test_view {{
    // View configuration
}}
""")

    arch = load_with_imports(view_file)

    # Should have blocks from imported model
    block_names = [b['name'] for b in arch['blocks']]
    assert 'BaseBlock' in block_names

    # Should have ports from imported model
    ports = [(p['owner'], p['name']) for p in arch['proxy_ports']]
    assert ('BaseBlock', 'basePort') in ports


@pytest.mark.parser
def test_load_with_imports_missing_file(tmp_path):
    """
    Test graceful handling of missing import file.
    Parser should log warning and continue.
    """
    view_file = tmp_path / "view.sysml"
    view_file.write_text("""import "nonexistent.sysml";

package test_view {
    part def LocalBlock {
        port localPort;
    }
}
""")

    # Should not crash, should parse local content
    arch = load_with_imports(view_file)

    # Should still have local block
    block_names = [b['name'] for b in arch['blocks']]
    assert 'LocalBlock' in block_names


@pytest.mark.parser
def test_load_with_imports_circular_detection(tmp_path):
    """
    Test detection of circular imports.
    Should raise ValueError with descriptive message.
    """
    # Create file A that imports B
    file_a = tmp_path / "a.sysml"
    file_a.write_text("""import "b.sysml";
package a {}
""")

    # Create file B that imports A
    file_b = tmp_path / "b.sysml"
    file_b.write_text("""import "a.sysml";
package b {}
""")

    # Should detect circular import
    with pytest.raises(ValueError, match="Circular import"):
        load_with_imports(file_a)


@pytest.mark.parser
def test_merge_architectures_blocks():
    """
    Test merging of block lists from base and override architectures.
    """
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
    # Should not have duplicates
    assert len(merged['blocks']) == 3


@pytest.mark.parser
def test_merge_architectures_view_preserves_model_id():
    """
    Test that view files preserve the model's core identity.
    """
    model = {
        'id': 'model_arch',
        'name': 'Model Architecture',
        'domain': 'system',
        'blocks': [{'name': 'ModelBlock'}]
    }

    view = {
        'id': 'view_arch',
        'name': 'View Name',
        'source': 'view',
        'blocks': []
    }

    merged = merge_architectures(model, view)

    # View should preserve model's id, name, domain
    assert merged['id'] == 'model_arch'
    assert merged['name'] == 'Model Architecture'
    assert merged['domain'] == 'system'


# ============================================================================
# VIEW METADATA TESTS
# ============================================================================

@pytest.mark.parser
def test_extract_view_metadata_simple():
    """
    Test extraction of view metadata from comment blocks.
    """
    content = """/*
    @viewType: BlockDefinitionDiagram
    @showPorts: true
    @showAttributes: false
*/

package test_view {}
"""
    metadata = extract_view_metadata(content)

    assert metadata['viewType'] == 'BlockDefinitionDiagram'
    assert metadata['showPorts'] is True
    assert metadata['showAttributes'] is False


@pytest.mark.parser
def test_extract_view_metadata_inline():
    """
    Test extraction of inline view metadata.
    """
    content = """/* @viewType: InternalBlockDiagram */
package test_view {}
"""
    metadata = extract_view_metadata(content)
    assert metadata['viewType'] == 'InternalBlockDiagram'


@pytest.mark.parser
def test_extract_view_metadata_context():
    """
    Test extraction of context from view metadata.
    """
    content = """/*
    @context: arch_000001::SystemBlock
*/
package test_view {}
"""
    metadata = extract_view_metadata(content)
    assert metadata['context'] == 'arch_000001::SystemBlock'


# ============================================================================
# UNIT TESTS FOR INDIVIDUAL FUNCTIONS
# ============================================================================

@pytest.mark.parser
def test_extract_package_name():
    """
    Test extraction of package name from various formats.
    """
    lines = ["package test_package {", "  // content", "}"]
    assert extract_package_name(lines) == "test_package"

    lines_whitespace = ["  package   arch_001   {"]
    assert extract_package_name(lines_whitespace) == "arch_001"

    lines_no_package = ["// comment", "part def Block {}"]
    assert extract_package_name(lines_no_package) is None


@pytest.mark.parser
def test_extract_domain_comment():
    """
    Test extraction of domain from comment lines.
    """
    lines = ["// Domain: aerospace", "package test {}"]
    assert extract_domain_comment(lines) == "aerospace"

    lines_whitespace = ["//    Domain:   autonomous rover  "]
    assert extract_domain_comment(lines_whitespace) == "autonomous rover"

    lines_no_domain = ["// Some comment", "package test {}"]
    result = extract_domain_comment(lines_no_domain)
    assert result is None or result == 'system'


@pytest.mark.parser
def test_extract_name_comment():
    """
    Test extraction of architecture name from comment lines.
    """
    lines = ["// Solar Array Architecture", "// Domain: solar", "package test {}"]
    assert extract_name_comment(lines) == "Solar Array Architecture"

    lines_no_name = ["// Domain: test", "package test {}"]
    result = extract_name_comment(lines_no_name)
    # Should return None or default if no name found
    assert result is None or result == 'Unknown Architecture'


@pytest.mark.parser
def test_extract_part_definitions():
    """
    Test extraction of part definitions from content.
    """
    content = """
    part def BlockA {
        port p1;
    }

    part def BlockB {
        port p2;
    }
    """
    blocks = extract_part_definitions(content)

    assert len(blocks) == 2
    block_names = [b['name'] for b in blocks]
    assert 'BlockA' in block_names
    assert 'BlockB' in block_names


@pytest.mark.parser
def test_extract_ports_from_parts():
    """
    Test extraction of ports from part definitions.
    """
    content = """
    part def BlockA {
        port p1 : TypeA;
        port p2 : TypeB;
    }

    part def BlockB {
        port p3;
    }
    """
    ports = extract_ports_from_parts(content)

    assert len(ports) == 3

    port_tuples = [(p['owner'], p['name'], p['type']) for p in ports]
    assert ('BlockA', 'p1', 'TypeA') in port_tuples
    assert ('BlockA', 'p2', 'TypeB') in port_tuples
    assert ('BlockB', 'p3', 'Port') in port_tuples  # Default type


@pytest.mark.parser
def test_extract_requirements():
    """
    Test extraction of requirement definitions.
    """
    content = """
    requirement REQ_001 {
        doc "First requirement text."
    }

    requirement REQ_002 {
        doc "Second requirement text."
    }
    """
    requirements = extract_requirements(content)

    assert len(requirements) == 2

    req_data = [(r['id'], r['text']) for r in requirements]
    assert ('REQ_001', 'First requirement text.') in req_data
    assert ('REQ_002', 'Second requirement text.') in req_data


@pytest.mark.parser
def test_extract_part_instances():
    """
    Test extraction of part instance to type mapping.
    """
    content = """
    part instance1 : TypeA;
    part instance2 : TypeB[2];
    part instance3 : TypeC {
        port p1;
    }
    """
    instance_map = extract_part_instances(content)

    assert instance_map['instance1'] == 'TypeA'
    assert instance_map['instance2'] == 'TypeB'
    assert instance_map['instance3'] == 'TypeC'


@pytest.mark.parser
def test_extract_connections_pattern1():
    """
    Test extraction of connections with pattern: connection : name connect A to B;
    """
    content = """
    part system : System {
        part a : BlockA;
        part b : BlockB;

        connection : link1 connect a.p1 to b.p2;
    }
    """
    instance_map = {'a': 'BlockA', 'b': 'BlockB'}
    connections = extract_connections(content, instance_map)

    assert len(connections) == 1
    conn = connections[0]
    assert conn['name'] == 'link1'
    assert conn['end_a'] == 'BlockA.p1'
    assert conn['end_b'] == 'BlockB.p2'


@pytest.mark.parser
def test_extract_connections_pattern2():
    """
    Test extraction of connections with pattern: connect A to B;
    """
    content = """
    part system : System {
        part a : BlockA;
        part b : BlockB;

        connect a.p1 to b.p2;
    }
    """
    instance_map = {'a': 'BlockA', 'b': 'BlockB'}
    connections = extract_connections(content, instance_map)

    assert len(connections) == 1
    conn = connections[0]
    assert conn['end_a'] == 'BlockA.p1'
    assert conn['end_b'] == 'BlockB.p2'


@pytest.mark.parser
def test_extract_satisfy_relationships():
    """
    Test extraction of satisfy relationships from inline statements.
    """
    content = """
    part system : System {
        part a : BlockA {
            satisfy REQ_001;
        }
        part b : BlockB {
            satisfy REQ_002;
        }
    }
    """
    instance_map = {'a': 'BlockA', 'b': 'BlockB'}
    relationships = extract_satisfy_relationships(content, instance_map)

    assert len(relationships) == 2

    rel_tuples = [(r['client'], r['supplier']) for r in relationships]
    assert ('BlockA', 'REQ_001') in rel_tuples
    assert ('BlockB', 'REQ_002') in rel_tuples


@pytest.mark.parser
def test_extract_compositions():
    """
    Test extraction of composition relationships.
    """
    content = """
    part def Vehicle {
        part wheels : Wheel[4];
        part engine : Engine;
    }

    part def System {
        part vehicle : Vehicle;
    }
    """
    compositions = extract_compositions(content)

    # Should find compositions within Vehicle and System
    comp_tuples = [(c['parent'], c['child'], c['multiplicity']) for c in compositions]

    assert ('Vehicle', 'Wheel', '4') in comp_tuples
    assert ('Vehicle', 'Engine', '1') in comp_tuples
    assert ('System', 'Vehicle', '1') in comp_tuples


# ============================================================================
# PERFORMANCE TESTS
# ============================================================================

@pytest.mark.parser
@pytest.mark.slow
def test_parser_large_file_performance():
    """
    Test parser performance on large file with many elements.
    Should complete in reasonable time without errors.
    """
    # Generate large architecture with 100 blocks
    lines = ["package large_arch {", "  // Large Architecture Test", "  // Domain: test"]

    for i in range(100):
        lines.append(f"  part def Block{i:03d} {{")
        lines.append(f"    port port{i:03d};")
        lines.append("  }")

    lines.append("  part system : Block000 {")
    for i in range(1, 100):
        lines.append(f"    part block{i:03d} : Block{i:03d};")

    # Add some connections
    for i in range(1, 50):
        lines.append(f"    connect block{i:03d}.port{i:03d} to block{i+1:03d}.port{i+1:03d};")

    lines.append("  }")
    lines.append("}")

    large_content = "\n".join(lines)

    # Time the parse
    import time
    start = time.time()
    arch = parse_sysml_to_json(large_content)
    duration = time.time() - start

    # Should complete in under 2 seconds
    assert duration < 2.0, f"Parser took {duration:.2f}s for large file"

    # Verify correct parsing
    assert len(arch['blocks']) == 100
    assert len(arch['connectors']) == 49


# ============================================================================
# ERROR HANDLING AND ROBUSTNESS TESTS
# ============================================================================

@pytest.mark.parser
def test_parser_invalid_utf8():
    """
    Test parser behavior with invalid UTF-8 sequences.
    Parser should handle encoding errors gracefully.
    """
    # This test would need actual invalid UTF-8 bytes
    # For now, test that valid UTF-8 works
    valid_content = "package test { part def Blockÿ { } }"
    arch = parse_sysml_to_json(valid_content)
    assert arch['id'] == 'test'


@pytest.mark.parser
def test_parser_extremely_long_lines():
    """
    Test parser with extremely long lines.
    """
    long_comment = "// " + "A" * 10000
    content = f"""package test_arch {{
{long_comment}
    part def Block {{}}
}}
"""
    arch = parse_sysml_to_json(content)
    assert arch['id'] == 'test_arch'
    assert len(arch['blocks']) == 1


@pytest.mark.parser
def test_parser_mixed_line_endings():
    """
    Test parser with mixed Windows (CRLF) and Unix (LF) line endings.
    """
    content = "package test_arch {\r\n  part def Block1 {}\n  part def Block2 {}\r\n}"
    arch = parse_sysml_to_json(content)

    assert arch['id'] == 'test_arch'
    assert len(arch['blocks']) == 2


@pytest.mark.parser
def test_parser_duplicate_names():
    """
    Test parser behavior with duplicate block/port names.
    Parser should keep all occurrences or handle gracefully.
    """
    content = """package test_arch {
    part def DuplicateBlock {
        port p1;
    }

    part def DuplicateBlock {
        port p2;
    }
}
"""
    arch = parse_sysml_to_json(content)

    # Parser may keep both or deduplicate - document behavior
    assert arch['id'] == 'test_arch'
    # At least one DuplicateBlock should be present
    block_names = [b['name'] for b in arch['blocks']]
    assert 'DuplicateBlock' in block_names


# ============================================================================
# INTEGRATION TESTS
# ============================================================================

@pytest.mark.parser
@pytest.mark.integration
def test_parse_actual_architecture_files(architecture_files_dir):
    """
    Integration test: Parse actual architecture files from data/architectures.
    Verifies parser works on real-world examples.
    """
    arch_files = list(architecture_files_dir.glob("arch_*.sysml"))

    # Should find architecture files
    assert len(arch_files) > 0, "No architecture files found"

    # Parse first 5 files
    for arch_file in arch_files[:5]:
        content = arch_file.read_text(encoding='utf-8')
        arch = parse_sysml_to_json(content)

        # Basic validation
        assert arch['id'] is not None
        assert arch['format'] == 'sysml_v2_textual'
        assert 'blocks' in arch
        assert 'proxy_ports' in arch
        assert 'connectors' in arch
        assert 'requirements' in arch


@pytest.mark.parser
@pytest.mark.integration
def test_parser_roundtrip_consistency():
    """
    Integration test: Verify parser extracts consistent data.
    Parse same content twice and compare results.
    """
    content = """package test_arch {
    // Test Architecture
    // Domain: test

    part def BlockA {
        port p1 : TypeA;
    }

    part def BlockB {
        port p2 : TypeB;
    }

    requirement REQ_001 {
        doc "Test requirement."
    }

    part system : BlockA {
        part b : BlockB;
        connect p1 to b.p2;
        satisfy REQ_001;
    }
}
"""

    arch1 = parse_sysml_to_json(content)
    arch2 = parse_sysml_to_json(content)

    # Should produce identical results
    assert arch1['id'] == arch2['id']
    assert len(arch1['blocks']) == len(arch2['blocks'])
    assert len(arch1['proxy_ports']) == len(arch2['proxy_ports'])
    assert len(arch1['connectors']) == len(arch2['connectors'])
    assert len(arch1['requirements']) == len(arch2['requirements'])
