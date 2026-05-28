# Model-View Separation Design

## Overview

This document describes the architecture for separating SysML v2 model definitions from diagram views (BDD and IBD). This separation enables:

1. Single source of truth for model structure
2. Multiple views of the same model
3. Better modularity and maintainability
4. Alignment with SysML v2 principles

## File Structure

### Current (Monolithic)
```
data/architectures/
  arch_000001.sysml  (contains model + implicit diagram data)
  arch_000002.sysml
  ...
```

### Proposed (Separated)
```
data/architectures/
  arch_000001/
    model.sysml           # Model definition only
    views/
      bdd.sysml           # Block Definition Diagram view
      ibd.sysml           # Internal Block Diagram view
  arch_000002/
    model.sysml
    views/
      bdd.sysml
      ibd.sysml
  ...
```

## File Naming Conventions

### Model Files
- **Name:** `model.sysml`
- **Location:** `data/architectures/<arch_id>/model.sysml`
- **Purpose:** Contains package, part definitions, port definitions, requirements, connections
- **Does NOT contain:** View-specific metadata, diagram layout, diagram rendering hints

### View Files
- **Names:** `bdd.sysml`, `ibd.sysml`
- **Location:** `data/architectures/<arch_id>/views/<view_name>.sysml`
- **Purpose:** Contains view definitions referencing model elements
- **Imports:** Model package to access definitions

### Legacy Compatibility
- Keep existing `arch_NNNNNN.sysml` files as read-only for backward compatibility
- Parser detects directory structure and loads accordingly

## SysML v2 Import Syntax

SysML v2 uses `import` statements to reference elements from other packages. Based on the official specification:

### Import Patterns

```sysml
// Import entire package
import <PackageName>::*;

// Import specific element
import <PackageName>::<ElementName>;

// Import with alias
import <PackageName>::<ElementName> as <Alias>;

// Import from file (implementation-specific)
import "model.sysml";
```

### Implementation Choice

For this MVP, we use **file-based imports** (pragmatic approach):

```sysml
import "model.sysml";
```

This is:
1. Simple to parse
2. Clear in intent
3. Commonly supported by SysML v2 tools
4. Easier to implement than full namespace resolution

## File Content Examples

### Model File: `data/architectures/arch_000001/model.sysml`

```sysml
package arch_000001 {

    // Uav Payload Reference Architecture 1
    // Domain: uav payload

    // Requirements
    requirement REQ_001 {
        doc "The uav payload system shall exchange command and data through typed interfaces."
    }

    requirement REQ_002 {
        doc "The uav payload system shall trace subsystem design to requirements."
    }

    // Component Definitions
    part def MissionComputer {
        attribute processingPower : Real [1];
        attribute memorySize : Real [1];
        port cmdOut;
    }

    part def SensorPayload {
        attribute dataRate : Real [1];
        attribute resolution : Real [1];
        port dataOut;
    }

    part def PowerUnit {
        attribute voltage : Real [1];
        attribute current : Real [1];
        port pwrOut;
    }

    // System Definition
    part def UavPayloadSystem {
        part missioncomputer : MissionComputer {
            satisfy REQ_001;
        }
        part sensorpayload : SensorPayload {
            satisfy REQ_002;
        }
        part powerunit : PowerUnit {
        }

        // Connections
        connect missioncomputer.cmdOut to sensorpayload.dataOut;
        connect powerunit.pwrOut to sensorpayload.dataOut;
    }

    // System Instance
    part uavpayloadsystem : UavPayloadSystem;

}
```

### BDD View: `data/architectures/arch_000001/views/bdd.sysml`

```sysml
// Import model definitions
import "model.sysml";

package arch_000001_bdd {
    // View metadata
    doc /* 
        Block Definition Diagram View
        Architecture: arch_000001
        Name: Uav Payload Reference Architecture 1
    */

    // View configuration (used by PlantUML generator)
    comment /* 
        @viewType: BlockDefinitionDiagram
        @showAttributes: true
        @showPorts: false
        @showCompositions: true
        @showRequirements: true
        @showSatisfyRelationships: true
    */

    // Views reference elements from imported package
    // The model elements are not redeclared here
    // The PlantUML generator reads this view file to determine:
    // - Which elements to include
    // - What relationships to show
    // - Diagram-specific rendering options
}
```

### IBD View: `data/architectures/arch_000001/views/ibd.sysml`

```sysml
// Import model definitions
import "model.sysml";

package arch_000001_ibd {
    // View metadata
    doc /* 
        Internal Block Diagram View
        Architecture: arch_000001
        Name: Uav Payload Reference Architecture 1
        Context: UavPayloadSystem
    */

    // View configuration (used by PlantUML generator)
    comment /* 
        @viewType: InternalBlockDiagram
        @context: arch_000001::UavPayloadSystem
        @showPorts: true
        @showConnections: true
        @showPartTypes: true
        @layoutDirection: TB
    */
}
```

## Parser Changes

### File: `spa/sysml_parser.py`

#### New Functions

```python
def parse_import_statement(line: str) -> Optional[str]:
    """
    Extract import target from import statement.
    
    Args:
        line: Line containing import statement
        
    Returns:
        Path to imported file, or None if not an import statement
        
    Examples:
        'import "model.sysml";' -> "model.sysml"
        'import arch_000001::*;' -> None (namespace import, not file)
    """
    pass

def resolve_import_path(view_file: Path, import_target: str) -> Path:
    """
    Resolve relative import path from view file location.
    
    Args:
        view_file: Path to the view file containing import
        import_target: Target from import statement (e.g., "model.sysml")
        
    Returns:
        Absolute path to imported file
        
    Examples:
        view_file: /data/arch_000001/views/bdd.sysml
        import_target: "model.sysml"
        returns: /data/arch_000001/model.sysml
    """
    pass

def load_with_imports(file_path: Path) -> Dict:
    """
    Load a SysML file and recursively resolve imports.
    
    Args:
        file_path: Path to SysML file (model or view)
        
    Returns:
        Merged architecture dictionary with all imported content
        
    Process:
        1. Parse file content
        2. Extract import statements
        3. Recursively load imported files
        4. Merge dictionaries (imported content first, local content overrides)
    """
    pass

def extract_view_metadata(content: str) -> Dict:
    """
    Extract view-specific metadata from comment blocks.
    
    Args:
        content: SysML file content
        
    Returns:
        Dictionary with view configuration
        
    Example output:
        {
            'viewType': 'BlockDefinitionDiagram',
            'showAttributes': True,
            'showPorts': False,
            'context': 'arch_000001::UavPayloadSystem'
        }
    """
    pass
```

#### Modified Functions

```python
def parse_sysml_to_json(sysml_content: str, file_path: Path = None) -> Dict:
    """
    Modified to:
    1. Accept optional file_path for resolving imports
    2. Call load_with_imports() if imports detected
    3. Extract view metadata if present
    4. Mark source as 'model', 'view', or 'monolithic'
    """
    pass
```

## Server Changes

### File: `spa/server.py`

#### New Functions

```python
def detect_architecture_format(arch_path: Path) -> str:
    """
    Detect if architecture uses new separated format or legacy monolithic.
    
    Args:
        arch_path: Path to architecture (file or directory)
        
    Returns:
        'separated' if directory with model.sysml exists
        'monolithic' if single .sysml file
        'json' if .json file (legacy)
    """
    pass

def load_architecture_separated(arch_dir: Path) -> Dict:
    """
    Load architecture from separated format.
    
    Args:
        arch_dir: Directory containing model.sysml and views/
        
    Returns:
        Architecture dictionary with model and view metadata
    """
    pass

def list_views(arch_dir: Path) -> List[Dict]:
    """
    List available views for an architecture.
    
    Args:
        arch_dir: Directory containing views/
        
    Returns:
        List of view metadata dictionaries
    """
    pass
```

#### Modified Endpoints

```python
# GET /api/architectures
# - Scan for both file-based and directory-based architectures
# - Include format indicator in response

# GET /api/architecture/<path>
# - Auto-detect format
# - If separated, load model + merge all views
# - Return combined architecture dict

# NEW: GET /api/architecture/<arch_id>/views
# - List available views for architecture
# - Return view metadata (type, context, name)

# NEW: GET /api/architecture/<arch_id>/view/<view_name>
# - Load specific view with model imported
# - Return merged architecture dict with view preferences

# GET /api/diagram/bdd/<path>
# - Check for views/bdd.sysml first
# - Fall back to generating from model.sysml
# - Apply view metadata to PlantUML generation

# GET /api/diagram/ibd/<path>
# - Check for views/ibd.sysml first
# - Fall back to generating from model.sysml
# - Apply view metadata to PlantUML generation
```

## Generator Changes

### File: `lib/sysml_generator.py`

#### New Functions

```python
def generate_model_file(arch: Dict) -> str:
    """
    Generate only the model portion (no view-specific content).
    
    Args:
        arch: Architecture dictionary
        
    Returns:
        SysML v2 model file content
    """
    pass

def generate_bdd_view_file(arch: Dict) -> str:
    """
    Generate BDD view file with import and metadata.
    
    Args:
        arch: Architecture dictionary
        
    Returns:
        SysML v2 view file content for BDD
    """
    pass

def generate_ibd_view_file(arch: Dict) -> str:
    """
    Generate IBD view file with import and metadata.
    
    Args:
        arch: Architecture dictionary
        
    Returns:
        SysML v2 view file content for IBD
    """
    pass

def generate_separated_architecture(arch: Dict, output_dir: Path):
    """
    Generate full separated architecture structure.
    
    Args:
        arch: Architecture dictionary
        output_dir: Base directory (e.g., data/architectures/arch_000001)
        
    Creates:
        output_dir/model.sysml
        output_dir/views/bdd.sysml
        output_dir/views/ibd.sysml
    """
    pass
```

#### Modified Functions

```python
def generate_sysml_from_dict(arch: Dict, format: str = 'monolithic') -> str:
    """
    Modified to:
    1. Accept format parameter ('monolithic' or 'model')
    2. If 'model', exclude view-specific content
    3. Maintain backward compatibility
    """
    pass
```

## Migration Strategy

### Phase 1: Add Support (Backward Compatible)
1. Implement import parsing in `sysml_parser.py`
2. Add directory detection in `server.py`
3. Add generator functions for separated format
4. Test with one example architecture

### Phase 2: Dual Format Support
1. Keep existing monolithic files unchanged
2. Generate new architectures in separated format
3. Server handles both formats transparently
4. Update tests to cover both formats

### Phase 3: Gradual Migration (Optional)
1. Create migration script to convert monolithic → separated
2. Migrate a few architectures manually
3. Verify diagram generation works identically
4. Document migration process

### Phase 4: Full Adoption (Future)
1. Deprecate monolithic format (with warnings)
2. Update all architectures to separated format
3. Archive or remove legacy monolithic files

## Benefits

### Architectural
1. Single source of truth for model structure
2. Multiple views of same model without duplication
3. Model changes automatically reflected in all views
4. Clear separation of concerns

### Development
1. Easier to understand model structure
2. View-specific customization without polluting model
3. Better version control (separate view diffs)
4. More modular testing

### User Experience
1. Select different views for same architecture
2. Customize view rendering without changing model
3. Compare multiple views side-by-side
4. More aligned with standard SysML v2 tools

## Testing Requirements

### Unit Tests
- Parse import statements correctly
- Resolve relative import paths
- Merge imported content with local content
- Extract view metadata from comments
- Detect architecture format correctly

### Integration Tests
- Load monolithic architecture (backward compat)
- Load separated architecture with imports
- Generate BDD from separated architecture
- Generate IBD from separated architecture
- List views for architecture
- Load specific view

### Acceptance Tests
- Run `ralph/run_mvp_checks.sh` with separated architectures
- Verify diagrams render identically to monolithic format
- Verify server serves both formats

## Open Questions

1. **Should we support namespace imports?**
   - `import arch_000001::*;` vs `import "model.sysml";`
   - Decision: Start with file imports, add namespace later if needed

2. **Should we validate import cycles?**
   - Detect circular imports
   - Decision: Add basic cycle detection in Phase 2

3. **Should we cache parsed imports?**
   - Performance optimization for repeated loads
   - Decision: Add simple in-memory cache in Phase 2

4. **Should we support parameterized views?**
   - Different BDD views showing different subsets
   - Decision: Add in Phase 4 if user demand exists

## Implementation Checklist

- [ ] Design review and approval
- [ ] Update `sysml_parser.py` with import handling
- [ ] Update `server.py` with directory detection
- [ ] Update `sysml_generator.py` with separated format generation
- [ ] Create test architecture in separated format
- [ ] Add unit tests for new functions
- [ ] Add integration tests for format detection
- [ ] Update `ralph/run_mvp_checks.sh` if needed
- [ ] Document API changes in README
- [ ] Create migration script for Phase 3

## References

- SysML v2 Pilot Implementation: https://github.com/Systems-Modeling/SysML-v2-Pilot-Implementation
- Memory: `sysmlv2_syntax.md` - Official textual syntax patterns
- Memory: `sysmlv2_pilot_repo.md` - Repository structure and components
- Current codebase: `spa/sysml_parser.py`, `spa/server.py`, `lib/sysml_generator.py`
