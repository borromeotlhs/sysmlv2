#!/usr/bin/env python
"""
SAJAI (SysML-Aware JSON for Auditing and Introspection) Generator

Converts SysML v2 architectures to SAJAI format for 3D visualization.
"""

import json
from pathlib import Path
from typing import Dict, List, Any, Optional


def ir_to_sajai(ir: Dict[str, Any], output_path: Optional[Path] = None) -> Dict[str, Any]:
    """
    Convert SysML IR (from parser) to SAJAI format.

    Args:
        ir: SysML intermediate representation dictionary
        output_path: Optional path to write SAJAI file

    Returns:
        SAJAI dictionary
    """
    # Extract architecture metadata
    arch_name = ir.get('name', 'System')
    arch_id = ir.get('id', 'system')

    # Build SAJAI structure
    sajai = {
        "format": "SAJAI",
        "version": "1.0",
        "description": f"Generated from SysML v2 architecture: {arch_name}",
        "scenes": {}
    }

    # Create main scene
    main_scene_id = f"scene_{arch_id}"
    main_scene = create_scene_from_ir(ir, main_scene_id, arch_name)
    sajai["scenes"][arch_id] = main_scene

    # Write to file if path provided
    if output_path:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(sajai, f, indent=2)

    return sajai


def create_scene_from_ir(ir: Dict[str, Any], scene_id: str, scene_name: str) -> Dict[str, Any]:
    """
    Create a SAJAI scene from SysML IR.

    Args:
        ir: SysML intermediate representation
        scene_id: Unique scene identifier
        scene_name: Human-readable scene name

    Returns:
        SAJAI scene dictionary
    """
    scene = {
        "id": scene_id,
        "name": scene_name,
        "contextRef": f"{ir.get('id', 'System')}",
        "camera": {
            "position": [15.0, 12.0, 15.0],
            "target": [0.0, 0.0, 0.0],
            "fov": 60.0,
            "near": 0.1,
            "far": 1000.0
        },
        "parts": [],
        "ports": [],
        "connectors": []
    }

    # Extract blocks and create parts
    blocks = ir.get('blocks', [])
    compositions = ir.get('compositions', [])
    proxy_ports = ir.get('proxy_ports', [])
    connectors = ir.get('connectors', [])

    # Build composition hierarchy to identify leaf parts
    children_map = {}
    for comp in compositions:
        parent = comp.get('parent', '')
        child = comp.get('child', '')
        if parent not in children_map:
            children_map[parent] = []
        children_map[parent].append(child)

    # Find system-level block (typically the last one)
    system_block = blocks[-1] if blocks else None
    system_name = system_block.get('name', 'System') if system_block else 'System'

    # Get direct children of system
    system_children = children_map.get(system_name, [])

    # Generate parts for system children
    # Layout in a grid pattern
    grid_size = max(3, int(len(system_children) ** 0.5) + 1)
    spacing = 5.0

    for idx, child_name in enumerate(system_children):
        # Calculate grid position
        row = idx // grid_size
        col = idx % grid_size
        x = (col - grid_size / 2) * spacing
        z = (row - grid_size / 2) * spacing
        y = 0.0

        # Find the block definition for this child
        child_block = next((b for b in blocks if b.get('name') == child_name), None)

        # Determine if this part has nested children (is a subsystem)
        has_children = child_name in children_map

        part = {
            "id": f"part_{child_name.lower().replace(' ', '_')}",
            "name": child_name,
            "sysmlRef": f"{system_name}::{child_name}",
            "qualifiedName": f"{system_name}::{child_name}",
            "type": child_block.get('name', child_name) if child_block else child_name,
            "owner": system_name,
            "position": [x, y, z],
            "size": [2.5, 2.0, 2.5],
            "color": assign_color(idx),
            "opacity": 0.85,
            "visible": True,
            "metadata": {}
        }

        # Add metadata if block has attributes
        if child_block:
            attrs = child_block.get('attributes', [])
            for attr in attrs:
                attr_name = attr.get('name', '')
                attr_type = attr.get('type', '')
                if attr_name and attr_type:
                    part["metadata"][attr_name] = attr_type

        # If part has children, mark it for drill-down
        if has_children:
            part["metadata"]["doubleClickScene"] = f"{child_name.lower()}_internals"

        scene["parts"].append(part)

    # Generate ports for each part
    port_index = 0
    for port in proxy_ports:
        owner = port.get('owner', '')
        port_name = port.get('name', '')
        port_type = port.get('type', '')

        # Only include ports for visible parts (system children)
        if owner in system_children:
            owner_part_id = f"part_{owner.lower().replace(' ', '_')}"

            # Determine port position on part surface
            # Distribute ports around the part
            surface = assign_port_surface(port_index, port_name)
            uv = assign_port_uv(port_index, port_name)

            port_obj = {
                "id": f"port_{owner.lower()}_{port_name.lower()}",
                "name": port_name,
                "sysmlRef": f"{system_name}::{owner}::{port_name}",
                "qualifiedName": f"{system_name}::{owner}::{port_name}",
                "type": port_type,
                "owner": owner,
                "partId": owner_part_id,
                "surface": surface,
                "uv": uv,
                "visible": True,
                "metadata": {}
            }

            scene["ports"].append(port_obj)
            port_index += 1

    # Generate connectors
    for conn in connectors:
        end_a = conn.get('end_a', '')
        end_b = conn.get('end_b', '')
        item_flow = conn.get('item_flow', '')

        # Parse endpoints (format: "PartName.portName")
        def parse_endpoint(endpoint: str) -> Optional[str]:
            if '.' in endpoint:
                parts = endpoint.split('.')
                owner = parts[0]
                port = parts[1]
                # Only include if owner is visible
                if owner in system_children:
                    return f"port_{owner.lower()}_{port.lower()}"
            return None

        source_port_id = parse_endpoint(end_a)
        target_port_id = parse_endpoint(end_b)

        if source_port_id and target_port_id:
            connector = {
                "id": f"conn_{source_port_id}_to_{target_port_id}",
                "sourcePortId": source_port_id,
                "targetPortId": target_port_id,
                "visible": True,
                "metadata": {}
            }

            if item_flow:
                connector["itemFlow"] = item_flow
                connector["metadata"]["flow"] = item_flow

            scene["connectors"].append(connector)

    return scene


def assign_color(index: int) -> str:
    """
    Assign a color from a palette based on index.

    Args:
        index: Part index

    Returns:
        Hex color string
    """
    colors = [
        "#3498db",  # Blue
        "#e74c3c",  # Red
        "#2ecc71",  # Green
        "#f39c12",  # Orange
        "#9b59b6",  # Purple
        "#1abc9c",  # Turquoise
        "#e67e22",  # Carrot
        "#34495e",  # Dark gray
        "#16a085",  # Green sea
        "#c0392b",  # Pomegranate
        "#8e44ad",  # Wisteria
        "#2980b9",  # Belize hole
    ]
    return colors[index % len(colors)]


def assign_port_surface(index: int, port_name: str) -> str:
    """
    Assign a surface (face) for a port based on index and name.

    Args:
        index: Port index
        port_name: Port name (may contain hints like "In", "Out")

    Returns:
        Surface name: "top", "bottom", "front", "back", "left", "right"
    """
    # Use naming convention hints
    name_lower = port_name.lower()
    if 'in' in name_lower or 'input' in name_lower:
        return "left"
    elif 'out' in name_lower or 'output' in name_lower:
        return "right"
    elif 'top' in name_lower:
        return "top"
    elif 'bottom' in name_lower or 'down' in name_lower:
        return "bottom"
    elif 'front' in name_lower:
        return "front"
    elif 'back' in name_lower or 'rear' in name_lower:
        return "back"

    # Default distribution
    surfaces = ["front", "back", "left", "right", "top", "bottom"]
    return surfaces[index % len(surfaces)]


def assign_port_uv(index: int, port_name: str) -> List[float]:
    """
    Assign UV coordinates for port position on surface.

    Args:
        index: Port index
        port_name: Port name

    Returns:
        [u, v] coordinates in range [0.0, 1.0]
    """
    # Distribute ports evenly on surface
    positions = [
        [0.5, 0.5],  # Center
        [0.3, 0.5],  # Left center
        [0.7, 0.5],  # Right center
        [0.5, 0.3],  # Bottom center
        [0.5, 0.7],  # Top center
        [0.3, 0.3],  # Bottom left
        [0.7, 0.3],  # Bottom right
        [0.3, 0.7],  # Top left
        [0.7, 0.7],  # Top right
    ]
    return positions[index % len(positions)]


def sysml_to_sajai(sysml_path: Path, output_path: Optional[Path] = None) -> Dict[str, Any]:
    """
    Convert a SysML v2 file to SAJAI format.

    Args:
        sysml_path: Path to .sysml file
        output_path: Optional path for output .sajai file (if None, data returned without saving)

    Returns:
        SAJAI dictionary
    """
    # Import parser
    try:
        from spa.sysml_parser import parse_sysml_to_json
    except ImportError:
        from sysml_parser import parse_sysml_to_json

    # Read and parse SysML file
    content = sysml_path.read_text(encoding='utf-8')
    ir = parse_sysml_to_json(content)

    # Convert to SAJAI
    return ir_to_sajai(ir, output_path)


if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print("Usage: python sajai_generator.py <input.sysml> <output.sajai>")
        sys.exit(1)

    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])

    if not input_path.exists():
        print(f"Error: Input file not found: {input_path}")
        sys.exit(1)

    print(f"Converting {input_path} to SAJAI format...")
    sajai = sysml_to_sajai(input_path, output_path)
    print(f"SAJAI file generated: {output_path}")
    print(f"  Scenes: {len(sajai.get('scenes', {}))}")
    for scene_key, scene in sajai.get('scenes', {}).items():
        print(f"    - {scene.get('name', scene_key)}: {len(scene.get('parts', []))} parts, {len(scene.get('ports', []))} ports, {len(scene.get('connectors', []))} connectors")
