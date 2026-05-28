# SPA Server API Endpoints

## Architecture Format Support

The server now supports two architecture formats:

1. **Monolithic**: Single `.sysml` file containing everything (backward compatible)
2. **Separated**: Directory structure with `model.sysml` + `views/` folder

Both formats are auto-detected and work transparently.

## Endpoints

### Core Architecture Endpoints

#### List All Architectures
```
GET /api/architectures
```

**Response:**
```json
{
  "architectures": [
    {
      "id": "arch_000001",
      "name": "Uav Payload Reference Architecture 1",
      "path": "data/architectures/arch_000001.sysml",
      "domain": "uav payload",
      "format": "monolithic"
    },
    {
      "id": "arch_test_001",
      "name": "Test Architecture 1",
      "path": "data/architectures/arch_test_001",
      "domain": "test system",
      "format": "separated",
      "available_views": ["bdd", "ibd"]
    }
  ]
}
```

#### Get Architecture
```
GET /api/architecture/<path>
```

Auto-detects format (file vs directory) and loads accordingly.

**Example:**
```
GET /api/architecture/data/architectures/arch_000001.sysml
GET /api/architecture/data/architectures/arch_test_001
```

**Response:**
```json
{
  "id": "arch_test_001",
  "name": "Test Architecture 1",
  "format": "separated",
  "available_views": ["bdd", "ibd"],
  "blocks": [...],
  "requirements": [...],
  "connectors": [...]
}
```

### View Endpoints (Separated Architectures Only)

#### List Views
```
GET /api/architecture/<path>/views
```

Lists available views for a separated architecture.

**Example:**
```
GET /api/architecture/data/architectures/arch_test_001/views
```

**Response:**
```json
{
  "views": [
    {
      "name": "bdd",
      "type": "bdd",
      "path": "views/bdd.sysml"
    },
    {
      "name": "ibd",
      "type": "ibd",
      "path": "views/ibd.sysml"
    }
  ],
  "format": "separated"
}
```

For monolithic architectures, returns empty list:
```json
{
  "views": [],
  "format": "monolithic"
}
```

#### Get Specific View
```
GET /api/architecture/<path>/view/<view_name>
```

Loads a specific view with its model data.

**Example:**
```
GET /api/architecture/data/architectures/arch_test_001/view/bdd
```

**Response:**
```json
{
  "id": "arch_test_001",
  "name": "Test Architecture 1",
  "format": "separated",
  "blocks": [...],
  "requirements": [...],
  "view": {
    "name": "bdd",
    "content": {
      "package": "arch_test_001_bdd",
      ...
    }
  }
}
```

### Diagram Generation Endpoints

Both endpoints now support both monolithic and separated architectures.

#### Generate BDD Diagram
```
GET /api/diagram/bdd/<path>
```

**Example:**
```
GET /api/diagram/bdd/data/architectures/arch_000001.sysml
GET /api/diagram/bdd/data/architectures/arch_test_001
```

**Response:**
```json
{
  "plantuml": "@startuml\n...\n@enduml",
  "url": "http://www.plantuml.com/plantuml/png/..."
}
```

#### Generate IBD Diagram
```
GET /api/diagram/ibd/<path>
```

**Example:**
```
GET /api/diagram/ibd/data/architectures/arch_000001.sysml
GET /api/diagram/ibd/data/architectures/arch_test_001
```

**Response:**
```json
{
  "plantuml": "@startuml\n...\n@enduml",
  "url": "http://www.plantuml.com/plantuml/png/..."
}
```

## Backward Compatibility

All existing endpoints maintain full backward compatibility:

- Monolithic `.sysml` files work exactly as before
- Legacy `.json` files continue to work
- All responses include a `format` field indicating the architecture type
- No breaking changes to response structure

## Separated Architecture Structure

```
data/architectures/arch_NNNNNN/
  ├── model.sysml              # Model definitions
  └── views/
      ├── bdd.sysml            # Block Definition Diagram view
      └── ibd.sysml            # Internal Block Diagram view
```

### model.sysml
Contains:
- Package definition
- Requirements
- Part definitions
- System structure
- Connections

### views/*.sysml
Contains:
- Import statement: `import "model.sysml";`
- View package
- View metadata in comments
- View configuration options

## Testing

Run the comprehensive test suite:
```bash
python3 test_separated_format.py
```

Run MVP checks:
```bash
bash ralph/run_mvp_checks.sh
```

## Example: Creating a Separated Architecture

1. Create directory structure:
```bash
mkdir -p data/architectures/my_arch/views
```

2. Create `model.sysml`:
```sysml
package my_arch {
    // Requirements, part definitions, etc.
}
```

3. Create `views/bdd.sysml`:
```sysml
import "model.sysml";

package my_arch_bdd {
    doc /* Block Definition Diagram View */
}
```

4. Create `views/ibd.sysml`:
```sysml
import "model.sysml";

package my_arch_ibd {
    doc /* Internal Block Diagram View */
}
```

The server will auto-detect and serve the separated architecture alongside existing monolithic files.
