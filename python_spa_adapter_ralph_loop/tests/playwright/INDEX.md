# Playwright Test Suite - Complete Index

## 📁 File Structure

```
tests/playwright/
├── README.md                      # Complete documentation
├── QUICKSTART.md                  # Quick start guide
├── TEST_SUMMARY.md                # Test coverage summary
├── INDEX.md                       # This file
│
├── playwright.config.js           # Playwright configuration
├── package.json                   # Dependencies
├── .gitignore                     # Git ignore rules
│
├── helpers.js                     # Shared helper functions
│
├── test_file_tree.spec.js         # File tree navigation (7 tests)
├── test_text_tab.spec.js          # Text tab functionality (9 tests)
├── test_bdd_tab.spec.js           # BDD diagram tests (10 tests)
├── test_ibd_tab.spec.js           # IBD diagram tests (10 tests)
├── test_3d_view.spec.js           # 3D view tests (18 tests) ⭐ CRITICAL
├── test_pair_authoring.spec.js    # Pair authoring (10 tests)
├── test_e2e_workflow.spec.js      # End-to-end workflows (9 tests)
│
├── run_tests.sh                   # Main test runner
├── verify_setup.sh                # Setup verification
│
└── test-results/                  # Generated during test runs
    ├── screenshots/               # Debug screenshots
    ├── html-report/               # HTML test report
    ├── videos/                    # Failure videos
    └── traces/                    # Debug traces
```

## 🚀 Getting Started

### 1. First Time Setup
```bash
cd tests/playwright
./verify_setup.sh              # Verify prerequisites
npm install                    # Install dependencies
npx playwright install chromium # Install browser
```

### 2. Start SPA (separate terminal)
```bash
cd python_spa_adapter_ralph_loop
python spa/adapter_spa.py
# Verify at http://127.0.0.1:8081
```

### 3. Run Tests
```bash
./run_tests.sh --headed        # Run with visible browser
```

## 📊 Test Files Overview

### Core Functionality Tests

#### `test_file_tree.spec.js` (7 tests, ~30s)
File tree navigation and architecture selection
- Loads on startup
- Expand/collapse directories
- Click .sysml files
- Load architectures
- Multiple selections
- Persistent visibility

#### `test_text_tab.spec.js` (9 tests, ~45s)
SysML text content display and export
- Display .sysml content
- Formatted code
- Copy button
- Download button
- Content updates
- Large file handling
- Tab preservation

#### `test_bdd_tab.spec.js` (10 tests, ~60s)
Block Definition Diagram rendering
- Diagram renders
- PlantUML content
- Show source code
- Copy source
- Pop-out window
- Full diagram in popout
- File switching
- Error handling
- Zoom/pan
- Tab preservation

#### `test_ibd_tab.spec.js` (10 tests, ~60s)
Internal Block Diagram rendering
- Diagram renders
- PlantUML content
- Show source code
- Copy source
- Pop-out window
- Full diagram in popout
- Internal structure
- File switching
- Different from BDD

### Critical Feature Tests

#### `test_3d_view.spec.js` (18 tests, ~2-3m) ⭐ **CRITICAL**
3D model generation and visualization
- **Generation:**
  - Tab visible and clickable
  - Generate button enabled
  - Modal opens
  - Filename input
  - Conversion triggers
  - Loading spinner
  - Success message
  - Auto-load scene

- **Visualization:**
  - Canvas renders objects
  - Property inspector

- **Visibility Toggles:**
  - Parts show/hide
  - Ports show/hide
  - Connectors show/hide

- **Popout Controls:**
  - Opens new window
  - Left-drag rotation
  - Right-drag panning
  - Scroll zoom

- **Export:**
  - Download SAJAI file
  - Complex architectures

### Integration Tests

#### `test_pair_authoring.spec.js` (10 tests, ~45s)
Pair creation and management
- Navigate to section
- Create pairs
- Save pairs
- List updates
- Edit pairs
- Delete pairs
- Form validation
- Display details
- Search/filter
- Persistence

#### `test_e2e_workflow.spec.js` (9 tests, ~3-4m)
Complete user workflows
- Full workflow (load → text → BDD → IBD → 3D → interact)
- Architecture comparison
- Export workflow
- Error recovery
- State preservation
- Concurrent operations
- Feature tour
- Performance (tab switching)
- Page refresh

## 🛠️ Helper Functions (`helpers.js`)

### Navigation
- `loadArchitecture(page, filename)` - Load architecture file
- `switchTab(page, tabName)` - Switch between tabs
- `waitForFileTree(page)` - Wait for file tree to load

### Diagrams
- `waitForDiagram(page, type)` - Wait for BDD/IBD render
- `waitFor3DScene(page)` - Wait for 3D canvas

### Interaction
- `verifyVisibilityToggle(page, toggleName)` - Test toggle behavior
- `openPopout(page, buttonSelector)` - Open popout window
- `verifyDownload(page, action)` - Verify file download

### Utilities
- `screenshot(page, name)` - Take debug screenshot
- `waitForModal(page, modalId)` - Wait for modal dialog
- `waitForLoadingComplete(page)` - Wait for spinners to disappear

## 🎯 Running Tests

### All Tests
```bash
./run_tests.sh                 # Headless
./run_tests.sh --headed        # With browser
./run_tests.sh --ui            # Interactive UI mode
./run_tests.sh --debug         # Debug mode
```

### Individual Suites
```bash
npm run test:file-tree         # File tree tests
npm run test:text              # Text tab tests
npm run test:bdd               # BDD diagram tests
npm run test:ibd               # IBD diagram tests
npm run test:3d                # 3D view tests (CRITICAL)
npm run test:pairs             # Pair authoring tests
npm run test:e2e               # End-to-end workflows
```

### Specific Files
```bash
./run_tests.sh test_3d_view.spec.js
./run_tests.sh test_e2e_workflow.spec.js --headed
```

### View Reports
```bash
npm run report                 # Open HTML report
```

## 📈 Test Statistics

| Metric | Value |
|--------|-------|
| Total Tests | 73 |
| Total Duration | 8-10 minutes |
| Test Files | 7 |
| Helper Functions | 13 |
| Coverage | All major features |

### Test Distribution
- File Tree: 7 tests (10%)
- Text Tab: 9 tests (12%)
- BDD Tab: 10 tests (14%)
- IBD Tab: 10 tests (14%)
- **3D View: 18 tests (25%)** ⭐
- Pair Authoring: 10 tests (14%)
- E2E Workflows: 9 tests (12%)

## 🔍 Test Priorities

### P0 - Critical (Must Pass)
- `test_3d_view.spec.js` - All 18 tests
- `test_e2e_workflow.spec.js` - "complete workflow" test
- `test_file_tree.spec.js` - "file tree loads" test

### P1 - High Priority
- All BDD/IBD rendering tests
- Text tab display and export
- E2E error recovery

### P2 - Important
- Pair authoring functionality
- Popout windows
- Performance tests

## 🐛 Debugging

### Failed Test
```bash
./run_tests.sh --debug test_name.spec.js
```

### View Trace
```bash
npx playwright show-trace test-results/traces/trace.zip
```

### Check Screenshots
```bash
ls -la test-results/screenshots/
```

### Watch Test Run
```bash
./run_tests.sh --headed --workers=1
```

## 📝 Configuration

### Timeouts
Edit `playwright.config.js`:
- Test timeout: 60s
- Action timeout: 10s
- Navigation timeout: 30s

### Base URL
Default: `http://127.0.0.1:8081`
Change in `playwright.config.js`

### Browsers
Default: Chromium
Add Firefox/WebKit in config

### Parallel Execution
Default: Sequential (1 worker)
Change `workers` in config

## ✅ Success Criteria

### All Tests Pass
- 73/73 tests passing
- No timeouts
- No errors
- Performance within limits

### Visual Verification
- Screenshots show correct UI
- Diagrams render properly
- 3D scenes load completely

### Reports Generated
- HTML report available
- Screenshots captured
- Videos on failures

## 🚨 Common Issues

### SPA Not Running
```bash
lsof -i :8081
python spa/adapter_spa.py
```

### No Architecture Files
```bash
./ralph/run_mvp_checks.sh
```

### Browser Not Installed
```bash
npx playwright install chromium --with-deps
```

### Tests Timing Out
- Increase timeout in config
- Check network connectivity
- Verify SPA is responsive

## 📚 Documentation

| File | Purpose |
|------|---------|
| `INDEX.md` | This file - complete index |
| `README.md` | Full documentation |
| `QUICKSTART.md` | Quick start guide |
| `TEST_SUMMARY.md` | Test coverage summary |

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
- run: npm install
- run: npx playwright install chromium --with-deps
- run: python spa/adapter_spa.py &
- run: npx playwright test
- uses: actions/upload-artifact@v3
  with:
    name: playwright-report
    path: test-results/
```

## 📞 Support

### Questions?
1. Read `QUICKSTART.md`
2. Check `README.md`
3. Review test file comments
4. Check helper function docs

### Issues?
1. Run `./verify_setup.sh`
2. Check console output
3. Review screenshots
4. Check trace files

---

**Version:** 1.0.0
**Created:** 2026-05-29
**Test Suite:** Comprehensive Playwright Regression Tests
**Target:** SysML v2 SPA at http://127.0.0.1:8081
