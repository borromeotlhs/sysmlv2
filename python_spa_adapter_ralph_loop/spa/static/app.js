let architectures = [];
let currentArchitecture = null;
let pairs = [];
let fileTree = null;
let currentPath = '';
let diagramCache = { bdd: null, ibd: null };
let treeRoot = '';
let projectRoot = '';

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

function popoutBdd() {
  if (diagramCache.bdd) {
    const win = window.open('', 'BDD_Diagram', 'width=1200,height=900,menubar=no,toolbar=no,location=no,status=no');
    if (win) {
      const title = currentArchitecture?.name || 'Architecture';
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
              <img src="${escapeHtml(diagramCache.bdd.url)}" alt="Block Definition Diagram" id="diagram" />
            </div>
          </div>
          <script>
            let zoom = 1.0;
            const wrapper = document.getElementById('wrapper');
            const container = document.getElementById('container');
            const zoomLevel = document.getElementById('zoomLevel');

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
  } else {
    alert('Load the BDD first by clicking the BDD tab');
  }
}

function popoutIbd() {
  if (diagramCache.ibd) {
    const win = window.open('', 'IBD_Diagram', 'width=1200,height=900,menubar=no,toolbar=no,location=no,status=no');
    if (win) {
      const title = currentArchitecture?.name || 'Architecture';
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
              <img src="${escapeHtml(diagramCache.ibd.url)}" alt="Internal Block Diagram" id="diagram" />
            </div>
          </div>
          <script>
            let zoom = 1.0;
            const wrapper = document.getElementById('wrapper');
            const container = document.getElementById('container');
            const zoomLevel = document.getElementById('zoomLevel');

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
  } else {
    alert('Load the IBD first by clicking the IBD tab');
  }
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
  const url = root ? `/api/tree?root=${encodeURIComponent(root)}` : '/api/tree';
  try {
    fileTree = await getJson(url);
    treeRoot = fileTree.resolved_path || '';
    if (!projectRoot) projectRoot = treeRoot; // Store initial project root
    renderFileTree();
  } catch (e) {
    alert('Failed to load directory tree: ' + e.message);
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

(async function init(){
  await refreshPairFiles();
  await refreshFileTree();
  renderPairs();
})();
