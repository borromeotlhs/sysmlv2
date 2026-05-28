#!/usr/bin/env python3
"""
Demonstrate namespace import resolution with actual package architectures.

This shows how namespace imports work when you have multiple package
architectures available in the system.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / 'spa'))

from sysml_parser import (
    parse_sysml_to_json,
    resolve_namespace_import
)


def main():
    print("=" * 70)
    print("Namespace Import Resolution Demonstration")
    print("=" * 70)
    print()

    # Parse the Systems package
    systems_sysml = """
package Systems {
    public part def PowerSystem {
        part battery : Battery;
    }

    public part def CoolingSystem {
        part radiator : Radiator;
    }

    part def Battery {
        part cell : Cell[4];
    }

    part def Radiator {
        port inlet;
        port outlet;
    }

    part def Cell {
        port positive;
        port negative;
    }
}
"""

    print("Step 1: Parse Systems package")
    print("-" * 70)
    systems_arch = parse_sysml_to_json(systems_sysml)
    print(f"Package: {systems_arch['id']}")
    print(f"Total blocks: {len(systems_arch['blocks'])}")
    print(f"Block names: {[b['name'] for b in systems_arch['blocks']]}")
    print(f"Public blocks: {systems_arch['exposed_elements']}")
    print()

    # Show what each import pattern resolves to
    print("Step 2: Resolve different import patterns")
    print("-" * 70)

    # Direct import (::*)
    direct_visible = resolve_namespace_import('Systems', 'direct', systems_arch)
    print(f"import Systems::*")
    print(f"  Makes visible: {sorted(direct_visible)}")
    print(f"  (Only direct public members)")
    print()

    # Recursive import (::**)
    recursive_visible = resolve_namespace_import('Systems', 'recursive', systems_arch)
    print(f"import Systems::**")
    print(f"  Makes visible: {sorted(recursive_visible)}")
    print(f"  (All nested elements, recursively)")
    print()

    # Hybrid import (::*::**)
    hybrid_visible = resolve_namespace_import('Systems', 'hybrid', systems_arch)
    print(f"import Systems::*::**")
    print(f"  Makes visible: {sorted(hybrid_visible)}")
    print(f"  (Both direct members and all nested)")
    print()

    # Parse a consuming package
    print("Step 3: Parse consuming package with namespace import")
    print("-" * 70)

    consumer_sysml = """
package Application {
    import Systems::*;

    public part def Vehicle {
        part power : PowerSystem;
        part cooling : CoolingSystem;
    }
}
"""

    consumer_arch = parse_sysml_to_json(consumer_sysml)
    print(f"Package: {consumer_arch['id']}")
    print(f"Namespace imports: {consumer_arch.get('namespace_imports', [])}")
    print()

    # Demonstrate resolution
    if consumer_arch.get('namespace_imports'):
        for ns_import in consumer_arch['namespace_imports']:
            pkg_name = ns_import['package']
            pattern = ns_import['pattern']
            print(f"Resolving: import {pkg_name}::{'::**' if pattern == 'hybrid' else ':**' if pattern == 'recursive' else '*'}")

            # In a real system, you would look up the pkg_name architecture
            # from a registry/cache. Here we use our systems_arch directly.
            if pkg_name == 'Systems':
                visible = resolve_namespace_import(pkg_name, pattern, systems_arch)
                print(f"  Available types from {pkg_name}: {sorted(visible)}")
    print()

    print("=" * 70)
    print("Summary")
    print("=" * 70)
    print()
    print("The three namespace import patterns provide different levels of access:")
    print()
    print("1. ::*        - Direct members only (public elements at package level)")
    print("               Use when you only need the main API types")
    print()
    print("2. ::**       - Nested elements only (recursively)")
    print("               Use when you want internal/implementation types")
    print()
    print("3. ::*::**    - Both direct and nested (everything)")
    print("               Use when you need full access to all types")
    print()


if __name__ == '__main__':
    main()
