const { test, expect } = require('@playwright/test');
const { loadArchitecture, waitForPageLoad } = require('./helpers');

test.describe('Working Test Pattern', () => {
  test('load architecture file and verify it displays', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);

    console.log('1. Page loaded, waiting for file tree...');

    // Wait for file tree to be fully loaded
    await page.waitForSelector('#fileTree[data-loaded="true"]', { timeout: 60000 });
    console.log('2. File tree loaded');

    // Find arch_000001.sysml in the tree
    const fileLink = page.locator('#fileTree .tree-item.file:has-text("arch_000001.sysml")');

    // Check if visible (should be since it's in root of ARCH_DIR)
    const isVisible = await fileLink.isVisible({ timeout: 5000 }).catch(() => false);
    console.log('3. arch_000001.sysml visible:', isVisible);

    if (!isVisible) {
      console.log('   File not immediately visible, taking screenshot...');
      await page.screenshot({ path: 'test-results/file-not-visible.png', fullPage: true });
      throw new Error('arch_000001.sysml not visible in file tree');
    }

    // Click the file
    await fileLink.click();
    console.log('4. Clicked on arch_000001.sysml');

    // Wait a moment for content to load
    await page.waitForTimeout(1000);

    // Take screenshot to see what happened
    await page.screenshot({ path: 'test-results/after-click.png', fullPage: true });

    // Check if architecture preview has content
    const preview = page.locator('#architecturePreview');
    await expect(preview).toBeVisible({ timeout: 10000 });
    console.log('5. Architecture preview element is visible');

    // Get the content
    const content = await preview.textContent();
    console.log('6. Preview content length:', content.length);
    console.log('   Preview content preview:', content.substring(0, 200));

    // The preview should have some content (not empty and not the placeholder text)
    expect(content.length).toBeGreaterThan(50);
    expect(content).not.toContain('Click on an architecture file');

    console.log('✓ Test passed - file loads correctly!');
  });
});
