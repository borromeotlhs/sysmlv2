"""
SAJAI Generator - Convert SysML v2 IR to SAJAI format for 3D visualization.

Transforms parsed SysML architectures into the SysML-Aware JSON for Auditing and
Introspection (SAJAI) format with 3D geometry, auto-layout, and scene generation.
"""
import math
import hashlib
from typing import Dict, List, Tuple, Optional, Set


# Color palette for different port types
PORT_TYPE_COLORS = {
    'power': '#f39c12',  # Orange
    'powerif': '#f39c12',
    'data': '#1abc9c',   # Teal
    'dataif': '#1abc9c',
    'command': '#3498db', # Blue
    'commandif': '#3498db',
    'control': '#9b59b6', # Purple
    'spi': '#3498db',
    'i2c': '#9b59b6',
    'uart': '#1abc9c',
    'default': '#95a5a6'  # Gray
}

# Color palette for different block types
BLOCK_TYPE_COLORS = {
    'computer': '#3498db',
    'sensor': '#e74c3c',
    'power': '#2ecc71',
    'battery': '#2ecc71',
    'radio': '#9b59b6',
    'controller': '#3498db',
    'system': '#34495e',
    'payload': '#e67e22',
    'default': '#7f8c8d'
}


def generate_sajai(sysml_ir: dict) -> dict:
    """
    Generate SAJAI format from SysML IR.

    Args:
        sysml_ir: Parsed SysML architecture dictionary

    Returns:
        SAJAI-formatted dictionary with 3D scenes

    Example:
        >>> ir = parse_sysml_to_json(sysml_content)
        >>> sajai = generate_sajai(ir)
    """
    arch_id = sysml_ir.get('id', 'unknown')
    arch_name = sysml_ir.get('name', 'Unknown Architecture')
    domain = sysml_ir.get('domain', 'system')

    # Build composition hierarchy
    blocks = sysml_ir.get('blocks', [])
    compositions = sysml_ir.get('compositions', [])
    proxy_ports = sysml_ir.get('proxy_ports', [])
    connectors = sysml_ir.get('connectors', [])

    # Find root block (one that is not a child of any other)
    parent_set = {comp['parent'] for comp in compositions}
    child_set = {comp['child'] for comp in compositions}
    root_blocks = parent_set - child_set

    if not root_blocks and blocks:
        # No composition hierarchy, create a single scene with all blocks as peers
        # Use the first block that ends with "System" or just the first block
        system_blocks = [b['name'] for b in blocks if 'system' in b['name'].lower()]
        if system_blocks:
            root_blocks = {system_blocks[0]}
        else:
            root_blocks = {blocks[0]['name']}

    # Generate scenes for each root block
    scenes = {}

    # Special case: if no compositions, create flat scene with all blocks
    if not compositions and blocks:
        scene_id = f"scene_{arch_id}"
        scene = generate_flat_scene(
            arch_id,
            arch_name,
            sysml_ir,
            scene_id
        )
        scenes[arch_id] = scene
    else:
        # Normal hierarchical scene generation
        for root_name in root_blocks:
            scene_id = f"scene_{to_snake_case(root_name)}"
            scene = generate_scene(
                root_name,
                arch_id,
                sysml_ir,
                scene_id
            )
            scenes[to_snake_case(root_name)] = scene

    # Generate nested scenes for blocks with internal structure
    for block in blocks:
        block_name = block['name']
        children = [c['child'] for c in compositions if c['parent'] == block_name]
        if children:
            scene_key = f"{to_snake_case(block_name)}_internals"
            scene_id = f"scene_{scene_key}"
            scene = generate_scene(
                block_name,
                arch_id,
                sysml_ir,
                scene_id,
                is_internal=True
            )
            scenes[scene_key] = scene

    return {
        'format': 'SAJAI',
        'version': '1.0',
        'description': f'{arch_name} - Generated from SysML v2',
        'scenes': scenes
    }


def generate_flat_scene(
    arch_id: str,
    arch_name: str,
    sysml_ir: dict,
    scene_id: str
) -> dict:
    """
    Generate a flat SAJAI scene with all blocks as peers (no hierarchy).

    Args:
        arch_id: Architecture ID
        arch_name: Architecture name
        sysml_ir: Full SysML IR
        scene_id: Unique scene identifier

    Returns:
        Scene dictionary with all blocks as parts at the same level
    """
    blocks = sysml_ir.get('blocks', [])
    proxy_ports = sysml_ir.get('proxy_ports', [])
    connectors = sysml_ir.get('connectors', [])

    # Create parts for each block
    parts = []
    part_id_map = {}  # block_name -> part_id

    for idx, block in enumerate(blocks):
        block_name = block['name']
        part_id = f"part_{to_snake_case(block_name)}"
        part_id_map[block_name] = part_id

        parts.append({
            'id': part_id,
            'name': block_name,
            'sysmlRef': f"{arch_id}::{block_name}",
            'qualifiedName': f"{arch_id}::{block_name}",
            'type': block_name,
            'owner': arch_id,
            'position': [0, 0, 0],  # Will be set by auto_layout
            'size': [2.0, 1.5, 2.0],  # Default size
            'color': get_block_color(block_name),
            'opacity': 0.85,
            'visible': True,
            'metadata': {
                'stereotype': block.get('stereotype', 'Block')
            }
        })

    # Auto-layout parts
    parts = auto_layout_parts(parts)

    # Create ports
    ports = []
    port_id_map = {}  # (block, port_name) -> port_id

    for proxy_port in proxy_ports:
        owner = proxy_port['owner']
        port_name = proxy_port['name']
        port_type = proxy_port.get('type', 'Port')

        # Only include ports for blocks that exist
        if owner not in part_id_map:
            continue

        part_id = part_id_map[owner]
        port_id = f"port_{to_snake_case(owner)}_{to_snake_case(port_name)}"
        port_id_map[(owner, port_name)] = port_id

        ports.append({
            'id': port_id,
            'name': port_name,
            'sysmlRef': f"{arch_id}::{owner}::{port_name}",
            'ownerPartId': part_id,
            'type': port_type,
            'surface': 'top',  # Will be assigned later
            'uv': [0.5, 0.5],
            'radius': 0.2,
            'color': get_port_color(port_type),
            'visible': True,
            'connectedPortIds': [],
            'metadata': {
                'protocol': infer_protocol(port_type, port_name)
            }
        })

    # Assign port surfaces based on connections
    ports = assign_port_surfaces(ports, connectors, part_id_map, parts)

    # Create connectors
    sajai_connectors = []
    for idx, conn in enumerate(connectors):
        conn_name = conn.get('name', f'conn_{idx+1:03d}')
        end_a = conn.get('end_a', '')
        end_b = conn.get('end_b', '')

        # Parse endpoints (format: "BlockName.portName")
        port_a_tuple = parse_endpoint(end_a)
        port_b_tuple = parse_endpoint(end_b)

        if not port_a_tuple or not port_b_tuple:
            continue

        # Get port IDs
        port_a_id = port_id_map.get(port_a_tuple)
        port_b_id = port_id_map.get(port_b_tuple)

        if not port_a_id or not port_b_id:
            continue

        # Update connected port IDs
        for port in ports:
            if port['id'] == port_a_id:
                if port_b_id not in port['connectedPortIds']:
                    port['connectedPortIds'].append(port_b_id)
            elif port['id'] == port_b_id:
                if port_a_id not in port['connectedPortIds']:
                    port['connectedPortIds'].append(port_a_id)

        # Generate route
        route = generate_connector_route(
            port_a_id,
            port_b_id,
            ports,
            parts
        )

        # Determine connector color from item_flow or port types
        item_flow = conn.get('item_flow', '').lower()
        conn_color = get_connector_color(item_flow, ports, port_a_id, port_b_id)

        connector_id = f"conn_{to_snake_case(conn_name)}"
        sajai_connectors.append({
            'id': connector_id,
            'name': conn_name,
            'sysmlRef': f"{arch_id}::{conn_name}",
            'sourcePortId': port_a_id,
            'targetPortId': port_b_id,
            'route': route,
            'color': conn_color,
            'visible': True,
            'metadata': {
                'itemFlow': conn.get('item_flow', '')
            }
        })

    # Create camera
    camera = {
        'position': [15.0, 12.0, 15.0],
        'target': [0.0, 0.0, 0.0],
        'fov': 60.0,
        'near': 0.1,
        'far': 1000.0
    }

    return {
        'id': scene_id,
        'name': arch_name,
        'contextRef': arch_id,
        'camera': camera,
        'parts': parts,
        'ports': ports,
        'connectors': sajai_connectors,
        'metadata': {
            'generated': True,
            'source': 'sysml_v2',
            'flat_architecture': True
        }
    }


def generate_scene(
    root_block_name: str,
    arch_id: str,
    sysml_ir: dict,
    scene_id: str,
    is_internal: bool = False
) -> dict:
    """
    Generate a single SAJAI scene for a block and its children.

    Args:
        root_block_name: Name of the block to use as scene root
        arch_id: Architecture ID
        sysml_ir: Full SysML IR
        scene_id: Unique scene identifier
        is_internal: True if this is an internal structure view

    Returns:
        Scene dictionary with parts, ports, and connectors
    """
    compositions = sysml_ir.get('compositions', [])
    proxy_ports = sysml_ir.get('proxy_ports', [])
    connectors = sysml_ir.get('connectors', [])

    # Find child blocks
    children = [c for c in compositions if c['parent'] == root_block_name]

    # Create parts for each child
    parts = []
    part_id_map = {}  # block_name -> part_id

    for idx, child in enumerate(children):
        child_name = child['child']
        part_id = f"part_{to_snake_case(child_name)}"
        part_id_map[child_name] = part_id

        # Check if this part has internal structure (for double-click scene)
        has_children = any(c['parent'] == child_name for c in compositions)
        double_click_scene = f"{to_snake_case(child_name)}_internals" if has_children else None

        parts.append({
            'id': part_id,
            'name': child_name,
            'sysmlRef': f"{arch_id}::{root_block_name}::{child_name}",
            'qualifiedName': f"{arch_id}::{root_block_name}::{child_name}",
            'type': child_name,
            'owner': f"{arch_id}::{root_block_name}",
            'position': [0, 0, 0],  # Will be set by auto_layout
            'size': [2.0, 1.5, 2.0],  # Default size
            'color': get_block_color(child_name),
            'opacity': 0.85,
            'visible': True,
            'metadata': {
                'multiplicity': child.get('multiplicity', '1'),
                'doubleClickScene': double_click_scene
            } if double_click_scene else {
                'multiplicity': child.get('multiplicity', '1')
            }
        })

    # Auto-layout parts
    parts = auto_layout_parts(parts)

    # Create ports
    ports = []
    port_id_map = {}  # (block, port_name) -> port_id

    for proxy_port in proxy_ports:
        owner = proxy_port['owner']
        port_name = proxy_port['name']
        port_type = proxy_port.get('type', 'Port')

        # Only include ports for blocks that are in this scene
        if owner not in part_id_map:
            continue

        part_id = part_id_map[owner]
        port_id = f"port_{to_snake_case(owner)}_{to_snake_case(port_name)}"
        port_id_map[(owner, port_name)] = port_id

        ports.append({
            'id': port_id,
            'name': port_name,
            'sysmlRef': f"{arch_id}::{root_block_name}::{owner}::{port_name}",
            'ownerPartId': part_id,
            'type': port_type,
            'surface': 'top',  # Will be assigned later
            'uv': [0.5, 0.5],
            'radius': 0.2,
            'color': get_port_color(port_type),
            'visible': True,
            'connectedPortIds': [],
            'metadata': {
                'protocol': infer_protocol(port_type, port_name)
            }
        })

    # Assign port surfaces based on connections
    ports = assign_port_surfaces(ports, connectors, part_id_map, parts)

    # Create connectors
    sajai_connectors = []
    for idx, conn in enumerate(connectors):
        conn_name = conn.get('name', f'conn_{idx+1:03d}')
        end_a = conn.get('end_a', '')
        end_b = conn.get('end_b', '')

        # Parse endpoints (format: "BlockName.portName")
        port_a_tuple = parse_endpoint(end_a)
        port_b_tuple = parse_endpoint(end_b)

        if not port_a_tuple or not port_b_tuple:
            continue

        # Get port IDs
        port_a_id = port_id_map.get(port_a_tuple)
        port_b_id = port_id_map.get(port_b_tuple)

        if not port_a_id or not port_b_id:
            continue

        # Update connected port IDs
        for port in ports:
            if port['id'] == port_a_id:
                port['connectedPortIds'].append(port_b_id)
            elif port['id'] == port_b_id:
                port['connectedPortIds'].append(port_a_id)

        # Generate route
        route = generate_connector_route(
            port_a_id,
            port_b_id,
            ports,
            parts
        )

        # Determine connector color from item_flow or port types
        item_flow = conn.get('item_flow', '').lower()
        conn_color = get_connector_color(item_flow, ports, port_a_id, port_b_id)

        connector_id = f"conn_{to_snake_case(conn_name)}"
        sajai_connectors.append({
            'id': connector_id,
            'name': conn_name,
            'sysmlRef': f"{arch_id}::{root_block_name}::{conn_name}",
            'sourcePortId': port_a_id,
            'targetPortId': port_b_id,
            'route': route,
            'color': conn_color,
            'visible': True,
            'metadata': {
                'itemFlow': conn.get('item_flow', '')
            }
        })

    # Create camera
    camera = {
        'position': [15.0, 12.0, 15.0],
        'target': [0.0, 0.0, 0.0],
        'fov': 60.0,
        'near': 0.1,
        'far': 1000.0
    }

    scene_name = f"{root_block_name} Internals" if is_internal else root_block_name

    return {
        'id': scene_id,
        'name': scene_name,
        'contextRef': f"{arch_id}::{root_block_name}",
        'camera': camera,
        'parts': parts,
        'ports': ports,
        'connectors': sajai_connectors,
        'metadata': {
            'generated': True,
            'source': 'sysml_v2'
        }
    }


def auto_layout_parts(parts: List[dict]) -> List[dict]:
    """
    Auto-layout parts in 3D space using circular arrangement.

    Args:
        parts: List of part dictionaries

    Returns:
        Parts list with updated positions
    """
    num_parts = len(parts)

    if num_parts == 0:
        return parts

    if num_parts == 1:
        # Single part at origin
        parts[0]['position'] = [0.0, 0.0, 0.0]
        return parts

    # Arrange in circle
    radius = 5.0 + (num_parts * 0.5)  # Scale radius with part count
    angle_step = (2 * math.pi) / num_parts

    for idx, part in enumerate(parts):
        angle = idx * angle_step
        x = radius * math.cos(angle)
        z = radius * math.sin(angle)
        y = 0.0  # All parts on same horizontal plane

        part['position'] = [round(x, 2), round(y, 2), round(z, 2)]

        # Vary size slightly based on hash of name for visual interest
        size_factor = 1.0 + (hash_to_float(part['name']) * 0.4)
        base_size = 2.0
        part['size'] = [
            round(base_size * size_factor, 2),
            round(base_size * 0.7 * size_factor, 2),
            round(base_size * size_factor, 2)
        ]

    return parts


def assign_port_surfaces(
    ports: List[dict],
    connectors: List[dict],
    part_id_map: dict,
    parts: List[dict]
) -> List[dict]:
    """
    Assign ports to surfaces of their owner parts based on connection directions.

    Args:
        ports: List of port dictionaries
        connectors: List of connector dictionaries
        part_id_map: Mapping from block name to part ID
        parts: List of part dictionaries with positions

    Returns:
        Ports list with updated surface and uv coordinates
    """
    # Build position lookup
    part_positions = {}
    for part in parts:
        part_positions[part['id']] = part['position']

    # For each port, determine surface based on connected ports
    for port in ports:
        owner_part_id = port['ownerPartId']
        owner_pos = part_positions.get(owner_part_id, [0, 0, 0])

        # Find connected ports
        connected_positions = []
        for conn in connectors:
            end_a = conn.get('end_a', '')
            end_b = conn.get('end_b', '')

            port_a_tuple = parse_endpoint(end_a)
            port_b_tuple = parse_endpoint(end_b)

            if port_a_tuple and (port_a_tuple[0], port_a_tuple[1]) == (
                get_owner_from_port_id(port['id']), port['name']
            ):
                # This port is end_a, find position of end_b owner
                if port_b_tuple and port_b_tuple[0] in part_id_map:
                    target_part_id = part_id_map[port_b_tuple[0]]
                    target_pos = part_positions.get(target_part_id, [0, 0, 0])
                    connected_positions.append(target_pos)

            elif port_b_tuple and (port_b_tuple[0], port_b_tuple[1]) == (
                get_owner_from_port_id(port['id']), port['name']
            ):
                # This port is end_b, find position of end_a owner
                if port_a_tuple and port_a_tuple[0] in part_id_map:
                    target_part_id = part_id_map[port_a_tuple[0]]
                    target_pos = part_positions.get(target_part_id, [0, 0, 0])
                    connected_positions.append(target_pos)

        # Determine surface from average direction
        if connected_positions:
            avg_direction = [
                sum(p[0] for p in connected_positions) / len(connected_positions) - owner_pos[0],
                sum(p[1] for p in connected_positions) / len(connected_positions) - owner_pos[1],
                sum(p[2] for p in connected_positions) / len(connected_positions) - owner_pos[2]
            ]
            surface = direction_to_surface(avg_direction)
        else:
            # No connections, default to top
            surface = 'top'

        port['surface'] = surface

        # Randomize UV slightly based on port name hash
        u = 0.5 + (hash_to_float(port['name']) * 0.3 - 0.15)
        v = 0.5 + (hash_to_float(port['name'] + 'v') * 0.3 - 0.15)
        port['uv'] = [round(u, 2), round(v, 2)]

    return ports


def generate_connector_route(
    port_a_id: str,
    port_b_id: str,
    ports: List[dict],
    parts: List[dict]
) -> List[List[float]]:
    """
    Generate a simple routed path between two ports.

    Args:
        port_a_id: Source port ID
        port_b_id: Target port ID
        ports: List of all ports
        parts: List of all parts

    Returns:
        List of 3D waypoints [[x,y,z], ...]
    """
    # Find ports
    port_a = next((p for p in ports if p['id'] == port_a_id), None)
    port_b = next((p for p in ports if p['id'] == port_b_id), None)

    if not port_a or not port_b:
        return []

    # Find owner parts
    part_a = next((p for p in parts if p['id'] == port_a['ownerPartId']), None)
    part_b = next((p for p in parts if p['id'] == port_b['ownerPartId']), None)

    if not part_a or not part_b:
        return []

    # Calculate port positions on part surfaces
    pos_a = calculate_port_position(port_a, part_a)
    pos_b = calculate_port_position(port_b, part_b)

    # Generate simple 3-waypoint route with slight arc
    mid_x = (pos_a[0] + pos_b[0]) / 2
    mid_y = max(pos_a[1], pos_b[1]) + 1.0  # Slightly above
    mid_z = (pos_a[2] + pos_b[2]) / 2

    route = [
        pos_a,
        [round(mid_x, 2), round(mid_y, 2), round(mid_z, 2)],
        pos_b
    ]

    return route


def calculate_port_position(port: dict, part: dict) -> List[float]:
    """
    Calculate 3D position of port on part surface.

    Args:
        port: Port dictionary with surface and uv
        part: Part dictionary with position and size

    Returns:
        [x, y, z] position
    """
    pos = part['position']
    size = part['size']
    surface = port['surface']
    uv = port['uv']

    # Map UV coordinates to surface position
    if surface == 'top':
        return [
            pos[0] + (uv[0] - 0.5) * size[0],
            pos[1] + size[1] / 2,
            pos[2] + (uv[1] - 0.5) * size[2]
        ]
    elif surface == 'bottom':
        return [
            pos[0] + (uv[0] - 0.5) * size[0],
            pos[1] - size[1] / 2,
            pos[2] + (uv[1] - 0.5) * size[2]
        ]
    elif surface == 'left':
        return [
            pos[0] - size[0] / 2,
            pos[1] + (uv[1] - 0.5) * size[1],
            pos[2] + (uv[0] - 0.5) * size[2]
        ]
    elif surface == 'right':
        return [
            pos[0] + size[0] / 2,
            pos[1] + (uv[1] - 0.5) * size[1],
            pos[2] + (uv[0] - 0.5) * size[2]
        ]
    elif surface == 'front':
        return [
            pos[0] + (uv[0] - 0.5) * size[0],
            pos[1] + (uv[1] - 0.5) * size[1],
            pos[2] + size[2] / 2
        ]
    elif surface == 'back':
        return [
            pos[0] + (uv[0] - 0.5) * size[0],
            pos[1] + (uv[1] - 0.5) * size[1],
            pos[2] - size[2] / 2
        ]
    else:
        # Default to center
        return pos


def direction_to_surface(direction: List[float]) -> str:
    """
    Convert direction vector to surface name.

    Args:
        direction: [dx, dy, dz] direction vector

    Returns:
        Surface name ('top', 'bottom', 'left', 'right', 'front', 'back')
    """
    abs_dir = [abs(d) for d in direction]
    max_idx = abs_dir.index(max(abs_dir))

    if max_idx == 0:  # X dominant
        return 'right' if direction[0] > 0 else 'left'
    elif max_idx == 1:  # Y dominant
        return 'top' if direction[1] > 0 else 'bottom'
    else:  # Z dominant
        return 'front' if direction[2] > 0 else 'back'


def get_block_color(block_name: str) -> str:
    """Get color for a block based on its name."""
    name_lower = block_name.lower()
    for keyword, color in BLOCK_TYPE_COLORS.items():
        if keyword in name_lower:
            return color
    return BLOCK_TYPE_COLORS['default']


def get_port_color(port_type: str) -> str:
    """Get color for a port based on its type."""
    type_lower = port_type.lower()
    for keyword, color in PORT_TYPE_COLORS.items():
        if keyword in type_lower:
            return color
    return PORT_TYPE_COLORS['default']


def get_connector_color(
    item_flow: str,
    ports: List[dict],
    port_a_id: str,
    port_b_id: str
) -> str:
    """Determine connector color from item_flow or port types."""
    if item_flow:
        flow_lower = item_flow.lower()
        if 'power' in flow_lower:
            return PORT_TYPE_COLORS['power']
        elif 'data' in flow_lower:
            return PORT_TYPE_COLORS['data']
        elif 'command' in flow_lower or 'control' in flow_lower:
            return PORT_TYPE_COLORS['command']

    # Use port color
    port_a = next((p for p in ports if p['id'] == port_a_id), None)
    if port_a:
        return port_a['color']

    return PORT_TYPE_COLORS['default']


def parse_endpoint(endpoint: str) -> Optional[Tuple[str, str]]:
    """
    Parse connector endpoint into (block_name, port_name).

    Args:
        endpoint: String like "BlockName.portName"

    Returns:
        Tuple of (block_name, port_name) or None if invalid
    """
    if '.' not in endpoint:
        return None

    parts = endpoint.split('.', 1)
    if len(parts) != 2:
        return None

    return (parts[0], parts[1])


def get_owner_from_port_id(port_id: str) -> str:
    """
    Extract owner block name from port ID.

    Args:
        port_id: Port ID like "port_missioncomputer_cmdout"

    Returns:
        Block name
    """
    # Remove "port_" prefix and extract owner part
    # Format: port_<owner>_<portname>
    if not port_id.startswith('port_'):
        return ''

    parts = port_id[5:].split('_')
    if len(parts) < 2:
        return ''

    # Owner is all parts except the last one
    owner_snake = '_'.join(parts[:-1])
    return from_snake_case(owner_snake)


def infer_protocol(port_type: str, port_name: str) -> str:
    """Infer communication protocol from port type and name."""
    combined = (port_type + port_name).lower()

    if 'spi' in combined:
        return 'SPI'
    elif 'i2c' in combined or 'iic' in combined:
        return 'I2C'
    elif 'uart' in combined or 'serial' in combined:
        return 'UART'
    elif 'can' in combined:
        return 'CAN'
    elif 'usb' in combined:
        return 'USB'
    elif 'eth' in combined or 'ethernet' in combined:
        return 'Ethernet'
    elif 'pci' in combined:
        return 'PCIe'
    elif 'power' in combined or 'pwr' in combined:
        return 'Power'
    elif 'cmd' in combined or 'command' in combined:
        return 'Command'
    elif 'data' in combined:
        return 'Data'
    else:
        return 'Generic'


def to_snake_case(name: str) -> str:
    """Convert PascalCase to snake_case."""
    result = []
    for i, char in enumerate(name):
        if char.isupper() and i > 0:
            result.append('_')
        result.append(char.lower())
    return ''.join(result)


def from_snake_case(name: str) -> str:
    """Convert snake_case to PascalCase."""
    return ''.join(word.capitalize() for word in name.split('_'))


def hash_to_float(text: str) -> float:
    """Convert string to deterministic float in [0, 1) range."""
    hash_obj = hashlib.md5(text.encode())
    hash_int = int(hash_obj.hexdigest()[:8], 16)
    return (hash_int % 1000) / 1000.0
