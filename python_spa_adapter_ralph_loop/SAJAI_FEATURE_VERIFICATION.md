# SAJAI Generation Feature - Verification Guide

## Overview
This feature adds a "Generate 3D Model" button to the 3D View tab that converts SysML v2 architectures to SAJAI format for 3D visualization.

## Implementation Summary

### 1. UI Components (index.html)
- Added "Generate 3D Model" button in 3D View tab controls
- Button is disabled when no architecture is selected
- Added modal dialog for filename input with default naming

### 2. JavaScript Functions (app.js)
- `openSajaiGenerateModal()` - Opens generation dialog
- `closeSajaiGenerateModal()` - Closes dialog
- `generateSajaiFromArch()` - Main generation function that:
  - Validates current architecture selection
  - Calls `/api/generate-sajai` endpoint
  - Shows loading state with spinner
  - Auto-loads generated file into 3D view on success
  - Displays error messages on failure
- Button enable/disable logic in `loadArchitectureFromPath()`

### 3. SAJAI Generator Library (lib/sajai_generator.py)
- `sysml_to_sajai()` - Main conversion function
- `ir_to_sajai()` - Converts IR to SAJAI format
- `create_scene_from_ir()` - Creates SAJAI scene with:
  - Camera settings
  - Parts (3D boxes with position, size, color)
  - Ports (connection points on part surfaces)
  - Connectors (links between ports)
- Color assignment, port positioning, and layout algorithms

### 4. Server Endpoint (spa/server.py)
- POST `/api/generate-sajai` endpoint
- Request format:
  ```json
  {
    "architecturePath": "data/architectures/arch_uav.sysml",
    "outputPath": "spa/static/sample-data/my_model.sajai"
  }
  ```
- Response format:
  ```json
  {
    "ok": true,
    "path": "spa/static/sample-data/my_model.sajai",
    "scenes": 1,
    "parts": 5,
    "ports": 12,
    "connectors": 8
  }
  ```
- Path validation and security checks
- Error handling with detailed messages

### 5. CSS Styling (style.css)
- Gradient button styling with purple theme
- Hover effects with elevation
- Disabled state styling
- Modal dialog styling

## Testing

### Automated Tests
Run integration test:
```bash
cd python_spa_adapter_ralph_loop
python3 test_sajai_integration.py
```

Expected output:
- Generator Library: PASS
- Server Endpoint: PASS

### Manual Testing Steps

1. Start the server:
   ```bash
   cd python_spa_adapter_ralph_loop
   python3 spa/server.py
   ```

2. Open browser to `http://127.0.0.1:8765`

3. Select a `.sysml` architecture from the file tree

4. Click the "3D View" tab

5. Click the "Generate 3D Model" button (should be enabled with purple gradient)

6. In the dialog:
   - Default filename should be auto-populated
   - Modify if desired
   - Click "Generate"

7. Verify:
   - Loading spinner appears on button
   - Success message displays
   - File appears in SAJAI file selector dropdown
   - 3D view automatically loads with generated model
   - Parts, ports, and connectors are visible

### Expected Behavior

#### Before Architecture Selection
- Generate 3D Model button is DISABLED (gray)
- Hovering shows no effect

#### After Architecture Selection (.sysml file)
- Generate 3D Model button is ENABLED (purple gradient)
- Hovering shows elevation effect
- Clicking opens filename dialog

#### During Generation
- Button shows "⟳ Generating..." with spinner
- Button is disabled during generation
- User cannot trigger multiple generations

#### After Success
- Success alert shows
- 3D view tab is active
- Generated file is auto-selected in dropdown
- 3D visualization renders automatically

#### Error Cases
- No architecture selected: Alert "No architecture selected"
- Empty filename: Alert "Please enter a filename"
- Server error: Alert with detailed error message
- Non-.sysml files: Button remains disabled

## File Locations

### Modified Files
- `spa/static/index.html` - Added button and modal
- `spa/static/app.js` - Added generation functions
- `spa/static/style.css` - Added button styling
- `spa/server.py` - Added API endpoint

### New Files
- `lib/sajai_generator.py` - SAJAI conversion library
- `test_sajai_integration.py` - Integration test suite
- `SAJAI_FEATURE_VERIFICATION.md` - This document

### Generated Files (at runtime)
- `spa/static/sample-data/*.sajai` - User-generated 3D models

## SAJAI Format Example

```json
{
  "format": "SAJAI",
  "version": "1.0",
  "description": "Generated from SysML v2 architecture",
  "scenes": {
    "scene_id": {
      "id": "scene_id",
      "name": "System Name",
      "camera": { "position": [15, 12, 15], ... },
      "parts": [
        {
          "id": "part_component",
          "name": "Component",
          "position": [0, 0, 0],
          "size": [2.5, 2.0, 2.5],
          "color": "#3498db",
          ...
        }
      ],
      "ports": [...],
      "connectors": [...]
    }
  }
}
```

## Future Enhancements

- Support for nested scene generation (drill-down)
- Custom color schemes
- Position/layout preferences
- Export to other 3D formats
- Real-time preview during generation
- Batch conversion of multiple architectures

## Troubleshooting

### Button Not Appearing
- Clear browser cache
- Verify `index.html` has the button element
- Check browser console for JavaScript errors

### Button Remains Disabled
- Verify a `.sysml` file is selected (not `.json`)
- Check `app.js` has enable/disable logic
- Verify `currentPath` variable is set

### Generation Fails
- Check server logs: `tail -f /tmp/spa_server.log`
- Verify SAJAI generator import works: `python3 -c "from lib.sajai_generator import sysml_to_sajai; print('OK')"`
- Check output directory exists: `ls spa/static/sample-data/`
- Verify architecture file is valid SysML v2

### 3D View Doesn't Load
- Check browser console for errors
- Verify `.sajai` file was created
- Check file is valid JSON: `python3 -m json.tool spa/static/sample-data/file.sajai`
- Verify sajaiParser.js and sajaiThreeRenderer.js are loaded
