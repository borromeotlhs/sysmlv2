# SysML v2 SPA Playwright Test Suite

Comprehensive regression tests for the SysML v2 Single Page Application.

## Test Coverage

### 1. File Tree Navigation (`test_file_tree.spec.js`)
- ✓ File tree loads on startup
- ✓ Can expand/collapse directories
- ✓ Can click on .sysml files
- ✓ Architecture loads in Text tab
- ✓ Multiple file selections
- ✓ File tree persists during navigation

### 2. Text Tab (`test_text_tab.spec.js`)
- ✓ Shows .sysml content
- ✓ Displays formatted SysML code
- ✓ Copy button works
- ✓ Download button works
- ✓ Content updates when switching files
- ✓ Handles large files without performance issues
- ✓ Preserves content when switching tabs

### 3. BDD Tab (`test_bdd_tab.spec.js`)
- ✓ BDD diagram renders
- ✓ Shows PlantUML source
- ✓ Pop-out button opens new window
- ✓ Copy source button works
- ✓ Popout shows full diagram without truncation
- ✓ Diagram updates when switching files
- ✓ Handles missing/invalid diagrams gracefully

### 4. IBD Tab (`test_ibd_tab.spec.js`)
- ✓ IBD diagram renders
- ✓ Shows PlantUML source
- ✓ Pop-out button opens new window
- ✓ Copy source button works
- ✓ Popout shows full diagram without truncation
- ✓ Diagram updates when switching files
- ✓ IBD different from BDD

### 5. 3D View Tab (`test_3d_view.spec.js`) - **CRITICAL**
- ✓ Tab is visible and clickable
- ✓ Generate 3D Model button enabled when architecture selected
- ✓ Clicking Generate opens modal
- ✓ Modal has filename input
- ✓ Generate button in modal triggers conversion
- ✓ Loading spinner shows during conversion
- ✓ Success message appears
- ✓ 3D scene auto-loads
- ✓ Can see 3D canvas with rendered objects
- ✓ **Visibility toggles work correctly:**
  - Parts toggle: starts checked → uncheck hides → check shows
  - Ports toggle: same behavior
  - Connectors toggle: same behavior
- ✓ Property inspector shows element details on click
- ✓ Pop-out button opens new window
- ✓ **Popout window controls work:**
  - Left-drag rotates view
  - Right-drag pans view
  - Scroll zooms in/out
- ✓ Download button exports SAJAI file

### 6. Pair Authoring (`test_pair_authoring.spec.js`)
- ✓ Can navigate to pair authoring section
- ✓ Can create pairs
- ✓ Can save pairs
- ✓ Pair list updates after creation
- ✓ Can edit existing pairs
- ✓ Can delete pairs
- ✓ Form validation works
- ✓ Pair authoring persists across refresh

### 7. End-to-End Workflow (`test_e2e_workflow.spec.js`)
- ✓ Complete workflow: Load → Text → BDD → IBD → Generate 3D → Interact
- ✓ Multiple architecture comparison
- ✓ Export workflow (text, diagrams, 3D)
- ✓ Error recovery
- ✓ Tab navigation preserves state
- ✓ Concurrent operations (popouts + main window)
- ✓ Full feature tour
- ✓ Performance: rapid tab switching
- ✓ Page refresh returns to clean slate

## Setup

### Prerequisites
- Node.js 16+ and npm
- SPA server running at `http://127.0.0.1:8081`

### Installation

```bash
cd tests/playwright
npm install
npm run install:browsers
```

## Running Tests

### Run all tests (headless)
```bash
./run_tests.sh
```

### Run all tests (headed - see browser)
```bash
./run_tests.sh --headed
```

### Run in UI mode (interactive)
```bash
./run_tests.sh --ui
```

### Run specific test file
```bash
./run_tests.sh test_3d_view.spec.js
# or
npm run test:3d
```

### Debug mode
```bash
./run_tests.sh --debug
```

### Run individual test suites
```bash
npm run test:file-tree   # File tree tests
npm run test:text        # Text tab tests
npm run test:bdd         # BDD diagram tests
npm run test:ibd         # IBD diagram tests
npm run test:3d          # 3D view tests (CRITICAL)
npm run test:pairs       # Pair authoring tests
npm run test:e2e         # End-to-end workflows
```

## Viewing Reports

```bash
npm run report
```

Opens an HTML report in your browser with:
- Test results
- Screenshots
- Videos of failures
- Trace files for debugging

## Test Results Location

- HTML Report: `test-results/html-report/`
- Screenshots: `test-results/screenshots/`
- Videos: `test-results/videos/` (on failure)
- Traces: `test-results/traces/` (on retry)

## Configuration

Edit `playwright.config.js` to customize:
- Base URL
- Timeouts
- Browsers
- Screenshot/video settings
- Parallel execution

## Helper Functions

Located in `helpers.js`:

- `loadArchitecture(page, filename)` - Load an architecture file
- `waitForDiagram(page, type)` - Wait for BDD/IBD diagram to render
- `waitFor3DScene(page)` - Wait for 3D canvas to load
- `screenshot(page, name)` - Take debug screenshot
- `verifyVisibilityToggle(page, toggleName)` - Test toggle behavior
- `switchTab(page, tabName)` - Switch between tabs
- `openPopout(page, buttonSelector)` - Open popout window
- `verifyDownload(page, action)` - Verify file download

## CI/CD Integration

The tests can run in CI with:
```bash
CI=true npx playwright test
```

This will:
- Retry failed tests automatically
- Run tests sequentially (not parallel)
- Generate JSON reports for processing

## Troubleshooting

### SPA not starting
```bash
# Check if port 8081 is available
lsof -i :8081

# Start SPA manually
cd ../../spa
python adapter_spa.py
```

### Browsers not installed
```bash
npx playwright install chromium --with-deps
```

### Tests timing out
- Increase timeouts in `playwright.config.js`
- Check network connectivity to PlantUML server
- Verify 3D conversion API is responding

### Screenshots not capturing
```bash
mkdir -p test-results/screenshots
```

## Best Practices

1. **Always use helpers** - Use helper functions for common operations
2. **Proper waits** - Use `waitForSelector`, `waitForLoadState`, not arbitrary timeouts
3. **Screenshots on key steps** - Take screenshots for debugging
4. **Descriptive test names** - Make failures easy to understand
5. **Independent tests** - Each test should work standalone
6. **Clean up** - Close popouts, reset state in `afterEach`

## Known Issues

None currently. Report issues with:
- Test name
- Screenshot from failure
- Console logs
- Expected vs actual behavior

## Contributing

When adding new tests:
1. Add test to appropriate spec file
2. Update this README with coverage
3. Add helper functions to `helpers.js` if reusable
4. Ensure test works in both headed and headless mode
5. Add screenshot at key verification points
