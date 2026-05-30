# SAJAI Generator

Convert SysML v2 architectures to SAJAI format for 3D visualization.

## Overview

The SAJAI (SysML-Aware JSON for Auditing and Introspection) generator transforms parsed SysML v2 architectures into a 3D visualization format with:

- **Auto-layout**: Automatic positioning of parts in 3D space
- **Smart port placement**: Ports positioned on part surfaces based on connection directions
- **Connector routing**: Automatic path generation for connections
- **Color coding**: Semantic colors for different component and port types
- **Scene hierarchy**: Support for nested scenes with internal structure views

## Files

- `sajai_generator.py` - Core generator module
- `convert_to_sajai.py` - CLI tool for conversion
- `static/sample-data/*.sajai` - Example output files

## Usage

### Python API

```python
from spa.sysml_parser import parse_sysml_to_json
from spa.sajai_generator import generate_sajai

# From .sysml file
with open('architecture.sysml', 'r') as f:
    sysml_ir = parse_sysml_to_json(f.read(), Path('architecture.sysml'))
sajai = generate_sajai(sysml_ir)

# From JSON IR
import json
with open('architecture.json', 'r') as f:
    sysml_ir = json.load(f)
sajai = generate_sajai(sysml_ir)
```

### Command Line

```bash
# Single file conversion
python spa/convert_to_sajai.py input.sysml output.sajai
python spa/convert_to_sajai.py input.json output.sajai

# Batch conversion
python spa/convert_to_sajai.py --batch data/architectures_json/ spa/static/sample-data/
```

## SAJAI Format Structure

```json
{
  "format": "SAJAI",
  "version": "1.0",
  "description": "...",
  "scenes": {
    "scene_name": {
      "id": "scene_id",
      "name": "Scene Name",
      "contextRef": "SysML::Ref",
      "camera": { ... },
      "parts": [ ... ],
      "ports": [ ... ],
      "connectors": [ ... ],
      "metadata": { ... }
    }
  }
}
```

### Parts

Each part represents a component with 3D geometry:

```json
{
  "id": "part_id",
  "name": "PartName",
  "sysmlRef": "qualified::name",
  "position": [x, y, z],
  "size": [width, height, depth],
  "color": "#hex",
  "opacity": 0.85,
  "visible": true,
  "metadata": {
    "doubleClickScene": "nested_scene_id"
  }
}
```

**Superposition**: Multiple parts MAY have identical `position` values. This is valid for representing hierarchical nesting, overlapping components, or multi-level abstractions.

### Ports

Ports are placed on part surfaces:

```json
{
  "id": "port_id",
  "name": "portName",
  "ownerPartId": "part_id",
  "surface": "top|bottom|left|right|front|back",
  "uv": [u, v],
  "radius": 0.2,
  "color": "#hex",
  "connectedPortIds": [],
  "metadata": {
    "protocol": "SPI"
  }
}
```

### Connectors

Connectors are routed paths between ports:

```json
{
  "id": "conn_id",
  "name": "ConnName",
  "sourcePortId": "port_id",
  "targetPortId": "port_id",
  "route": [[x,y,z], ...],
  "color": "#hex",
  "visible": true,
  "metadata": {
    "itemFlow": "Data"
  }
}
```

## Auto-Layout Algorithm

### Part Positioning

Parts are arranged in a circular layout:
- Single part: placed at origin
- Multiple parts: distributed evenly around a circle
- Radius scales with part count: `radius = 5.0 + (num_parts * 0.5)`

Part sizes vary slightly based on name hash for visual interest.

**Note on Superposition**: The layout algorithm may intentionally place multiple elements at the same coordinates. This is valid behavior for hierarchical or overlapping representations. Position uniqueness is NOT enforced.

### Port Surface Assignment

Ports are placed on surfaces based on connection directions:
1. Calculate average direction vector to connected parts
2. Map dominant axis to surface:
   - +X → right
   - -X → left
   - +Y → top
   - -Y → bottom
   - +Z → front
   - -Z → back
3. UV coordinates randomized slightly based on port name

### Connector Routing

Simple 3-waypoint routing:
1. Start at source port position on surface
2. Arc through midpoint above the parts
3. End at target port position on surface

## Color Schemes

### Port Types

| Type | Color | Hex |
|------|-------|-----|
| Power | Orange | #f39c12 |
| Data | Teal | #1abc9c |
| Command | Blue | #3498db |
| Control | Purple | #9b59b6 |
| Default | Gray | #95a5a6 |

### Block Types

| Type | Color | Hex |
|------|-------|-----|
| Computer | Blue | #3498db |
| Sensor | Red | #e74c3c |
| Power/Battery | Green | #2ecc71 |
| Radio | Purple | #9b59b6 |
| System | Dark Gray | #34495e |
| Payload | Orange | #e67e22 |
| Default | Gray | #7f8c8d |

Colors are assigned by keyword matching on block/port names.

## Scene Generation

### Flat Architectures

When no composition hierarchy is detected (empty `compositions` array):
- Single scene with all blocks as peers
- All ports and connectors included
- Scene named after architecture ID

### Hierarchical Architectures

When composition relationships exist:
- Root scene for top-level system
- Nested scenes for parts with internal structure
- `doubleClickScene` metadata links to internal views

## Examples

### Input: SysML v2 JSON IR

```json
{
  "id": "arch_000001",
  "name": "UAV Payload System",
  "blocks": [
    {"name": "FlightController", "stereotype": "Block"},
    {"name": "GPS", "stereotype": "Block"}
  ],
  "proxy_ports": [
    {"owner": "FlightController", "name": "gpsIn", "type": "DataIF"}
  ],
  "connectors": [
    {"name": "gpsLink", "end_a": "GPS.dataOut", "end_b": "FlightController.gpsIn"}
  ]
}
```

### Output: SAJAI

```json
{
  "format": "SAJAI",
  "version": "1.0",
  "scenes": {
    "arch_000001": {
      "parts": [
        {
          "id": "part_flight_controller",
          "name": "FlightController",
          "position": [5.0, 0.0, 0.0],
          "color": "#3498db"
        },
        {
          "id": "part_gps",
          "name": "GPS",
          "position": [-5.0, 0.0, 0.0],
          "color": "#e74c3c"
        }
      ],
      "ports": [...],
      "connectors": [...]
    }
  }
}
```

## Integration with SPA

The generated SAJAI files can be loaded directly into the SPA 3D viewer:

1. Place `.sajai` files in `spa/static/sample-data/`
2. Load via API: `GET /api/sajai/<filename>`
3. Render in Three.js viewer with interactive navigation

## Testing

Run the test suite:

```bash
cd python_spa_adapter_ralph_loop
python3 test_sajai_generator.py
```

## Future Enhancements

Potential improvements:
- [ ] Multi-level hierarchy traversal
- [ ] Advanced routing algorithms (avoid collisions)
- [ ] Grid layout option
- [ ] Custom color palettes
- [ ] Size calculation based on internal complexity
- [ ] Animation keyframes for assembly sequences
- [ ] Export to other 3D formats (glTF, OBJ)
