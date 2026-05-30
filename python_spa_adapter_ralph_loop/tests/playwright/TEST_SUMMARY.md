# Playwright Test Suite - Summary

## Overview

Comprehensive regression test suite for the SysML v2 Single Page Application (SPA), covering all major features and workflows.

**Location:** `python_spa_adapter_ralph_loop/tests/playwright/`

## Test Files

| File | Tests | Focus | Duration |
|------|-------|-------|----------|
| `test_file_tree.spec.js` | 7 | File tree navigation and selection | ~30s |
| `test_text_tab.spec.js` | 9 | SysML text display and export | ~45s |
| `test_bdd_tab.spec.js` | 10 | BDD diagram rendering and interaction | ~60s |
| `test_ibd_tab.spec.js` | 10 | IBD diagram rendering and interaction | ~60s |
| `test_3d_view.spec.js` | 18 | 3D model generation and visualization | ~2-3m |
| `test_pair_authoring.spec.js` | 10 | Pair creation and management | ~45s |
| `test_e2e_workflow.spec.js` | 9 | Complete user workflows | ~3-4m |

**Total Tests:** 73 tests
**Total Duration:** ~8-10 minutes (full suite)

## Critical Test Coverage

### 3D View (CRITICAL)

The 3D view tests are the most comprehensive and critical, covering:

1. **Generation Flow**
   - Button states and modal interaction
   - Conversion process and loading states
   - Success indicators and auto-loading

2. **Visibility Controls**
   - Parts toggle: Show/hide functionality
   - Ports toggle: Show/hide functionality
   - Connectors toggle: Show/hide functionality
   - Each toggle verified with click and state checks

3. **3D Interaction**
   - Canvas rendering verification
   - Mouse controls (rotate, pan, zoom)
   - Property inspector on element selection

4. **Popout Window**
   - Opens correctly with full 3D scene
   - All controls work (rotate, pan, zoom)
   - Independent from main window

5. **Export**
   - SAJAI file download
   - Correct file format verification

### Diagram Tests (BDD/IBD)

Both diagram types tested for:
- Rendering from PlantUML source
- Source code display and copying
- Popout windows with full diagrams (no truncation)
- Updates when switching architectures
- Error handling for invalid/missing diagrams

### File Tree Navigation

Core application flow:
- Initial load and visibility
- File selection and architecture loading
- Directory expansion/collapse
- Multiple file switching
- Persistence across tab changes

### Text Tab

SysML content display:
- Formatted code display
- Copy to clipboard functionality
- Download as .sysml file
- Content preservation across tab switches
- Performance with large files

### End-to-End Workflows

Real-world user scenarios:
- Complete feature tour (load → view → diagram → 3D)
- Architecture comparison workflow
- Export workflow (all formats)
- Error recovery scenarios
- Concurrent operations (popouts + main window)
- Performance testing (rapid tab switching)

## Test Quality Features

### Robust Selectors
- Multiple fallback selectors for each element
- Text-based selectors for stability
- ID and class-based selectors for precision

### Proper Waiting
- `waitForSelector` for DOM elements
- `waitForLoadState` for page loads
- `waitForDiagram` helper for PlantUML rendering
- `waitFor3DScene` helper for canvas initialization
- `waitForLoadingComplete` for async operations

### Debug Support
- Screenshots at key verification points
- Named screenshots for easy identification
- Video recording on failures
- Trace files for detailed debugging

### Modular Helpers
- `helpers.js` with reusable functions
- Consistent patterns across all tests
- Easy to extend and maintain

## Running the Tests

### Quick Run
```bash
cd tests/playwright
./run_tests.sh --headed
```

### Individual Suites
```bash
npm run test:3d        # Most critical
npm run test:e2e       # Full workflows
npm run test:bdd       # BDD diagrams
npm run test:ibd       # IBD diagrams
npm run test:text      # Text view
npm run test:file-tree # Navigation
npm run test:pairs     # Pair authoring
```

### Debug Mode
```bash
./run_tests.sh --debug test_3d_view.spec.js
```

### UI Mode (Recommended)
```bash
./run_tests.sh --ui
```

## Expected Results

### Success Criteria
- All 73 tests pass
- No timeouts or errors
- Screenshots show correct UI state
- Performance metrics within acceptable range

### Common Failure Points
1. **3D Generation Timeout**
   - Increase timeout in config if needed
   - Verify conversion API is responding

2. **PlantUML Diagrams Not Loading**
   - Check network connectivity
   - Verify PlantUML server is accessible

3. **File Tree Empty**
   - Ensure architecture files exist in `data/generated_architectures/`
   - Run generator: `./ralph/run_mvp_checks.sh`

4. **SPA Not Starting**
   - Check port 8081 availability
   - Start manually: `python spa/adapter_spa.py`

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Install Playwright
  run: |
    cd tests/playwright
    npm install
    npx playwright install --with-deps chromium

- name: Start SPA
  run: |
    python spa/adapter_spa.py &
    sleep 5

- name: Run Tests
  run: |
    cd tests/playwright
    npx playwright test

- name: Upload Results
  uses: actions/upload-artifact@v3
  with:
    name: playwright-report
    path: tests/playwright/test-results/
```

## Maintenance

### Adding New Tests
1. Choose appropriate spec file or create new one
2. Use existing helpers when possible
3. Add new helpers to `helpers.js` if reusable
4. Follow existing patterns for consistency
5. Update README and this summary

### Updating Selectors
- Check all tests when UI changes
- Update helpers if selectors need to change globally
- Test in both headed and headless mode

### Performance Optimization
- Keep tests independent (no shared state)
- Use parallel execution where safe
- Minimize arbitrary timeouts
- Use proper wait conditions

## Reports and Artifacts

### HTML Report
- Detailed test results
- Screenshots and videos
- Execution timeline
- View: `npm run report`

### Screenshots
- Saved in `test-results/screenshots/`
- Named with test context and timestamp
- Useful for visual regression

### Videos
- Recorded on test failure
- Saved in `test-results/videos/`
- Full test execution playback

### Traces
- Detailed execution traces on retry
- Saved in `test-results/traces/`
- Debug with: `npx playwright show-trace trace.zip`

## Test Pyramid

```
    E2E Workflows (9 tests)
         /\
        /  \
       /    \
      / Feature Tests (55 tests)
     /  - 3D View (18)
    /   - Diagrams (20)
   /    - Text/Tree (17)
  /      
 / Integration Tests (9 pairs)
/_____________________________
```

**Bottom:** Unit tests (not in this suite - see pytest tests)
**Middle:** Feature tests (this Playwright suite)
**Top:** End-to-end workflow tests

## Success Metrics

- **Coverage:** All major features tested
- **Reliability:** Tests pass consistently
- **Speed:** Complete suite runs in <10 minutes
- **Maintainability:** Clear structure and helpers
- **Debuggability:** Screenshots, videos, traces
- **Documentation:** README, QUICKSTART, this summary

## Next Steps

1. ✓ Test suite created
2. ⏳ Run initial test suite
3. ⏳ Fix any failures
4. ⏳ Integrate into CI/CD
5. ⏳ Set up automated daily runs
6. ⏳ Add visual regression testing
7. ⏳ Add performance benchmarks
8. ⏳ Add accessibility tests

---

**Created:** 2026-05-29
**Version:** 1.0.0
**Maintainer:** Development Team
