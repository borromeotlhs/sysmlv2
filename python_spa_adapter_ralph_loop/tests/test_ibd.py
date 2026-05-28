#!/usr/bin/env python3
"""Test that IBD generation produces valid PlantUML syntax"""

from pathlib import Path
from spa.server import load_architecture, generate_ibd_plantuml

# Test with the first architecture
arch_path = Path('data/architectures/arch_000001.sysml')
arch = load_architecture(arch_path)

# Generate IBD PlantUML
plantuml_source = generate_ibd_plantuml(arch)

print("Generated IBD PlantUML:")
print("=" * 60)
print(plantuml_source)
print("=" * 60)

# Check for problematic patterns
if 'portin' in plantuml_source.lower() and '-->' in plantuml_source:
    # Check if we're trying to connect nested ports (the broken pattern)
    lines = plantuml_source.split('\n')
    for i, line in enumerate(lines, 1):
        if '-->' in line and '_' in line:
            # This might be trying to connect nested port IDs
            parts = line.split('-->')
            if len(parts) == 2:
                left = parts[0].strip()
                right = parts[1].split(':')[0].strip()
                if left.count('_') > 1 or right.count('_') > 1:
                    print(f"\nWARNING: Line {i} may have nested port connection syntax:")
                    print(f"  {line.strip()}")

print("\n✓ IBD generation completed")
print("\nNote: Restart the server (spa/server.py) to see the updated diagrams")
