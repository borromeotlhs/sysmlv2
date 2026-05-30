const { test, expect } = require('@playwright/test');

test.describe('Expand and Load Test', () => {
  test('expand architectures directory and load file', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');

    // Wait for file tree to be fully loaded
    await page.waitForSelector('#fileTree[data-loaded="true"]', { timeout: 60000 });
    console.log('1. File tree loaded');

    // Find the ROOT "architectures" directory (the first one)
    const archDir = page.locator('#fileTree .tree-item.directory:has-text("architectures")').first();
    await expect(archDir).toBeVisible();
    console.log('2. Found architectures directory');

    // Click to expand it
    await archDir.click();
    await page.waitForTimeout(500);
    console.log('3. Clicked to expand architectures directory');

    // Now look for arch_000001.sysml
    const fileLink = page.locator('#fileTree .tree-item.file:has-text("arch_000001.sysml")');
    await expect(fileLink).toBeVisible({ timeout: 5000 });
    console.log('4. arch_000001.sysml is now visible');

    // Click the file
    await fileLink.click();
    console.log('5. Clicked on arch_000001.sysml');

    // Wait for content to load
    await page.waitForTimeout(1000);

    // Check if architecture preview has content
    const preview = page.locator('#architecturePreview');
    await expect(preview).toBeVisible();
    console.log('6. Architecture preview visible');

    // Get content
    const content = await preview.textContent();
    console.log('7. Content length:', content.length);

    // Take screenshot
    await page.screenshot({ path: 'test-results/expanded-and-loaded.png', fullPage: true });

    // Verify content loaded
    expect(content.length).toBeGreaterThan(50);
    expect(content).not.toContain('Click on an architecture file');

    console.log('✓ SUCCESS - This is the working pattern!');
  });
});
