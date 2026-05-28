#!/usr/bin/env python3
"""
Unified test runner for all test suites.

Usage:
    python tests/run_tests.py                    # Run all tests
    python tests/run_tests.py --suite parser     # Run parser tests only
    python tests/run_tests.py --suite validation # Run validation tests only
    python tests/run_tests.py --suite integration # Run integration tests only
    python tests/run_tests.py --verbose          # Verbose output
    python tests/run_tests.py --coverage         # Generate coverage report
    python tests/run_tests.py --html             # Generate HTML coverage report
"""

import sys
import argparse
import subprocess
import time
from pathlib import Path

# Project root
PROJECT_ROOT = Path(__file__).parent.parent


def run_pytest(args):
    """Run pytest with specified arguments"""
    cmd = ["python3", "-m", "pytest"]

    # Add markers based on suite selection
    if args.suite == "parser":
        cmd.extend(["-m", "parser"])
    elif args.suite == "validation":
        cmd.extend(["-m", "validation"])
    elif args.suite == "integration":
        cmd.extend(["-m", "integration"])

    # Add verbose flag
    if args.verbose:
        cmd.append("-vv")

    # Add coverage
    if args.coverage or args.html:
        cmd.extend(["--cov=spa", "--cov=scripts", "--cov=lib"])
        cmd.append("--cov-report=term")

        if args.html:
            cmd.append("--cov-report=html")

    # Add parallel execution if requested
    if args.parallel:
        cmd.extend(["-n", "auto"])

    # Add test path
    cmd.append(str(PROJECT_ROOT / "tests"))

    # Additional pytest args
    if args.pytest_args:
        cmd.extend(args.pytest_args)

    return cmd


def print_header(text):
    """Print a formatted header"""
    print("\n" + "=" * 70)
    print(f"  {text}")
    print("=" * 70 + "\n")


def print_summary(start_time, exit_code):
    """Print test execution summary"""
    duration = time.time() - start_time

    print("\n" + "=" * 70)
    print("  TEST SUMMARY")
    print("=" * 70)
    print(f"  Duration: {duration:.2f} seconds")

    if exit_code == 0:
        print("  Status: ALL TESTS PASSED")
    elif exit_code == 5:
        print("  Status: NO TESTS COLLECTED")
    else:
        print(f"  Status: TESTS FAILED (exit code: {exit_code})")

    print("=" * 70 + "\n")


def main():
    parser = argparse.ArgumentParser(
        description="Unified test runner for SysML v2 adapter",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )

    parser.add_argument(
        "--suite",
        choices=["all", "parser", "validation", "integration"],
        default="all",
        help="Test suite to run (default: all)"
    )

    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output"
    )

    parser.add_argument(
        "--coverage",
        action="store_true",
        help="Generate coverage report"
    )

    parser.add_argument(
        "--html",
        action="store_true",
        help="Generate HTML coverage report"
    )

    parser.add_argument(
        "--parallel",
        action="store_true",
        help="Run tests in parallel (requires pytest-xdist)"
    )

    parser.add_argument(
        "pytest_args",
        nargs="*",
        help="Additional arguments to pass to pytest"
    )

    args = parser.parse_args()

    # Print header
    suite_name = args.suite.upper() if args.suite != "all" else "ALL"
    print_header(f"Running {suite_name} Tests")

    # Build pytest command
    cmd = run_pytest(args)

    # Print command for debugging
    if args.verbose:
        print(f"Command: {' '.join(cmd)}\n")

    # Run tests
    start_time = time.time()

    try:
        result = subprocess.run(cmd, cwd=PROJECT_ROOT)
        exit_code = result.returncode
    except KeyboardInterrupt:
        print("\n\nTests interrupted by user")
        exit_code = 130
    except Exception as e:
        print(f"\n\nError running tests: {e}")
        exit_code = 1

    # Print summary
    print_summary(start_time, exit_code)

    # Show coverage report location if generated
    if args.html and exit_code in [0, 5]:
        html_report = PROJECT_ROOT / "htmlcov" / "index.html"
        if html_report.exists():
            print(f"HTML coverage report: {html_report}\n")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
