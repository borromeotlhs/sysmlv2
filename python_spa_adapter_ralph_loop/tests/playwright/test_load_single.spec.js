const { test, expect } = require('@playwright/test');
const { loadArchitecture, waitForPageLoad } = require('./helpers');

test.describe('Single Load Test', () => {
  test('can load arch_000001.sysml by expanding directories', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);

    console.log('1. Attempting to load arch_000001.sysml...');
    await loadArchitecture(page, 'arch_000001.sysml');
    console.log('2. File loaded successfully!');

    // Verify content loaded in text tab
    const preview = page.locator('#architecturePreview');
    await expect(preview).toBeVisible();
    console.log('3. Architecture preview visible');

    // Verify it contains SysML content
    const content = await preview.textContent();
    expect(content).toContain('package'); // SysML files typically have "package" keyword
    console.log('4. Content contains SysML package keyword');

    await page.screenshot({ path: 'test-results/single-load-success.png', fullPage: true });
  });
});
