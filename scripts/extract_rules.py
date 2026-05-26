#!/usr/bin/env python3
"""
Rule Extractor for SysML v2 Generator

Produces a minimal fallback rule catalog for MVP.
This is a smoke-test rule set; a future implementation should parse SysML.xtext.
"""
import json
import argparse
from pathlib import Path


def generate_fallback_rules():
    """Generate minimal SysML v2 grammar rules for MVP."""
    return {
        "schema": "sysml-rules-v0",
        "description": "Fallback MVP rules - NOT full SysML v2 grammar",
        "note": "This is a minimal smoke-test rule catalog. Replace with Xtext grammar parser.",
        "keywords": [
            "package", "part", "def", "requirement", "verification", "case",
            "doc", "subject", "import", "alias"
        ],
        "member_kinds": [
            "part_def",
            "requirement_def",
            "verification_case_def"
        ],
        "patterns": {
            "package_name": "^[A-Za-z][A-Za-z0-9_]*$",
            "identifier": "^[A-Za-z][A-Za-z0-9_]*$",
            "doc_text": ".*"
        },
        "syntax_rules": {
            "package": "package <name> { <members> }",
            "part_def": "part def <name> { <parts>? }",
            "part": "part <name> : <type>;",
            "requirement_def": "requirement def <name> { doc /* <text> */ }",
            "verification_case_def": "verification case def <name> { subject <requirement>; }"
        }
    }


def main():
    parser = argparse.ArgumentParser(
        description="Extract SysML v2 grammar rules (MVP fallback mode)"
    )
    parser.add_argument(
        "--output",
        default="output/rules/rules.json",
        help="Output path for rules.json"
    )
    parser.add_argument(
        "--xtext",
        help="Path to SysML.xtext (not implemented in MVP fallback mode)"
    )

    args = parser.parse_args()

    if args.xtext:
        print(f"[extract-rules] WARNING: Xtext parsing not yet implemented")
        print(f"[extract-rules] Falling back to minimal hardcoded rules")

    rules = generate_fallback_rules()

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w') as f:
        json.dump(rules, f, indent=2)

    print(f"[extract-rules] Generated fallback rules: {output_path}")
    print(f"[extract-rules] Rule catalog contains {len(rules['member_kinds'])} member kinds")


if __name__ == "__main__":
    main()
