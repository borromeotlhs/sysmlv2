"""
Test API endpoints for saving architectures and validating SysML.
"""
import json
import pytest
from pathlib import Path
from http.server import HTTPServer
from threading import Thread
import time
import urllib.request
import urllib.error


# Import server components
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))

from spa.server import Handler, ROOT, ARCH_DIR, validate_save_path, validate_sysml_content_basic


class TestPathValidation:
    """Test path validation security"""

    def test_relative_path_allowed(self):
        """Relative paths under architectures should be allowed"""
        path = validate_save_path("test_arch.sysml")
        assert path.suffix == '.sysml'
        assert ARCH_DIR.resolve() in path.parents or path.parent == ARCH_DIR.resolve()

    def test_directory_traversal_blocked(self):
        """Directory traversal should be blocked"""
        with pytest.raises(ValueError, match="directory traversal"):
            validate_save_path("../../../etc/passwd.sysml")

    def test_absolute_path_outside_root_blocked(self):
        """Absolute paths outside project root should be blocked"""
        with pytest.raises(ValueError, match="must be under project root"):
            validate_save_path("/etc/passwd.sysml")

    def test_invalid_extension_blocked(self):
        """Files without .sysml extension should be blocked"""
        with pytest.raises(ValueError, match="extension must be"):
            validate_save_path("test_arch.txt")

    def test_special_characters_blocked(self):
        """Filenames with special characters should be blocked"""
        with pytest.raises(ValueError, match="invalid characters"):
            validate_save_path("test<>arch.sysml")

    def test_subdirectory_allowed(self):
        """Paths in subdirectories should be allowed"""
        path = validate_save_path("subdir/test_arch.sysml")
        assert path.suffix == '.sysml'
        assert ARCH_DIR.resolve() in path.parents


class TestSysMLValidation:
    """Test SysML validation functionality"""

    def test_valid_sysml(self):
        """Valid SysML should pass validation"""
        content = """
// Test Architecture
// Domain: aerospace
package TestArch {
    part def SystemBlock {
        port dataIn;
        port dataOut;
    }
}
"""
        result = validate_sysml_content_basic(content)
        assert result['valid'] is True
        assert len(result['errors']) == 0

    def test_invalid_sysml(self):
        """Invalid SysML should fail validation"""
        content = """
This is not valid SysML content at all!
"""
        result = validate_sysml_content_basic(content)
        assert result['valid'] is False
        assert len(result['errors']) > 0
        assert result['errors'][0]['severity'] == 'error'

    def test_empty_content(self):
        """Empty content should fail validation"""
        content = ""
        result = validate_sysml_content_basic(content)
        assert result['valid'] is False
        assert len(result['errors']) > 0


class TestAPIEndpoints:
    """Test API endpoints via HTTP"""

    @pytest.fixture
    def server(self):
        """Start test server"""
        httpd = HTTPServer(('127.0.0.1', 8766), Handler)
        thread = Thread(target=httpd.serve_forever, daemon=True)
        thread.start()
        time.sleep(0.5)  # Wait for server to start
        yield 'http://127.0.0.1:8766'
        httpd.shutdown()

    def test_save_architecture_endpoint(self, server):
        """Test POST /api/save-architecture"""
        test_content = """
// Test Architecture
// Domain: test
package TestArch {
    part def TestBlock {
        port testPort;
    }
}
"""
        test_path = "test_save_endpoint.sysml"

        # Prepare request
        data = {
            'path': test_path,
            'content': test_content
        }
        req = urllib.request.Request(
            f'{server}/api/save-architecture',
            data=json.dumps(data).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='POST'
        )

        # Send request
        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                assert result['ok'] is True
                assert 'path' in result
                assert result['path'].endswith(test_path)

            # Verify file was created
            saved_file = ARCH_DIR / test_path
            assert saved_file.exists()
            assert test_content.strip() in saved_file.read_text()

            # Clean up
            saved_file.unlink()

        except urllib.error.HTTPError as e:
            pytest.fail(f"HTTP Error: {e.code} - {e.read().decode('utf-8')}")

    def test_save_architecture_with_invalid_path(self, server):
        """Test POST /api/save-architecture with invalid path"""
        data = {
            'path': '../../../etc/passwd.sysml',
            'content': 'malicious content'
        }
        req = urllib.request.Request(
            f'{server}/api/save-architecture',
            data=json.dumps(data).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='POST'
        )

        # Should return 400 error
        with pytest.raises(urllib.error.HTTPError) as exc_info:
            urllib.request.urlopen(req)

        assert exc_info.value.code == 400

    def test_validate_sysml_endpoint_valid(self, server):
        """Test POST /api/validate-sysml with valid content"""
        data = {
            'content': """
// Test Architecture
package TestArch {
    part def TestBlock {
        port testPort;
    }
}
"""
        }
        req = urllib.request.Request(
            f'{server}/api/validate-sysml',
            data=json.dumps(data).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='POST'
        )

        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                assert 'valid' in result
                assert 'errors' in result
                # May have warnings but should be valid
                assert isinstance(result['valid'], bool)
                assert isinstance(result['errors'], list)

        except urllib.error.HTTPError as e:
            pytest.fail(f"HTTP Error: {e.code} - {e.read().decode('utf-8')}")

    def test_validate_sysml_endpoint_invalid(self, server):
        """Test POST /api/validate-sysml with invalid content"""
        data = {
            'content': 'This is not valid SysML!'
        }
        req = urllib.request.Request(
            f'{server}/api/validate-sysml',
            data=json.dumps(data).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='POST'
        )

        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode('utf-8'))
                assert result['valid'] is False
                assert len(result['errors']) > 0
                # Check error structure
                error = result['errors'][0]
                assert 'message' in error
                assert 'severity' in error

        except urllib.error.HTTPError as e:
            pytest.fail(f"HTTP Error: {e.code} - {e.read().decode('utf-8')}")

    def test_validate_sysml_endpoint_missing_content(self, server):
        """Test POST /api/validate-sysml without content field"""
        data = {}
        req = urllib.request.Request(
            f'{server}/api/validate-sysml',
            data=json.dumps(data).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='POST'
        )

        # Should return 400 error
        with pytest.raises(urllib.error.HTTPError) as exc_info:
            urllib.request.urlopen(req)

        assert exc_info.value.code == 400


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
