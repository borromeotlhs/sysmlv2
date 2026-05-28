#!/usr/bin/env python3
"""
Extract SysML 1.x model from MagicDraw .mdzip file and convert to SysML v2 .sysml format
"""

import xml.etree.ElementTree as ET
import json
from collections import defaultdict

# Parse the XMI file
tree = ET.parse('extracted_mdzip/com.nomagic.magicdraw.uml_model.model')
root = tree.getroot()

# Namespace mappings
ns = {
    'xmi': 'http://www.omg.org/spec/XMI/20131001',
    'uml': 'http://www.omg.org/spec/UML/20131001',
    'sysml': 'http://www.omg.org/spec/SysML/20181001/SysML',
    'StandardProfile': 'http://www.omg.org/spec/UML/20131001/StandardProfile'
}

# Data structures
blocks = {}
requirements = {}
ports = {}
attributes = {}
connections = []
compositions = []

def get_stereotype(element):
    """Check if element has SysML Block stereotype"""
    # Look for applied stereotypes in MagicDraw XMI
    return element.get('{http://www.omg.org/spec/SysML/20181001/SysML}stereotype', None)

def extract_blocks(root):
    """Extract all Class elements that represent SysML Blocks"""
    # Find nestedClassifier elements (these are the block definitions)
    for elem in root.findall('.//nestedClassifier[@xmi:type="uml:Class"]', ns):
        block_id = elem.get('{http://www.omg.org/spec/XMI/20131001}id')
        block_name = elem.get('name')

        if block_name and block_id:
            blocks[block_id] = {
                'id': block_id,
                'name': block_name,
                'attributes': [],
                'ports': [],
                'parts': []
            }

            # Extract attributes (ownedAttribute with no aggregation)
            for attr in elem.findall('./ownedAttribute[@xmi:type="uml:Property"]', ns):
                attr_name = attr.get('name')
                attr_type = attr.get('type', 'Real')
                aggregation = attr.get('aggregation')

                if attr_name and not aggregation:
                    blocks[block_id]['attributes'].append({
                        'name': attr_name,
                        'type': attr_type
                    })
                elif attr_name and aggregation == 'composite':
                    # This is a part (composition)
                    blocks[block_id]['parts'].append({
                        'name': attr_name,
                        'type': attr_type,
                        'id': attr.get('{http://www.omg.org/spec/XMI/20131001}id')
                    })

            # Extract ports (ownedAttribute with type Port)
            for port in elem.findall('./ownedAttribute[@xmi:type="uml:Port"]', ns):
                port_name = port.get('name')
                port_type = port.get('type', 'Port')

                if port_name:
                    blocks[block_id]['ports'].append({
                        'name': port_name,
                        'type': port_type
                    })

def extract_ports(root):
    """Extract port definitions from the model"""
    # In SysML 1.x, ports are typically Port elements
    for elem in root.findall('.//ownedAttribute[@xmi:type="uml:Port"]', ns):
        port_id = elem.get('{http://www.omg.org/spec/XMI/20131001}id')
        port_name = elem.get('name')
        port_type = elem.get('type', 'Port')

        if port_name and port_id:
            ports[port_id] = {
                'id': port_id,
                'name': port_name,
                'type': port_type
            }

def extract_requirements(root):
    """Extract requirements from the model"""
    # Requirements in SysML 1.x may be Class elements with requirement stereotype
    for elem in root.findall('.//packagedElement', ns):
        elem_type = elem.get('{http://www.omg.org/spec/XMI/20131001}type')
        req_id = elem.get('{http://www.omg.org/spec/XMI/20131001}id')
        req_name = elem.get('name')

        # Look for elements that might be requirements
        if req_name and 'REQ' in req_name.upper():
            body = elem.find('.//body')
            req_text = body.text if body is not None else f"Requirement {req_name}"

            requirements[req_id] = {
                'id': req_name,
                'text': req_text
            }

def extract_connectors(root):
    """Extract connectors (connections between parts)"""
    for conn in root.findall('.//connector', ns):
        conn_id = conn.get('{http://www.omg.org/spec/XMI/20131001}id')
        conn_name = conn.get('name', '')

        # Get connector ends
        ends = conn.findall('.//end', ns)
        if len(ends) >= 2:
            source_role = ends[0].get('role')
            target_role = ends[1].get('role')

            connections.append({
                'id': conn_id,
                'name': conn_name,
                'source': source_role,
                'target': target_role
            })

# Execute extraction
print("Extracting blocks...")
extract_blocks(root)
print(f"Found {len(blocks)} blocks")

print("\nExtracting ports...")
extract_ports(root)
print(f"Found {len(ports)} ports")

print("\nExtracting requirements...")
extract_requirements(root)
print(f"Found {len(requirements)} requirements")

print("\nExtracting connectors...")
extract_connectors(root)
print(f"Found {len(connections)} connections")

# Print summary
print("\n=== EXTRACTION SUMMARY ===")
print("\nBlocks:")
for block_id, block in blocks.items():
    print(f"  - {block['name']}")
    if block['parts']:
        print(f"    Parts: {', '.join([p['name'] for p in block['parts']])}")
    if block['attributes']:
        print(f"    Attributes: {', '.join([a['name'] for a in block['attributes']])}")

print("\nPorts:")
for port_id, port in ports.items():
    print(f"  - {port['name']} : {port['type']}")

print("\nRequirements:")
for req_id, req in requirements.items():
    print(f"  - {req['id']}: {req['text'][:60]}...")

print("\nConnections:")
for conn in connections:
    print(f"  - {conn.get('name', 'unnamed')}: {conn['source']} -> {conn['target']}")

# Save extracted data to JSON for inspection
output_data = {
    'blocks': blocks,
    'ports': ports,
    'requirements': requirements,
    'connections': connections
}

with open('extracted_model.json', 'w') as f:
    json.dump(output_data, f, indent=2)

print("\n\nExtracted data saved to: extracted_model.json")
