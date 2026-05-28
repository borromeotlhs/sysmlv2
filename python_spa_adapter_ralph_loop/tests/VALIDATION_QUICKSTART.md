# SysML Validation Quick Start

## 30-Second Start

```bash
# Validate all architectures and generate report
python3 tests/validation_report.py

# Open report in browser
open validation_report.html
```

## 5-Minute Integration

Add validation to your code:

```python
from pathlib import Path
from tests.test_sysml_validation import SysMLValidator, ErrorSeverity

# Create validator
validator = SysMLValidator()

# Validate a file
issues = validator.validate_file(Path("my_arch.sysml"))

# Check results
errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
if errors:
    print(f"❌ FAIL: {len(errors)} errors")
    for e in errors[:5]:  # Show first 5
        print(f"  Line {e.line_number}: {e.message}")
else:
    print("✅ PASS: No errors")

# Optional: Check warnings too
warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
if warnings:
    print(f"⚠️  {len(warnings)} warnings (non-critical)")
```

## Common Use Cases

### 1. Validate After Generation

```python
def generate_and_validate(arch_dict):
    # Generate
    output_path = Path(f"data/architectures/{arch_dict['id']}.sysml")
    output_path.write_text(render_to_sysml(arch_dict))
    
    # Validate
    validator = SysMLValidator()
    issues = validator.validate_file(output_path)
    
    # Report
    errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
    return output_path, len(errors) == 0
```

### 2. Batch Validation

```python
from pathlib import Path
from tests.test_sysml_validation import SysMLValidator, ErrorSeverity

validator = SysMLValidator()
results = {}

for sysml_file in Path("data/architectures").glob("*.sysml"):
    issues = validator.validate_file(sysml_file)
    errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
    results[sysml_file.name] = len(errors)

# Report
failed = sum(1 for count in results.values() if count > 0)
print(f"Failed: {failed}/{len(results)} files")
```

### 3. CI/CD Pipeline

```bash
#!/bin/bash
# In your CI pipeline

python3 tests/validation_report.py
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Validation passed"
else
    echo "❌ Validation failed"
    echo "See validation_report.html for details"
fi

exit $EXIT_CODE
```

## What Gets Checked?

### ❌ Errors (Critical)
- Missing package declaration
- Unbalanced braces
- Undefined port/part references in connections
- Undefined requirement references in satisfy
- Circular composition dependencies

### ⚠️ Warnings (Style)
- Ports without type declarations
- Non-standard naming conventions
- Missing documentation

### ℹ️ Info (Optional)
- Indentation consistency
- Best practice suggestions

## Quick Fix Guide

### Untyped Port Warning

```sysml
// Before (warning)
port cmdOut;

// After (no warning)
port cmdOut : CommandPort;
```

### Missing Documentation

```sysml
// Before (info message)
package my_system {

// After (no info message)
// My System Architecture
// Domain: aerospace
package my_system {
```

### Undefined Reference Error

```sysml
// Before (error)
connect sensor.badPort to processor.dataIn;

// After (fixed) - ensure port exists
part def Sensor {
    port badPort : DataPort;  // Define the port
}
```

## Output Examples

### Console Output

```
Running validation on 202 architecture files...
======================================================================

Validating arch_000001.sysml... PASS with warnings (3 warnings)
Validating arch_000002.sysml... PASS with warnings (3 warnings)
...

======================================================================
VALIDATION SUMMARY
======================================================================

Total files: 202
  Clean: 2 (1.0%)
  Warnings only: 200 (99.0%)
  Errors: 0 (0.0%)

Top error categories:
  PortTyping: 1572
  Documentation: 202

Validation PASSED: All files are valid
```

### HTML Report

Interactive report with:
- Summary cards (clean/warnings/errors)
- Expandable file details
- Color-coded issues
- Clickable line numbers

## API Reference

### SysMLValidator Class

```python
validator = SysMLValidator()

# Validate file
issues = validator.validate_file(Path("file.sysml"))

# Issues are list of ValidationError objects
for issue in issues:
    print(issue.severity)    # ErrorSeverity.ERROR/WARNING/INFO
    print(issue.category)    # e.g., "PortTyping", "UndefinedReference"
    print(issue.message)     # Human-readable description
    print(issue.line_number) # Line number (if available)
```

### ErrorSeverity Enum

```python
from tests.test_sysml_validation import ErrorSeverity

ErrorSeverity.ERROR    # Critical - file is invalid
ErrorSeverity.WARNING  # Style issue - file is valid
ErrorSeverity.INFO     # Informational - suggestion
```

## FAQ

**Q: What if I get warnings?**
A: Warnings are non-critical. Your file is still valid SysML v2. Fix if you want cleaner output.

**Q: How long does validation take?**
A: ~50ms per file, ~10 seconds for all 202 files.

**Q: Can I customize validation rules?**
A: Yes! Add methods to `SysMLValidator` class. See tests/README.md for details.

**Q: Does this replace the official SysML v2 validator?**
A: No, this is a lightweight syntax checker. For full validation, use the official SysML v2 Pilot Implementation tools.

**Q: Can I disable specific warnings?**
A: Currently no, but you can filter results by severity or category.

## Next Steps

1. ✅ Run validation: `python3 tests/validation_report.py`
2. ✅ Review HTML report: `open validation_report.html`
3. ✅ Fix any errors (if any)
4. 🔄 Fix warnings (optional)
5. 🔄 Integrate into pipeline (optional)

## Support

- Full documentation: `tests/README.md`
- Summary report: `VALIDATION_SUMMARY.md`
- Test examples: `tests/test_validation_suite.py`
