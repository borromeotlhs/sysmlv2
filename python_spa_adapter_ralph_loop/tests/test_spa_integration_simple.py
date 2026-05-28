#!/usr/bin/env python3
"""
Comprehensive integration tests for the SPA (Single Page Application).
Standalone version that doesn't require pytest.

Tests API endpoints, error handling, file operations, concurrency, and more.
"""

import json
import sys
import time
import tempfile
import threading
import subprocess
from pathlib import Path
from urllib.parse import quote
import urllib.request
import urllib.error
import os

# Add project paths
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT / 'spa'))
sys.path.insert(0, str(PROJECT_ROOT / 'scripts'))

# Test tracking
test_results = {
    'passed': 0,
    'failed': 0,
    'skipped': 0,
    'errors': []
}


def test(name):
    """Decorator to register and run a test"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            try:
                print(f"  ▶ {name}...", end=' ')
                result = func(*args, **kwargs)
                print("✓ PASS")
                test_results['passed'] += 1
                return result
            except AssertionError as e:
                print(f"✗ FAIL: {e}")
                test_results['failed'] += 1
                test_results['errors'].append((name, str(e)))
            except Exception as e:
                print(f"✗ ERROR: {e}")
                test_results['failed'] += 1
                test_results['errors'].append((name, f"Exception: {e}"))
        wrapper.__name__ = func.__name__
        wrapper._is_test = True
        wrapper._test_name = name
        return wrapper
    return decorator


def skip(reason):
    """Skip a test"""
    print(f"⊘ SKIP: {reason}")
    test_results['skipped'] += 1
    raise RuntimeError(f"SKIP: {reason}")


class SPATestServer:
    """Manage SPA server lifecycle for testing"""

    def __init__(self):
        self.host = os.environ.get('APP_HOST', '127.0.0.1')
        self.port = int(os.environ.get('APP_PORT', '8766'))
        self.url = f'http://{self.host}:{self.port}'
        self.process = None

    def start(self):
        """Start the SPA server"""
        server_py = PROJECT_ROOT / 'spa' / 'server.py'
        env = os.environ.copy()
        env['SPA_QUIET'] = '1'

        self.process = subprocess.Popen(
            [sys.executable, str(server_py), '--host', self.host, '--port', str(self.port)],
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        # Wait for server to be ready
        for i in range(30):
            try:
                with urllib.request.urlopen(f'{self.url}/api/health', timeout=1) as response:
                    data = json.loads(response.read().decode())
                    if data.get('ok'):
                        print(f"\n✓ Server started at {self.url}\n")
                        return True
            except Exception:
                time.sleep(0.2)

        self.stop()
        raise RuntimeError("Failed to start SPA server")

    def stop(self):
        """Stop the SPA server"""
        if self.process:
            self.process.terminate()
            try:
                self.process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.process.kill()
            print("\n✓ Server stopped\n")

    def request(self, endpoint, method='GET', data=None, headers=None):
        """Make HTTP request to server"""
        url = self.url + endpoint

        if headers is None:
            headers = {}

        if data is not None and isinstance(data, dict):
            data = json.dumps(data).encode('utf-8')
            headers['Content-Type'] = 'application/json'

        req = urllib.request.Request(url, data=data, headers=headers, method=method)

        try:
            with urllib.request.urlopen(req, timeout=5) as response:
                body = response.read().decode('utf-8')
                try:
                    response_data = json.loads(body)
                except json.JSONDecodeError:
                    response_data = body
                return response.status, response_data, dict(response.headers)
        except urllib.error.HTTPError as e:
            body = e.read().decode('utf-8')
            try:
                error_data = json.loads(body)
            except json.JSONDecodeError:
                error_data = {'error': body}
            return e.code, error_data, dict(e.headers)
        except urllib.error.URLError as e:
            return None, {'error': str(e)}, {}


# Global server instance
server = None


def run_tests():
    """Run all tests"""
    global server

    print("\n" + "=" * 70)
    print("  SPA INTEGRATION TESTS")
    print("=" * 70)

    # Start server
    server = SPATestServer()
    try:
        server.start()
    except RuntimeError as e:
        print(f"\n✗ Failed to start server: {e}")
        return 1

    try:
        # Run all test functions
        test_functions = [
            (test_health_endpoint, "Health and Basic API Tests"),
            (test_health_multiple_calls, None),
            (test_architectures_list, None),
            (test_architecture_get, None),
            (test_architecture_not_found, None),
            (test_architecture_path_traversal, None),
            (test_architecture_separated_format, None),
            (test_architecture_views_list, None),
            (test_architecture_view_get, None),
            (test_diagram_bdd, None),
            (test_diagram_ibd, None),
            (test_diagram_not_found, None),
            (test_pair_files_list, None),
            (test_pairs_get, None),
            (test_pairs_not_found, None),
            (test_save_pairs, None),
            (test_save_pairs_auto_extension, None),
            (test_save_pairs_default_filename, None),
            (test_save_pairs_invalid, None),
            (test_save_pairs_security, None),
            (test_serve_index, "Static File Serving Tests"),
            (test_serve_app_js, None),
            (test_serve_css, None),
            (test_static_not_found, None),
            (test_static_path_traversal, None),
            (test_tree_endpoint, "Tree Endpoint Tests"),
            (test_tree_custom_root, None),
            (test_tree_invalid_path, None),
            (test_malformed_json, "Error Handling Tests"),
            (test_unknown_endpoint, None),
            (test_post_to_get_endpoint, None),
            (test_concurrent_health, "Concurrency Tests"),
            (test_concurrent_architecture_reads, None),
            (test_concurrent_saves, None),
            (test_large_pair_save, "Large Data Tests"),
            (test_large_architecture_parsing, None),
            (test_content_type_headers, "Content-Type and Header Tests"),
            (test_content_length_header, None),
            (test_empty_pair_save, "Edge Cases Tests"),
            (test_special_characters_filename, None),
            (test_unicode_content, None),
            (test_response_time, "Performance Tests"),
            (test_architecture_list_performance, None),
        ]

        current_section = None
        for func, section in test_functions:
            if section and section != current_section:
                print(f"\n{section}")
                print("-" * 70)
                current_section = section
            func()

    finally:
        server.stop()

    # Print summary
    print("\n" + "=" * 70)
    print("  TEST SUMMARY")
    print("=" * 70)
    print(f"  Passed:  {test_results['passed']}")
    print(f"  Failed:  {test_results['failed']}")
    print(f"  Skipped: {test_results['skipped']}")

    if test_results['errors']:
        print("\n  Failed Tests:")
        for name, error in test_results['errors']:
            print(f"    - {name}: {error}")

    print("=" * 70 + "\n")

    return 0 if test_results['failed'] == 0 else 1


# ============================================
# Test Functions
# ============================================

@test("Health endpoint returns correct status")
def test_health_endpoint():
    status, data, headers = server.request('/api/health')
    assert status == 200, f"Expected 200, got {status}"
    assert data['ok'] is True, "Expected ok=True"
    assert data['npm_required'] is False, "Expected npm_required=False"
    assert 'application/json' in headers.get('Content-Type', ''), "Expected JSON content type"


@test("Health endpoint handles multiple rapid calls")
def test_health_multiple_calls():
    for i in range(10):
        status, data, _ = server.request('/api/health')
        assert status == 200, f"Call {i} failed with status {status}"
        assert data['ok'] is True, f"Call {i} returned ok=False"


@test("List architectures")
def test_architectures_list():
    status, data, _ = server.request('/api/architectures')
    assert status == 200, f"Expected 200, got {status}"
    assert 'architectures' in data, "Missing architectures key"
    assert isinstance(data['architectures'], list), "architectures should be a list"


@test("Get architecture by path")
def test_architecture_get():
    status, data, _ = server.request('/api/architectures')
    if len(data['architectures']) == 0:
        skip("No architectures available")

    arch = data['architectures'][0]
    path = arch['path']
    encoded_path = quote(path, safe='')

    status, arch_data, _ = server.request(f'/api/architecture/{encoded_path}')
    assert status == 200, f"Expected 200, got {status}"
    assert 'id' in arch_data, "Missing id"
    assert 'blocks' in arch_data, "Missing blocks"
    assert 'connectors' in arch_data, "Missing connectors"


@test("Architecture not found returns 404")
def test_architecture_not_found():
    status, data, _ = server.request('/api/architecture/data%2Farchitectures%2Fnonexistent.sysml')
    assert status == 404, f"Expected 404, got {status}"
    assert 'error' in data, "Expected error message"


@test("Architecture path traversal blocked")
def test_architecture_path_traversal():
    status, data, _ = server.request('/api/architecture/..%2F..%2Fetc%2Fpasswd')
    assert status in (400, 404, 500), f"Expected error status, got {status}"
    assert 'error' in data, "Expected error message"


@test("Load separated format architecture")
def test_architecture_separated_format():
    status, data, _ = server.request('/api/architectures')
    separated_arch = None
    for arch in data['architectures']:
        if arch.get('format') == 'separated':
            separated_arch = arch
            break

    if separated_arch is None:
        skip("No separated format architectures available")

    path = separated_arch['path']
    encoded_path = quote(path, safe='')
    status, arch_data, _ = server.request(f'/api/architecture/{encoded_path}')

    assert status == 200, f"Expected 200, got {status}"
    assert 'format' in arch_data, "Missing format"
    assert arch_data['format'] == 'separated', "Should be separated format"


@test("List views for separated architecture")
def test_architecture_views_list():
    status, data, _ = server.request('/api/architectures')
    separated_arch = None
    for arch in data['architectures']:
        if arch.get('format') == 'separated':
            separated_arch = arch
            break

    if separated_arch is None:
        skip("No separated format architectures available")

    path = separated_arch['path']
    encoded_path = quote(path, safe='')
    status, views_data, _ = server.request(f'/api/architecture/{encoded_path}/views')

    assert status == 200, f"Expected 200, got {status}"
    assert 'views' in views_data, "Missing views key"
    assert 'format' in views_data, "Missing format key"


@test("Get specific view from separated architecture")
def test_architecture_view_get():
    status, data, _ = server.request('/api/architectures')
    separated_arch = None
    for arch in data['architectures']:
        if arch.get('format') == 'separated' and arch.get('available_views'):
            separated_arch = arch
            break

    if separated_arch is None:
        skip("No separated format architectures with views available")

    path = separated_arch['path']
    view_name = separated_arch['available_views'][0]
    encoded_path = quote(path, safe='')
    status, view_data, _ = server.request(f'/api/architecture/{encoded_path}/view/{view_name}')

    assert status == 200, f"Expected 200, got {status}"
    assert 'view' in view_data, "Missing view key"
    assert view_data['view']['name'] == view_name, f"Expected view name {view_name}"


@test("Generate BDD diagram")
def test_diagram_bdd():
    status, data, _ = server.request('/api/architectures')
    if len(data['architectures']) == 0:
        skip("No architectures available")

    arch = data['architectures'][0]
    path = arch['path']
    encoded_path = quote(path, safe='')

    status, diagram_data, _ = server.request(f'/api/diagram/bdd/{encoded_path}')
    assert status == 200, f"Expected 200, got {status}"
    assert 'plantuml' in diagram_data, "Missing plantuml source"
    assert '@startuml' in diagram_data['plantuml'], "Invalid PlantUML source"
    assert 'url' in diagram_data, "Missing PlantUML URL"


@test("Generate IBD diagram")
def test_diagram_ibd():
    status, data, _ = server.request('/api/architectures')
    if len(data['architectures']) == 0:
        skip("No architectures available")

    arch = data['architectures'][0]
    path = arch['path']
    encoded_path = quote(path, safe='')

    status, diagram_data, _ = server.request(f'/api/diagram/ibd/{encoded_path}')
    assert status == 200, f"Expected 200, got {status}"
    assert 'plantuml' in diagram_data, "Missing plantuml source"
    assert 'component' in diagram_data['plantuml'].lower(), "Should contain component"


@test("Diagram for non-existent architecture returns 404")
def test_diagram_not_found():
    status, data, _ = server.request('/api/diagram/bdd/data%2Farchitectures%2Fnonexistent.sysml')
    assert status == 404, f"Expected 404, got {status}"
    assert 'error' in data, "Expected error message"


@test("List pair files")
def test_pair_files_list():
    status, data, _ = server.request('/api/pair-files')
    assert status == 200, f"Expected 200, got {status}"
    assert 'pair_files' in data, "Missing pair_files key"
    assert isinstance(data['pair_files'], list), "pair_files should be a list"


@test("Get pair file contents")
def test_pairs_get():
    status, data, _ = server.request('/api/pair-files')
    if len(data['pair_files']) == 0:
        skip("No pair files available")

    pair_file = data['pair_files'][0]
    path = pair_file['path']
    encoded_path = quote(path, safe='')
    status, pairs_data, _ = server.request(f'/api/pairs/{encoded_path}')

    assert status == 200, f"Expected 200, got {status}"
    assert isinstance(pairs_data, list), "Pairs should be a list"


@test("Pair file not found returns 404")
def test_pairs_not_found():
    status, data, _ = server.request('/api/pairs/data%2Fpairs%2Fnonexistent.json')
    assert status == 404, f"Expected 404, got {status}"
    assert 'error' in data, "Expected error message"


@test("Save pairs")
def test_save_pairs():
    test_pairs = [
        {"description": "Test 1", "sysml": "package test1 { part def A; }"},
        {"description": "Test 2", "sysml": "package test2 { part def B; }"}
    ]

    payload = {'filename': 'test_integration.json', 'records': test_pairs}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 200, f"Expected 200, got {status}"
    assert response['ok'] is True, "Expected ok=True"
    assert response['records'] == 2, "Expected 2 records"


@test("Save pairs auto-adds .json extension")
def test_save_pairs_auto_extension():
    test_pairs = [{"description": "test", "sysml": "package test {}"}]
    payload = {'filename': 'test_no_ext', 'records': test_pairs}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 200, f"Expected 200, got {status}"
    assert response['path'].endswith('.json'), "Should add .json extension"


@test("Save pairs uses default filename")
def test_save_pairs_default_filename():
    test_pairs = [{"description": "test", "sysml": "package test {}"}]
    payload = {'records': test_pairs}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 200, f"Expected 200, got {status}"
    assert 'authored_pairs.json' in response['path'], "Should use default filename"


@test("Save pairs with invalid records")
def test_save_pairs_invalid():
    payload = {'filename': 'test_invalid.json', 'records': "not a list"}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 400, f"Expected 400, got {status}"
    assert 'error' in response, "Expected error message"


@test("Save pairs blocks path traversal")
def test_save_pairs_security():
    test_pairs = [{"description": "test", "sysml": "package test {}"}]
    payload = {'filename': '../../etc/test.json', 'records': test_pairs}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 200, "Should succeed"
    assert 'data/pairs/test.json' in response['path'], "Should normalize path"
    assert '../' not in response['path'], "Should not contain path traversal"


@test("Serve index.html")
def test_serve_index():
    status, data, headers = server.request('/')
    assert status == 200, f"Expected 200, got {status}"
    assert 'Adapter Pair Authoring SPA' in data, "Should contain page title"
    assert 'text/html' in headers.get('Content-Type', ''), "Should be HTML"


@test("Serve app.js")
def test_serve_app_js():
    status, data, headers = server.request('/app.js')
    assert status == 200, f"Expected 200, got {status}"
    assert 'javascript' in headers.get('Content-Type', '').lower(), "Should be JavaScript"


@test("Serve style.css")
def test_serve_css():
    status, data, headers = server.request('/style.css')
    assert status == 200, f"Expected 200, got {status}"
    assert 'text/css' in headers.get('Content-Type', ''), "Should be CSS"


@test("Static file not found")
def test_static_not_found():
    status, data, _ = server.request('/nonexistent.js')
    assert status == 404, f"Expected 404, got {status}"


@test("Static path traversal blocked")
def test_static_path_traversal():
    status, data, _ = server.request('/../../../etc/passwd')
    assert status in (400, 404), f"Expected error status, got {status}"
    assert 'error' in data, "Expected error message"


@test("Tree endpoint")
def test_tree_endpoint():
    status, data, _ = server.request('/api/tree')
    assert status == 200, f"Expected 200, got {status}"
    assert 'type' in data, "Missing type"
    assert data['type'] == 'directory', "Should be directory"
    assert 'children' in data, "Missing children"


@test("Tree endpoint with custom root")
def test_tree_custom_root():
    with tempfile.TemporaryDirectory() as tmpdir:
        test_file = Path(tmpdir) / 'test.txt'
        test_file.write_text('test content')

        status, data, _ = server.request(f'/api/tree?root={quote(tmpdir)}')
        assert status == 200, f"Expected 200, got {status}"
        assert 'children' in data, "Missing children"

        file_names = [child['name'] for child in data['children']]
        assert 'test.txt' in file_names, "Should include test file"


@test("Tree endpoint with invalid path")
def test_tree_invalid_path():
    status, data, _ = server.request('/api/tree?root=/nonexistent/path/12345')
    assert status == 400, f"Expected 400, got {status}"
    assert 'error' in data, "Expected error message"


@test("Malformed JSON POST")
def test_malformed_json():
    try:
        req = urllib.request.Request(
            server.url + '/api/save-pairs',
            data=b'{invalid json}',
            headers={'Content-Type': 'application/json'},
            method='POST'
        )
        with urllib.request.urlopen(req, timeout=5) as response:
            status = response.status
    except urllib.error.HTTPError as e:
        status = e.code

    assert status == 500, f"Expected 500 for malformed JSON, got {status}"


@test("Unknown endpoint returns 404")
def test_unknown_endpoint():
    status, data, _ = server.request('/api/unknown-endpoint')
    assert status == 404, f"Expected 404, got {status}"


@test("POST to GET-only endpoint")
def test_post_to_get_endpoint():
    status, data, _ = server.request('/api/health', method='POST', data={})
    # Server may return 404 or 405 or 500, but should error
    assert status >= 400, f"Expected error status, got {status}"


@test("Concurrent health requests")
def test_concurrent_health():
    results = []

    def make_request():
        status, data, _ = server.request('/api/health')
        results.append((status, data))

    threads = [threading.Thread(target=make_request) for _ in range(10)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    assert len(results) == 10, "Should have 10 results"
    for status, data in results:
        assert status == 200, f"Expected 200, got {status}"
        assert data['ok'] is True, "Expected ok=True"


@test("Concurrent architecture reads")
def test_concurrent_architecture_reads():
    status, data, _ = server.request('/api/architectures')
    if len(data['architectures']) == 0:
        skip("No architectures available")

    path = data['architectures'][0]['path']
    encoded_path = quote(path, safe='')
    results = []

    def make_request():
        status, arch_data, _ = server.request(f'/api/architecture/{encoded_path}')
        results.append((status, arch_data))

    threads = [threading.Thread(target=make_request) for _ in range(5)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    assert len(results) == 5, "Should have 5 results"
    for status, arch_data in results:
        assert status == 200, f"Expected 200, got {status}"
        assert 'id' in arch_data, "Missing id"


@test("Concurrent saves")
def test_concurrent_saves():
    results = []

    def save_pairs(index):
        test_pairs = [{
            "description": f"Concurrent test {index}",
            "sysml": f"package test{index} {{ part def Test{index}; }}"
        }]
        payload = {'filename': f'test_concurrent_{index}.json', 'records': test_pairs}
        status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)
        results.append((status, response, index))

    threads = [threading.Thread(target=save_pairs, args=(i,)) for i in range(5)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    assert len(results) == 5, "Should have 5 results"
    for status, response, index in results:
        assert status == 200, f"Save {index} failed with status {status}"
        assert response['ok'] is True, f"Save {index} returned ok=False"


@test("Large pair save")
def test_large_pair_save():
    large_pairs = []
    for i in range(50):
        large_pairs.append({
            "description": f"Large test architecture {i}",
            "sysml": f"package large_test_{i} {{ part def Block{i} {{ attribute x : Real; }} }}"
        })

    payload = {'filename': 'test_large.json', 'records': large_pairs}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 200, f"Expected 200, got {status}"
    assert response['ok'] is True, "Expected ok=True"
    assert response['records'] == 50, "Expected 50 records"


@test("Large architecture file parsing")
def test_large_architecture_parsing():
    # Create a large .sysml file
    large_sysml = ["package large_test {"]
    for i in range(30):
        large_sysml.append(f"    part def Block{i} {{ attribute attr{i} : Real; }}")
    large_sysml.append("}")

    arch_dir = PROJECT_ROOT / 'data' / 'architectures'
    arch_dir.mkdir(parents=True, exist_ok=True)
    large_file = arch_dir / 'test_large_integration.sysml'
    large_file.write_text('\n'.join(large_sysml))

    try:
        encoded_path = quote('data/architectures/test_large_integration.sysml', safe='')
        status, arch_data, _ = server.request(f'/api/architecture/{encoded_path}')

        assert status == 200, f"Expected 200, got {status}"
        assert 'blocks' in arch_data, "Missing blocks"
        assert len(arch_data['blocks']) >= 30, f"Expected at least 30 blocks, got {len(arch_data['blocks'])}"
    finally:
        if large_file.exists():
            large_file.unlink()


@test("JSON endpoints return correct Content-Type")
def test_content_type_headers():
    endpoints = ['/api/health', '/api/architectures', '/api/pair-files', '/api/tree']

    for endpoint in endpoints:
        status, data, headers = server.request(endpoint)
        assert status == 200, f"{endpoint} returned {status}"
        assert 'application/json' in headers.get('Content-Type', ''), \
            f"{endpoint} did not return JSON content type"


@test("Responses include Content-Length header")
def test_content_length_header():
    status, data, headers = server.request('/api/health')
    assert status == 200, f"Expected 200, got {status}"
    assert 'Content-Length' in headers, "Missing Content-Length header"
    assert int(headers['Content-Length']) > 0, "Content-Length should be positive"


@test("Empty pair save")
def test_empty_pair_save():
    payload = {'filename': 'test_empty.json', 'records': []}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 200, f"Expected 200, got {status}"
    assert response['ok'] is True, "Expected ok=True"
    assert response['records'] == 0, "Expected 0 records"


@test("Filename with special characters")
def test_special_characters_filename():
    test_pairs = [{"description": "test", "sysml": "package test {}"}]
    # Server should handle or sanitize special characters
    payload = {'filename': 'test-file_123.json', 'records': test_pairs}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 200, f"Expected 200, got {status}"
    assert response['ok'] is True, "Expected ok=True"


@test("Unicode content in pairs")
def test_unicode_content():
    test_pairs = [{
        "description": "Architecture with unicode: 中文, العربية, 日本語",
        "sysml": "package test { /* Unicode comment: café, naïve */ part def TestBlock; }"
    }]

    payload = {'filename': 'test_unicode.json', 'records': test_pairs}
    status, response, _ = server.request('/api/save-pairs', method='POST', data=payload)

    assert status == 200, f"Expected 200, got {status}"
    assert response['ok'] is True, "Expected ok=True"

    # Verify we can read it back
    path = response['path']
    encoded_path = quote(path, safe='')
    status, pairs_data, _ = server.request(f'/api/pairs/{encoded_path}')

    assert status == 200, f"Expected 200, got {status}"
    assert len(pairs_data) > 0, "Should have pairs"
    assert '中文' in pairs_data[0]['description'], "Unicode should be preserved"


@test("Health endpoint response time")
def test_response_time():
    times = []
    for _ in range(5):
        start = time.time()
        status, data, _ = server.request('/api/health')
        elapsed = time.time() - start
        times.append(elapsed)

    avg_time = sum(times) / len(times)
    assert avg_time < 0.5, f"Average response time {avg_time:.3f}s is too slow"


@test("Architecture list performance")
def test_architecture_list_performance():
    start = time.time()
    status, data, _ = server.request('/api/architectures')
    elapsed = time.time() - start

    assert status == 200, f"Expected 200, got {status}"
    # Should complete within 3 seconds even with many files
    assert elapsed < 3.0, f"Response time {elapsed:.3f}s is too slow"


if __name__ == '__main__':
    sys.exit(run_tests())
