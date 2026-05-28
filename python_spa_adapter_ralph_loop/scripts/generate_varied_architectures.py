#!/usr/bin/env python
"""
Generate varied architecture files in SysML v2 format.

Creates diverse system architectures with randomized structure.
Generates .sysml files directly (primary output).
Can optionally generate JSON IR for academic/training purposes with --json flag.
"""
import json
import random
import sys
from pathlib import Path

# Add lib directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'lib'))

from sysml_generator import generate_sysml_from_dict
from xmi_generator import generate_xmi_from_dict

OUT_SYSML = Path('data/architectures')
OUT_JSON = Path('data/architectures_json')  # Optional JSON IR output
OUT_SYSML.mkdir(parents=True, exist_ok=True)

# Configuration
NUM_ARCHITECTURES = 50  # Change this to generate more
START_ID = 1

# Domain vocabulary
DOMAINS = [
    'uav payload', 'autonomous rover', 'lunar habitat', 'satellite bus',
    'ground station', 'communication relay', 'data processing unit',
    'power distribution system', 'thermal control', 'propulsion module',
    'guidance navigation', 'sensor suite', 'command data handling',
    'telemetry system', 'antenna subsystem', 'radar system',
    'imaging payload', 'robotic arm', 'docking mechanism', 'life support',
    'solar array', 'battery management', 'attitude control', 'reaction wheel',
    'thruster assembly', 'fuel cell', 'avionics bay', 'instrument platform'
]

# Component types
COMPONENT_TYPES = [
    'Computer', 'Controller', 'Processor', 'Module', 'Unit', 'Assembly',
    'Subsystem', 'Payload', 'Sensor', 'Actuator', 'Interface', 'Bus'
]

COMPONENT_PREFIXES = [
    'Mission', 'Flight', 'Command', 'Data', 'Power', 'Thermal', 'Comm',
    'Nav', 'Sensor', 'Control', 'Monitor', 'Processing', 'Distribution'
]

# Interface types
INTERFACE_TYPES = [
    'CommandIF', 'DataIF', 'PowerIF', 'ThermalIF', 'SignalIF',
    'ControlIF', 'StatusIF', 'TelemetryIF', 'ConfigIF', 'DiagnosticIF'
]

# Port names
PORT_NAMES = [
    'cmdIn', 'cmdOut', 'dataIn', 'dataOut', 'pwrIn', 'pwrOut',
    'statusOut', 'ctrlIn', 'sensorOut', 'configIn', 'telemetryOut'
]

# Item flows
ITEM_FLOWS = [
    'Command', 'Data', 'Power', 'Status', 'Control', 'Signal',
    'Telemetry', 'Config', 'Sensor', 'Diagnostic', 'Alert'
]


def generate_block_name(prefix=None):
    """Generate a realistic block name"""
    if prefix is None:
        prefix = random.choice(COMPONENT_PREFIXES)
    comp_type = random.choice(COMPONENT_TYPES)
    return f'{prefix}{comp_type}'


def generate_architecture(arch_id, domain):
    """Generate a varied architecture with randomized structure"""

    # Randomize number of blocks (3-8)
    num_blocks = random.randint(3, 8)

    # Generate system block + subsystem blocks
    system_name = f'{domain.title().replace(" ", "")}System'
    blocks = [{'name': system_name, 'stereotype': 'Block'}]

    block_names = [system_name]
    for _ in range(num_blocks - 1):
        name = generate_block_name()
        # Ensure unique names
        while name in block_names:
            name = generate_block_name()
        block_names.append(name)
        blocks.append({'name': name, 'stereotype': 'Block'})

    # Generate proxy ports (1-3 per block, skip system block)
    proxy_ports = []
    for block_name in block_names[1:]:
        num_ports = random.randint(1, 3)
        for _ in range(num_ports):
            port_name = random.choice(PORT_NAMES)
            port_type = random.choice(INTERFACE_TYPES)
            proxy_ports.append({
                'owner': block_name,
                'name': port_name,
                'type': port_type
            })

    # Generate connectors (create mesh connectivity)
    connectors = []
    if len(proxy_ports) >= 2:
        # Create 2-5 connections
        num_connectors = min(random.randint(2, 5), len(proxy_ports) - 1)
        used_pairs = set()

        for i in range(num_connectors):
            # Pick two different ports
            attempts = 0
            while attempts < 20:
                port_a = random.choice(proxy_ports)
                port_b = random.choice(proxy_ports)

                # Different owners
                if port_a['owner'] != port_b['owner']:
                    pair = tuple(sorted([
                        f"{port_a['owner']}.{port_a['name']}",
                        f"{port_b['owner']}.{port_b['name']}"
                    ]))

                    if pair not in used_pairs:
                        used_pairs.add(pair)
                        connectors.append({
                            'name': f'link{i+1}',
                            'end_a': f"{port_a['owner']}.{port_a['name']}",
                            'end_b': f"{port_b['owner']}.{port_b['name']}",
                            'item_flow': random.choice(ITEM_FLOWS)
                        })
                        break

                attempts += 1

    # Generate requirements (2-4)
    num_reqs = random.randint(2, 4)
    requirements = []
    req_templates = [
        f'The {domain} system shall exchange data through typed interfaces.',
        f'The {domain} system shall trace subsystem design to requirements.',
        f'The {domain} system shall provide fault detection and recovery.',
        f'The {domain} system shall maintain operational status monitoring.',
        f'The {domain} system shall support configuration updates.',
        f'The {domain} system shall implement thermal management.',
        f'The {domain} system shall ensure power distribution reliability.'
    ]

    for i in range(num_reqs):
        requirements.append({
            'id': f'REQ-{i+1:03d}',
            'text': req_templates[i % len(req_templates)]
        })

    # Generate relationships (satisfy connections from blocks to requirements)
    relationships = []
    for i, req in enumerate(requirements):
        # Pick 1-2 blocks to satisfy this requirement
        num_satisfy = min(random.randint(1, 2), len(block_names) - 1)
        clients = random.sample(block_names[1:], num_satisfy)  # Skip system block

        for client in clients:
            relationships.append({
                'type': 'satisfy',
                'client': client,
                'supplier': req['id']
            })

    return {
        'id': f'arch_{arch_id:06d}',
        'name': f'{domain.title()} Reference Architecture {arch_id}',
        'domain': domain,
        'format': 'sysml_style_json_mvp',
        'blocks': blocks,
        'proxy_ports': proxy_ports,
        'connectors': connectors,
        'requirements': requirements,
        'relationships': relationships
    }


def main():
    import argparse
    parser = argparse.ArgumentParser(
        description='Generate varied architectures in SysML v2 format'
    )
    parser.add_argument(
        '--json',
        action='store_true',
        help='Also generate JSON IR files for academic/training purposes'
    )
    parser.add_argument(
        '--count',
        type=int,
        default=NUM_ARCHITECTURES,
        help=f'Number of architectures to generate (default: {NUM_ARCHITECTURES})'
    )
    parser.add_argument(
        '--start-id',
        type=int,
        default=START_ID,
        help=f'Starting architecture ID (default: {START_ID})'
    )
    parser.add_argument(
        '--xmi',
        action='store_true',
        help='Also output XMI format for EMF/Eclipse tool interoperability'
    )
    args = parser.parse_args()

    random.seed(42)  # For reproducibility

    for i in range(args.start_id, args.start_id + args.count):
        domain = random.choice(DOMAINS)
        arch_dict = generate_architecture(i, domain)

        # Primary output: .sysml files
        sysml_content = generate_sysml_from_dict(arch_dict)
        sysml_path = OUT_SYSML / f'arch_{i:06d}.sysml'
        sysml_path.write_text(sysml_content, encoding='utf-8')

        # Optional output: JSON IR for academic purposes
        if args.json:
            OUT_JSON.mkdir(parents=True, exist_ok=True)
            json_path = OUT_JSON / f'arch_{i:06d}.json'
            json_path.write_text(json.dumps(arch_dict, indent=2), encoding='utf-8')

        # Optional output: XMI for tool interoperability
        if args.xmi:
            OUT_XMI = Path('data/architectures_xmi')
            OUT_XMI.mkdir(parents=True, exist_ok=True)
            xmi_content = generate_xmi_from_dict(arch_dict)
            xmi_path = OUT_XMI / f'arch_{i:06d}.xmi'
            xmi_path.write_text(xmi_content, encoding='utf-8')

    print(f'Generated {args.count} varied architectures in {OUT_SYSML}')
    print(f'Architecture IDs: arch_{args.start_id:06d} to arch_{args.start_id + args.count - 1:06d}')
    if args.json:
        print(f'Also generated JSON IR in {OUT_JSON}')
    if args.xmi:
        print(f'Also generated XMI format in {OUT_XMI}')


if __name__ == '__main__':
    main()
