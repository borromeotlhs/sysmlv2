/**
 * SAJAI Three.js Renderer
 *
 * Renders SAJAI 3D scene data using Three.js:
 * - Parts as 3D boxes
 * - Ports as half-spheres/domes on part surfaces
 * - Connectors as lines or tubes
 * - Interactive selection, visibility toggles, orbit controls
 *
 * Vanilla JS, no build system required.
 */

class SajaiThreeRenderer {
  constructor() {
    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.controls = null;
    this.raycaster = null;
    this.mouse = null;

    this.sajai = null;
    this.container = null;

    // Object maps for quick lookup
    this.partMeshes = new Map(); // sajaiId -> mesh
    this.portMeshes = new Map(); // sajaiId -> mesh
    this.connectorObjects = new Map(); // sajaiId -> line/tube

    // Selection state
    this.selectedObject = null;
    this.highlightMaterial = null;

    // Visibility state
    this.visibility = {
      parts: true,
      ports: true,
      connectors: true,
      labels: false
    };

    // Animation
    this.animationId = null;
  }

  /**
   * Initialize the renderer
   * @param {HTMLElement} containerElement - DOM element to render into
   * @param {Object} sajai - SAJAI instance reference
   */
  init(containerElement, sajai) {
    this.container = containerElement;
    this.sajai = sajai;

    // Setup scene
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0xf0f0f0);

    // Setup camera
    const width = containerElement.clientWidth;
    const height = containerElement.clientHeight;
    this.camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 10000);
    this.camera.position.set(50, 50, 50);
    this.camera.lookAt(0, 0, 0);

    // Setup renderer
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    containerElement.appendChild(this.renderer.domElement);

    // Setup lights
    this._setupLights();

    // Setup controls (requires THREE.OrbitControls to be loaded)
    if (typeof THREE.OrbitControls !== 'undefined') {
      this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
      this.controls.enableDamping = true;
      this.controls.dampingFactor = 0.05;
      this.controls.screenSpacePanning = false;
      this.controls.minDistance = 10;
      this.controls.maxDistance = 500;
      this.controls.maxPolarAngle = Math.PI / 2;
    }

    // Setup raycaster for picking
    this.raycaster = new THREE.Raycaster();
    this.mouse = new THREE.Vector2();

    // Setup highlight material
    this.highlightMaterial = new THREE.MeshPhongMaterial({
      color: 0xffff00,
      emissive: 0x444400,
      shininess: 30,
      transparent: true,
      opacity: 0.8
    });

    // Event listeners
    this.renderer.domElement.addEventListener('click', this._onMouseClick.bind(this), false);
    this.renderer.domElement.addEventListener('mousemove', this._onMouseMove.bind(this), false);
    window.addEventListener('resize', this._onWindowResize.bind(this), false);

    // Start render loop
    this._animate();

    console.log('SAJAI Three.js renderer initialized');
  }

  /**
   * Setup scene lighting
   * @private
   */
  _setupLights() {
    // Ambient light for general illumination
    const ambientLight = new THREE.AmbientLight(0x404040, 1.5);
    this.scene.add(ambientLight);

    // Directional light for shadows and definition
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(50, 100, 50);
    directionalLight.castShadow = true;
    directionalLight.shadow.camera.left = -100;
    directionalLight.shadow.camera.right = 100;
    directionalLight.shadow.camera.top = 100;
    directionalLight.shadow.camera.bottom = -100;
    directionalLight.shadow.mapSize.width = 2048;
    directionalLight.shadow.mapSize.height = 2048;
    this.scene.add(directionalLight);

    // Additional directional light from opposite side
    const directionalLight2 = new THREE.DirectionalLight(0xffffff, 0.4);
    directionalLight2.position.set(-50, 50, -50);
    this.scene.add(directionalLight2);

    // Hemisphere light for soft gradient
    const hemisphereLight = new THREE.HemisphereLight(0xffffff, 0x444444, 0.3);
    this.scene.add(hemisphereLight);
  }

  /**
   * Load and render a scene from SAJAI data
   * @param {Object} sceneData - Scene data with parts, ports, connectors
   */
  loadScene(sceneData) {
    try {
      // Clear existing scene
      this.clear();

      if (!sceneData) {
        console.warn('No scene data provided');
        return;
      }

      // Render parts
      if (sceneData.parts && Array.isArray(sceneData.parts)) {
        sceneData.parts.forEach(part => this._renderPart(part));
      }

      // Render ports (after parts, so we can position them on part surfaces)
      if (sceneData.ports && Array.isArray(sceneData.ports)) {
        sceneData.ports.forEach(port => this._renderPort(port));
      }

      // Render connectors (after parts and ports exist)
      if (sceneData.connectors && Array.isArray(sceneData.connectors)) {
        sceneData.connectors.forEach(connector => this._renderConnector(connector));
      }

      // Auto-frame scene
      this._frameScene();

      console.log(`Scene loaded: ${this.partMeshes.size} parts, ${this.portMeshes.size} ports, ${this.connectorObjects.size} connectors`);
    } catch (error) {
      console.error('Error loading scene:', error);
    }
  }

  /**
   * Render a part as a 3D box
   * @private
   * @param {Object} part - Part data with position, size, color, etc.
   */
  _renderPart(part) {
    // NOTE: This renderer supports superposition - multiple parts may have identical
    // positions. They will render naturally with later elements appearing on top.
    // Transparency/opacity can be used to show nested/layered structures.
    try {
      // Extract dimensions (handle both array [w,h,d] and object {width,height,depth} formats)
      let width, height, depth;
      if (Array.isArray(part.size)) {
        width = part.size[0] || 10;
        height = part.size[1] || 10;
        depth = part.size[2] || 10;
      } else {
        width = part.size?.width || part.width || 10;
        height = part.size?.height || part.height || 10;
        depth = part.size?.depth || part.depth || 10;
      }

      // Create box geometry
      const geometry = new THREE.BoxGeometry(width, height, depth);

      // Create solid material (not wireframe)
      const color = part.color ? this._parseColor(part.color) : 0x4A90E2;
      const opacity = part.opacity !== undefined ? part.opacity : 0.9;
      const material = new THREE.MeshPhongMaterial({
        color: color,
        transparent: opacity < 1.0,
        opacity: opacity,
        shininess: 30,
        side: THREE.FrontSide,
        wireframe: false
      });

      // Create mesh
      const mesh = new THREE.Mesh(geometry, material);

      // Set position (handle both array [x,y,z] and object {x,y,z} formats)
      if (part.position) {
        if (Array.isArray(part.position)) {
          mesh.position.set(
            part.position[0] || 0,
            part.position[1] || 0,
            part.position[2] || 0
          );
        } else {
          mesh.position.set(
            part.position.x || 0,
            part.position.y || 0,
            part.position.z || 0
          );
        }
      }

      // Store reference to SAJAI data
      mesh.userData = {
        type: 'part',
        sajaiId: part.id,
        sajaiData: part,
        originalMaterial: material
      };

      // Enable shadows
      mesh.castShadow = true;
      mesh.receiveShadow = true;

      // Add to scene
      this.scene.add(mesh);
      this.partMeshes.set(part.id, mesh);

      // Apply visibility
      mesh.visible = this.visibility.parts;

    } catch (error) {
      console.error('Error rendering part:', part, error);
    }
  }

  /**
   * Render a port as a sphere on part surface
   * @private
   * @param {Object} port - Port data with parent part, surface, position
   */
  _renderPort(port) {
    try {
      // Find parent part mesh (flexible field names)
      const parentId = port.ownerPartId || port.parentId || port.partId;
      const parentMesh = this.partMeshes.get(parentId);
      if (!parentMesh) {
        console.warn('Port parent part not found:', parentId);
        return;
      }

      // Create full sphere geometry (proxy ports as spheres that protrude from parent)
      const radius = port.radius || 0.4;
      const geometry = new THREE.SphereGeometry(radius, 16, 16);

      // Create material with solid appearance
      const color = port.color ? this._parseColor(port.color) : 0xFF6B6B;
      const material = new THREE.MeshPhongMaterial({
        color: color,
        shininess: 60,
        emissive: color,
        emissiveIntensity: 0.2
      });

      // Create mesh
      const mesh = new THREE.Mesh(geometry, material);

      // Position on parent surface (sphere will intersect/protrude from the box)
      const position = this._calculatePortPosition(port, parentMesh);
      mesh.position.copy(position);

      // Store reference
      mesh.userData = {
        type: 'port',
        sajaiId: port.id,
        sajaiData: port,
        originalMaterial: material
      };

      // Add to scene
      this.scene.add(mesh);
      this.portMeshes.set(port.id, mesh);

      // Apply visibility
      mesh.visible = this.visibility.ports;

    } catch (error) {
      console.error('Error rendering port:', port, error);
    }
  }

  /**
   * Calculate port position on part surface
   * @private
   */
  _calculatePortPosition(port, parentMesh) {
    const parentPos = parentMesh.position;
    const partData = parentMesh.userData.sajaiData;

    // Handle both array and object formats for size
    let width, height, depth;
    if (Array.isArray(partData.size)) {
      width = partData.size[0] || 10;
      height = partData.size[1] || 10;
      depth = partData.size[2] || 10;
    } else {
      width = partData.size?.width || partData.width || 10;
      height = partData.size?.height || partData.height || 10;
      depth = partData.size?.depth || partData.depth || 10;
    }

    const pos = new THREE.Vector3(parentPos.x, parentPos.y, parentPos.z);

    // Use surface name if provided
    const surface = (port.surface || '').toLowerCase();

    // Handle both array [u,v] and object {u,v} formats for UV
    let u, v;
    if (Array.isArray(port.uv)) {
      u = port.uv[0] || 0.5;
      v = port.uv[1] || 0.5;
    } else {
      u = port.u || port.uv?.u || 0.5;
      v = port.v || port.uv?.v || 0.5;
    }

    // Map UV coordinates to surface position
    switch (surface) {
      case 'top':
        pos.x += (u - 0.5) * width;
        pos.y += height / 2;
        pos.z += (v - 0.5) * depth;
        break;
      case 'bottom':
        pos.x += (u - 0.5) * width;
        pos.y -= height / 2;
        pos.z += (v - 0.5) * depth;
        break;
      case 'front':
        pos.x += (u - 0.5) * width;
        pos.y += (v - 0.5) * height;
        pos.z += depth / 2;
        break;
      case 'back':
        pos.x += (u - 0.5) * width;
        pos.y += (v - 0.5) * height;
        pos.z -= depth / 2;
        break;
      case 'left':
        pos.x -= width / 2;
        pos.y += (v - 0.5) * height;
        pos.z += (u - 0.5) * depth;
        break;
      case 'right':
        pos.x += width / 2;
        pos.y += (v - 0.5) * height;
        pos.z += (u - 0.5) * depth;
        break;
      default:
        // Default to top surface
        pos.x += (u - 0.5) * width;
        pos.y += height / 2;
        pos.z += (v - 0.5) * depth;
    }

    return pos;
  }

  /**
   * Calculate surface normal vector
   * @private
   */
  _calculateSurfaceNormal(surface, parentMesh) {
    const normal = new THREE.Vector3(0, 1, 0); // default: up

    switch ((surface || '').toLowerCase()) {
      case 'top':
        normal.set(0, 1, 0);
        break;
      case 'bottom':
        normal.set(0, -1, 0);
        break;
      case 'front':
        normal.set(0, 0, 1);
        break;
      case 'back':
        normal.set(0, 0, -1);
        break;
      case 'left':
        normal.set(-1, 0, 0);
        break;
      case 'right':
        normal.set(1, 0, 0);
        break;
    }

    return normal;
  }

  /**
   * Render a connector as line or tube
   * @private
   * @param {Object} connector - Connector data with endpoints and route
   */
  _renderConnector(connector) {
    try {
      // Get endpoint positions
      const fromPort = this.portMeshes.get(connector.fromPortId);
      const toPort = this.portMeshes.get(connector.toPortId);

      if (!fromPort || !toPort) {
        console.warn('Connector endpoint ports not found:', connector);
        return;
      }

      const fromPos = fromPort.position;
      const toPos = toPort.position;

      // Build path points
      const points = [fromPos.clone()];

      // Add route points if present
      if (connector.route && Array.isArray(connector.route)) {
        connector.route.forEach(pt => {
          points.push(new THREE.Vector3(pt.x || 0, pt.y || 0, pt.z || 0));
        });
      }

      points.push(toPos.clone());

      // Create line or tube
      let connectorObject;
      const color = connector.color ? this._parseColor(connector.color) : 0x333333;

      if (connector.renderAsTube || points.length > 2) {
        // Render as tube for complex paths
        const path = new THREE.CatmullRomCurve3(points);
        const tubeGeometry = new THREE.TubeGeometry(path, points.length * 4, 0.3, 8, false);
        const tubeMaterial = new THREE.MeshPhongMaterial({ color: color });
        connectorObject = new THREE.Mesh(tubeGeometry, tubeMaterial);
        connectorObject.castShadow = true;
      } else {
        // Render as simple line
        const lineGeometry = new THREE.BufferGeometry().setFromPoints(points);
        const lineMaterial = new THREE.LineBasicMaterial({
          color: color,
          linewidth: 2
        });
        connectorObject = new THREE.Line(lineGeometry, lineMaterial);
      }

      // Store reference
      connectorObject.userData = {
        type: 'connector',
        sajaiId: connector.id,
        sajaiData: connector,
        originalMaterial: connectorObject.material
      };

      // Add to scene
      this.scene.add(connectorObject);
      this.connectorObjects.set(connector.id, connectorObject);

      // Apply visibility
      connectorObject.visible = this.visibility.connectors;

      // Add arrow/direction indicator if appropriate
      if (connector.showDirection) {
        this._addDirectionArrow(connectorObject, fromPos, toPos);
      }

    } catch (error) {
      console.error('Error rendering connector:', connector, error);
    }
  }

  /**
   * Add direction arrow to connector
   * @private
   */
  _addDirectionArrow(connectorObject, fromPos, toPos) {
    const direction = new THREE.Vector3().subVectors(toPos, fromPos).normalize();
    const midpoint = new THREE.Vector3().lerpVectors(fromPos, toPos, 0.7);

    const arrowHelper = new THREE.ArrowHelper(
      direction,
      midpoint,
      5,
      0x333333,
      2,
      1.5
    );

    arrowHelper.userData = { type: 'arrow', parent: connectorObject };
    this.scene.add(arrowHelper);
  }

  /**
   * Parse color from various formats
   * @private
   */
  _parseColor(color) {
    if (typeof color === 'number') {
      return color;
    }
    if (typeof color === 'string') {
      if (color.startsWith('#')) {
        return parseInt(color.substring(1), 16);
      }
      if (color.startsWith('0x')) {
        return parseInt(color, 16);
      }
    }
    if (color.r !== undefined && color.g !== undefined && color.b !== undefined) {
      return (color.r << 16) | (color.g << 8) | color.b;
    }
    return 0x4A90E2; // default blue
  }

  /**
   * Handle mouse click for selection
   * @private
   */
  _onMouseClick(event) {
    // Calculate mouse position in normalized device coordinates
    const rect = this.renderer.domElement.getBoundingClientRect();
    this.mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    this.mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    // Update raycaster
    this.raycaster.setFromCamera(this.mouse, this.camera);

    // Get all pickable objects
    const pickableObjects = [
      ...Array.from(this.partMeshes.values()),
      ...Array.from(this.portMeshes.values()),
      ...Array.from(this.connectorObjects.values())
    ];

    // Check for intersections
    const intersects = this.raycaster.intersectObjects(pickableObjects, true);

    if (intersects.length > 0) {
      const picked = intersects[0].object;
      this._selectObject(picked);
    } else {
      this._deselectObject();
    }
  }

  /**
   * Handle mouse move for hover effects
   * @private
   */
  _onMouseMove(event) {
    // Update cursor based on hover
    const rect = this.renderer.domElement.getBoundingClientRect();
    this.mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    this.mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    this.raycaster.setFromCamera(this.mouse, this.camera);

    const pickableObjects = [
      ...Array.from(this.partMeshes.values()),
      ...Array.from(this.portMeshes.values()),
      ...Array.from(this.connectorObjects.values())
    ];

    const intersects = this.raycaster.intersectObjects(pickableObjects, true);

    if (intersects.length > 0) {
      this.renderer.domElement.style.cursor = 'pointer';
    } else {
      this.renderer.domElement.style.cursor = 'default';
    }
  }

  /**
   * Select an object
   * @private
   */
  _selectObject(object) {
    // Deselect previous
    if (this.selectedObject) {
      this._deselectObject();
    }

    // Highlight selected object
    this.selectedObject = object;

    if (object.userData.originalMaterial) {
      object.material = this.highlightMaterial.clone();
      object.material.color = new THREE.Color(0xffff00);
    }

    // Emit selection event (if SAJAI provides event system)
    if (this.sajai && this.sajai.emit) {
      this.sajai.emit('element-selected', {
        type: object.userData.type,
        id: object.userData.sajaiId,
        data: object.userData.sajaiData
      });
    }

    console.log('Selected:', object.userData.type, object.userData.sajaiId);
  }

  /**
   * Deselect current object
   * @private
   */
  _deselectObject() {
    if (this.selectedObject) {
      // Restore original material
      if (this.selectedObject.userData.originalMaterial) {
        this.selectedObject.material = this.selectedObject.userData.originalMaterial;
      }

      this.selectedObject = null;

      // Emit deselection event
      if (this.sajai && this.sajai.emit) {
        this.sajai.emit('element-deselected');
      }
    }
  }

  /**
   * Get currently selected element data
   * @returns {Object|null} Selected element data or null
   */
  getSelectedElement() {
    if (this.selectedObject) {
      return {
        type: this.selectedObject.userData.type,
        id: this.selectedObject.userData.sajaiId,
        data: this.selectedObject.userData.sajaiData
      };
    }
    return null;
  }

  /**
   * Set visibility for element types
   * @param {string} type - Element type ('parts', 'ports', 'connectors', 'labels')
   * @param {boolean} visible - Visibility state
   */
  setVisibility(type, visible) {
    console.log(`[Renderer] setVisibility(${type}, ${visible})`);
    this.visibility[type] = visible;

    switch (type) {
      case 'parts':
        console.log(`[Renderer] Setting ${this.partMeshes.size} parts to visible=${visible}`);
        this.partMeshes.forEach(mesh => {
          mesh.visible = visible;
        });
        break;
      case 'ports':
        console.log(`[Renderer] Setting ${this.portMeshes.size} ports to visible=${visible}`);
        this.portMeshes.forEach(mesh => {
          mesh.visible = visible;
        });
        break;
      case 'connectors':
        console.log(`[Renderer] Setting ${this.connectorObjects.size} connectors to visible=${visible}`);
        this.connectorObjects.forEach(obj => {
          obj.visible = visible;
        });
        // Also hide arrows
        this.scene.children.forEach(child => {
          if (child.userData.type === 'arrow') {
            child.visible = visible;
          }
        });
        break;
      case 'labels':
        // Label implementation would go here
        console.log('Label visibility not yet implemented');
        break;
    }
  }

  /**
   * Update positions of parts (and cascade to ports/connectors)
   * @param {Object} updates - Map of partId -> new position
   */
  updatePositions(updates) {
    if (!updates || typeof updates !== 'object') {
      return;
    }

    Object.keys(updates).forEach(partId => {
      const mesh = this.partMeshes.get(partId);
      if (mesh && updates[partId]) {
        const pos = updates[partId];
        mesh.position.set(
          pos.x !== undefined ? pos.x : mesh.position.x,
          pos.y !== undefined ? pos.y : mesh.position.y,
          pos.z !== undefined ? pos.z : mesh.position.z
        );

        // Update ports on this part
        this.portMeshes.forEach((portMesh, portId) => {
          const portData = portMesh.userData.sajaiData;
          const portParentId = portData.ownerPartId || portData.parentId || portData.partId;
          if (portParentId === partId) {
            const newPos = this._calculatePortPosition(portData, mesh);
            portMesh.position.copy(newPos);
          }
        });

        // Update connectors connected to ports on this part
        this._updateConnectors();
      }
    });
  }

  /**
   * Update connector geometries based on current port positions
   * @private
   */
  _updateConnectors() {
    this.connectorObjects.forEach((connectorObj, connectorId) => {
      const connectorData = connectorObj.userData.sajaiData;
      const fromPort = this.portMeshes.get(connectorData.fromPortId);
      const toPort = this.portMeshes.get(connectorData.toPortId);

      if (fromPort && toPort) {
        // Rebuild geometry with new positions
        const points = [fromPort.position.clone()];

        if (connectorData.route && Array.isArray(connectorData.route)) {
          connectorData.route.forEach(pt => {
            points.push(new THREE.Vector3(pt.x || 0, pt.y || 0, pt.z || 0));
          });
        }

        points.push(toPort.position.clone());

        // Update geometry
        if (connectorObj.geometry) {
          connectorObj.geometry.dispose();
        }

        if (connectorObj.type === 'Mesh') {
          const path = new THREE.CatmullRomCurve3(points);
          connectorObj.geometry = new THREE.TubeGeometry(path, points.length * 4, 0.3, 8, false);
        } else {
          connectorObj.geometry = new THREE.BufferGeometry().setFromPoints(points);
        }
      }
    });
  }

  /**
   * Frame the camera to show all objects in scene
   * @private
   */
  _frameScene() {
    if (this.partMeshes.size === 0) {
      return;
    }

    // Calculate bounding box of all parts
    const box = new THREE.Box3();
    this.partMeshes.forEach(mesh => {
      box.expandByObject(mesh);
    });

    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());
    const maxDim = Math.max(size.x, size.y, size.z);

    // Position camera to see entire scene
    const fov = this.camera.fov * (Math.PI / 180);
    const distance = Math.abs(maxDim / Math.sin(fov / 2)) * 1.5;

    this.camera.position.set(
      center.x + distance * 0.5,
      center.y + distance * 0.7,
      center.z + distance * 0.5
    );

    this.camera.lookAt(center);

    if (this.controls) {
      this.controls.target.copy(center);
      this.controls.update();
    }
  }

  /**
   * Handle window resize
   * @private
   */
  _onWindowResize() {
    if (!this.container || !this.camera || !this.renderer) {
      return;
    }

    const width = this.container.clientWidth;
    const height = this.container.clientHeight;

    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();

    this.renderer.setSize(width, height);
  }

  /**
   * Animation loop
   * @private
   */
  _animate() {
    this.animationId = requestAnimationFrame(this._animate.bind(this));

    // Update controls
    if (this.controls) {
      this.controls.update();
    }

    // Render scene
    if (this.renderer && this.scene && this.camera) {
      this.renderer.render(this.scene, this.camera);
    }
  }

  /**
   * Clear the scene
   */
  clear() {
    // Deselect
    this._deselectObject();

    // Remove all objects from scene
    const objectsToRemove = [
      ...Array.from(this.partMeshes.values()),
      ...Array.from(this.portMeshes.values()),
      ...Array.from(this.connectorObjects.values())
    ];

    objectsToRemove.forEach(obj => {
      if (obj.geometry) {
        obj.geometry.dispose();
      }
      if (obj.material) {
        if (Array.isArray(obj.material)) {
          obj.material.forEach(mat => mat.dispose());
        } else {
          obj.material.dispose();
        }
      }
      this.scene.remove(obj);
    });

    // Remove arrows
    this.scene.children.forEach(child => {
      if (child.userData.type === 'arrow') {
        this.scene.remove(child);
      }
    });

    // Clear maps
    this.partMeshes.clear();
    this.portMeshes.clear();
    this.connectorObjects.clear();
  }

  /**
   * Dispose of all resources and stop rendering
   */
  dispose() {
    // Stop animation
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
      this.animationId = null;
    }

    // Remove event listeners
    if (this.renderer && this.renderer.domElement) {
      this.renderer.domElement.removeEventListener('click', this._onMouseClick.bind(this));
      this.renderer.domElement.removeEventListener('mousemove', this._onMouseMove.bind(this));
    }
    window.removeEventListener('resize', this._onWindowResize.bind(this));

    // Clear scene
    this.clear();

    // Dispose controls
    if (this.controls) {
      this.controls.dispose();
    }

    // Dispose renderer
    if (this.renderer) {
      if (this.container && this.renderer.domElement.parentNode === this.container) {
        this.container.removeChild(this.renderer.domElement);
      }
      this.renderer.dispose();
    }

    // Clear references
    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.controls = null;
    this.raycaster = null;
    this.mouse = null;

    console.log('SAJAI Three.js renderer disposed');
  }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SajaiThreeRenderer;
}
