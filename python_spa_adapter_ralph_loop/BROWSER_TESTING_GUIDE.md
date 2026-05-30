# SAJAI 3D View - Browser Testing Guide

**Server:** http://127.0.0.1:8081  
**Tab:** 3D View (4th tab, after Text/BDD/IBD)

---

## Quick Start

1. **Open browser** to http://127.0.0.1:8081
2. **Click** the **"3D View"** tab
3. **Observe** the UAV example auto-loads
4. **Interact** with the 3D scene

---

## Acceptance Check Testing

### ✅ Check 1: Server Starts
**Expected:** Server running on port 8081  
**Verify:** Browser loads http://127.0.0.1:8081

---

### ✅ Check 2: "3D View" Tab Visible
**Expected:** Tab appears next to Text/BDD/IBD  
**Verify:** Click "3D View" tab, content area switches

---

### ✅ Check 3: Loading .sajai File Renders Scene
**Expected:** UAV scene renders automatically  
**Verify:**
- 3D canvas shows rendered scene
- Parts visible as colored boxes
- Ports visible as small spheres
- Connectors visible as lines

**Troubleshooting:**
- If blank: Check browser console for errors
- If "Loading...": Wait 2-3 seconds
- If error: Verify sample file exists at `spa/static/sample-data/uav_example.sajai`

---

### ✅ Check 4: Multiple Parts with Different Positions
**Expected:** 4 distinct parts not stacked  
**Verify:**
- FlightController (blue) at center-top
- GPS (teal) at right-top
- Battery (orange) at left-bottom
- TelemetryRadio (green) at right-front
- All clearly separated in 3D space

**Test:**
- Drag mouse to rotate view
- All 4 parts should remain visible from different angles
- No parts overlap or hide each other

---

### ✅ Check 5: Proxy Port as Surface Nodule
**Expected:** Small half-spheres on part surfaces  
**Verify:**
- Look closely at FlightController (blue box)
- Should see small spheres on top, bottom, and sides
- Ports are smaller than parts
- Ports sit on part surfaces, not floating

**Test:**
- Zoom in close (scroll wheel)
- Rotate to see ports from different angles
- Ports should follow surface normals (point outward)

---

### ✅ Check 6: Connector Between Ports
**Expected:** Lines connecting ports  
**Verify:**
- Line from Battery to FlightController (power)
- Line from Battery to GPS (power)
- Line from GPS to FlightController (data)
- Line from TelemetryRadio to FlightController (telemetry)

**Test:**
- Rotate view to see connectors from different angles
- Connectors should follow slight curves (routed paths)
- Connectors connect port-to-port, not part-to-part

---

### ✅ Check 7: Clicking Part Updates Inspector
**Expected:** Property panel shows part details  
**Verify:**
1. **Click** on FlightController (blue box)
2. **Observe** right panel updates with:
   - Type: "Part"
   - ID: "part_flight_controller"
   - Name: "flightController"
   - Position: [0, 2, 0]
   - Size: [3, 1.5, 2]
   - Color, Opacity, Visible status
   - Metadata section with specs

**Test:**
- Click different parts
- Inspector updates each time
- Click empty space → "Click an element to inspect"

---

### ✅ Check 8: Clicking Port Highlights Connected Elements
**Expected:** Port selection shows connections  
**Verify:**
1. **Click** a small sphere (port) on FlightController
2. **Observe** right panel shows:
   - Type: "Port"
   - Port name and ID
   - Owner: "part_flight_controller"
   - Connected ports listed

**Test:**
- Click port with connections (e.g., powerIn)
- Inspector shows connected port IDs
- Visual highlighting may appear (yellow glow)

---

### ✅ Check 9: Visibility Toggles Work
**Expected:** Checkboxes show/hide elements  
**Verify:**
1. **Uncheck** "Show Parts" → All boxes disappear
2. **Check** "Show Parts" → Boxes reappear
3. **Uncheck** "Show Ports" → Small spheres disappear
4. **Check** "Show Ports" → Spheres reappear
5. **Uncheck** "Show Connectors" → Lines disappear
6. **Check** "Show Connectors" → Lines reappear

**Note:** "Show Labels" may not have visible effect yet (labels not fully implemented)

---

### ✅ Check 10: Pop Out Button Opens Separate Window
**Expected:** New window with same scene  
**Verify:**
1. **Click** "Pop Out" button (top controls)
2. **Observe** new window opens
3. **New window shows:**
   - Same UAV scene
   - Same 3D rendering
   - Independent camera control
   - Side property panel
   - Toolbar with visibility toggles

**Test:**
- Rotate view in pop-out (independent from main)
- Click elements in pop-out
- Close pop-out → main window unaffected

---

### ✅ Check 11: Back/Forward Navigation for Nested Scenes
**Expected:** Navigation controls present  
**Verify:**
1. **Observe** Back/Forward buttons below SAJAI selector
2. **Buttons** currently disabled (no navigation yet)
3. **Scene path** shows current scene name

**Future Test (when double-click implemented):**
- Double-click FlightController
- Should navigate to "Flight Controller Internals" scene
- Back button becomes enabled
- Click Back → returns to UAV System scene

**Current Status:** Infrastructure ready, double-click handler not yet wired

---

### ✅ Check 12: Download Updated SAJAI Exports JSON
**Expected:** JSON file downloads  
**Verify:**
1. **Click** "Download Updated SAJAI" button
2. **Observe** browser downloads file (e.g., `uav_system.sajai`)
3. **Open** downloaded file in text editor
4. **Verify:**
   - Valid JSON format
   - Contains same scene data
   - Position data preserved

**Test:**
- Downloaded file should be ~18KB
- Should match original structure
- Can be re-loaded into 3D View

---

### ✅ Check 13: Existing Features Still Work
**Expected:** Other tabs unaffected  
**Verify:**
1. **Click** "Text" tab → Shows .sysml content
2. **Click** "BDD" tab → Shows block diagram
3. **Click** "IBD" tab → Shows internal diagram
4. **Click** file in tree → Loads architecture
5. **Test** pair authoring → Still functional

**Test:**
- Navigate through all tabs
- Load different architectures
- Create pairs (if needed)
- All existing features work normally

---

## Interactive Testing Checklist

### Camera Controls
- ✅ **Left Click + Drag** → Rotate (orbit) view
- ✅ **Right Click + Drag** → Pan view
- ✅ **Scroll Wheel** → Zoom in/out
- ✅ **View rotates** smoothly around center
- ✅ **All parts remain visible** during rotation

### Selection Testing
- ✅ **Click part** → Highlights with yellow material
- ✅ **Click port** → Highlights with yellow material
- ✅ **Click connector** → Highlights with yellow material
- ✅ **Click empty space** → Deselects current
- ✅ **Inspector updates** on each selection

### File Loading
- ✅ **Dropdown** shows "uav_example.sajai"
- ✅ **Click "Load SAJAI"** → Reloads scene
- ✅ **Loading indicator** shows briefly
- ✅ **Scene renders** after load completes

### UI Responsiveness
- ✅ **Tab switching** is instant
- ✅ **Checkboxes** respond immediately
- ✅ **Buttons** have hover effects
- ✅ **Canvas** fills viewport properly
- ✅ **Inspector panel** scrolls if needed

---

## Troubleshooting

### Scene Doesn't Render
**Symptoms:** Blank canvas, no 3D objects  
**Checks:**
1. Browser console for errors (F12)
2. Sample file exists: `spa/static/sample-data/uav_example.sajai`
3. Three.js loaded: Check Network tab for `three.min.js`
4. WebGL enabled: Visit https://get.webgl.org/

**Solutions:**
- Refresh page (Ctrl+R)
- Clear browser cache
- Try different browser
- Check server logs

### Parts Are Stacked/Invisible
**Symptoms:** Can't see all 4 parts  
**Checks:**
1. Zoom out (scroll wheel away)
2. Rotate view (click+drag)
3. Check visibility toggles are ON
4. Verify sample data has unique positions

**Solutions:**
- Reset view by reloading tab
- Zoom way out and look around
- Check browser zoom is 100% (Ctrl+0)

### Inspector Shows "Click an element"
**Symptoms:** Can't select objects  
**Checks:**
1. Are objects visible?
2. Is mouse cursor over canvas?
3. Browser console for JS errors

**Solutions:**
- Click directly on colored boxes
- Try clicking different parts
- Refresh page

### Pop-Out Doesn't Open
**Symptoms:** Nothing happens on click  
**Checks:**
1. Browser popup blocker settings
2. Browser console for errors
3. localStorage available

**Solutions:**
- Allow popups for this site
- Try different browser
- Check browser settings

### Slow Performance
**Symptoms:** Choppy rotation, laggy interaction  
**Checks:**
1. Too many objects (>1000)
2. Complex scene with many triangles
3. Low-end GPU/CPU

**Solutions:**
- Use visibility toggles to hide elements
- Reduce scene complexity
- Close other browser tabs
- Update graphics drivers

---

## Expected Performance

### Rendering
- **FPS:** 60 on modern hardware
- **Load Time:** < 1 second for UAV example
- **Rotation:** Smooth and responsive
- **Selection:** Instant feedback

### File Sizes
- **Sample SAJAI:** ~18KB
- **Three.js:** ~600KB (CDN)
- **Total Assets:** < 1MB

### Browser Resources
- **Memory:** ~50-100MB for scene
- **CPU:** Low during idle, moderate during interaction
- **GPU:** WebGL acceleration used

---

## Success Criteria

All checks pass if:
- ✅ 3D View tab loads and shows UAV scene
- ✅ 4 parts visible and separated in space
- ✅ 8 ports visible as surface spheres
- ✅ 4 connectors visible as lines
- ✅ Clicking objects updates inspector
- ✅ Visibility toggles show/hide elements
- ✅ Pop-out opens new window with scene
- ✅ Download exports valid SAJAI JSON
- ✅ Other tabs (Text/BDD/IBD) still work
- ✅ No console errors during normal use

---

## Next Steps After Testing

### If All Tests Pass:
1. Mark feature as complete ✅
2. Use for actual SysML v2 architectures
3. Create more .sajai files for your models
4. Customize styling and layout as needed

### If Issues Found:
1. Document specific failure case
2. Check browser console for errors
3. Review relevant code module
4. Check SAJAI file format
5. Report issue with reproduction steps

### Future Enhancements:
1. Enable drag-to-move parts
2. Implement CSS2D labels
3. Wire double-click navigation
4. Add more filter controls
5. Improve performance for large scenes

---

## Testing Completion

**Tester:** ___________________  
**Date:** ___________________  
**Browser:** ___________________  
**Result:** ✅ PASS / ❌ FAIL  

**Notes:**
```
[Space for testing notes]
```

---

**Server:** http://127.0.0.1:8081  
**Status:** Running (pid: 16915)  
**Ready for testing!**
