#!/usr/bin/env python
"""
Manual test script for new API endpoints.
Tests validation and save functionality without requiring pytest.
"""
import sys
from pathlib import Path

# Add spa module to path
sys.path.insert(0, str(Path(__file__).parent))

from spa.server import validate_save_path, validate_sysml_content_basic, ARCH_DIR


def test_path_validation():
    """Test path validation security"""
    print("\n=== Testing Path Validation ===")

    # Test 1: Valid relative path
    try:
        path = validate_save_path("test_arch.sysml")
        print(f"✓ Valid relative path: {path}")
    except Exception as e:
        print(f"✗ Valid relative path failed: {e}")
        return False

    # Test 2: Block directory traversal
    try:
        validate_save_path("../../../etc/passwd.sysml")
        print("✗ Directory traversal not blocked!")
        return False
    except ValueError as e:
        print(f"✓ Directory traversal blocked: {e}")

    # Test 3: Block invalid extension
    try:
        validate_save_path("test.txt")
        print("✗ Invalid extension not blocked!")
        return False
    except ValueError as e:
        print(f"✓ Invalid extension blocked: {e}")

    # Test 4: Block special characters
    try:
        validate_save_path("test<>arch.sysml")
        print("✗ Special characters not blocked!")
        return False
    except ValueError as e:
        print(f"✓ Special characters blocked: {e}")

    # Test 5: Allow subdirectories
    try:
        path = validate_save_path("subdir/test_arch.sysml")
        print(f"✓ Subdirectory path allowed: {path}")
    except Exception as e:
        print(f"✗ Subdirectory path failed: {e}")
        return False

    return True


def test_sysml_validation():
    """Test SysML validation functionality"""
    print("\n=== Testing SysML Validation ===")

    # Test 1: Valid SysML
    valid_content = """
// Test Architecture
// Domain: aerospace
package TestArch {
    part def SystemBlock {
        port dataIn;
        port dataOut;
    }
}
"""
    try:
        result = validate_sysml_content_basic(valid_content)
        if result['valid']:
            print(f"✓ Valid SysML accepted: {result}")
        else:
            print(f"✗ Valid SysML rejected: {result}")
            return False
    except Exception as e:
        print(f"✗ Valid SysML validation failed: {e}")
        return False

    # Test 2: Invalid SysML
    invalid_content = """
This is not valid SysML content at all!
Random text that should fail parsing.
"""
    try:
        result = validate_sysml_content_basic(invalid_content)
        if not result['valid']:
            print(f"✓ Invalid SysML rejected: {result['errors'][0]['message'][:80]}")
        else:
            print(f"✗ Invalid SysML accepted: {result}")
            return False
    except Exception as e:
        print(f"✗ Invalid SysML validation failed: {e}")
        return False

    # Test 3: Empty content
    empty_content = ""
    try:
        result = validate_sysml_content_basic(empty_content)
        if not result['valid']:
            print(f"✓ Empty content rejected: {result['errors'][0]['message'][:80]}")
        else:
            print(f"✗ Empty content accepted: {result}")
            return False
    except Exception as e:
        print(f"✗ Empty content validation failed: {e}")
        return False

    return True


def test_save_functionality():
    """Test actual file saving"""
    print("\n=== Testing Save Functionality ===")

    test_content = """
// Test Architecture
// Domain: test
package TestArch {
    part def TestBlock {
        port testPort;
    }
}
"""
    test_file = ARCH_DIR / "test_manual_save.sysml"

    # Test 1: Create file
    try:
        test_file.parent.mkdir(parents=True, exist_ok=True)
        test_file.write_text(test_content, encoding='utf-8')
        print(f"✓ File created: {test_file}")
    except Exception as e:
        print(f"✗ File creation failed: {e}")
        return False

    # Test 2: Verify content
    try:
        saved_content = test_file.read_text(encoding='utf-8')
        if saved_content == test_content:
            print(f"✓ Content verified: {len(saved_content)} bytes")
        else:
            print(f"✗ Content mismatch")
            return False
    except Exception as e:
        print(f"✗ Content verification failed: {e}")
        return False

    # Test 3: Clean up
    try:
        test_file.unlink()
        print(f"✓ File cleaned up")
    except Exception as e:
        print(f"⚠ Clean up warning: {e}")

    return True


def main():
    """Run all tests"""
    print("=" * 60)
    print("API Endpoints Manual Test Suite")
    print("=" * 60)

    results = []

    # Run tests
    results.append(("Path Validation", test_path_validation()))
    results.append(("SysML Validation", test_sysml_validation()))
    results.append(("Save Functionality", test_save_functionality()))

    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)

    for test_name, passed in results:
        status = "PASS" if passed else "FAIL"
        symbol = "✓" if passed else "✗"
        print(f"{symbol} {test_name}: {status}")

    # Overall result
    all_passed = all(passed for _, passed in results)
    print("\n" + "=" * 60)
    if all_passed:
        print("✓ ALL TESTS PASSED")
        return 0
    else:
        print("✗ SOME TESTS FAILED")
        return 1


if __name__ == '__main__':
    sys.exit(main())
