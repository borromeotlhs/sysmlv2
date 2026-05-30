const { test, expect } = require('@playwright/test');

test.describe('Diagnostic Tests', () => {
  test('check if file tree loads and data-loaded is set', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');

    console.log('1. Page loaded');

    // Wait a bit for page to initialize
    await page.waitForTimeout(2000);

    // Check if file tree exists
    const fileTree = page.locator('#fileTree');
    await expect(fileTree).toBeVisible();
    console.log('2. File tree element exists');

    // Check current data-loaded attribute
    const dataLoadedBefore = await fileTree.getAttribute('data-loaded');
    console.log('3. data-loaded attribute:', dataLoadedBefore);

    // Wait for data-loaded="true" with a reasonable timeout
    console.log('4. Waiting for data-loaded="true"...');
    try {
      await page.waitForSelector('#fileTree[data-loaded="true"]', { timeout: 60000 });
      console.log('5. File tree loaded successfully!');
    } catch (e) {
      console.log('5. FAILED: File tree never set data-loaded="true"');
      const dataLoadedAfter = await fileTree.getAttribute('data-loaded');
      console.log('   Final data-loaded value:', dataLoadedAfter);

      // Take screenshot for debugging
      await page.screenshot({ path: 'test-results/diagnostic-tree-failed.png', fullPage: true });
      throw e;
    }

    // Check if any tree items exist
    const treeItems = page.locator('#fileTree .tree-item');
    const count = await treeItems.count();
    console.log('6. Number of tree items:', count);

    // List some filenames
    if (count > 0) {
      for (let i = 0; i < Math.min(5, count); i++) {
        const text = await treeItems.nth(i).textContent();
        console.log(`   Item ${i}: ${text}`);
      }
    }

    // Look specifically for arch_000001.sysml
    console.log('7. Looking for arch_000001.sysml...');
    const targetFile = page.locator('#fileTree .tree-item.file:has-text("arch_000001.sysml")');
    const isVisible = await targetFile.isVisible().catch(() => false);
    console.log('   arch_000001.sysml visible:', isVisible);

    if (!isVisible) {
      // Try to find any .sysml files
      const sysmlFiles = page.locator('#fileTree .tree-item.file:has-text(".sysml")');
      const sysmlCount = await sysmlFiles.count();
      console.log('   Total .sysml files found:', sysmlCount);

      if (sysmlCount > 0) {
        for (let i = 0; i < Math.min(3, sysmlCount); i++) {
          const text = await sysmlFiles.nth(i).textContent();
          console.log(`   .sysml file ${i}: ${text}`);
        }
      }
    }

    await page.screenshot({ path: 'test-results/diagnostic-tree-success.png', fullPage: true });
  });
});
