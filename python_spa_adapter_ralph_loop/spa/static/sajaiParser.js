/**
 * sajaiParser.js
 *
 * Load and parse .sajai (SysML-Aware JSON for Auditing and Introspection) files.
 * SAJAI is a flexible JSON format for 3D SysML visualization geometry and layout.
 *
 * This module handles:
 * - Loading .sajai from URL or file
 * - Basic validation of required fields
 * - Error handling with helpful messages
 *
 * Usage:
 *   const sajai = await SajaiParser.loadFromUrl('/path/to/file.sajai');
 *   const sajai = await SajaiParser.loadFromFile(fileObject);
 *   const isValid = SajaiParser.validate(sajaiData);
 */

const SajaiParser = {
  /**
   * Load and parse a .sajai file from a URL
   * @param {string} url - URL to the .sajai file
   * @returns {Promise<Object>} Parsed SAJAI data
   * @throws {Error} If loading or parsing fails
   */
  async loadFromUrl(url) {
    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error(`Failed to load SAJAI file: HTTP ${response.status} ${response.statusText}`);
      }

      const contentType = response.headers.get('content-type');
      if (contentType && !contentType.includes('application/json') && !contentType.includes('text/plain')) {
        console.warn(`SAJAI file has unexpected content-type: ${contentType}`);
      }

      const text = await response.text();

      if (!text.trim()) {
        throw new Error('SAJAI file is empty');
      }

      let sajaiData;
      try {
        sajaiData = JSON.parse(text);
      } catch (parseError) {
        throw new Error(`Failed to parse SAJAI JSON: ${parseError.message}`);
      }

      // Validate the parsed data
      const validation = this.validate(sajaiData);
      if (!validation.valid) {
        throw new Error(`Invalid SAJAI format: ${validation.errors.join(', ')}`);
      }

      return sajaiData;

    } catch (error) {
      if (error.name === 'TypeError' && error.message.includes('fetch')) {
        throw new Error(`Network error loading SAJAI file: ${error.message}`);
      }
      throw error;
    }
  },

  /**
   * Load and parse a .sajai file from a File object (e.g., from file input)
   * @param {File} file - File object to read
   * @returns {Promise<Object>} Parsed SAJAI data
   * @throws {Error} If loading or parsing fails
   */
  async loadFromFile(file) {
    if (!(file instanceof File)) {
      throw new Error('Invalid input: expected a File object');
    }

    if (!file.name.endsWith('.sajai')) {
      console.warn(`File does not have .sajai extension: ${file.name}`);
    }

    return new Promise((resolve, reject) => {
      const reader = new FileReader();

      reader.onload = (event) => {
        try {
          const text = event.target.result;

          if (!text.trim()) {
            reject(new Error('SAJAI file is empty'));
            return;
          }

          let sajaiData;
          try {
            sajaiData = JSON.parse(text);
          } catch (parseError) {
            reject(new Error(`Failed to parse SAJAI JSON: ${parseError.message}`));
            return;
          }

          // Validate the parsed data
          const validation = this.validate(sajaiData);
          if (!validation.valid) {
            reject(new Error(`Invalid SAJAI format: ${validation.errors.join(', ')}`));
            return;
          }

          resolve(sajaiData);

        } catch (error) {
          reject(error);
        }
      };

      reader.onerror = () => {
        reject(new Error(`Failed to read file: ${reader.error}`));
      };

      reader.readAsText(file);
    });
  },

  /**
   * Validate SAJAI data structure
   * @param {Object} data - Parsed SAJAI data to validate
   * @returns {Object} Validation result with {valid: boolean, errors: string[]}
   */
  validate(data) {
    const errors = [];

    // Check that data is an object
    if (!data || typeof data !== 'object' || Array.isArray(data)) {
      return {
        valid: false,
        errors: ['SAJAI root must be an object']
      };
    }

    // Check for scenes (required field)
    // Flexible: could be 'scenes', 'scene', or 'sceneList'
    const hasScenes = data.scenes || data.scene || data.sceneList;
    if (!hasScenes) {
      errors.push('Missing required field: scenes (or scene/sceneList)');
    } else {
      // Validate scenes structure
      const scenes = this._normalizeFieldName(data, ['scenes', 'scene', 'sceneList']);

      if (Array.isArray(scenes)) {
        if (scenes.length === 0) {
          errors.push('Scenes array is empty');
        } else {
          // Validate each scene
          scenes.forEach((scene, index) => {
            this._validateScene(scene, index, errors);
          });
        }
      } else if (typeof scenes === 'object') {
        // Could be a single scene OR a named scenes object
        // Check if this looks like a scene (has id/sceneId/parts) or a container
        const hasSceneFields = scenes.id || scenes.sceneId || scenes.sceneID ||
                               scenes.parts || scenes.elements || scenes.components;

        if (hasSceneFields) {
          // Single scene object
          this._validateScene(scenes, 0, errors);
        } else {
          // Named scenes object {"sceneName": {...}, ...} - extract values
          const sceneArray = Object.values(scenes);
          if (sceneArray.length === 0) {
            errors.push('Named scenes object is empty');
          } else {
            sceneArray.forEach((scene, index) => {
              this._validateScene(scene, index, errors);
            });
          }
        }
      } else {
        errors.push('Scenes must be an array or object');
      }
    }

    // Check for metadata (optional but recommended)
    const metadata = data.metadata || data.meta || data.info;
    if (metadata && typeof metadata !== 'object') {
      errors.push('Metadata must be an object if present');
    }

    return {
      valid: errors.length === 0,
      errors: errors
    };
  },

  /**
   * Validate a single scene object
   * @private
   */
  _validateScene(scene, index, errors) {
    if (!scene || typeof scene !== 'object') {
      errors.push(`Scene ${index} is not an object`);
      return;
    }

    // Scene should have an ID
    const id = this._normalizeFieldName(scene, ['id', 'sceneId', 'sceneID']);
    if (!id) {
      errors.push(`Scene ${index} is missing an id field`);
    }

    // Scene should have a name (recommended but not required)
    const name = this._normalizeFieldName(scene, ['name', 'sceneName', 'label']);
    if (!name) {
      console.warn(`Scene ${index} is missing a name field (recommended)`);
    }

    // Parts validation (flexible: 'parts', 'elements', 'blocks', 'components')
    const parts = this._normalizeFieldName(scene, ['parts', 'elements', 'blocks', 'components']);
    if (parts && !Array.isArray(parts)) {
      errors.push(`Scene ${index} parts must be an array`);
    }

    // Ports validation (flexible: 'ports', 'interfaces', 'proxies')
    const ports = this._normalizeFieldName(scene, ['ports', 'interfaces', 'proxies', 'proxyPorts']);
    if (ports && !Array.isArray(ports)) {
      errors.push(`Scene ${index} ports must be an array`);
    }

    // Connectors validation (flexible: 'connectors', 'connections', 'links', 'edges')
    const connectors = this._normalizeFieldName(scene, ['connectors', 'connections', 'links', 'edges']);
    if (connectors && !Array.isArray(connectors)) {
      errors.push(`Scene ${index} connectors must be an array`);
    }

    // NOTE: Position uniqueness is NOT validated.
    // SAJAI explicitly supports superposition (multiple elements at same coordinates)
    // for hierarchical representations and overlapping components.
  },

  /**
   * Helper to find a field by multiple possible names
   * @private
   */
  _normalizeFieldName(obj, possibleNames) {
    for (const name of possibleNames) {
      if (obj.hasOwnProperty(name)) {
        return obj[name];
      }
    }
    return undefined;
  },

  /**
   * Get a human-readable summary of SAJAI data
   * Useful for debugging and logging
   * @param {Object} data - Parsed SAJAI data
   * @returns {string} Summary text
   */
  getSummary(data) {
    if (!data || typeof data !== 'object') {
      return 'Invalid SAJAI data';
    }

    const scenes = this._normalizeFieldName(data, ['scenes', 'scene', 'sceneList']);
    const sceneArray = Array.isArray(scenes) ? scenes : [scenes];
    const sceneCount = sceneArray.length;

    let totalParts = 0;
    let totalPorts = 0;
    let totalConnectors = 0;

    sceneArray.forEach(scene => {
      const parts = this._normalizeFieldName(scene, ['parts', 'elements', 'blocks', 'components']) || [];
      const ports = this._normalizeFieldName(scene, ['ports', 'interfaces', 'proxies', 'proxyPorts']) || [];
      const connectors = this._normalizeFieldName(scene, ['connectors', 'connections', 'links', 'edges']) || [];

      totalParts += parts.length || 0;
      totalPorts += ports.length || 0;
      totalConnectors += connectors.length || 0;
    });

    return `SAJAI: ${sceneCount} scene(s), ${totalParts} part(s), ${totalPorts} port(s), ${totalConnectors} connector(s)`;
  }
};

// For debugging in console
if (typeof window !== 'undefined') {
  window.SajaiParser = SajaiParser;
}
