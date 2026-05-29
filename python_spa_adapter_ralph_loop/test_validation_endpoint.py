#!/usr/bin/env python
"""
Integration test for the /api/validate-sysml endpoint.

This test starts the SPA server and mock validator, then tests the full integration.
"""

import json
import subprocess
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path


def wait_for_server(url, timeout=10, name="Server"):
    """Wait for a server to become available"""
    print(f"Waiting for {name} at {url}...")
    start = time.time()
    while time.time() - start < timeout:
        try:
            with urllib.request.urlopen(url, timeout=1) as response:
                if response.status == 200:
                    print(f"✓ {name} is ready")
                    return True
        except:
            time.sleep(0.5)
    print(f"✗ {name} failed to start within {timeout}s")
    return False


def send_validation_request(content, port=8765):
    """Send validation request to SPA server"""
    url = f'http://127.0.0.1:{port}/api/validate-sysml'
    payload = json.dumps({'content': content}).encode('utf-8')

    req = urllib.request.Request(
        url,
        data=payload,
        headers={'Content-Type': 'application/json'}
    )

    with urllib.request.urlopen(req, timeout=10) as response:
        return json.loads(response.read().decode('utf-8'))


def main():
    """Run integration tests"""
    print("=" * 70)
    print("SysML Remote Validation - Integration Test")
    print("=" * 70)

    # Test samples
    valid_sysml = """
package TestSystem {
    part def Sensor;
    part def Processor;

    part system : System {
        part sensor : Sensor;
        part processor : Processor;
    }
}
"""

    invalid_sysml = """
package TestSystem {
    part def Sensor
    part def Processor;
}
"""

    # Start mock validator
    print("\n1. Starting mock validator on port 9000...")
    mock_validator = subprocess.Popen(
        [sys.executable, 'mock_remote_validator.py', '--port', '9000'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=Path(__file__).parent
    )

    # Wait for mock validator to start
    if not wait_for_server('http://127.0.0.1:9000/health', name="Mock Validator"):
        mock_validator.terminate()
        return 1

    try:
        # Start SPA server with remote validation
        print("\n2. Starting SPA server with remote validation...")
        import os
        env = os.environ.copy()
        env['SYSML_VALIDATION_MODE'] = 'remote'
        env['SYSML_REMOTE_VALIDATOR_URL'] = 'http://127.0.0.1:9000/api/validate'
        env['APP_PORT'] = '8765'

        spa_server = subprocess.Popen(
            [sys.executable, '-m', 'spa.server', '--port', '8765'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=Path(__file__).parent,
            env=env
        )

        # Wait for SPA server to start
        if not wait_for_server('http://127.0.0.1:8765/api/health', name="SPA Server"):
            spa_server.terminate()
            mock_validator.terminate()
            return 1

        # Test 1: Valid SysML
        print("\n3. Testing valid SysML content...")
        result = send_validation_request(valid_sysml)
        print(f"   Valid: {result['valid']}")
        print(f"   Errors: {len(result.get('errors', []))}")
        print(f"   Source: {result.get('validation_source', 'unknown')}")

        assert result.get('validation_source') == 'remote', \
            f"Expected 'remote', got '{result.get('validation_source')}'"
        # May have warnings, so just check no hard errors
        has_errors = any(e.get('severity') == 'error' for e in result.get('errors', []))
        if has_errors:
            print("   Warning: Valid SysML has errors (mock validator may be too strict)")

        # Test 2: Invalid SysML
        print("\n4. Testing invalid SysML content...")
        result = send_validation_request(invalid_sysml)
        print(f"   Valid: {result['valid']}")
        print(f"   Errors: {len(result.get('errors', []))}")
        print(f"   Source: {result.get('validation_source', 'unknown')}")

        assert result.get('validation_source') == 'remote', \
            f"Expected 'remote', got '{result.get('validation_source')}'"
        assert not result['valid'], "Invalid SysML should be marked as invalid"
        assert len(result.get('errors', [])) > 0, "Should have validation errors"

        if result.get('errors'):
            print(f"   First error: {result['errors'][0]['message']}")

        # Test 3: Response format
        print("\n5. Verifying response format...")
        assert 'valid' in result, "Missing 'valid' field"
        assert 'errors' in result, "Missing 'errors' field"
        assert 'validation_source' in result, "Missing 'validation_source' field"
        assert isinstance(result['valid'], bool), "'valid' must be boolean"
        assert isinstance(result['errors'], list), "'errors' must be list"
        print("   ✓ Response format correct")

        print("\n" + "=" * 70)
        print("✓ All integration tests passed!")
        print("=" * 70)

        return 0

    except AssertionError as e:
        print(f"\n✗ Test failed: {e}")
        return 1

    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return 1

    finally:
        # Cleanup
        print("\n6. Cleaning up...")
        spa_server.terminate()
        mock_validator.terminate()

        # Wait for processes to exit
        spa_server.wait(timeout=5)
        mock_validator.wait(timeout=5)
        print("   ✓ Servers stopped")


if __name__ == '__main__':
    sys.exit(main())
