#!/usr/bin/env python3
"""
Shared pytest fixtures for all test suites.
"""

import sys
import json
import tempfile
from pathlib import Path
from typing import Dict, Any
import pytest

# Add spa and scripts to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT / 'spa'))
sys.path.insert(0, str(PROJECT_ROOT / 'scripts'))
sys.path.insert(0, str(PROJECT_ROOT / 'lib'))


@pytest.fixture
def sample_sysml_content() -> str:
    """Sample SysML content for testing"""
    return """package test_arch_001 {
    // Test Architecture
    // Domain: test

    import ScalarValues::*;

    // Interface Definitions
    interface def DataIF;
    interface def CommandIF;

    // Part Definitions
    part def System {
    }

    part def SubsystemA {
        port dataOut : DataIF;
    }

    part def SubsystemB {
        port dataIn : DataIF;
    }

    // Requirements
    requirement <'REQ-001'> {
        doc /* System shall exchange data through typed interfaces. */
    }

    // System Assembly
    part system : System {
        part subsystemA : SubsystemA;
        part subsystemB : SubsystemB;

        // Connections
        connection : dataFlow connect
            subsystemA.dataOut to subsystemB.dataIn;

        // Requirement Satisfaction
        satisfy requirement <'REQ-001'> by subsystemA;
        satisfy requirement <'REQ-001'> by subsystemB;
    }
}
"""


@pytest.fixture
def sample_architecture_dict() -> Dict[str, Any]:
    """Sample architecture as dictionary (JSON IR format)"""
    return {
        "id": "test_arch_001",
        "name": "Test Architecture",
        "domain": "test",
        "source": "model",
        "blocks": [
            {"name": "System", "type": "part def"},
            {"name": "SubsystemA", "type": "part def"},
            {"name": "SubsystemB", "type": "part def"}
        ],
        "proxy_ports": [
            {"owner": "SubsystemA", "name": "dataOut", "type": "DataIF", "direction": "out"},
            {"owner": "SubsystemB", "name": "dataIn", "type": "DataIF", "direction": "in"}
        ],
        "connectors": [
            {
                "name": "dataFlow",
                "end_a": "SubsystemA.dataOut",
                "end_b": "SubsystemB.dataIn"
            }
        ],
        "compositions": [
            {"parent": "System", "child": "SubsystemA"},
            {"parent": "System", "child": "SubsystemB"}
        ],
        "requirements": [
            {
                "id": "REQ-001",
                "text": "System shall exchange data through typed interfaces."
            }
        ],
        "relationships": [
            {"type": "satisfy", "client": "SubsystemA", "supplier": "REQ-001"},
            {"type": "satisfy", "client": "SubsystemB", "supplier": "REQ-001"}
        ]
    }


@pytest.fixture
def temp_sysml_file(sample_sysml_content, tmp_path):
    """Create a temporary .sysml file"""
    sysml_file = tmp_path / "test_arch.sysml"
    sysml_file.write_text(sample_sysml_content)
    return sysml_file


@pytest.fixture
def temp_json_file(sample_architecture_dict, tmp_path):
    """Create a temporary JSON architecture file"""
    json_file = tmp_path / "test_arch.json"
    json_file.write_text(json.dumps(sample_architecture_dict, indent=2))
    return json_file


@pytest.fixture
def architecture_files_dir():
    """Path to actual architecture files"""
    return PROJECT_ROOT / "data" / "architectures"


@pytest.fixture
def sample_pairs_file():
    """Path to sample pairs file"""
    return PROJECT_ROOT / "data" / "pairs" / "sample_pairs.json"


@pytest.fixture
def temp_output_dir(tmp_path):
    """Create a temporary output directory"""
    output_dir = tmp_path / "output"
    output_dir.mkdir()
    return output_dir


@pytest.fixture
def import_test_files(tmp_path):
    """Create test files for import testing"""
    # Create model file
    model_dir = tmp_path / "model"
    model_dir.mkdir()

    model_file = model_dir / "model.sysml"
    model_file.write_text("""package test_import {
    part def TestBlock {
        attribute testAttr : Real;
    }
}
""")

    # Create view directory
    view_dir = model_dir / "views"
    view_dir.mkdir()

    # Create BDD view
    bdd_file = view_dir / "bdd.sysml"
    bdd_file.write_text("""import "../model.sysml";

comment /*
    @viewType: BlockDefinitionDiagram
    @context: test_import
*/

// BDD view showing block definitions
""")

    return {
        "model": model_file,
        "bdd": bdd_file,
        "dir": model_dir
    }


@pytest.fixture(scope="session")
def test_summary():
    """Track test execution for summary report"""
    summary = {
        "total": 0,
        "passed": 0,
        "failed": 0,
        "skipped": 0,
        "errors": [],
        "start_time": None,
        "end_time": None
    }
    return summary


# ============================================
# SPA Server Fixtures
# ============================================

@pytest.fixture(scope="module")
def spa_server():
    """
    Start SPA server for integration testing.

    Returns:
        dict with 'url', 'host', 'port', 'process'
    """
    import subprocess
    import time
    import urllib.request
    import json
    import os

    host = os.environ.get('APP_HOST', '127.0.0.1')
    port = int(os.environ.get('APP_PORT', '8766'))  # Different port to avoid conflicts
    url = f'http://{host}:{port}'

    # Start server
    server_py = PROJECT_ROOT / 'spa' / 'server.py'
    env = os.environ.copy()
    env['SPA_QUIET'] = '1'

    process = subprocess.Popen(
        [sys.executable, str(server_py), '--host', host, '--port', str(port)],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    # Wait for server to be ready
    max_retries = 30
    for i in range(max_retries):
        try:
            with urllib.request.urlopen(f'{url}/api/health', timeout=1) as response:
                data = json.loads(response.read().decode())
                if data.get('ok'):
                    break
        except Exception:
            time.sleep(0.2)
    else:
        process.kill()
        pytest.fail(f"SPA server failed to start on {url}")

    yield {
        'url': url,
        'host': host,
        'port': port,
        'process': process
    }

    # Cleanup
    process.terminate()
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        process.kill()


@pytest.fixture
def spa_client(spa_server):
    """
    HTTP client for making requests to SPA server.

    Returns:
        Callable that makes requests and returns (status, data)
    """
    import urllib.request
    import urllib.error
    import json

    def make_request(endpoint, method='GET', data=None, headers=None):
        """
        Make HTTP request to SPA server.

        Args:
            endpoint: API endpoint (e.g., '/api/health')
            method: HTTP method
            data: Request body (will be JSON encoded if dict)
            headers: Additional headers

        Returns:
            (status_code, response_data, response_headers)
        """
        url = spa_server['url'] + endpoint

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

    return make_request
