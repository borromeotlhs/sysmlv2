Modify the spa to add a new feature:3D diagram viewing (glb files made from a custom json artifact)

Context:

* emits `.sajai` files from SysML v2 source.
* Treat `.sajai` as the input contract.
* SAJAI means “SysML-Aware JSON for Auditing and Introspection.”
* `.sajai` is a JSON geometry/layout/audit/introspection format for expressing SysML-aware geometry.
* The SPA should parse `.sajai` and render an interactive 3D scene using Three.js.
* The authoritative model remains the SysML/SysML-derived source. The `.sajai` file provides geometry, layout, presentation state, SysML element references, audit metadata, and introspection data.

Feature to add:
Add a new “3d view” tab to the SPA, plus a “Pop Out” button that opens the same 3D scene in a separate popout window.

Core UI requirements:

1. Add a top-level tab named “3D View”.
2. The tab must let the user select/load a `.sajai` file from the existing file/tree/navigation system if one is available.
3. If the SPA already has a selected architecture/model/file context, the Diagram View should attempt to find and load a corresponding `.sajai` file.
4. Add a Three.js viewport inside the Diagram View tab.
5. Add a “Pop Out” button that opens the current diagram view in a separate browser window.
6. The popout must render the same scene and preserve the same loaded `.sajai` data.
7. The main tab and popout should both support basic camera orbit/pan/zoom.
8. Add a right-side property inspector panel showing details for the selected SAJAI element.
9. Add basic visibility toggles for:

   * part properties
   * proxy ports
   * connectors
   * labels
10. Add a small legend/filter panel that can color/highlight elements by SAJAI metadata fields if present.
11. the popout should be able to allow modification of positioning of all elements
12. renderer should have a placement algorithm to initially populate x,y,z coordinates of elements so they are not initially stacked atop each other at (0,0,0)

Rendering requirements:

1. Render part properties as 3D rectangular boxes.
2. Use SAJAI-provided position, size, color, opacity/transparency, and visible fields when present.
3. Render proxy ports as half-sphere or dome-like nodules on the surface of the owning part box.
4. Proxy port placement should use SAJAI surface-placement fields when present, such as surface name and normalized UV coordinates.
5. Render connectors as lines, curves, or tubes between proxy ports.
6. Use SAJAI-provided connector route points when present.
7. If connector route points are absent, draw a direct line between source and target port positions.
8. Render labels for parts, ports, and connectors when enabled.
9. Support transparency correctly enough for an MVP.
10. Use stable SysML/Sajai IDs for picking and property inspection.

Interaction requirements:

1. Click a part, port, or connector to select it.
2. Selected element should be visually highlighted.
3. Property inspector should show:

   * SAJAI id
   * SysML reference / qualified name if present
   * element kind
   * name
   * type
   * owner
   * stereotype/tag metadata if present
   * visibility
   * geometry/layout fields
4. Clicking a proxy port should highlight all directly connected proxy ports and connectors.
5. Double-clicking a part should navigate into that part’s child/internal scene if SAJAI contains a scene for the part’s type or referenced block.
6. Provide Back and Forward navigation for recursive scene traversal.
7. If no child scene exists, show a non-blocking message like “No nested scene available for this part.”
8. Allow dragging/moving part boxes in x/y/z for MVP if feasible. If full 3D dragging is too much, implement x/z plane dragging first and leave TODO comments for y-axis/freeform dragging.
9. Allow toggling visibility of selected parts, ports, and connectors.
10. Persist changed layout state in SPA memory and provide a “Download Updated SAJAI” button.

SAJAI shape:
Support a flexible schema. Do not hardcode only one exact shape. Implement adapters/helpers that can normalize likely SAJAI fields into internal scene objects.

The normalized internal shape should include:

* scenes:

  * id
  * name
  * contextBlockId/contextRef
  * parts
  * ports
  * connectors
  * camera
* parts:

  * id
  * name
  * sysmlRef
  * qualifiedName
  * type
  * owner
  * position [x, y, z]
  * size [x, y, z]
  * color
  * opacity
  * visible
  * metadata
* ports:

  * id
  * name
  * sysmlRef
  * ownerPartId
  * type
  * surface
  * uv [u, v]
  * radius
  * color
  * visible
  * connectedPortIds
  * metadata
* connectors:

  * id
  * name
  * sysmlRef
  * sourcePortId
  * targetPortId
  * route points
  * color
  * visible
  * metadata

Implementation constraints:

* attempt to install dependencies first, and if they fail, direct user to install (e.g. "sudo apt *" calls)
* Prefer no new build-chain complexity unless the SPA already has one.
* If the SPA is currently Python-only/static HTML/JS/CSS, keep it that way.
* Use Three.js from a CDN or local vendor file depending on the existing project pattern.
* Do not require npm unless the SPA already requires npm.
* Keep the app runnable using the project’s existing run instructions.
* Do not break existing SPA behavior.
* Keep changes modular:

  * sajaiParser.js
  * sajaiSceneNormalizer.js
  * sajaiThreeRenderer.js
  * diagramView.js
  * popoutDiagramView.html or equivalent
  * CSS additions for diagram view layout
* Add comments where the SAJAI schema is intentionally flexible.

Acceptance checks:

1. The SPA starts using the existing documented command.
2. A “Diagram View” tab is visible.
3. Loading a valid sample `.sajai` file renders a 3D scene.
4. At least two part boxes render with different positions.
5. At least one proxy port renders as a surface nodule.
6. At least one connector renders between proxy ports.
7. Clicking a part updates the property inspector.
8. Clicking a proxy port highlights its connected connector/port.
9. Visibility toggles for parts, ports, connectors, and labels work.
10. The Pop Out button opens a separate window showing the same scene.
11. Back/Forward navigation exists for nested scenes.
12. “Download Updated SAJAI” exports the currently edited layout JSON.
13. Existing SPA features still work.

Create a small sample `.sajai` file under an examples or sample-data directory if no sample exists. The sample should include:

* one top-level UAV scene
* at least three parts
* at least four proxy ports
* at least two connectors
* one nested scene reachable by double-clicking a part
* metadata fields sufficient to demonstrate the property inspector and legend/filter panel

Do not claim the feature is complete unless the acceptance checks actually pass. If a check cannot be fully implemented, document the limitation clearly in a TODO/known-issues section and make the check fail honestly rather than pretending it passes.
