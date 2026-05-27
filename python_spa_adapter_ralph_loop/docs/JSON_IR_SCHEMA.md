# JSON IR Schema Documentation

This document describes the JSON Intermediate Representation (IR) schema used for SysML v2 architectures in this project.

## Purpose

The JSON IR serves as:
- **Intermediate format** for programmatic generation and manipulation
- **Bridge format** between generators and SysML v2 textual syntax
- **Training data source** that gets converted to .sysml files for model training

## Schema Overview

```json
{
  "id": "string",
  "name": "string", 
  "domain": "string",
  "format": "sysml_style_json_mvp",
  "blocks": [...],
  "proxy_ports": [...],
  "connectors": [...],
  "requirements": [...],
  "relationships": [...]
}
```

## Field Specifications

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique identifier (e.g., "arch_000001") |
| `name` | string | Yes | Human-readable name |
| `domain` | string | Yes | Domain category (e.g., "uav payload", "satellite bus") |
| `format` | string | Yes | Format version identifier (currently "sysml_style_json_mvp") |
| `blocks` | array | Yes | System components / part definitions |
| `proxy_ports` | array | No | Interface points on blocks |
| `connectors` | array | No | Connections between ports |
| `requirements` | array | No | System requirements |
| `relationships` | array | No | Traceability relationships |

### Blocks

Blocks represent SysML v2 `part def` (part definitions) - the structural building blocks of the system.

```json
{
  "name": "MissionComputer",
  "stereotype": "Block"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Block identifier (must be valid SysML v2 identifier) |
| `stereotype` | string | Yes | Currently always "Block" |

**SysML v2 Mapping:**
```sysml
part def MissionComputer {
  // ports and other features go here
}
```

**Conventions:**
- First block in array is typically the system-level block
- Subsequent blocks are subsystems/components
- Names should be PascalCase

### Proxy Ports

Ports represent interface points where blocks can connect. Maps to SysML v2 `port` features.

```json
{
  "owner": "MissionComputer",
  "name": "cmdOut", 
  "type": "CommandIF"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `owner` | string | Yes | Name of the owning block |
| `name` | string | Yes | Port identifier |
| `type` | string | Yes | Interface type (e.g., "CommandIF", "DataIF") |

**SysML v2 Mapping:**
```sysml
part def MissionComputer {
  port cmdOut : CommandIF;
}
```

**Conventions:**
- Port names typically use camelCase
- Port types use PascalCase with "IF" suffix convention
- Common types: CommandIF, DataIF, PowerIF, StatusIF, ControlIF

### Connectors

Connectors define relationships between ports, including item flows. Maps to SysML v2 `connection` and `flow`.

```json
{
  "name": "cmdLink",
  "end_a": "MissionComputer.cmdOut",
  "end_b": "SensorPayload.dataIn",
  "item_flow": "Command"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Connector identifier |
| `end_a` | string | Yes | Source port in format "BlockName.portName" |
| `end_b` | string | Yes | Target port in format "BlockName.portName" |
| `item_flow` | string | No | Type of data/material flowing |

**SysML v2 Mapping:**
```sysml
part system : System {
  part missionComputer : MissionComputer;
  part sensorPayload : SensorPayload;
  
  connection : cmdLink connect 
    missionComputer.cmdOut to sensorPayload.dataIn;
}
```

**Conventions:**
- Connector names use camelCase, often with "Link" or "Connection" suffix
- Item flows describe what passes through (Command, Data, Power, etc.)

### Requirements

Requirements represent system needs and constraints. Maps to SysML v2 `requirement`.

```json
{
  "id": "REQ-001",
  "text": "The system shall exchange data through typed interfaces."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Requirement identifier (e.g., "REQ-001") |
| `text` | string | Yes | Requirement statement |

**SysML v2 Mapping:**
```sysml
requirement <'REQ-001'> {
  doc /* The system shall exchange data through typed interfaces. */
}
```

**Conventions:**
- IDs use format "REQ-NNN" with zero-padded numbers
- Text should be clear, testable requirement statements
- Use modal verbs "shall", "should", "must"

### Relationships

Relationships establish traceability between model elements. Currently supports satisfaction relationships.

```json
{
  "type": "satisfy",
  "client": "MissionComputer",
  "supplier": "REQ-001"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Relationship type (currently "satisfy") |
| `client` | string | Yes | Source element (typically a block) |
| `supplier` | string | Yes | Target element (typically a requirement ID) |

**SysML v2 Mapping:**
```sysml
part system : System {
  part missionComputer : MissionComputer;
  
  satisfy requirement <'REQ-001'> by missionComputer;
}
```

**Conventions:**
- "satisfy" indicates a block satisfies/fulfills a requirement
- Future: may support "trace", "refine", "verify" relationships

## Complete Example

```json
{
  "id": "arch_000001",
  "name": "UAV Payload Reference Architecture",
  "domain": "uav payload",
  "format": "sysml_style_json_mvp",
  "blocks": [
    {"name": "UavPayloadSystem", "stereotype": "Block"},
    {"name": "MissionComputer", "stereotype": "Block"},
    {"name": "SensorPayload", "stereotype": "Block"}
  ],
  "proxy_ports": [
    {"owner": "MissionComputer", "name": "cmdOut", "type": "CommandIF"},
    {"owner": "SensorPayload", "name": "dataOut", "type": "DataIF"}
  ],
  "connectors": [
    {
      "name": "cmdLink",
      "end_a": "MissionComputer.cmdOut",
      "end_b": "SensorPayload.dataOut",
      "item_flow": "Command"
    }
  ],
  "requirements": [
    {
      "id": "REQ-001",
      "text": "The system shall exchange command and data through typed interfaces."
    }
  ],
  "relationships": [
    {"type": "satisfy", "client": "MissionComputer", "supplier": "REQ-001"}
  ]
}
```

**Converts to SysML v2:**

```sysml
package arch_000001 {
  // UAV Payload Reference Architecture
  // Domain: uav payload

  import ScalarValues::*;

  // Interface Definitions
  interface def CommandIF;
  interface def DataIF;

  // Part Definitions
  part def UavPayloadSystem {
  }

  part def MissionComputer {
    port cmdOut : CommandIF;
  }

  part def SensorPayload {
    port dataOut : DataIF;
  }

  // Requirements
  requirement <'REQ-001'> {
    doc /* The system shall exchange command and data through typed interfaces. */
  }

  // System Assembly
  part uavpayloadsystem : UavPayloadSystem {
    part missioncomputer : MissionComputer;
    part sensorpayload : SensorPayload;

    // Connections
    connection : cmdLink connect 
      missioncomputer.cmdOut to sensorpayload.dataOut;

    // Requirement Satisfaction
    satisfy requirement <'REQ-001'> by missioncomputer;
  }
}
```

## Validation

To validate generated .sysml files:

```bash
# Convert JSON to SysML
python3 scripts/json_to_sysml.py

# Use SysML v2 Pilot Implementation validator (requires Java)
# Clone: https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation
# Run validator on generated .sysml files
```

## Extension Points

The schema can be extended to support:

- **Attributes** - Add `attributes` array to blocks for properties
- **Value types** - Add `value_types` for units, quantities
- **Actions** - Add `actions` for behavior
- **States** - Add `states` for state machines
- **Allocations** - Add `allocations` for logical-to-physical mapping
- **Metadata** - Add `metadata` object for annotations

## Generator Scripts

- `scripts/generate_sample_architectures.py` - Creates 3 simple examples
- `scripts/generate_varied_architectures.py` - Creates 50+ diverse architectures
- `scripts/json_to_sysml.py` - Converts JSON IR to .sysml files

## References

- [SysML v2 Pilot Implementation](https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation)
- [SysML v2 Specification](https://www.omg.org/spec/SysML/2.0/)
- SysML v2 examples in: `sysml/src/training/` and `sysml/src/examples/`
