/**
 * sajaiSceneNormalizer.js
 *
 * Normalize flexible SAJAI schema to a consistent internal format.
 *
 * SAJAI is intentionally flexible to support various emitters and use cases.
 * This normalizer handles variations in field names and provides sensible defaults
 * for missing optional fields.
 *
 * Field name flexibility examples:
 * - "position" vs "pos" vs "location" vs "transform.position"
 * - "scenes" vs "scene" vs "sceneList"
 * - "parts" vs "elements" vs "blocks" vs "components"
 * - "ports" vs "interfaces" vs "proxies" vs "proxyPorts"
 * - "connectors" vs "connections" vs "links" vs "edges"
 *
 * Normalized internal scene format:
 * {
 *   scenes: [{
 *     id: string,
 *     name: string,
 *     contextBlockId: string,
 *     parts: [...],
 *     ports: [...],
 *     connectors: [...],
 *     camera: {...},
 *     metadata: {...}
 *   }],
 *   parts: [{
 *     id: string,
 *     name: string,
 *     sysmlRef: string,
 *     qualifiedName: string,
 *     type: string,
 *     owner: string,
 *     position: [x, y, z],
 *     size: [x, y, z],
 *     color: string,
 *     opacity: number,
 *     visible: boolean,
 *     metadata: {...}
 *   }],
 *   ports: [{
 *     id: string,
 *     name: string,
 *     sysmlRef: string,
 *     ownerPartId: string,
 *     type: string,
 *     surface: string,
 *     uv: [u, v],
 *     radius: number,
 *     color: string,
 *     visible: boolean,
 *     connectedPortIds: [...],
 *     metadata: {...}
 *   }],
 *   connectors: [{
 *     id: string,
 *     name: string,
 *     sysmlRef: string,
 *     sourcePortId: string,
 *     targetPortId: string,
 *     route: [...],
 *     color: string,
 *     visible: boolean,
 *     metadata: {...}
 *   }]
 * }
 */

const SajaiSceneNormalizer = {
  /**
   * Normalize raw SAJAI data to internal format
   * @param {Object} rawSajai - Raw parsed SAJAI data
   * @returns {Object} Normalized scene data
   */
  normalize(rawSajai) {
    if (!rawSajai || typeof rawSajai !== 'object') {
      throw new Error('Invalid SAJAI data: expected object');
    }

    // Extract scenes (flexible field names)
    const rawScenes = this._getField(rawSajai, ['scenes', 'scene', 'sceneList']);

    // Handle different scenes structures:
    // 1. Array of scenes: [{...}, {...}]
    // 2. Single scene object: {...}
    // 3. Named scenes object: {"scene1": {...}, "scene2": {...}}
    let sceneArray;
    if (Array.isArray(rawScenes)) {
      sceneArray = rawScenes;
    } else if (rawScenes && typeof rawScenes === 'object') {
      // Check if this is a scene object (has id, name, parts, etc.) or a container of scenes
      if (rawScenes.id || rawScenes.sceneId || rawScenes.parts || rawScenes.elements) {
        // Single scene object
        sceneArray = [rawScenes];
      } else {
        // Named scenes object - extract values
        sceneArray = Object.values(rawScenes);
      }
    } else {
      sceneArray = [];
    }

    if (sceneArray.length === 0) {
      throw new Error('No scenes found in SAJAI data');
    }

    // Normalize each scene
    const normalizedScenes = sceneArray.map((scene, index) => this._normalizeScene(scene, index));

    return {
      scenes: normalizedScenes,
      metadata: rawSajai.metadata || rawSajai.meta || rawSajai.info || {},
      version: rawSajai.version || rawSajai.sajaiVersion || '1.0'
    };
  },

  /**
   * Normalize a single scene
   * @private
   */
  _normalizeScene(rawScene, index) {
    const scene = {
      id: this._getField(rawScene, ['id', 'sceneId', 'sceneID']) || `scene_${index}`,
      name: this._getField(rawScene, ['name', 'sceneName', 'label']) || `Scene ${index}`,
      contextBlockId: this._getField(rawScene, ['contextBlockId', 'contextRef', 'context', 'blockId']),
      parts: [],
      ports: [],
      connectors: [],
      camera: this._normalizeCamera(rawScene.camera),
      metadata: this._extractMetadata(rawScene)
    };

    // Normalize parts
    const rawParts = this._getField(rawScene, ['parts', 'elements', 'blocks', 'components']) || [];
    scene.parts = rawParts.map((part, i) => this._normalizePart(part, i, scene.id));

    // Normalize ports
    const rawPorts = this._getField(rawScene, ['ports', 'interfaces', 'proxies', 'proxyPorts']) || [];
    scene.ports = rawPorts.map((port, i) => this._normalizePort(port, i, scene.id));

    // Normalize connectors
    const rawConnectors = this._getField(rawScene, ['connectors', 'connections', 'links', 'edges']) || [];
    scene.connectors = rawConnectors.map((conn, i) => this._normalizeConnector(conn, i, scene.id));

    return scene;
  },

  /**
   * Normalize a part (3D box)
   * @private
   *
   * NOTE: Multiple parts MAY have identical positions (superposition).
   * This is valid for hierarchical/nested representations.
   * No position uniqueness validation is performed.
   */
  _normalizePart(rawPart, index, sceneId) {
    // Position: flexible field names and formats
    const position = this._normalizeVector3(
      this._getField(rawPart, ['position', 'pos', 'location', 'transform.position', 'xyz']),
      [0, 0, 0]
    );

    // Size: flexible field names and formats
    const size = this._normalizeVector3(
      this._getField(rawPart, ['size', 'dimensions', 'scale', 'extent', 'bounds']),
      [1, 1, 1]
    );

    // Color: flexible formats (hex, rgb, rgba, name)
    const color = this._normalizeColor(
      this._getField(rawPart, ['color', 'colour', 'fill', 'fillColor'])
    );

    return {
      id: this._getField(rawPart, ['id', 'partId', 'elementId']) || `part_${sceneId}_${index}`,
      name: this._getField(rawPart, ['name', 'label', 'title']) || `Part ${index}`,
      sysmlRef: this._getField(rawPart, ['sysmlRef', 'ref', 'reference', 'sysmlId', 'elementRef']),
      qualifiedName: this._getField(rawPart, ['qualifiedName', 'qname', 'fqn', 'fullName']),
      type: this._getField(rawPart, ['type', 'kind', 'elementType', 'blockType']),
      owner: this._getField(rawPart, ['owner', 'parent', 'ownerId', 'parentId']),
      position: position,
      size: size,
      color: color,
      opacity: this._normalizeNumber(this._getField(rawPart, ['opacity', 'alpha', 'transparency']), 1.0, 0.0, 1.0),
      visible: this._normalizeBoolean(this._getField(rawPart, ['visible', 'shown', 'display']), true),
      metadata: this._extractMetadata(rawPart)
    };
  },

  /**
   * Normalize a port (surface nodule/dome)
   * @private
   */
  _normalizePort(rawPort, index, sceneId) {
    // UV coordinates for surface placement
    const uv = this._normalizeVector2(
      this._getField(rawPort, ['uv', 'surfaceUV', 'coords', 'surfaceCoords']),
      [0.5, 0.5]
    );

    return {
      id: this._getField(rawPort, ['id', 'portId', 'interfaceId']) || `port_${sceneId}_${index}`,
      name: this._getField(rawPort, ['name', 'label', 'title']) || `Port ${index}`,
      sysmlRef: this._getField(rawPort, ['sysmlRef', 'ref', 'reference', 'sysmlId', 'elementRef']),
      ownerPartId: this._getField(rawPort, ['ownerPartId', 'owner', 'parentId', 'partId', 'parent']),
      type: this._getField(rawPort, ['type', 'kind', 'portType', 'interfaceType']),
      surface: this._getField(rawPort, ['surface', 'face', 'side', 'surfaceName']) || 'front',
      uv: uv,
      radius: this._normalizeNumber(this._getField(rawPort, ['radius', 'size', 'scale']), 0.1, 0.01, 1.0),
      color: this._normalizeColor(this._getField(rawPort, ['color', 'colour', 'fill', 'fillColor'])),
      visible: this._normalizeBoolean(this._getField(rawPort, ['visible', 'shown', 'display']), true),
      connectedPortIds: this._normalizeArray(this._getField(rawPort, ['connectedPortIds', 'connections', 'connected', 'links'])),
      metadata: this._extractMetadata(rawPort)
    };
  },

  /**
   * Normalize a connector (line/curve between ports)
   * @private
   */
  _normalizeConnector(rawConn, index, sceneId) {
    // Route can be array of points or empty for direct connection
    const route = this._normalizeRoute(
      this._getField(rawConn, ['route', 'path', 'points', 'waypoints', 'routePoints'])
    );

    return {
      id: this._getField(rawConn, ['id', 'connectorId', 'connectionId', 'linkId']) || `conn_${sceneId}_${index}`,
      name: this._getField(rawConn, ['name', 'label', 'title']) || `Connector ${index}`,
      sysmlRef: this._getField(rawConn, ['sysmlRef', 'ref', 'reference', 'sysmlId', 'elementRef']),
      sourcePortId: this._getField(rawConn, ['sourcePortId', 'source', 'from', 'fromPort', 'startPort']),
      targetPortId: this._getField(rawConn, ['targetPortId', 'target', 'to', 'toPort', 'endPort']),
      route: route,
      color: this._normalizeColor(this._getField(rawConn, ['color', 'colour', 'stroke', 'strokeColor'])),
      visible: this._normalizeBoolean(this._getField(rawConn, ['visible', 'shown', 'display']), true),
      metadata: this._extractMetadata(rawConn)
    };
  },

  /**
   * Normalize camera settings
   * @private
   */
  _normalizeCamera(rawCamera) {
    if (!rawCamera || typeof rawCamera !== 'object') {
      return {
        position: [10, 10, 10],
        target: [0, 0, 0],
        up: [0, 1, 0],
        fov: 50
      };
    }

    return {
      position: this._normalizeVector3(
        this._getField(rawCamera, ['position', 'pos', 'eye']),
        [10, 10, 10]
      ),
      target: this._normalizeVector3(
        this._getField(rawCamera, ['target', 'lookAt', 'center']),
        [0, 0, 0]
      ),
      up: this._normalizeVector3(
        this._getField(rawCamera, ['up', 'upVector']),
        [0, 1, 0]
      ),
      fov: this._normalizeNumber(
        this._getField(rawCamera, ['fov', 'fieldOfView', 'fovy']),
        50, 10, 120
      )
    };
  },

  /**
   * Normalize a 3D vector [x, y, z]
   * Handles: arrays, objects {x,y,z}, comma-separated strings
   * @private
   */
  _normalizeVector3(value, defaultValue = [0, 0, 0]) {
    if (!value) return defaultValue;

    // Array format: [x, y, z]
    if (Array.isArray(value)) {
      if (value.length >= 3) {
        return [
          this._normalizeNumber(value[0], defaultValue[0]),
          this._normalizeNumber(value[1], defaultValue[1]),
          this._normalizeNumber(value[2], defaultValue[2])
        ];
      }
      return defaultValue;
    }

    // Object format: {x, y, z}
    if (typeof value === 'object') {
      if ('x' in value && 'y' in value && 'z' in value) {
        return [
          this._normalizeNumber(value.x, defaultValue[0]),
          this._normalizeNumber(value.y, defaultValue[1]),
          this._normalizeNumber(value.z, defaultValue[2])
        ];
      }
    }

    // String format: "x,y,z"
    if (typeof value === 'string') {
      const parts = value.split(',').map(s => parseFloat(s.trim()));
      if (parts.length >= 3 && parts.every(n => !isNaN(n))) {
        return parts.slice(0, 3);
      }
    }

    return defaultValue;
  },

  /**
   * Normalize a 2D vector [u, v]
   * @private
   */
  _normalizeVector2(value, defaultValue = [0, 0]) {
    if (!value) return defaultValue;

    // Array format: [u, v]
    if (Array.isArray(value)) {
      if (value.length >= 2) {
        return [
          this._normalizeNumber(value[0], defaultValue[0]),
          this._normalizeNumber(value[1], defaultValue[1])
        ];
      }
      return defaultValue;
    }

    // Object format: {u, v} or {x, y}
    if (typeof value === 'object') {
      if ('u' in value && 'v' in value) {
        return [
          this._normalizeNumber(value.u, defaultValue[0]),
          this._normalizeNumber(value.v, defaultValue[1])
        ];
      }
      if ('x' in value && 'y' in value) {
        return [
          this._normalizeNumber(value.x, defaultValue[0]),
          this._normalizeNumber(value.y, defaultValue[1])
        ];
      }
    }

    // String format: "u,v"
    if (typeof value === 'string') {
      const parts = value.split(',').map(s => parseFloat(s.trim()));
      if (parts.length >= 2 && parts.every(n => !isNaN(n))) {
        return parts.slice(0, 2);
      }
    }

    return defaultValue;
  },

  /**
   * Normalize color to hex string
   * Handles: hex strings, rgb/rgba strings, color names, objects {r,g,b}
   * @private
   */
  _normalizeColor(value) {
    if (!value) return '#808080'; // Default gray

    // Already hex string
    if (typeof value === 'string' && value.startsWith('#')) {
      return value;
    }

    // RGB/RGBA string: "rgb(255,0,0)" or "rgba(255,0,0,1)"
    if (typeof value === 'string' && (value.startsWith('rgb(') || value.startsWith('rgba('))) {
      return value;
    }

    // Color name string: "red", "blue", etc.
    if (typeof value === 'string') {
      return value;
    }

    // Object format: {r, g, b} or {r, g, b, a}
    if (typeof value === 'object' && 'r' in value && 'g' in value && 'b' in value) {
      const r = Math.round(this._normalizeNumber(value.r, 128, 0, 255));
      const g = Math.round(this._normalizeNumber(value.g, 128, 0, 255));
      const b = Math.round(this._normalizeNumber(value.b, 128, 0, 255));
      return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
    }

    return '#808080'; // Default gray
  },

  /**
   * Normalize connector route to array of [x,y,z] points
   * @private
   */
  _normalizeRoute(value) {
    if (!value) return []; // Empty route means direct connection

    if (Array.isArray(value)) {
      // Array of points
      return value.map(point => this._normalizeVector3(point, [0, 0, 0]));
    }

    return [];
  },

  /**
   * Normalize array field
   * @private
   */
  _normalizeArray(value) {
    if (Array.isArray(value)) return value;
    if (!value) return [];
    // Single value to array
    return [value];
  },

  /**
   * Normalize number with optional range clamping
   * @private
   */
  _normalizeNumber(value, defaultValue = 0, min = -Infinity, max = Infinity) {
    const num = parseFloat(value);
    if (isNaN(num)) return defaultValue;
    return Math.max(min, Math.min(max, num));
  },

  /**
   * Normalize boolean
   * @private
   */
  _normalizeBoolean(value, defaultValue = true) {
    if (typeof value === 'boolean') return value;
    if (value === 'true' || value === '1' || value === 1) return true;
    if (value === 'false' || value === '0' || value === 0) return false;
    return defaultValue;
  },

  /**
   * Get field value by trying multiple possible field names
   * Supports nested paths with dot notation
   * @private
   */
  _getField(obj, names) {
    if (!obj || typeof obj !== 'object') return undefined;

    for (const name of names) {
      // Handle dot notation for nested fields (e.g., "transform.position")
      if (name.includes('.')) {
        const parts = name.split('.');
        let value = obj;
        for (const part of parts) {
          if (value && typeof value === 'object' && part in value) {
            value = value[part];
          } else {
            value = undefined;
            break;
          }
        }
        if (value !== undefined) return value;
      } else {
        // Simple field name
        if (name in obj) return obj[name];
      }
    }

    return undefined;
  },

  /**
   * Extract metadata fields (anything not in standard fields)
   * @private
   */
  _extractMetadata(obj) {
    if (!obj || typeof obj !== 'object') return {};

    // List of known standard fields to exclude from metadata
    const standardFields = new Set([
      'id', 'name', 'type', 'position', 'pos', 'location', 'size', 'dimensions',
      'color', 'colour', 'opacity', 'visible', 'owner', 'parent', 'sysmlRef',
      'qualifiedName', 'surface', 'uv', 'radius', 'connectedPortIds',
      'sourcePortId', 'targetPortId', 'route', 'ownerPartId', 'camera',
      'parts', 'ports', 'connectors', 'elements', 'blocks', 'components',
      'interfaces', 'proxies', 'connections', 'links', 'edges',
      'sceneId', 'contextBlockId', 'scenes', 'scene', 'metadata', 'meta'
    ]);

    const metadata = {};
    for (const [key, value] of Object.entries(obj)) {
      if (!standardFields.has(key)) {
        metadata[key] = value;
      }
    }

    // Include explicit metadata field if present
    if (obj.metadata) {
      Object.assign(metadata, obj.metadata);
    }
    if (obj.meta) {
      Object.assign(metadata, obj.meta);
    }

    return metadata;
  }
};

// For debugging in console
if (typeof window !== 'undefined') {
  window.SajaiSceneNormalizer = SajaiSceneNormalizer;
}
