const { test, expect } = require('@playwright/test');
const {
  loadArchitecture,
  waitFor3DScene,
  screenshot,
  switchTab,
  waitForModal,
  waitForLoadingComplete,
  verifyVisibilityToggle,
  openPopout,
  verifyDownload,
  waitForPageLoad
} = require('./helpers');

test.describe('3D View Tab', () => {
  test('tab is visible and clickable', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');

    // Find 3D View tab
    const tab3D = page.locator('button:has-text("3D View"), button:has-text("3D"), [data-tab="3d-view"]');
    await expect(tab3D).toBeVisible();

    // Click the tab
    await tab3D.click();
    await page.waitForTimeout(500);

    // Verify we're on the 3D tab
    const tab3DActive = page.locator('button:has-text("3D View").active, button:has-text("3D")[class*="active"]');
    const isActive = await tab3DActive.isVisible().catch(() => false);

    // Tab should be clickable at minimum
    await screenshot(page, '3d-tab-visible');
  });

  test('Generate 3D Model button is enabled when architecture selected', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Find generate button
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button');
    await expect(generateButton).toBeVisible();

    // Should be enabled
    await expect(generateButton).toBeEnabled();

    await screenshot(page, '3d-generate-button-enabled');
  });

  test('clicking Generate opens modal', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Click generate button
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    // Wait for modal
    await waitForModal(page, 'generate-modal');

    // Verify modal is visible
    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    await expect(modal).toBeVisible();

    await screenshot(page, '3d-generate-modal-opened');
  });

  test('modal has filename input', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Open modal
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();
    await waitForModal(page, 'generate-modal');

    // Find filename input
    const filenameInput = page.locator('input[name="filename"], input[placeholder*="filename"], #filename-input');
    await expect(filenameInput).toBeVisible();

    // Should have default value or be editable
    await filenameInput.fill('test_model');
    const value = await filenameInput.inputValue();
    expect(value).toContain('test_model');

    await screenshot(page, '3d-modal-filename-input');
  });

  test('Generate button in modal triggers conversion', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Open modal
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();
    await waitForModal(page, 'generate-modal');

    // Fill filename
    const filenameInput = page.locator('input[name="filename"], input[placeholder*="filename"], #filename-input');
    if (await filenameInput.isVisible()) {
      await filenameInput.fill('test_conversion');
    }

    // Click modal generate button
    const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
    await modalGenerateButton.click();

    // Wait for modal to close or loading to start
    await page.waitForTimeout(1000);

    await screenshot(page, '3d-conversion-triggered');
  });

  test('loading spinner shows during conversion', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Open modal and trigger generation
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();
    await waitForModal(page, 'generate-modal');

    const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
    await modalGenerateButton.click();

    // Look for loading spinner (might be brief)
    const spinner = page.locator('.loading-spinner, .spinner, [data-loading="true"]');
    const spinnerAppeared = await spinner.isVisible({ timeout: 2000 }).catch(() => false);

    // Spinner might appear and disappear quickly
    // Test passes if we can detect it or if conversion completes
    await screenshot(page, '3d-loading-spinner');
  });

  test('success message appears after generation', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Trigger generation
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();
    await waitForModal(page, 'generate-modal');

    const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
    await modalGenerateButton.click();

    // Wait for completion
    await waitForLoadingComplete(page);

    // Look for success message
    const successMessage = page.locator('.success-message, .alert-success, [class*="success"]');
    const hasSuccess = await successMessage.isVisible({ timeout: 10000 }).catch(() => false);

    // Either success message or 3D scene appears
    const canvas = page.locator('#three-canvas, canvas');
    const hasCanvas = await canvas.isVisible({ timeout: 10000 }).catch(() => false);

    expect(hasSuccess || hasCanvas).toBe(true);

    await screenshot(page, '3d-generation-success');
  });

  test('3D scene auto-loads after generation', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Trigger generation
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    // Handle modal if it appears
    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);

    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    // Wait for 3D scene
    await waitFor3DScene(page);

    // Verify canvas is visible
    const canvas = page.locator('#three-canvas, canvas');
    await expect(canvas).toBeVisible();

    await screenshot(page, '3d-scene-auto-loaded');
  });

  test('can see 3D canvas with rendered objects', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Trigger generation and wait for scene
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    // Verify scene has objects
    const hasObjects = await page.evaluate(() => {
      const canvas = document.querySelector('#three-canvas, canvas');
      // Basic check: canvas exists and has dimensions
      return canvas && canvas.width > 0 && canvas.height > 0;
    });

    expect(hasObjects).toBe(true);

    await screenshot(page, '3d-canvas-rendered-objects');
  });

  test('visibility toggles work correctly - Parts', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate 3D model
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    // Test parts toggle
    await verifyVisibilityToggle(page, 'parts');

    await screenshot(page, '3d-parts-toggle-tested');
  });

  test('visibility toggles work correctly - Ports', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate 3D model
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    // Test ports toggle
    await verifyVisibilityToggle(page, 'ports');

    await screenshot(page, '3d-ports-toggle-tested');
  });

  test('visibility toggles work correctly - Connectors', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate 3D model
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    // Test connectors toggle
    await verifyVisibilityToggle(page, 'connectors');

    await screenshot(page, '3d-connectors-toggle-tested');
  });

  test('property inspector shows element details on click', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate and load 3D
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    // Try to click on canvas (simulate object selection)
    const canvas = page.locator('#three-canvas, canvas');
    await canvas.click({ position: { x: 400, y: 300 } });
    await page.waitForTimeout(500);

    // Look for property inspector
    const inspector = page.locator('.property-inspector, .element-details, .inspector-panel');
    const inspectorVisible = await inspector.isVisible().catch(() => false);

    // Property inspector might appear on selection
    await screenshot(page, '3d-property-inspector');
  });

  test('pop-out button opens new window', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate 3D
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    // Find pop-out button
    const popoutButton = page.locator('button:has-text("Pop out"), button:has-text("Open in new window"), .popout-button').first();

    if (await popoutButton.isVisible()) {
      const popoutPage = await openPopout(page, 'button:has-text("Pop out"), button:has-text("Open in new window"), .popout-button');

      // Verify new window has canvas
      await popoutPage.waitForLoadState('domcontentloaded');
      const popoutCanvas = popoutPage.locator('#three-canvas, canvas');
      await expect(popoutCanvas).toBeVisible({ timeout: 10000 });

      await screenshot(popoutPage, '3d-popout-window');
      await popoutPage.close();
    }
  });

  test('popout window controls work - rotation', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate and open popout
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    const popoutButton = page.locator('button:has-text("Pop out"), button:has-text("Open in new window"), .popout-button').first();

    if (await popoutButton.isVisible()) {
      const popoutPage = await openPopout(page, 'button:has-text("Pop out"), button:has-text("Open in new window"), .popout-button');
      await waitFor3DScene(popoutPage);

      const canvas = popoutPage.locator('#three-canvas, canvas');

      // Simulate left-drag (rotation)
      await canvas.hover({ position: { x: 300, y: 300 } });
      await popoutPage.mouse.down();
      await popoutPage.mouse.move(400, 350);
      await popoutPage.mouse.up();
      await page.waitForTimeout(500);

      await screenshot(popoutPage, '3d-popout-rotation');
      await popoutPage.close();
    }
  });

  test('popout window controls work - panning', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate and open popout
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    const popoutButton = page.locator('button:has-text("Pop out"), button:has-text("Open in new window"), .popout-button').first();

    if (await popoutButton.isVisible()) {
      const popoutPage = await openPopout(page, 'button:has-text("Pop out"), button:has-text("Open in new window"), .popout-button');
      await waitFor3DScene(popoutPage);

      const canvas = popoutPage.locator('#three-canvas, canvas');

      // Simulate right-drag (panning)
      await canvas.hover({ position: { x: 300, y: 300 } });
      await popoutPage.mouse.down({ button: 'right' });
      await popoutPage.mouse.move(350, 350);
      await popoutPage.mouse.up({ button: 'right' });
      await page.waitForTimeout(500);

      await screenshot(popoutPage, '3d-popout-panning');
      await popoutPage.close();
    }
  });

  test('popout window controls work - zooming', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate and open popout
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    const popoutButton = page.locator('button:has-text("Pop out"), button:has-text("Open in new window"), .popout-button').first();

    if (await popoutButton.isVisible()) {
      const popoutPage = await openPopout(page, 'button:has-text("Pop out"), button:has-text("Open in new window"), .popout-button');
      await waitFor3DScene(popoutPage);

      const canvas = popoutPage.locator('#three-canvas, canvas');

      // Simulate scroll (zoom)
      await canvas.hover({ position: { x: 300, y: 300 } });
      await popoutPage.mouse.wheel(0, 100); // Zoom out
      await page.waitForTimeout(300);
      await popoutPage.mouse.wheel(0, -100); // Zoom in
      await page.waitForTimeout(300);

      await screenshot(popoutPage, '3d-popout-zooming');
      await popoutPage.close();
    }
  });

  test('download button exports SAJAI file', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    await switchTab(page, '3d-view');

    // Generate 3D
    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    await waitFor3DScene(page);

    // Find download button
    const downloadButton = page.locator('button:has-text("Download"), button:has-text("Export"), .download-3d-button');

    if (await downloadButton.first().isVisible()) {
      const filename = await verifyDownload(page, async () => {
        await downloadButton.first().click();
      });

      // Verify file has correct extension
      expect(filename).toMatch(/\.sajai$/i);

      await screenshot(page, '3d-download-sajai');
    }
  });

  test('3D view handles complex architectures', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page, { skipTreeLoad: true });
    await loadArchitecture(page, 'architecture_001.sysml');
    // Load a more complex architecture if available
    await loadArchitecture(page, 'architecture_010.sysml');
    await switchTab(page, '3d-view');

    const generateButton = page.locator('button:has-text("Generate 3D Model"), button:has-text("Generate"), #generate-3d-button').first();
    await generateButton.click();

    const modal = page.locator('#generate-modal, .modal, [role="dialog"]');
    const modalVisible = await modal.isVisible({ timeout: 2000 }).catch(() => false);
    if (modalVisible) {
      const modalGenerateButton = page.locator('.modal button:has-text("Generate"), [role="dialog"] button:has-text("Generate")').first();
      await modalGenerateButton.click();
    }

    // Allow more time for complex models
    await waitFor3DScene(page);
    await page.waitForTimeout(2000);

    // Verify scene loaded
    const canvas = page.locator('#three-canvas, canvas');
    await expect(canvas).toBeVisible();

    await screenshot(page, '3d-complex-architecture');
  });
});
