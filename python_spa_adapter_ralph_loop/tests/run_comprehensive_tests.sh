#!/bin/bash
# Run comprehensive test suite for SysML v2 pipeline
# Usage: bash tests/run_comprehensive_tests.sh

set -e  # Exit on error

cd "$(dirname "$0")/.."

echo "=========================================="
echo "SysML v2 Comprehensive Test Suite"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test suite components
TESTS=(
    "tests/test_validation_comprehensive.py"
    "tests/test_generator_comprehensive.py"
    "tests/test_parser_comprehensive.py"
    "tests/test_renderer_comprehensive.py"
    "tests/test_integration_comprehensive.py"
)

echo "Running comprehensive test suite..."
echo ""

# Track results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Run each test file
for TEST_FILE in "${TESTS[@]}"; do
    echo "----------------------------------------"
    echo "Running: $TEST_FILE"
    echo "----------------------------------------"

    if pytest "$TEST_FILE" -v --tb=short; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED_TESTS++))
    fi

    echo ""
done

# Run all comprehensive tests together for coverage
echo "=========================================="
echo "Running all tests with coverage..."
echo "=========================================="

if pytest tests/test_*_comprehensive.py -v --cov=lib --cov=spa --cov-report=term-missing --cov-report=html; then
    echo -e "${GREEN}✓ All tests completed${NC}"
else
    echo -e "${RED}✗ Some tests failed${NC}"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Test files run: ${#TESTS[@]}"
echo ""

# Generate coverage report
if command -v coverage &> /dev/null; then
    echo "Coverage report available at: htmlcov/index.html"
fi

echo ""
echo "=========================================="
echo "Test suite complete!"
echo "=========================================="
