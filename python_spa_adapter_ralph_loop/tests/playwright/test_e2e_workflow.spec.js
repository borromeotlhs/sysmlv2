const { test, expect } = require('@playwright/test');
const {
  loadArchitecture,
  waitForDiagram,
  waitFor3DScene,
  screenshot,
  switchTab,
  waitForModal,
  waitForLoadingComplete,
  waitForPageLoad
} = require('./helpers');

test.describe('End-to-End Workflow', () => {
  test('complete workflow: load → text → BDD → IBD → 3D', async ({ page }) => {
    // Step 1: Load application
    // Step 1: Load application
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await screenshot(page, 'e2e-01-app-loaded');

    // Step 2: Load architecture
    await loadArchitecture(page, 'architecture_001.sysml');
    await screenshot(page, 'e2e-02-architecture-loaded');

    // Step 3: View in Text tab
    await switchTab(page, 'text');
    const textContent = page.locator('#architecturePreview');
    await expect(textContent).toBeVisible();

    const content = await textContent.textContent();
    expect(content).toContain('package');
    await screenshot(page, 'e2e-03-text-view');

    // Step 4: View BDD diagram
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');

    const bddDiagram = page.locator('#bddDiagram');
    await expect(bddDiagram).toBeVisible();
    await screenshot(page, 'e2e-04-bdd-view');

    // Step 5: View IBD diagram
    await switchTab(page, 'ibd');
    await waitForDiagram(page, 'ibd');

    const ibdDiagram = page.locator('#ibdDiagram');
    await expect(ibdDiagram).toBeVisible();
    await screenshot(page, 'e2e-05-ibd-view');

    // Step 6: Generate 3D model
    // 3D view is always visible - no need to switch tabs
    await page.waitForTimeout(500);

    const generateButton = page.locator('#generateSajaiBtn');
    await expect(generateButton).toBeVisible();
    await generateButton.click();

    // Handle modal if present
    const modal = page.locator('#sajaiGenerateModal');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);

    if (modalVisible) {
      await waitForModal(page, 'sajaiGenerateModal');
      const modalGenerateButton = page.locator('#confirmSajaiGenerate');
      await modalGenerateButton.click();
    }

    await screenshot(page, 'e2e-06-3d-generation-started');

    // Step 7: Wait for 3D scene to load
    await waitFor3DScene(page);

    const canvas = page.locator('#threejsContainer canvas');
    await expect(canvas).toBeVisible();
    await screenshot(page, 'e2e-07-3d-scene-loaded');

    // Step 8: Interact with 3D view (toggle visibility)
    const partsToggle = page.locator('#visibility-parts');
    if (await partsToggle.isVisible()) {
      await partsToggle.click();
      await page.waitForTimeout(300);
      await partsToggle.click();
      await page.waitForTimeout(300);
    }

    await screenshot(page, 'e2e-08-3d-interaction-complete');
  });

  test('multiple architecture comparison workflow', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');

    // Load first architecture
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');

    const bddDiagram = page.locator('#bddDiagram');
    const firstBddSrc = await bddDiagram.getAttribute('src');
    await screenshot(page, 'e2e-compare-arch1-bdd');

    // Load second architecture
    await loadArchitecture(page, 'architecture_002.sysml');
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');

    const secondBddSrc = await bddDiagram.getAttribute('src');
    await screenshot(page, 'e2e-compare-arch2-bdd');

    // Verify they're different
    expect(firstBddSrc).not.toBe(secondBddSrc);

    // Compare IBD
    await switchTab(page, 'ibd');
    await waitForDiagram(page, 'ibd');
    await screenshot(page, 'e2e-compare-arch2-ibd');
  });

  test('export workflow: text → diagrams → 3D', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await loadArchitecture(page, 'architecture_001.sysml');

    // Export text
    await switchTab(page, 'text');
    const copyButton = page.locator('button:has-text("Copy"), .copy-button').first();

    if (await copyButton.isVisible()) {
      await page.context().grantPermissions(['clipboard-read', 'clipboard-write']);
      await copyButton.click();
      await page.waitForTimeout(500);

      const clipboardContent = await page.evaluate(() => navigator.clipboard.readText());
      expect(clipboardContent.length).toBeGreaterThan(0);
      await screenshot(page, 'e2e-export-text');
    }

    // View and copy BDD source
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');
    await screenshot(page, 'e2e-export-bdd-diagram');

    // Generate and download 3D
    // 3D view is always visible - no need to switch tabs
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate")').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal');
    if (await modal.isVisible({ timeout: 2000 })) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);
    await screenshot(page, 'e2e-export-3d-complete');
  });

  test('error recovery workflow', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');

    // Try to switch tabs without loading architecture
    await switchTab(page, 'bdd');
    await page.waitForTimeout(1000);

    // Should handle gracefully (show message or empty state)
    const errorOrEmpty = page.locator('.error-message, .no-content, .empty-state');
    const diagram = page.locator('#bddDiagram');

    const hasError = await errorOrEmpty.isVisible().catch(() => false);
    const hasDiagram = await diagram.isVisible().catch(() => false);

    // Either shows error/empty state or requires architecture first
    await screenshot(page, 'e2e-error-no-architecture');

    // Now load architecture and try again
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');

    // Should work now
    await expect(diagram).toBeVisible();
    await screenshot(page, 'e2e-error-recovered');
  });

  test('tab navigation preserves state', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await loadArchitecture(page, 'architecture_001.sysml');

    // Load Text tab
    await switchTab(page, 'text');
    const textContent = page.locator('#architecturePreview');
    const originalText = await textContent.textContent();

    // Navigate through all tabs
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');
    await screenshot(page, 'e2e-nav-bdd');

    await switchTab(page, 'ibd');
    await waitForDiagram(page, 'ibd');
    await screenshot(page, 'e2e-nav-ibd');

    // 3D view is always visible - no need to switch tabs
    await page.waitForTimeout(500);
    await screenshot(page, 'e2e-nav-3d');

    // Return to Text tab
    await switchTab(page, 'text');
    const restoredText = await textContent.textContent();

    // Content should be preserved
    expect(restoredText).toBe(originalText);
    await screenshot(page, 'e2e-nav-state-preserved');
  });

  test('concurrent operations workflow', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await loadArchitecture(page, 'architecture_001.sysml');

    // Open BDD in popout
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');

    const bddPopoutButton = page.locator('button:has-text("Pop out"), .popout-button').first();

    if (await bddPopoutButton.isVisible()) {
      const popoutPromise = page.context().waitForEvent('page');
      await bddPopoutButton.click();
      const popoutPage = await popoutPromise;
      await popoutPage.waitForLoadState('domcontentloaded');

      // Main window: Generate 3D
      // 3D view is always visible - no need to switch tabs
      const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate")').first();
      await generateButton.click();

      const modal = page.locator('#generate-modal, .modal');
      if (await modal.isVisible({ timeout: 2000 })) {
        const modalGenerateButton = page.locator('#confirmSajaiGenerate');
        await modalGenerateButton.click();
      }

      // Wait for 3D in main window
      await waitFor3DScene(page);
      await screenshot(page, 'e2e-concurrent-main-3d');

      // Popout should still show BDD
      const popoutDiagram = popoutPage.locator('#bddDiagram, img');
      await expect(popoutDiagram).toBeVisible();
      await screenshot(popoutPage, 'e2e-concurrent-popout-bdd');

      await popoutPage.close();
    }
  });

  test('full feature tour workflow', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await page.waitForLoadState('domcontentloaded');

    // 1. Verify file tree
    const fileTree = page.locator('#fileTree');
    await expect(fileTree).toBeVisible();
    await screenshot(page, 'e2e-tour-01-file-tree');

    // 2. Load architecture
    await loadArchitecture(page, 'architecture_005.sysml');
    await screenshot(page, 'e2e-tour-02-loaded');

    // 3. View text
    await switchTab(page, 'text');
    const textContent = page.locator('#architecturePreview');
    await expect(textContent).toBeVisible();
    await screenshot(page, 'e2e-tour-03-text');

    // 4. Copy text
    const copyButton = page.locator('button:has-text("Copy")').first();
    if (await copyButton.isVisible()) {
      await page.context().grantPermissions(['clipboard-read', 'clipboard-write']);
      await copyButton.click();
      await page.waitForTimeout(500);
    }

    // 5. View BDD
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');
    await screenshot(page, 'e2e-tour-04-bdd');

    // 6. View IBD
    await switchTab(page, 'ibd');
    await waitForDiagram(page, 'ibd');
    await screenshot(page, 'e2e-tour-05-ibd');

    // 7. Generate 3D
    // 3D view is always visible - no need to switch tabs
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate")').first();

    if (await generateButton.isVisible()) {
      await generateButton.click();

      const modal = page.locator('#generate-modal, .modal');
      if (await modal.isVisible({ timeout: 2000 })) {
        const modalGenerateButton = page.locator('#confirmSajaiGenerate');
        await modalGenerateButton.click();
      }

      await waitFor3DScene(page);
      await screenshot(page, 'e2e-tour-06-3d-generated');

      // 8. Toggle visibility
      const partsToggle = page.locator('#visibility-parts');
      if (await partsToggle.isVisible()) {
        await partsToggle.click();
        await page.waitForTimeout(300);
        await screenshot(page, 'e2e-tour-07-3d-parts-hidden');

        await partsToggle.click();
        await page.waitForTimeout(300);
        await screenshot(page, 'e2e-tour-08-3d-parts-shown');
      }

      // 9. Interact with canvas
      const canvas = page.locator('#threejsContainer canvas');
      await canvas.hover({ position: { x: 300, y: 300 } });
      await page.mouse.down();
      await page.mouse.move(350, 320);
      await page.mouse.up();
      await page.waitForTimeout(300);
      await screenshot(page, 'e2e-tour-09-3d-rotated');
    }

    // 10. Load different architecture
    await loadArchitecture(page, 'architecture_010.sysml');
    await switchTab(page, 'text');
    await screenshot(page, 'e2e-tour-10-new-architecture');

    // Tour complete
    await screenshot(page, 'e2e-tour-complete');
  });

  test('performance: rapid tab switching', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await loadArchitecture(page, 'architecture_001.sysml');

    // Rapidly switch between tabs
    const startTime = Date.now();

    for (let i = 0; i < 3; i++) {
      await switchTab(page, 'text');
      await switchTab(page, 'bdd');
      await switchTab(page, 'ibd');
      // 3D view is always visible - no need to switch tabs
    }

    const endTime = Date.now();
    const totalTime = endTime - startTime;

    // Should complete in reasonable time (< 10 seconds)
    expect(totalTime).toBeLessThan(10000);

    await screenshot(page, 'e2e-performance-tab-switching');
  });

  test('page refresh preserves no state (clean slate)', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');

    // Refresh
    await page.reload();
    await page.waitForLoadState('domcontentloaded');

    // Should return to initial state
    const fileTree = page.locator('#fileTree');
    await expect(fileTree).toBeVisible();

    await screenshot(page, 'e2e-refresh-clean-slate');
  });
});
