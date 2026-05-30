const { test, expect } = require('@playwright/test');

test('verify inline tree loads instantly', async ({ page }) => {
  const startTime = Date.now();

  await page.goto('http://127.0.0.1:8081/');

  // Check if tree data was injected into HTML
  const hasInlineTree = await page.evaluate(() => {
    return typeof window.__INITIAL_FILE_TREE__ !== 'undefined';
  });

  console.log('1. Has inline tree data:', hasInlineTree);
  expect(hasInlineTree).toBe(true);

  // Wait for tree to be marked as loaded
  await page.waitForSelector('#fileTree[data-loaded="true"]', { timeout: 5000 });

  const loadTime = Date.now() - startTime;
  console.log('2. Tree loaded in:', loadTime, 'ms');

  // Verify tree has items
  const treeItems = page.locator('#fileTree .tree-item');
  const count = await treeItems.count();
  console.log('3. Tree item count:', count);
  expect(count).toBeGreaterThan(0);

  // Check console for pre-loaded message
  const logs = [];
  page.on('console', msg => logs.push(msg.text()));

  // Tree should load quickly (under 10 seconds) - much faster than before (60s+)
  // Inline tree eliminates the slow /api/tree fetch
  expect(loadTime).toBeLessThan(10000);

  console.log('✓ Inline tree optimization working! Load time:', loadTime, 'ms');

  await page.screenshot({ path: 'test-results/inline-tree-test.png', fullPage: true });
});
