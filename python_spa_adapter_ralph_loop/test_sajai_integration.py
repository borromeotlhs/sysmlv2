#!/usr/bin/env python3
"""
Integration test for SAJAI generation feature.

Tests:
1. SAJAI generator library works
2. Server endpoint is accessible
3. Generated files are valid
"""

import json
import time
from pathlib import Path
import urllib.request
import urllib.error


def test_sajai_generator():
    """Test SAJAI generator library"""
    print("\n=== Testing SAJAI Generator Library ===")

    from lib.sajai_generator import sysml_to_sajai

    # Find a test architecture
    arch_dir = Path('data/architectures')
    test_arch = None
    for arch_file in arch_dir.glob('*.sysml'):
        test_arch = arch_file
        break

    if not test_arch:
        print("ERROR: No .sysml architecture files found for testing")
        return False

    print(f"Testing with: {test_arch}")

    # Generate SAJAI
    output_path = Path('spa/static/sample-data/test_integration.sajai')
    try:
        sajai = sysml_to_sajai(test_arch, output_path)

        # Verify output file exists
        if not output_path.exists():
            print(f"ERROR: Output file not created: {output_path}")
            return False

        print(f"✓ SAJAI file generated: {output_path}")

        # Verify structure
        if 'format' not in sajai or sajai['format'] != 'SAJAI':
            print("ERROR: Invalid SAJAI format")
            return False

        if 'scenes' not in sajai:
            print("ERROR: No scenes in SAJAI")
            return False

        # Print stats
        for scene_key, scene in sajai['scenes'].items():
            parts_count = len(scene.get('parts', []))
            ports_count = len(scene.get('ports', []))
            connectors_count = len(scene.get('connectors', []))
            print(f"  Scene '{scene.get('name', scene_key)}':")
            print(f"    - Parts: {parts_count}")
            print(f"    - Ports: {ports_count}")
            print(f"    - Connectors: {connectors_count}")

        print("✓ SAJAI generator library works correctly")
        return True

    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_server_endpoint():
    """Test server endpoint (requires server to be running)"""
    print("\n=== Testing Server Endpoint ===")

    # Check if server is running
    try:
        req = urllib.request.Request('http://127.0.0.1:8765/api/health')
        with urllib.request.urlopen(req, timeout=2) as response:
            health = json.loads(response.read())
            if not health.get('ok'):
                print("ERROR: Server health check failed")
                return False
        print("✓ Server is running")
    except Exception as e:
        print(f"ERROR: Server not accessible: {e}")
        print("  Please start the server with: python spa/server.py")
        return False

    # Find a test architecture
    arch_dir = Path('data/architectures')
    test_arch = None
    for arch_file in arch_dir.glob('*.sysml'):
        test_arch = arch_file
        break

    if not test_arch:
        print("ERROR: No .sysml files found for testing")
        return False

    # Call API
    arch_path = str(test_arch).replace('\\', '/')
    output_path = "spa/static/sample-data/test_api.sajai"

    payload = {
        'architecturePath': arch_path,
        'outputPath': output_path
    }

    try:
        req = urllib.request.Request(
            'http://127.0.0.1:8765/api/generate-sajai',
            data=json.dumps(payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='POST'
        )

        with urllib.request.urlopen(req, timeout=10) as response:
            result = json.loads(response.read())

            if not result.get('ok'):
                print(f"ERROR: API returned not ok: {result}")
                return False

            print(f"✓ API call successful")
            print(f"  Generated: {result.get('path')}")
            print(f"  Scenes: {result.get('scenes')}")
            print(f"  Parts: {result.get('parts')}")
            print(f"  Ports: {result.get('ports')}")
            print(f"  Connectors: {result.get('connectors')}")

            # Verify file exists
            output_file = Path(result.get('path'))
            if not output_file.exists():
                print(f"ERROR: Output file not found: {output_file}")
                return False

            print("✓ Server endpoint works correctly")
            return True

    except urllib.error.HTTPError as e:
        print(f"ERROR: HTTP {e.code}")
        error_body = e.read().decode('utf-8')
        print(f"  Response: {error_body}")
        return False
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False


def cleanup_test_files():
    """Clean up test files"""
    print("\n=== Cleaning Up Test Files ===")
    test_files = [
        Path('spa/static/sample-data/test_integration.sajai'),
        Path('spa/static/sample-data/test_api.sajai')
    ]

    for f in test_files:
        if f.exists():
            f.unlink()
            print(f"✓ Removed {f}")


if __name__ == '__main__':
    print("=" * 60)
    print("SAJAI Integration Test Suite")
    print("=" * 60)

    # Test 1: Generator library
    test1_passed = test_sajai_generator()

    # Test 2: Server endpoint
    test2_passed = test_server_endpoint()

    # Cleanup
    cleanup_test_files()

    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    print(f"Generator Library: {'PASS' if test1_passed else 'FAIL'}")
    print(f"Server Endpoint: {'PASS' if test2_passed else 'FAIL'}")
    print()

    if test1_passed and test2_passed:
        print("✓ All tests passed!")
        exit(0)
    else:
        print("✗ Some tests failed")
        exit(1)
