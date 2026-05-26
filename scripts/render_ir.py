#!/usr/bin/env python3
"""
SysML v2 Renderer

Deterministically renders IR JSON to SysML v2 textual syntax.
"""
import json
import argparse
from pathlib import Path
from typing import Dict, List, Any, TextIO


class SysMLRenderer:
    """Renders IR to SysML v2 textual notation."""

    def __init__(self):
        self.indent_level = 0
        self.indent_size = 4

    def indent(self) -> str:
        """Return current indentation string."""
        return " " * (self.indent_level * self.indent_size)

    def render_part_def(self, member: Dict[str, Any], out: TextIO):
        """Render a part definition."""
        name = member["name"]
        out.write(f"{self.indent()}part def {name}")

        if "parts" in member and member["parts"]:
            out.write(" {\n")
            self.indent_level += 1

            for part in member["parts"]:
                part_name = part["name"]
                part_type = part["type"]
                out.write(f"{self.indent()}part {part_name} : {part_type};\n")

            self.indent_level -= 1
            out.write(f"{self.indent()}}}\n")
        else:
            out.write(";\n")

    def render_requirement_def(self, member: Dict[str, Any], out: TextIO):
        """Render a requirement definition."""
        name = member["name"]
        doc = member.get("doc", "")

        out.write(f"{self.indent()}requirement def {name} {{\n")
        self.indent_level += 1
        out.write(f"{self.indent()}doc /* {doc} */\n")
        self.indent_level -= 1
        out.write(f"{self.indent()}}}\n")

    def render_verification_case_def(self, member: Dict[str, Any], out: TextIO):
        """Render a verification case definition."""
        name = member["name"]
        subject = member["subject"]

        out.write(f"{self.indent()}verification case def {name} {{\n")
        self.indent_level += 1
        out.write(f"{self.indent()}subject {subject};\n")
        self.indent_level -= 1
        out.write(f"{self.indent()}}}\n")

    def render_member(self, member: Dict[str, Any], out: TextIO):
        """Render a package member based on its kind."""
        kind = member["kind"]

        if kind == "part_def":
            self.render_part_def(member, out)
        elif kind == "requirement_def":
            self.render_requirement_def(member, out)
        elif kind == "verification_case_def":
            self.render_verification_case_def(member, out)
        else:
            raise ValueError(f"Unknown member kind: {kind}")

    def render_package(self, pkg: Dict[str, Any], out: TextIO):
        """Render a package."""
        name = pkg["name"]
        members = pkg.get("members", [])

        out.write(f"package {name} {{\n")
        self.indent_level += 1

        for i, member in enumerate(members):
            self.render_member(member, out)
            if i < len(members) - 1:
                out.write("\n")

        self.indent_level -= 1
        out.write("}\n")

    def render(self, ir: Dict[str, Any], out: TextIO):
        """Render complete IR to SysML."""
        schema = ir.get("schema")
        if schema != "sysml-ir-v0":
            raise ValueError(f"Unsupported IR schema: {schema}")

        package = ir.get("package")
        if not package:
            raise ValueError("IR missing package")

        self.render_package(package, out)


def load_ir(ir_path: str) -> Dict[str, Any]:
    """Load IR from JSON file."""
    with open(ir_path, 'r') as f:
        return json.load(f)


def main():
    parser = argparse.ArgumentParser(
        description="Render SysML IR to textual notation"
    )
    parser.add_argument(
        "input",
        help="Input IR JSON file or directory"
    )
    parser.add_argument(
        "--output",
        help="Output file or directory (defaults to same name with .sysml extension)"
    )

    args = parser.parse_args()

    input_path = Path(args.input)

    if input_path.is_file():
        # Single file mode
        ir = load_ir(input_path)

        if args.output:
            output_path = Path(args.output)
        else:
            output_path = input_path.with_suffix('.sysml')

        output_path.parent.mkdir(parents=True, exist_ok=True)

        renderer = SysMLRenderer()
        with open(output_path, 'w') as out:
            renderer.render(ir, out)

        print(f"[render-ir] Rendered {input_path} -> {output_path}")

    elif input_path.is_dir():
        # Directory mode
        ir_files = list(input_path.glob("*.ir.json"))

        if not ir_files:
            print(f"[render-ir] No .ir.json files found in {input_path}")
            return

        output_dir = Path(args.output) if args.output else input_path
        output_dir.mkdir(parents=True, exist_ok=True)

        renderer = SysMLRenderer()

        for ir_file in ir_files:
            ir = load_ir(ir_file)
            output_file = output_dir / ir_file.name.replace('.ir.json', '.sysml')

            with open(output_file, 'w') as out:
                renderer.render(ir, out)

            print(f"[render-ir] Rendered {ir_file.name} -> {output_file.name}")

        print(f"[render-ir] Rendered {len(ir_files)} files")

    else:
        raise ValueError(f"Input path does not exist: {input_path}")


if __name__ == "__main__":
    main()
