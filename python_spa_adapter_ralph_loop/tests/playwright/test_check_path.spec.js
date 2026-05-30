const { test } = require('@playwright/test');

test('check what path is in tree items', async ({ page }) => {
  await page.goto('http://127.0.0.1:8081/');
  await page.waitForSelector('#fileTree[data-loaded="true"]', { timeout: 60000 });

  // Expand architectures directory
  const archDir = page.locator('#fileTree .tree-item.directory:has-text("architectures")').first();
  await archDir.click();
  await page.waitForTimeout(500);

  // Get the data-path attribute from arch_000001.sysml
  const fileLink = page.locator('#fileTree .tree-item.file:has-text("arch_000001.sysml")');
  const dataPath = await fileLink.getAttribute('data-path');
  console.log('data-path attribute:', dataPath);

  await page.screenshot({ path: 'test-results/path-check.png', fullPage: true });
});
