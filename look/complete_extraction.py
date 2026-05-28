#!/usr/bin/env python3
"""
Complete extraction of SysML 1.x model from claudeValidation.mdzip
Captures all elements including domain, stereotypes, parts, ports, and connectors.
"""

import xml.etree.ElementTree as ET
import json
from typing import Dict, List, Any
from pathlib import Path

# Define namespace mappings
NAMESPACES = {
    'xmi': 'http://www.omg.org/spec/XMI/20131001',
    'uml': 'http://www.omg.org/spec/UML/20131001',
    'sysml': 'http://www.omg.org/spec/SysML/20181001/SysML',
    'StandardProfile': 'http://www.omg.org/spec/UML/20131001/StandardProfile',
}

def get_element_name(elem: ET.Element) -> str:
    """Get the name attribute of an element."""
    return elem.get('name', 'unnamed')

def get_element_id(elem: ET.Element) -> str:
    """Get the xmi:id of an element."""
    return elem.get('{http://www.omg.org/spec/XMI/20131001}id', '')

def get_element_type(elem: ET.Element) -> str:
    """Get the xmi:type of an element."""
    return elem.get('{http://www.omg.org/spec/XMI/20131001}type', elem.tag.split('}')[-1])

def extract_stereotypes(elem: ET.Element) -> List[str]:
    """Extract stereotype applications from an element."""
    stereotypes = []

    # Look for stereotype applications (they reference the base element)
    elem_id = get_element_id(elem)

    # Check common SysML stereotypes in attributes
    for attr in elem.attrib:
        if 'sysml' in attr.lower() or 'stereotype' in attr.lower():
            stereotypes.append(attr)

    return stereotypes

def extract_attributes(elem: ET.Element, id_map: Dict) -> List[Dict[str, Any]]:
    """Extract ownedAttribute elements (parts, properties)."""
    attributes = []

    for attr in elem.findall('.//ownedAttribute', NAMESPACES):
        attr_info = {
            'id': get_element_id(attr),
            'name': get_element_name(attr),
            'type': get_element_type(attr),
            'aggregation': attr.get('aggregation', 'none'),
            'visibility': attr.get('visibility', 'public'),
        }

        # Get the type reference
        type_ref = attr.get('type')
        if type_ref and type_ref in id_map:
            attr_info['type_name'] = id_map[type_ref]
        else:
            attr_info['type_ref'] = type_ref

        # Check for multiplicity
        lower = None
        upper = None
        for lower_val in attr.findall('.//lowerValue', NAMESPACES):
            lower = lower_val.get('value', '1')
        for upper_val in attr.findall('.//upperValue', NAMESPACES):
            upper = upper_val.get('value', '1')

        if lower is not None or upper is not None:
            attr_info['multiplicity'] = f"[{lower or '0'}..{upper or '*'}]"

        attributes.append(attr_info)

    return attributes

def extract_ports(elem: ET.Element, id_map: Dict) -> List[Dict[str, Any]]:
    """Extract ownedPort elements."""
    ports = []

    for port in elem.findall('.//ownedPort', NAMESPACES):
        port_info = {
            'id': get_element_id(port),
            'name': get_element_name(port),
            'type': get_element_type(port),
            'visibility': port.get('visibility', 'public'),
        }

        # Get the type reference
        type_ref = port.get('type')
        if type_ref and type_ref in id_map:
            port_info['type_name'] = id_map[type_ref]
        else:
            port_info['type_ref'] = type_ref

        ports.append(port_info)

    return ports

def extract_connectors(elem: ET.Element, id_map: Dict) -> List[Dict[str, Any]]:
    """Extract ownedConnector elements."""
    connectors = []

    for conn in elem.findall('.//ownedConnector', NAMESPACES):
        conn_info = {
            'id': get_element_id(conn),
            'name': get_element_name(conn),
            'type': get_element_type(conn),
            'ends': []
        }

        # Extract connector ends
        for end in conn.findall('.//end', NAMESPACES):
            end_info = {
                'role': end.get('role', ''),
                'partWithPort': end.get('partWithPort', ''),
            }

            # Resolve role names
            role_ref = end.get('role')
            if role_ref and role_ref in id_map:
                end_info['role_name'] = id_map[role_ref]

            pwp_ref = end.get('partWithPort')
            if pwp_ref and pwp_ref in id_map:
                end_info['part_name'] = id_map[pwp_ref]

            conn_info['ends'].append(end_info)

        connectors.append(conn_info)

    return connectors

def extract_nested_classifiers(elem: ET.Element, id_map: Dict, depth: int = 0) -> List[Dict[str, Any]]:
    """Recursively extract nestedClassifier elements."""
    classifiers = []

    for classifier in elem.findall('./nestedClassifier', NAMESPACES):
        classifier_info = {
            'id': get_element_id(classifier),
            'name': get_element_name(classifier),
            'type': get_element_type(classifier),
            'depth': depth,
            'stereotypes': extract_stereotypes(classifier),
            'attributes': extract_attributes(classifier, id_map),
            'ports': extract_ports(classifier, id_map),
            'connectors': extract_connectors(classifier, id_map),
            'nested_classifiers': extract_nested_classifiers(classifier, id_map, depth + 1)
        }

        classifiers.append(classifier_info)

    return classifiers

def build_id_map(root: ET.Element) -> Dict[str, str]:
    """Build a map of xmi:id to name for all elements."""
    id_map = {}

    for elem in root.iter():
        elem_id = get_element_id(elem)
        elem_name = get_element_name(elem)
        if elem_id and elem_name != 'unnamed':
            id_map[elem_id] = elem_name

    return id_map

def extract_requirements(root: ET.Element, id_map: Dict) -> List[Dict[str, Any]]:
    """Extract requirements from the model."""
    requirements = []

    # Look for elements with 'requirement' stereotype or 'REQ' in name
    for elem in root.iter():
        elem_name = get_element_name(elem)
        elem_type = get_element_type(elem)

        # Check if it's a requirement
        if 'requirement' in elem_type.lower() or 'REQ' in elem_name:
            req_info = {
                'id': get_element_id(elem),
                'name': elem_name,
                'type': elem_type,
            }

            # Extract text/body if available
            for owned_comment in elem.findall('.//ownedComment', NAMESPACES):
                body = owned_comment.get('body', '')
                if body:
                    req_info['text'] = body

            requirements.append(req_info)

    return requirements

def extract_model(xml_file: Path) -> Dict[str, Any]:
    """Extract complete model structure from XMI file."""
    tree = ET.parse(xml_file)
    root = tree.getroot()

    # Build ID to name mapping first
    print("Building ID map...")
    id_map = build_id_map(root)
    print(f"Found {len(id_map)} named elements")

    # Find the Model element
    model = root.find('.//uml:Model', NAMESPACES)
    if model is None:
        raise ValueError("No uml:Model found in XMI file")

    model_name = get_element_name(model)
    print(f"Extracting model: {model_name}")

    # Extract Architecture package
    arch_package = None
    for pkg in model.findall('.//packagedElement[@name="Architecture"]', NAMESPACES):
        arch_package = pkg
        break

    if arch_package is None:
        raise ValueError("No Architecture package found")

    # Extract Structure package
    struct_package = None
    for pkg in arch_package.findall('.//packagedElement[@name="Structure"]', NAMESPACES):
        struct_package = pkg
        break

    if struct_package is None:
        raise ValueError("No Structure package found")

    # Extract Automotive Domain
    domain = None
    for cls in struct_package.findall('.//packagedElement[@name="Automotive Domain"]', NAMESPACES):
        domain = cls
        break

    if domain is None:
        raise ValueError("No Automotive Domain found")

    print(f"Found domain: {get_element_name(domain)}")

    # Extract domain information
    domain_info = {
        'id': get_element_id(domain),
        'name': get_element_name(domain),
        'type': get_element_type(domain),
        'stereotypes': extract_stereotypes(domain),
        'attributes': extract_attributes(domain, id_map),
        'ports': extract_ports(domain, id_map),
        'connectors': extract_connectors(domain, id_map),
        'nested_classifiers': extract_nested_classifiers(domain, id_map, depth=1)
    }

    print(f"Found {len(domain_info['attributes'])} domain attributes")
    print(f"Found {len(domain_info['nested_classifiers'])} nested classifiers")

    # Extract requirements
    print("Extracting requirements...")
    requirements = extract_requirements(root, id_map)
    print(f"Found {len(requirements)} requirements")

    # Build complete model structure
    complete_model = {
        'model_name': model_name,
        'packages': {
            'Architecture': {
                'Structure': {
                    'Automotive_Domain': domain_info
                }
            }
        },
        'requirements': requirements,
        'statistics': {
            'total_elements': len(id_map),
            'total_attributes': len(domain_info['attributes']),
            'total_connectors': len(domain_info['connectors']),
            'total_requirements': len(requirements),
        }
    }

    return complete_model

def print_hierarchy(data: Dict, indent: int = 0):
    """Print the hierarchy structure."""
    prefix = "  " * indent

    if 'name' in data:
        print(f"{prefix}- {data['name']} (type: {data.get('type', 'unknown')})")

        if data.get('attributes'):
            print(f"{prefix}  Attributes ({len(data['attributes'])}):")
            for attr in data['attributes']:
                type_info = attr.get('type_name', attr.get('type_ref', 'unknown'))
                agg = attr.get('aggregation', 'none')
                mult = attr.get('multiplicity', '')
                print(f"{prefix}    - {attr['name']}: {type_info} [{agg}] {mult}")

        if data.get('ports'):
            print(f"{prefix}  Ports ({len(data['ports'])}):")
            for port in data['ports']:
                type_info = port.get('type_name', port.get('type_ref', 'unknown'))
                print(f"{prefix}    - {port['name']}: {type_info}")

        if data.get('connectors'):
            print(f"{prefix}  Connectors ({len(data['connectors'])}):")
            for conn in data['connectors']:
                ends_info = []
                for end in conn['ends']:
                    role = end.get('role_name', end.get('role', '?'))
                    part = end.get('part_name', end.get('partWithPort', ''))
                    if part:
                        ends_info.append(f"{part}.{role}")
                    else:
                        ends_info.append(role)
                print(f"{prefix}    - {conn['name']}: {' <-> '.join(ends_info)}")

        if data.get('nested_classifiers'):
            print(f"{prefix}  Nested Classifiers ({len(data['nested_classifiers'])}):")
            for nested in data['nested_classifiers']:
                print_hierarchy(nested, indent + 2)

def main():
    """Main extraction function."""
    # Paths
    mdzip_dir = Path("/mnt/c/Users/borrth/offline/_now/LEAD/Claude Code/sysmlv2/look/extracted_mdzip")
    xml_file = mdzip_dir / "com.nomagic.magicdraw.uml_model.model"
    output_file = Path("/mnt/c/Users/borrth/offline/_now/LEAD/Claude Code/sysmlv2/look/extracted_model_complete.json")

    print(f"Reading XMI file: {xml_file}")

    # Extract model
    model = extract_model(xml_file)

    # Print hierarchy
    print("\n" + "="*80)
    print("MODEL HIERARCHY")
    print("="*80)
    print_hierarchy(model['packages']['Architecture']['Structure']['Automotive_Domain'])

    # Print requirements
    if model['requirements']:
        print("\n" + "="*80)
        print("REQUIREMENTS")
        print("="*80)
        for req in model['requirements']:
            print(f"- {req['name']} (type: {req['type']})")
            if 'text' in req:
                print(f"  Text: {req['text'][:100]}...")

    # Print statistics
    print("\n" + "="*80)
    print("STATISTICS")
    print("="*80)
    for key, value in model['statistics'].items():
        print(f"{key}: {value}")

    # Save to JSON
    print(f"\nSaving complete extraction to: {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(model, f, indent=2, ensure_ascii=False)

    print("Extraction complete!")

if __name__ == '__main__':
    main()
