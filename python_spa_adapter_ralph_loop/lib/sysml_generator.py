#!/usr/bin/env python
"""
SysML v2 Generator Library

Provides functions to generate SysML v2 textual syntax (.sysml) from Python
dictionary representations of architectures.

This module is used by:
- scripts/json_to_sysml.py (converts existing JSON files)
- scripts/generate_sample_architectures.py (generates .sysml directly)
- scripts/generate_varied_architectures.py (generates .sysml directly)
"""


def sanitize_name(name: str) -> str:
    """
    Sanitize names for SysML v2 identifiers.

    SysML v2 allows alphanumeric characters and underscores.
    Replace spaces and special chars with underscores.

    Args:
        name: The name to sanitize

    Returns:
        Sanitized name safe for SysML v2
    """
    return ''.join(c if c.isalnum() or c == '_' else '_' for c in name)


def get_attributes_for_component(component_name: str) -> list:
    """
    Generate realistic attributes based on component name heuristics.

    Args:
        component_name: Name of the component

    Returns:
        List of attribute declarations
    """
    name_lower = component_name.lower()
    attributes = []

    # Computer/Processor components
    if any(kw in name_lower for kw in ['computer', 'processor', 'cpu', 'controller']):
        attributes.append('attribute processingPower : Real [1];')
        attributes.append('attribute memorySize : Real [1];')

    # Sensor/Payload components
    elif any(kw in name_lower for kw in ['sensor', 'payload', 'camera', 'radar', 'detector']):
        attributes.append('attribute dataRate : Real [1];')
        attributes.append('attribute resolution : Real [1];')

    # Power components
    elif any(kw in name_lower for kw in ['power', 'battery', 'supply', 'converter']):
        attributes.append('attribute voltage : Real [1];')
        attributes.append('attribute current : Real [1];')

    # Communication components
    elif any(kw in name_lower for kw in ['comm', 'radio', 'antenna', 'transceiver', 'link']):
        attributes.append('attribute frequency : Real [1];')
        attributes.append('attribute bandwidth : Real [1];')

    # Storage components
    elif any(kw in name_lower for kw in ['storage', 'memory', 'recorder', 'disk']):
        attributes.append('attribute capacity : Real [1];')
        attributes.append('attribute transferRate : Real [1];')

    # Default attributes for general components
    else:
        attributes.append('attribute mass : Real [1];')
        attributes.append('attribute power : Real [1];')

    return attributes


def generate_sysml_from_dict(arch: dict) -> str:
    """
    Convert architecture dictionary to valid SysML v2 textual syntax.

    Expected dictionary structure:
    {
        'id': 'arch_000001',
        'name': 'UAV Payload Reference Architecture 1',
        'domain': 'uav payload',
        'blocks': [
            {'name': 'UavPayloadSystem', 'stereotype': 'Block'},
            {'name': 'MissionComputer', 'stereotype': 'Block'},
            ...
        ],
        'proxy_ports': [
            {'owner': 'MissionComputer', 'name': 'cmdOut', 'type': 'CommandIF'},
            ...
        ],
        'connectors': [
            {'name': 'cmdLink', 'end_a': 'MissionComputer.cmdOut',
             'end_b': 'SensorPayload.dataOut', 'item_flow': 'Command'},
            ...
        ],
        'requirements': [
            {'id': 'REQ-001', 'text': 'The system shall...'},
            ...
        ],
        'relationships': [
            {'type': 'satisfy', 'client': 'MissionComputer', 'supplier': 'REQ-001'},
            ...
        ]
    }

    Args:
        arch: Dictionary containing architecture data

    Returns:
        Valid SysML v2 textual syntax as a string
    """
    arch_id = arch.get('id', 'unknown')
    name = arch.get('name', 'Unknown Architecture')
    domain = arch.get('domain', 'system')

    # Sanitize package name
    package_name = sanitize_name(arch_id)

    lines = []
    lines.append(f'package {package_name} {{')
    lines.append('')
    lines.append('    import ScalarValues::*;')
    lines.append('')
    lines.append(f'    // {name}')
    lines.append(f'    // Domain: {domain}')
    lines.append('')

    blocks = arch.get('blocks', [])
    proxy_ports = arch.get('proxy_ports', [])
    connectors = arch.get('connectors', [])
    requirements = arch.get('requirements', [])
    relationships = arch.get('relationships', [])

    # Build port map: block_name -> [ports]
    port_map = {}
    for port in proxy_ports:
        owner = port.get('owner', '')
        if owner not in port_map:
            port_map[owner] = []
        port_map[owner].append(port)

    # Collect unique port types for port def generation
    port_types = set()
    for port in proxy_ports:
        port_type = port.get('type')
        if port_type:
            port_types.add(port_type)

    # Build satisfy map: client_name -> [requirement_ids]
    satisfy_map = {}
    for rel in relationships:
        if rel.get('type') == 'satisfy':
            client = rel.get('client', '')
            supplier = rel.get('supplier', '')
            if client not in satisfy_map:
                satisfy_map[client] = []
            satisfy_map[client].append(sanitize_name(supplier))

    # Generate requirements
    if requirements:
        lines.append('    // Requirements')
        for req in requirements:
            req_id = sanitize_name(req.get('id', 'REQ'))
            req_text = req.get('text', '').replace('"', '\\"')
            lines.append(f'    public requirement {req_id} {{')
            lines.append(f'        doc "{req_text}"')
            lines.append('    }')
            lines.append('')

    # Generate port definitions
    if port_types:
        lines.append('    // Port Definitions')
        for port_type in sorted(port_types):
            lines.append(f'    public port def {port_type};')
        lines.append('')

    # Generate part definitions for subsystem blocks (skip system block)
    lines.append('    // Component Definitions')
    for block in blocks[1:]:
        block_name = block.get('name', 'Unknown')
        lines.append(f'    public part def {block_name} {{')

        # Add attributes based on component type
        attributes = get_attributes_for_component(block_name)
        for attr in attributes:
            lines.append(f'        {attr}')

        # Add ports if any
        if block_name in port_map:
            for port in port_map[block_name]:
                port_name = port.get('name', 'port')
                port_type = port.get('type')
                if port_type:
                    lines.append(f'        port {port_name} : {port_type};')
                else:
                    lines.append(f'        port {port_name};')

        lines.append('    }')
        lines.append('')

    # Generate system part definition and usage
    system_block = blocks[0] if blocks else None
    if system_block:
        system_name = system_block.get('name', 'System')
        system_usage = sanitize_name(system_name.lower())

        lines.append(f'    // System Definition')
        lines.append(f'    public part def {system_name} {{')

        # Instantiate subsystem parts inside the definition
        for block in blocks[1:]:
            block_name = block.get('name', 'Unknown')
            part_name = sanitize_name(block_name.lower())
            lines.append(f'        part {part_name} : {block_name} {{')

            # Add satisfy statements if this component satisfies any requirements
            if block_name in satisfy_map:
                for req_id in satisfy_map[block_name]:
                    lines.append(f'            satisfy {req_id};')

            lines.append('        }')

        lines.append('')

        # Add connections between parts
        if connectors:
            lines.append('        // Connections')
            for conn in connectors:
                end_a = conn.get('end_a', '')
                end_b = conn.get('end_b', '')

                if '.' in end_a and '.' in end_b:
                    part_a, port_a = end_a.split('.', 1)
                    part_b, port_b = end_b.split('.', 1)

                    part_a_lower = sanitize_name(part_a.lower())
                    part_b_lower = sanitize_name(part_b.lower())

                    lines.append(f'        connect {part_a_lower}.{port_a} to {part_b_lower}.{port_b};')

        lines.append('    }')
        lines.append('')

        # Create system usage instance
        lines.append(f'    // System Instance')
        lines.append(f'    public part {system_usage} : {system_name};')
        lines.append('')

    lines.append('}')
    return '\n'.join(lines)
