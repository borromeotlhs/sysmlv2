const { test, expect } = require('@playwright/test');
const { loadArchitecture, waitForPageLoad } = require('./helpers');

test.describe('Working Test Pattern', () => {
  test('load architecture file and verify it displays', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);

    console.log('1. Page loaded, waiting for file tree...');

    // Use loadArchitecture helper which properly handles directory expansion
    await loadArchitecture(page, 'arch_000001.sysml');
    console.log('2. Architecture loaded via helper');

    // Take screenshot to see what happened
    await page.screenshot({ path: 'test-results/after-click.png', fullPage: true });

    // Check if architecture preview has content
    const preview = page.locator('#architecturePreview');
    await expect(preview).toBeVisible({ timeout: 10000 });
    console.log('3. Architecture preview element is visible');

    // Get the content
    const content = await preview.textContent();
    console.log('4. Preview content length:', content.length);
    console.log('   Preview content preview:', content.substring(0, 200));

    // The preview should have some content (not empty and not the placeholder text)
    expect(content.length).toBeGreaterThan(50);
    expect(content).not.toContain('Click on an architecture file');

    console.log('✓ Test passed - file loads correctly!');
  });
});
