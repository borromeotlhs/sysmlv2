"""Tests for render_ir.py"""
import io
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))
from render_ir import SysMLRenderer


def test_renderer_simple_package():
    """Test rendering a simple package."""
    ir = {
        "schema": "sysml-ir-v0",
        "id": "test",
        "package": {
            "name": "TestPackage",
            "members": []
        }
    }

    renderer = SysMLRenderer()
    out = io.StringIO()
    renderer.render(ir, out)

    result = out.getvalue()
    assert "package TestPackage" in result
    assert "{" in result
    assert "}" in result


def test_renderer_part_def():
    """Test rendering a part definition."""
    ir = {
        "schema": "sysml-ir-v0",
        "id": "test",
        "package": {
            "name": "TestPackage",
            "members": [
                {
                    "kind": "part_def",
                    "name": "TestPart"
                }
            ]
        }
    }

    renderer = SysMLRenderer()
    out = io.StringIO()
    renderer.render(ir, out)

    result = out.getvalue()
    assert "part def TestPart;" in result


def test_renderer_part_with_parts():
    """Test rendering a part with sub-parts."""
    ir = {
        "schema": "sysml-ir-v0",
        "id": "test",
        "package": {
            "name": "TestPackage",
            "members": [
                {
                    "kind": "part_def",
                    "name": "System",
                    "parts": [
                        {"name": "component", "type": "Component"}
                    ]
                }
            ]
        }
    }

    renderer = SysMLRenderer()
    out = io.StringIO()
    renderer.render(ir, out)

    result = out.getvalue()
    assert "part def System" in result
    assert "part component : Component;" in result


def test_renderer_requirement_def():
    """Test rendering a requirement definition."""
    ir = {
        "schema": "sysml-ir-v0",
        "id": "test",
        "package": {
            "name": "TestPackage",
            "members": [
                {
                    "kind": "requirement_def",
                    "name": "TestRequirement",
                    "doc": "Test documentation"
                }
            ]
        }
    }

    renderer = SysMLRenderer()
    out = io.StringIO()
    renderer.render(ir, out)

    result = out.getvalue()
    assert "requirement def TestRequirement" in result
    assert "doc /* Test documentation */" in result


def test_renderer_verification_case_def():
    """Test rendering a verification case definition."""
    ir = {
        "schema": "sysml-ir-v0",
        "id": "test",
        "package": {
            "name": "TestPackage",
            "members": [
                {
                    "kind": "verification_case_def",
                    "name": "TestVerification",
                    "subject": "TestRequirement"
                }
            ]
        }
    }

    renderer = SysMLRenderer()
    out = io.StringIO()
    renderer.render(ir, out)

    result = out.getvalue()
    assert "verification case def TestVerification" in result
    assert "subject TestRequirement;" in result
