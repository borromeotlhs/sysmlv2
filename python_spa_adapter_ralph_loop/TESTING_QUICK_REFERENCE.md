# Testing Quick Reference

## 🚀 Quick Start

### Run All Tests (No Dependencies Required)
```bash
# Basic tests
python3 tests/run_tests_simple.py

# V&V validation
python3 tests/run_vv_validation.py

# SPA integration
python3 tests/test_spa_integration_simple.py

# Full MVP acceptance
bash ralph/run_mvp_checks.sh
```

### Run All Tests (With Pytest)
```bash
# Install dependencies first
pip install -r requirements-test.txt

# Run everything
python3 tests/run_tests.py

# With coverage
python3 tests/run_tests.py --coverage --html
```

## 📋 Test Suites

| Suite | Command | Tests | Purpose |
|-------|---------|-------|---------|
| **Parser** | `python3 tests/run_tests.py --suite parser` | 48 | SysML parser functionality |
| **Validation** | `python3 tests/run_tests.py --suite validation` | 16 | Generated SysML quality |
| **Integration** | `python3 tests/run_tests.py --suite integration` | 43 | SPA API & endpoints |
| **Simple** | `python3 tests/run_tests_simple.py` | 5 | Basic smoke tests |

## 🎯 Common Tasks

### Test a Specific File
```bash
# With pytest
python3 -m pytest tests/test_parser.py -v

# Specific test
python3 -m pytest tests/test_parser.py::test_basic_parsing -v
```

### Run Fast Tests Only
```bash
# Skip slow tests
python3 -m pytest -m "not slow"
```

### Generate Coverage Report
```bash
python3 tests/run_tests.py --coverage --html
open htmlcov/index.html  # View in browser
```

### Run Tests in Parallel
```bash
python3 tests/run_tests.py --parallel
```

## 🔍 Test Markers

Use markers to run specific test categories:

```bash
# Parser tests only
python3 -m pytest -m parser

# Validation tests only
python3 -m pytest -m validation

# Integration tests only
python3 -m pytest -m integration

# Exclude slow tests
python3 -m pytest -m "not slow"
```

## 📊 Quality Checks

### Check Generated SysML Quality
```bash
python3 tests/run_vv_validation.py

# Produces quality metrics:
# - Syntax validation
# - Semantic validation
# - Completeness checks
# - Round-trip consistency
# - PlantUML generation
```

### Validate Specific Architecture
```python
from tests.test_sysml_validation import SysMLValidator

validator = SysMLValidator()
issues = validator.validate_file("data/architectures/arch_000001.sysml")

for issue in issues:
    print(f"{issue.severity}: {issue.message}")
```

## 🛠️ Development Workflow

### Before Committing
```bash
# 1. Run quick tests
python3 tests/run_tests_simple.py

# 2. Run full validation
python3 tests/run_vv_validation.py

# 3. Run MVP checks
bash ralph/run_mvp_checks.sh
```

### After Parser Changes
```bash
# Run parser tests
python3 tests/run_tests.py --suite parser

# Test with real files
python3 -c "
from spa.sysml_parser import parse_sysml_file
result = parse_sysml_file('data/architectures/arch_000001.sysml')
print(f'Blocks: {len(result.get(\"blocks\", []))}')
"
```

### After Generator Changes
```bash
# Regenerate samples
python3 scripts/generate_sample_architectures.py

# Validate all generated files
python3 tests/run_vv_validation.py

# Check specific file
python3 -c "
from tests.test_sysml_validation import SysMLValidator
v = SysMLValidator()
issues = v.validate_file('data/architectures/arch_000001.sysml')
print(f'Errors: {sum(1 for i in issues if i.severity == \"ERROR\")}')
"
```

### After SPA Changes
```bash
# Run integration tests
python3 tests/test_spa_integration_simple.py

# Or with pytest
python3 tests/run_tests.py --suite integration

# Test server manually
python3 spa/server.py &
curl http://localhost:8765/api/health
curl http://localhost:8765/api/architectures
```

## 📁 Test File Locations

```
tests/
├── conftest.py                          # Pytest fixtures
├── run_tests.py                         # Unified pytest runner
├── run_tests_simple.py                  # No-dependency runner
├── run_vv_validation.py                 # V&V standalone runner
│
├── test_parser.py                       # Parser tests (48)
├── test_generated_sysml_vv.py          # V&V pytest suite (16)
├── test_spa_integration.py             # SPA pytest tests (50+)
├── test_spa_integration_simple.py      # SPA standalone (43)
│
├── test_sysml_validation.py            # Validator implementation
├── test_validation_suite.py            # Validation pytest suite
├── test_integration.py                 # Original integration tests
│
└── test_data/                          # Test fixtures
```

## 🐛 Debugging Failed Tests

### Verbose Output
```bash
# With pytest
python3 -m pytest tests/test_parser.py -vv

# With unittest runner
python3 tests/run_tests_simple.py
```

### Run Single Test
```bash
python3 -m pytest tests/test_parser.py::test_basic_parsing -vv
```

### Debug with Print Statements
```python
# Add to test file
import json
print(json.dumps(result, indent=2))
```

### Check Test Fixtures
```bash
ls -la tests/test_data/
cat tests/test_data/simple_architecture.sysml
```

## 🔧 Test Utilities

### Parse SysML from Python
```python
from spa.sysml_parser import parse_sysml_file

# Parse file
result = parse_sysml_file("path/to/file.sysml")

# Access data
print(f"System: {result['system_name']}")
print(f"Blocks: {len(result['blocks'])}")
print(f"Requirements: {len(result['requirements'])}")
```

### Validate SysML from Python
```python
from tests.test_sysml_validation import SysMLValidator

validator = SysMLValidator()

# Validate file
issues = validator.validate_file("path/to/file.sysml")

# Filter by severity
errors = [i for i in issues if i.severity == "ERROR"]
warnings = [i for i in issues if i.severity == "WARNING"]

print(f"Errors: {len(errors)}, Warnings: {len(warnings)}")
```

### Generate PlantUML from Python
```python
import sys
sys.path.insert(0, 'scripts')
from generate_diagrams import generate_bdd, generate_ibd

# Generate diagrams
bdd = generate_bdd("path/to/arch.sysml")
ibd = generate_ibd("path/to/arch.sysml")

print(f"BDD: {len(bdd)} chars")
print(f"IBD: {len(ibd)} chars")
```

## 📈 Performance Benchmarks

Expected test durations (on reference hardware):

| Test Suite | Duration | Notes |
|------------|----------|-------|
| Simple runner | 0.1s | 5 basic tests |
| Parser suite | 2-5s | 48 tests including edge cases |
| V&V validation | 20-25s | 202 files analyzed |
| SPA integration | 5-10s | Server startup + 43 tests |
| Full MVP checks | 30-45s | Complete pipeline |

## 🚨 Troubleshooting

### "No module named pytest"
```bash
# Solution 1: Install pytest
pip install -r requirements-test.txt

# Solution 2: Use standalone runners
python3 tests/run_tests_simple.py
python3 tests/test_spa_integration_simple.py
```

### "Address already in use" (SPA tests)
```bash
# Kill existing server
pkill -f "spa/server.py"

# Or use different port
APP_PORT=8766 python3 tests/test_spa_integration_simple.py
```

### Tests hang or timeout
```bash
# Increase timeout in test file or:
TIMEOUT=300 python3 tests/test_spa_integration_simple.py
```

### Import errors
```bash
# Ensure you're in project root
cd /path/to/python_spa_adapter_ralph_loop

# Or set PYTHONPATH
export PYTHONPATH=$PWD:$PYTHONPATH
```

## 📚 Documentation

- **Test Suite Summary:** `TEST_SUITE_SUMMARY.md`
- **Parser Tests:** `tests/ENHANCED_TESTS_REPORT.md`
- **V&V Tests:** `tests/VV_REPORT.md`, `tests/VV_QUICKSTART.md`
- **SPA Tests:** `tests/SPA_INTEGRATION_TEST_REPORT.md`
- **Test README:** `tests/README.md`

## ✅ Success Indicators

Healthy test run should show:
- ✅ 0 syntax errors in generated SysML
- ✅ 0 semantic errors in generated SysML
- ✅ 100% parser test pass rate
- ✅ 93%+ V&V test pass rate
- ✅ 100% SPA test pass rate
- ✅ MVP checks pass

## 🎓 Learning Resources

### Understanding Test Structure
```python
# tests/test_parser.py
@pytest.mark.parser  # Marker for test suite selection
def test_basic_parsing(temp_dir):  # Fixture injection
    """Test docstring"""  # Always document what test does
    # Arrange
    content = "..."
    
    # Act
    result = parse_sysml_content(content)
    
    # Assert
    assert result['system_name'] == "TestSystem"
```

### Writing New Tests
1. Add test function to appropriate file
2. Use fixtures from `conftest.py`
3. Add appropriate pytest marker
4. Write clear docstring
5. Follow AAA pattern (Arrange, Act, Assert)

### Example Test
```python
import pytest
from spa.sysml_parser import parse_sysml_content

@pytest.mark.parser
def test_my_new_feature(temp_dir):
    """Test description of what this validates"""
    # Arrange
    content = """
    package TestPkg {
        // Your test SysML
    }
    """
    
    # Act
    result = parse_sysml_content(content)
    
    # Assert
    assert 'blocks' in result
    assert len(result['blocks']) > 0
```

---

**Need help?** See full documentation in `TEST_SUITE_SUMMARY.md` or test-specific READMEs in `tests/` directory.
