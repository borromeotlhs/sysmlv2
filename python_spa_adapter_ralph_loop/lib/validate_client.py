"""
Unified SysML v2 Validation Client

Provides a single interface for validating SysML content with automatic
fallback from API to local validation.

Usage:
    from lib.validate_client import validate_sysml, validate_file

    # Validate content string
    result = validate_sysml("package Test { part def MyPart; }")
    if result['valid']:
        print("Valid SysML!")
    else:
        for error in result['errors']:
            print(f"Line {error['line']}: {error['message']}")

    # Validate file
    from pathlib import Path
    result = validate_file(Path("data/architectures/my_arch.sysml"))
    print(f"Validated using: {result['validation_source']}")

Environment Variables:
    - SYSML_VALIDATOR_URL: Override default server URL (default: http://localhost:8765)
    - SYSML_VALIDATION_TIMEOUT: API timeout in seconds (default: 2)
"""

import json
import sys
import tempfile
import urllib.request
import urllib.error
from pathlib import Path
from typing import Dict, Optional

# Add project root to path for imports
_PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))


def validate_sysml(content: str, server_url: str = 'http://localhost:8765') -> Dict:
    """
    Validate SysML v2 textual content using unified validation strategy.

    Strategy:
    1. Try calling {server_url}/api/validate-sysml (SPA server endpoint)
    2. If server not available, fall back to direct local validation

    Args:
        content: SysML v2 textual content to validate
        server_url: Base URL of SPA server (default: http://localhost:8765)
                   Can be overridden via SYSML_VALIDATOR_URL env var

    Returns:
        Dictionary with:
        - valid: bool - True if content passes validation
        - errors: list of dicts with keys:
            - line: int or None - Line number where error occurred
            - column: int or None - Column number (may be None)
            - message: str - Error description
            - severity: str - 'error', 'warning', or 'info'
            - category: str - Error category (e.g., 'SyntaxError')
        - validation_source: str - 'api' if validated via endpoint, 'local' if fallback

    Examples:
        >>> result = validate_sysml("package Test { part def MyPart; }")
        >>> print(result['valid'])
        True
        >>> print(result['validation_source'])
        'api'

        >>> result = validate_sysml("package Test { invalid syntax")
        >>> print(result['valid'])
        False
        >>> for err in result['errors']:
        ...     print(f"Line {err['line']}: {err['message']}")
    """
    import os

    # Allow environment variable override
    api_url = os.environ.get('SYSML_VALIDATOR_URL', server_url)
    timeout = int(os.environ.get('SYSML_VALIDATION_TIMEOUT', '2'))

    # Ensure URL has the endpoint path
    if not api_url.endswith('/api/validate-sysml'):
        api_url = api_url.rstrip('/') + '/api/validate-sysml'

    # Try API validation first
    try:
        result = _validate_via_api(content, api_url, timeout)
        result['validation_source'] = 'api'
        return result
    except Exception as api_error:
        # API failed, fall back to local validation
        try:
            result = _validate_local(content)
            result['validation_source'] = 'local'
            return result
        except Exception as local_error:
            # Both failed - return error result
            return {
                'valid': False,
                'errors': [{
                    'line': None,
                    'column': None,
                    'message': f'All validation methods failed. API: {str(api_error)}. Local: {str(local_error)}',
                    'severity': 'error',
                    'category': 'ValidationError'
                }],
                'validation_source': 'error'
            }


def validate_file(file_path: Path, server_url: str = 'http://localhost:8765') -> Dict:
    """
    Validate a SysML file using unified validation strategy.

    Reads the file content and validates it using the same strategy as validate_sysml().

    Args:
        file_path: Path to .sysml file to validate
        server_url: Base URL of SPA server (default: http://localhost:8765)

    Returns:
        Same format as validate_sysml()

    Raises:
        FileNotFoundError: If file does not exist
        IOError: If file cannot be read

    Examples:
        >>> from pathlib import Path
        >>> result = validate_file(Path("data/architectures/arch_000001.sysml"))
        >>> print(f"Valid: {result['valid']}, Source: {result['validation_source']}")
    """
    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")

    try:
        content = file_path.read_text(encoding='utf-8')
    except Exception as e:
        raise IOError(f"Failed to read file {file_path}: {str(e)}")

    return validate_sysml(content, server_url)


# ============================================================================
# Internal Helper Functions
# ============================================================================

def _validate_via_api(content: str, api_url: str, timeout: int) -> Dict:
    """
    Validate content via API endpoint.

    Args:
        content: SysML content to validate
        api_url: Full URL to validation API endpoint
        timeout: Request timeout in seconds

    Returns:
        Validation result dictionary

    Raises:
        Exception: If API call fails (connection, timeout, HTTP error, etc.)
    """
    # Prepare request payload
    payload = json.dumps({'content': content}).encode('utf-8')

    # Create request
    req = urllib.request.Request(
        api_url,
        data=payload,
        headers={
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        method='POST'
    )

    # Make request with timeout
    try:
        with urllib.request.urlopen(req, timeout=timeout) as response:
            result = json.loads(response.read().decode('utf-8'))

            # Validate response format
            if 'valid' not in result:
                raise ValueError('Invalid API response: missing "valid" field')

            # Ensure errors field exists
            if 'errors' not in result:
                result['errors'] = []

            return result

    except urllib.error.HTTPError as e:
        # Try to extract error details from response
        try:
            error_body = e.read().decode('utf-8')
            error_data = json.loads(error_body)
            error_msg = error_data.get('error', error_body)
        except:
            error_msg = e.reason
        raise Exception(f'API validation HTTP {e.code}: {error_msg}')

    except urllib.error.URLError as e:
        raise Exception(f'API validation connection error: {str(e.reason)}')

    except Exception as e:
        raise Exception(f'API validation failed: {str(e)}')


def _validate_local(content: str) -> Dict:
    """
    Validate content using local validator.

    Falls back to this when API is unavailable. Uses the SysMLValidator
    from tests/test_sysml_validation.py if available, otherwise falls back
    to basic parser validation.

    Args:
        content: SysML content to validate

    Returns:
        Validation result dictionary

    Raises:
        Exception: If local validation fails
    """
    # Try full local validator first
    try:
        from tests.test_sysml_validation import SysMLValidator, ErrorSeverity

        # Write content to temp file for validation
        with tempfile.NamedTemporaryFile(
            mode='w',
            suffix='.sysml',
            delete=False,
            encoding='utf-8'
        ) as f:
            f.write(content)
            temp_path = Path(f.name)

        try:
            # Run validator
            validator = SysMLValidator()
            issues = validator.validate_file(temp_path)

            # Convert to standard format
            errors = []
            for issue in issues:
                errors.append({
                    'line': issue.line_number,
                    'column': None,  # Validator doesn't track columns yet
                    'message': issue.message,
                    'severity': issue.severity.value,
                    'category': issue.category
                })

            # Determine if valid (no errors, warnings are OK)
            is_valid = not any(e['severity'] == 'error' for e in errors)

            return {
                'valid': is_valid,
                'errors': errors
            }

        finally:
            # Clean up temp file
            if temp_path.exists():
                temp_path.unlink()

    except ImportError:
        # Full validator not available, fall back to basic parser check
        return _validate_basic(content)


def _validate_basic(content: str) -> Dict:
    """
    Basic validation using parser only.

    This is the last fallback when neither API nor full local validator
    are available. Just tries to parse the content.

    Args:
        content: SysML content to validate

    Returns:
        Validation result dictionary
    """
    try:
        # Try to import parser (multiple possible locations)
        parse_sysml_to_json = None
        import_error = None

        # Try spa.sysml_parser first (standard location)
        try:
            from spa.sysml_parser import parse_sysml_to_json
        except ImportError as e1:
            import_error = e1
            # Try direct import as fallback
            try:
                from sysml_parser import parse_sysml_to_json
            except ImportError as e2:
                import_error = e2

        if parse_sysml_to_json is None:
            raise ImportError(f"Cannot import sysml_parser: {import_error}")

        # Try to parse the content
        parse_sysml_to_json(content)

        return {
            'valid': True,
            'errors': []
        }

    except Exception as e:
        # Parse error - extract useful information
        error_msg = str(e)

        # Try to extract line number from error message
        import re
        line_num = None
        line_match = re.search(r'line (\d+)', error_msg, re.IGNORECASE)
        if line_match:
            line_num = int(line_match.group(1))

        return {
            'valid': False,
            'errors': [{
                'line': line_num,
                'column': None,
                'message': error_msg,
                'severity': 'error',
                'category': 'ParseError'
            }]
        }


# ============================================================================
# Command-line interface for testing
# ============================================================================

if __name__ == '__main__':
    import sys
    import argparse

    parser = argparse.ArgumentParser(
        description='Validate SysML v2 files or content',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Validate a file
  python lib/validate_client.py data/architectures/arch_000001.sysml

  # Validate a file with custom server URL
  python lib/validate_client.py --server http://localhost:9000 arch.sysml

  # Validate from stdin
  echo "package Test { part def MyPart; }" | python lib/validate_client.py -
"""
    )

    parser.add_argument(
        'file',
        help='Path to .sysml file to validate, or "-" to read from stdin'
    )
    parser.add_argument(
        '--server',
        default='http://localhost:8765',
        help='SPA server URL (default: http://localhost:8765)'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Show detailed error information'
    )

    args = parser.parse_args()

    # Read content
    if args.file == '-':
        content = sys.stdin.read()
        filename = '<stdin>'
    else:
        file_path = Path(args.file)
        if not file_path.exists():
            print(f"Error: File not found: {args.file}", file=sys.stderr)
            sys.exit(1)
        content = file_path.read_text(encoding='utf-8')
        filename = args.file

    # Validate
    print(f"Validating {filename}...", file=sys.stderr)
    result = validate_sysml(content, args.server)

    # Print results
    print(f"\nValidation source: {result['validation_source']}")
    print(f"Valid: {result['valid']}")

    if result['errors']:
        print(f"\nFound {len(result['errors'])} issue(s):\n")
        for i, error in enumerate(result['errors'], 1):
            loc = f"line {error['line']}" if error['line'] else "unknown location"
            severity = error['severity'].upper()
            print(f"{i}. [{severity}] {error['category']}: {error['message']}")
            print(f"   at {loc}")
            if args.verbose and error.get('column'):
                print(f"   column {error['column']}")
            print()
    else:
        print("\nNo issues found.")

    # Exit with appropriate code
    sys.exit(0 if result['valid'] else 1)
