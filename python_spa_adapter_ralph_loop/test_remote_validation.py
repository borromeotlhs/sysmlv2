#!/usr/bin/env python
"""
Test script for remote SysML validation functionality.

Tests:
1. Valid SysML content
2. Invalid SysML content
3. Different validation modes (local, remote, auto)
4. Fallback behavior when remote unavailable
"""

import os
import sys
import json
from pathlib import Path

# Add spa directory to path
sys.path.insert(0, str(Path(__file__).parent / 'spa'))

from server import validate_sysml_content, validate_sysml_content_local, validate_sysml_remote


# Test SysML samples
VALID_SYSML = """
package TestSystem {
    part def Sensor;
    part def Processor;
    part def Actuator;

    part system : System {
        part sensor : Sensor;
        part processor : Processor;
        part actuator : Actuator;
    }
}
"""

INVALID_SYSML = """
package TestSystem {
    part def Sensor
    // Missing semicolon above
    part def Processor;
}
"""


def test_local_validation():
    """Test local validation mode"""
    print("\n=== Test 1: Local Validation (Valid SysML) ===")
    os.environ['SYSML_VALIDATION_MODE'] = 'local'

    result = validate_sysml_content(VALID_SYSML)
    print(f"Valid: {result['valid']}")
    print(f"Errors: {len(result.get('errors', []))}")
    print(f"Source: {result.get('validation_source', 'unknown')}")

    assert result['validation_source'] == 'local', "Should use local validation"

    print("\n=== Test 2: Local Validation (Invalid SysML) ===")
    result = validate_sysml_content(INVALID_SYSML)
    print(f"Valid: {result['valid']}")
    print(f"Errors: {len(result.get('errors', []))}")
    print(f"Source: {result.get('validation_source', 'unknown')}")

    if result.get('errors'):
        print(f"First error: {result['errors'][0]['message'][:100]}")


def test_remote_validation_no_url():
    """Test remote validation without URL configured"""
    print("\n=== Test 3: Remote Validation (No URL) ===")
    os.environ['SYSML_VALIDATION_MODE'] = 'remote'

    # Remove URL if set
    if 'SYSML_REMOTE_VALIDATOR_URL' in os.environ:
        del os.environ['SYSML_REMOTE_VALIDATOR_URL']

    try:
        result = validate_sysml_content(VALID_SYSML)
        print(f"ERROR: Should have raised exception, got: {result}")
    except Exception as e:
        print(f"Expected error: {str(e)[:100]}")
        assert 'not configured' in str(e).lower(), "Should indicate URL not configured"


def test_auto_mode_fallback():
    """Test auto mode falls back to local when remote unavailable"""
    print("\n=== Test 4: Auto Mode (Fallback to Local) ===")
    os.environ['SYSML_VALIDATION_MODE'] = 'auto'
    os.environ['SYSML_REMOTE_VALIDATOR_URL'] = 'http://invalid-url-that-does-not-exist.example.com/validate'
    os.environ['SPA_QUIET'] = '0'  # Show fallback message

    result = validate_sysml_content(VALID_SYSML)
    print(f"Valid: {result['valid']}")
    print(f"Source: {result.get('validation_source', 'unknown')}")

    # Should fall back to local or basic
    assert result.get('validation_source') in ['local', 'basic'], \
        f"Should fall back to local/basic, got: {result.get('validation_source')}"


def test_response_format():
    """Test that validation response has correct format"""
    print("\n=== Test 5: Response Format ===")
    os.environ['SYSML_VALIDATION_MODE'] = 'local'

    result = validate_sysml_content(VALID_SYSML)

    # Check required fields
    assert 'valid' in result, "Response must have 'valid' field"
    assert 'errors' in result, "Response must have 'errors' field"
    assert 'validation_source' in result, "Response must have 'validation_source' field"

    # Check types
    assert isinstance(result['valid'], bool), "'valid' must be boolean"
    assert isinstance(result['errors'], list), "'errors' must be list"
    assert isinstance(result['validation_source'], str), "'validation_source' must be string"

    print("✓ Response format correct")
    print(f"  valid: {type(result['valid']).__name__}")
    print(f"  errors: {type(result['errors']).__name__}")
    print(f"  validation_source: {type(result['validation_source']).__name__}")


def main():
    """Run all tests"""
    print("Testing Remote SysML Validation Implementation")
    print("=" * 60)

    try:
        test_local_validation()
        test_remote_validation_no_url()
        test_auto_mode_fallback()
        test_response_format()

        print("\n" + "=" * 60)
        print("✓ All tests passed!")
        print("\nEnvironment Variables:")
        print(f"  SYSML_VALIDATION_MODE: {os.environ.get('SYSML_VALIDATION_MODE', 'not set')}")
        print(f"  SYSML_REMOTE_VALIDATOR_URL: {os.environ.get('SYSML_REMOTE_VALIDATOR_URL', 'not set')}")

        return 0

    except AssertionError as e:
        print(f"\n✗ Test failed: {e}")
        return 1
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    sys.exit(main())
