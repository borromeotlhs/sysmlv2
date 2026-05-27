#!/usr/bin/env python
import json
from pathlib import Path

OUT = Path('data/architectures')
OUT.mkdir(parents=True, exist_ok=True)

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

for i, domain in enumerate(['uav payload', 'autonomous rover', 'lunar habitat'], start=1):
    p = OUT / f'arch_{i:06d}.json'
    p.write_text(json.dumps(arch(i, domain), indent=2), encoding='utf-8')
print(f'generated 3 sample architectures in {OUT}')
