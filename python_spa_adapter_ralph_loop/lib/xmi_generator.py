#!/usr/bin/env python
"""
XMI Generator for SysML v2 Models

Generates XMI (XML Metadata Interchange) format from architecture IR dictionaries.
XMI enables tool interoperability with:
- Eclipse Papyrus (SysML v2 profile)
- Cameo Systems Modeler
- IBM Rhapsody
- Other EMF-based modeling tools

XMI Format Reference:
- OMG XMI Specification: https://www.omg.org/spec/XMI/
- SysML v2 Metamodel: https://github.com/Systems-Modeling/SysML-v2-Release
"""

import xml.etree.ElementTree as ET
from xml.dom import minidom
from typing import Dict, List
import hashlib


def generate_xmi_id(name: str, element_type: str) -> str:
    """
    Generate stable XMI ID from name and type.

    Args:
        name: Element name
        element_type: Type of element (e.g., 'PartDefinition', 'PortUsage')

    Returns:
        XMI ID string (e.g., '_part_def_abc123')
    """
    # Create deterministic hash from name and type
    hash_input = f"{element_type}:{name}".encode('utf-8')
    hash_hex = hashlib.md5(hash_input).hexdigest()[:8]

    # Format as XMI ID
    type_prefix = element_type.lower().replace('definition', 'def').replace('usage', '')
    return f"_{type_prefix}_{hash_hex}"


def sanitize_xml_text(text: str) -> str:
    """
    Sanitize text for XML by escaping special characters.

    Args:
        text: Raw text string

    Returns:
        XML-safe text
    """
    return (text
            .replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace("'", '&apos;'))


def generate_xmi_from_dict(arch_dict: Dict) -> str:
    """
    Generate XMI representation from architecture IR dictionary.

    Args:
        arch_dict: Architecture intermediate representation with keys:
            - id: Architecture identifier
            - name: Architecture name
            - domain: Domain/category
            - blocks: List of component definitions
            - proxy_ports: List of port definitions
            - connectors: List of connections
            - requirements: List of requirements
            - relationships: List of satisfy/trace relationships

    Returns:
        XMI string conforming to SysML v2 metamodel
    """
    # Create root package element
    root = ET.Element('sysml:Package')
    root.set('xmi:version', '2.0')
    root.set('xmlns:xmi', 'http://www.omg.org/XMI')
    root.set('xmlns:sysml', 'https://www.omg.org/spec/SysML/20230201')

    # Package attributes
    pkg_id = generate_xmi_id(arch_dict.get('id', 'package'), 'Package')
    root.set('xmi:id', pkg_id)
    root.set('name', arch_dict.get('id', 'UnnamedPackage'))

    # Add documentation comment
    doc_comment = ET.Comment(f" {arch_dict.get('name', 'Architecture')} ")
    doc_comment.tail = '\n  '
    root.insert(0, doc_comment)

    domain_comment = ET.Comment(f" Domain: {arch_dict.get('domain', 'unknown')} ")
    domain_comment.tail = '\n\n  '
    root.insert(1, domain_comment)

    # Track element IDs for references
    element_ids = {}

    # Generate port type definitions first
    port_types = set()
    for port in arch_dict.get('proxy_ports', []):
        port_type = port.get('type', 'Port')
        if port_type and port_type not in port_types:
            port_types.add(port_type)
            port_def = ET.SubElement(root, 'ownedElement')
            port_def.set('xmi:type', 'sysml:PortDefinition')
            port_def_id = generate_xmi_id(port_type, 'PortDefinition')
            port_def.set('xmi:id', port_def_id)
            port_def.set('name', port_type)
            port_def.tail = '\n  '
            element_ids[port_type] = port_def_id

    if port_types:
        blank = ET.Comment(' Part Definitions ')
        blank.tail = '\n  '
        root.append(blank)

    # Generate part definitions (blocks)
    for block in arch_dict.get('blocks', []):
        block_name = block.get('name', 'UnnamedBlock')

        part_def = ET.SubElement(root, 'ownedElement')
        part_def.set('xmi:type', 'sysml:PartDefinition')
        part_def_id = generate_xmi_id(block_name, 'PartDefinition')
        part_def.set('xmi:id', part_def_id)
        part_def.set('name', block_name)
        part_def.tail = '\n  '
        element_ids[block_name] = part_def_id

        # Add ports owned by this block
        block_ports = [p for p in arch_dict.get('proxy_ports', [])
                      if p.get('owner') == block_name]

        for port in block_ports:
            port_usage = ET.SubElement(part_def, 'ownedPort')
            port_usage.set('xmi:type', 'sysml:PortUsage')
            port_usage_id = generate_xmi_id(f"{block_name}.{port.get('name')}", 'PortUsage')
            port_usage.set('xmi:id', port_usage_id)
            port_usage.set('name', port.get('name', 'port'))
            port_usage.tail = '\n    '

            # Reference port type definition
            port_type = port.get('type', 'Port')
            if port_type in element_ids:
                port_def_ref = ET.SubElement(port_usage, 'portDefinition')
                port_def_ref.set('xmi:idref', element_ids[port_type])
                port_def_ref.tail = '\n    '

            # Store port usage ID for connections
            element_ids[f"{block_name}.{port.get('name')}"] = port_usage_id

    # Generate requirements
    requirements = arch_dict.get('requirements', [])
    if requirements:
        blank = ET.Comment(' Requirements ')
        blank.tail = '\n  '
        root.append(blank)

        for req in requirements:
            req_def = ET.SubElement(root, 'ownedElement')
            req_def.set('xmi:type', 'sysml:RequirementDefinition')
            req_id_str = req.get('id', 'REQ-?')
            req_def_id = generate_xmi_id(req_id_str, 'RequirementDefinition')
            req_def.set('xmi:id', req_def_id)
            req_def.set('name', req_id_str.replace('-', '_'))
            req_def.tail = '\n  '
            element_ids[req_id_str] = req_def_id

            # Requirement ID
            req_id_elem = ET.SubElement(req_def, 'reqId')
            req_id_elem.text = req_id_str
            req_id_elem.tail = '\n    '

            # Requirement text
            req_text = ET.SubElement(req_def, 'text')
            req_text.text = sanitize_xml_text(req.get('text', ''))
            req_text.tail = '\n  '

    # Generate system definition with part usages
    if arch_dict.get('blocks'):
        blank = ET.Comment(' System Definition ')
        blank.tail = '\n  '
        root.append(blank)

        # Use last block as system or find one with 'System' in name
        system_block = None
        for block in arch_dict.get('blocks', []):
            if 'System' in block.get('name', ''):
                system_block = block
                break
        if not system_block:
            system_block = arch_dict.get('blocks', [])[-1] if arch_dict.get('blocks') else None

        if system_block:
            system_name = system_block.get('name', 'System')
            sys_def = ET.SubElement(root, 'ownedElement')
            sys_def.set('xmi:type', 'sysml:PartDefinition')
            sys_def_id = generate_xmi_id(f"{system_name}Instance", 'PartDefinition')
            sys_def.set('xmi:id', sys_def_id)
            sys_def.set('name', f"{system_name}")
            sys_def.tail = '\n  '

            # Add part usages for composition
            for block in arch_dict.get('blocks', []):
                if block == system_block:
                    continue  # Skip system block itself

                block_name = block.get('name', 'UnnamedBlock')
                part_usage = ET.SubElement(sys_def, 'ownedPart')
                part_usage.set('xmi:type', 'sysml:PartUsage')
                part_usage_id = generate_xmi_id(f"{system_name}.{block_name.lower()}", 'PartUsage')
                part_usage.set('xmi:id', part_usage_id)
                part_usage.set('name', block_name.lower())
                part_usage.tail = '\n    '

                # Reference part definition
                if block_name in element_ids:
                    part_def_ref = ET.SubElement(part_usage, 'partDefinition')
                    part_def_ref.set('xmi:idref', element_ids[block_name])
                    part_def_ref.tail = '\n    '

                # Add satisfy relationships
                for rel in arch_dict.get('relationships', []):
                    if rel.get('client') == block_name and rel.get('type') == 'satisfy':
                        req_id = rel.get('supplier', '')
                        if req_id in element_ids:
                            satisfy_ref = ET.SubElement(part_usage, 'satisfiedRequirement')
                            satisfy_ref.set('xmi:idref', element_ids[req_id])
                            satisfy_ref.tail = '\n    '

            # Add connections
            connectors = arch_dict.get('connectors', [])
            if connectors:
                for conn in connectors:
                    conn_usage = ET.SubElement(sys_def, 'ownedConnection')
                    conn_usage.set('xmi:type', 'sysml:ConnectionUsage')
                    conn_name = conn.get('name', 'connection')
                    conn_id = generate_xmi_id(f"{system_name}.{conn_name}", 'ConnectionUsage')
                    conn_usage.set('xmi:id', conn_id)
                    conn_usage.set('name', conn_name)
                    conn_usage.tail = '\n    '

                    # Connection ends
                    end_a = conn.get('end_a', '')
                    end_b = conn.get('end_b', '')

                    if end_a in element_ids:
                        end_elem = ET.SubElement(conn_usage, 'end')
                        end_elem.set('xmi:idref', element_ids[end_a])
                        end_elem.tail = '\n      '

                    if end_b in element_ids:
                        end_elem = ET.SubElement(conn_usage, 'end')
                        end_elem.set('xmi:idref', element_ids[end_b])
                        end_elem.tail = '\n    '

                    # Item flow (if specified)
                    item_flow = conn.get('item_flow', '')
                    if item_flow:
                        flow_elem = ET.SubElement(conn_usage, 'itemFlow')
                        flow_elem.set('xmi:type', 'sysml:ItemFlow')
                        flow_elem.tail = '\n      '

                        flow_type = ET.SubElement(flow_elem, 'itemType')
                        flow_type.text = item_flow
                        flow_type.tail = '\n    '

    # Convert to string with pretty printing
    rough_string = ET.tostring(root, encoding='utf-8')
    parsed = minidom.parseString(rough_string)
    pretty_xml = parsed.toprettyxml(indent='  ', encoding='utf-8').decode('utf-8')

    # Remove extra blank lines
    lines = [line for line in pretty_xml.split('\n') if line.strip()]
    return '\n'.join(lines)


def main():
    """Test XMI generation with sample architecture"""
    sample_arch = {
        'id': 'test_arch_001',
        'name': 'Test Architecture',
        'domain': 'test',
        'blocks': [
            {'name': 'Controller', 'stereotype': 'Block'},
            {'name': 'Sensor', 'stereotype': 'Block'},
            {'name': 'TestSystem', 'stereotype': 'Block'},
        ],
        'proxy_ports': [
            {'owner': 'Controller', 'name': 'cmdOut', 'type': 'CommandPort'},
            {'owner': 'Sensor', 'name': 'dataIn', 'type': 'DataPort'},
        ],
        'connectors': [
            {'name': 'cmd_link', 'end_a': 'Controller.cmdOut', 'end_b': 'Sensor.dataIn', 'item_flow': 'Command'},
        ],
        'requirements': [
            {'id': 'REQ-001', 'text': 'System shall respond within 100ms'},
        ],
        'relationships': [
            {'type': 'satisfy', 'client': 'Controller', 'supplier': 'REQ-001'},
        ]
    }

    xmi = generate_xmi_from_dict(sample_arch)
    print(xmi)


if __name__ == '__main__':
    main()
