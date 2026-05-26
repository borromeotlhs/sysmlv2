#!/usr/bin/env python3
"""
IR Generator for SysML v2

Generates intermediate representation JSON files with controlled randomness.
"""
import json
import argparse
import random
from pathlib import Path
from typing import Dict, List, Any


class IRGenerator:
    """Generates SysML IR with seeded randomness."""

    def __init__(self, rules: Dict[str, Any], seed: int):
        self.rules = rules
        self.random = random.Random(seed)

    def generate_name(self, prefix: str = "") -> str:
        """Generate a random identifier."""
        suffixes = ["System", "Subsystem", "Component", "Unit", "Module", "Controller"]
        prefixes = ["Power", "Flight", "Navigation", "Communication", "Sensor", "Battery"]

        if not prefix:
            prefix = self.random.choice(prefixes)

        suffix = self.random.choice(suffixes)
        number = self.random.randint(1, 999)

        return f"{prefix}{suffix}{number:03d}"

    def generate_part_def(self, name: str = None, with_parts: bool = True) -> Dict[str, Any]:
        """Generate a part definition."""
        if name is None:
            name = self.generate_name()

        part_def = {
            "kind": "part_def",
            "name": name
        }

        if with_parts and self.random.random() < 0.7:
            num_parts = self.random.randint(1, 3)
            parts = []
            for _ in range(num_parts):
                part_name = self.generate_name().lower()
                part_type = self.generate_name()
                parts.append({
                    "name": part_name,
                    "type": part_type
                })
            part_def["parts"] = parts

        return part_def

    def generate_requirement_def(self) -> Dict[str, Any]:
        """Generate a requirement definition."""
        req_types = ["Voltage", "Current", "Temperature", "Performance", "Safety", "Weight"]
        req_type = self.random.choice(req_types)
        name = f"{req_type}Requirement{self.random.randint(1, 99):02d}"

        docs = [
            f"The system shall maintain {req_type.lower()} within specified limits.",
            f"The {req_type.lower()} shall meet operational requirements.",
            f"All {req_type.lower()} parameters shall be monitored continuously."
        ]

        return {
            "kind": "requirement_def",
            "name": name,
            "doc": self.random.choice(docs)
        }

    def generate_verification_case_def(self, requirement_name: str) -> Dict[str, Any]:
        """Generate a verification case definition."""
        base_name = requirement_name.replace("Requirement", "Verification")

        return {
            "kind": "verification_case_def",
            "name": base_name,
            "subject": requirement_name
        }

    def generate_model(self, model_id: str) -> Dict[str, Any]:
        """Generate a complete model IR."""
        members = []

        # Generate main system part definition
        main_system = self.generate_part_def(with_parts=True)
        members.append(main_system)

        # Generate referenced part types
        if "parts" in main_system:
            for part in main_system["parts"]:
                members.append(self.generate_part_def(name=part["type"], with_parts=False))

        # Generate additional subsystems
        num_subsystems = self.random.randint(0, 2)
        for _ in range(num_subsystems):
            subsystem = self.generate_part_def(with_parts=False)
            members.append(subsystem)

        # Generate requirements
        num_requirements = self.random.randint(1, 3)
        requirements = []
        for _ in range(num_requirements):
            req = self.generate_requirement_def()
            requirements.append(req)
            members.append(req)

        # Generate verification cases for requirements
        for req in requirements:
            if self.random.random() < 0.8:
                verif = self.generate_verification_case_def(req["name"])
                members.append(verif)

        return {
            "schema": "sysml-ir-v0",
            "id": model_id,
            "package": {
                "name": model_id,
                "members": members
            }
        }


def load_rules(rules_path: str) -> Dict[str, Any]:
    """Load grammar rules."""
    with open(rules_path, 'r') as f:
        return json.load(f)


def main():
    parser = argparse.ArgumentParser(
        description="Generate SysML IR with controlled randomness"
    )
    parser.add_argument(
        "--rules",
        default="output/rules/rules.json",
        help="Path to rules.json"
    )
    parser.add_argument(
        "--output-dir",
        default="output/candidates",
        help="Output directory for IR files"
    )
    parser.add_argument(
        "--count",
        type=int,
        default=1,
        help="Number of models to generate"
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Random seed for reproducibility"
    )
    parser.add_argument(
        "--prefix",
        default="model",
        help="Prefix for generated model IDs"
    )

    args = parser.parse_args()

    # Load rules
    rules = load_rules(args.rules)
    print(f"[generate-ir] Loaded rules from {args.rules}")

    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Generate models
    generator = IRGenerator(rules, args.seed)

    for i in range(args.count):
        model_id = f"{args.prefix}_{args.seed}_{i:03d}"
        model = generator.generate_model(model_id)

        output_path = output_dir / f"{model_id}.ir.json"
        with open(output_path, 'w') as f:
            json.dump(model, f, indent=2)

        print(f"[generate-ir] Generated {output_path}")

    print(f"[generate-ir] Generated {args.count} IR files with seed {args.seed}")


if __name__ == "__main__":
    main()
