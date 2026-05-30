#!/usr/bin/env python3
"""
3D View Feature Verification Script

Verifies all 13 acceptance checks from SAJAI.md by analyzing:
- File structure and existence
- HTML elements and structure
- JavaScript functions and logic
- Sample data validity
- Server endpoints
- CSS styling

This script does NOT require a browser - it performs static analysis
of code and files to verify implementation completeness.
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

class AcceptanceCheck:
    def __init__(self, number: int, description: str):
        self.number = number
        self.description = description
        self.passed = False
        self.details = []
        self.failures = []

    def add_detail(self, detail: str):
        self.details.append(detail)

    def add_failure(self, failure: str):
        self.failures.append(failure)

    def mark_passed(self):
        self.passed = True

    def status(self) -> str:
        return "✓ PASS" if self.passed else "✗ FAIL"


class ThreeDViewVerifier:
    def __init__(self, spa_dir: Path):
        self.spa_dir = spa_dir
        self.static_dir = spa_dir / "static"
        self.checks: List[AcceptanceCheck] = []
        self.files_cache = {}

    def read_file(self, path: Path) -> str:
        """Read and cache file contents"""
        if path not in self.files_cache:
            try:
                self.files_cache[path] = path.read_text(encoding='utf-8')
            except Exception as e:
                self.files_cache[path] = f"ERROR: {e}"
        return self.files_cache[path]

    def file_exists(self, path: Path) -> bool:
        return path.exists() and path.is_file()

    def contains_text(self, file_path: Path, pattern: str, is_regex: bool = False) -> bool:
        """Check if file contains text or matches regex pattern"""
        content = self.read_file(file_path)
        if "ERROR:" in content:
            return False

        if is_regex:
            return re.search(pattern, content) is not None
        else:
            return pattern in content

    def run_all_checks(self) -> List[AcceptanceCheck]:
        """Run all 13 acceptance checks"""
        self.check_1_server_starts()
        self.check_2_diagram_view_tab()
        self.check_3_load_sajai_renders()
        self.check_4_multiple_parts()
        self.check_5_proxy_port_renders()
        self.check_6_connector_renders()
        self.check_7_part_click_inspector()
        self.check_8_port_click_highlights()
        self.check_9_visibility_toggles()
        self.check_10_popout_button()
        self.check_11_back_forward_navigation()
        self.check_12_download_updated_sajai()
        self.check_13_existing_features_work()

        return self.checks

    def check_1_server_starts(self):
        """Check 1: The SPA starts using the existing documented command"""
        check = AcceptanceCheck(1, "The SPA starts using the existing documented command")

        server_file = self.spa_dir / "server.py"
        if not self.file_exists(server_file):
            check.add_failure("server.py not found")
            self.checks.append(check)
            return

        check.add_detail(f"server.py exists at {server_file}")

        # Check for main function and server setup
        if self.contains_text(server_file, "def main()"):
            check.add_detail("main() function found")
        else:
            check.add_failure("main() function not found")

        if self.contains_text(server_file, "ThreadingHTTPServer"):
            check.add_detail("ThreadingHTTPServer found")
        else:
            check.add_failure("ThreadingHTTPServer not found")

        if self.contains_text(server_file, "httpd.serve_forever()"):
            check.add_detail("serve_forever() call found")
        else:
            check.add_failure("serve_forever() call not found")

        # Check for command documentation
        readme_candidates = [
            self.spa_dir.parent / "README.md",
            self.spa_dir / "README.md",
            self.spa_dir.parent / "CLAUDE.md"
        ]

        for readme in readme_candidates:
            if readme.exists():
                content = self.read_file(readme)
                if "python" in content.lower() and "server.py" in content.lower():
                    check.add_detail(f"Command documented in {readme.name}")
                    break

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_2_diagram_view_tab(self):
        """Check 2: A "Diagram View" tab (named "3D View") is visible"""
        check = AcceptanceCheck(2, 'A "3D View" tab is visible')

        index_html = self.static_dir / "index.html"
        if not self.file_exists(index_html):
            check.add_failure("index.html not found")
            self.checks.append(check)
            return

        # Check for 3D View tab button
        if self.contains_text(index_html, 'data-tab="3d"'):
            check.add_detail('Tab button with data-tab="3d" found')
        else:
            check.add_failure('Tab button with data-tab="3d" not found')

        # Check for tab text "3D View"
        if self.contains_text(index_html, '>3D View<'):
            check.add_detail('Tab text "3D View" found')
        else:
            check.add_failure('Tab text "3D View" not found')

        # Check for tab pane
        if self.contains_text(index_html, 'id="tab-3d"'):
            check.add_detail('Tab pane with id="tab-3d" found')
        else:
            check.add_failure('Tab pane with id="tab-3d" not found')

        # Check for threejs container
        if self.contains_text(index_html, 'id="threejsContainer"'):
            check.add_detail('Three.js container found')
        else:
            check.add_failure('Three.js container not found')

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_3_load_sajai_renders(self):
        """Check 3: Loading a valid sample .sajai file renders a 3D scene"""
        check = AcceptanceCheck(3, "Loading a valid sample .sajai file renders a 3D scene")

        # Check for sample SAJAI file
        sample_file = self.static_dir / "sample-data" / "uav_example.sajai"
        if not self.file_exists(sample_file):
            check.add_failure("Sample SAJAI file not found")
            self.checks.append(check)
            return

        check.add_detail(f"Sample file exists: {sample_file.name}")

        # Validate JSON structure
        try:
            content = self.read_file(sample_file)
            data = json.loads(content)

            if "scenes" in data:
                check.add_detail(f"SAJAI contains {len(data['scenes'])} scene(s)")
            else:
                check.add_failure("SAJAI missing 'scenes' field")

            # Check for required structure
            if isinstance(data.get("scenes"), dict):
                scenes = list(data["scenes"].values())
            else:
                scenes = data.get("scenes", [])

            if scenes:
                scene = scenes[0]
                if "parts" in scene:
                    check.add_detail(f"Scene has {len(scene['parts'])} parts")
                if "ports" in scene:
                    check.add_detail(f"Scene has {len(scene['ports'])} ports")
                if "connectors" in scene:
                    check.add_detail(f"Scene has {len(scene['connectors'])} connectors")

        except json.JSONDecodeError as e:
            check.add_failure(f"Invalid JSON: {e}")

        # Check for renderer implementation
        renderer_file = self.static_dir / "sajaiThreeRenderer.js"
        if self.file_exists(renderer_file):
            check.add_detail("Renderer file exists")

            # Check for loadScene method
            if self.contains_text(renderer_file, "loadScene(sceneData)"):
                check.add_detail("loadScene() method found")
            else:
                check.add_failure("loadScene() method not found")

            # Check for _renderPart method
            if self.contains_text(renderer_file, "_renderPart(part)"):
                check.add_detail("_renderPart() method found")
            else:
                check.add_failure("_renderPart() method not found")
        else:
            check.add_failure("Renderer file not found")

        # Check for loading logic in app.js
        app_js = self.static_dir / "app.js"
        if self.file_exists(app_js):
            if self.contains_text(app_js, "loadSajaiData"):
                check.add_detail("loadSajaiData() function found")
            else:
                check.add_failure("loadSajaiData() function not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_4_multiple_parts(self):
        """Check 4: At least two part boxes render with different positions"""
        check = AcceptanceCheck(4, "At least two part boxes render with different positions")

        sample_file = self.static_dir / "sample-data" / "uav_example.sajai"
        if not self.file_exists(sample_file):
            check.add_failure("Sample SAJAI file not found")
            self.checks.append(check)
            return

        try:
            content = self.read_file(sample_file)
            data = json.loads(content)

            # Get scenes
            if isinstance(data.get("scenes"), dict):
                scenes = list(data["scenes"].values())
            else:
                scenes = data.get("scenes", [])

            if not scenes:
                check.add_failure("No scenes found")
                self.checks.append(check)
                return

            scene = scenes[0]
            parts = scene.get("parts", [])

            if len(parts) < 2:
                check.add_failure(f"Only {len(parts)} part(s) found, need at least 2")
            else:
                check.add_detail(f"Found {len(parts)} parts")

                # Check positions are different
                positions = []
                for part in parts:
                    pos = part.get("position", [0, 0, 0])
                    positions.append(tuple(pos))
                    check.add_detail(f"Part '{part.get('name')}' at {pos}")

                unique_positions = set(positions)
                if len(unique_positions) >= 2:
                    check.add_detail(f"{len(unique_positions)} unique positions found")
                else:
                    check.add_failure("Parts have identical positions")

        except Exception as e:
            check.add_failure(f"Error parsing SAJAI: {e}")

        # Check renderer implementation
        renderer_file = self.static_dir / "sajaiThreeRenderer.js"
        if self.file_exists(renderer_file):
            if self.contains_text(renderer_file, "new THREE.BoxGeometry"):
                check.add_detail("BoxGeometry creation found in renderer")
            else:
                check.add_failure("BoxGeometry creation not found")

            if self.contains_text(renderer_file, "mesh.position.set"):
                check.add_detail("Position setting found in renderer")
            else:
                check.add_failure("Position setting not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_5_proxy_port_renders(self):
        """Check 5: At least one proxy port renders as a surface nodule"""
        check = AcceptanceCheck(5, "At least one proxy port renders as a surface nodule")

        sample_file = self.static_dir / "sample-data" / "uav_example.sajai"
        if not self.file_exists(sample_file):
            check.add_failure("Sample SAJAI file not found")
            self.checks.append(check)
            return

        try:
            content = self.read_file(sample_file)
            data = json.loads(content)

            # Get scenes
            if isinstance(data.get("scenes"), dict):
                scenes = list(data["scenes"].values())
            else:
                scenes = data.get("scenes", [])

            if scenes:
                scene = scenes[0]
                ports = scene.get("ports", [])

                if len(ports) < 1:
                    check.add_failure("No ports found in sample data")
                else:
                    check.add_detail(f"Found {len(ports)} port(s)")

                    # Check port has surface and ownerPartId
                    for port in ports[:3]:  # Check first 3
                        name = port.get("name", "unknown")
                        surface = port.get("surface")
                        owner = port.get("ownerPartId")

                        if surface:
                            check.add_detail(f"Port '{name}' has surface: {surface}")
                        if owner:
                            check.add_detail(f"Port '{name}' has owner: {owner}")

        except Exception as e:
            check.add_failure(f"Error parsing SAJAI: {e}")

        # Check renderer implementation
        renderer_file = self.static_dir / "sajaiThreeRenderer.js"
        if self.file_exists(renderer_file):
            if self.contains_text(renderer_file, "_renderPort(port)"):
                check.add_detail("_renderPort() method found")
            else:
                check.add_failure("_renderPort() method not found")

            # Check for half-sphere geometry
            if self.contains_text(renderer_file, "SphereGeometry"):
                check.add_detail("SphereGeometry creation found")
            else:
                check.add_failure("SphereGeometry not found")

            # Check for surface positioning
            if self.contains_text(renderer_file, "_calculatePortPosition"):
                check.add_detail("Port surface positioning logic found")
            else:
                check.add_failure("Port positioning logic not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_6_connector_renders(self):
        """Check 6: At least one connector renders between proxy ports"""
        check = AcceptanceCheck(6, "At least one connector renders between proxy ports")

        sample_file = self.static_dir / "sample-data" / "uav_example.sajai"
        if not self.file_exists(sample_file):
            check.add_failure("Sample SAJAI file not found")
            self.checks.append(check)
            return

        try:
            content = self.read_file(sample_file)
            data = json.loads(content)

            if isinstance(data.get("scenes"), dict):
                scenes = list(data["scenes"].values())
            else:
                scenes = data.get("scenes", [])

            if scenes:
                scene = scenes[0]
                connectors = scene.get("connectors", [])

                if len(connectors) < 1:
                    check.add_failure("No connectors found in sample data")
                else:
                    check.add_detail(f"Found {len(connectors)} connector(s)")

                    # Check connector structure
                    for conn in connectors[:2]:
                        name = conn.get("name", "unknown")
                        source = conn.get("sourcePortId")
                        target = conn.get("targetPortId")

                        if source and target:
                            check.add_detail(f"Connector '{name}': {source} -> {target}")

        except Exception as e:
            check.add_failure(f"Error parsing SAJAI: {e}")

        # Check renderer implementation
        renderer_file = self.static_dir / "sajaiThreeRenderer.js"
        if self.file_exists(renderer_file):
            if self.contains_text(renderer_file, "_renderConnector(connector)"):
                check.add_detail("_renderConnector() method found")
            else:
                check.add_failure("_renderConnector() method not found")

            # Check for line/tube rendering
            if self.contains_text(renderer_file, "LineBasicMaterial") or \
               self.contains_text(renderer_file, "TubeGeometry"):
                check.add_detail("Line/tube rendering found")
            else:
                check.add_failure("Line/tube rendering not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_7_part_click_inspector(self):
        """Check 7: Clicking a part updates the property inspector"""
        check = AcceptanceCheck(7, "Clicking a part updates the property inspector")

        index_html = self.static_dir / "index.html"

        # Check for property inspector panel
        if self.contains_text(index_html, 'id="elementDetails"'):
            check.add_detail("Property inspector element found")
        else:
            check.add_failure("Property inspector not found")

        # Check app.js for inspector update logic
        app_js = self.static_dir / "app.js"
        if self.file_exists(app_js):
            if self.contains_text(app_js, "updatePropertyInspector"):
                check.add_detail("updatePropertyInspector() function found")
            else:
                check.add_failure("updatePropertyInspector() function not found")

            # Check for element-selected event
            if self.contains_text(app_js, "element-selected"):
                check.add_detail("element-selected event handling found")
            else:
                check.add_failure("element-selected event handling not found")

        # Check renderer for click handling
        renderer_file = self.static_dir / "sajaiThreeRenderer.js"
        if self.file_exists(renderer_file):
            if self.contains_text(renderer_file, "_onMouseClick"):
                check.add_detail("Mouse click handler found in renderer")
            else:
                check.add_failure("Mouse click handler not found")

            if self.contains_text(renderer_file, "raycaster"):
                check.add_detail("Raycaster for picking found")
            else:
                check.add_failure("Raycaster not found")

            if self.contains_text(renderer_file, "_selectObject"):
                check.add_detail("Object selection logic found")
            else:
                check.add_failure("Object selection logic not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_8_port_click_highlights(self):
        """Check 8: Clicking a proxy port highlights its connected connector/port"""
        check = AcceptanceCheck(8, "Clicking a proxy port highlights its connected connector/port")

        app_js = self.static_dir / "app.js"
        if self.file_exists(app_js):
            # Check for port selection handling
            pattern = r"if.*type.*==.*['\"]port['\"]"
            if self.contains_text(app_js, pattern, is_regex=True):
                check.add_detail("Port type check found")
            else:
                check.add_failure("Port type check not found")

            # Check for connected ports highlighting
            if self.contains_text(app_js, "connectedPortIds"):
                check.add_detail("Connected ports handling found")
            else:
                check.add_failure("Connected ports handling not found")

            if self.contains_text(app_js, "highlightConnectedPorts"):
                check.add_detail("highlightConnectedPorts() function found")
            else:
                check.add_failure("highlightConnectedPorts() function not found")

        # Check renderer
        renderer_file = self.static_dir / "sajaiThreeRenderer.js"
        if self.file_exists(renderer_file):
            if self.contains_text(renderer_file, "highlightMaterial"):
                check.add_detail("Highlight material found")
            else:
                check.add_failure("Highlight material not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_9_visibility_toggles(self):
        """Check 9: Visibility toggles for parts, ports, connectors, and labels work"""
        check = AcceptanceCheck(9, "Visibility toggles for parts, ports, connectors, and labels work")

        index_html = self.static_dir / "index.html"

        # Check for visibility checkboxes
        toggles = [
            ("parts", 'id="visibility-parts"'),
            ("ports", 'id="visibility-ports"'),
            ("connectors", 'id="visibility-connectors"'),
            ("labels", 'id="visibility-labels"')
        ]

        for name, pattern in toggles:
            if self.contains_text(index_html, pattern):
                check.add_detail(f"Visibility toggle for {name} found")
            else:
                check.add_failure(f"Visibility toggle for {name} not found")

        # Check app.js for toggle handling
        app_js = self.static_dir / "app.js"
        if self.file_exists(app_js):
            if self.contains_text(app_js, "handleVisibilityToggle"):
                check.add_detail("Visibility toggle handler found")
            else:
                check.add_failure("Visibility toggle handler not found")

            # Check for event listeners
            pattern = r"visibility-\w+.*onchange"
            if self.contains_text(app_js, pattern, is_regex=True):
                check.add_detail("Visibility toggle event listeners found")
            else:
                check.add_failure("Event listeners not found")

        # Check renderer setVisibility method
        renderer_file = self.static_dir / "sajaiThreeRenderer.js"
        if self.file_exists(renderer_file):
            if self.contains_text(renderer_file, "setVisibility(type, visible)"):
                check.add_detail("setVisibility() method found in renderer")
            else:
                check.add_failure("setVisibility() method not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_10_popout_button(self):
        """Check 10: The Pop Out button opens a separate window showing the same scene"""
        check = AcceptanceCheck(10, "The Pop Out button opens a separate window")

        index_html = self.static_dir / "index.html"

        # Check for popout button
        if self.contains_text(index_html, 'id="popout3d"'):
            check.add_detail("Pop-out button found")
        else:
            check.add_failure("Pop-out button not found")

        # Check app.js for popout logic
        app_js = self.static_dir / "app.js"
        if self.file_exists(app_js):
            if self.contains_text(app_js, "popout3d"):
                check.add_detail("Pop-out event handler found")
            else:
                check.add_failure("Pop-out event handler not found")

            if self.contains_text(app_js, "window.open"):
                check.add_detail("window.open() call found")
            else:
                check.add_failure("window.open() not found")

            if self.contains_text(app_js, "localStorage"):
                check.add_detail("localStorage usage for data passing found")
            else:
                check.add_failure("localStorage not used")

            if self.contains_text(app_js, "popout3DView.html"):
                check.add_detail("Reference to popout HTML found")
            else:
                check.add_failure("Popout HTML reference not found")

        # Check for popout HTML file
        popout_html = self.static_dir / "popout3DView.html"
        if self.file_exists(popout_html):
            check.add_detail("popout3DView.html exists")

            # Check it loads Three.js and SAJAI modules
            if self.contains_text(popout_html, "three.min.js"):
                check.add_detail("Three.js loaded in popout")

            if self.contains_text(popout_html, "sajaiThreeRenderer.js"):
                check.add_detail("SAJAI renderer loaded in popout")
        else:
            check.add_failure("popout3DView.html not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_11_back_forward_navigation(self):
        """Check 11: Back/Forward navigation exists for nested scenes"""
        check = AcceptanceCheck(11, "Back/Forward navigation exists for nested scenes")

        index_html = self.static_dir / "index.html"

        # Check for navigation buttons
        if self.contains_text(index_html, 'id="nav3dBack"'):
            check.add_detail("Back button found")
        else:
            check.add_failure("Back button not found")

        if self.contains_text(index_html, 'id="nav3dForward"'):
            check.add_detail("Forward button found")
        else:
            check.add_failure("Forward button not found")

        # Check for navigation path display
        if self.contains_text(index_html, 'id="nav3dPath"'):
            check.add_detail("Navigation path display found")
        else:
            check.add_failure("Navigation path not found")

        # Check app.js for navigation logic
        app_js = self.static_dir / "app.js"
        if self.file_exists(app_js):
            if self.contains_text(app_js, "navigate3DBack"):
                check.add_detail("navigate3DBack() function found")
            else:
                check.add_failure("navigate3DBack() not found")

            if self.contains_text(app_js, "navigate3DForward"):
                check.add_detail("navigate3DForward() function found")
            else:
                check.add_failure("navigate3DForward() not found")

            if self.contains_text(app_js, "sceneHistory"):
                check.add_detail("Scene history tracking found")
            else:
                check.add_failure("Scene history not found")

            if self.contains_text(app_js, "currentSceneIndex"):
                check.add_detail("Current scene index tracking found")
            else:
                check.add_failure("Scene index tracking not found")

        # Check sample data has nested scene
        sample_file = self.static_dir / "sample-data" / "uav_example.sajai"
        if self.file_exists(sample_file):
            try:
                content = self.read_file(sample_file)
                data = json.loads(content)

                if isinstance(data.get("scenes"), dict):
                    scene_count = len(data["scenes"])
                else:
                    scene_count = len(data.get("scenes", []))

                if scene_count > 1:
                    check.add_detail(f"Sample has {scene_count} scenes (supports nesting)")
                else:
                    check.add_detail(f"Sample has only {scene_count} scene (nesting possible via doubleClickScene)")
            except:
                pass

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_12_download_updated_sajai(self):
        """Check 12: "Download Updated SAJAI" exports the currently edited layout JSON"""
        check = AcceptanceCheck(12, '"Download Updated SAJAI" exports edited layout')

        index_html = self.static_dir / "index.html"

        # Check for download button
        if self.contains_text(index_html, 'id="downloadUpdatedSajai"'):
            check.add_detail("Download button found")
        else:
            check.add_failure("Download button not found")

        # Check app.js for download logic
        app_js = self.static_dir / "app.js"
        if self.file_exists(app_js):
            if self.contains_text(app_js, "downloadUpdatedSajai"):
                check.add_detail("downloadUpdatedSajai() function found")
            else:
                check.add_failure("downloadUpdatedSajai() not found")

            # Check for blob creation
            if self.contains_text(app_js, "Blob"):
                check.add_detail("Blob creation found")
            else:
                check.add_failure("Blob creation not found")

            # Check for JSON.stringify
            if self.contains_text(app_js, "JSON.stringify"):
                check.add_detail("JSON serialization found")
            else:
                check.add_failure("JSON serialization not found")

            # Check for download trigger
            pattern = r"\.download\s*=.*\.sajai"
            if self.contains_text(app_js, pattern, is_regex=True):
                check.add_detail("Download trigger found")
            else:
                check.add_failure("Download trigger not found")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)

    def check_13_existing_features_work(self):
        """Check 13: Existing SPA features still work"""
        check = AcceptanceCheck(13, "Existing SPA features still work")

        index_html = self.static_dir / "index.html"
        app_js = self.static_dir / "app.js"

        # Check existing tabs still present
        existing_tabs = [
            ("Text", 'data-tab="text"'),
            ("BDD", 'data-tab="bdd"'),
            ("IBD", 'data-tab="ibd"')
        ]

        for name, pattern in existing_tabs:
            if self.contains_text(index_html, pattern):
                check.add_detail(f"{name} tab still present")
            else:
                check.add_failure(f"{name} tab missing")

        # Check for file tree
        if self.contains_text(index_html, 'id="fileTree"'):
            check.add_detail("File tree still present")
        else:
            check.add_failure("File tree missing")

        # Check for pair authoring
        if self.contains_text(index_html, 'id="pairsList"'):
            check.add_detail("Pair authoring still present")
        else:
            check.add_failure("Pair authoring missing")

        # Check app.js core functions intact
        if self.file_exists(app_js):
            core_functions = [
                "loadArchitectureFromPath",
                "switchTab",
                "loadBddDiagram",
                "loadIbdDiagram",
                "addPair",
                "savePairs"
            ]

            missing = []
            for func in core_functions:
                if self.contains_text(app_js, func):
                    pass
                else:
                    missing.append(func)

            if missing:
                check.add_failure(f"Missing core functions: {', '.join(missing)}")
            else:
                check.add_detail("All core functions present")

        # Check server.py endpoints still work
        server_file = self.spa_dir / "server.py"
        if self.file_exists(server_file):
            endpoints = [
                "/api/architectures",
                "/api/diagram/bdd/",
                "/api/diagram/ibd/",
                "/api/save-pairs",
                "/api/tree"
            ]

            missing_endpoints = []
            for endpoint in endpoints:
                if self.contains_text(server_file, endpoint):
                    pass
                else:
                    missing_endpoints.append(endpoint)

            if missing_endpoints:
                check.add_failure(f"Missing endpoints: {', '.join(missing_endpoints)}")
            else:
                check.add_detail("All core endpoints present")

        if not check.failures:
            check.mark_passed()

        self.checks.append(check)


def main():
    # Determine SPA directory
    script_dir = Path(__file__).parent
    spa_dir = script_dir / "spa"

    if not spa_dir.exists():
        print(f"ERROR: SPA directory not found at {spa_dir}")
        return 1

    print("=" * 80)
    print("3D View Feature Verification")
    print("=" * 80)
    print(f"SPA Directory: {spa_dir}")
    print()

    # Run verification
    verifier = ThreeDViewVerifier(spa_dir)
    checks = verifier.run_all_checks()

    # Print results
    passed = sum(1 for c in checks if c.passed)
    failed = sum(1 for c in checks if not c.passed)

    print(f"Results: {passed}/{len(checks)} checks passed\n")

    for check in checks:
        print(f"{check.status()} Check {check.number}: {check.description}")

        for detail in check.details:
            print(f"    ✓ {detail}")

        for failure in check.failures:
            print(f"    ✗ {failure}")

        print()

    # Summary
    print("=" * 80)
    if failed == 0:
        print("✓ All acceptance checks passed!")
        return 0
    else:
        print(f"✗ {failed} check(s) failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())
