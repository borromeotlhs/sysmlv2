#!/bin/bash

# Verify Playwright Test Setup
# Checks that all dependencies and prerequisites are met

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "Playwright Test Setup Verification"
echo "=========================================="
echo ""

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# Track overall status
OVERALL_STATUS=0

# Check Node.js
echo -e "${BLUE}Checking Node.js...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_status 0 "Node.js installed: $NODE_VERSION"
else
    print_status 1 "Node.js not found - please install Node.js 16+"
    OVERALL_STATUS=1
fi
echo ""

# Check npm
echo -e "${BLUE}Checking npm...${NC}"
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_status 0 "npm installed: $NPM_VERSION"
else
    print_status 1 "npm not found"
    OVERALL_STATUS=1
fi
echo ""

# Check node_modules
echo -e "${BLUE}Checking dependencies...${NC}"
if [ -d "node_modules" ]; then
    print_status 0 "node_modules directory exists"

    if [ -d "node_modules/@playwright/test" ]; then
        print_status 0 "Playwright test package installed"
    else
        print_status 1 "Playwright test package not found - run: npm install"
        OVERALL_STATUS=1
    fi
else
    print_status 1 "node_modules not found - run: npm install"
    OVERALL_STATUS=1
fi
echo ""

# Check Playwright browsers
echo -e "${BLUE}Checking Playwright browsers...${NC}"
if npx playwright --version &> /dev/null; then
    PLAYWRIGHT_VERSION=$(npx playwright --version)
    print_status 0 "Playwright CLI available: $PLAYWRIGHT_VERSION"

    # Check if chromium is installed
    if npx playwright install --dry-run chromium 2>&1 | grep -q "is already installed"; then
        print_status 0 "Chromium browser installed"
    else
        print_status 1 "Chromium browser not installed - run: npx playwright install chromium"
        OVERALL_STATUS=1
    fi
else
    print_status 1 "Playwright not found - run: npm install"
    OVERALL_STATUS=1
fi
echo ""

# Check test files
echo -e "${BLUE}Checking test files...${NC}"
TEST_FILES=(
    "test_file_tree.spec.js"
    "test_text_tab.spec.js"
    "test_bdd_tab.spec.js"
    "test_ibd_tab.spec.js"
    "test_3d_view.spec.js"
    "test_pair_authoring.spec.js"
    "test_e2e_workflow.spec.js"
    "helpers.js"
    "playwright.config.js"
)

ALL_FILES_EXIST=1
for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status 0 "$file exists"
    else
        print_status 1 "$file missing"
        ALL_FILES_EXIST=0
        OVERALL_STATUS=1
    fi
done
echo ""

# Check SPA server
echo -e "${BLUE}Checking SPA server...${NC}"
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8081 | grep -q "200"; then
    print_status 0 "SPA server running at http://127.0.0.1:8081"
else
    print_status 1 "SPA server not responding at http://127.0.0.1:8081"
    echo -e "${YELLOW}  → Start with: python spa/adapter_spa.py${NC}"
    OVERALL_STATUS=1
fi
echo ""

# Check architecture files
echo -e "${BLUE}Checking test data...${NC}"
ARCH_DIR="../../data/generated_architectures"
if [ -d "$ARCH_DIR" ]; then
    ARCH_COUNT=$(find "$ARCH_DIR" -name "*.sysml" 2>/dev/null | wc -l)
    if [ "$ARCH_COUNT" -gt 0 ]; then
        print_status 0 "Found $ARCH_COUNT architecture files"
    else
        print_status 1 "No .sysml files found in $ARCH_DIR"
        echo -e "${YELLOW}  → Generate with: ./ralph/run_mvp_checks.sh${NC}"
        OVERALL_STATUS=1
    fi
else
    print_status 1 "Architecture directory not found: $ARCH_DIR"
    OVERALL_STATUS=1
fi
echo ""

# Check output directories
echo -e "${BLUE}Checking output directories...${NC}"
mkdir -p test-results/screenshots
mkdir -p test-results/html-report
print_status 0 "Created test-results directories"
echo ""

# Summary
echo "=========================================="
if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e "${GREEN}✓ Setup verification passed!${NC}"
    echo ""
    echo "Ready to run tests:"
    echo "  ./run_tests.sh --headed"
else
    echo -e "${RED}✗ Setup verification failed${NC}"
    echo ""
    echo "Fix the issues above, then run this script again."
    echo ""
    echo "Quick fix commands:"
    echo "  npm install                              # Install dependencies"
    echo "  npx playwright install chromium          # Install browser"
    echo "  cd ../.. && python spa/adapter_spa.py &  # Start SPA"
fi
echo "=========================================="
echo ""

exit $OVERALL_STATUS
