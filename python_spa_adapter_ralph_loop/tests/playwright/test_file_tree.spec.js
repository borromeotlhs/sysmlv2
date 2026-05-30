const { test, expect } = require('@playwright/test');
const { waitForFileTree, screenshot, waitForPageLoad } = require('./helpers');

test.describe('File Tree Navigation', () => {
    test('file tree loads on startup', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    // Verify file tree container is visible
    const fileTree = page.locator('.file-tree');
    await expect(fileTree).toBeVisible();

    // Verify at least one file is present
    const files = page.locator('.file-tree a');
    const count = await files.count();
    expect(count).toBeGreaterThan(0);

    await screenshot(page, 'file-tree-loaded');
  });

  test('can expand and collapse directories', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    // Find a directory toggle (usually a folder icon or expand button)
    const directoryToggle = page.locator('.directory-toggle, .folder-icon').first();

    if (await directoryToggle.isVisible()) {
      // Get initial state
      const parentDir = directoryToggle.locator('..').first();

      // Click to expand/collapse
      await directoryToggle.click();
      await page.waitForTimeout(300);

      // Click again to toggle back
      await directoryToggle.click();
      await page.waitForTimeout(300);

      await screenshot(page, 'directory-toggled');
    } else {
      // If no directories, just verify files are visible
      const files = page.locator('.file-tree a');
      await expect(files.first()).toBeVisible();
    }
  });

  test('can click on .sysml files', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    // Find first .sysml file in tree
    const sysmlFile = page.locator('.file-tree a').filter({ hasText: '.sysml' }).first();

    await expect(sysmlFile).toBeVisible();

    // Click the file
    await sysmlFile.click();
    await page.waitForTimeout(500);

    // Verify something happened (active state, content loaded, etc.)
    const activeFile = page.locator('.file-tree a.active, .file-tree a.selected');
    await expect(activeFile).toBeVisible();

    await screenshot(page, 'sysml-file-clicked');
  });

  test('architecture loads in Text tab after file click', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    // Find and click first architecture file
    const archFile = page.locator('.file-tree a').filter({ hasText: 'architecture' }).first();

    if (await archFile.isVisible()) {
      await archFile.click();
      await page.waitForTimeout(500);

      // Verify Text tab content is visible and populated
      const textContent = page.locator('.text-content, #text-tab-content');
      await expect(textContent).toBeVisible();

      // Verify content is not empty
      const content = await textContent.textContent();
      expect(content.trim().length).toBeGreaterThan(0);

      // Verify it contains SysML keywords
      expect(content).toMatch(/package|part def|port def|connection def/i);

      await screenshot(page, 'architecture-loaded');
    }
  });

  test('multiple file selections work correctly', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    // Get list of architecture files
    const archFiles = page.locator('.file-tree a').filter({ hasText: 'architecture' });
    const count = await archFiles.count();

    if (count >= 2) {
      // Click first file
      await archFiles.nth(0).click();
      await page.waitForTimeout(500);

      const firstContent = await page.locator('.text-content, #text-tab-content').textContent();

      // Click second file
      await archFiles.nth(1).click();
      await page.waitForTimeout(500);

      const secondContent = await page.locator('.text-content, #text-tab-content').textContent();

      // Verify content changed
      expect(firstContent).not.toBe(secondContent);

      await screenshot(page, 'multiple-selections');
    }
  });

  test('file tree remains visible during navigation', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    const fileTree = page.locator('.file-tree');

    // Click a file
    const firstFile = page.locator('.file-tree a').first();
    await firstFile.click();
    await page.waitForTimeout(300);

    // Verify tree is still visible
    await expect(fileTree).toBeVisible();

    // Switch to BDD tab
    const bddTab = page.locator('button:has-text("BDD"), [data-tab="bdd"]');
    if (await bddTab.isVisible()) {
      await bddTab.click();
      await page.waitForTimeout(300);

      // Verify tree is still visible
      await expect(fileTree).toBeVisible();
    }

    await screenshot(page, 'file-tree-persistent');
  });

  test('file tree handles empty selection gracefully', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    // If there's a way to deselect or clear selection
    const clearButton = page.locator('button:has-text("Clear"), .clear-selection');

    if (await clearButton.isVisible()) {
      await clearButton.click();
      await page.waitForTimeout(300);

      // Verify no active file
      const activeFile = page.locator('.file-tree a.active, .file-tree a.selected');
      await expect(activeFile).toHaveCount(0);
    }

    // File tree should still be visible and functional
    const fileTree = page.locator('.file-tree');
    await expect(fileTree).toBeVisible();
  });
});
