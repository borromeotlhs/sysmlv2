#!/usr/bin/env python
"""
Generate sample architecture files in SysML v2 format.

Generates .sysml files directly (primary output).
Can optionally generate JSON IR for academic/training purposes with --json flag.
"""
import json
import sys
from pathlib import Path

# Add lib directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'lib'))

from sysml_generator import generate_sysml_from_dict

OUT_SYSML = Path('data/architectures')
OUT_JSON = Path('data/architectures_json')  # Optional JSON IR output
OUT_SYSML.mkdir(parents=True, exist_ok=True)

def arch(i, domain):
    return {
        'id': f'arch_{i:06d}',
        'name': f'{domain.title()} Reference Architecture {i}',
        'domain': domain,
        'format': 'sysml_style_json_mvp',
        'blocks': [
            {'name': f'{domain.title().replace(" ", "")}System', 'stereotype': 'Block'},
            {'name': 'MissionComputer', 'stereotype': 'Block'},
            {'name': 'SensorPayload', 'stereotype': 'Block'},
            {'name': 'PowerUnit', 'stereotype': 'Block'},
        ],
        'proxy_ports': [
            {'owner': 'MissionComputer', 'name': 'cmdOut', 'type': 'CommandIF'},
            {'owner': 'SensorPayload', 'name': 'dataOut', 'type': 'DataIF'},
            {'owner': 'PowerUnit', 'name': 'pwrOut', 'type': 'PowerIF'},
        ],
        'connectors': [
            {'name': 'cmdLink', 'end_a': 'MissionComputer.cmdOut', 'end_b': 'SensorPayload.dataOut', 'item_flow': 'Command'},
            {'name': 'powerLink', 'end_a': 'PowerUnit.pwrOut', 'end_b': 'SensorPayload.dataOut', 'item_flow': 'Power'},
        ],
        'requirements': [
            {'id': 'REQ-001', 'text': f'The {domain} system shall exchange command and data through typed interfaces.'},
            {'id': 'REQ-002', 'text': f'The {domain} system shall trace subsystem design to requirements.'},
        ],
        'relationships': [
            {'type': 'satisfy', 'client': 'MissionComputer', 'supplier': 'REQ-001'},
            {'type': 'satisfy', 'client': 'SensorPayload', 'supplier': 'REQ-002'},
        ]
    }

def main():
    import argparse
    parser = argparse.ArgumentParser(
        description='Generate sample architectures in SysML v2 format'
    )
    parser.add_argument(
        '--json',
        action='store_true',
        help='Also generate JSON IR files for academic/training purposes'
    )
    args = parser.parse_args()

    domains = ['uav payload', 'autonomous rover', 'lunar habitat']

    for i, domain in enumerate(domains, start=1):
        arch_dict = arch(i, domain)

        # Primary output: .sysml files
        sysml_content = generate_sysml_from_dict(arch_dict)
        sysml_path = OUT_SYSML / f'arch_{i:06d}.sysml'
        sysml_path.write_text(sysml_content, encoding='utf-8')

        # Optional output: JSON IR for academic purposes
        if args.json:
            OUT_JSON.mkdir(parents=True, exist_ok=True)
            json_path = OUT_JSON / f'arch_{i:06d}.json'
            json_path.write_text(json.dumps(arch_dict, indent=2), encoding='utf-8')

    print(f'Generated {len(domains)} sample architectures in {OUT_SYSML}')
    if args.json:
        print(f'Also generated JSON IR in {OUT_JSON}')


if __name__ == '__main__':
    main()
