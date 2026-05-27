# SysML v2 Training Data Generation - Quick Start

This guide shows you how to generate SysML v2 training data for your Qwen adapter.

## Workflow

```
Generate JSON IR → Convert to .sysml → Train on .sysml files
```

## Step 1: Generate Architecture JSON Files

### Option A: Generate varied architectures (recommended for training)

```bash
# Generate 50 diverse architectures
python3 scripts/generate_varied_architectures.py

# To generate more, edit the script:
# NUM_ARCHITECTURES = 200  # Change from 50 to 200
# START_ID = 51            # Continue from where you left off
```

### Option B: Generate simple examples

```bash
# Generate 3 basic examples (UAV, rover, habitat)
python3 scripts/generate_sample_architectures.py
```

## Step 2: Convert JSON to SysML v2

```bash
# Convert all JSON files to .sysml
python3 scripts/json_to_sysml.py

# Output will be in: outputs/sysml/*.sysml

# Convert specific file
python3 scripts/json_to_sysml.py --input data/architectures/arch_000001.json

# Specify output directory
python3 scripts/json_to_sysml.py --output my_sysml_dir/
```

## Step 3: Create Prompt-Architecture Pairs (Optional)

Use the SPA to manually create training pairs:

```bash
# Start the SPA server
python3 spa/server.py --host 127.0.0.1 --port 8081

# Open browser: http://127.0.0.1:8081
```

In the SPA:
1. Click architecture JSON file in tree
2. View tabs: Text / BDD / IBD
3. Write prompt describing the architecture
4. Click "Add pair"
5. Save pairs to `data/pairs/`

## Step 4: Validate SysML v2 Files (Optional)

To validate generated .sysml files with the official validator:

```bash
# Clone SysML v2 Pilot Implementation
cd /tmp
git clone https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation.git

# Build (requires Java 11+)
cd SysML-v2-Pilot-Implementation
./gradlew build

# Validate your .sysml file
./gradlew run --args="outputs/sysml/arch_000001.sysml"
```

## What You Get

### Input JSON (IR Format)
```json
{
  "id": "arch_000001",
  "name": "UAV Payload System",
  "blocks": [
    {"name": "MissionComputer", "stereotype": "Block"}
  ],
  "proxy_ports": [
    {"owner": "MissionComputer", "name": "cmdOut", "type": "CommandIF"}
  ],
  "requirements": [
    {"id": "REQ-001", "text": "System shall..."}
  ]
}
```

### Output SysML v2
```sysml
package arch_000001 {
  import ScalarValues::*;

  interface def CommandIF;

  part def MissionComputer {
    port cmdOut : CommandIF;
  }

  requirement <'REQ-001'> {
    doc /* System shall... */
  }

  part system : System {
    part missionComputer : MissionComputer;
    satisfy requirement <'REQ-001'> by missionComputer;
  }
}
```

## Training Data Format

For training your Qwen adapter:

**Input:** Natural language prompts describing what you want
```
"Create a UAV payload system with a mission computer that has command 
and data interfaces, connected to sensor payloads..."
```

**Output:** Valid SysML v2 code
```sysml
package uav_system {
  // Generated SysML v2 model
  ...
}
```

## File Locations

```
data/
  architectures/     # JSON IR files
  pairs/            # Prompt-architecture training pairs

outputs/
  sysml/           # Generated .sysml files for training

scripts/
  generate_varied_architectures.py  # Generate diverse JSON
  json_to_sysml.py                  # Convert JSON → .sysml

docs/
  JSON_IR_SCHEMA.md                 # Schema documentation
  QUICKSTART_SYSML.md              # This guide
```

## Customization

### Add More Domains

Edit `scripts/generate_varied_architectures.py`:

```python
DOMAINS = [
    'uav payload', 'satellite bus', 'ground station',
    'your_custom_domain_here',  # Add here
]
```

### Modify Architecture Structure

Edit ranges in `generate_architecture()`:
```python
num_blocks = random.randint(3, 8)   # Change block count range
num_ports = random.randint(1, 3)    # Change port count range
```

### Extend JSON Schema

See `docs/JSON_IR_SCHEMA.md` for adding:
- Attributes
- Value types  
- Actions
- States
- Metadata

## Next Steps

1. **Generate data**: Run generation scripts to create 50-200+ architectures
2. **Convert to SysML**: Use `json_to_sysml.py` to get .sysml files
3. **Create pairs**: Use SPA to author prompt-architecture pairs
4. **Train adapter**: Use .sysml files as training corpus for Qwen adapter

## References

- JSON IR Schema: `docs/JSON_IR_SCHEMA.md`
- SysML v2 Pilot: https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation
- SysML v2 Spec: https://www.omg.org/spec/SysML/2.0/
