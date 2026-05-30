# Playwright Tests - Quick Start

## 1. Install Dependencies

```bash
cd tests/playwright
npm install
npx playwright install chromium
```

## 2. Start the SPA

In a separate terminal:
```bash
cd python_spa_adapter_ralph_loop
python spa/adapter_spa.py
```

Verify it's running at: http://127.0.0.1:8081

## 3. Run Tests

### All tests (headless)
```bash
./run_tests.sh
```

### All tests (headed - see browser)
```bash
./run_tests.sh --headed
```

### Interactive UI mode (recommended for development)
```bash
./run_tests.sh --ui
```

### Specific test suite
```bash
npm run test:3d        # 3D view tests
npm run test:bdd       # BDD diagram tests
npm run test:e2e       # End-to-end workflows
```

## 4. View Results

```bash
npm run report
```

## Common Commands

```bash
# Debug a failing test
./run_tests.sh --debug test_3d_view.spec.js

# Run specific test file
./run_tests.sh test_file_tree.spec.js

# Run with verbose output
npx playwright test --reporter=list

# Generate trace for debugging
npx playwright test --trace on
```

## Test Structure

```
test_file_tree.spec.js      # File navigation tests
test_text_tab.spec.js        # Text view tests
test_bdd_tab.spec.js         # BDD diagram tests
test_ibd_tab.spec.js         # IBD diagram tests
test_3d_view.spec.js         # 3D view tests (CRITICAL)
test_pair_authoring.spec.js  # Pair authoring tests
test_e2e_workflow.spec.js    # End-to-end workflows
helpers.js                   # Shared helper functions
```

## Expected Test Duration

- File Tree: ~30 seconds
- Text Tab: ~45 seconds
- BDD Tab: ~60 seconds
- IBD Tab: ~60 seconds
- 3D View: ~2-3 minutes (includes generation)
- Pair Authoring: ~45 seconds
- E2E Workflow: ~3-4 minutes

**Total: ~8-10 minutes for full suite**

## Troubleshooting

### Port 8081 already in use
```bash
lsof -i :8081
kill -9 <PID>
```

### Tests failing due to timeouts
- Increase timeout in `playwright.config.js`
- Check SPA is responding: `curl http://127.0.0.1:8081`

### Missing architecture files
- Ensure `data/generated_architectures/` has .sysml files
- Run generator if needed: `./ralph/run_mvp_checks.sh`

### Browser not found
```bash
npx playwright install chromium --with-deps
```

## Next Steps

1. Run all tests: `./run_tests.sh`
2. Review results: `npm run report`
3. Fix any failures
4. Add to CI/CD pipeline

See `README.md` for complete documentation.
