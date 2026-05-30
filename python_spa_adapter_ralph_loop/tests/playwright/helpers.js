const { expect } = require('@playwright/test');

/**
 * Load an architecture file from the file tree (left sidebar)
 * @param {import('@playwright/test').Page} page
 * @param {string} filename - The architecture filename (e.g., 'architecture_001.sysml')
 */
async function loadArchitecture(page, filename) {
  // Wait for file tree to load (increased timeout since /api/tree can be slow)
  await page.waitForSelector('#fileTree', { timeout: 60000 });

  // Find and click on the architecture file
  const fileLink = page.locator(`#fileTree a:has-text("${filename}")`);
  await expect(fileLink).toBeVisible({ timeout: 10000 });
  await fileLink.click();

  // Wait for the content to load in the Text tab (default active tab)
  await page.waitForSelector('#architecturePreview', { timeout: 10000 });

  // Small delay to ensure everything is loaded
  await page.waitForTimeout(500);
}

/**
 * Wait for a diagram to render completely
 * @param {import('@playwright/test').Page} page
 * @param {string} type - Diagram type: 'bdd' or 'ibd'
 */
async function waitForDiagram(page, type) {
  const selector = type === 'bdd' ? '#bddDiagram' : '#ibdDiagram';

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
  // Wait for the 3D container to be visible (always visible in new UI)
  await page.waitForSelector('#threejsContainer', { state: 'visible', timeout: 10000 });

  // Wait for canvas to appear (created by Three.js renderer)
  await page.waitForSelector('#threejsContainer canvas', { state: 'visible', timeout: 10000 });

  // Wait for the scene to be initialized (check for canvas rendering)
  await page.waitForFunction(
    () => {
      const canvas = document.querySelector('#threejsContainer canvas');
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
 * @param {string} toggleName - Toggle name: 'parts', 'ports', 'connectors', or 'labels'
 */
async function verifyVisibilityToggle(page, toggleName) {
  const checkbox = page.locator(`#visibility-${toggleName}`);

  // Verify toggle exists and is visible
  await expect(checkbox).toBeVisible();

  // Get initial state (should be checked for parts/ports/connectors, unchecked for labels)
  const initialState = await checkbox.isChecked();

  // Click to toggle
  await checkbox.click();
  await page.waitForTimeout(300); // Wait for animation

  // Verify state changed
  const afterFirstClick = await checkbox.isChecked();
  expect(afterFirstClick).toBe(!initialState);

  // Click to toggle back
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
 * Switch to a specific tab (only for Text/BDD/IBD - 3D is always visible)
 * @param {import('@playwright/test').Page} page
 * @param {string} tabName - Tab name: 'text', 'bdd', or 'ibd' (NOT '3d-view' - that's no longer a tab)
 */
async function switchTab(page, tabName) {
  // 3D view is not a tab anymore - it's always visible on the right
  if (tabName === '3d-view' || tabName === '3d' || tabName === '3D View') {
    console.warn('3D view is no longer a tab - it is always visible on the right side');
    // Just return without error to maintain backward compatibility
    await page.waitForTimeout(500);
    return;
  }

  const tabButton = page.locator(`.tab-btn[data-tab="${tabName}"]`);
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
 * Wait for file tree to be fully loaded (left sidebar - architecture files)
 * @param {import('@playwright/test').Page} page
 */
async function waitForFileTree(page) {
  await page.waitForSelector('#fileTree', { state: 'visible', timeout: 60000 });

  // Wait for at least one file to be present
  await page.waitForSelector('#fileTree a', { timeout: 10000 });

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
  await page.waitForSelector('#architecturePreview', { timeout: 10000 });

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

/**
 * Load a SAJAI file from the right sidebar file tree
 * @param {import('@playwright/test').Page} page
 * @param {string} filename - The SAJAI filename (e.g., 'model.sajai')
 */
async function loadSajaiFile(page, filename) {
  // Wait for SAJAI file tree to load
  await page.waitForSelector('#sajaiFileTree', { timeout: 10000 });

  // Find and click on the SAJAI file
  const fileItem = page.locator(`#sajaiFileTree .sajai-file-item:has-text("${filename}")`);
  await expect(fileItem).toBeVisible({ timeout: 10000 });
  await fileItem.click();

  // Wait for 3D scene to load
  await waitFor3DScene(page);

  // Small delay to ensure everything is loaded
  await page.waitForTimeout(500);
}

/**
 * Wait for SAJAI file tree to be visible (right sidebar)
 * @param {import('@playwright/test').Page} page
 */
async function waitForSajaiFileTree(page) {
  await page.waitForSelector('#sajaiSidebar', { state: 'visible', timeout: 10000 });
  await page.waitForSelector('#sajaiFileTree', { state: 'visible', timeout: 10000 });
  await page.waitForTimeout(300);
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
  openPopout,
  loadSajaiFile,
  waitForSajaiFileTree
};
