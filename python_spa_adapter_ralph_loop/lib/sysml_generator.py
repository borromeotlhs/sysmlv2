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


def generate_sysml_from_dict(arch: dict) -> str:
    """
    Convert architecture dictionary to SysML v2 textual syntax.

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
        SysML v2 textual syntax as a string
    """
    arch_id = arch.get('id', 'unknown')
    name = arch.get('name', 'Unknown Architecture')
    domain = arch.get('domain', 'system')

    # Sanitize package name
    package_name = sanitize_name(arch_id)

    lines = []
    lines.append(f'package {package_name} {{')
    lines.append(f'\t// {name}')
    lines.append(f'\t// Domain: {domain}')
    lines.append('')

    # Import standard libraries
    lines.append('\timport ScalarValues::*;')
    lines.append('')

    # Generate interface definitions from port types
    interface_types = set()
    for port in arch.get('proxy_ports', []):
        port_type = port.get('type', '')
        if port_type:
            interface_types.add(port_type)

    if interface_types:
        lines.append('\t// Interface Definitions')
        for iface in sorted(interface_types):
            lines.append(f'\tinterface def {iface};')
        lines.append('')

    # Generate part definitions for each block
    lines.append('\t// Part Definitions')

    blocks = arch.get('blocks', [])
    proxy_ports = arch.get('proxy_ports', [])

    # Build port map: block_name -> [ports]
    port_map = {}
    for port in proxy_ports:
        owner = port.get('owner', '')
        if owner not in port_map:
            port_map[owner] = []
        port_map[owner].append(port)

    for block in blocks:
        block_name = block.get('name', 'Unknown')
        lines.append(f'\tpart def {block_name} {{')

        # Add ports if any
        if block_name in port_map:
            for port in port_map[block_name]:
                port_name = port.get('name', 'port')
                port_type = port.get('type', '')
                lines.append(f'\t\tport {port_name} : {port_type};')

        lines.append('\t}')
        lines.append('')

    # Generate requirement definitions
    requirements = arch.get('requirements', [])
    if requirements:
        lines.append('\t// Requirements')
        for req in requirements:
            req_id = req.get('id', 'REQ')
            req_text = req.get('text', '')
            # Escape quotes in text
            req_text_safe = req_text.replace('"', '\\"')
            lines.append(f'\trequirement <\'{req_id}\'> {{')
            lines.append(f'\t\tdoc /* {req_text_safe} */')
            lines.append('\t}')
            lines.append('')

    # Generate system part that instantiates and connects everything
    system_block = blocks[0] if blocks else None
    if system_block:
        system_name = system_block.get('name', 'System')
        lines.append(f'\t// System Assembly')
        lines.append(f'\tpart {sanitize_name(system_name.lower())} : {system_name} {{')

        # Instantiate subsystem parts
        for block in blocks[1:]:
            block_name = block.get('name', 'Unknown')
            part_name = sanitize_name(block_name.lower())
            lines.append(f'\t\tpart {part_name} : {block_name};')

        lines.append('')

        # Add connections
        connectors = arch.get('connectors', [])
        if connectors:
            lines.append('\t\t// Connections')
            for conn in connectors:
                conn_name = conn.get('name', 'connection')
                end_a = conn.get('end_a', '')  # e.g., "MissionComputer.cmdOut"
                end_b = conn.get('end_b', '')
                item_flow = conn.get('item_flow', '')

                # Parse ends to get part.port format
                if '.' in end_a and '.' in end_b:
                    part_a, port_a = end_a.split('.', 1)
                    part_b, port_b = end_b.split('.', 1)

                    part_a_lower = sanitize_name(part_a.lower())
                    part_b_lower = sanitize_name(part_b.lower())

                    # SysML v2 connection syntax
                    lines.append(f'\t\tconnection : {conn_name} connect ')
                    lines.append(f'\t\t\t{part_a_lower}.{port_a} to {part_b_lower}.{port_b};')

        lines.append('')

        # Add satisfy relationships
        relationships = arch.get('relationships', [])
        if relationships:
            lines.append('\t\t// Requirement Satisfaction')
            for rel in relationships:
                rel_type = rel.get('type', 'satisfy')
                client = rel.get('client', '')
                supplier = rel.get('supplier', '')

                if rel_type == 'satisfy' and client and supplier:
                    client_lower = sanitize_name(client.lower())
                    # Find the requirement by ID
                    req_obj = next((r for r in requirements if r.get('id') == supplier), None)
                    if req_obj:
                        lines.append(f'\t\tsatisfy requirement <\'{supplier}\'> by {client_lower};')

        lines.append('\t}')

    lines.append('}')
    lines.append('')

    return '\n'.join(lines)
