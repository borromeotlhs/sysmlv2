"""
SysML v2 Validation Test Suite

Validates generated .sysml files for:
- Syntax correctness
- Semantic validity
- Style conventions
"""
import re
from pathlib import Path
from typing import List, Dict, Set, Optional
from dataclasses import dataclass, field
from enum import Enum


class ErrorSeverity(Enum):
    """Validation error severity levels"""
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"


@dataclass
class ValidationError:
    """Represents a validation error or warning"""
    severity: ErrorSeverity
    category: str
    message: str
    line_number: Optional[int] = None
    code: Optional[str] = None

    def __str__(self):
        loc = f"line {self.line_number}" if self.line_number else "unknown location"
        return f"[{self.severity.value.upper()}] {self.category}: {self.message} ({loc})"


class SysMLValidator:
    """Validates SysML v2 textual syntax files"""

    def __init__(self):
        self.errors: List[ValidationError] = []
        self.warnings: List[ValidationError] = []
        self.info: List[ValidationError] = []

    def validate_file(self, file_path: Path) -> List[ValidationError]:
        """
        Validate a SysML file and return all errors/warnings.

        Args:
            file_path: Path to .sysml file

        Returns:
            List of ValidationError objects
        """
        self.errors = []
        self.warnings = []
        self.info = []

        if not file_path.exists():
            self.add_error(ErrorSeverity.ERROR, "FileNotFound",
                          f"File does not exist: {file_path}")
            return self.all_issues()

        content = file_path.read_text(encoding='utf-8')
        lines = content.split('\n')

        # Run all validation checks
        self.validate_syntax(content, lines)
        self.validate_semantics(content, lines)
        self.validate_style(content, lines)

        return self.all_issues()

    def all_issues(self) -> List[ValidationError]:
        """Return all errors, warnings, and info messages"""
        return self.errors + self.warnings + self.info

    def add_error(self, severity: ErrorSeverity, category: str, message: str,
                  line_number: Optional[int] = None, code: Optional[str] = None):
        """Add a validation error/warning/info"""
        error = ValidationError(severity, category, message, line_number, code)

        if severity == ErrorSeverity.ERROR:
            self.errors.append(error)
        elif severity == ErrorSeverity.WARNING:
            self.warnings.append(error)
        else:
            self.info.append(error)

    # ========================================================================
    # SYNTAX VALIDATION
    # ========================================================================

    def validate_syntax(self, content: str, lines: List[str]):
        """Validate SysML v2 textual syntax"""

        # Check package structure
        self.check_package_declaration(lines)

        # Check brace matching
        self.check_brace_balance(content)

        # Check semicolons
        self.check_semicolons(lines)

        # Check port syntax
        self.check_port_syntax(content, lines)

        # Check requirement syntax
        self.check_requirement_syntax(content, lines)

        # Check connection syntax
        self.check_connection_syntax(content, lines)

        # Check multiplicity syntax
        self.check_multiplicity_syntax(content, lines)

    def check_package_declaration(self, lines: List[str]):
        """Verify package declaration exists and is well-formed"""
        package_found = False

        for i, line in enumerate(lines[:10], start=1):
            if re.match(r'\s*package\s+\w+\s*\{', line):
                package_found = True
                break

        if not package_found:
            self.add_error(ErrorSeverity.ERROR, "SyntaxError",
                          "Missing or malformed package declaration", line_number=1)

    def check_brace_balance(self, content: str):
        """Check that braces are balanced"""
        open_count = content.count('{')
        close_count = content.count('}')

        if open_count != close_count:
            self.add_error(ErrorSeverity.ERROR, "SyntaxError",
                          f"Unbalanced braces: {open_count} opening, {close_count} closing")

    def check_semicolons(self, lines: List[str]):
        """Check semicolon usage on statements"""

        # Patterns that should end with semicolon
        semicolon_required = [
            r'attribute\s+\w+\s*:\s*\w+\s*\[\d+\]\s*$',  # attribute declarations
            r'port\s+\w+\s*:\s*\w+\s*$',  # port declarations (typed)
            r'port\s+\w+\s*$',  # port declarations (untyped)
            r'satisfy\s+\w+\s*$',  # satisfy statements
            r'connect\s+.+\s+to\s+.+\s*$',  # connect statements
            r'part\s+\w+\s*:\s*\w+(?:\[\d+\])?\s*$',  # part instances without body
            r'import\s+.+\s*$',  # import statements
        ]

        for i, line in enumerate(lines, start=1):
            stripped = line.strip()

            # Skip empty lines, comments, and lines with braces
            if not stripped or stripped.startswith('//') or '{' in stripped or '}' in stripped:
                continue

            # Check if line matches a pattern requiring semicolon
            for pattern in semicolon_required:
                if re.match(pattern, stripped):
                    if not stripped.endswith(';'):
                        self.add_error(ErrorSeverity.ERROR, "SyntaxError",
                                      f"Missing semicolon: {stripped[:50]}", line_number=i)
                    break

    def check_port_syntax(self, content: str, lines: List[str]):
        """Validate port declarations have proper syntax"""

        # Find all port declarations
        port_pattern = r'port\s+(\w+)(?:\s*:\s*(\w+))?\s*;'

        for match in re.finditer(port_pattern, content):
            port_name = match.group(1)
            port_type = match.group(2)

            # Check if port has a type (SysML v2 best practice)
            if not port_type:
                line_num = content[:match.start()].count('\n') + 1
                self.add_error(ErrorSeverity.WARNING, "PortTyping",
                              f"Port '{port_name}' has no type declaration", line_number=line_num)

    def check_requirement_syntax(self, content: str, lines: List[str]):
        """Validate requirement definitions"""

        # Pattern: requirement REQ_ID { doc "text" }
        req_pattern = r'requirement\s+(\w+)\s*\{[^}]*\}'

        for match in re.finditer(req_pattern, content, re.DOTALL):
            req_id = match.group(1)
            req_body = match.group(0)
            line_num = content[:match.start()].count('\n') + 1

            # Check for doc statement
            if 'doc' not in req_body:
                self.add_error(ErrorSeverity.ERROR, "RequirementFormat",
                              f"Requirement '{req_id}' missing doc statement", line_number=line_num)

            # Check doc statement format
            doc_match = re.search(r'doc\s+"([^"]*)"', req_body)
            if not doc_match:
                self.add_error(ErrorSeverity.ERROR, "RequirementFormat",
                              f"Requirement '{req_id}' has malformed doc statement", line_number=line_num)
            elif not doc_match.group(1).strip():
                self.add_error(ErrorSeverity.WARNING, "RequirementFormat",
                              f"Requirement '{req_id}' has empty doc text", line_number=line_num)

    def check_connection_syntax(self, content: str, lines: List[str]):
        """Validate connection statements"""

        # Pattern: connect SOURCE to TARGET;
        conn_pattern = r'connect\s+(.+?)\s+to\s+(.+?)\s*;'

        for match in re.finditer(conn_pattern, content):
            source = match.group(1).strip()
            target = match.group(2).strip()
            line_num = content[:match.start()].count('\n') + 1

            # Check for valid identifiers
            valid_identifier = r'^[\w.]+$'

            if not re.match(valid_identifier, source):
                self.add_error(ErrorSeverity.ERROR, "ConnectionSyntax",
                              f"Invalid connection source: '{source}'", line_number=line_num)

            if not re.match(valid_identifier, target):
                self.add_error(ErrorSeverity.ERROR, "ConnectionSyntax",
                              f"Invalid connection target: '{target}'", line_number=line_num)

    def check_multiplicity_syntax(self, content: str, lines: List[str]):
        """Validate multiplicity expressions"""

        # Pattern: [multiplicity] - should be [number] or [min..max]
        mult_pattern = r'\[([^\]]+)\]'

        for match in re.finditer(mult_pattern, content):
            mult_expr = match.group(1).strip()
            line_num = content[:match.start()].count('\n') + 1

            # Valid patterns: digit, digit..digit, digit..*, *
            valid_mult = r'^\d+$|^\d+\.\.\d+$|^\d+\.\.\*$|^\*$'

            if not re.match(valid_mult, mult_expr):
                self.add_error(ErrorSeverity.ERROR, "MultiplicitySyntax",
                              f"Invalid multiplicity expression: '[{mult_expr}]'", line_number=line_num)

    # ========================================================================
    # SEMANTIC VALIDATION
    # ========================================================================

    def validate_semantics(self, content: str, lines: List[str]):
        """Validate semantic correctness"""

        # Extract defined elements
        part_defs = self.extract_part_definitions(content)
        part_instances = self.extract_part_instances(content)
        ports = self.extract_port_definitions(content)
        requirements = self.extract_requirement_ids(content)

        # Check connections reference existing parts/ports
        self.check_connection_references(content, part_defs, part_instances, ports)

        # Check satisfy statements reference existing requirements
        self.check_satisfy_references(content, requirements, part_defs)

        # Check for duplicate definitions
        self.check_duplicate_definitions(part_defs, "part def")
        self.check_duplicate_definitions(requirements, "requirement")

        # Check for circular dependencies in compositions
        self.check_circular_compositions(content, part_defs)

    def extract_part_definitions(self, content: str) -> Dict[str, int]:
        """Extract all part definitions with their line numbers"""
        part_defs = {}
        pattern = r'part\s+def\s+(\w+)\s*\{'

        for match in re.finditer(pattern, content):
            part_name = match.group(1)
            line_num = content[:match.start()].count('\n') + 1
            part_defs[part_name] = line_num

        return part_defs

    def extract_part_instances(self, content: str) -> Dict[str, str]:
        """Extract part instances mapping instance_name -> type_name"""
        instances = {}
        pattern = r'part\s+(\w+)\s*:\s*(\w+)(?:\[[^\]]*\])?'

        for match in re.finditer(pattern, content):
            instance_name = match.group(1).lower()
            type_name = match.group(2)
            instances[instance_name] = type_name

        return instances

    def extract_port_definitions(self, content: str) -> Dict[str, Set[str]]:
        """Extract ports grouped by owner: {owner: {port_names}}"""
        ports = {}

        # Find each part def and its ports
        part_pattern = r'part\s+def\s+(\w+)\s*\{'

        for part_match in re.finditer(part_pattern, content):
            owner = part_match.group(1)
            start_pos = part_match.end()

            # Find matching closing brace
            brace_count = 1
            pos = start_pos
            while pos < len(content) and brace_count > 0:
                if content[pos] == '{':
                    brace_count += 1
                elif content[pos] == '}':
                    brace_count -= 1
                pos += 1

            if brace_count == 0:
                part_body = content[start_pos:pos-1]

                # Extract ports
                port_pattern = r'port\s+(\w+)'
                port_names = {m.group(1) for m in re.finditer(port_pattern, part_body)}

                if port_names:
                    ports[owner] = port_names

        return ports

    def extract_requirement_ids(self, content: str) -> Dict[str, int]:
        """Extract all requirement IDs with their line numbers"""
        requirements = {}
        pattern = r'requirement\s+(\w+)\s*\{'

        for match in re.finditer(pattern, content):
            req_id = match.group(1)
            line_num = content[:match.start()].count('\n') + 1
            requirements[req_id] = line_num

        return requirements

    def check_connection_references(self, content: str, part_defs: Dict[str, int],
                                   part_instances: Dict[str, str], ports: Dict[str, Set[str]]):
        """Verify connections reference existing parts and ports"""

        conn_pattern = r'connect\s+(.+?)\s+to\s+(.+?)\s*;'

        for match in re.finditer(conn_pattern, content):
            source = match.group(1).strip()
            target = match.group(2).strip()
            line_num = content[:match.start()].count('\n') + 1

            # Check source
            self.validate_connection_endpoint(source, part_defs, part_instances, ports, line_num, "source")

            # Check target
            self.validate_connection_endpoint(target, part_defs, part_instances, ports, line_num, "target")

    def validate_connection_endpoint(self, endpoint: str, part_defs: Dict[str, int],
                                    part_instances: Dict[str, str], ports: Dict[str, Set[str]],
                                    line_num: int, endpoint_type: str):
        """Validate a single connection endpoint"""

        if '.' in endpoint:
            # Format: part.port
            part_instance, port_name = endpoint.split('.', 1)
            part_instance_lower = part_instance.lower()

            # Check if part instance exists
            if part_instance_lower not in part_instances:
                self.add_error(ErrorSeverity.ERROR, "UndefinedReference",
                              f"Connection {endpoint_type} references undefined part instance: '{part_instance}'",
                              line_number=line_num)
                return

            # Get the type of the part instance
            part_type = part_instances[part_instance_lower]

            # Check if the type has this port
            if part_type in ports:
                if port_name not in ports[part_type]:
                    self.add_error(ErrorSeverity.ERROR, "UndefinedReference",
                                  f"Connection {endpoint_type} references undefined port '{port_name}' on '{part_type}'",
                                  line_number=line_num)
            else:
                # Part type not found in our analysis - might be external
                self.add_error(ErrorSeverity.WARNING, "UndefinedReference",
                              f"Cannot verify port '{port_name}' on undefined part type '{part_type}'",
                              line_number=line_num)

    def check_satisfy_references(self, content: str, requirements: Dict[str, int],
                                part_defs: Dict[str, int]):
        """Verify satisfy statements reference existing requirements"""

        satisfy_pattern = r'satisfy\s+(\w+)\s*;'

        for match in re.finditer(satisfy_pattern, content):
            req_id = match.group(1)
            line_num = content[:match.start()].count('\n') + 1

            if req_id not in requirements:
                self.add_error(ErrorSeverity.ERROR, "UndefinedReference",
                              f"Satisfy statement references undefined requirement: '{req_id}'",
                              line_number=line_num)

    def check_duplicate_definitions(self, definitions: Dict[str, int], def_type: str):
        """Check for duplicate definitions"""

        # The dict already prevents duplicates, but we can check for case variations
        seen = {}
        for name, line_num in definitions.items():
            name_lower = name.lower()
            if name_lower in seen:
                self.add_error(ErrorSeverity.ERROR, "DuplicateDefinition",
                              f"Duplicate {def_type} '{name}' (case-insensitive match with line {seen[name_lower]})",
                              line_number=line_num)
            else:
                seen[name_lower] = line_num

    def check_circular_compositions(self, content: str, part_defs: Dict[str, int]):
        """Check for circular composition dependencies"""

        # Build composition graph: parent -> [children]
        compositions = {}

        part_pattern = r'part\s+def\s+(\w+)\s*\{'

        for part_match in re.finditer(part_pattern, content):
            parent = part_match.group(1)
            start_pos = part_match.end()

            # Find matching closing brace
            brace_count = 1
            pos = start_pos
            while pos < len(content) and brace_count > 0:
                if content[pos] == '{':
                    brace_count += 1
                elif content[pos] == '}':
                    brace_count -= 1
                pos += 1

            if brace_count == 0:
                part_body = content[start_pos:pos-1]

                # Extract child parts
                child_pattern = r'part\s+\w+\s*:\s*(\w+)'
                children = [m.group(1) for m in re.finditer(child_pattern, part_body)]

                compositions[parent] = children

        # Check for cycles using DFS
        def has_cycle(node: str, visited: Set[str], rec_stack: Set[str]) -> bool:
            visited.add(node)
            rec_stack.add(node)

            for child in compositions.get(node, []):
                if child not in visited:
                    if has_cycle(child, visited, rec_stack):
                        return True
                elif child in rec_stack:
                    return True

            rec_stack.remove(node)
            return False

        visited = set()
        for node in compositions:
            if node not in visited:
                if has_cycle(node, visited, set()):
                    line_num = part_defs.get(node)
                    self.add_error(ErrorSeverity.ERROR, "CircularDependency",
                                  f"Circular composition dependency detected involving '{node}'",
                                  line_number=line_num)

    # ========================================================================
    # STYLE VALIDATION
    # ========================================================================

    def validate_style(self, content: str, lines: List[str]):
        """Validate style conventions"""

        self.check_naming_conventions(content)
        self.check_indentation(lines)
        self.check_documentation(content, lines)

    def check_naming_conventions(self, content: str):
        """Check naming conventions: PascalCase for types, camelCase for instances"""

        # Check part definitions (should be PascalCase)
        part_def_pattern = r'part\s+def\s+(\w+)'
        for match in re.finditer(part_def_pattern, content):
            name = match.group(1)
            line_num = content[:match.start()].count('\n') + 1

            if not name[0].isupper():
                self.add_error(ErrorSeverity.WARNING, "NamingConvention",
                              f"Part definition '{name}' should use PascalCase", line_number=line_num)

        # Check part instances (should be camelCase)
        part_instance_pattern = r'part\s+(\w+)\s*:\s*\w+'
        for match in re.finditer(part_instance_pattern, content):
            name = match.group(1)
            line_num = content[:match.start()].count('\n') + 1

            if name[0].isupper():
                self.add_error(ErrorSeverity.WARNING, "NamingConvention",
                              f"Part instance '{name}' should use camelCase", line_number=line_num)

        # Check requirements (should be uppercase with underscores)
        req_pattern = r'requirement\s+(\w+)'
        for match in re.finditer(req_pattern, content):
            name = match.group(1)
            line_num = content[:match.start()].count('\n') + 1

            if not re.match(r'^[A-Z][A-Z0-9_]*$', name):
                self.add_error(ErrorSeverity.WARNING, "NamingConvention",
                              f"Requirement '{name}' should use UPPER_CASE", line_number=line_num)

    def check_indentation(self, lines: List[str]):
        """Check consistent indentation"""

        # Track indentation level (spaces at start of line)
        prev_indent = 0

        for i, line in enumerate(lines, start=1):
            if not line.strip():
                continue

            # Count leading spaces
            indent = len(line) - len(line.lstrip())

            # Check if indentation is multiple of 4
            if indent % 4 != 0:
                self.add_error(ErrorSeverity.INFO, "Indentation",
                              f"Indentation should be multiple of 4 spaces (found {indent})",
                              line_number=i)

    def check_documentation(self, content: str, lines: List[str]):
        """Check for documentation comments"""

        # Check if package has a description comment
        package_line = 0
        for i, line in enumerate(lines[:10], start=1):
            if 'package' in line:
                package_line = i
                break

        if package_line > 0:
            # Check if there's a comment before package
            has_doc = False
            for i in range(max(0, package_line - 5), package_line):
                if '//' in lines[i]:
                    has_doc = True
                    break

            if not has_doc:
                self.add_error(ErrorSeverity.INFO, "Documentation",
                              "Package should have documentation comment",
                              line_number=package_line)
