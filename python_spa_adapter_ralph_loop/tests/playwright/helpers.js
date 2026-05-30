const { expect } = require('@playwright/test');

/**
 * Load an architecture file from the file tree
 * @param {import('@playwright/test').Page} page
 * @param {string} filename - The architecture filename (e.g., 'architecture_001.sysml')
 */
async function loadArchitecture(page, filename) {
  // Wait for file tree to load (increased timeout since /api/tree can be slow)
  await page.waitForSelector('.file-tree', { timeout: 60000 });

  // Find and click on the architecture file
  const fileLink = page.locator(`.file-tree a:has-text("${filename}")`);
  await expect(fileLink).toBeVisible({ timeout: 10000 });
  await fileLink.click();

  // Wait for the content to load in the Text tab
  await page.waitForSelector('.text-content', { timeout: 10000 });

  // Small delay to ensure everything is loaded
  await page.waitForTimeout(500);
}

/**
 * Wait for a diagram to render completely
 * @param {import('@playwright/test').Page} page
 * @param {string} type - Diagram type: 'bdd' or 'ibd'
 */
async function waitForDiagram(page, type) {
  const selector = type === 'bdd' ? '#bdd-diagram-image' : '#ibd-diagram-image';

  // Wait for the image element to be visible
  await page.waitForSelector(selector, { state: 'visible', timeout: 15000 });

  // Wait for the image to actually load
  await page.waitForFunction(
    (sel) => {
      const img = document.querySelector(sel);
      return img && img.complete && img.naturalHeight > 0;
    },
    selector,
    { timeout: 15000 }
  );

  // Additional small delay to ensure rendering is complete
  await page.waitForTimeout(500);
}

/**
 * Wait for 3D scene to render
 * @param {import('@playwright/test').Page} page
 */
async function waitFor3DScene(page) {
  // Wait for the 3D canvas
  await page.waitForSelector('#three-canvas', { state: 'visible', timeout: 10000 });

  // Wait for the scene to be initialized (check for objects in scene)
  await page.waitForFunction(
    () => {
      const canvas = document.querySelector('#three-canvas');
      return canvas && canvas.offsetHeight > 0;
    },
    { timeout: 10000 }
  );

  // Small delay for rendering
  await page.waitForTimeout(1000);
}

/**
 * Take a screenshot for debugging
 * @param {import('@playwright/test').Page} page
 * @param {string} name - Screenshot name
 */
async function screenshot(page, name) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  await page.screenshot({
    path: `test-results/screenshots/${name}-${timestamp}.png`,
    fullPage: true
  });
}

/**
 * Verify visibility toggle behavior
 * @param {import('@playwright/test').Page} page
 * @param {string} toggleName - Toggle name: 'parts', 'ports', or 'connectors'
 */
async function verifyVisibilityToggle(page, toggleName) {
  const checkbox = page.locator(`#toggle-${toggleName}`);

  // Verify toggle exists and is visible
  await expect(checkbox).toBeVisible();

  // Get initial state (should be checked)
  const initialState = await checkbox.isChecked();

  // Click to uncheck
  await checkbox.click();
  await page.waitForTimeout(300); // Wait for animation

  // Verify state changed
  const afterFirstClick = await checkbox.isChecked();
  expect(afterFirstClick).toBe(!initialState);

  // Click to check again
  await checkbox.click();
  await page.waitForTimeout(300); // Wait for animation

  // Verify state changed back
  const afterSecondClick = await checkbox.isChecked();
  expect(afterSecondClick).toBe(initialState);

  return true;
}

/**
 * Wait for modal to appear
 * @param {import('@playwright/test').Page} page
 * @param {string} modalId - Modal element ID
 */
async function waitForModal(page, modalId) {
  await page.waitForSelector(`#${modalId}`, { state: 'visible', timeout: 5000 });
  await page.waitForTimeout(300); // Wait for modal animation
}

/**
 * Wait for loading spinner to disappear
 * @param {import('@playwright/test').Page} page
 */
async function waitForLoadingComplete(page) {
  // Wait for any loading spinner to disappear
  const spinner = page.locator('.loading-spinner, .spinner, [data-loading="true"]');
  await spinner.waitFor({ state: 'hidden', timeout: 30000 }).catch(() => {
    // Spinner might not exist, that's ok
  });
}

/**
 * Switch to a specific tab
 * @param {import('@playwright/test').Page} page
 * @param {string} tabName - Tab name: 'text', 'bdd', 'ibd', or '3d-view'
 */
async function switchTab(page, tabName) {
  const tabButton = page.locator(`.tab-button[data-tab="${tabName}"], button:has-text("${tabName}")`);
  await expect(tabButton).toBeVisible();
  await tabButton.click();
  await page.waitForTimeout(500); // Wait for tab transition
}

/**
 * Verify download was triggered
 * @param {import('@playwright/test').Page} page
 * @param {Function} action - Function that triggers the download
 * @returns {Promise<string>} - Downloaded filename
 */
async function verifyDownload(page, action) {
  const downloadPromise = page.waitForEvent('download', { timeout: 10000 });
  await action();
  const download = await downloadPromise;
  return download.suggestedFilename();
}

/**
 * Wait for file tree to be fully loaded
 * @param {import('@playwright/test').Page} page
 */
async function waitForFileTree(page) {
  await page.waitForSelector('.file-tree', { state: 'visible', timeout: 60000 });

  // Wait for at least one file to be present
  await page.waitForSelector('.file-tree a', { timeout: 10000 });

  await page.waitForTimeout(300);
}

/**
 * Wait for page to load, optionally skipping the file tree load
 * @param {import('@playwright/test').Page} page
 * @param {Object} options
 * @param {boolean} options.skipTreeLoad - If true, don't wait for /api/tree endpoint to complete
 */
async function waitForPageLoad(page, options = {}) {
  const { skipTreeLoad = false } = options;

  if (skipTreeLoad) {
    // Wait for DOM content loaded, then wait for main app resources
    await page.waitForLoadState('domcontentloaded');
    // Give the app a moment to initialize and start tree fetch in background
    await page.waitForTimeout(1000);
  } else {
    // Wait for network idle (includes /api/tree)
    await page.waitForLoadState('networkidle', { timeout: 90000 });
    await waitForFileTree(page);
  }
}

/**
 * Load an architecture directly without using the file tree UI
 * Uses direct API call or URL navigation to load architecture
 * @param {import('@playwright/test').Page} page
 * @param {string} filename - The architecture filename (e.g., 'architecture_001.sysml')
 */
async function loadArchitectureDirectly(page, filename) {
  // Navigate directly to the architecture via query parameter or hash
  // This assumes the app supports direct loading via URL parameter
  const currentUrl = page.url();
  const url = new URL(currentUrl);
  url.searchParams.set('file', filename);

  await page.goto(url.toString());

  // Wait for the content to load in the Text tab
  await page.waitForSelector('.text-content', { timeout: 10000 });

  // Small delay to ensure everything is loaded
  await page.waitForTimeout(500);
}

/**
 * Open popout window and return new page
 * @param {import('@playwright/test').Page} page
 * @param {string} buttonSelector - Selector for popout button
 * @returns {Promise<import('@playwright/test').Page>} - New page context
 */
async function openPopout(page, buttonSelector) {
  const popoutPromise = page.context().waitForEvent('page');
  await page.click(buttonSelector);
  const popoutPage = await popoutPromise;
  await popoutPage.waitForLoadState('domcontentloaded');
  return popoutPage;
}

module.exports = {
  loadArchitecture,
  loadArchitectureDirectly,
  waitForDiagram,
  waitFor3DScene,
  screenshot,
  verifyVisibilityToggle,
  waitForModal,
  waitForLoadingComplete,
  switchTab,
  verifyDownload,
  waitForFileTree,
  waitForPageLoad,
  openPopout
};
