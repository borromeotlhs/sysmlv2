#!/usr/bin/env python3
"""
Test script for unified validation client.

Tests both API and local fallback modes.
"""

from pathlib import Path
from lib.validate_client import validate_sysml, validate_file


def test_valid_sysml():
    """Test validation of valid SysML content"""
    print("Test 1: Valid SysML content")
    content = """package TestPackage {
    part def Engine {
        attribute power: Real;
    }

    part def Vehicle {
        part engine: Engine;
    }
}"""

    result = validate_sysml(content)
    print(f"  Valid: {result['valid']}")
    print(f"  Source: {result['validation_source']}")
    print(f"  Issues: {len(result['errors'])}")
    if result['errors']:
        for err in result['errors']:
            print(f"    - [{err['severity']}] {err['message']}")
    print()


def test_invalid_sysml():
    """Test validation of invalid SysML content"""
    print("Test 2: Invalid SysML content (unbalanced braces)")
    content = "package Test { part def Broken"

    result = validate_sysml(content)
    print(f"  Valid: {result['valid']}")
    print(f"  Source: {result['validation_source']}")
    print(f"  Issues: {len(result['errors'])}")
    if result['errors']:
        for err in result['errors']:
            print(f"    - [{err['severity']}] {err['message']}")
    print()


def test_validate_file():
    """Test file validation"""
    print("Test 3: Validate existing file")

    # Find first .sysml file
    arch_dir = Path("data/architectures")
    sysml_files = list(arch_dir.glob("*.sysml"))

    if not sysml_files:
        print("  No .sysml files found to test")
        print()
        return

    test_file = sysml_files[0]
    print(f"  File: {test_file}")

    result = validate_file(test_file)
    print(f"  Valid: {result['valid']}")
    print(f"  Source: {result['validation_source']}")
    print(f"  Issues: {len(result['errors'])}")
    if result['errors'] and len(result['errors']) <= 3:
        for err in result['errors']:
            print(f"    - [{err['severity']}] {err['message']}")
    print()


def test_minimal_content():
    """Test minimal valid package"""
    print("Test 4: Minimal valid package")
    content = "package Minimal { }"

    result = validate_sysml(content)
    print(f"  Valid: {result['valid']}")
    print(f"  Source: {result['validation_source']}")
    print(f"  Issues: {len(result['errors'])}")
    print()


def test_api_endpoint():
    """Test API endpoint if server is running"""
    print("Test 5: API endpoint check")
    import urllib.request
    import urllib.error

    try:
        req = urllib.request.Request('http://localhost:8765/api/health')
        with urllib.request.urlopen(req, timeout=1) as response:
            print("  Server status: RUNNING")
            print("  Note: Client will use API validation")
    except (urllib.error.URLError, OSError) as e:
        print("  Server status: NOT RUNNING")
        print("  Note: Client will use local fallback")
    print()


if __name__ == '__main__':
    print("=" * 70)
    print("Unified Validation Client Test Suite")
    print("=" * 70)
    print()

    # Check API availability first
    test_api_endpoint()

    # Run validation tests
    test_valid_sysml()
    test_invalid_sysml()
    test_validate_file()
    test_minimal_content()

    print("=" * 70)
    print("All tests completed")
    print("=" * 70)
