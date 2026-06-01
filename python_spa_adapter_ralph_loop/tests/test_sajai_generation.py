#!/usr/bin/env python3
"""
Tests for SAJAI generation from SysML v2 architectures.

Specifically tests:
- Connector field names match SAJAI specification (sourcePortId, targetPortId)
- Port reference integrity
- On-the-fly generation
"""

import pytest
import json
import sys
from pathlib import Path

# Add lib to path
ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
if str(LIB) not in sys.path:
    sys.path.insert(0, str(LIB))

from sajai_generator import sysml_to_sajai, ir_to_sajai


@pytest.fixture
def sample_sysml_file(tmp_path):
    """Create a sample SysML file with connectors for testing."""
    sysml_content = """
package 'TestSystem' {
    part def Motor {
        port powerIn;
        port dataOut;
    }

    part def Controller {
        port dataIn;
        port powerOut;
    }

    part system : TestSystem {
        part motor : Motor;
        part ctrl : Controller;

        connect ctrl.powerOut to motor.powerIn;
        connect motor.dataOut to ctrl.dataIn;
    }
}
"""
    sysml_file = tmp_path / "test_system.sysml"
    sysml_file.write_text(sysml_content)
    return sysml_file


@pytest.mark.integration
def test_connector_field_names_match_spec(sample_sysml_file):
    """
    Test that generated connectors use correct field names from SAJAI spec.

    SAJAI specification requires:
    - sourcePortId (not fromPortId)
    - targetPortId (not toPortId)
    """
    # Generate SAJAI without saving to file (in-memory)
    sajai_data = sysml_to_sajai(sample_sysml_file, output_path=None)

    # Verify SAJAI structure
    assert 'format' in sajai_data
    assert sajai_data['format'] == 'SAJAI'
    assert 'scenes' in sajai_data

    # Find connectors in all scenes
    connectors_found = False
    for scene_id, scene in sajai_data['scenes'].items():
        if 'connectors' in scene and len(scene['connectors']) > 0:
            connectors_found = True

            for connector in scene['connectors']:
                # Assert correct field names per SAJAI spec
                assert 'sourcePortId' in connector, \
                    f"Connector missing 'sourcePortId': {connector}"
                assert 'targetPortId' in connector, \
                    f"Connector missing 'targetPortId': {connector}"

                # Assert WRONG field names are NOT present
                assert 'fromPortId' not in connector, \
                    f"Connector has deprecated 'fromPortId' field: {connector}"
                assert 'toPortId' not in connector, \
                    f"Connector has deprecated 'toPortId' field: {connector}"

                # Verify IDs are non-empty strings
                assert isinstance(connector['sourcePortId'], str)
                assert len(connector['sourcePortId']) > 0
                assert isinstance(connector['targetPortId'], str)
                assert len(connector['targetPortId']) > 0

    # Ensure we actually tested connectors
    assert connectors_found, "No connectors found in generated SAJAI data"


@pytest.mark.integration
def test_connector_ports_reference_valid_components(sample_sysml_file):
    """
    Test that connector port IDs reference actual ports in the parts array.

    Ensures referential integrity between connectors and ports.
    """
    # Generate SAJAI
    sajai_data = sysml_to_sajai(sample_sysml_file, output_path=None)

    # Collect all port IDs from parts
    all_port_ids = set()
    for scene_id, scene in sajai_data['scenes'].items():
        if 'ports' in scene:
            for port in scene['ports']:
                all_port_ids.add(port['id'])

    # Verify connector port references are valid
    for scene_id, scene in sajai_data['scenes'].items():
        if 'connectors' in scene:
            for connector in scene['connectors']:
                source_id = connector['sourcePortId']
                target_id = connector['targetPortId']

                assert source_id in all_port_ids, \
                    f"Connector sourcePortId '{source_id}' does not reference a valid port"
                assert target_id in all_port_ids, \
                    f"Connector targetPortId '{target_id}' does not reference a valid port"


@pytest.mark.integration
def test_in_memory_generation_no_file_written(sample_sysml_file, tmp_path):
    """
    Test that in-memory generation (output_path=None) does not write a file.
    """
    # Generate SAJAI with no output path
    sajai_data = sysml_to_sajai(sample_sysml_file, output_path=None)

    # Verify data returned
    assert sajai_data is not None
    assert 'format' in sajai_data

    # Verify no .sajai file created in tmp_path
    sajai_files = list(tmp_path.glob("*.sajai"))
    assert len(sajai_files) == 0, \
        f"In-memory generation should not write files, but found: {sajai_files}"


@pytest.mark.integration
def test_file_generation_writes_to_disk(sample_sysml_file, tmp_path):
    """
    Test that generation with output_path writes the file.
    """
    output_path = tmp_path / "output.sajai"

    # Generate SAJAI with output path
    sajai_data = sysml_to_sajai(sample_sysml_file, output_path=output_path)

    # Verify file was written
    assert output_path.exists(), "Output file should be created"

    # Verify file content matches returned data
    file_content = json.loads(output_path.read_text())
    assert file_content == sajai_data, "File content should match returned data"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
