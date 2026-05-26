"""Tests for extract_rules.py"""
import json
import tempfile
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))
from extract_rules import generate_fallback_rules


def test_fallback_rules_schema():
    """Test that fallback rules have correct schema."""
    rules = generate_fallback_rules()

    assert rules["schema"] == "sysml-rules-v0"
    assert "description" in rules
    assert "keywords" in rules
    assert "member_kinds" in rules
    assert "patterns" in rules
    assert "syntax_rules" in rules


def test_fallback_rules_member_kinds():
    """Test that required member kinds are present."""
    rules = generate_fallback_rules()

    required_kinds = ["part_def", "requirement_def", "verification_case_def"]
    for kind in required_kinds:
        assert kind in rules["member_kinds"]


def test_fallback_rules_keywords():
    """Test that basic keywords are present."""
    rules = generate_fallback_rules()

    required_keywords = ["package", "part", "def", "requirement", "verification"]
    for kw in required_keywords:
        assert kw in rules["keywords"]
