"""Tests for generate_ir.py"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))
from generate_ir import IRGenerator


def test_ir_generator_deterministic():
    """Test that IR generation is deterministic with same seed."""
    rules = {
        "member_kinds": ["part_def", "requirement_def", "verification_case_def"]
    }

    gen1 = IRGenerator(rules, seed=42)
    model1 = gen1.generate_model("test_model")

    gen2 = IRGenerator(rules, seed=42)
    model2 = gen2.generate_model("test_model")

    # Should generate identical models with same seed
    assert json.dumps(model1, sort_keys=True) == json.dumps(model2, sort_keys=True)


def test_ir_generator_different_seeds():
    """Test that different seeds produce different models."""
    rules = {
        "member_kinds": ["part_def", "requirement_def", "verification_case_def"]
    }

    gen1 = IRGenerator(rules, seed=42)
    model1 = gen1.generate_model("test_model")

    gen2 = IRGenerator(rules, seed=99)
    model2 = gen2.generate_model("test_model")

    # Should generate different models with different seeds
    assert json.dumps(model1, sort_keys=True) != json.dumps(model2, sort_keys=True)


def test_ir_model_structure():
    """Test that generated IR has correct structure."""
    rules = {
        "member_kinds": ["part_def", "requirement_def", "verification_case_def"]
    }

    gen = IRGenerator(rules, seed=42)
    model = gen.generate_model("test_model")

    assert model["schema"] == "sysml-ir-v0"
    assert model["id"] == "test_model"
    assert "package" in model
    assert "name" in model["package"]
    assert "members" in model["package"]
    assert len(model["package"]["members"]) > 0


def test_part_def_generation():
    """Test part definition generation."""
    rules = {}
    gen = IRGenerator(rules, seed=42)

    part = gen.generate_part_def("TestPart", with_parts=False)

    assert part["kind"] == "part_def"
    assert part["name"] == "TestPart"


def test_requirement_def_generation():
    """Test requirement definition generation."""
    rules = {}
    gen = IRGenerator(rules, seed=42)

    req = gen.generate_requirement_def()

    assert req["kind"] == "requirement_def"
    assert "name" in req
    assert "doc" in req
