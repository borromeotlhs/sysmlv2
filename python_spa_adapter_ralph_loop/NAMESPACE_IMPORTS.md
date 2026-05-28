# SysML v2 Namespace Import Implementation

## Overview

This document describes the implementation of SysML v2 namespace import patterns in the parser (`spa/sysml_parser.py`).

## Supported Import Patterns

The parser now supports three namespace import patterns as defined in the SysML v2 specification:

### 1. Direct Import (`::*`)

```sysml
import PackageName::*;
```

**Behavior**: Imports only direct public members of the package.

**Example**:
```sysml
package Systems {
    public part def PowerSystem {
        part battery : Battery;
    }
    public part def CoolingSystem {
        part radiator : Radiator;
    }
    part def Battery { }
}

package Application {
    import Systems::*;  // Makes PowerSystem and CoolingSystem visible
                        // Battery is NOT visible (it's nested)
}
```

**Visibility**: `PowerSystem`, `CoolingSystem`

### 2. Recursive Import (`::**`)

```sysml
import PackageName::**;
```

**Behavior**: Imports all nested elements recursively, but NOT the direct members.

**Example**:
```sysml
package Systems {
    public part def PowerSystem {
        part battery : Battery;
    }
    part def Battery {
        part cell : Cell[4];
    }
    part def Cell { }
}

package Application {
    import Systems::**;  // Makes Battery and Cell visible
                         // PowerSystem is NOT visible (it's a direct member)
}
```

**Visibility**: `Battery`, `Cell`

### 3. Hybrid Import (`::*::**`)

```sysml
import PackageName::*::**;
```

**Behavior**: Imports both direct members AND all nested elements.

**Example**:
```sysml
package Systems {
    public part def PowerSystem {
        part battery : Battery;
    }
    part def Battery {
        part cell : Cell[4];
    }
}

package Application {
    import Systems::*::**;  // Makes PowerSystem, Battery, and Cell visible
}
```

**Visibility**: `PowerSystem`, `Battery`, `Cell`

## API Functions

### `parse_namespace_import(line: str) -> Optional[Dict]`

Parses a namespace import statement and identifies the pattern.

**Returns**:
- `{'package': str, 'pattern': str}` where pattern is 'direct', 'recursive', or 'hybrid'
- `None` if not a namespace import

**Examples**:
```python
parse_namespace_import("import Systems::*;")
# Returns: {'package': 'Systems', 'pattern': 'direct'}

parse_namespace_import("import Systems::**;")
# Returns: {'package': 'Systems', 'pattern': 'recursive'}

parse_namespace_import("import Systems::*::**;")
# Returns: {'package': 'Systems', 'pattern': 'hybrid'}
```

### `resolve_namespace_import(package_name: str, pattern: str, arch: Dict) -> Set[str]`

Resolves a namespace import to determine which elements become visible.

**Parameters**:
- `package_name`: Name of package being imported from
- `pattern`: Import pattern ('direct', 'recursive', or 'hybrid')
- `arch`: Architecture dictionary containing blocks, compositions, and exposed_elements

**Returns**: Set of element names that should be visible after import

**Algorithm**:
1. Extract direct public members from `arch['exposed_elements']`
2. Build parent-child relationship map from `arch['compositions']`
3. For each pattern:
   - **direct**: Return only direct members
   - **recursive**: Return all nested children of direct members
   - **hybrid**: Return direct members + all nested children

### `parse_sysml_to_json(sysml_content: str, file_path: Optional[Path] = None) -> Dict`

Enhanced to track namespace imports in parsed architecture.

**New Fields in Result**:
- `namespace_imports`: List of namespace import dictionaries
- `exposed_elements`: Merged set of locally exposed + imported elements

## Integration

The namespace import tracking is integrated into the main parser pipeline:

1. During parsing, each `import` statement is checked
2. If it's a namespace import, it's added to the `namespace_imports` list
3. The import is resolved against the local architecture (for validation)
4. Resolved elements are merged into `exposed_elements`

## Testing

Three test files are provided:

### `test_namespace_imports.py`

Comprehensive unit tests covering:
- Parsing of all three import patterns
- Resolution logic for each pattern
- Integration with full parsing pipeline
- Tracking of namespace imports in results

**Run**: `python3 test_namespace_imports.py`

### `test_namespace_resolution.py`

Demonstration script showing how namespace imports work with actual package architectures.

**Run**: `python3 test_namespace_resolution.py`

### `example_namespace_imports.sysml`

Example SysML file demonstrating all three patterns with realistic use cases.

## Implementation Notes

### Current Scope

The implementation provides:
1. **Parsing**: Recognizes all three namespace import patterns
2. **Tracking**: Records imports in parsed architecture
3. **Resolution**: Resolves imports when architecture is available

### Future Enhancements

For full cross-package resolution in a multi-file system, you would need:
1. Package registry/cache to store parsed architectures
2. Import resolution phase after all files are parsed
3. Dependency graph to handle circular imports
4. Qualified name resolution for ambiguous references

### Backward Compatibility

The implementation is fully backward compatible:
- Existing file-based imports (`import "file.sysml"`) continue to work
- No namespace imports results in empty `namespace_imports` list
- Existing tests continue to pass

## Usage Examples

### Basic Usage

```python
from spa.sysml_parser import parse_sysml_to_json

sysml_content = """
package Application {
    import Systems::*;
    
    public part def Vehicle {
        part power : PowerSystem;
    }
}
"""

result = parse_sysml_to_json(sysml_content)

# Check namespace imports
for imp in result['namespace_imports']:
    print(f"Imports from {imp['package']} using {imp['pattern']} pattern")
```

### Cross-Package Resolution

```python
from spa.sysml_parser import parse_sysml_to_json, resolve_namespace_import

# Parse source package
systems_arch = parse_sysml_to_json(systems_sysml)

# Parse consuming package
app_arch = parse_sysml_to_json(app_sysml)

# Resolve imports
for imp in app_arch['namespace_imports']:
    visible = resolve_namespace_import(
        imp['package'],
        imp['pattern'],
        systems_arch  # Pass source package architecture
    )
    print(f"Visible from {imp['package']}: {visible}")
```

## References

- SysML v2 Language Specification
- `/mnt/c/Users/borrth/offline/_now/LEAD/Claude Code/sysmlv2/python_spa_adapter_ralph_loop/spa/sysml_parser.py`
- Project CLAUDE.md for pipeline architecture

## Status

✅ Implementation complete and tested
✅ All MVP checks passing
✅ Backward compatible with existing code
