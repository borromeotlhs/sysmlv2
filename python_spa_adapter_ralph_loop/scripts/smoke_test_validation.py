#!/usr/bin/env python3
"""
Smoke test validation for all SysML architectures using the API endpoint.

Tests all .sysml files in data/architectures/ against the validation endpoint.
"""
import json
import urllib.request
import urllib.error
from pathlib import Path
import time
import sys

# Configuration
SERVER_URL = 'http://localhost:8765'
VALIDATION_ENDPOINT = f'{SERVER_URL}/api/validate-sysml'
ARCH_DIR = Path(__file__).resolve().parents[1] / 'data' / 'architectures'


def validate_via_api(content: str) -> dict:
    """Validate content via API endpoint"""
    payload = json.dumps({'content': content}).encode('utf-8')
    req = urllib.request.Request(
        VALIDATION_ENDPOINT,
        data=payload,
        headers={'Content-Type': 'application/json'},
        method='POST'
    )

    with urllib.request.urlopen(req, timeout=10) as response:
        return json.loads(response.read().decode('utf-8'))


def main():
    print("=" * 70)
    print("Validation Smoke Test Report")
    print("=" * 70)
    print()

    # Check if server is running
    try:
        health_check = urllib.request.urlopen(f'{SERVER_URL}/api/health', timeout=2)
        health_check.read()
        print(f"✓ Server running at {SERVER_URL}")
    except Exception as e:
        print(f"✗ Server not accessible at {SERVER_URL}")
        print(f"  Error: {e}")
        print()
        print("Please start the server with: python3 spa/server.py")
        sys.exit(1)

    print()

    # Find all .sysml files
    sysml_files = sorted(ARCH_DIR.glob('*.sysml'))

    if not sysml_files:
        print(f"No .sysml files found in {ARCH_DIR}")
        sys.exit(1)

    print(f"Found {len(sysml_files)} architecture files")
    print()

    # Test each file
    results = {
        'valid': [],
        'invalid': [],
        'errors': []
    }

    total_time = 0

    for i, file_path in enumerate(sysml_files, 1):
        try:
            # Read file
            content = file_path.read_text(encoding='utf-8')

            # Validate via API
            start = time.time()
            result = validate_via_api(content)
            elapsed = time.time() - start
            total_time += elapsed

            # Track results
            if result.get('valid'):
                results['valid'].append(file_path.name)
                status = '✓'
            else:
                results['invalid'].append(file_path.name)
                status = '✗'
                # Collect error details
                for error in result.get('errors', []):
                    results['errors'].append({
                        'file': file_path.name,
                        'error': error
                    })

            # Progress indicator
            if i % 10 == 0 or not result.get('valid'):
                print(f"  [{i:3d}/{len(sysml_files)}] {status} {file_path.name:40s} ({elapsed*1000:.0f}ms)")

        except Exception as e:
            print(f"  [FAIL] {file_path.name}: {str(e)}")
            results['invalid'].append(file_path.name)
            results['errors'].append({
                'file': file_path.name,
                'error': {'message': str(e), 'severity': 'error'}
            })

    # Print summary
    print()
    print("=" * 70)
    print("Summary")
    print("=" * 70)
    print(f"Files tested: {len(sysml_files)}")
    print(f"Valid:        {len(results['valid'])} ({len(results['valid'])/len(sysml_files)*100:.1f}%)")
    print(f"Invalid:      {len(results['invalid'])} ({len(results['invalid'])/len(sysml_files)*100:.1f}%)")
    print(f"Avg time:     {total_time/len(sysml_files)*1000:.0f}ms per file")
    print()

    # Print errors if any
    if results['errors']:
        print("Validation Errors:")
        print("-" * 70)
        for item in results['errors'][:10]:  # Show first 10 errors
            error = item['error']
            print(f"  {item['file']}:")
            print(f"    Line {error.get('line', '?')}: {error.get('message', 'Unknown error')}")
            print(f"    Severity: {error.get('severity', 'error')}")
            print()

        if len(results['errors']) > 10:
            print(f"  ... and {len(results['errors']) - 10} more errors")
            print()

    # Print invalid files
    if results['invalid']:
        print("Invalid Files:")
        print("-" * 70)
        for filename in results['invalid'][:20]:
            print(f"  - {filename}")
        if len(results['invalid']) > 20:
            print(f"  ... and {len(results['invalid']) - 20} more")
        print()

    print("=" * 70)

    # Exit with appropriate code
    if results['invalid']:
        print("SMOKE TEST FAILED")
        sys.exit(1)
    else:
        print("SMOKE TEST PASSED ✓")
        sys.exit(0)


if __name__ == '__main__':
    main()
