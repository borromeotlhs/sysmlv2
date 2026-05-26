#!/usr/bin/env python3
"""
SysML v2 Validator

MVP FALLBACK VALIDATOR - This is NOT full SysML v2 semantic validation.
This is a smoke-test validator. Future implementations should use a real Xtext/SysML validator JAR.

Exit codes:
  0 - valid
  1 - invalid
  2 - tool/config error
"""
import json
import argparse
import re
import sys
from pathlib import Path
from typing import Dict, List, Any, Tuple


class FallbackValidator:
    """
    Fallback smoke-test validator for MVP.

    WARNING: This does NOT provide full SysML v2 semantic validation.
    Replace with Xtext/SysML validator for production use.
    """

    def __init__(self):
        self.errors = []
        self.warnings = []

    def validate_syntax(self, content: str) -> bool:
        """Basic syntax checks."""
        # Check balanced braces
        if content.count('{') != content.count('}'):
            self.errors.append("Unbalanced braces")
            return False

        # Check for package declaration
        if not re.search(r'package\s+\w+\s*\{', content):
            self.errors.append("Missing package declaration")
            return False

        # Check for basic keyword usage
        valid_keywords = {
            'package', 'part', 'def', 'requirement', 'verification',
            'case', 'doc', 'subject', 'import', 'alias'
        }

        # Simple token extraction
        tokens = re.findall(r'\b[a-zA-Z_]\w*\b', content)
        used_keywords = set(tokens) & valid_keywords

        if not used_keywords:
            self.warnings.append("No recognized SysML keywords found")

        return True

    def validate_structure(self, content: str) -> bool:
        """Check structural patterns."""
        # Check part definitions are well-formed
        part_defs = re.findall(r'part\s+def\s+(\w+)', content)
        if part_defs:
            for name in part_defs:
                if not re.match(r'^[A-Za-z][A-Za-z0-9_]*$', name):
                    self.errors.append(f"Invalid part def name: {name}")
                    return False

        # Check requirement definitions
        req_defs = re.findall(r'requirement\s+def\s+(\w+)', content)
        if req_defs:
            for name in req_defs:
                if not re.match(r'^[A-Za-z][A-Za-z0-9_]*$', name):
                    self.errors.append(f"Invalid requirement def name: {name}")
                    return False

        # Check for unterminated statements (very basic)
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped and not stripped.startswith('//') and not stripped.startswith('/*'):
                # Lines inside docs can be anything
                if '/*' in stripped or '*/' in stripped:
                    continue
                # Declarations should end with ; or { or }
                if stripped and stripped[-1] not in {';', '{', '}', '/'}:
                    # Check if it's a keyword line (like "part def Name")
                    if not any(kw in stripped for kw in ['package', 'part def', 'requirement def', 'verification case def']):
                        # Could be continuation, so just warn
                        pass

        return True

    def validate_references(self, content: str) -> bool:
        """Check that referenced types are defined (basic check)."""
        # Extract all defined types
        defined_types = set()
        defined_types.update(re.findall(r'part\s+def\s+(\w+)', content))
        defined_types.update(re.findall(r'requirement\s+def\s+(\w+)', content))

        # Extract all type references in part declarations
        type_refs = re.findall(r'part\s+\w+\s*:\s*(\w+)\s*;', content)

        # Check references
        for ref in type_refs:
            if ref not in defined_types:
                self.errors.append(f"Undefined type reference: {ref}")
                return False

        # Extract verification case subjects
        subjects = re.findall(r'subject\s+(\w+)\s*;', content)
        for subj in subjects:
            # Should reference a requirement
            if subj not in defined_types:
                self.errors.append(f"Undefined subject reference: {subj}")
                return False

        return True

    def validate(self, sysml_path: str) -> Tuple[bool, Dict[str, Any]]:
        """
        Validate a SysML file.

        Returns:
            (is_valid, validation_result)
        """
        self.errors = []
        self.warnings = []

        try:
            with open(sysml_path, 'r') as f:
                content = f.read()
        except Exception as e:
            return False, {
                "validator": "fallback-smoke-v0",
                "disclaimer": "NOT full SysML v2 validation - smoke test only",
                "valid": False,
                "errors": [f"Failed to read file: {e}"],
                "warnings": []
            }

        # Run validation checks
        valid = True
        valid = valid and self.validate_syntax(content)
        valid = valid and self.validate_structure(content)
        valid = valid and self.validate_references(content)

        result = {
            "validator": "fallback-smoke-v0",
            "disclaimer": "NOT full SysML v2 validation - smoke test only",
            "valid": valid,
            "errors": self.errors,
            "warnings": self.warnings
        }

        return valid, result


def main():
    parser = argparse.ArgumentParser(
        description="Validate SysML v2 files (MVP fallback mode)",
        epilog="WARNING: This is a smoke-test validator, not full SysML v2 validation."
    )
    parser.add_argument(
        "input",
        help="Input .sysml file"
    )
    parser.add_argument(
        "--output",
        help="Output validation JSON file (optional)"
    )
    parser.add_argument(
        "--xtext-jar",
        help="Path to Xtext validator JAR (not implemented in MVP)"
    )

    args = parser.parse_args()

    if args.xtext_jar:
        print("[validate] WARNING: Xtext validator not yet integrated", file=sys.stderr)
        print("[validate] Falling back to smoke-test validator", file=sys.stderr)

    validator = FallbackValidator()
    is_valid, result = validator.validate(args.input)

    # Write validation result if output specified
    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            json.dump(result, f, indent=2)

    # Print result
    print(f"[validate] File: {args.input}")
    print(f"[validate] Validator: {result['validator']}")
    print(f"[validate] Valid: {result['valid']}")

    if result['errors']:
        print(f"[validate] Errors:")
        for err in result['errors']:
            print(f"  - {err}")

    if result['warnings']:
        print(f"[validate] Warnings:")
        for warn in result['warnings']:
            print(f"  - {warn}")

    # Exit with appropriate code
    if is_valid:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
