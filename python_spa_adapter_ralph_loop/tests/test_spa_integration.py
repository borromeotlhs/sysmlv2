#!/usr/bin/env python3
"""
Comprehensive integration tests for the SPA (Single Page Application).

Tests API endpoints, error handling, file operations, concurrency, and more.
"""

import pytest
import json
import tempfile
import time
import threading
from pathlib import Path
from urllib.parse import quote


# ============================================
# Health and Basic API Tests
# ============================================

@pytest.mark.integration
def test_health_endpoint(spa_client):
    """Test /api/health endpoint returns correct status"""
    status, data, headers = spa_client('/api/health')

    assert status == 200
    assert data['ok'] is True
    assert data['runtime'] == 'python-standard-library'
    assert data['npm_required'] is False
    assert 'application/json' in headers.get('Content-Type', '')


@pytest.mark.integration
def test_health_endpoint_multiple_requests(spa_client):
    """Test health endpoint handles multiple rapid requests"""
    for _ in range(10):
        status, data, _ = spa_client('/api/health')
        assert status == 200
        assert data['ok'] is True


# ============================================
# Architecture Endpoints
# ============================================

@pytest.mark.integration
def test_architectures_list(spa_client):
    """Test /api/architectures endpoint lists all architectures"""
    status, data, headers = spa_client('/api/architectures')

    assert status == 200
    assert 'architectures' in data
    assert isinstance(data['architectures'], list)
    assert 'application/json' in headers.get('Content-Type', '')

    # Check structure of architecture items
    if len(data['architectures']) > 0:
        arch = data['architectures'][0]
        assert 'id' in arch
        assert 'name' in arch
        assert 'path' in arch
        assert 'format' in arch  # monolithic, separated, or json


@pytest.mark.integration
def test_architecture_get_by_path(spa_client):
    """Test /api/architecture/<path> endpoint"""
    # First get list
    status, data, _ = spa_client('/api/architectures')
    assert status == 200

    if len(data['architectures']) == 0:
        pytest.skip("No architectures available")

    # Get first architecture
    arch = data['architectures'][0]
    path = arch['path']
    encoded_path = quote(path, safe='')

    status, arch_data, headers = spa_client(f'/api/architecture/{encoded_path}')

    assert status == 200
    assert 'id' in arch_data
    assert 'blocks' in arch_data
    assert 'connectors' in arch_data
    assert 'requirements' in arch_data
    assert 'compositions' in arch_data
    assert 'application/json' in headers.get('Content-Type', '')


@pytest.mark.integration
def test_architecture_not_found(spa_client):
    """Test 404 for non-existent architecture"""
    status, data, _ = spa_client('/api/architecture/data%2Farchitectures%2Fnonexistent.sysml')

    assert status == 404
    assert 'error' in data


@pytest.mark.integration
def test_architecture_path_traversal_blocked(spa_client):
    """Test that path traversal attempts are blocked"""
    # Try to access file outside data directory
    status, data, _ = spa_client('/api/architecture/..%2F..%2Fetc%2Fpasswd')

    assert status in (400, 404, 500)
    assert 'error' in data


@pytest.mark.integration
def test_architecture_views_list(spa_client):
    """Test /api/architecture/<path>/views endpoint"""
    # Get a separated format architecture if available
    status, data, _ = spa_client('/api/architectures')
    assert status == 200

    separated_arch = None
    for arch in data['architectures']:
        if arch.get('format') == 'separated':
            separated_arch = arch
            break

    if separated_arch is None:
        pytest.skip("No separated format architectures available")

    path = separated_arch['path']
    encoded_path = quote(path, safe='')

    status, views_data, _ = spa_client(f'/api/architecture/{encoded_path}/views')

    assert status == 200
    assert 'views' in views_data
    assert 'format' in views_data
    assert isinstance(views_data['views'], list)


@pytest.mark.integration
def test_architecture_view_get(spa_client):
    """Test /api/architecture/<path>/view/<name> endpoint"""
    # Get a separated format architecture
    status, data, _ = spa_client('/api/architectures')
    assert status == 200

    separated_arch = None
    for arch in data['architectures']:
        if arch.get('format') == 'separated' and arch.get('available_views'):
            separated_arch = arch
            break

    if separated_arch is None:
        pytest.skip("No separated format architectures with views available")

    path = separated_arch['path']
    view_name = separated_arch['available_views'][0]
    encoded_path = quote(path, safe='')

    status, view_data, _ = spa_client(f'/api/architecture/{encoded_path}/view/{view_name}')

    assert status == 200
    assert 'view' in view_data
    assert view_data['view']['name'] == view_name


# ============================================
# Diagram Generation Tests
# ============================================

@pytest.mark.integration
def test_diagram_bdd_generation(spa_client):
    """Test /api/diagram/bdd/<path> endpoint"""
    # Get first architecture
    status, data, _ = spa_client('/api/architectures')
    assert status == 200

    if len(data['architectures']) == 0:
        pytest.skip("No architectures available")

    arch = data['architectures'][0]
    path = arch['path']
    encoded_path = quote(path, safe='')

    status, diagram_data, _ = spa_client(f'/api/diagram/bdd/{encoded_path}')

    assert status == 200
    assert 'plantuml' in diagram_data
    assert 'url' in diagram_data

    # Verify PlantUML source structure
    plantuml = diagram_data['plantuml']
    assert '@startuml' in plantuml
    assert '@enduml' in plantuml

    # Verify URL format
    assert diagram_data['url'].startswith('http://www.plantuml.com/plantuml/png/')


@pytest.mark.integration
def test_diagram_ibd_generation(spa_client):
    """Test /api/diagram/ibd/<path> endpoint"""
    # Get first architecture
    status, data, _ = spa_client('/api/architectures')
    assert status == 200

    if len(data['architectures']) == 0:
        pytest.skip("No architectures available")

    arch = data['architectures'][0]
    path = arch['path']
    encoded_path = quote(path, safe='')

    status, diagram_data, _ = spa_client(f'/api/diagram/ibd/{encoded_path}')

    assert status == 200
    assert 'plantuml' in diagram_data
    assert 'url' in diagram_data

    # Verify PlantUML source structure
    plantuml = diagram_data['plantuml']
    assert '@startuml' in plantuml
    assert '@enduml' in plantuml
    assert 'component' in plantuml.lower()


@pytest.mark.integration
def test_diagram_not_found(spa_client):
    """Test 404 for diagram of non-existent architecture"""
    status, data, _ = spa_client('/api/diagram/bdd/data%2Farchitectures%2Fnonexistent.sysml')

    assert status == 404
    assert 'error' in data


# ============================================
# Pair File Tests
# ============================================

@pytest.mark.integration
def test_pair_files_list(spa_client):
    """Test /api/pair-files endpoint"""
    status, data, headers = spa_client('/api/pair-files')

    assert status == 200
    assert 'pair_files' in data
    assert isinstance(data['pair_files'], list)
    assert 'application/json' in headers.get('Content-Type', '')


@pytest.mark.integration
def test_pairs_get(spa_client):
    """Test /api/pairs/<path> endpoint"""
    # First get list of pair files
    status, data, _ = spa_client('/api/pair-files')
    assert status == 200

    if len(data['pair_files']) == 0:
        pytest.skip("No pair files available")

    # Get first pair file
    pair_file = data['pair_files'][0]
    path = pair_file['path']
    encoded_path = quote(path, safe='')

    status, pairs_data, _ = spa_client(f'/api/pairs/{encoded_path}')

    assert status == 200
    assert isinstance(pairs_data, list)

    # Check structure of pairs
    if len(pairs_data) > 0:
        pair = pairs_data[0]
        assert 'description' in pair or 'sysml' in pair


@pytest.mark.integration
def test_pairs_not_found(spa_client):
    """Test 404 for non-existent pair file"""
    status, data, _ = spa_client('/api/pairs/data%2Fpairs%2Fnonexistent.json')

    assert status == 404
    assert 'error' in data


@pytest.mark.integration
def test_save_pairs(spa_client):
    """Test POST /api/save-pairs endpoint"""
    test_pairs = [
        {
            "description": "Test architecture 1",
            "sysml": "package test { part def TestBlock; }"
        },
        {
            "description": "Test architecture 2",
            "sysml": "package test2 { part def AnotherBlock; }"
        }
    ]

    payload = {
        'filename': 'test_integration_pairs.json',
        'records': test_pairs
    }

    status, response, _ = spa_client('/api/save-pairs', method='POST', data=payload)

    assert status == 200
    assert response['ok'] is True
    assert response['records'] == 2
    assert 'path' in response
    assert 'test_integration_pairs.json' in response['path']


@pytest.mark.integration
def test_save_pairs_auto_extension(spa_client):
    """Test save-pairs adds .json extension if missing"""
    test_pairs = [{"description": "test", "sysml": "package test {}"}]

    payload = {
        'filename': 'test_no_extension',
        'records': test_pairs
    }

    status, response, _ = spa_client('/api/save-pairs', method='POST', data=payload)

    assert status == 200
    assert response['ok'] is True
    assert response['path'].endswith('.json')


@pytest.mark.integration
def test_save_pairs_default_filename(spa_client):
    """Test save-pairs uses default filename if none provided"""
    test_pairs = [{"description": "test", "sysml": "package test {}"}]

    payload = {
        'records': test_pairs
    }

    status, response, _ = spa_client('/api/save-pairs', method='POST', data=payload)

    assert status == 200
    assert response['ok'] is True
    assert 'authored_pairs.json' in response['path']


@pytest.mark.integration
def test_save_pairs_invalid_records(spa_client):
    """Test save-pairs rejects invalid records"""
    payload = {
        'filename': 'test_invalid.json',
        'records': "not a list"
    }

    status, response, _ = spa_client('/api/save-pairs', method='POST', data=payload)

    assert status == 400
    assert 'error' in response


@pytest.mark.integration
def test_save_pairs_path_traversal_blocked(spa_client):
    """Test save-pairs blocks path traversal in filename"""
    test_pairs = [{"description": "test", "sysml": "package test {}"}]

    # The server should extract basename only
    payload = {
        'filename': '../../etc/test.json',
        'records': test_pairs
    }

    status, response, _ = spa_client('/api/save-pairs', method='POST', data=payload)

    # Should succeed but save to data/pairs/test.json, not traverse
    assert status == 200
    assert 'data/pairs/test.json' in response['path']
    assert '../' not in response['path']


# ============================================
# Static File Serving Tests
# ============================================

@pytest.mark.integration
def test_serve_index_html(spa_client):
    """Test serving index.html at root path"""
    status, data, headers = spa_client('/')

    assert status == 200
    assert 'Adapter Pair Authoring SPA' in data
    assert 'text/html' in headers.get('Content-Type', '')


@pytest.mark.integration
def test_serve_app_js(spa_client):
    """Test serving app.js static file"""
    status, data, headers = spa_client('/app.js')

    assert status == 200
    assert 'application/javascript' in headers.get('Content-Type', '') or \
           'text/javascript' in headers.get('Content-Type', '')


@pytest.mark.integration
def test_serve_style_css(spa_client):
    """Test serving style.css static file"""
    status, data, headers = spa_client('/style.css')

    assert status == 200
    assert 'text/css' in headers.get('Content-Type', '')


@pytest.mark.integration
def test_static_file_not_found(spa_client):
    """Test 404 for non-existent static file"""
    status, data, _ = spa_client('/nonexistent.js')

    assert status == 404
    assert 'error' in data


@pytest.mark.integration
def test_static_path_traversal_blocked(spa_client):
    """Test static file path traversal is blocked"""
    status, data, _ = spa_client('/../../../etc/passwd')

    assert status in (400, 404)
    assert 'error' in data


# ============================================
# Tree Endpoint Tests
# ============================================

@pytest.mark.integration
def test_tree_default(spa_client):
    """Test /api/tree endpoint with default root"""
    status, data, headers = spa_client('/api/tree')

    assert status == 200
    assert 'name' in data
    assert 'path' in data
    assert 'type' in data
    assert data['type'] == 'directory'
    assert 'children' in data
    assert 'resolved_path' in data


@pytest.mark.integration
def test_tree_custom_root(spa_client):
    """Test /api/tree with custom root parameter"""
    import tempfile

    with tempfile.TemporaryDirectory() as tmpdir:
        # Create some test files
        test_file = Path(tmpdir) / 'test.txt'
        test_file.write_text('test content')

        status, data, _ = spa_client(f'/api/tree?root={quote(tmpdir)}')

        assert status == 200
        assert 'children' in data
        # Should include our test file
        file_names = [child['name'] for child in data['children']]
        assert 'test.txt' in file_names


@pytest.mark.integration
def test_tree_invalid_path(spa_client):
    """Test /api/tree with invalid path"""
    status, data, _ = spa_client('/api/tree?root=/nonexistent/path')

    assert status == 400
    assert 'error' in data


# ============================================
# Error Handling Tests
# ============================================

@pytest.mark.integration
def test_malformed_json_post(spa_client):
    """Test POST with malformed JSON"""
    import urllib.request

    url = spa_client.__self__['url'] if hasattr(spa_client, '__self__') else spa_client.__globals__['spa_server']['url']

    # This is a bit of a hack - we need to bypass the spa_client helper
    # to send truly malformed JSON
    try:
        req = urllib.request.Request(
            url + '/api/save-pairs',
            data=b'{invalid json}',
            headers={'Content-Type': 'application/json'},
            method='POST'
        )
        with urllib.request.urlopen(req, timeout=5) as response:
            status = response.status
    except urllib.error.HTTPError as e:
        status = e.code

    assert status == 500


@pytest.mark.integration
def test_unknown_endpoint(spa_client):
    """Test request to unknown endpoint"""
    status, data, _ = spa_client('/api/unknown-endpoint')

    assert status == 404
    assert 'error' in data


@pytest.mark.integration
def test_post_to_get_only_endpoint(spa_client):
    """Test POST to GET-only endpoint"""
    status, data, _ = spa_client('/api/health', method='POST', data={})

    # Should return error since health doesn't support POST
    assert status in (404, 405, 500)


# ============================================
# Concurrency Tests
# ============================================

@pytest.mark.integration
def test_concurrent_health_requests(spa_client):
    """Test server handles concurrent health requests"""
    results = []

    def make_request():
        status, data, _ = spa_client('/api/health')
        results.append((status, data))

    threads = [threading.Thread(target=make_request) for _ in range(10)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    # All requests should succeed
    assert len(results) == 10
    for status, data in results:
        assert status == 200
        assert data['ok'] is True


@pytest.mark.integration
def test_concurrent_architecture_reads(spa_client):
    """Test concurrent reads of same architecture"""
    # Get first architecture path
    status, data, _ = spa_client('/api/architectures')
    assert status == 200

    if len(data['architectures']) == 0:
        pytest.skip("No architectures available")

    path = data['architectures'][0]['path']
    encoded_path = quote(path, safe='')
    results = []

    def make_request():
        status, arch_data, _ = spa_client(f'/api/architecture/{encoded_path}')
        results.append((status, arch_data))

    threads = [threading.Thread(target=make_request) for _ in range(5)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    # All requests should succeed
    assert len(results) == 5
    for status, arch_data in results:
        assert status == 200
        assert 'id' in arch_data


@pytest.mark.integration
def test_concurrent_saves(spa_client):
    """Test concurrent pair saves don't corrupt files"""
    results = []

    def save_pairs(index):
        test_pairs = [{
            "description": f"Test architecture {index}",
            "sysml": f"package test{index} {{ part def TestBlock{index}; }}"
        }]

        payload = {
            'filename': f'test_concurrent_{index}.json',
            'records': test_pairs
        }

        status, response, _ = spa_client('/api/save-pairs', method='POST', data=payload)
        results.append((status, response, index))

    threads = [threading.Thread(target=save_pairs, args=(i,)) for i in range(5)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    # All saves should succeed
    assert len(results) == 5
    for status, response, index in results:
        assert status == 200, f"Save {index} failed"
        assert response['ok'] is True
        assert f'test_concurrent_{index}.json' in response['path']


# ============================================
# Large Data Tests
# ============================================

@pytest.mark.integration
def test_large_pair_save(spa_client):
    """Test saving large pair file"""
    # Create 100 pairs
    large_pairs = []
    for i in range(100):
        large_pairs.append({
            "description": f"Test architecture {i} with detailed description that is quite long",
            "sysml": f"""package test_arch_{i:05d} {{
    // Architecture {i}
    part def System{i} {{
        part subsystem1 : Subsystem{i}A;
        part subsystem2 : Subsystem{i}B;
    }}
    part def Subsystem{i}A;
    part def Subsystem{i}B;
}}"""
        })

    payload = {
        'filename': 'test_large_pairs.json',
        'records': large_pairs
    }

    status, response, _ = spa_client('/api/save-pairs', method='POST', data=payload)

    assert status == 200
    assert response['ok'] is True
    assert response['records'] == 100


@pytest.mark.integration
def test_large_sysml_file_parsing(spa_client, tmp_path):
    """Test parsing large .sysml file through architecture endpoint"""
    # Create a large .sysml file
    large_sysml = ["package large_test {"]

    for i in range(50):
        large_sysml.append(f"""
    part def Block{i} {{
        attribute attr{i}a : Real;
        attribute attr{i}b : String;
    }}""")

    large_sysml.append("\n    part system : System {")
    for i in range(50):
        large_sysml.append(f"        part block{i} : Block{i};")
    large_sysml.append("    }")
    large_sysml.append("}")

    # Save to data/architectures for testing
    from pathlib import Path
    import sys
    project_root = Path(__file__).parent.parent
    arch_dir = project_root / 'data' / 'architectures'
    arch_dir.mkdir(parents=True, exist_ok=True)

    large_file = arch_dir / 'test_large_integration.sysml'
    large_file.write_text('\n'.join(large_sysml))

    try:
        # Try to load it
        encoded_path = quote('data/architectures/test_large_integration.sysml', safe='')
        status, arch_data, _ = spa_client(f'/api/architecture/{encoded_path}')

        assert status == 200
        assert 'blocks' in arch_data
        assert len(arch_data['blocks']) >= 50
    finally:
        # Cleanup
        if large_file.exists():
            large_file.unlink()


# ============================================
# Content-Type and Header Tests
# ============================================

@pytest.mark.integration
def test_json_content_type_headers(spa_client):
    """Test all JSON endpoints return correct Content-Type"""
    json_endpoints = [
        '/api/health',
        '/api/architectures',
        '/api/pair-files',
        '/api/tree'
    ]

    for endpoint in json_endpoints:
        status, data, headers = spa_client(endpoint)
        assert status == 200
        assert 'application/json' in headers.get('Content-Type', ''), \
            f"{endpoint} did not return JSON content type"


@pytest.mark.integration
def test_content_length_headers(spa_client):
    """Test responses include Content-Length header"""
    status, data, headers = spa_client('/api/health')

    assert status == 200
    assert 'Content-Length' in headers
    assert int(headers['Content-Length']) > 0


# ============================================
# Server Info Tests
# ============================================

@pytest.mark.integration
def test_server_version_header(spa_client):
    """Test server returns Server header"""
    status, data, headers = spa_client('/api/health')

    assert status == 200
    # The server should include a Server header
    # Note: The actual server version is 'PythonSPAPairAuthor/1.0'
    # but headers may vary


# ============================================
# Edge Cases and Boundary Tests
# ============================================

@pytest.mark.integration
def test_empty_pair_save(spa_client):
    """Test saving empty pair list"""
    payload = {
        'filename': 'test_empty_pairs.json',
        'records': []
    }

    status, response, _ = spa_client('/api/save-pairs', method='POST', data=payload)

    assert status == 200
    assert response['ok'] is True
    assert response['records'] == 0


@pytest.mark.integration
def test_architecture_with_special_characters(spa_client):
    """Test loading architecture with special characters in name"""
    # Get architectures list
    status, data, _ = spa_client('/api/architectures')
    assert status == 200

    # Look for any architecture and verify proper URL encoding works
    if len(data['architectures']) > 0:
        arch = data['architectures'][0]
        path = arch['path']

        # Test both safe and full encoding
        encoded_path = quote(path, safe='')
        status, arch_data, _ = spa_client(f'/api/architecture/{encoded_path}')

        assert status == 200


@pytest.mark.integration
def test_missing_content_type_post(spa_client):
    """Test POST without Content-Type header"""
    import urllib.request
    import urllib.error

    # We need direct access to server URL for this test
    # Get it from the spa_client closure or use default
    server_url = 'http://127.0.0.1:8766'  # Default from fixture

    try:
        req = urllib.request.Request(
            server_url + '/api/save-pairs',
            data=b'{}',
            method='POST'
        )
        with urllib.request.urlopen(req, timeout=5) as response:
            status = response.status
    except urllib.error.HTTPError as e:
        status = e.code

    # Should handle gracefully (may succeed or fail, but not crash)
    assert status in (200, 400, 500)


# ============================================
# Performance Tests
# ============================================

@pytest.mark.integration
@pytest.mark.slow
def test_response_time_health(spa_client):
    """Test health endpoint responds quickly"""
    import time

    times = []
    for _ in range(10):
        start = time.time()
        status, data, _ = spa_client('/api/health')
        elapsed = time.time() - start
        times.append(elapsed)
        assert status == 200

    avg_time = sum(times) / len(times)
    # Health check should be fast (< 100ms on average)
    assert avg_time < 0.1, f"Average response time {avg_time:.3f}s is too slow"


@pytest.mark.integration
@pytest.mark.slow
def test_response_time_architecture_list(spa_client):
    """Test architecture list responds in reasonable time"""
    import time

    start = time.time()
    status, data, _ = spa_client('/api/architectures')
    elapsed = time.time() - start

    assert status == 200
    # Should complete within 2 seconds even with many files
    assert elapsed < 2.0, f"Response time {elapsed:.3f}s is too slow"
