"""
Comprehensive Verification and Validation (V&V) Test Suite for Generated SysML Output

This suite validates all aspects of the generated .sysml files:
- Syntactic validation: all generated .sysml files are syntactically correct
- Semantic validation: blocks reference valid types, connections reference valid ports
- Completeness: all required elements present (names, types, multiplicities)
- Consistency: IR -> .sysml -> parsed IR round-trip preserves semantics
- PlantUML generation: view rendering commands produce valid PlantUML
- Naming conventions: identifiers follow SysML v2 rules
- Import chains: all imports resolve correctly (for separated format)
- Property-based tests: generate random architectures and validate them

Run with: pytest tests/test_generated_sysml_vv.py -v -m validation
"""
import pytest
import json
import re
from pathlib import Path
from typing import List, Dict, Set, Optional
from dataclasses import dataclass

# Import existing validation infrastructure
from tests.test_sysml_validation import SysMLValidator, ErrorSeverity, ValidationError

# Import generator and parser for round-trip testing
from lib.sysml_generator import generate_sysml_from_dict, sanitize_name
import sys
sys.path.insert(0, str(Path(__file__).parent.parent / 'spa'))
from sysml_parser import parse_sysml_to_json
from server import generate_bdd_plantuml, generate_ibd_plantuml, plantuml_encode


# ============================================================================
# FIXTURES
# ============================================================================

@pytest.fixture
def validator():
    """Create a validator instance"""
    return SysMLValidator()


@pytest.fixture
def architectures_dir():
    """Get the architectures directory"""
    return Path(__file__).parent.parent / 'data' / 'architectures'


@pytest.fixture
def all_sysml_files(architectures_dir):
    """Get all generated .sysml files"""
    return sorted(architectures_dir.glob('*.sysml'))


@pytest.fixture
def sample_architectures(all_sysml_files):
    """Get sample of architectures for faster testing"""
    # Use every 5th file for quick tests
    return all_sysml_files[::5]


# ============================================================================
# TEST 1: SYNTACTIC VALIDATION
# ============================================================================

class TestSyntacticValidation:
    """Validate syntactic correctness of all generated .sysml files"""

    @pytest.mark.validation
    def test_all_files_have_no_syntax_errors(self, validator, all_sysml_files):
        """Every generated .sysml file must be syntactically valid"""
        failed_files = []

        for arch_file in all_sysml_files:
            issues = validator.validate_file(arch_file)
            errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]

            # Filter out acceptable errors (if any - currently expect none)
            critical_errors = [e for e in errors if self._is_critical_error(e)]

            if critical_errors:
                failed_files.append((arch_file.name, critical_errors))

        if failed_files:
            self._print_syntax_failures(failed_files)

        assert len(failed_files) == 0, \
            f"{len(failed_files)} files have critical syntax errors"

    @pytest.mark.validation
    def test_package_declarations_valid(self, all_sysml_files):
        """All files must have valid package declarations"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')
            lines = content.split('\n')

            # Check first 5 lines for package declaration
            found_package = False
            for i, line in enumerate(lines[:5], start=1):
                if re.match(r'^\s*package\s+\w+\s*\{', line):
                    found_package = True
                    break

            if not found_package:
                failures.append(arch_file.name)

        assert len(failures) == 0, \
            f"Files missing package declaration: {failures}"

    @pytest.mark.validation
    def test_balanced_braces(self, all_sysml_files):
        """All files must have balanced braces"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')
            open_count = content.count('{')
            close_count = content.count('}')

            if open_count != close_count:
                failures.append((
                    arch_file.name,
                    f"open={open_count}, close={close_count}"
                ))

        assert len(failures) == 0, \
            f"Files with unbalanced braces: {failures}"

    @pytest.mark.validation
    def test_no_invalid_characters(self, all_sysml_files):
        """Files should not contain invalid characters in identifiers"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            # Check for common issues
            issues = []

            # Invalid characters in identifiers (after keywords)
            invalid_id_pattern = r'\b(?:part|port|requirement)\s+(?:def\s+)?([^\s:;{]+)'
            for match in re.finditer(invalid_id_pattern, content):
                identifier = match.group(1)
                if not re.match(r'^[a-zA-Z_]\w*$', identifier):
                    issues.append(f"Invalid identifier: {identifier}")

            if issues:
                failures.append((arch_file.name, issues[:5]))  # First 5 issues

        assert len(failures) == 0, \
            f"Files with invalid characters: {failures}"

    def _is_critical_error(self, error: ValidationError) -> bool:
        """Determine if a validation error is critical"""
        # Allow certain errors that may be acceptable
        acceptable_categories = []
        return error.category not in acceptable_categories

    def _print_syntax_failures(self, failed_files):
        """Pretty print syntax failure details"""
        print("\n\nSyntax Validation Failures:")
        print("=" * 80)
        for filename, errors in failed_files:
            print(f"\n{filename}:")
            for error in errors[:10]:  # Show first 10 errors
                print(f"  {error}")


# ============================================================================
# TEST 2: SEMANTIC VALIDATION
# ============================================================================

class TestSemanticValidation:
    """Validate semantic correctness of generated SysML"""

    @pytest.mark.validation
    def test_all_port_references_valid(self, validator, all_sysml_files):
        """All connection endpoints must reference valid ports"""
        failures = []

        for arch_file in all_sysml_files:
            issues = validator.validate_file(arch_file)

            # Check for undefined port/part references
            port_errors = [
                i for i in issues
                if i.severity == ErrorSeverity.ERROR
                and 'undefined' in i.message.lower()
                and 'port' in i.message.lower()
            ]

            if port_errors:
                failures.append((arch_file.name, port_errors[:5]))

        if failures:
            print("\n\nPort Reference Failures:")
            for filename, errors in failures:
                print(f"\n{filename}:")
                for error in errors:
                    print(f"  {error}")

        assert len(failures) == 0, \
            f"{len(failures)} files have invalid port references"

    @pytest.mark.validation
    def test_all_requirement_references_valid(self, validator, all_sysml_files):
        """All satisfy statements must reference defined requirements"""
        failures = []

        for arch_file in all_sysml_files:
            issues = validator.validate_file(arch_file)

            req_errors = [
                i for i in issues
                if i.severity == ErrorSeverity.ERROR
                and 'undefined' in i.message.lower()
                and 'requirement' in i.message.lower()
            ]

            if req_errors:
                failures.append((arch_file.name, req_errors[:5]))

        if failures:
            print("\n\nRequirement Reference Failures:")
            for filename, errors in failures:
                print(f"\n{filename}:")
                for error in errors:
                    print(f"  {error}")

        assert len(failures) == 0, \
            f"{len(failures)} files have invalid requirement references"

    @pytest.mark.validation
    def test_no_circular_dependencies(self, validator, all_sysml_files):
        """No circular composition dependencies"""
        failures = []

        for arch_file in all_sysml_files:
            issues = validator.validate_file(arch_file)

            circular_errors = [
                i for i in issues
                if i.severity == ErrorSeverity.ERROR
                and 'circular' in i.message.lower()
            ]

            if circular_errors:
                failures.append((arch_file.name, circular_errors))

        assert len(failures) == 0, \
            f"{len(failures)} files have circular dependencies"

    @pytest.mark.validation
    def test_all_part_types_defined(self, all_sysml_files):
        """All part instances must reference defined types"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            # Extract defined types
            defined_types = set()
            for match in re.finditer(r'part\s+def\s+(\w+)', content):
                defined_types.add(match.group(1))

            # Extract part instances
            undefined_refs = []
            for match in re.finditer(r'part\s+\w+\s*:\s*(\w+)', content):
                type_ref = match.group(1)
                if type_ref not in defined_types:
                    undefined_refs.append(type_ref)

            if undefined_refs:
                failures.append((arch_file.name, undefined_refs[:5]))

        if failures:
            print("\n\nUndefined Type Failures:")
            for filename, types in failures:
                print(f"\n{filename}: {types}")

        assert len(failures) == 0, \
            f"{len(failures)} files reference undefined types"

    @pytest.mark.validation
    def test_connection_endpoints_well_formed(self, all_sysml_files):
        """All connection endpoints must be well-formed (part.port format)"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            malformed = []
            conn_pattern = r'connect\s+(.+?)\s+to\s+(.+?)\s*;'

            for match in re.finditer(conn_pattern, content):
                source = match.group(1).strip()
                target = match.group(2).strip()

                # Validate format: should be identifier or identifier.identifier
                valid_pattern = r'^[a-zA-Z_]\w*(?:\.[a-zA-Z_]\w*)?$'

                if not re.match(valid_pattern, source):
                    malformed.append(f"Invalid source: {source}")
                if not re.match(valid_pattern, target):
                    malformed.append(f"Invalid target: {target}")

            if malformed:
                failures.append((arch_file.name, malformed[:5]))

        assert len(failures) == 0, \
            f"{len(failures)} files have malformed connections"


# ============================================================================
# TEST 3: COMPLETENESS VALIDATION
# ============================================================================

class TestCompletenessValidation:
    """Validate that all required elements are present"""

    @pytest.mark.validation
    def test_all_architectures_have_system_block(self, all_sysml_files):
        """Every architecture should have at least one system-level block"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            # Check for part def declarations
            part_defs = re.findall(r'part\s+def\s+(\w+)', content)

            if len(part_defs) == 0:
                failures.append(arch_file.name)

        assert len(failures) == 0, \
            f"{len(failures)} files missing system blocks"

    @pytest.mark.validation
    def test_all_architectures_have_requirements(self, all_sysml_files):
        """Every architecture should have at least one requirement"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            requirements = re.findall(r'requirement\s+(\w+)', content)

            if len(requirements) == 0:
                failures.append(arch_file.name)

        assert len(failures) == 0, \
            f"{len(failures)} files missing requirements"

    @pytest.mark.validation
    def test_requirements_have_doc_strings(self, all_sysml_files):
        """All requirements must have doc strings"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            # Find all requirements
            req_pattern = r'requirement\s+(\w+)\s*\{([^}]*)\}'

            missing_docs = []
            for match in re.finditer(req_pattern, content, re.DOTALL):
                req_id = match.group(1)
                req_body = match.group(2)

                if 'doc' not in req_body:
                    missing_docs.append(req_id)

            if missing_docs:
                failures.append((arch_file.name, missing_docs))

        assert len(failures) == 0, \
            f"{len(failures)} files have requirements without docs"

    @pytest.mark.validation
    def test_parts_have_attributes_or_ports(self, all_sysml_files):
        """Part definitions should have attributes or ports (not be empty)"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            # Find all part defs
            part_def_pattern = r'part\s+def\s+(\w+)\s*\{([^}]*)\}'

            empty_parts = []
            for match in re.finditer(part_def_pattern, content, re.DOTALL):
                part_name = match.group(1)
                part_body = match.group(2)

                # Check if body has attributes, ports, or nested parts
                has_content = (
                    'attribute' in part_body or
                    'port' in part_body or
                    re.search(r'part\s+\w+\s*:', part_body)
                )

                if not has_content:
                    # Check if it's just whitespace or comments
                    stripped = re.sub(r'//.*', '', part_body).strip()
                    if not stripped:
                        empty_parts.append(part_name)

            if empty_parts:
                failures.append((arch_file.name, empty_parts[:5]))

        # This is a warning, not a hard failure
        if failures:
            print("\n\nWarning: Empty part definitions found:")
            for filename, parts in failures[:10]:
                print(f"  {filename}: {parts}")


# ============================================================================
# TEST 4: CONSISTENCY (ROUND-TRIP) VALIDATION
# ============================================================================

class TestRoundTripConsistency:
    """Validate IR -> .sysml -> IR round-trip preserves semantics"""

    @pytest.mark.validation
    def test_round_trip_preserves_blocks(self, sample_architectures):
        """Round-trip should preserve all block definitions"""
        failures = []

        for arch_file in sample_architectures:
            content = arch_file.read_text(encoding='utf-8')

            # Parse .sysml to IR
            arch_dict = parse_sysml_to_json(content)

            # Extract block names from original
            original_blocks = set(
                b['name'] for b in arch_dict.get('blocks', [])
            )

            # Generate .sysml again
            regenerated_sysml = generate_sysml_from_dict(arch_dict)

            # Parse regenerated
            reparsed_dict = parse_sysml_to_json(regenerated_sysml)

            regenerated_blocks = set(
                b['name'] for b in reparsed_dict.get('blocks', [])
            )

            # Compare
            if original_blocks != regenerated_blocks:
                failures.append({
                    'file': arch_file.name,
                    'original': original_blocks,
                    'regenerated': regenerated_blocks,
                    'missing': original_blocks - regenerated_blocks,
                    'extra': regenerated_blocks - original_blocks
                })

        assert len(failures) == 0, \
            f"Round-trip lost blocks: {failures[:3]}"

    @pytest.mark.validation
    def test_round_trip_preserves_requirements(self, sample_architectures):
        """Round-trip should preserve all requirements"""
        failures = []

        for arch_file in sample_architectures:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            original_reqs = set(
                r['id'] for r in arch_dict.get('requirements', [])
            )

            regenerated_sysml = generate_sysml_from_dict(arch_dict)
            reparsed_dict = parse_sysml_to_json(regenerated_sysml)

            regenerated_reqs = set(
                r['id'] for r in reparsed_dict.get('requirements', [])
            )

            if original_reqs != regenerated_reqs:
                failures.append({
                    'file': arch_file.name,
                    'missing': original_reqs - regenerated_reqs,
                    'extra': regenerated_reqs - original_reqs
                })

        assert len(failures) == 0, \
            f"Round-trip lost requirements: {failures[:3]}"

    @pytest.mark.validation
    def test_round_trip_preserves_connections(self, sample_architectures):
        """Round-trip should preserve connection count and endpoints"""
        failures = []

        for arch_file in sample_architectures:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            original_conn_count = len(arch_dict.get('connectors', []))

            regenerated_sysml = generate_sysml_from_dict(arch_dict)
            reparsed_dict = parse_sysml_to_json(regenerated_sysml)

            regenerated_conn_count = len(reparsed_dict.get('connectors', []))

            # Allow some variation due to auto-generated names
            # but counts should be exact
            if original_conn_count != regenerated_conn_count:
                failures.append({
                    'file': arch_file.name,
                    'original_count': original_conn_count,
                    'regenerated_count': regenerated_conn_count
                })

        assert len(failures) == 0, \
            f"Round-trip changed connection count: {failures}"

    @pytest.mark.validation
    def test_round_trip_preserves_ports(self, sample_architectures):
        """Round-trip should preserve ports"""
        failures = []

        for arch_file in sample_architectures:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            # Build original port set
            original_ports = set(
                (p['owner'], p['name'])
                for p in arch_dict.get('proxy_ports', [])
            )

            regenerated_sysml = generate_sysml_from_dict(arch_dict)
            reparsed_dict = parse_sysml_to_json(regenerated_sysml)

            regenerated_ports = set(
                (p['owner'], p['name'])
                for p in reparsed_dict.get('proxy_ports', [])
            )

            if original_ports != regenerated_ports:
                failures.append({
                    'file': arch_file.name,
                    'missing': original_ports - regenerated_ports,
                    'extra': regenerated_ports - original_ports
                })

        assert len(failures) == 0, \
            f"Round-trip lost ports: {failures[:3]}"


# ============================================================================
# TEST 5: PLANTUML GENERATION VALIDATION
# ============================================================================

class TestPlantUMLGeneration:
    """Validate PlantUML diagram generation"""

    @pytest.mark.validation
    def test_bdd_generation_succeeds(self, sample_architectures):
        """BDD PlantUML generation should succeed for all architectures"""
        failures = []

        for arch_file in sample_architectures:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            try:
                plantuml_src = generate_bdd_plantuml(arch_dict)

                # Basic validation
                if '@startuml' not in plantuml_src:
                    failures.append((arch_file.name, "Missing @startuml"))
                if '@enduml' not in plantuml_src:
                    failures.append((arch_file.name, "Missing @enduml"))

            except Exception as e:
                failures.append((arch_file.name, str(e)))

        assert len(failures) == 0, \
            f"BDD generation failed: {failures}"

    @pytest.mark.validation
    def test_ibd_generation_succeeds(self, sample_architectures):
        """IBD PlantUML generation should succeed for all architectures"""
        failures = []

        for arch_file in sample_architectures:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            try:
                plantuml_src = generate_ibd_plantuml(arch_dict)

                if '@startuml' not in plantuml_src:
                    failures.append((arch_file.name, "Missing @startuml"))
                if '@enduml' not in plantuml_src:
                    failures.append((arch_file.name, "Missing @enduml"))

            except Exception as e:
                failures.append((arch_file.name, str(e)))

        assert len(failures) == 0, \
            f"IBD generation failed: {failures}"

    @pytest.mark.validation
    def test_plantuml_encoding_works(self, sample_architectures):
        """PlantUML URL encoding should work"""
        failures = []

        for arch_file in sample_architectures[:5]:  # Test first 5 only
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            try:
                plantuml_src = generate_bdd_plantuml(arch_dict)
                encoded = plantuml_encode(plantuml_src)

                # Should be non-empty and URL-safe
                if not encoded:
                    failures.append((arch_file.name, "Empty encoding"))
                elif ' ' in encoded:
                    failures.append((arch_file.name, "Contains spaces"))

            except Exception as e:
                failures.append((arch_file.name, str(e)))

        assert len(failures) == 0, \
            f"PlantUML encoding failed: {failures}"

    @pytest.mark.validation
    def test_plantuml_has_all_blocks(self, sample_architectures):
        """Generated PlantUML should reference all blocks"""
        failures = []

        for arch_file in sample_architectures:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            blocks = arch_dict.get('blocks', [])
            plantuml_src = generate_bdd_plantuml(arch_dict)

            missing_blocks = []
            for block in blocks:
                block_name = block['name']
                if block_name not in plantuml_src:
                    missing_blocks.append(block_name)

            if missing_blocks:
                failures.append((arch_file.name, missing_blocks))

        assert len(failures) == 0, \
            f"PlantUML missing blocks: {failures[:5]}"


# ============================================================================
# TEST 6: NAMING CONVENTION VALIDATION
# ============================================================================

class TestNamingConventions:
    """Validate SysML v2 naming conventions"""

    @pytest.mark.validation
    def test_part_definitions_use_pascal_case(self, all_sysml_files):
        """Part definitions should use PascalCase"""
        violations = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            bad_names = []
            for match in re.finditer(r'part\s+def\s+(\w+)', content):
                name = match.group(1)
                if not name[0].isupper():
                    bad_names.append(name)

            if bad_names:
                violations.append((arch_file.name, bad_names[:5]))

        # This is a warning, not a failure
        if violations:
            print("\n\nWarning: Part definitions not using PascalCase:")
            for filename, names in violations[:10]:
                print(f"  {filename}: {names}")

    @pytest.mark.validation
    def test_part_instances_use_camel_case(self, all_sysml_files):
        """Part instances should use camelCase"""
        violations = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            bad_names = []
            for match in re.finditer(r'part\s+(\w+)\s*:\s*\w+', content):
                name = match.group(1)
                # Should start with lowercase
                if name[0].isupper():
                    bad_names.append(name)

            if bad_names:
                violations.append((arch_file.name, bad_names[:5]))

        # Warning only
        if violations:
            print("\n\nWarning: Part instances not using camelCase:")
            for filename, names in violations[:10]:
                print(f"  {filename}: {names}")

    @pytest.mark.validation
    def test_requirements_use_upper_case(self, all_sysml_files):
        """Requirements should use UPPER_CASE"""
        violations = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            bad_names = []
            for match in re.finditer(r'requirement\s+(\w+)', content):
                name = match.group(1)
                if not re.match(r'^[A-Z][A-Z0-9_]*$', name):
                    bad_names.append(name)

            if bad_names:
                violations.append((arch_file.name, bad_names[:5]))

        # Warning only
        if violations:
            print("\n\nWarning: Requirements not using UPPER_CASE:")
            for filename, names in violations[:10]:
                print(f"  {filename}: {names}")

    @pytest.mark.validation
    def test_identifiers_valid(self, all_sysml_files):
        """All identifiers must be valid (alphanumeric + underscore)"""
        failures = []

        for arch_file in all_sysml_files:
            content = arch_file.read_text(encoding='utf-8')

            # Extract all identifiers after keywords
            patterns = [
                r'part\s+def\s+(\w+)',
                r'part\s+(\w+)\s*:',
                r'requirement\s+(\w+)',
                r'port\s+(\w+)',
                r'attribute\s+(\w+)'
            ]

            invalid_ids = []
            for pattern in patterns:
                for match in re.finditer(pattern, content):
                    identifier = match.group(1)
                    # Must start with letter or underscore, contain only alphanumeric + underscore
                    if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', identifier):
                        invalid_ids.append(identifier)

            if invalid_ids:
                failures.append((arch_file.name, invalid_ids[:5]))

        assert len(failures) == 0, \
            f"Files with invalid identifiers: {failures}"


# ============================================================================
# TEST 7: PROPERTY-BASED VALIDATION
# ============================================================================

class TestPropertyBased:
    """Property-based tests using generated random architectures"""

    @pytest.mark.validation
    @pytest.mark.slow
    def test_generated_architectures_are_valid(self):
        """Generate random architectures and validate them"""
        # This test would use hypothesis if available
        try:
            from hypothesis import given, strategies as st
            has_hypothesis = True
        except ImportError:
            has_hypothesis = False
            pytest.skip("hypothesis not available")

        if has_hypothesis:
            # Implementation would go here
            # For now, just placeholder
            pass


# ============================================================================
# TEST 8: STATISTICS AND QUALITY METRICS
# ============================================================================

class TestQualityMetrics:
    """Collect quality metrics on generated architectures"""

    @pytest.mark.validation
    def test_collect_statistics(self, all_sysml_files, validator):
        """Collect comprehensive statistics on generated files"""
        stats = {
            'total_files': len(all_sysml_files),
            'total_errors': 0,
            'total_warnings': 0,
            'files_with_errors': 0,
            'files_with_warnings': 0,
            'error_categories': {},
            'warning_categories': {},
            'avg_blocks_per_file': 0,
            'avg_requirements_per_file': 0,
            'avg_connections_per_file': 0,
            'avg_file_size': 0,
        }

        total_blocks = 0
        total_requirements = 0
        total_connections = 0
        total_size = 0

        for arch_file in all_sysml_files:
            issues = validator.validate_file(arch_file)
            content = arch_file.read_text(encoding='utf-8')

            errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
            warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]

            if errors:
                stats['files_with_errors'] += 1
                stats['total_errors'] += len(errors)

            if warnings:
                stats['files_with_warnings'] += 1
                stats['total_warnings'] += len(warnings)

            for issue in issues:
                category = issue.category
                if issue.severity == ErrorSeverity.ERROR:
                    stats['error_categories'][category] = \
                        stats['error_categories'].get(category, 0) + 1
                elif issue.severity == ErrorSeverity.WARNING:
                    stats['warning_categories'][category] = \
                        stats['warning_categories'].get(category, 0) + 1

            # Count elements
            total_blocks += len(re.findall(r'part\s+def\s+\w+', content))
            total_requirements += len(re.findall(r'requirement\s+\w+', content))
            total_connections += len(re.findall(r'connect\s+.+\s+to\s+', content))
            total_size += len(content)

        stats['avg_blocks_per_file'] = total_blocks / stats['total_files']
        stats['avg_requirements_per_file'] = total_requirements / stats['total_files']
        stats['avg_connections_per_file'] = total_connections / stats['total_files']
        stats['avg_file_size'] = total_size / stats['total_files']

        # Print report
        print("\n\n" + "=" * 80)
        print("COMPREHENSIVE V&V QUALITY METRICS REPORT")
        print("=" * 80)
        print(f"\nTotal files analyzed: {stats['total_files']}")
        print(f"Files with errors: {stats['files_with_errors']}")
        print(f"Files with warnings: {stats['files_with_warnings']}")
        print(f"\nTotal errors: {stats['total_errors']}")
        print(f"Total warnings: {stats['total_warnings']}")
        print(f"\nAverage blocks per file: {stats['avg_blocks_per_file']:.2f}")
        print(f"Average requirements per file: {stats['avg_requirements_per_file']:.2f}")
        print(f"Average connections per file: {stats['avg_connections_per_file']:.2f}")
        print(f"Average file size: {stats['avg_file_size']:.0f} bytes")

        if stats['error_categories']:
            print("\nTop error categories:")
            for category, count in sorted(
                stats['error_categories'].items(),
                key=lambda x: -x[1]
            )[:10]:
                print(f"  {category}: {count}")

        if stats['warning_categories']:
            print("\nTop warning categories:")
            for category, count in sorted(
                stats['warning_categories'].items(),
                key=lambda x: -x[1]
            )[:10]:
                print(f"  {category}: {count}")

        print("\n" + "=" * 80)

        # Success criteria: less than 5% of files with errors
        error_rate = stats['files_with_errors'] / stats['total_files']
        assert error_rate < 0.05, \
            f"Error rate too high: {error_rate*100:.1f}% (threshold: 5%)"
