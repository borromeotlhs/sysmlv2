# Comprehensive Test Suite for SysML v2 Pipeline

This directory contains a comprehensive test suite covering all aspects of the SysML v2 pipeline.

## Test Files Created

### 1. test_validation_comprehensive.py
**Coverage**: Validation of SysML v2 textual syntax

**Test Categories**:
- Valid Syntax Tests (6 tests)
  - Minimal package with public keyword
  - Packages with namespace imports
  - Typed ports
  - Requirements with satisfy relationships
  - Connection statements
  - Nested structures

- Invalid Syntax Tests (6 tests)
  - Missing package declaration
  - Unbalanced braces
  - Missing semicolons
  - Malformed requirements
  - Invalid multiplicity expressions
  - Invalid connection syntax

- Edge Case Tests (5 tests)
  - Empty packages
  - Deeply nested structures
  - Circular composition detection
  - Many connections
  - Unicode identifiers

- Semantic Validation Tests (5 tests)
  - Undefined part types
  - Undefined ports in connections
  - Undefined requirements in satisfy
  - Duplicate definitions
  - Port type consistency

- Style Validation Tests (5 tests)
  - PascalCase for part definitions
  - camelCase for part instances
  - UPPER_CASE for requirements
  - Untyped port warnings
  - Empty requirement text

- Integration Tests (2 tests)
  - Complete valid architecture
  - Mixed issues architecture

**Total**: ~29 test cases

### 2. test_generator_comprehensive.py
**Coverage**: SysML v2 generation from JSON IR

**Test Categories**:
- Utility Function Tests (9 tests)
  - Name sanitization (basic, special chars, unicode)
  - Attribute generation (processor, sensor, power, comm, default)

- Basic Generation Tests (3 tests)
  - Minimal architecture
  - Multiple blocks
  - Package name sanitization

- Port Generation Tests (3 tests)
  - Typed ports
  - Untyped ports
  - Port type deduplication

- Public Keyword Tests (4 tests)
  - Public on requirements
  - Public on port definitions
  - Public on part definitions
  - Public on system instances

- Import Statement Tests (2 tests)
  - ScalarValues import
  - Import placement

- Connection Generation Tests (2 tests)
  - Basic connections
  - Instance name sanitization

- Requirement Generation Tests (3 tests)
  - Requirement definitions
  - Satisfy relationships
  - Text escaping

- Edge Case Tests (6 tests)
  - Empty architecture
  - No ports
  - No requirements
  - No connections
  - Complete architecture

**Total**: ~32 test cases

### 3. test_parser_comprehensive.py
**Coverage**: SysML v2 parsing and import resolution

**Test Categories**:
- Namespace Import Tests (5 tests)
  - Import all pattern (Package::*)
  - Import specific pattern (Package::Element)
  - Import alias pattern (Package::Element as Alias)
  - Multiple import types
  - File vs namespace import detection

- Exposed Elements Tests (5 tests)
  - Public part definitions
  - Public requirements
  - Parser includes exposed_elements
  - No public keywords (backward compat)
  - Mixed public/private

- File Import Tests (4 tests)
  - Has imports detection
  - Simple file import
  - Missing file handling
  - Relative path imports
  - Circular import detection

- Merge Architectures Tests (3 tests)
  - Block merging
  - Model ID preservation
  - Port merging
  - Requirement merging

- Round-Trip Tests (5 tests)
  - Minimal architecture
  - With ports
  - With connections
  - With requirements
  - Complete architecture

- Parsing Edge Cases Tests (5 tests)
  - Empty content
  - Whitespace only
  - Inline comments
  - Multi-line strings
  - Mixed line endings
  - Parse consistency

**Total**: ~27 test cases

### 4. test_renderer_comprehensive.py
**Coverage**: PlantUML diagram generation with view filtering

**Test Categories**:
- BDD Filtering Tests (5 tests)
  - All public components
  - Mixed visibility
  - No public keywords (backward compat)
  - Composition relationships
  - Port display

- IBD Filtering Tests (4 tests)
  - All public components
  - Mixed visibility
  - No public keywords
  - Connection filtering
  - Port display

- PlantUML Generation Tests (5 tests)
  - Basic structure
  - Title inclusion
  - Styling directives
  - BDD format
  - IBD format

- Edge Case Tests (5 tests)
  - Empty architecture
  - No connections
  - No ports
  - Many components
  - Deep nesting

- Integration Tests (2 tests)
  - Round-trip render
  - Filtered render

**Total**: ~21 test cases

### 5. test_integration_comprehensive.py
**Coverage**: End-to-end pipeline integration

**Test Categories**:
- Full Pipeline Tests (4 tests)
  - IR → SysML → diagrams
  - Pipeline with validation
  - Data preservation
  - Round-trip consistency

- Cross-Package Import Tests (3 tests)
  - Import base model
  - Import chain
  - Mix file and namespace imports

- Filtered View Tests (2 tests)
  - Complete system with filtering
  - View respects exposed elements

- Error Handling Tests (5 tests)
  - Parse invalid SysML
  - Validation catches errors
  - Render malformed files
  - Missing requirements
  - Undefined ports

- End-to-End Workflow Tests (3 tests)
  - New architecture workflow
  - Modify architecture workflow
  - Architecture refactoring workflow

**Total**: ~17 test cases

## Total Test Coverage

- **Total Test Files**: 5
- **Total Test Cases**: ~126 tests
- **Coverage Areas**: 
  - Validation (syntax, semantic, style)
  - Generation (IR → SysML)
  - Parsing (SysML → IR)
  - Rendering (SysML → PlantUML)
  - Integration (full pipeline)

## Running the Tests

### Run all comprehensive tests:
```bash
bash tests/run_comprehensive_tests.sh
```

### Run individual test files:
```bash
pytest tests/test_validation_comprehensive.py -v
pytest tests/test_generator_comprehensive.py -v
pytest tests/test_parser_comprehensive.py -v
pytest tests/test_renderer_comprehensive.py -v
pytest tests/test_integration_comprehensive.py -v
```

### Run with coverage:
```bash
pytest tests/test_*_comprehensive.py -v --cov=lib --cov=spa --cov-report=term-missing --cov-report=html
```

### Run specific test class:
```bash
pytest tests/test_validation_comprehensive.py::TestValidSyntax -v
```

### Run specific test:
```bash
pytest tests/test_validation_comprehensive.py::TestValidSyntax::test_valid_minimal_package -v
```

## Test Organization

Each test file follows this structure:

1. **Imports and Fixtures**: Common setup code
2. **Test Classes**: Organized by category
3. **Test Methods**: Individual test cases with clear names
4. **Assertions**: Verify expected behavior
5. **Documentation**: Docstrings explain what each test validates

## Key Testing Patterns

### Fixture Usage
```python
@pytest.fixture
def validator():
    """Create fresh validator for each test"""
    return SysMLValidator()

@pytest.fixture
def tmp_sysml(tmp_path):
    """Helper to create temp .sysml files"""
    def _create(content: str, name: str = 'test.sysml') -> Path:
        file_path = tmp_path / name
        file_path.write_text(content, encoding='utf-8')
        return file_path
    return _create
```

### Parameterized Tests
Tests can be parameterized for multiple scenarios:
```python
@pytest.mark.parametrize("component_name,expected_attr", [
    ("MissionComputer", "processingPower"),
    ("SensorPayload", "dataRate"),
    ("PowerSupply", "voltage")
])
def test_attributes(component_name, expected_attr):
    attrs = get_attributes_for_component(component_name)
    assert expected_attr in ' '.join(attrs)
```

### Test Markers
```python
@pytest.mark.validation  # Validation tests
@pytest.mark.generator   # Generator tests
@pytest.mark.parser      # Parser tests
@pytest.mark.renderer    # Renderer tests
@pytest.mark.integration # Integration tests
@pytest.mark.slow        # Slow-running tests
```

## Expected Coverage

Target coverage by component:

- **lib/sysml_generator.py**: 80%+ coverage
- **spa/sysml_parser.py**: 80%+ coverage
- **spa/server.py** (rendering): 70%+ coverage
- **tests/test_sysml_validation.py**: 75%+ coverage

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# .github/workflows/test.yml
- name: Run comprehensive tests
  run: |
    pytest tests/test_*_comprehensive.py -v --cov=lib --cov=spa
```

## Test Data

Tests use:
- **In-memory fixtures**: Most tests use dynamically created test data
- **Temporary files**: `tmp_path` fixture for file-based tests
- **Sample architectures**: Realistic architecture structures

## Troubleshooting

### Import Errors
Ensure the project is on PYTHONPATH:
```bash
export PYTHONPATH=/mnt/c/Users/borrth/offline/_now/LEAD/Claude\ Code/sysmlv2/python_spa_adapter_ralph_loop:$PYTHONPATH
```

### Missing Dependencies
Install test requirements:
```bash
pip install -r requirements-test.txt
```

### Slow Tests
Skip slow tests:
```bash
pytest tests/ -v -m "not slow"
```

## Contributing

When adding new tests:

1. Follow the existing structure
2. Add descriptive docstrings
3. Use appropriate test markers
4. Verify tests pass locally
5. Update this documentation

## Coverage Reports

After running tests with coverage, view the HTML report:
```bash
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
```

## References

- [pytest documentation](https://docs.pytest.org/)
- [pytest-cov documentation](https://pytest-cov.readthedocs.io/)
- [SysML v2 Specification](https://github.com/Systems-Modeling/SysML-v2-Release)
