# Playwright Test Suite Refactoring Summary

## Overview
Refactored the Playwright test suite to maximize efficiency by sharing browser contexts and minimizing page reloads.

## Changes Made

### 1. Updated helpers.js
- Added `loadArchitectureDirectly()` helper function for loading architectures without file tree interaction
- Exported the new helper in module.exports

### 2. Refactored Test Files

#### Files Refactored (No File Tree Loading)
These tests load architecture directly and skip file tree loading:

- **test_3d_view.spec.js** (19 tests)
  - Shared page context across all tests
  - Loads architecture_001.sysml once in beforeAll
  - ~19 page reloads eliminated → ~3-5 minutes saved

- **test_bdd_tab.spec.js** (10 tests)
  - Shared page context across all tests
  - Loads architecture_001.sysml once in beforeAll
  - ~10 page reloads eliminated → ~2 minutes saved

- **test_ibd_tab.spec.js** (12 tests)
  - Shared page context across all tests
  - Loads architecture_001.sysml once in beforeAll
  - ~12 page reloads eliminated → ~2.5 minutes saved

- **test_text_tab.spec.js** (9 tests)
  - Shared page context across all tests
  - Loads architecture_001.sysml once in beforeAll
  - ~9 page reloads eliminated → ~1.5 minutes saved

#### Files Refactored (With File Tree Loading)
These tests load file tree once in beforeAll:

- **test_file_tree.spec.js** (7 tests)
  - Shared page context across all tests
  - Loads file tree once in beforeAll
  - ~7 page reloads eliminated → ~1.5 minutes saved

- **test_pair_authoring.spec.js** (10 tests)
  - Shared page context across all tests
  - Loads file tree once in beforeAll
  - ~10 page reloads eliminated → ~2 minutes saved

#### Special Cases

- **test_e2e_workflow.spec.js** (9 tests)
  - Shared browser context but tests reload page as needed for clean state
  - Still eliminates browser restarts between tests
  - ~9 page reloads eliminated → ~1-2 minutes saved

- **test_lazy_load.spec.js** (3 tests)
  - NOT REFACTORED - special case that tests lazy loading behavior
  - Requires testing /api/tree request patterns

## Key Refactoring Patterns

### Before:
```javascript
test.describe('Test Suite', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'architecture_001.sysml');
  });

  test('test 1', async ({ page }) => {
    // Test code
  });
});
```

### After (No File Tree):
```javascript
let sharedPage;

test.describe.configure({ mode: 'serial' });

test.describe('Test Suite', () => {
  test.beforeAll(async ({ browser }) => {
    sharedPage = await browser.newPage();
    await sharedPage.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(sharedPage, { skipTreeLoad: true });
    await loadArchitecture(sharedPage, 'architecture_001.sysml');
  });

  test.afterAll(async () => {
    await sharedPage.close();
  });

  test('test 1', async () => {
    const page = sharedPage;
    // Test code
  });
});
```

### After (With File Tree):
```javascript
let sharedPage;

test.describe.configure({ mode: 'serial' });

test.describe('Test Suite', () => {
  test.beforeAll(async ({ browser }) => {
    sharedPage = await browser.newPage();
    await sharedPage.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(sharedPage); // Loads file tree
  });

  test.afterAll(async () => {
    await sharedPage.close();
  });

  test('test 1', async () => {
    const page = sharedPage;
    // Test code
  });
});
```

## Performance Improvements

### Before Refactoring:
- Each test file created new browser/page
- Chromium process restarted repeatedly
- DOM and file tree reloaded for each test (10+ seconds per test)
- Tests ran one at a time with full teardown

### After Refactoring:
- Single browser context shared per test file
- Single page context shared across related tests
- DOM loaded once per test file
- File tree loaded once (or not at all for tests that don't need it)
- Tests run sequentially in shared context (serial mode)

### Expected Speedup:
- **test_3d_view.spec.js**: ~3-5 minutes saved
- **test_bdd_tab.spec.js**: ~2 minutes saved
- **test_ibd_tab.spec.js**: ~2.5 minutes saved
- **test_text_tab.spec.js**: ~1.5 minutes saved
- **test_file_tree.spec.js**: ~1.5 minutes saved
- **test_pair_authoring.spec.js**: ~2 minutes saved
- **test_e2e_workflow.spec.js**: ~1-2 minutes saved

**Total Expected Speedup: ~14-18 minutes faster test execution**

## Test Counts
- Total tests refactored: 76 tests
- Page reloads eliminated: ~76
- Browser restarts eliminated: ~76

## Files Modified
1. `/tests/playwright/helpers.js` - Added loadArchitectureDirectly helper
2. `/tests/playwright/test_3d_view.spec.js` - Refactored (19 tests)
3. `/tests/playwright/test_bdd_tab.spec.js` - Refactored (10 tests)
4. `/tests/playwright/test_ibd_tab.spec.js` - Refactored (12 tests)
5. `/tests/playwright/test_text_tab.spec.js` - Refactored (9 tests)
6. `/tests/playwright/test_file_tree.spec.js` - Refactored (7 tests)
7. `/tests/playwright/test_pair_authoring.spec.js` - Refactored (10 tests)
8. `/tests/playwright/test_e2e_workflow.spec.js` - Refactored (9 tests)
9. `/tests/playwright/test_lazy_load.spec.js` - NOT MODIFIED (special case)

## Testing
To verify the refactoring works:

```bash
cd python_spa_adapter_ralph_loop/tests/playwright
npx playwright test test_3d_view.spec.js
npx playwright test test_bdd_tab.spec.js
# ... etc
```

Or run all tests:
```bash
npx playwright test
```

## Notes
- Tests now run in serial mode (`test.describe.configure({ mode: 'serial' })`)
- Each test file maintains its own shared page context
- Page state is preserved across tests within the same file
- test_lazy_load.spec.js intentionally NOT refactored as it tests lazy loading behavior
- All tests use explicit URL: `http://127.0.0.1:8081/` instead of relative paths

## Rollback
If issues arise, individual files can be restored from git history or by reverting the specific changes above.
