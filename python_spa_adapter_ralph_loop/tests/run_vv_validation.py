#!/usr/bin/env python3
"""
Verification and Validation Test Runner

Runs comprehensive V&V checks on generated SysML files without requiring pytest.
This is a simple runner that can be used in environments where pytest is not available.
"""
import sys
import time
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent / 'spa'))

from tests.test_sysml_validation import SysMLValidator, ErrorSeverity
from lib.sysml_generator import generate_sysml_from_dict
from sysml_parser import parse_sysml_to_json
from server import generate_bdd_plantuml, generate_ibd_plantuml
import re


def print_header(title):
    """Print section header"""
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70 + "\n")


def print_test_result(test_name, passed, details=None):
    """Print test result"""
    status = "✓ PASS" if passed else "✗ FAIL"
    print(f"{status}: {test_name}")
    if details and not passed:
        print(f"  {details}")


def test_syntactic_validation(validator, sysml_files):
    """Test 1: Syntactic Validation"""
    print_header("TEST 1: SYNTACTIC VALIDATION")

    test_results = []

    # Test 1.1: No syntax errors
    print("1.1: Testing all files for syntax errors...")
    failed_files = []
    for arch_file in sysml_files:
        issues = validator.validate_file(arch_file)
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        if errors:
            failed_files.append((arch_file.name, len(errors)))

    passed = len(failed_files) == 0
    test_results.append(('Syntax error check', passed))
    print_test_result(
        "All files syntactically valid",
        passed,
        f"{len(failed_files)} files have errors" if not passed else None
    )

    # Test 1.2: Package declarations
    print("\n1.2: Testing package declarations...")
    missing_package = []
    for arch_file in sysml_files:
        content = arch_file.read_text(encoding='utf-8')
        if not re.search(r'^\s*package\s+\w+\s*\{', content, re.MULTILINE):
            missing_package.append(arch_file.name)

    passed = len(missing_package) == 0
    test_results.append(('Package declaration check', passed))
    print_test_result(
        "All files have package declarations",
        passed,
        f"{len(missing_package)} files missing package" if not passed else None
    )

    # Test 1.3: Balanced braces
    print("\n1.3: Testing balanced braces...")
    unbalanced = []
    for arch_file in sysml_files:
        content = arch_file.read_text(encoding='utf-8')
        open_count = content.count('{')
        close_count = content.count('}')
        if open_count != close_count:
            unbalanced.append((arch_file.name, open_count, close_count))

    passed = len(unbalanced) == 0
    test_results.append(('Balanced braces check', passed))
    print_test_result(
        "All files have balanced braces",
        passed,
        f"{len(unbalanced)} files have unbalanced braces" if not passed else None
    )

    return test_results


def test_semantic_validation(validator, sysml_files):
    """Test 2: Semantic Validation"""
    print_header("TEST 2: SEMANTIC VALIDATION")

    test_results = []

    # Test 2.1: Valid port references
    print("2.1: Testing port references...")
    port_errors = []
    for arch_file in sysml_files:
        issues = validator.validate_file(arch_file)
        errors = [
            i for i in issues
            if i.severity == ErrorSeverity.ERROR
            and 'undefined' in i.message.lower()
            and 'port' in i.message.lower()
        ]
        if errors:
            port_errors.append((arch_file.name, len(errors)))

    passed = len(port_errors) == 0
    test_results.append(('Port reference check', passed))
    print_test_result(
        "All port references are valid",
        passed,
        f"{len(port_errors)} files have invalid port references" if not passed else None
    )

    # Test 2.2: Valid requirement references
    print("\n2.2: Testing requirement references...")
    req_errors = []
    for arch_file in sysml_files:
        issues = validator.validate_file(arch_file)
        errors = [
            i for i in issues
            if i.severity == ErrorSeverity.ERROR
            and 'undefined' in i.message.lower()
            and 'requirement' in i.message.lower()
        ]
        if errors:
            req_errors.append((arch_file.name, len(errors)))

    passed = len(req_errors) == 0
    test_results.append(('Requirement reference check', passed))
    print_test_result(
        "All requirement references are valid",
        passed,
        f"{len(req_errors)} files have invalid requirement references" if not passed else None
    )

    # Test 2.3: No circular dependencies
    print("\n2.3: Testing for circular dependencies...")
    circular = []
    for arch_file in sysml_files:
        issues = validator.validate_file(arch_file)
        errors = [
            i for i in issues
            if i.severity == ErrorSeverity.ERROR
            and 'circular' in i.message.lower()
        ]
        if errors:
            circular.append(arch_file.name)

    passed = len(circular) == 0
    test_results.append(('Circular dependency check', passed))
    print_test_result(
        "No circular dependencies",
        passed,
        f"{len(circular)} files have circular dependencies" if not passed else None
    )

    return test_results


def test_completeness(sysml_files):
    """Test 3: Completeness Validation"""
    print_header("TEST 3: COMPLETENESS VALIDATION")

    test_results = []

    # Test 3.1: All architectures have system blocks
    print("3.1: Testing for system blocks...")
    missing_blocks = []
    for arch_file in sysml_files:
        content = arch_file.read_text(encoding='utf-8')
        if not re.search(r'part\s+def\s+\w+', content):
            missing_blocks.append(arch_file.name)

    passed = len(missing_blocks) == 0
    test_results.append(('System block check', passed))
    print_test_result(
        "All architectures have system blocks",
        passed,
        f"{len(missing_blocks)} files missing blocks" if not passed else None
    )

    # Test 3.2: All architectures have requirements
    print("\n3.2: Testing for requirements...")
    missing_reqs = []
    for arch_file in sysml_files:
        content = arch_file.read_text(encoding='utf-8')
        if not re.search(r'requirement\s+\w+', content):
            missing_reqs.append(arch_file.name)

    passed = len(missing_reqs) == 0
    test_results.append(('Requirements check', passed))
    print_test_result(
        "All architectures have requirements",
        passed,
        f"{len(missing_reqs)} files missing requirements" if not passed else None
    )

    # Test 3.3: Requirements have doc strings
    print("\n3.3: Testing requirement doc strings...")
    missing_docs = []
    for arch_file in sysml_files:
        content = arch_file.read_text(encoding='utf-8')
        for match in re.finditer(r'requirement\s+(\w+)\s*\{([^}]*)\}', content, re.DOTALL):
            req_body = match.group(2)
            if 'doc' not in req_body:
                missing_docs.append((arch_file.name, match.group(1)))
                break

    passed = len(missing_docs) == 0
    test_results.append(('Requirement doc strings check', passed))
    print_test_result(
        "All requirements have doc strings",
        passed,
        f"{len(missing_docs)} files have requirements without docs" if not passed else None
    )

    return test_results


def test_round_trip(sysml_files):
    """Test 4: Round-trip Consistency"""
    print_header("TEST 4: ROUND-TRIP CONSISTENCY")

    test_results = []
    sample_files = sysml_files[::5]  # Test every 5th file

    # Test 4.1: Round-trip preserves blocks
    print("4.1: Testing round-trip block preservation...")
    block_failures = []
    for arch_file in sample_files:
        try:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            original_blocks = set(b['name'] for b in arch_dict.get('blocks', []))

            regenerated_sysml = generate_sysml_from_dict(arch_dict)
            reparsed_dict = parse_sysml_to_json(regenerated_sysml)

            regenerated_blocks = set(b['name'] for b in reparsed_dict.get('blocks', []))

            if original_blocks != regenerated_blocks:
                block_failures.append(arch_file.name)
        except Exception as e:
            block_failures.append(f"{arch_file.name}: {str(e)}")

    passed = len(block_failures) == 0
    test_results.append(('Round-trip block preservation', passed))
    print_test_result(
        "Round-trip preserves blocks",
        passed,
        f"{len(block_failures)} files lost blocks" if not passed else None
    )

    # Test 4.2: Round-trip preserves requirements
    print("\n4.2: Testing round-trip requirement preservation...")
    req_failures = []
    for arch_file in sample_files:
        try:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            original_reqs = set(r['id'] for r in arch_dict.get('requirements', []))

            regenerated_sysml = generate_sysml_from_dict(arch_dict)
            reparsed_dict = parse_sysml_to_json(regenerated_sysml)

            regenerated_reqs = set(r['id'] for r in reparsed_dict.get('requirements', []))

            if original_reqs != regenerated_reqs:
                req_failures.append(arch_file.name)
        except Exception as e:
            req_failures.append(f"{arch_file.name}: {str(e)}")

    passed = len(req_failures) == 0
    test_results.append(('Round-trip requirement preservation', passed))
    print_test_result(
        "Round-trip preserves requirements",
        passed,
        f"{len(req_failures)} files lost requirements" if not passed else None
    )

    # Test 4.3: Round-trip preserves connection count
    print("\n4.3: Testing round-trip connection count...")
    conn_failures = []
    for arch_file in sample_files:
        try:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)

            original_count = len(arch_dict.get('connectors', []))

            regenerated_sysml = generate_sysml_from_dict(arch_dict)
            reparsed_dict = parse_sysml_to_json(regenerated_sysml)

            regenerated_count = len(reparsed_dict.get('connectors', []))

            if original_count != regenerated_count:
                conn_failures.append((arch_file.name, original_count, regenerated_count))
        except Exception as e:
            conn_failures.append(f"{arch_file.name}: {str(e)}")

    passed = len(conn_failures) == 0
    test_results.append(('Round-trip connection preservation', passed))
    print_test_result(
        "Round-trip preserves connection count",
        passed,
        f"{len(conn_failures)} files changed connection count" if not passed else None
    )

    return test_results


def test_plantuml_generation(sysml_files):
    """Test 5: PlantUML Generation"""
    print_header("TEST 5: PLANTUML GENERATION")

    test_results = []
    sample_files = sysml_files[::5]  # Test every 5th file

    # Test 5.1: BDD generation succeeds
    print("5.1: Testing BDD generation...")
    bdd_failures = []
    for arch_file in sample_files:
        try:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)
            plantuml_src = generate_bdd_plantuml(arch_dict)

            if '@startuml' not in plantuml_src or '@enduml' not in plantuml_src:
                bdd_failures.append(arch_file.name)
        except Exception as e:
            bdd_failures.append(f"{arch_file.name}: {str(e)}")

    passed = len(bdd_failures) == 0
    test_results.append(('BDD generation', passed))
    print_test_result(
        "BDD generation succeeds",
        passed,
        f"{len(bdd_failures)} files failed BDD generation" if not passed else None
    )

    # Test 5.2: IBD generation succeeds
    print("\n5.2: Testing IBD generation...")
    ibd_failures = []
    for arch_file in sample_files:
        try:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)
            plantuml_src = generate_ibd_plantuml(arch_dict)

            if '@startuml' not in plantuml_src or '@enduml' not in plantuml_src:
                ibd_failures.append(arch_file.name)
        except Exception as e:
            ibd_failures.append(f"{arch_file.name}: {str(e)}")

    passed = len(ibd_failures) == 0
    test_results.append(('IBD generation', passed))
    print_test_result(
        "IBD generation succeeds",
        passed,
        f"{len(ibd_failures)} files failed IBD generation" if not passed else None
    )

    # Test 5.3: PlantUML includes all blocks
    print("\n5.3: Testing PlantUML completeness...")
    incomplete = []
    for arch_file in sample_files:
        try:
            content = arch_file.read_text(encoding='utf-8')
            arch_dict = parse_sysml_to_json(content)
            plantuml_src = generate_bdd_plantuml(arch_dict)

            blocks = arch_dict.get('blocks', [])
            missing = [b['name'] for b in blocks if b['name'] not in plantuml_src]

            if missing:
                incomplete.append((arch_file.name, missing))
        except Exception as e:
            incomplete.append(f"{arch_file.name}: {str(e)}")

    passed = len(incomplete) == 0
    test_results.append(('PlantUML completeness', passed))
    print_test_result(
        "PlantUML includes all blocks",
        passed,
        f"{len(incomplete)} files have incomplete PlantUML" if not passed else None
    )

    return test_results


def collect_statistics(validator, sysml_files):
    """Collect and display statistics"""
    print_header("QUALITY METRICS REPORT")

    stats = {
        'total_files': len(sysml_files),
        'total_errors': 0,
        'total_warnings': 0,
        'files_with_errors': 0,
        'error_categories': {},
    }

    total_blocks = 0
    total_requirements = 0
    total_connections = 0
    total_size = 0

    for arch_file in sysml_files:
        issues = validator.validate_file(arch_file)
        content = arch_file.read_text(encoding='utf-8')

        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]

        if errors:
            stats['files_with_errors'] += 1
            stats['total_errors'] += len(errors)

        if warnings:
            stats['total_warnings'] += len(warnings)

        for issue in issues:
            if issue.severity == ErrorSeverity.ERROR:
                cat = issue.category
                stats['error_categories'][cat] = stats['error_categories'].get(cat, 0) + 1

        # Count elements
        total_blocks += len(re.findall(r'part\s+def\s+\w+', content))
        total_requirements += len(re.findall(r'requirement\s+\w+', content))
        total_connections += len(re.findall(r'connect\s+.+\s+to\s+', content))
        total_size += len(content)

    print(f"Total files analyzed: {stats['total_files']}")
    print(f"Files with errors: {stats['files_with_errors']}")
    print(f"Total errors: {stats['total_errors']}")
    print(f"Total warnings: {stats['total_warnings']}")
    print(f"\nAverage blocks per file: {total_blocks / stats['total_files']:.2f}")
    print(f"Average requirements per file: {total_requirements / stats['total_files']:.2f}")
    print(f"Average connections per file: {total_connections / stats['total_files']:.2f}")
    print(f"Average file size: {total_size / stats['total_files']:.0f} bytes")

    if stats['error_categories']:
        print("\nTop error categories:")
        for cat, count in sorted(stats['error_categories'].items(), key=lambda x: -x[1])[:10]:
            print(f"  {cat}: {count}")

    error_rate = stats['files_with_errors'] / stats['total_files']
    print(f"\nError rate: {error_rate * 100:.1f}%")

    return error_rate < 0.05  # Pass if less than 5% error rate


def main():
    """Run all V&V tests"""
    start_time = time.time()

    print("\n" + "=" * 70)
    print("  COMPREHENSIVE V&V TEST SUITE FOR GENERATED SYSML")
    print("=" * 70)

    # Setup
    validator = SysMLValidator()
    arch_dir = Path(__file__).parent.parent / 'data' / 'architectures'
    sysml_files = sorted(arch_dir.glob('*.sysml'))

    print(f"\nFound {len(sysml_files)} .sysml files to validate")

    all_results = []

    # Run test suites
    try:
        all_results.extend(test_syntactic_validation(validator, sysml_files))
        all_results.extend(test_semantic_validation(validator, sysml_files))
        all_results.extend(test_completeness(sysml_files))
        all_results.extend(test_round_trip(sysml_files))
        all_results.extend(test_plantuml_generation(sysml_files))

        # Collect statistics
        stats_passed = collect_statistics(validator, sysml_files)
        all_results.append(('Quality metrics (error rate < 5%)', stats_passed))

    except Exception as e:
        print(f"\n✗ FATAL ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return 1

    # Summary
    duration = time.time() - start_time
    passed = sum(1 for _, result in all_results if result)
    total = len(all_results)

    print_header("TEST SUMMARY")
    print(f"Total tests: {total}")
    print(f"Passed: {passed}")
    print(f"Failed: {total - passed}")
    print(f"Duration: {duration:.2f} seconds")

    if passed == total:
        print(f"\nStatus: ALL V&V TESTS PASSED ✓")
        return 0
    else:
        print(f"\nStatus: {total - passed} V&V TESTS FAILED ✗")
        return 1


if __name__ == '__main__':
    sys.exit(main())
