"""Tests for validate_sysml.py"""
import tempfile
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))
from validate_sysml import FallbackValidator


def test_validator_valid_package():
    """Test validation of a valid package."""
    validator = FallbackValidator()

    with tempfile.NamedTemporaryFile(mode='w', suffix='.sysml', delete=False) as f:
        f.write("""
package TestPackage {
    part def System;
}
        """)
        temp_path = f.name

    try:
        is_valid, result = validator.validate(temp_path)

        assert is_valid
        assert result["valid"]
        assert result["validator"] == "fallback-smoke-v0"
        assert "disclaimer" in result
    finally:
        Path(temp_path).unlink()


def test_validator_unbalanced_braces():
    """Test validation detects unbalanced braces."""
    validator = FallbackValidator()

    with tempfile.NamedTemporaryFile(mode='w', suffix='.sysml', delete=False) as f:
        f.write("""
package TestPackage {
    part def System;
        """)
        temp_path = f.name

    try:
        is_valid, result = validator.validate(temp_path)

        assert not is_valid
        assert not result["valid"]
        assert any("brace" in err.lower() for err in result["errors"])
    finally:
        Path(temp_path).unlink()


def test_validator_missing_package():
    """Test validation detects missing package declaration."""
    validator = FallbackValidator()

    with tempfile.NamedTemporaryFile(mode='w', suffix='.sysml', delete=False) as f:
        f.write("""
part def System;
        """)
        temp_path = f.name

    try:
        is_valid, result = validator.validate(temp_path)

        assert not is_valid
        assert not result["valid"]
        assert any("package" in err.lower() for err in result["errors"])
    finally:
        Path(temp_path).unlink()


def test_validator_undefined_type_reference():
    """Test validation detects undefined type references."""
    validator = FallbackValidator()

    with tempfile.NamedTemporaryFile(mode='w', suffix='.sysml', delete=False) as f:
        f.write("""
package TestPackage {
    part def System {
        part component : UndefinedType;
    }
}
        """)
        temp_path = f.name

    try:
        is_valid, result = validator.validate(temp_path)

        assert not is_valid
        assert not result["valid"]
        assert any("undefined" in err.lower() for err in result["errors"])
    finally:
        Path(temp_path).unlink()


def test_validator_valid_with_requirements():
    """Test validation of package with requirements and verification."""
    validator = FallbackValidator()

    with tempfile.NamedTemporaryFile(mode='w', suffix='.sysml', delete=False) as f:
        f.write("""
package TestPackage {
    part def System;

    requirement def TestReq {
        doc /* Test requirement */
    }

    verification case def TestVerif {
        subject TestReq;
    }
}
        """)
        temp_path = f.name

    try:
        is_valid, result = validator.validate(temp_path)

        assert is_valid
        assert result["valid"]
    finally:
        Path(temp_path).unlink()
