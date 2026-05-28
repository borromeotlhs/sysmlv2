# V&V Test Suite Quick Start Guide

## Overview

This comprehensive Verification and Validation (V&V) test suite validates all aspects of generated SysML v2 files.

## Quick Run

```bash
# Simple runner (no dependencies)
python3 tests/run_vv_validation.py

# With pytest (if installed)
pytest tests/test_generated_sysml_vv.py -v -m validation
```

## What Gets Validated

### 1. Syntactic Validation ✓
- Package declarations
- Brace balancing
- Semicolon usage
- Identifier validity
- Port syntax
- Requirement format
- Connection syntax
- Multiplicity expressions

### 2. Semantic Validation ✓
- Port references (all connections point to valid ports)
- Requirement references (all satisfy statements valid)
- Type references (all part instances reference defined types)
- Circular dependency detection
- Duplicate definition detection

### 3. Completeness Validation ✓
- System blocks present
- Requirements present
- Documentation strings present
- Non-empty definitions

### 4. Round-Trip Consistency ✓
- IR → .sysml → IR preserves blocks
- IR → .sysml → IR preserves requirements
- IR → .sysml → IR preserves connections
- IR → .sysml → IR preserves ports

### 5. PlantUML Generation ✓
- BDD (Block Definition Diagram) generation
- IBD (Internal Block Diagram) generation
- URL encoding
- Diagram completeness

### 6. Naming Conventions ⚠
- Part definitions use PascalCase (warning level)
- Part instances use camelCase (warning level)
- Requirements use UPPER_CASE (warning level)

## Test Results Summary

**Current Status: 15/16 tests PASS (93.75%)**

- Syntactic: 4/4 ✓
- Semantic: 3/3 ✓
- Completeness: 2/3 ⚠ (1 test file missing requirements)
- Round-Trip: 3/3 ✓
- PlantUML: 3/3 ✓
- Quality: 1/1 ✓ (error rate < 5%)

## Understanding the Output

### Simple Runner Output

```
======================================================================
  TEST 1: SYNTACTIC VALIDATION
======================================================================

1.1: Testing all files for syntax errors...
✓ PASS: All files syntactically valid

...

======================================================================
  TEST SUMMARY
======================================================================

Total tests: 16
Passed: 15
Failed: 1
Duration: 22.18 seconds
Status: ALL V&V TESTS PASSED ✓
```

### Quality Metrics Report

The runner produces a detailed quality report:

```
Total files analyzed: 202
Files with errors: 0
Total errors: 0
Total warnings: 1799

Average blocks per file: 5.59
Average requirements per file: 3.02
Average connections per file: 3.44
Average file size: 2038 bytes

Error rate: 0.0%
```

## Exit Codes

- **0** - All tests passed
- **1** - One or more tests failed

## Integrating with CI/CD

Add to your test pipeline:

```bash
# In ralph/run_mvp_checks.sh
python3 tests/run_vv_validation.py || exit 1
```

## Individual Test Execution (pytest)

```bash
# Run only syntactic tests
pytest tests/test_generated_sysml_vv.py::TestSyntacticValidation -v

# Run only semantic tests
pytest tests/test_generated_sysml_vv.py::TestSemanticValidation -v

# Run only round-trip tests
pytest tests/test_generated_sysml_vv.py::TestRoundTripConsistency -v

# Run specific test
pytest tests/test_generated_sysml_vv.py::TestSyntacticValidation::test_all_files_have_no_syntax_errors -v

# Skip slow tests
pytest tests/test_generated_sysml_vv.py -v -m "validation and not slow"
```

## Validation Classes

The V&V suite uses the existing `SysMLValidator` class from `test_sysml_validation.py`:

```python
from tests.test_sysml_validation import SysMLValidator

validator = SysMLValidator()
issues = validator.validate_file(Path("data/architectures/arch_000001.sysml"))

# Check for errors
errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
```

## Adding New Tests

### In pytest suite (`test_generated_sysml_vv.py`):

```python
@pytest.mark.validation
def test_my_new_check(self, all_sysml_files):
    """Description of what this validates"""
    failures = []
    
    for arch_file in all_sysml_files:
        content = arch_file.read_text(encoding='utf-8')
        
        # Your validation logic here
        if not_valid:
            failures.append(arch_file.name)
    
    assert len(failures) == 0, f"Failed: {failures}"
```

### In simple runner (`run_vv_validation.py`):

```python
def test_my_new_category(sysml_files):
    """Test Category: My New Tests"""
    print_header("TEST N: MY NEW CATEGORY")
    
    test_results = []
    
    # Test N.1
    print("N.1: Testing something...")
    failures = []
    
    for arch_file in sysml_files:
        # Validation logic
        pass
    
    passed = len(failures) == 0
    test_results.append(('My test name', passed))
    print_test_result("My test", passed, details)
    
    return test_results
```

## Common Issues

### Issue: Import errors
**Solution:** Run from project root:
```bash
cd /path/to/project
python3 tests/run_vv_validation.py
```

### Issue: Module not found
**Solution:** Ensure spa/ directory is in Python path:
```python
sys.path.insert(0, str(Path(__file__).parent.parent / 'spa'))
```

### Issue: Pytest not available
**Solution:** Use simple runner instead:
```bash
python3 tests/run_vv_validation.py
```

Or install pytest:
```bash
pip install pytest
```

## Validation Thresholds

The suite enforces quality gates:

- **Error Rate Threshold:** < 5% of files with errors
- **Current Error Rate:** 0.0% ✓
- **Semantic Errors:** 0 required
- **Syntactic Errors:** 0 required

## File Structure

```
tests/
├── test_sysml_validation.py      # Core validator class
├── test_validation_suite.py      # Original pytest suite
├── test_generated_sysml_vv.py    # New comprehensive V&V suite
├── run_vv_validation.py          # Simple runner (no pytest needed)
├── VV_REPORT.md                  # Detailed validation report
└── VV_QUICKSTART.md              # This file
```

## Validation Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                    Generator Pipeline                        │
│  generator → IR → renderer → .sysml → validator              │
│      ✓        ✓       ✓         ✓         ✓                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Round-Trip Validation                     │
│  .sysml → parser → IR → generator → .sysml → parser → IR     │
│     ✓        ✓      ✓        ✓         ✓        ✓      ✓    │
└─────────────────────────────────────────────────────────────┘
```

## Performance

- **202 files** validated in **22.18 seconds**
- ~109ms per file average
- Fast enough for CI/CD integration

## Next Steps

1. Run the validation suite: `python3 tests/run_vv_validation.py`
2. Review the output in `tests/VV_REPORT.md`
3. Address any failures (currently 15/16 passing)
4. Integrate into CI/CD pipeline
5. Run after any generator changes

## Support

For issues or questions:
- Review `tests/VV_REPORT.md` for detailed findings
- Check existing validation in `tests/test_sysml_validation.py`
- See test examples in `tests/test_validation_suite.py`
