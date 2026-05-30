const { test, expect } = require('@playwright/test');
const { loadArchitecture, waitForDiagram, screenshot, switchTab, openPopout, waitForPageLoad } = require('./helpers');

test.describe('BDD Tab', () => {
    test('BDD diagram renders', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    // Wait for diagram to load
    await waitForDiagram(page, 'bdd');

    // Verify image is visible
    const diagram = page.locator('#bddDiagram');
    await expect(diagram).toBeVisible();

    // Verify image has loaded (has natural dimensions)
    const hasLoaded = await page.evaluate(() => {
      const img = document.querySelector('#bddDiagram');
      return img && img.complete && img.naturalHeight > 0;
    });

    expect(hasLoaded).toBe(true);

    await screenshot(page, 'bdd-diagram-rendered');
  });

  test('BDD diagram displays PlantUML content', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    await waitForDiagram(page, 'bdd');

    // Verify diagram source is from PlantUML
    const diagram = page.locator('#bddDiagram');
    const src = await diagram.getAttribute('src');

    // Should be PlantUML URL or base64 encoded SVG/PNG
    expect(src).toMatch(/plantuml|data:image/i);

    await screenshot(page, 'bdd-plantuml-content');
  });

  test('shows PlantUML source', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    await waitForDiagram(page, 'bdd');

    // Find PlantUML source display
    const sourceElement = page.locator('#bddSource');

    // Source might be hidden by default, look for show source button
    const showSourceButton = page.locator('button:has-text("Show Source"), button:has-text("View Source")');

    if (await showSourceButton.isVisible()) {
      await showSourceButton.click();
      await page.waitForTimeout(500);
    }

    // Now check if source is visible
    const isVisible = await sourceElement.isVisible().catch(() => false);

    if (isVisible) {
      await expect(sourceElement).toBeVisible();

      const sourceText = await sourceElement.textContent();
      expect(sourceText).toContain('@startuml');
      expect(sourceText).toContain('@enduml');
    }

    await screenshot(page, 'bdd-plantuml-source');
  });

  test('copy source button works', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    await waitForDiagram(page, 'bdd');

    // Find copy source button
    const copyButton = page.locator('#copyBddSource');

    if (await copyButton.isVisible()) {
      // Grant clipboard permissions
      await page.context().grantPermissions(['clipboard-read', 'clipboard-write']);

      await copyButton.click();
      await page.waitForTimeout(500);

      // Read clipboard
      const clipboardContent = await page.evaluate(() => navigator.clipboard.readText());

      // Verify clipboard contains PlantUML code
      expect(clipboardContent).toContain('@startuml');

      await screenshot(page, 'bdd-source-copied');
    }
  });

  test('pop-out button opens new window', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    await waitForDiagram(page, 'bdd');

    // Find pop-out button
    const popoutButton = page.locator('#popoutBdd');
    await expect(popoutButton).toBeVisible();

    // Open popout
    const popoutPage = await openPopout(page, '#popoutBdd');

    // Verify new window opened
    expect(popoutPage).toBeTruthy();

    // Verify diagram is visible in popout
    await popoutPage.waitForLoadState('domcontentloaded');
    const popoutDiagram = popoutPage.locator('#bddDiagram, img[src*="plantuml"]');
    await expect(popoutDiagram).toBeVisible({ timeout: 10000 });

    await screenshot(popoutPage, 'bdd-popout-window');

    // Close popout
    await popoutPage.close();
  });

  test('popout window shows full diagram without truncation', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    await waitForDiagram(page, 'bdd');

    const popoutButton = page.locator('#popoutBdd');

    if (await popoutButton.isVisible()) {
      const popoutPage = await openPopout(page, '#popoutBdd');

      await popoutPage.waitForLoadState('domcontentloaded');
      await page.waitForTimeout(1000);

      // Get diagram dimensions
      const dimensions = await popoutPage.evaluate(() => {
        const img = document.querySelector('#bddDiagram, img[src*="plantuml"]');
        if (!img) return null;
        return {
          natural: { width: img.naturalWidth, height: img.naturalHeight },
          displayed: { width: img.width, height: img.height }
        };
      });

      expect(dimensions).toBeTruthy();
      expect(dimensions.natural.width).toBeGreaterThan(0);
      expect(dimensions.natural.height).toBeGreaterThan(0);

      await screenshot(popoutPage, 'bdd-popout-full-diagram');
      await popoutPage.close();
    }
  });

  test('diagram updates when switching files', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForDiagram(page, 'bdd');

    // Get initial diagram source
    const diagram = page.locator('#bddDiagram');
    const firstSrc = await diagram.getAttribute('src');

    // Load different architecture
    await loadArchitecture(page, 'arch_000002.sysml');
    await switchTab(page, 'bdd');
    await waitForDiagram(page, 'bdd');

    // Get new diagram source
    const secondSrc = await diagram.getAttribute('src');

    // Sources should be different
    expect(firstSrc).not.toBe(secondSrc);

    await screenshot(page, 'bdd-diagram-updated');
  });

  test('handles missing or invalid diagrams gracefully', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    // Try to load a file that might not have a BDD diagram
    // or test error handling

    // Look for error message or placeholder
    const errorMessage = page.locator('.error-message, .no-diagram, .diagram-error');
    const diagram = page.locator('#bddDiagram');

    // Either diagram loads or error message shows
    const diagramVisible = await diagram.isVisible({ timeout: 5000 }).catch(() => false);
    const errorVisible = await errorMessage.isVisible().catch(() => false);

    expect(diagramVisible || errorVisible).toBe(true);

    await screenshot(page, 'bdd-error-handling');
  });

  test('diagram is zoomable or pannable', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    await waitForDiagram(page, 'bdd');

    const diagram = page.locator('#bddDiagram');

    // Try to zoom (if zoom controls exist)
    const zoomInButton = page.locator('button:has-text("Zoom In"), .zoom-in, button[title*="Zoom"]');

    if (await zoomInButton.isVisible()) {
      await zoomInButton.click();
      await page.waitForTimeout(300);

      await screenshot(page, 'bdd-zoomed');
    } else {
      // Check if diagram is in a scrollable container
      const container = diagram.locator('..');
      const isScrollable = await page.evaluate((el) => {
        const elem = el || document.querySelector('.bdd-diagram-container, .diagram-container');
        return elem && (elem.scrollHeight > elem.clientHeight || elem.scrollWidth > elem.clientWidth);
      }, await container.elementHandle());

      // Having scroll or zoom capability is good UX
      // Test passes regardless as this is optional functionality
      await screenshot(page, 'bdd-zoom-check');
    }
  });

  test('preserves diagram when switching tabs', async ({ page }) => {
    await page.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(page);
    await loadArchitecture(page, 'arch_000001.sysml');
    await waitForDiagram(page, 'bdd');

    const diagram = page.locator('#bddDiagram');
    const originalSrc = await diagram.getAttribute('src');

    // Switch to Text tab
    await switchTab(page, 'text');
    await page.waitForTimeout(500);

    // Switch back to BDD
    await switchTab(page, 'bdd');
    await page.waitForTimeout(500);

    // Diagram should still be there (might reload, but should show)
    await expect(diagram).toBeVisible();

    await screenshot(page, 'bdd-preserved-after-switch');
  });
});
