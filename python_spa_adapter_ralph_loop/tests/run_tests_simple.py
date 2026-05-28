#!/usr/bin/env python3
"""
Simple test runner that doesn't require pytest.
Runs tests by importing and executing test functions.
"""

import sys
import time
from pathlib import Path

# Add project paths
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT / 'spa'))
sys.path.insert(0, str(PROJECT_ROOT / 'scripts'))
sys.path.insert(0, str(PROJECT_ROOT / 'lib'))


def print_header(text):
    """Print a formatted header"""
    print("\n" + "=" * 70)
    print(f"  {text}")
    print("=" * 70 + "\n")


def print_test_result(test_name, passed, error=None):
    """Print result of a single test"""
    status = "✓ PASS" if passed else "✗ FAIL"
    print(f"{status}: {test_name}")
    if error and not passed:
        print(f"  Error: {error}")


def run_parser_tests():
    """Run parser tests"""
    print_header("Parser Tests")

    from sysml_parser import parse_sysml_to_json

    test_sysml = """package test_arch {
    // Test Architecture
    // Domain: test

    import ScalarValues::*;

    interface def DataIF;

    part def System {
    }

    part def SubsystemA {
        port dataOut : DataIF;
    }

    part system : System {
        part subsystemA : SubsystemA;
    }
}
"""

    passed = 0
    failed = 0

    # Test 1: Basic parsing
    try:
        result = parse_sysml_to_json(test_sysml)
        assert result['id'] == 'test_arch', f"Expected 'test_arch', got '{result['id']}'"
        assert len(result['blocks']) > 0, "No blocks parsed"
        print_test_result("test_basic_parsing", True)
        passed += 1
    except Exception as e:
        print_test_result("test_basic_parsing", False, str(e))
        failed += 1

    # Test 2: Block parsing
    try:
        result = parse_sysml_to_json(test_sysml)
        block_names = [b['name'] for b in result['blocks']]
        assert 'System' in block_names, "System block not found"
        assert 'SubsystemA' in block_names, "SubsystemA block not found"
        print_test_result("test_block_parsing", True)
        passed += 1
    except Exception as e:
        print_test_result("test_block_parsing", False, str(e))
        failed += 1

    # Test 3: Port parsing
    try:
        result = parse_sysml_to_json(test_sysml)
        assert len(result['proxy_ports']) > 0, "No ports parsed"
        port_names = [p['name'] for p in result['proxy_ports']]
        assert 'dataOut' in port_names, "dataOut port not found"
        print_test_result("test_port_parsing", True)
        passed += 1
    except Exception as e:
        print_test_result("test_port_parsing", False, str(e))
        failed += 1

    return passed, failed


def run_validation_tests():
    """Run validation tests"""
    print_header("Validation Tests")

    from sysml_parser import parse_sysml_to_json

    arch_dir = PROJECT_ROOT / "data" / "architectures"
    if not arch_dir.exists():
        print("⊘ Architecture directory not found, skipping validation tests")
        return 0, 0

    passed = 0
    failed = 0

    # Test: Parse existing architectures
    try:
        arch_files = list(arch_dir.glob("arch_*.sysml"))[:3]
        if arch_files:
            for arch_file in arch_files:
                content = arch_file.read_text()
                result = parse_sysml_to_json(content, file_path=arch_file)
                assert result['id'], f"Missing ID in {arch_file.name}"
                assert len(result['blocks']) > 0, f"No blocks in {arch_file.name}"
            print_test_result("test_existing_architectures", True)
            passed += 1
        else:
            print("⊘ No architecture files found")
    except Exception as e:
        print_test_result("test_existing_architectures", False, str(e))
        failed += 1

    return passed, failed


def run_integration_tests():
    """Run integration tests"""
    print_header("Integration Tests")

    from sysml_parser import parse_sysml_to_json

    passed = 0
    failed = 0

    # Test: Full parsing pipeline
    try:
        test_content = """package integration_test {
    part def TestBlock {
        attribute attr1 : Real;
    }

    requirement <'REQ-001'> {
        doc /* Test requirement */
    }

    part testblock : TestBlock {
        satisfy requirement <'REQ-001'> by testblock;
    }
}
"""
        result = parse_sysml_to_json(test_content)
        assert 'id' in result, "Missing ID"
        assert 'blocks' in result, "Missing blocks"
        assert 'requirements' in result, "Missing requirements"
        print_test_result("test_full_pipeline", True)
        passed += 1
    except Exception as e:
        print_test_result("test_full_pipeline", False, str(e))
        failed += 1

    return passed, failed


def main():
    """Run all tests"""
    print_header("SysML v2 Test Suite (Simple Runner)")
    print("Note: For full pytest features, install: pip install -r requirements-test.txt\n")

    start_time = time.time()

    total_passed = 0
    total_failed = 0

    # Run test suites
    try:
        p, f = run_parser_tests()
        total_passed += p
        total_failed += f

        p, f = run_validation_tests()
        total_passed += p
        total_failed += f

        p, f = run_integration_tests()
        total_passed += p
        total_failed += f

    except KeyboardInterrupt:
        print("\n\nTests interrupted by user")
        sys.exit(130)

    # Print summary
    duration = time.time() - start_time
    total_tests = total_passed + total_failed

    print("\n" + "=" * 70)
    print("  TEST SUMMARY")
    print("=" * 70)
    print(f"  Total tests: {total_tests}")
    print(f"  Passed: {total_passed}")
    print(f"  Failed: {total_failed}")
    print(f"  Duration: {duration:.2f} seconds")

    if total_failed == 0:
        print("  Status: ALL TESTS PASSED ✓")
        exit_code = 0
    else:
        print(f"  Status: {total_failed} TEST(S) FAILED ✗")
        exit_code = 1

    print("=" * 70 + "\n")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
