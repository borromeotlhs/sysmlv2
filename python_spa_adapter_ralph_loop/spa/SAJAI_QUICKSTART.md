# SAJAI Generator Quick Start

## 60-Second Setup

Convert your SysML v2 architectures to 3D visualization format in three simple steps.

## Installation

No dependencies beyond Python 3 standard library. Module is ready to use.

## Quick Examples

### 1. Convert a Single File

```bash
cd python_spa_adapter_ralph_loop/spa
python3 convert_to_sajai.py ../data/architectures_json/arch_000001.json output.sajai
```

### 2. Batch Convert All Architectures

```bash
cd python_spa_adapter_ralph_loop/spa
python3 convert_to_sajai.py --batch ../data/architectures_json/ static/sample-data/
```

### 3. Use in Python

```python
from spa.sajai_generator import generate_sajai
import json

# Load SysML IR
with open('architecture.json') as f:
    sysml_ir = json.load(f)

# Generate SAJAI
sajai = generate_sajai(sysml_ir)

# Save
with open('output.sajai', 'w') as f:
    json.dump(sajai, f, indent=2)
```

## What You Get

Each architecture becomes a 3D scene with:
- **Parts**: Automatically positioned in circular layout
- **Ports**: Placed on part surfaces (top/bottom/left/right/front/back)
- **Connectors**: Routed paths between ports
- **Colors**: Semantic color coding (power=orange, data=teal, etc.)
- **Metadata**: SysML references preserved for traceability

## File Structure

```
python_spa_adapter_ralph_loop/
├── spa/
│   ├── sajai_generator.py       # Core generator
│   ├── convert_to_sajai.py      # CLI tool
│   ├── sysml_parser.py          # Existing parser (used for .sysml)
│   └── static/sample-data/
│       ├── arch_000001.sajai    # Generated examples
│       ├── arch_000002.sajai
│       └── uav_example.sajai    # Reference example
├── test_sajai_generator.py      # Test suite
└── data/
    └── architectures_json/      # Input architectures
```

## Input Format

Expects SysML IR JSON with:

```json
{
  "id": "arch_id",
  "name": "Architecture Name",
  "blocks": [{"name": "BlockName", "stereotype": "Block"}],
  "proxy_ports": [{"owner": "BlockName", "name": "portName", "type": "PortType"}],
  "connectors": [{"name": "conn", "end_a": "Block.port", "end_b": "Block.port"}],
  "compositions": []
}
```

## Output Format

Generates SAJAI JSON with:

```json
{
  "format": "SAJAI",
  "version": "1.0",
  "scenes": {
    "scene_name": {
      "parts": [...],
      "ports": [...],
      "connectors": [...],
      "camera": {...}
    }
  }
}
```

## Testing

```bash
cd python_spa_adapter_ralph_loop
python3 test_sajai_generator.py
```

Expected output:
```
Testing SAJAI Generator
==================================================
Test 1: JSON IR input
--------------------------------------------------
Loaded architecture: arch_000001
  Blocks: 4
  Ports: 3
  Connectors: 2

Generated SAJAI:
  Format: SAJAI
  Version: 1.0
  Scenes: 1
  ...

All tests passed!
```

## Viewing Results

Open any `.sajai` file to inspect the generated 3D scene data:

```bash
cat spa/static/sample-data/arch_000001.sajai | jq '.scenes.arch_000001.parts[0]'
```

Example output:
```json
{
  "id": "part_uav_payload_system",
  "name": "UavPayloadSystem",
  "position": [7.0, 0.0, 0.0],
  "size": [2.0, 1.4, 2.0],
  "color": "#34495e",
  "opacity": 0.85
}
```

## Next Steps

1. **Integrate with SPA**: Load `.sajai` files in the Three.js viewer
2. **Customize colors**: Edit `PORT_TYPE_COLORS` and `BLOCK_TYPE_COLORS` in `sajai_generator.py`
3. **Add layouts**: Implement grid or force-directed layouts
4. **Generate from .sysml**: Use `sysml_parser.py` to convert textual SysML v2

## Documentation

- **Full guide**: `spa/SAJAI_README.md`
- **Implementation details**: `SAJAI_IMPLEMENTATION.md`
- **Example files**: `spa/static/sample-data/*.sajai`

## Support

For issues or questions, check:
1. Verify input JSON has required fields (`blocks`, `proxy_ports`, `connectors`)
2. Check test suite passes: `python3 test_sajai_generator.py`
3. Inspect example outputs in `spa/static/sample-data/`

## That's It!

You now have a working SAJAI generator. Convert your architectures and visualize them in 3D.
