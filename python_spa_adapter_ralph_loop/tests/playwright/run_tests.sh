#!/bin/bash

# SysML v2 SPA Playwright Test Runner
# Run comprehensive regression tests for the Single Page Application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "SysML v2 SPA Playwright Test Suite"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install
    echo ""
fi

# Check if Playwright browsers are installed
if [ ! -d "node_modules/@playwright/test" ]; then
    echo -e "${YELLOW}Installing Playwright...${NC}"
    npm install
fi

# Install browsers if needed
echo -e "${YELLOW}Checking Playwright browsers...${NC}"
npx playwright install chromium --with-deps
echo ""

# Parse arguments
HEADED=""
DEBUG=""
TEST_FILE=""
UI_MODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --headed)
            HEADED="--headed"
            shift
            ;;
        --debug)
            DEBUG="--debug"
            shift
            ;;
        --ui)
            UI_MODE="--ui"
            shift
            ;;
        --file=*)
            TEST_FILE="${1#*=}"
            shift
            ;;
        *)
            TEST_FILE="$1"
            shift
            ;;
    esac
done

# Build test command
TEST_CMD="npx playwright test"

if [ -n "$UI_MODE" ]; then
    echo -e "${GREEN}Running Playwright in UI mode...${NC}"
    TEST_CMD="$TEST_CMD $UI_MODE"
elif [ -n "$DEBUG" ]; then
    echo -e "${GREEN}Running Playwright in debug mode...${NC}"
    TEST_CMD="$TEST_CMD $DEBUG"
elif [ -n "$HEADED" ]; then
    echo -e "${GREEN}Running Playwright in headed mode...${NC}"
    TEST_CMD="$TEST_CMD $HEADED"
else
    echo -e "${GREEN}Running Playwright tests (headless)...${NC}"
fi

if [ -n "$TEST_FILE" ]; then
    echo -e "${YELLOW}Running specific test file: $TEST_FILE${NC}"
    TEST_CMD="$TEST_CMD $TEST_FILE"
fi

echo ""
echo "Command: $TEST_CMD"
echo ""

# Run tests
eval $TEST_CMD

# Capture exit code
EXIT_CODE=$?

echo ""
echo "=========================================="

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "View detailed report:"
    echo "  npm run report"
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "View detailed report:"
    echo "  npm run report"
    echo ""
    echo "Debug failing tests:"
    echo "  ./run_tests.sh --debug"
fi

echo "=========================================="
echo ""

exit $EXIT_CODE
