#!/usr/bin/env python
"""Debug script to test IBD generation from .sysml files"""
import json
import sys
from pathlib import Path

# Add spa to path
sys.path.insert(0, str(Path(__file__).parent / 'spa'))

from sysml_parser import parse_sysml_to_json
from server import generate_ibd_plantuml

def main():
    sysml_file = Path(__file__).parent / 'data' / 'architectures' / 'arch_000001.sysml'

    print("=" * 80)
    print("DEBUG: IBD Generation from .sysml file")
    print("=" * 80)
    print()

    # Step 1: Read file
    print(f"1. Reading file: {sysml_file}")
    content = sysml_file.read_text(encoding='utf-8')
    print(f"   File size: {len(content)} bytes")
    print()

    # Step 2: Parse to JSON IR
    print("2. Parsing SysML to JSON IR...")
    arch = parse_sysml_to_json(content)
    print(f"   Architecture ID: {arch.get('id')}")
    print(f"   Architecture name: {arch.get('name')}")
    print(f"   Domain: {arch.get('domain')}")
    print()

    # Step 3: Inspect parsed data
    print("3. Inspecting parsed architecture structure:")
    print(f"   Blocks: {len(arch.get('blocks', []))}")
    for block in arch.get('blocks', []):
        print(f"     - {block.get('name')}")
    print()

    print(f"   Proxy Ports: {len(arch.get('proxy_ports', []))}")
    for port in arch.get('proxy_ports', []):
        print(f"     - {port.get('owner')}.{port.get('name')} : {port.get('type')}")
    print()

    print(f"   Connectors: {len(arch.get('connectors', []))}")
    for conn in arch.get('connectors', []):
        print(f"     - {conn.get('name')}: {conn.get('end_a')} -> {conn.get('end_b')}")
    print()

    print(f"   Requirements: {len(arch.get('requirements', []))}")
    for req in arch.get('requirements', []):
        print(f"     - {req.get('id')}")
    print()

    print(f"   Relationships: {len(arch.get('relationships', []))}")
    for rel in arch.get('relationships', []):
        print(f"     - {rel.get('client')} --{rel.get('type')}--> {rel.get('supplier')}")
    print()

    # Step 4: Generate IBD
    print("4. Generating IBD PlantUML...")
    plantuml_src = generate_ibd_plantuml(arch)
    print()
    print("Generated PlantUML:")
    print("-" * 80)
    print(plantuml_src)
    print("-" * 80)
    print()

    # Step 5: Save full JSON for inspection
    json_output = Path(__file__).parent / 'debug_parsed_arch.json'
    json_output.write_text(json.dumps(arch, indent=2), encoding='utf-8')
    print(f"5. Saved parsed architecture to: {json_output}")
    print()

    print("=" * 80)
    print("DEBUG COMPLETE")
    print("=" * 80)

if __name__ == '__main__':
    main()
