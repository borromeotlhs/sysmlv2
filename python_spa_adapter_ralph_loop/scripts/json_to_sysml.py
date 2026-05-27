#!/usr/bin/env python
"""
Convert JSON IR architecture files to SysML v2 textual syntax (.sysml).

This script reads JSON architecture files and generates valid SysML v2 code
that can be validated with the SysML v2 Pilot Implementation.

Usage:
    python3 scripts/json_to_sysml.py                    # Convert all JSON files
    python3 scripts/json_to_sysml.py --input data/architectures/arch_000001.json
    python3 scripts/json_to_sysml.py --output outputs/sysml/
"""
import json
import argparse
from pathlib import Path


def sanitize_name(name: str) -> str:
    """Sanitize names for SysML v2 identifiers"""
    # SysML v2 allows alphanumeric, underscore
    # Replace spaces and special chars with underscores
    return ''.join(c if c.isalnum() or c == '_' else '_' for c in name)


def generate_sysml_from_json(arch: dict) -> str:
    """Convert JSON architecture to SysML v2 textual syntax"""

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


def convert_file(input_path: Path, output_dir: Path):
    """Convert a single JSON file to .sysml"""
    try:
        arch = json.loads(input_path.read_text(encoding='utf-8'))
        sysml_content = generate_sysml_from_json(arch)

        # Output filename: arch_000001.json -> arch_000001.sysml
        output_file = output_dir / input_path.with_suffix('.sysml').name
        output_file.write_text(sysml_content, encoding='utf-8')

        print(f'✓ {input_path.name} -> {output_file.name}')
        return True

    except Exception as e:
        print(f'✗ {input_path.name}: {e}')
        return False


def main():
    parser = argparse.ArgumentParser(
        description='Convert JSON IR to SysML v2 textual syntax'
    )
    parser.add_argument(
        '--input',
        type=Path,
        help='Input JSON file or directory (default: data/architectures/)'
    )
    parser.add_argument(
        '--output',
        type=Path,
        default=Path('outputs/sysml'),
        help='Output directory for .sysml files (default: outputs/sysml/)'
    )

    args = parser.parse_args()

    # Determine input path
    if args.input:
        input_path = args.input
    else:
        input_path = Path('data/architectures')

    # Create output directory
    args.output.mkdir(parents=True, exist_ok=True)

    # Collect JSON files
    if input_path.is_file():
        json_files = [input_path]
    elif input_path.is_dir():
        json_files = sorted(input_path.glob('*.json'))
    else:
        print(f'Error: {input_path} does not exist')
        return 1

    if not json_files:
        print(f'No JSON files found in {input_path}')
        return 1

    # Convert files
    print(f'Converting {len(json_files)} files...')
    success = 0
    for json_file in json_files:
        if convert_file(json_file, args.output):
            success += 1

    print(f'\nConverted {success}/{len(json_files)} files to {args.output}')
    return 0 if success == len(json_files) else 1


if __name__ == '__main__':
    exit(main())
