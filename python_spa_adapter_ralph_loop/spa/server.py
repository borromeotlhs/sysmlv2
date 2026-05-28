#!/usr/bin/env python
import argparse
import json
import mimetypes
import os
import zlib
import base64
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse, unquote

# Import SysML parser
try:
    from spa.sysml_parser import parse_sysml_to_json
except ImportError:
    from sysml_parser import parse_sysml_to_json

ROOT = Path(__file__).resolve().parents[1]
STATIC = Path(__file__).resolve().parent / 'static'
ARCH_DIR = ROOT / 'data' / 'architectures'
PAIR_DIR = ROOT / 'data' / 'pairs'


def safe_data_path(base: Path, rel: str) -> Path:
    candidate = (base / rel).resolve()
    if base.resolve() not in candidate.parents and candidate != base.resolve():
        raise ValueError('path escapes data directory')
    return candidate


def detect_architecture_format(arch_path: Path) -> str:
    """
    Detect if architecture uses new separated format or legacy monolithic.

    Args:
        arch_path: Path to architecture (file or directory)

    Returns:
        'separated' if directory with model.sysml exists
        'monolithic' if single .sysml file
        'json' if .json file (legacy)
    """
    if arch_path.is_dir():
        model_file = arch_path / 'model.sysml'
        if model_file.exists():
            return 'separated'
    elif arch_path.is_file():
        if arch_path.suffix.lower() == '.sysml':
            return 'monolithic'
        elif arch_path.suffix.lower() == '.json':
            return 'json'
    return 'unknown'


def load_architecture_separated(arch_dir: Path) -> dict:
    """
    Load architecture from separated format (model.sysml + views/).

    Args:
        arch_dir: Directory containing model.sysml and views/

    Returns:
        Architecture dictionary with model content
    """
    model_file = arch_dir / 'model.sysml'
    if not model_file.exists():
        raise FileNotFoundError(f"model.sysml not found in {arch_dir}")

    content = model_file.read_text(encoding='utf-8')
    arch_dict = parse_sysml_to_json(content)

    # Add metadata about available views
    views_dir = arch_dir / 'views'
    if views_dir.exists() and views_dir.is_dir():
        arch_dict['available_views'] = [
            v.stem for v in views_dir.glob('*.sysml')
        ]

    arch_dict['format'] = 'separated'
    return arch_dict


def list_views(arch_dir: Path) -> list:
    """
    List available views for an architecture.

    Args:
        arch_dir: Directory containing views/

    Returns:
        List of view metadata dictionaries
    """
    views_dir = arch_dir / 'views'
    if not views_dir.exists() or not views_dir.is_dir():
        return []

    views = []
    for view_file in sorted(views_dir.glob('*.sysml')):
        view_name = view_file.stem
        try:
            content = view_file.read_text(encoding='utf-8')
            # Extract basic metadata from comments
            view_type = 'unknown'
            if 'BlockDefinitionDiagram' in content or 'bdd' in view_name.lower():
                view_type = 'bdd'
            elif 'InternalBlockDiagram' in content or 'ibd' in view_name.lower():
                view_type = 'ibd'

            views.append({
                'name': view_name,
                'type': view_type,
                'path': str(view_file.relative_to(arch_dir))
            })
        except Exception as e:
            views.append({
                'name': view_name,
                'type': 'error',
                'error': str(e)
            })

    return views


def load_architecture(file_path: Path) -> dict:
    """Load architecture from either JSON or .sysml file"""
    content = file_path.read_text(encoding='utf-8')

    # Detect format by extension
    if file_path.suffix.lower() == '.sysml':
        # Parse SysML v2 textual syntax
        arch_dict = parse_sysml_to_json(content)
        arch_dict['format'] = 'monolithic'
        return arch_dict
    else:
        # Assume JSON
        arch_dict = json.loads(content)
        arch_dict['format'] = 'json'
        return arch_dict


def plantuml_encode(source: str) -> str:
    """Encode PlantUML source for public server URL using deflate + custom base64"""
    compressed = zlib.compress(source.encode('utf-8'))[2:-4]  # Remove zlib header/trailer
    b64 = base64.b64encode(compressed).decode('ascii')
    # PlantUML uses custom base64 alphabet
    custom = b64.translate(str.maketrans(
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'
    ))
    return custom.rstrip('=')


def generate_bdd_plantuml(sysml_path: Path) -> str:
    """Generate Block Definition Diagram PlantUML from .sysml file

    Args:
        sysml_path: Path to .sysml file or directory with model.sysml

    Returns:
        PlantUML source code as string
    """
    # Parse the .sysml file to get architecture dict
    if sysml_path.is_dir():
        # Separated format: load from model.sysml
        model_file = sysml_path / 'model.sysml'
        if not model_file.exists():
            raise FileNotFoundError(f"model.sysml not found in {sysml_path}")
        content = model_file.read_text(encoding='utf-8')
    else:
        # Monolithic format: load directly
        content = sysml_path.read_text(encoding='utf-8')

    # Parse to JSON IR
    arch = parse_sysml_to_json(content)

    # Generate PlantUML from parsed architecture
    lines = ['@startuml', 'skinparam componentStyle rectangle', '']

    # Add all blocks
    for block in arch.get('blocks', []):
        name = block.get('name', 'Unknown')
        lines.append(f'class {name} <<block>>')

    lines.append('')

    # Add composition relationships from actual SysML structure
    # Use *--> (directed composition) to show parent contains child
    compositions = arch.get('compositions', [])
    if compositions:
        for comp in compositions:
            parent = comp.get('parent', '')
            child = comp.get('child', '')
            mult = comp.get('multiplicity', '1')
            lines.append(f'{parent} *--> "{mult}" {child}')

        lines.append('')

    # Add requirements - use note style to avoid syntax issues
    for req in arch.get('requirements', []):
        req_id = req.get('id', 'REQ-?')
        text = req.get('text', '').replace('"', '\\"')[:80]  # Escape quotes and truncate
        # Use object notation for requirements
        lines.append(f'object "{req_id}" as {req_id.replace("-", "_")} <<requirement>> {{')
        lines.append(f'  text = "{text}"')
        lines.append('}')

    lines.append('')

    # Add satisfy relationships
    for rel in arch.get('relationships', []):
        client = rel.get('client', '')
        supplier = rel.get('supplier', '').replace('-', '_')  # Handle requirement IDs
        rel_type = rel.get('type', 'trace')
        lines.append(f'{client} ..> {supplier} : <<{rel_type}>>')

    lines.append('@enduml')
    return '\n'.join(lines)


def generate_ibd_plantuml(sysml_path: Path) -> str:
    """Generate Internal Block Diagram PlantUML from .sysml file

    Uses component-based syntax with real ports that straddle component boundaries.
    Recursively renders nested subsystems to show all components and connections.

    Args:
        sysml_path: Path to .sysml file or directory with model.sysml

    Returns:
        PlantUML source code as string
    """
    # Parse the .sysml file to get architecture dict
    if sysml_path.is_dir():
        # Separated format: load from model.sysml
        model_file = sysml_path / 'model.sysml'
        if not model_file.exists():
            raise FileNotFoundError(f"model.sysml not found in {sysml_path}")
        content = model_file.read_text(encoding='utf-8')
    else:
        # Monolithic format: load directly
        content = sysml_path.read_text(encoding='utf-8')

    # Parse to JSON IR
    arch = parse_sysml_to_json(content)

    # Generate PlantUML from parsed architecture
    lines = ['@startuml']
    lines.append('skinparam componentStyle rectangle')
    lines.append('skinparam shadowing false')
    lines.append('skinparam roundcorner 12')
    lines.append('')
    lines.append("'=================================================='")
    lines.append("' SYSTEM STRUCTURE")
    lines.append("'=================================================='")
    lines.append('')

    # Build port ownership map
    port_owners = {}
    for port in arch.get('proxy_ports', []):
        owner = port.get('owner', '')
        if owner not in port_owners:
            port_owners[owner] = []
        port_owners[owner].append(port)

    blocks = arch.get('blocks', [])
    compositions = arch.get('compositions', [])

    # Build composition hierarchy map
    children_map = {}
    for comp in compositions:
        parent = comp.get('parent', '')
        child = comp.get('child', '')
        if parent not in children_map:
            children_map[parent] = []
        children_map[parent].append(comp)

    # Find the system-level block
    system_block = blocks[-1] if blocks else None
    system_name = system_block.get('name', 'System') if system_block else 'System'

    # Track port aliases for connections
    port_aliases = {}
    port_aliases_lower = {}  # Case-insensitive lookup map
    used_aliases = set()

    def render_component(parent_name, indent_level, parent_alias=''):
        """Recursively render a component and its children"""
        nonlocal used_aliases

        children = children_map.get(parent_name, [])
        if not children:
            return []

        indent = '  ' * indent_level
        component_lines = []

        for comp in children:
            child_name = comp['child']

            # Create unique alias
            base_alias = child_name.upper().replace(' ', '_')
            child_alias = base_alias[:8]
            counter = 1
            while child_alias in used_aliases:
                child_alias = base_alias[:6] + str(counter)
                counter += 1
            used_aliases.add(child_alias)

            # Check if this child has its own children (is a subsystem)
            has_children = child_name in children_map

            component_lines.append(f'{indent}component "«part» {child_name.lower()}:{child_name}" as {child_alias} {{')
            component_lines.append('')

            # Add ports for this component
            if child_name in port_owners:
                for port in port_owners[child_name]:
                    port_name = port.get('name', '')
                    port_type = port.get('type', '')

                    # Create port alias: COMPONENTNAME_PORTNAME
                    port_alias = f'{child_alias}_{port_name.upper()}'
                    port_key = f'{child_name}.{port_name}'
                    port_aliases[port_key] = port_alias
                    # Also store lowercase version for case-insensitive lookup
                    port_aliases_lower[port_key.lower()] = port_alias

                    # Determine port direction
                    if 'in' in port_name.lower() or 'In' in port_name:
                        component_lines.append(f'{indent}  portin "{port_name}" as {port_alias}')
                    elif 'out' in port_name.lower() or 'Out' in port_name:
                        component_lines.append(f'{indent}  portout "{port_name}" as {port_alias}')
                    else:
                        component_lines.append(f'{indent}  port "{port_name}" as {port_alias}')

            # Recursively render nested children
            if has_children:
                component_lines.append('')
                nested_lines = render_component(child_name, indent_level + 1, child_alias)
                component_lines.extend(nested_lines)

            component_lines.append(f'{indent}}}')
            component_lines.append('')

        return component_lines

    # Create system component container
    system_alias = 'SYS'
    used_aliases.add(system_alias)
    lines.append(f'component "«part» {system_name.lower()}:{system_name}" as {system_alias} {{')
    lines.append('')

    # Recursively render all components
    component_lines = render_component(system_name, 1, system_alias)
    lines.extend(component_lines)

    lines.append('}')
    lines.append('')
    lines.append("'=================================================='")
    lines.append("' CONNECTORS")
    lines.append("'=================================================='")
    lines.append('')

    # Build a map of boundary port names to their full qualified names
    boundary_port_map = {}
    for port_key in port_aliases.keys():
        if '.' in port_key:
            parts = port_key.split('.')
            owner = parts[0]
            port_name = parts[1]
            # Map bare port name to full qualified name for this owner's ports
            # This helps resolve connections like "connect foo.bar to portName"
            boundary_port_map[port_name] = boundary_port_map.get(port_name, [])
            boundary_port_map[port_name].append(port_key)

    # Add connections between ports
    connectors = arch.get('connectors', [])
    if connectors:
        for conn in connectors:
            end_a = conn.get('end_a', '')
            end_b = conn.get('end_b', '')
            flow = conn.get('item_flow', '')

            # Helper function to resolve port alias
            def resolve_port_alias(end):
                if '.' in end:
                    # Try exact match first, then case-insensitive
                    return port_aliases.get(end) or port_aliases_lower.get(end.lower())
                else:
                    # Boundary port without qualifier - try to find it
                    # Look for a port with this name in the port_aliases
                    for port_key, alias in port_aliases.items():
                        if port_key.endswith('.' + end):
                            return alias
                    # Try case-insensitive
                    for port_key, alias in port_aliases_lower.items():
                        if port_key.endswith('.' + end.lower()):
                            return alias
                return None

            alias_a = resolve_port_alias(end_a)
            alias_b = resolve_port_alias(end_b)

            if alias_a and alias_b:
                # Build connection label
                if flow:
                    label = f'«itemFlow» {flow}'
                else:
                    port_a_name = end_a.split('.')[-1]  # Get last part (port name)
                    port_b_name = end_b.split('.')[-1]  # Get last part (port name)
                    label = f'{port_a_name}→{port_b_name}'

                lines.append(f'{alias_a} --> {alias_b} : {label}')

    lines.append('')
    lines.append('@enduml')
    return '\n'.join(lines)


class Handler(BaseHTTPRequestHandler):
    server_version = 'PythonSPAPairAuthor/1.0'

    def log_message(self, fmt, *args):
        if os.environ.get('SPA_QUIET') != '1':
            super().log_message(fmt, *args)

    def build_tree(self, root_path: Path, rel_from: Path = None):
        """Build a directory tree structure"""
        if rel_from is None:
            rel_from = root_path

        def scan_dir(path: Path):
            items = []
            try:
                for entry in sorted(path.iterdir(), key=lambda p: (not p.is_dir(), p.name)):
                    if entry.name.startswith('.'):
                        continue
                    rel_path = str(entry.relative_to(rel_from)).replace('\\', '/')
                    item = {
                        'name': entry.name,
                        'path': rel_path,
                        'type': 'directory' if entry.is_dir() else 'file'
                    }
                    if entry.is_dir():
                        item['children'] = scan_dir(entry)
                    items.append(item)
            except PermissionError:
                pass
            return items

        return {
            'name': root_path.name or 'root',
            'path': '',
            'type': 'directory',
            'children': scan_dir(root_path)
        }

    def send_json(self, obj, code=200):
        body = json.dumps(obj, indent=2).encode('utf-8')
        self.send_response(code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def read_body_json(self):
        length = int(self.headers.get('Content-Length', '0'))
        raw = self.rfile.read(length).decode('utf-8') if length else ''
        return json.loads(raw or '{}')

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        try:
            if path == '/api/health':
                return self.send_json({'ok': True, 'runtime': 'python-standard-library', 'npm_required': False})
            if path == '/api/tree':
                # Check for custom root path in query params
                from urllib.parse import parse_qs
                query = parse_qs(parsed.query)
                custom_root = query.get('root', [None])[0]

                if custom_root:
                    try:
                        custom_path = Path(custom_root).resolve()
                        if custom_path.exists() and custom_path.is_dir():
                            tree = self.build_tree(custom_path)
                            tree['resolved_path'] = str(custom_path)
                            return self.send_json(tree)
                        else:
                            return self.send_json({'error': 'Path does not exist or is not a directory'}, 400)
                    except Exception as e:
                        return self.send_json({'error': f'Invalid path: {str(e)}'}, 400)

                tree = self.build_tree(ROOT)
                tree['resolved_path'] = str(ROOT.resolve())
                return self.send_json(tree)
            if path == '/api/architectures':
                ARCH_DIR.mkdir(parents=True, exist_ok=True)
                items = []

                # Scan for monolithic files (.sysml and .json)
                for p in sorted(list(ARCH_DIR.glob('*.sysml')) + list(ARCH_DIR.glob('*.json'))):
                    try:
                        data = load_architecture(p)
                        items.append({
                            'id': data.get('id', p.stem),
                            'name': data.get('name', p.name),
                            'path': str(p.relative_to(ROOT)).replace('\\','/'),
                            'domain': data.get('domain',''),
                            'format': data.get('format', 'unknown')
                        })
                    except Exception as e:
                        items.append({
                            'id': p.stem,
                            'name': p.name,
                            'path': str(p.relative_to(ROOT)).replace('\\','/'),
                            'error': str(e)
                        })

                # Scan for separated directories (arch_NNNNNN/ with model.sysml)
                for p in sorted(ARCH_DIR.iterdir()):
                    if p.is_dir() and not p.name.startswith('.'):
                        model_file = p / 'model.sysml'
                        if model_file.exists():
                            try:
                                data = load_architecture_separated(p)
                                items.append({
                                    'id': data.get('id', p.name),
                                    'name': data.get('name', p.name),
                                    'path': str(p.relative_to(ROOT)).replace('\\','/'),
                                    'domain': data.get('domain',''),
                                    'format': 'separated',
                                    'available_views': data.get('available_views', [])
                                })
                            except Exception as e:
                                items.append({
                                    'id': p.name,
                                    'name': p.name,
                                    'path': str(p.relative_to(ROOT)).replace('\\','/'),
                                    'error': str(e),
                                    'format': 'separated'
                                })

                return self.send_json({'architectures': items})
            if path.startswith('/api/architecture/'):
                rel = unquote(path[len('/api/architecture/'):])

                # Check if this is a views or view subroute first
                if '/views' in rel or '/view/' in rel:
                    # Handle separately below
                    pass
                else:
                    p = safe_data_path(ROOT, rel)
                    if not p.exists(): return self.send_json({'error': 'not found'}, 404)

                    # Auto-detect format
                    fmt = detect_architecture_format(p)

                    if fmt == 'separated':
                        arch = load_architecture_separated(p)
                    elif fmt in ('monolithic', 'json'):
                        arch = load_architecture(p)
                    else:
                        return self.send_json({'error': 'unknown architecture format'}, 400)

                    return self.send_json(arch)

            # New endpoint: /api/architecture/<id>/views - List available views
            if '/views' in path and not '/view/' in path:
                # Extract architecture path before /views
                parts = path.split('/views')
                if len(parts) == 2:
                    arch_rel = unquote(parts[0][len('/api/architecture/'):])
                    arch_p = safe_data_path(ROOT, arch_rel)

                    if not arch_p.exists():
                        return self.send_json({'error': 'architecture not found'}, 404)

                    if not arch_p.is_dir():
                        # Monolithic architecture - no separate views
                        return self.send_json({'views': [], 'format': 'monolithic'})

                    views = list_views(arch_p)
                    return self.send_json({'views': views, 'format': 'separated'})

            # New endpoint: /api/architecture/<id>/view/<view_name> - Get specific view
            if '/view/' in path:
                # Extract architecture path and view name
                match_parts = path.split('/view/')
                if len(match_parts) == 2:
                    arch_rel = unquote(match_parts[0][len('/api/architecture/'):])
                    view_name = unquote(match_parts[1])

                    arch_p = safe_data_path(ROOT, arch_rel)
                    if not arch_p.exists() or not arch_p.is_dir():
                        return self.send_json({'error': 'architecture directory not found'}, 404)

                    # Load the specific view file
                    view_file = arch_p / 'views' / f'{view_name}.sysml'
                    if not view_file.exists():
                        return self.send_json({'error': f'view {view_name} not found'}, 404)

                    try:
                        # First load the base model
                        arch = load_architecture_separated(arch_p)

                        # Then parse the view file content for metadata
                        view_content = view_file.read_text(encoding='utf-8')
                        view_data = parse_sysml_to_json(view_content)

                        # Merge view metadata into architecture
                        arch['view'] = {
                            'name': view_name,
                            'content': view_data
                        }

                        return self.send_json(arch)
                    except Exception as e:
                        return self.send_json({'error': str(e)}, 500)

            if path == '/api/pair-files':
                PAIR_DIR.mkdir(parents=True, exist_ok=True)
                files = [{'name': p.name, 'path': str(p.relative_to(ROOT)).replace('\\','/')} for p in sorted(PAIR_DIR.glob('*.json'))]
                return self.send_json({'pair_files': files})
            if path.startswith('/api/pairs/'):
                rel = unquote(path[len('/api/pairs/'):])
                p = safe_data_path(ROOT, rel)
                if not p.exists(): return self.send_json({'error': 'not found'}, 404)
                return self.send_json(json.loads(p.read_text(encoding='utf-8')))
            if path.startswith('/api/diagram/bdd/'):
                rel = unquote(path[len('/api/diagram/bdd/'):])
                p = safe_data_path(ROOT, rel)
                if not p.exists(): return self.send_json({'error': 'not found'}, 404)

                # Auto-detect format
                fmt = detect_architecture_format(p)
                if fmt == 'json':
                    # Legacy JSON format - need to convert to .sysml first
                    # For now, load and use old method
                    arch = load_architecture(p)
                    # TODO: This should eventually write a temp .sysml file
                    # For now, we'll need to keep backward compat with JSON
                    return self.send_json({'error': 'JSON format not supported for diagram generation. Convert to .sysml first.'}, 400)
                elif fmt in ('separated', 'monolithic'):
                    # Pass the path directly to the generator
                    # It will handle parsing internally
                    plantuml_src = generate_bdd_plantuml(p)
                    encoded = plantuml_encode(plantuml_src)
                    return self.send_json({
                        'plantuml': plantuml_src,
                        'url': f'http://www.plantuml.com/plantuml/png/{encoded}'
                    })
                else:
                    return self.send_json({'error': 'unknown architecture format'}, 400)
            if path.startswith('/api/diagram/ibd/'):
                rel = unquote(path[len('/api/diagram/ibd/'):])
                p = safe_data_path(ROOT, rel)
                if not p.exists(): return self.send_json({'error': 'not found'}, 404)

                # Auto-detect format
                fmt = detect_architecture_format(p)
                if fmt == 'json':
                    # Legacy JSON format - need to convert to .sysml first
                    return self.send_json({'error': 'JSON format not supported for diagram generation. Convert to .sysml first.'}, 400)
                elif fmt in ('separated', 'monolithic'):
                    # Pass the path directly to the generator
                    # It will handle parsing internally
                    plantuml_src = generate_ibd_plantuml(p)
                    encoded = plantuml_encode(plantuml_src)
                    return self.send_json({
                        'plantuml': plantuml_src,
                        'url': f'http://www.plantuml.com/plantuml/png/{encoded}'
                    })
                else:
                    return self.send_json({'error': 'unknown architecture format'}, 400)
            return self.serve_static(path)
        except Exception as e:
            return self.send_json({'error': str(e)}, 500)

    def do_POST(self):
        parsed = urlparse(self.path)
        try:
            if parsed.path == '/api/save-pairs':
                body = self.read_body_json()
                filename = body.get('filename') or 'authored_pairs.json'
                if not filename.endswith('.json'):
                    filename += '.json'
                # basename only, because this endpoint owns data/pairs.
                filename = Path(filename).name
                records = body.get('records')
                if not isinstance(records, list):
                    return self.send_json({'error': 'records must be a list'}, 400)
                PAIR_DIR.mkdir(parents=True, exist_ok=True)
                out = PAIR_DIR / filename
                out.write_text(json.dumps(records, indent=2), encoding='utf-8')
                return self.send_json({'ok': True, 'path': str(out.relative_to(ROOT)).replace('\\','/'), 'records': len(records)})
            return self.send_json({'error': 'unknown endpoint'}, 404)
        except Exception as e:
            return self.send_json({'error': str(e)}, 500)

    def serve_static(self, path):
        if path == '/': path = '/index.html'
        rel = path.lstrip('/')
        p = (STATIC / rel).resolve()
        if STATIC.resolve() not in p.parents and p != STATIC.resolve():
            return self.send_json({'error': 'bad static path'}, 400)
        if not p.exists() or not p.is_file():
            return self.send_json({'error': 'not found'}, 404)
        ctype = mimetypes.guess_type(str(p))[0] or 'application/octet-stream'
        body = p.read_bytes()
        self.send_response(200)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--host', default=os.environ.get('APP_HOST', '127.0.0.1'))
    ap.add_argument('--port', type=int, default=int(os.environ.get('APP_PORT', '8765')))
    args = ap.parse_args()
    httpd = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f'Serving Python-only pair authoring SPA at http://{args.host}:{args.port}')
    httpd.serve_forever()

if __name__ == '__main__':
    main()
