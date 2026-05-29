#!/usr/bin/env python
"""
Mock remote SysML validator for testing.

This is a simple HTTP server that mimics a remote validation API.
Useful for testing the remote validation feature without setting up a real validator.

Usage:
    python mock_remote_validator.py --port 9000

Then in another terminal:
    export SYSML_REMOTE_VALIDATOR_URL=http://localhost:9000/api/validate
    export SYSML_VALIDATION_MODE=remote
    python spa/server.py
"""

import argparse
import json
import re
from http.server import BaseHTTPRequestHandler, HTTPServer


class MockValidatorHandler(BaseHTTPRequestHandler):
    """Mock validation API handler"""

    server_version = 'MockSysMLValidator/1.0'

    def log_message(self, fmt, *args):
        """Log requests to console"""
        print(f"[{self.log_date_time_string()}] {fmt % args}")

    def send_json_response(self, data, status=200):
        """Send JSON response"""
        body = json.dumps(data, indent=2).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Access-Control-Allow-Origin', '*')  # Allow CORS
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        """Handle CORS preflight"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        """Handle POST requests"""
        if self.path == '/api/validate':
            return self.handle_validate()
        else:
            return self.send_json_response({'error': 'Unknown endpoint'}, 404)

    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/health':
            return self.send_json_response({'status': 'ok', 'service': 'mock-validator'})
        else:
            return self.send_json_response({'error': 'Use POST /api/validate'}, 404)

    def handle_validate(self):
        """Handle validation request"""
        try:
            # Read request body
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length).decode('utf-8')
            request_data = json.loads(body)

            # Extract SysML content
            if 'content' not in request_data:
                return self.send_json_response(
                    {'error': 'Missing required field: content'},
                    400
                )

            content = request_data['content']

            # Perform mock validation
            result = self.validate_content(content)

            return self.send_json_response(result, 200)

        except json.JSONDecodeError as e:
            return self.send_json_response(
                {'error': f'Invalid JSON: {str(e)}'},
                400
            )
        except Exception as e:
            return self.send_json_response(
                {'error': f'Validation error: {str(e)}'},
                500
            )

    def validate_content(self, content: str) -> dict:
        """
        Perform mock validation using simple regex patterns.

        This is NOT a real SysML validator - it just checks for common syntax issues.
        """
        errors = []
        lines = content.split('\n')

        # Check 1: Missing semicolons after part def
        for i, line in enumerate(lines, 1):
            # Match "part def Name" without semicolon at end
            if re.search(r'part\s+def\s+\w+\s*$', line.strip()):
                errors.append({
                    'line': i,
                    'column': len(line) - len(line.lstrip()),
                    'message': 'Missing semicolon after part definition',
                    'severity': 'error',
                    'category': 'SyntaxError'
                })

        # Check 2: Unclosed braces
        open_braces = content.count('{')
        close_braces = content.count('}')
        if open_braces != close_braces:
            errors.append({
                'line': len(lines),
                'column': 0,
                'message': f'Mismatched braces: {open_braces} open, {close_braces} close',
                'severity': 'error',
                'category': 'SyntaxError'
            })

        # Check 3: Empty content
        if not content.strip():
            errors.append({
                'line': 1,
                'column': 0,
                'message': 'Empty content',
                'severity': 'error',
                'category': 'ValidationError'
            })

        # Check 4: Missing package declaration (warning only)
        if 'package' not in content.lower():
            errors.append({
                'line': 1,
                'column': 0,
                'message': 'No package declaration found (recommended)',
                'severity': 'warning',
                'category': 'StyleWarning'
            })

        # Determine if valid (no errors, warnings are OK)
        is_valid = not any(e['severity'] == 'error' for e in errors)

        return {
            'valid': is_valid,
            'errors': errors
        }


def main():
    """Run mock validator server"""
    parser = argparse.ArgumentParser(description='Mock SysML validation server')
    parser.add_argument('--host', default='127.0.0.1', help='Host to bind to')
    parser.add_argument('--port', type=int, default=9000, help='Port to listen on')
    args = parser.parse_args()

    server = HTTPServer((args.host, args.port), MockValidatorHandler)

    print(f'Mock SysML Validator running at http://{args.host}:{args.port}')
    print(f'Validation endpoint: http://{args.host}:{args.port}/api/validate')
    print(f'Health check: http://{args.host}:{args.port}/health')
    print()
    print('To use with SPA server:')
    print(f'  export SYSML_REMOTE_VALIDATOR_URL=http://{args.host}:{args.port}/api/validate')
    print(f'  export SYSML_VALIDATION_MODE=remote  # or "auto" for fallback')
    print(f'  python spa/server.py')
    print()
    print('Press Ctrl+C to stop')

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\nShutting down...')
        server.shutdown()


if __name__ == '__main__':
    main()
