# Test Suite Documentation

This directory contains the unified test framework for the SysML v2 Python SPA Adapter.

## Test Organization

Tests are organized into three categories:

### Parser Tests (`@pytest.mark.parser`)
- **test_parser.py**: Core SysML parsing functionality
- **test_import_parsing.py**: Import statement parsing and file resolution
- Test parsing of blocks, ports, connectors, requirements, and relationships

### Validation Tests (`@pytest.mark.validation`)
- **test_sysml_validation.py**: Core SysML v2 syntax and semantic validator
- **test_validation_suite.py**: Pytest test cases for validation rules
- **validation_report.py**: Script to generate HTML validation reports
- **test_backward_compat.py**: Backward compatibility with monolithic .sysml files
- Test that existing architectures continue to parse correctly
- Validate new features don't break existing functionality

### Integration Tests (`@pytest.mark.integration`)
- **test_integration.py**: End-to-end workflows
- Test architecture roundtrips
- Test pair file loading and validation
- Test complete parsing pipelines

## SysML Validation Suite

The validation suite ensures generated `.sysml` files conform to SysML v2 syntax rules and best practices.

### Quick Validation

Run validation on all architectures:

```bash
python3 tests/validation_report.py
```

This will:
- Validate all `.sysml` files in `data/architectures/`
- Print summary to console
- Generate `validation_report.html` with detailed results
- Exit with code 1 if any errors found, 0 if all pass

### Validation Levels

1. **Syntax Validation** - Package structure, braces, semicolons, port syntax, requirement format
2. **Semantic Validation** - Port references, requirement references, circular dependencies
3. **Style Validation** - Naming conventions, documentation, indentation

### Using the Validator

```python
from tests.test_sysml_validation import SysMLValidator, ErrorSeverity

validator = SysMLValidator()
issues = validator.validate_file(Path("my_architecture.sysml"))

errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
```

### Current Status (202 files)

- **Clean**: 2 files (1.0%)
- **Warnings Only**: 200 files (99.0%)
- **Errors**: 0 files (0.0%)

Common warnings: untyped ports, missing documentation, naming conventions.

See HTML report for detailed breakdown.

## Installation

Install test dependencies:

```bash
pip install -r requirements-test.txt
```

Or install specific packages:

```bash
pip install pytest pytest-cov pytest-timeout pytest-xdist
```

## Running Tests

### Run all tests
```bash
python tests/run_tests.py
```

### Run specific suite
```bash
python tests/run_tests.py --suite parser
python tests/run_tests.py --suite validation
python tests/run_tests.py --suite integration
```

### Run with coverage
```bash
python tests/run_tests.py --coverage
python tests/run_tests.py --html  # Generate HTML report
```

### Run in parallel
```bash
python tests/run_tests.py --parallel
```

### Run specific test file
```bash
pytest tests/test_parser.py
```

### Run specific test function
```bash
pytest tests/test_parser.py::test_parser_blocks
```

### Run with verbose output
```bash
python tests/run_tests.py --verbose
```

## Using pytest directly

You can also use pytest directly for more control:

```bash
# Run all tests
pytest

# Run specific marker
pytest -m parser
pytest -m validation
pytest -m integration

# Run with coverage
pytest --cov=spa --cov=scripts --cov-report=html

# Run in parallel
pytest -n auto

# Run with specific verbosity
pytest -vv

# Run and stop on first failure
pytest -x

# Run last failed tests
pytest --lf

# Show local variables in tracebacks
pytest -l
```

## Writing New Tests

### 1. Create test file in `tests/` directory
```python
#!/usr/bin/env python3
"""Description of test module"""
import pytest
from sysml_parser import parse_sysml_to_json

@pytest.mark.parser  # or @pytest.mark.validation or @pytest.mark.integration
def test_my_feature():
    """Test description"""
    # Test code here
    assert result == expected
```

### 2. Use fixtures from conftest.py
```python
def test_with_fixture(sample_sysml_content, temp_sysml_file):
    """Tests can use shared fixtures"""
    result = parse_sysml_to_json(sample_sysml_content)
    # ...
```

### 3. Mark slow tests
```python
@pytest.mark.slow
def test_expensive_operation():
    """This test takes a long time"""
    # ...
```

### 4. Parametrize tests
```python
@pytest.mark.parametrize("input,expected", [
    ("case1", "result1"),
    ("case2", "result2"),
])
def test_multiple_cases(input, expected):
    assert process(input) == expected
```

## Available Fixtures

See `tests/conftest.py` for all available fixtures:

- `sample_sysml_content`: Sample SysML content string
- `sample_architecture_dict`: Sample architecture as dict (JSON IR)
- `temp_sysml_file`: Temporary .sysml file
- `temp_json_file`: Temporary JSON architecture file
- `architecture_files_dir`: Path to data/architectures
- `sample_pairs_file`: Path to sample_pairs.json
- `temp_output_dir`: Temporary output directory
- `import_test_files`: Test files for import testing

## CI/CD Integration

Tests run automatically on:
- Push to any branch
- Pull request creation/update
- Manual workflow dispatch

See `.github/workflows/tests.yml` for configuration.

### Exit Codes
- `0`: All tests passed
- `1`: Tests failed
- `5`: No tests collected
- `130`: Tests interrupted by user

## Coverage Reports

Coverage reports show which code is tested:

```bash
# Terminal report
python tests/run_tests.py --coverage

# HTML report
python tests/run_tests.py --html
open htmlcov/index.html
```

Coverage reports are saved to:
- `htmlcov/`: HTML coverage report
- `.coverage`: Coverage data file

## Test Markers

Configure test markers in `pytest.ini`:

- `@pytest.mark.parser`: Parser tests
- `@pytest.mark.validation`: Validation tests
- `@pytest.mark.integration`: Integration tests
- `@pytest.mark.slow`: Slow-running tests
- `@pytest.mark.requires_server`: Tests needing server

Run specific markers:
```bash
pytest -m "parser and not slow"
pytest -m "validation or integration"
```

## Troubleshooting

### Import errors
Make sure you're in the project root when running tests:
```bash
cd /path/to/python_spa_adapter_ralph_loop
python tests/run_tests.py
```

### Fixtures not found
Check that `conftest.py` is in the tests directory and paths are correct.

### Tests skipped
Some tests skip if test data is not available. This is normal for:
- Import parsing tests (need test_import_example directory)
- Architecture tests (need data/architectures directory)

### Coverage not working
Install coverage:
```bash
pip install pytest-cov
```

## Best Practices

1. **One assertion per test** (when practical)
2. **Use descriptive test names** (test_parser_blocks, not test1)
3. **Use fixtures for common setup** (avoid duplication)
4. **Mark tests appropriately** (parser/validation/integration)
5. **Test edge cases** (empty input, invalid input, etc.)
6. **Keep tests fast** (mock external dependencies)
7. **Use parametrize for similar cases** (avoid copy-paste)
8. **Document test intent** (use clear docstrings)

## Resources

- [pytest documentation](https://docs.pytest.org/)
- [pytest-cov documentation](https://pytest-cov.readthedocs.io/)
- [pytest-xdist documentation](https://pytest-xdist.readthedocs.io/)
