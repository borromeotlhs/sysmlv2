#!/usr/bin/env python3
"""
Convert extracted SysML 1.x model data to SysML v2 .sysml format
"""

import json

# Load extracted data
with open('extracted_model.json', 'r') as f:
    data = json.load(f)

blocks = data['blocks']

# Create a mapping of block IDs to names for lookups
id_to_name = {block_id: block['name'] for block_id, block in blocks.items()}

# Collect unique port types
port_types = set()
for block_id, block in blocks.items():
    for port in block['ports']:
        # Clean up port type names
        port_type = port.get('type', 'Port')
        if port_type == 'Port':
            # Infer type from port name
            port_name = port['name'].lower()
            if 'power' in port_name or 'dc' in port_name or 'ac' in port_name:
                port_types.add('PowerPort')
            elif 'control' in port_name or 'command' in port_name:
                port_types.add('ControlPort')
            elif 'can' in port_name or 'data' in port_name:
                port_types.add('DataPort')
            elif 'thermal' in port_name or 'coolant' in port_name:
                port_types.add('ThermalPort')
            elif 'drive' in port_name or 'shaft' in port_name or 'torque' in port_name:
                port_types.add('MechanicalPort')
            elif 'wheel' in port_name or 'joint' in port_name or 'hub' in port_name:
                port_types.add('MechanicalPort')
            elif 'sense' in port_name or 'sensor' in port_name:
                port_types.add('SensorPort')
            else:
                port_types.add('Port')
        else:
            port_types.add(port_type)

def infer_port_type(port_name):
    """Infer port type from port name"""
    port_name_lower = port_name.lower()
    if 'power' in port_name_lower or 'dc' in port_name_lower or 'ac' in port_name_lower:
        return 'PowerPort'
    elif 'control' in port_name_lower or 'command' in port_name_lower:
        return 'ControlPort'
    elif 'can' in port_name_lower or 'data' in port_name_lower:
        return 'DataPort'
    elif 'thermal' in port_name_lower or 'coolant' in port_name_lower:
        return 'ThermalPort'
    elif 'drive' in port_name_lower or 'shaft' in port_name_lower or 'torque' in port_name_lower:
        return 'MechanicalPort'
    elif 'wheel' in port_name_lower or 'joint' in port_name_lower or 'hub' in port_name_lower:
        return 'MechanicalPort'
    elif 'sense' in port_name_lower or 'sensor' in port_name_lower:
        return 'SensorPort'
    else:
        return 'Port'

def sanitize_name(name):
    """Convert name to valid SysML v2 identifier"""
    # Replace spaces with underscores, remove special chars
    name = name.replace(' ', '')
    name = name.replace('-', '')
    return name

# Generate SysML v2 .sysml file
output = []
output.append("package AutomotiveDomain {")
output.append("")

# Port type definitions
output.append("    // Port type definitions")
for port_type in sorted(port_types):
    output.append(f"    port def {port_type};")
output.append("")

# Part definitions
output.append("    // Part definitions")
for block_id, block in blocks.items():
    block_name = sanitize_name(block['name'])
    output.append(f"    part def {block_name} {{")

    # Attributes
    if block['attributes']:
        for attr in block['attributes']:
            attr_name = attr['name']
            attr_type = attr.get('type', 'Real')
            output.append(f"        attribute {attr_name} : Real [1];")

    # Ports
    if block['ports']:
        for port in block['ports']:
            port_name = sanitize_name(port['name'])
            port_type = infer_port_type(port['name'])
            output.append(f"        port {port_name} : {port_type};")

    output.append("    }")
    output.append("")

# System definition (ElectricVehicleSystem)
ev_system = blocks.get('_2022x_2_8eb0292_1779926129991_912275_3373')
if ev_system:
    output.append("    // System definition")
    output.append("    part def AutomotiveSystem {")

    # Parts
    for part in ev_system['parts']:
        part_name = sanitize_name(part['name'])
        part_type_id = part['type']
        part_type_name = sanitize_name(id_to_name.get(part_type_id, 'Component'))
        output.append(f"        part {part_name} : {part_type_name};")

    output.append("    }")
    output.append("")

    # Instance
    output.append("    // System instance")
    output.append("    part automotiveSystem : AutomotiveSystem;")

output.append("}")

# Write to file
sysml_content = "\n".join(output)
with open('claudeValidation_extracted.sysml', 'w') as f:
    f.write(sysml_content)

print("✅ SysML v2 file generated: claudeValidation_extracted.sysml")
print(f"\n📊 Statistics:")
print(f"  - {len(blocks)} block definitions")
print(f"  - {len(port_types)} port types")
print(f"  - {len(ev_system['parts']) if ev_system else 0} system parts")

# Print the file content
print("\n" + "="*60)
print("Generated SysML v2 content:")
print("="*60)
print(sysml_content)
