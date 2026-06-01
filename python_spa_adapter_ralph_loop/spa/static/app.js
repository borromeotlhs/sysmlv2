let architectures = [];
let currentArchitecture = null;
let pairs = [];
let fileTree = null;
let currentPath = '';
let diagramCache = { bdd: null, ibd: null };
let treeRoot = '';
let projectRoot = '';

// 3D View state
let sajaiRenderer = null;
let currentSajaiData = null;
let normalizedSajaiData = null;
let sceneHistory = [];
let currentSceneIndex = 0;
let sajaiFiles = [];

const $ = (id) => document.getElementById(id);

async function getJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`${url} failed: ${res.status}`);
  return await res.json();
}

async function postJson(url, body) {
  const res = await fetch(url, {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body)});
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || `${url} failed`);
  return data;
}

async function loadArchitectureFromPath(path) {
  try {
    const filename = path.split('/').pop();
    const isSysML = path.endsWith('.sysml');

    // For .sysml files, fetch BOTH parsed JSON (for metadata) and raw content (for display)
    if (isSysML) {
      // Get metadata from parsed JSON
      const metadata = await getJson('/api/architecture/' + encodeURIComponent(path));
      currentArchitecture = metadata;

      // Get raw .sysml content for display
      const rawResponse = await fetch('/api/architecture/' + encodeURIComponent(path) + '?format=raw');
      const rawContent = await rawResponse.text();

      currentPath = path;
      diagramCache = { bdd: null, ibd: null };

      // Update info box with metadata
      $('architectureInfo').innerHTML = `
        <strong>File: ${escapeHtml(filename)}</strong>
        <p>ID: ${escapeHtml(metadata.id || 'N/A')}</p>
        <p>Name: ${escapeHtml(metadata.name || 'N/A')}</p>
        <p>Format: SysML v2 Textual (${escapeHtml(metadata.format || 'unknown')})</p>
        <p>Path: ${escapeHtml(path)}</p>
      `;

      // Show RAW .sysml textual syntax (not JSON!)
      $('architecturePreview').textContent = rawContent;

      // Show copy/download controls for .sysml files
      $('textControls').style.display = 'flex';

      // Enable Generate 3D Model button
      $('generateSajaiBtn').disabled = false;

      // Auto-generate 3D view on-the-fly (don't wait for user to click button)
      // Don't await - let it run in background so UI remains responsive
      generateInMemorySajai(path).catch(err => {
        console.error('Auto-generation failed:', err);
        // Silently fail - user can still manually generate if needed
      });

    } else {
      // For JSON files, use existing behavior
      currentArchitecture = await getJson('/api/architecture/' + encodeURIComponent(path));
      currentPath = path;
      diagramCache = { bdd: null, ibd: null };

      const format = currentArchitecture.format || 'unknown';

      $('architectureInfo').innerHTML = `
        <strong>File: ${escapeHtml(filename)}</strong>
        <p>ID: ${escapeHtml(currentArchitecture.id || 'N/A')}</p>
        <p>Name: ${escapeHtml(currentArchitecture.name || 'N/A')}</p>
        <p>Format: JSON IR (${escapeHtml(format)})</p>
        <p>Path: ${escapeHtml(path)}</p>
      `;

      // Show JSON
      $('architecturePreview').textContent = JSON.stringify(currentArchitecture, null, 2);

      // Hide copy/download controls for JSON files
      $('textControls').style.display = 'none';

      // Disable Generate 3D Model button for JSON files
      $('generateSajaiBtn').disabled = true;
    }

    // Reset to text tab
    switchTab('text');

    // Show prompt section
    $('promptSection').style.display = 'block';
    $('promptText').value = '';
    $('promptText').focus();
  } catch (e) {
    alert('Failed to load architecture: ' + e.message);
  }
}

function switchTab(tabName) {
  // Hide all tab panes
  document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));

  // Show selected tab
  document.getElementById('tab-' + tabName).classList.add('active');
  document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

  // Lazy load diagrams
  if (tabName === 'bdd' && currentPath && !diagramCache.bdd) {
    loadBddDiagram(currentPath);
  }
  if (tabName === 'ibd' && currentPath && !diagramCache.ibd) {
    loadIbdDiagram(currentPath);
  }
}

async function loadBddDiagram(path) {
  try {
    const data = await getJson('/api/diagram/bdd/' + encodeURIComponent(path));
    diagramCache.bdd = data;
    $('bddSource').value = data.plantuml;
    $('bddDiagram').src = data.url;
  } catch (e) {
    alert('Failed to load BDD: ' + e.message);
  }
}

async function loadIbdDiagram(path) {
  try {
    const data = await getJson('/api/diagram/ibd/' + encodeURIComponent(path));
    diagramCache.ibd = data;
    $('ibdSource').value = data.plantuml;
    $('ibdDiagram').src = data.url;
  } catch (e) {
    alert('Failed to load IBD: ' + e.message);
  }
}

async function copyToClipboard(text) {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch (e) {
    // Fallback for older browsers
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    const success = document.execCommand('copy');
    document.body.removeChild(textarea);
    return success;
  }
}

function copyBddSource() {
  if (diagramCache.bdd) {
    copyToClipboard(diagramCache.bdd.plantuml).then(success => {
      if (success) alert('BDD PlantUML source copied to clipboard!');
      else alert('Failed to copy to clipboard');
    });
  }
}

function copyIbdSource() {
  if (diagramCache.ibd) {
    copyToClipboard(diagramCache.ibd.plantuml).then(success => {
      if (success) alert('IBD PlantUML source copied to clipboard!');
      else alert('Failed to copy to clipboard');
    });
  }
}

async function popoutBdd() {
  if (!currentArchitecture) return;

  // Load BDD if not cached
  if (!diagramCache.bdd) {
    try {
      const data = await getJson('/api/diagram/bdd/' + encodeURIComponent(currentPath));
      diagramCache.bdd = data;
    } catch (e) {
      alert('Failed to load BDD: ' + e.message);
      return;
    }
  }

  const win = window.open('', 'BDD_Diagram', 'width=1200,height=900,menubar=no,toolbar=no,location=no,status=no');
  if (!win) return;

  const title = currentArchitecture.name || 'Architecture';

  // Write initial HTML with loading message
  win.document.write(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>BDD - ${escapeHtml(title)}</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: sans-serif; background: #f5f5f5; overflow: hidden; }
        .header { background: #fff; border-bottom: 1px solid #ddd; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; }
        h1 { font-size: 18px; color: #333; }
        .controls { display: flex; gap: 10px; align-items: center; }
        button { padding: 6px 12px; border: 1px solid #ccc; background: white; cursor: pointer; font-size: 14px; border-radius: 3px; }
        button:hover { background: #f0f0f0; }
        .zoom-level { font-size: 14px; color: #666; min-width: 60px; text-align: center; }
        .diagram-container { height: calc(100vh - 60px); overflow: auto; padding: 20px; }
        .diagram-wrapper { display: inline-block; transition: transform 0.1s ease; transform-origin: top left; }
        img { display: block; border: 1px solid #ddd; background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .loading { text-align: center; padding: 40px; color: #666; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Block Definition Diagram - ${escapeHtml(title)}</h1>
        <div class="controls">
          <button onclick="zoomOut()">−</button>
          <span class="zoom-level" id="zoomLevel">100%</span>
          <button onclick="zoomIn()">+</button>
          <button onclick="resetZoom()">Reset</button>
        </div>
      </div>
      <div class="diagram-container" id="container">
        <div class="diagram-wrapper" id="wrapper">
          <div class="loading">Loading full diagram...</div>
        </div>
      </div>
      <script>
        let zoom = 1.0;
        const wrapper = document.getElementById('wrapper');
        const container = document.getElementById('container');
        const zoomLevel = document.getElementById('zoomLevel');

        // Fetch full diagram from server with ?full=true parameter
        fetch('/api/diagram/bdd/${encodeURIComponent(currentPath)}?full=true')
          .then(res => res.json())
          .then(data => {
            wrapper.innerHTML = '<img src="' + data.url + '" alt="Block Definition Diagram" id="diagram" />';
          })
          .catch(err => {
            wrapper.innerHTML = '<div class="loading" style="color: red;">Error loading diagram: ' + err.message + '</div>';
          });

        function updateZoom() {
          wrapper.style.transform = 'scale(' + zoom + ')';
          zoomLevel.textContent = Math.round(zoom * 100) + '%';
        }

        function zoomIn() {
          zoom = Math.min(zoom + 0.25, 5.0);
          updateZoom();
        }

        function zoomOut() {
          zoom = Math.max(zoom - 0.25, 0.25);
          updateZoom();
        }

        function resetZoom() {
          zoom = 1.0;
          updateZoom();
          container.scrollTop = 0;
          container.scrollLeft = 0;
        }

        // Mouse wheel zoom
        container.addEventListener('wheel', (e) => {
          if (e.ctrlKey || e.metaKey) {
            e.preventDefault();
            if (e.deltaY < 0) {
              zoomIn();
            } else {
              zoomOut();
            }
          }
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
          if (e.key === '+' || e.key === '=') {
            e.preventDefault();
            zoomIn();
          } else if (e.key === '-' || e.key === '_') {
            e.preventDefault();
            zoomOut();
          } else if (e.key === '0' || e.key === 'r') {
            e.preventDefault();
            resetZoom();
          }
        });
      </script>
    </body>
    </html>
  `);
  win.document.close();
}

function copySysmlContent() {
  const content = $('architecturePreview').textContent;
  if (!content) {
    alert('No content to copy');
    return;
  }

  const btn = $('copySysmlContent');
  const originalText = btn.textContent;

  copyToClipboard(content).then(success => {
    if (success) {
      btn.textContent = '✓ Copied!';
      setTimeout(() => {
        btn.textContent = originalText;
      }, 2000);
    } else {
      alert('Failed to copy to clipboard');
    }
  });
}

function downloadSysml() {
  const content = $('architecturePreview').textContent;
  if (!content) {
    alert('No content to download');
    return;
  }

  // Extract filename from currentPath
  const filename = currentPath ? currentPath.split('/').pop() : 'architecture.sysml';

  const blob = new Blob([content], { type: 'text/plain' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

async function popoutIbd() {
  if (!currentArchitecture) return;

  // Load IBD if not cached
  if (!diagramCache.ibd) {
    try {
      const data = await getJson('/api/diagram/ibd/' + encodeURIComponent(currentPath));
      diagramCache.ibd = data;
    } catch (e) {
      alert('Failed to load IBD: ' + e.message);
      return;
    }
  }

  const win = window.open('', 'IBD_Diagram', 'width=1200,height=900,menubar=no,toolbar=no,location=no,status=no');
  if (!win) return;

  const title = currentArchitecture.name || 'Architecture';

  // Write initial HTML with loading message
  win.document.write(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>IBD - ${escapeHtml(title)}</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: sans-serif; background: #f5f5f5; overflow: hidden; }
        .header { background: #fff; border-bottom: 1px solid #ddd; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; }
        h1 { font-size: 18px; color: #333; }
        .controls { display: flex; gap: 10px; align-items: center; }
        button { padding: 6px 12px; border: 1px solid #ccc; background: white; cursor: pointer; font-size: 14px; border-radius: 3px; }
        button:hover { background: #f0f0f0; }
        .zoom-level { font-size: 14px; color: #666; min-width: 60px; text-align: center; }
        .diagram-container { height: calc(100vh - 60px); overflow: auto; padding: 20px; }
        .diagram-wrapper { display: inline-block; transition: transform 0.1s ease; transform-origin: top left; }
        img { display: block; border: 1px solid #ddd; background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .loading { text-align: center; padding: 40px; color: #666; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Internal Block Diagram - ${escapeHtml(title)}</h1>
        <div class="controls">
          <button onclick="zoomOut()">−</button>
          <span class="zoom-level" id="zoomLevel">100%</span>
          <button onclick="zoomIn()">+</button>
          <button onclick="resetZoom()">Reset</button>
        </div>
      </div>
      <div class="diagram-container" id="container">
        <div class="diagram-wrapper" id="wrapper">
          <div class="loading">Loading full diagram...</div>
        </div>
      </div>
      <script>
        let zoom = 1.0;
        const wrapper = document.getElementById('wrapper');
        const container = document.getElementById('container');
        const zoomLevel = document.getElementById('zoomLevel');

        // Fetch full diagram from server with ?full=true parameter
        fetch('/api/diagram/ibd/${encodeURIComponent(currentPath)}?full=true')
          .then(res => res.json())
          .then(data => {
            wrapper.innerHTML = '<img src="' + data.url + '" alt="Internal Block Diagram" id="diagram" />';
          })
          .catch(err => {
            wrapper.innerHTML = '<div class="loading" style="color: red;">Error loading diagram: ' + err.message + '</div>';
          });

        function updateZoom() {
          wrapper.style.transform = 'scale(' + zoom + ')';
          zoomLevel.textContent = Math.round(zoom * 100) + '%';
        }

        function zoomIn() {
          zoom = Math.min(zoom + 0.25, 5.0);
          updateZoom();
        }

        function zoomOut() {
          zoom = Math.max(zoom - 0.25, 0.25);
          updateZoom();
        }

        function resetZoom() {
          zoom = 1.0;
          updateZoom();
          container.scrollTop = 0;
          container.scrollLeft = 0;
        }

        // Mouse wheel zoom
        container.addEventListener('wheel', (e) => {
          if (e.ctrlKey || e.metaKey) {
            e.preventDefault();
            if (e.deltaY < 0) {
              zoomIn();
            } else {
              zoomOut();
            }
          }
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
          if (e.key === '+' || e.key === '=') {
            e.preventDefault();
            zoomIn();
          } else if (e.key === '-' || e.key === '_') {
            e.preventDefault();
            zoomOut();
          } else if (e.key === '0' || e.key === 'r') {
            e.preventDefault();
            resetZoom();
          }
        });
      </script>
    </body>
    </html>
  `);
  win.document.close();
}

async function refreshPairFiles() {
  const data = await getJson('/api/pair-files');
  $('pairFileSelect').innerHTML = (data.pair_files || []).map(f => `<option value="${f.path}">${f.path}</option>`).join('');
}

async function loadPairFile() {
  const path = $('pairFileSelect').value;
  if (!path) return;
  pairs = await getJson('/api/pairs/' + encodeURIComponent(path));
  $('outputFilename').value = path.split('/').pop();
  renderPairs();
}

function pairFromForm() {
  if (!currentArchitecture) throw new Error('Load an architecture first.');
  const prompt = $('promptText').value.trim();
  if (!prompt) throw new Error('Prompt is empty.');
  const n = pairs.length + 1;
  return {
    id: `pair_${currentArchitecture.id}_${String(n).padStart(3, '0')}`,
    architecture_id: currentArchitecture.id,
    prompt_id: `prompt_${currentArchitecture.id}_${String(n).padStart(3, '0')}`,
    prompt,
    target_path: `data/architectures/${currentArchitecture.id}.json`,
    target_format: 'json',
    metadata: { split: $('splitSelect').value, authoring_mode: 'human_spa' }
  };
}

function addPair() {
  try {
    pairs.push(pairFromForm());
    $('promptText').value = '';
    renderPairs();
  } catch (e) { alert(e.message); }
}

function updatePair(index, field, value) {
  if (field === 'split') pairs[index].metadata.split = value;
  else pairs[index][field] = value;
}

function deletePair(index) {
  pairs.splice(index, 1);
  renderPairs();
}

function renderPairs() {
  $('pairCount').textContent = pairs.length;
  $('pairsList').innerHTML = pairs.map((p, i) => `
    <div class="pair">
      <strong>${p.id}</strong> — ${escapeHtml(p.architecture_id)} [${escapeHtml(p.metadata?.split || 'train')}]<br/>
      <label>Prompt<textarea onchange="updatePair(${i}, 'prompt', this.value)">${escapeHtml(p.prompt)}</textarea></label>
      <button onclick="deletePair(${i})">Delete</button>
    </div>
  `).join('');
}

async function savePairs() {
  const filename = $('outputFilename').value || 'authored_pairs.json';
  const result = await postJson('/api/save-pairs', {filename, records: pairs});
  alert(`Saved ${result.records} records to ${result.path}`);
  await refreshPairFiles();
}

function downloadPairs() {
  const blob = new Blob([JSON.stringify(pairs, null, 2)], {type: 'application/json'});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = $('outputFilename').value || 'authored_pairs.json';
  a.click();
  URL.revokeObjectURL(a.href);
}

function clearPairs() {
  if (confirm('Clear all pairs? This will not delete saved files.')) {
    pairs = [];
    renderPairs();
  }
}

function escapeHtml(s) {
  return String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[c]));
}

async function refreshFileTree(root) {
  const treeContainer = $('fileTree');

  // Use pre-loaded tree if available (no custom root requested)
  if (!root && window.__INITIAL_FILE_TREE__) {
    console.log('[refreshFileTree] Using pre-loaded tree from HTML');
    fileTree = window.__INITIAL_FILE_TREE__;
    treeRoot = fileTree.resolved_path || '';
    if (!projectRoot) projectRoot = treeRoot;
    renderFileTree();
    treeContainer.setAttribute('data-loaded', 'true');
    console.log('[refreshFileTree] Pre-loaded tree rendered successfully');
    return;
  }

  // Otherwise fetch from API
  const url = root ? `/api/tree?root=${encodeURIComponent(root)}` : '/api/tree';
  console.log('[refreshFileTree] Fetching tree from:', url);

  // Show loading indicator
  treeContainer.innerHTML = '<div style="padding: 20px; text-align: center; color: #888;">Loading file tree...</div>';
  treeContainer.setAttribute('data-loaded', 'false');

  try {
    fileTree = await getJson(url);
    console.log('[refreshFileTree] Tree loaded:', fileTree);
    treeRoot = fileTree.resolved_path || '';
    if (!projectRoot) projectRoot = treeRoot; // Store initial project root
    renderFileTree();
    console.log('[refreshFileTree] Tree rendered successfully');
    // Signal that tree is fully loaded
    treeContainer.setAttribute('data-loaded', 'true');
  } catch (e) {
    console.error('[refreshFileTree] Failed to load tree:', e);
    treeContainer.innerHTML = '<div style="padding: 20px; text-align: center; color: #c00;">Failed to load file tree</div>';
    treeContainer.setAttribute('data-loaded', 'error');
  }
}

function renderFileTree() {
  if (!fileTree) return;
  $('fileTree').innerHTML = renderTreeNode(fileTree);
  $('currentRoot').textContent = treeRoot || 'Project Root';
  $('rootPath').value = treeRoot;
  setupTreeClickHandlers();
}

function changeTreeRoot() {
  const newRoot = $('rootPath').value.trim();
  if (newRoot) {
    refreshFileTree(newRoot);
  }
}

function goUpDirectory() {
  if (treeRoot) {
    const parent = treeRoot.split('/').slice(0, -1).join('/') || '/';
    refreshFileTree(parent);
  }
}

function resetTreeRoot() {
  refreshFileTree(projectRoot);
}

function renderTreeNode(node, level = 0) {
  if (node.type === 'file') {
    // Check if file is an architecture (JSON or .sysml) - recognize anywhere
    const isArchitecture = node.name.endsWith('.json') || node.name.endsWith('.sysml');
    const className = isArchitecture ? 'tree-item file architecture-file' : 'tree-item file';
    return `<div class="${className}" data-path="${escapeHtml(node.path)}" data-type="file">${escapeHtml(node.name)}</div>`;
  }

  const hasChildren = node.children && node.children.length > 0;
  const pathId = (node.path || 'root').replace(/[^a-zA-Z0-9_-]/g, '_');
  const childrenHtml = hasChildren
    ? `<div class="tree-children collapsed" id="children-${pathId}">${node.children.map(child => renderTreeNode(child, level + 1)).join('')}</div>`
    : '';

  return `
    <div class="tree-item directory" data-path="${escapeHtml(node.path || '')}" data-pathid="${pathId}" data-type="directory">
      ${escapeHtml(node.name)}
    </div>
    ${childrenHtml}
  `;
}

function handleFileClick(path) {
  // Handle both JSON and .sysml architecture files anywhere
  if (path.endsWith('.json') || path.endsWith('.sysml')) {
    loadArchitectureFromPath(path);
  }
}

function toggleDirectory(pathId) {
  const children = document.getElementById(`children-${pathId}`);
  const item = document.querySelector(`.tree-item[data-pathid="${pathId}"]`);
  if (children && item) {
    children.classList.toggle('collapsed');
    item.classList.toggle('expanded');
  }
}

// Handle tree item clicks
function setupTreeClickHandlers() {
  const treeContainer = document.getElementById('fileTree');
  if (treeContainer) {
    treeContainer.onclick = (e) => {
      const target = e.target.closest('.tree-item');
      if (!target) return;

      const type = target.dataset.type;
      const path = target.dataset.path;
      const pathId = target.dataset.pathid;

      if (type === 'directory' && pathId) {
        toggleDirectory(pathId);
      } else if (type === 'file' && path) {
        handleFileClick(path);
      }
    };
  }
}

$('refreshPairFiles').onclick = refreshPairFiles;
$('loadPairFile').onclick = loadPairFile;
$('addPair').onclick = addPair;
$('savePairs').onclick = savePairs;
$('downloadPairs').onclick = downloadPairs;
$('clearPairs').onclick = clearPairs;
$('refreshTree').onclick = () => refreshFileTree(treeRoot);
$('changeRoot').onclick = changeTreeRoot;
$('goUp').onclick = goUpDirectory;
$('resetRoot').onclick = resetTreeRoot;
$('copyBddSource').onclick = copyBddSource;
$('copyIbdSource').onclick = copyIbdSource;
$('popoutBdd').onclick = popoutBdd;
$('popoutIbd').onclick = popoutIbd;
$('copySysmlContent').onclick = copySysmlContent;
$('downloadSysml').onclick = downloadSysml;

// SAJAI Generation event listeners
$('generateSajaiBtn').onclick = openSajaiGenerateModal;
$('closeSajaiModal').onclick = closeSajaiGenerateModal;
$('cancelSajaiGenerate').onclick = closeSajaiGenerateModal;
$('confirmSajaiGenerate').onclick = generateSajaiFromArch;

// Modal backdrop click to close
$('sajaiGenerateModal').onclick = (e) => {
  if (e.target.classList.contains('modal-backdrop')) {
    closeSajaiGenerateModal();
  }
};

// Save 3D Model event listeners
$('save3DBtn').onclick = openSave3DModal;
$('closeSave3DModal').onclick = closeSave3DModal;
$('cancelSave3D').onclick = closeSave3DModal;
$('confirmSave3D').onclick = save3DModel;

// Modal backdrop click to close
$('save3DModal').onclick = (e) => {
  if (e.target.classList.contains('modal-backdrop')) {
    closeSave3DModal();
  }
};

// Allow Enter key in root path input
$('rootPath').onkeypress = (e) => {
  if (e.key === 'Enter') changeTreeRoot();
};

// Add tab button listeners
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.onclick = () => switchTab(btn.dataset.tab);
});

window.updatePair = updatePair;
window.deletePair = deletePair;

// ========== SysML Editor Modal ==========

let validationTimeout = null;
let currentValidation = null;
let editorLineCount = 1;

function openSysmlEditor(content = '', filename = '') {
  const modal = $('sysmlEditorModal');
  const editor = $('sysmlEditor');
  const filenameInput = $('architectureFilename');

  // Set content and filename
  editor.value = content;
  filenameInput.value = filename || generateNextArchitectureFilename();

  // Show modal
  modal.classList.add('active');

  // Focus editor
  setTimeout(() => editor.focus(), 100);

  // Update line numbers
  updateLineNumbers();

  // Clear validation
  clearValidation();

  // Trigger initial validation if there's content
  if (content.trim()) {
    scheduleValidation();
  }
}

function closeSysmlEditor() {
  const modal = $('sysmlEditorModal');
  modal.classList.remove('active');

  // Clear editor
  $('sysmlEditor').value = '';
  $('architectureFilename').value = '';

  // Clear validation
  if (validationTimeout) {
    clearTimeout(validationTimeout);
    validationTimeout = null;
  }
  if (currentValidation) {
    currentValidation = null;
  }
}

function generateNextArchitectureFilename() {
  // Try to find highest numbered architecture in current tree
  // For now, just return a placeholder
  return 'arch_000XXX.sysml';
}

function updateLineNumbers() {
  const editor = $('sysmlEditor');
  const lineNumbers = $('lineNumbers');
  const lines = editor.value.split('\n');
  editorLineCount = lines.length;

  // Generate line numbers
  const numbers = [];
  for (let i = 1; i <= editorLineCount; i++) {
    numbers.push(i);
  }
  lineNumbers.textContent = numbers.join('\n');

  // Sync scroll
  lineNumbers.scrollTop = editor.scrollTop;
}

function scheduleValidation() {
  // Clear existing timeout
  if (validationTimeout) {
    clearTimeout(validationTimeout);
  }

  // Show validating status
  showValidationStatus('validating', 'Validating...');

  // Schedule validation after 500ms of no typing
  validationTimeout = setTimeout(() => {
    validateSysmlContent();
  }, 500);
}

async function validateSysmlContent() {
  const editor = $('sysmlEditor');
  const content = editor.value.trim();

  if (!content) {
    clearValidation();
    return;
  }

  try {
    // Call backend validation endpoint
    const response = await fetch('/api/validate-sysml', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ content })
    });

    const result = await response.json();

    if (response.ok && result.valid) {
      // No errors
      showValidationStatus('valid', 'Valid SysML v2 syntax');
      editor.classList.remove('has-errors');
      $('saveArchitecture').disabled = false;
    } else {
      // Has errors
      const errors = result.errors || [];
      displayValidationErrors(errors);
      editor.classList.add('has-errors');
      $('saveArchitecture').disabled = errors.some(e => e.severity === 'error');
    }
  } catch (e) {
    console.error('Validation failed:', e);
    showValidationStatus('error', 'Validation service unavailable');
    editor.classList.remove('has-errors');
    $('saveArchitecture').disabled = false; // Allow saving even if validation fails
  }
}

function clearValidation() {
  const errorList = $('errorList');
  errorList.innerHTML = '<div class="status-message">Type to validate...</div>';
  $('sysmlEditor').classList.remove('has-errors');
  $('saveArchitecture').disabled = false;
}

function showValidationStatus(type, message) {
  const errorList = $('errorList');
  errorList.innerHTML = `<div class="status-message ${type}">${escapeHtml(message)}</div>`;
}

function displayValidationErrors(errors) {
  const errorList = $('errorList');

  if (errors.length === 0) {
    showValidationStatus('valid', 'Valid SysML v2 syntax');
    return;
  }

  // Sort errors by line number
  errors.sort((a, b) => (a.line || 0) - (b.line || 0));

  // Generate error items
  const errorItems = errors.map((err, index) => {
    const severity = err.severity || 'error';
    const line = err.line || '?';
    const column = err.column ? `:${err.column}` : '';
    const message = err.message || 'Unknown error';

    return `
      <div class="error-item ${severity}" onclick="jumpToErrorLine(${err.line})" data-line="${err.line}">
        <div class="error-line">Line ${line}${column}</div>
        <div class="error-message">${escapeHtml(message)}</div>
      </div>
    `;
  }).join('');

  errorList.innerHTML = errorItems;
}

function jumpToErrorLine(line) {
  if (!line) return;

  const editor = $('sysmlEditor');
  const lines = editor.value.split('\n');

  // Calculate character position for the line
  let charPos = 0;
  for (let i = 0; i < line - 1 && i < lines.length; i++) {
    charPos += lines[i].length + 1; // +1 for newline
  }

  // Set cursor position
  editor.focus();
  editor.setSelectionRange(charPos, charPos + (lines[line - 1]?.length || 0));

  // Scroll to line
  const lineHeight = 19.5; // Approximate line height in pixels
  editor.scrollTop = (line - 1) * lineHeight - (editor.clientHeight / 3);
}

async function saveSysmlArchitecture() {
  const editor = $('sysmlEditor');
  const filenameInput = $('architectureFilename');

  const content = editor.value.trim();
  const filename = filenameInput.value.trim();

  if (!content) {
    alert('Content is empty. Please enter SysML v2 syntax.');
    return;
  }

  if (!filename) {
    alert('Please enter a filename.');
    filenameInput.focus();
    return;
  }

  // Ensure filename ends with .sysml
  const finalFilename = filename.endsWith('.sysml') ? filename : filename + '.sysml';

  try {
    // Save to backend
    const result = await postJson('/api/save-sysml', {
      filename: finalFilename,
      content: content
    });

    alert(`Architecture saved to ${result.path}`);

    // Close modal
    closeSysmlEditor();

    // Refresh file tree
    await refreshFileTree(treeRoot);

    // Load the newly created file
    if (result.path) {
      loadArchitectureFromPath(result.path);
    }
  } catch (e) {
    alert('Failed to save architecture: ' + e.message);
  }
}

// Event listeners for modal
$('newArchitectureBtn').onclick = () => openSysmlEditor();
$('closeModal').onclick = closeSysmlEditor;
$('cancelEditor').onclick = closeSysmlEditor;
$('saveArchitecture').onclick = saveSysmlArchitecture;

// Modal backdrop click to close
$('sysmlEditorModal').onclick = (e) => {
  if (e.target.classList.contains('modal-backdrop')) {
    closeSysmlEditor();
  }
};

// ESC key to close modals
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    const sysmlModal = $('sysmlEditorModal');
    const sajaiModal = $('sajaiGenerateModal');
    if (sysmlModal.classList.contains('active')) {
      closeSysmlEditor();
    } else if (sajaiModal.classList.contains('active')) {
      closeSajaiGenerateModal();
    }
  }
});

// Editor events
$('sysmlEditor').addEventListener('input', () => {
  updateLineNumbers();
  scheduleValidation();
});

$('sysmlEditor').addEventListener('scroll', () => {
  const editor = $('sysmlEditor');
  const lineNumbers = $('lineNumbers');
  lineNumbers.scrollTop = editor.scrollTop;
});

// Expose jumpToErrorLine globally
window.jumpToErrorLine = jumpToErrorLine;

// ========== SAJAI Generation Functions ==========

/**
 * Open SAJAI generation modal
 */
function openSajaiGenerateModal() {
  if (!currentPath) {
    alert('No architecture selected');
    return;
  }

  const modal = $('sajaiGenerateModal');
  const filenameInput = $('sajaiFilename');

  // Generate default filename from architecture name
  const archName = currentPath.split('/').pop().replace('.sysml', '');
  filenameInput.value = `${archName}.sajai`;

  // Show modal
  modal.classList.add('active');

  // Focus input
  setTimeout(() => filenameInput.focus(), 100);
}

/**
 * Close SAJAI generation modal
 */
function closeSajaiGenerateModal() {
  const modal = $('sajaiGenerateModal');
  modal.classList.remove('active');
  $('sajaiFilename').value = '';
}

/**
 * Generate SAJAI from current architecture
 */
async function generateSajaiFromArch() {
  if (!currentPath) {
    alert('No architecture selected');
    return;
  }

  const filename = $('sajaiFilename').value.trim();
  if (!filename) {
    alert('Please enter a filename');
    return;
  }

  // Ensure .sajai extension
  const finalFilename = filename.endsWith('.sajai') ? filename : filename + '.sajai';
  const outputPath = `spa/static/sample-data/${finalFilename}`;

  // Close modal
  closeSajaiGenerateModal();

  // Show loading in 3D view tab
  const generateBtn = $('generateSajaiBtn');
  const originalText = generateBtn.textContent;
  generateBtn.disabled = true;
  generateBtn.textContent = '⟳ Generating...';

  try {
    // Call backend API
    const result = await postJson('/api/generate-sajai', {
      architecturePath: currentPath,
      outputPath: outputPath
    });

    // Show success message
    alert(`3D model generated successfully!\nSaved to: ${result.path}`);

    // Refresh SAJAI file list
    await refreshSajaiFiles();

    // Auto-select and load the newly generated file
    const relativePath = result.path.replace('spa/static/', '');
    const treeContainer = $('sajaiFileTree');
    const fileItem = Array.from(treeContainer.querySelectorAll('.sajai-file-item')).find(
      item => item.dataset.path === relativePath
    );

    if (fileItem) {
      // Remove selection from all items
      treeContainer.querySelectorAll('.sajai-file-item').forEach(i => i.classList.remove('selected'));
      // Select the new file
      fileItem.classList.add('selected');
      // Load it
      await loadSajaiFromPath(relativePath);
    }

  } catch (e) {
    alert('Failed to generate 3D model: ' + e.message);
    console.error('SAJAI generation error:', e);
  } finally {
    // Restore button
    generateBtn.disabled = false;
    generateBtn.textContent = originalText;
  }
}

/**
 * Open Save 3D Model modal
 */
function openSave3DModal() {
  // Check if 3D scene is loaded
  if (!currentSajaiData || !sajaiRenderer) {
    alert('No 3D model loaded. Load or generate a 3D model first.');
    return;
  }

  const modal = $('save3DModal');
  const filenameInput = $('save3DFilename');

  // Generate default filename from current architecture or SAJAI filename
  let defaultName = 'model';
  if (currentPath) {
    defaultName = currentPath.split('/').pop().replace('.sysml', '');
  }
  filenameInput.value = defaultName;

  // Show modal
  modal.classList.add('active');

  // Focus input
  setTimeout(() => filenameInput.focus(), 100);
}

/**
 * Close Save 3D Model modal
 */
function closeSave3DModal() {
  const modal = $('save3DModal');
  modal.classList.remove('active');
  $('save3DFilename').value = '';
}

/**
 * Save current 3D model as SAJAI or GLB
 */
async function save3DModel() {
  if (!currentSajaiData || !sajaiRenderer) {
    alert('No 3D model to save');
    return;
  }

  const filename = $('save3DFilename').value.trim();
  const format = $('save3DFormat').value;

  if (!filename) {
    alert('Please enter a filename');
    return;
  }

  // Add extension if not present
  const ext = format === 'glb' ? '.glb' : '.sajai';
  const finalFilename = filename.endsWith(ext) ? filename : filename + ext;
  const outputPath = `spa/static/sample-data/${finalFilename}`;

  // Close modal
  closeSave3DModal();

  // Show loading state
  const saveBtn = $('save3DBtn');
  const originalText = saveBtn.textContent;
  saveBtn.disabled = true;
  saveBtn.textContent = '⟳ Saving...';

  try {
    if (format === 'sajai') {
      // Save SAJAI format
      const result = await postJson('/api/save-sajai', {
        sajaiData: currentSajaiData,
        outputPath: outputPath
      });

      alert(`3D model saved successfully!\nSaved to: ${result.path}`);

    } else if (format === 'glb') {
      // Convert to GLB format
      const result = await postJson('/api/export-glb', {
        sajaiData: currentSajaiData,
        outputPath: outputPath
      });

      alert(`3D model exported successfully!\nSaved to: ${result.path}`);
    }

    // Refresh SAJAI file list if saved as .sajai
    if (format === 'sajai') {
      await refreshSajaiFiles();
    }

  } catch (e) {
    alert('Failed to save 3D model: ' + e.message);
    console.error('Save 3D error:', e);
  } finally {
    // Restore button
    saveBtn.disabled = false;
    saveBtn.textContent = originalText;
  }
}

// ========== 3D View Functions ==========

/**
 * Initialize 3D view - called on page load
 */
function init3DView() {
  // Populate SAJAI file tree
  refreshSajaiFiles();
}

/**
 * Refresh the list of available SAJAI files
 */
async function refreshSajaiFiles() {
  try {
    const response = await fetch('/api/sajai-files');
    if (response.ok) {
      const data = await response.json();
      sajaiFiles = data.files || [];

      // Populate SAJAI file tree
      const treeContainer = $('sajaiFileTree');
      if (sajaiFiles.length === 0) {
        treeContainer.innerHTML = '<div style="padding: 12px; text-align: center; color: #888; font-size: 12px;">No .sajai files found</div>';
      } else {
        treeContainer.innerHTML = sajaiFiles.map(f =>
          `<div class="sajai-file-item" data-path="${escapeHtml(f.path)}">${escapeHtml(f.name)}</div>`
        ).join('');

        // Add click handlers
        treeContainer.querySelectorAll('.sajai-file-item').forEach(item => {
          item.onclick = () => {
            // Remove selection from all items
            treeContainer.querySelectorAll('.sajai-file-item').forEach(i => i.classList.remove('selected'));
            // Add selection to clicked item
            item.classList.add('selected');
            // Load the file
            loadSajaiFromPath(item.dataset.path);
          };
        });
      }
    }
  } catch (e) {
    console.error('Failed to load SAJAI files:', e);
    const treeContainer = $('sajaiFileTree');
    treeContainer.innerHTML = '<div style="padding: 12px; text-align: center; color: #c00; font-size: 12px;">Failed to load files</div>';
  }
}

/**
 * Load SAJAI file from path
 */
async function loadSajaiFromPath(path) {
  try {
    showLoading3D('Loading 3D model...');

    const sajaiData = await SajaiParser.loadFromUrl('/api/sajai/' + encodeURIComponent(path));
    await loadSajaiData(sajaiData);

    hideLoading3D();
  } catch (e) {
    console.error('Failed to load SAJAI file:', e);
    hideLoading3D();
    show3DError('Failed to load file: ' + e.message);
  }
}

/* loadSelectedSajai removed - now using tree-based selection with loadSajaiFromPath */

/**
 * Generate SAJAI on-the-fly from current .sysml architecture (in-memory, not saved)
 * Called automatically when .sysml file is loaded
 */
async function generateInMemorySajai(architecturePath) {
  if (!architecturePath || !architecturePath.endsWith('.sysml')) {
    return; // Only generate for .sysml files
  }

  try {
    showLoading3D('Generating 3D view...');

    // Call backend API to generate SAJAI JSON (don't save to file)
    const result = await postJson('/api/generate-sajai', {
      architecturePath: architecturePath,
      inMemory: true  // Signal to backend: return JSON, don't save file
    });

    // Load the generated SAJAI data directly into Three.js
    if (result.sajaiData) {
      await loadSajaiData(result.sajaiData);
      hideLoading3D();
    } else {
      throw new Error('No SAJAI data returned from generator');
    }

  } catch (e) {
    console.error('Failed to generate 3D view:', e);
    hideLoading3D();
    show3DError('Failed to generate 3D: ' + e.message);
  }
}

/**
 * Load and render SAJAI data
 */
async function loadSajaiData(sajaiData) {
  currentSajaiData = sajaiData;

  // Normalize the data
  normalizedSajaiData = SajaiSceneNormalizer.normalize(sajaiData);

  // Initialize renderer if needed
  const container = $('threejsContainer');
  if (!sajaiRenderer) {
    // Clear placeholder
    container.innerHTML = '';

    // Create renderer with event system
    const eventEmitter = {
      listeners: {},
      emit(event, data) {
        if (this.listeners[event]) {
          this.listeners[event].forEach(fn => fn(data));
        }
      },
      on(event, fn) {
        if (!this.listeners[event]) {
          this.listeners[event] = [];
        }
        this.listeners[event].push(fn);
      }
    };

    sajaiRenderer = new SajaiThreeRenderer();
    sajaiRenderer.init(container, eventEmitter);

    // Apply current checkbox states to renderer immediately after init
    sajaiRenderer.visibility.parts = $('visibility-parts').checked;
    sajaiRenderer.visibility.ports = $('visibility-ports').checked;
    sajaiRenderer.visibility.connectors = $('visibility-connectors').checked;
    sajaiRenderer.visibility.labels = $('visibility-labels').checked;
    console.log('[3D View] Initialized renderer with visibility:', sajaiRenderer.visibility);

    // Handle element selection
    eventEmitter.on('element-selected', (data) => {
      updatePropertyInspector(data);

      // If port clicked, highlight connected ports
      if (data.type === 'port' && data.data.connectedPortIds) {
        highlightConnectedPorts(data.data.connectedPortIds);
      }
    });

    eventEmitter.on('element-deselected', () => {
      updatePropertyInspector(null);
    });
  }

  // Reset scene history
  sceneHistory = [normalizedSajaiData.scenes[0]];
  currentSceneIndex = 0;

  // Load first scene
  if (normalizedSajaiData.scenes.length > 0) {
    loadScene(normalizedSajaiData.scenes[0]);
  }

  // Sync checkbox states with renderer
  syncVisibilityCheckboxes();

  // Show download button
  $('downloadUpdatedSajai').style.display = 'inline-block';

  // Enable save 3D button
  $('save3DBtn').disabled = false;

  console.log('SAJAI data loaded:', SajaiParser.getSummary(sajaiData));
}

/**
 * Load a specific scene
 */
function loadScene(sceneData) {
  if (!sajaiRenderer) return;

  sajaiRenderer.loadScene(sceneData);

  // Update scene navigation
  updateSceneNavigation(sceneData);
}

/**
 * Update scene navigation UI
 */
function updateSceneNavigation(sceneData) {
  const pathSpan = $('nav3dPath');
  const backBtn = $('nav3dBack');
  const forwardBtn = $('nav3dForward');

  pathSpan.textContent = sceneData.name || sceneData.id || 'Root';

  // Enable/disable navigation buttons
  backBtn.disabled = currentSceneIndex === 0;
  forwardBtn.disabled = currentSceneIndex >= sceneHistory.length - 1;
}

/**
 * Navigate back in scene history
 */
function navigate3DBack() {
  if (currentSceneIndex > 0) {
    currentSceneIndex--;
    loadScene(sceneHistory[currentSceneIndex]);
  }
}

/**
 * Navigate forward in scene history
 */
function navigate3DForward() {
  if (currentSceneIndex < sceneHistory.length - 1) {
    currentSceneIndex++;
    loadScene(sceneHistory[currentSceneIndex]);
  }
}

/**
 * Navigate into a nested scene (e.g., double-click on part)
 */
function navigateIntoScene(sceneId) {
  if (!normalizedSajaiData) return;

  // Find scene by ID
  const scene = normalizedSajaiData.scenes.find(s => s.id === sceneId);
  if (!scene) {
    alert('Nested scene not found: ' + sceneId);
    return;
  }

  // Add to history (remove any forward history)
  sceneHistory = sceneHistory.slice(0, currentSceneIndex + 1);
  sceneHistory.push(scene);
  currentSceneIndex = sceneHistory.length - 1;

  // Load scene
  loadScene(scene);
}

/**
 * Update property inspector panel
 */
function updatePropertyInspector(elementData) {
  const content = $('elementDetails');

  if (!elementData) {
    content.innerHTML = '<p class="hint">Click an element in the 3D view to inspect its properties</p>';
    return;
  }

  const { type, id, data } = elementData;

  let html = `
    <div class="property-tag">${escapeHtml(type.toUpperCase())}</div>
    <p><strong>ID:</strong> ${escapeHtml(id)}</p>
    <p><strong>Name:</strong> ${escapeHtml(data.name || 'N/A')}</p>
  `;

  if (data.type) {
    html += `<p><strong>Type:</strong> ${escapeHtml(data.type)}</p>`;
  }

  if (data.sysmlRef) {
    html += `<p><strong>SysML Ref:</strong></p><div class="property-value">${escapeHtml(data.sysmlRef)}</div>`;
  }

  if (data.qualifiedName) {
    html += `<p><strong>Qualified Name:</strong></p><div class="property-value">${escapeHtml(data.qualifiedName)}</div>`;
  }

  if (type === 'part') {
    if (data.position) {
      html += `<p><strong>Position:</strong> [${data.position[0].toFixed(1)}, ${data.position[1].toFixed(1)}, ${data.position[2].toFixed(1)}]</p>`;
    }
    if (data.size) {
      html += `<p><strong>Size:</strong> [${data.size[0].toFixed(1)}, ${data.size[1].toFixed(1)}, ${data.size[2].toFixed(1)}]</p>`;
    }
    if (data.color) {
      html += `<p><strong>Color:</strong> <span class="legend-color" style="background: ${data.color}; display: inline-block; vertical-align: middle;"></span> ${escapeHtml(data.color)}</p>`;
    }

    // Check for nested scene
    if (data.metadata && data.metadata.doubleClickScene) {
      html += `<p><em>Double-click to explore internals</em></p>`;
    }
  } else if (type === 'port') {
    if (data.surface) {
      html += `<p><strong>Surface:</strong> ${escapeHtml(data.surface)}</p>`;
    }
    if (data.uv) {
      html += `<p><strong>UV:</strong> [${data.uv[0].toFixed(2)}, ${data.uv[1].toFixed(2)}]</p>`;
    }
    if (data.connectedPortIds && data.connectedPortIds.length > 0) {
      html += `<p><strong>Connected Ports:</strong> ${data.connectedPortIds.length}</p>`;
    }
  } else if (type === 'connector') {
    if (data.sourcePortId) {
      html += `<p><strong>From Port:</strong> ${escapeHtml(data.sourcePortId)}</p>`;
    }
    if (data.targetPortId) {
      html += `<p><strong>To Port:</strong> ${escapeHtml(data.targetPortId)}</p>`;
    }
  }

  // Show metadata
  if (data.metadata && Object.keys(data.metadata).length > 0) {
    html += '<p><strong>Metadata:</strong></p>';
    for (const [key, value] of Object.entries(data.metadata)) {
      if (key !== 'doubleClickScene') {
        html += `<p style="margin-left: 16px;"><strong>${escapeHtml(key)}:</strong> ${escapeHtml(String(value))}</p>`;
      }
    }
  }

  content.innerHTML = html;
}

/**
 * Highlight connected ports
 */
function highlightConnectedPorts(portIds) {
  // TODO: Implement visual highlighting of connected ports
  console.log('Highlight connected ports:', portIds);
}

/**
 * Handle visibility toggles
 */
function handleVisibilityToggle(type, checked) {
  if (!sajaiRenderer) {
    console.warn('[Visibility] Renderer not initialized yet');
    return;
  }

  console.log(`[Visibility] Setting ${type} to ${checked}`);
  sajaiRenderer.setVisibility(type, checked);
}

/**
 * Sync checkbox states with renderer visibility state
 */
function syncVisibilityCheckboxes() {
  if (!sajaiRenderer) return;

  $('visibility-parts').checked = sajaiRenderer.visibility.parts;
  $('visibility-ports').checked = sajaiRenderer.visibility.ports;
  $('visibility-connectors').checked = sajaiRenderer.visibility.connectors;
  $('visibility-labels').checked = sajaiRenderer.visibility.labels;
}

/**
 * Download updated SAJAI file with modified positions
 */
function downloadUpdatedSajai() {
  if (!currentSajaiData || !sajaiRenderer) {
    alert('No SAJAI data loaded');
    return;
  }

  // TODO: Collect position updates from renderer
  // For now, just download the original data
  const blob = new Blob([JSON.stringify(currentSajaiData, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'updated_scene.sajai';
  a.click();
  URL.revokeObjectURL(url);
}

/**
 * Show loading indicator in 3D view
 */
function showLoading3D(message = 'Loading...') {
  const container = $('threejsContainer');
  const existing = container.querySelector('.threejs-loading');
  if (existing) {
    existing.textContent = message;
  } else {
    const loading = document.createElement('div');
    loading.className = 'threejs-loading';
    loading.textContent = message;
    container.appendChild(loading);
  }
}

/**
 * Hide loading indicator
 */
function hideLoading3D() {
  const container = $('threejsContainer');
  const loading = container.querySelector('.threejs-loading');
  if (loading) {
    loading.remove();
  }
}

/**
 * Show error in 3D view
 */
function show3DError(message) {
  const container = $('threejsContainer');
  container.innerHTML = `<div class="threejs-placeholder"><p style="color: #dc2626;">${escapeHtml(message)}</p></div>`;
}

// 3D View event listeners
$('refreshSajaiTree').onclick = refreshSajaiFiles;
$('nav3dBack').onclick = navigate3DBack;
$('nav3dForward').onclick = navigate3DForward;
$('downloadUpdatedSajai').onclick = downloadUpdatedSajai;

// Visibility toggle listeners
$('visibility-parts').onchange = (e) => {
  handleVisibilityToggle('parts', e.target.checked);
  console.log('[Visibility] Parts:', e.target.checked);
};
$('visibility-ports').onchange = (e) => {
  handleVisibilityToggle('ports', e.target.checked);
  console.log('[Visibility] Ports:', e.target.checked);
};
$('visibility-connectors').onchange = (e) => {
  handleVisibilityToggle('connectors', e.target.checked);
  console.log('[Visibility] Connectors:', e.target.checked);
};
$('visibility-labels').onchange = (e) => {
  handleVisibilityToggle('labels', e.target.checked);
  console.log('[Visibility] Labels:', e.target.checked);
};

// Pop-out 3D view
$('popout3d').onclick = () => {
  if (!currentSajaiData || !normalizedSajaiData) {
    alert('Load a SAJAI file first');
    return;
  }

  try {
    // Store normalized SAJAI data in localStorage with unique session ID
    const sessionId = 'session_' + Date.now();

    // Store normalized data so popout doesn't need to normalize again
    const popoutData = {
      ...normalizedSajaiData,
      metadata: {
        ...(normalizedSajaiData.metadata || {}),
        originalFormat: currentSajaiData.format || 'SAJAI',
        sessionId: sessionId
      }
    };

    localStorage.setItem('popout3d_sajai', JSON.stringify(popoutData));
    localStorage.setItem('popout3d_session', sessionId);

    // Open pop-out window
    const win = window.open(
      '/popout3DView.html?session=' + sessionId,
      '3D_View_' + sessionId,
      'width=1400,height=900,menubar=no,toolbar=no,location=no,status=no'
    );

    if (!win) {
      alert('Pop-up blocked. Please allow pop-ups for this site.');
      return;
    }

    console.log('Opened 3D view pop-out window with session:', sessionId);
  } catch (error) {
    console.error('Failed to open 3D view pop-out:', error);
    alert('Failed to open 3D view: ' + error.message);
  }
};

(async function init(){
  console.log('[INIT] Starting application initialization...');
  try {
    console.log('[INIT] Refreshing pair files...');
    await refreshPairFiles();

    console.log('[INIT] Rendering pairs...');
    renderPairs();

    // Load file tree asynchronously in the background (non-blocking)
    // Page is immediately interactive while tree loads
    console.log('[INIT] Starting background file tree load...');
    refreshFileTree().catch(e => {
      console.error('[INIT] Background file tree load failed:', e);
    });

    // Initialize 3D view
    console.log('[INIT] Initializing 3D view...');
    init3DView();

    console.log('[INIT] Application initialized successfully!');
  } catch (e) {
    console.error('[INIT] Initialization failed:', e);
  }
})();
