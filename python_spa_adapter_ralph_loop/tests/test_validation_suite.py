"""
Pytest test suite for SysML validation

Run with: pytest tests/test_validation_suite.py -v
"""
import pytest
from pathlib import Path
from tests.test_sysml_validation import SysMLValidator, ErrorSeverity


@pytest.fixture
def validator():
    """Create a validator instance"""
    return SysMLValidator()


@pytest.fixture
def architectures_dir():
    """Get the architectures directory"""
    return Path(__file__).parent.parent / 'data' / 'architectures'


@pytest.fixture
def sample_architectures(architectures_dir):
    """Get list of sample architecture files"""
    return sorted(architectures_dir.glob('*.sysml'))[:10]  # Test first 10


class TestSyntaxValidation:
    """Test syntax validation rules"""

    def test_package_declaration(self, validator, tmp_path):
        """Test package declaration validation"""

        # Valid package
        valid = tmp_path / "valid.sysml"
        valid.write_text("package test_pkg {\n}\n")
        issues = validator.validate_file(valid)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert len(errors) == 0

        # Missing package
        invalid = tmp_path / "invalid.sysml"
        invalid.write_text("part def Block {}")
        validator2 = SysMLValidator()
        issues = validator2.validate_file(invalid)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any("package declaration" in i.message.lower() for i in errors)

    def test_brace_balance(self, validator, tmp_path):
        """Test brace balance checking"""

        # Unbalanced braces
        invalid = tmp_path / "unbalanced.sysml"
        invalid.write_text("package test {\n  part def Block {\n}\n")
        issues = validator.validate_file(invalid)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        assert any("brace" in i.message.lower() for i in errors)

    def test_port_typing(self, validator, tmp_path):
        """Test port typing validation"""

        content = """
package test {
    part def Component {
        port untypedPort;
        port typedPort : DataPort;
    }
}
"""
        test_file = tmp_path / "ports.sysml"
        test_file.write_text(content)
        issues = validator.validate_file(test_file)

        # Should have warning for untyped port
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING
                   and "untypedPort" in i.message]
        assert len(warnings) > 0

    def test_requirement_format(self, validator, tmp_path):
        """Test requirement format validation"""

        # Missing doc statement
        invalid = tmp_path / "req_invalid.sysml"
        invalid.write_text('package test {\n  requirement REQ_001 {\n  }\n}\n')
        issues = validator.validate_file(invalid)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR
                 and "doc" in i.message.lower()]
        assert len(errors) > 0

        # Valid requirement
        valid = tmp_path / "req_valid.sysml"
        valid.write_text('package test {\n  requirement REQ_001 {\n    doc "text"\n  }\n}\n')
        validator2 = SysMLValidator()
        issues = validator2.validate_file(valid)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        req_errors = [e for e in errors if "requirement" in e.category.lower()]
        assert len(req_errors) == 0


class TestSemanticValidation:
    """Test semantic validation rules"""

    def test_undefined_port_reference(self, validator, tmp_path):
        """Test detection of undefined port references in connections"""

        content = """
package test {
    part def ComponentA {
        port portA : DataPort;
    }
    part def System {
        part compA : ComponentA;
        connect compA.undefinedPort to compA.portA;
    }
}
"""
        test_file = tmp_path / "undefined_port.sysml"
        test_file.write_text(content)
        issues = validator.validate_file(test_file)

        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR
                 and "undefined" in i.message.lower() and "port" in i.message.lower()]
        assert len(errors) > 0

    def test_undefined_requirement_reference(self, validator, tmp_path):
        """Test detection of undefined requirement references"""

        content = """
package test {
    requirement REQ_001 {
        doc "Test requirement"
    }
    part def System {
        part component : Component {
            satisfy UNDEFINED_REQ;
        }
    }
    part def Component {}
}
"""
        test_file = tmp_path / "undefined_req.sysml"
        test_file.write_text(content)
        issues = validator.validate_file(test_file)

        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR
                 and "undefined" in i.message.lower() and "requirement" in i.message.lower()]
        assert len(errors) > 0

    def test_circular_composition(self, validator, tmp_path):
        """Test detection of circular composition dependencies"""

        content = """
package test {
    part def A {
        part b : B;
    }
    part def B {
        part c : C;
    }
    part def C {
        part a : A;
    }
}
"""
        test_file = tmp_path / "circular.sysml"
        test_file.write_text(content)
        issues = validator.validate_file(test_file)

        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR
                 and "circular" in i.message.lower()]
        assert len(errors) > 0


class TestStyleValidation:
    """Test style validation rules"""

    def test_naming_conventions(self, validator, tmp_path):
        """Test naming convention checks"""

        content = """
package test {
    part def lowercaseBlock {
    }
    part def GoodBlock {
        part BadInstance : GoodBlock;
    }
}
"""
        test_file = tmp_path / "naming.sysml"
        test_file.write_text(content)
        issues = validator.validate_file(test_file)

        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING
                   and "naming" in i.category.lower()]
        assert len(warnings) >= 2  # At least one for part def, one for instance


class TestRealArchitectures:
    """Test validation on real generated architectures"""

    def test_all_architectures_have_no_errors(self, validator, sample_architectures):
        """Test that generated architectures pass validation (no errors)"""

        failed_files = []

        for arch_file in sample_architectures:
            issues = validator.validate_file(arch_file)
            errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]

            if errors:
                failed_files.append((arch_file.name, errors))

        # Print details if any failures
        if failed_files:
            print("\n\nValidation failures:")
            for filename, errors in failed_files:
                print(f"\n{filename}:")
                for error in errors[:5]:  # Show first 5 errors
                    print(f"  {error}")

        # This should pass - no critical errors
        # (warnings are acceptable)
        assert len(failed_files) == 0, f"{len(failed_files)} files have validation errors"

    def test_architecture_statistics(self, validator, sample_architectures):
        """Collect statistics on validation issues"""

        total_files = len(sample_architectures)
        total_errors = 0
        total_warnings = 0
        category_counts = {}

        for arch_file in sample_architectures:
            issues = validator.validate_file(arch_file)

            for issue in issues:
                if issue.severity == ErrorSeverity.ERROR:
                    total_errors += 1
                elif issue.severity == ErrorSeverity.WARNING:
                    total_warnings += 1

                category_counts[issue.category] = category_counts.get(issue.category, 0) + 1

        print(f"\n\nValidation Statistics for {total_files} files:")
        print(f"  Total errors: {total_errors}")
        print(f"  Total warnings: {total_warnings}")
        print(f"  Avg errors per file: {total_errors / total_files:.2f}")
        print(f"  Avg warnings per file: {total_warnings / total_files:.2f}")

        if category_counts:
            print("\nTop issue categories:")
            for category, count in sorted(category_counts.items(), key=lambda x: -x[1])[:5]:
                print(f"  {category}: {count}")


def test_validator_comprehensive_example(validator, tmp_path):
    """Test a comprehensive example with multiple issues"""

    content = """
package comprehensive_test {

    // Missing documentation for package

    // Requirements
    requirement REQ_001 {
        doc "System shall process data"
    }

    requirement REQ_002 {
        doc ""
    }

    requirement bad_req_name {
        doc "Bad naming"
    }

    // Component Definitions
    part def SensorBlock {
        port dataOut : DataPort;
        port untypedPort;
    }

    part def ProcessorBlock {
        port dataIn : DataPort;
        port cmdOut : CommandPort;
    }

    part def System {
        part sensor : SensorBlock {
            satisfy REQ_001;
        }
        part Processor : ProcessorBlock {
            satisfy REQ_UNDEFINED;
        }

        // Valid connection
        connect sensor.dataOut to Processor.dataIn;

        // Invalid connection - port doesn't exist
        connect sensor.badPort to Processor.dataIn;
    }

    part system : System;
}
"""

    test_file = tmp_path / "comprehensive.sysml"
    test_file.write_text(content)
    issues = validator.validate_file(test_file)

    # Check we caught various issues
    errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
    warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]

    print(f"\n\nComprehensive test found:")
    print(f"  {len(errors)} errors")
    print(f"  {len(warnings)} warnings")

    # Should catch at least:
    # - Empty doc text (warning)
    # - Bad requirement name (warning)
    # - Untyped port (warning)
    # - Bad naming convention for instance (warning)
    # - Undefined requirement reference (error)
    # - Undefined port reference (error)

    assert len(errors) >= 2  # At least undefined ref errors
    assert len(warnings) >= 3  # At least naming and typing warnings
