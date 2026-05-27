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


def load_architecture(file_path: Path) -> dict:
    """Load architecture from either JSON or .sysml file"""
    content = file_path.read_text(encoding='utf-8')

    # Detect format by extension
    if file_path.suffix.lower() == '.sysml':
        # Parse SysML v2 textual syntax
        return parse_sysml_to_json(content)
    else:
        # Assume JSON
        return json.loads(content)


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


def generate_bdd_plantuml(arch: dict) -> str:
    """Generate Block Definition Diagram PlantUML from architecture JSON"""
    lines = ['@startuml', 'skinparam componentStyle rectangle', '']

    # Add blocks
    for block in arch.get('blocks', []):
        name = block.get('name', 'Unknown')
        lines.append(f'class {name} <<block>>')

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

    # Add relationships
    for rel in arch.get('relationships', []):
        client = rel.get('client', '')
        supplier = rel.get('supplier', '').replace('-', '_')  # Handle requirement IDs
        rel_type = rel.get('type', 'trace')
        lines.append(f'{client} ..> {supplier} : <<{rel_type}>>')

    lines.append('@enduml')
    return '\n'.join(lines)


def generate_ibd_plantuml(arch: dict) -> str:
    """Generate Internal Block Diagram PlantUML from architecture JSON

    Style based on SysML v2 IBD conventions with parts as rectangles,
    ports on edges, and labeled connections.
    """
    lines = ['@startuml']
    lines.append('!define PART_BG_COLOR #FEFECE')
    lines.append('!define PORT_COLOR #ADD1B2')
    lines.append('')
    lines.append('skinparam rectangle {')
    lines.append('    BackgroundColor PART_BG_COLOR')
    lines.append('    BorderColor #A80036')
    lines.append('    FontSize 11')
    lines.append('}')
    lines.append('skinparam component {')
    lines.append('    BackgroundColor PORT_COLOR')
    lines.append('    BorderColor #18A558')
    lines.append('    FontSize 9')
    lines.append('}')
    lines.append('')

    # Build port ownership map
    port_owners = {}
    for port in arch.get('proxy_ports', []):
        owner = port.get('owner', '')
        if owner not in port_owners:
            port_owners[owner] = []
        port_owners[owner].append(port)

    blocks = arch.get('blocks', [])

    # System frame
    system_name = blocks[0].get('name', 'System') if blocks else 'System'
    lines.append(f'package "ibd [Block] {system_name}" {{')
    lines.append('')

    # Add parts (subsystems) as rectangles with ports
    for block in blocks[1:]:  # Skip system block
        name = block.get('name', 'Unknown')
        part_name = name.lower()

        lines.append(f'  rectangle "{part_name} : {name}" as {part_name} {{')

        # Add ports inside the part
        if name in port_owners:
            for port in port_owners[name]:
                port_name = port.get('name', '')
                port_type = port.get('type', '')
                port_id = f'{part_name}_{port_name}'
                lines.append(f'    component "p\\n:{port_type}" as {port_id}')

        lines.append('  }')
        lines.append('')

    # Add connections between ports
    connectors = arch.get('connectors', [])
    if connectors:
        lines.append('  \' Connections')
        for conn in connectors:
            end_a = conn.get('end_a', '')
            end_b = conn.get('end_b', '')
            flow = conn.get('item_flow', '')

            if '.' in end_a and '.' in end_b:
                part_a, port_a = end_a.split('.', 1)
                part_b, port_b = end_b.split('.', 1)

                part_a_lower = part_a.lower()
                part_b_lower = part_b.lower()

                port_a_id = f'{part_a_lower}_{port_a}'
                port_b_id = f'{part_b_lower}_{port_b}'

                label = flow if flow else ''
                lines.append(f'  {port_a_id} --> {port_b_id} : {label}')

    lines.append('}')
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
                # Scan for both .sysml (primary) and .json (legacy/academic) files
                for p in sorted(list(ARCH_DIR.glob('*.sysml')) + list(ARCH_DIR.glob('*.json'))):
                    try:
                        data = load_architecture(p)
                        items.append({'id': data.get('id', p.stem), 'name': data.get('name', p.name), 'path': str(p.relative_to(ROOT)).replace('\\','/'), 'domain': data.get('domain','')})
                    except Exception as e:
                        items.append({'id': p.stem, 'name': p.name, 'path': str(p.relative_to(ROOT)).replace('\\','/'), 'error': str(e)})
                return self.send_json({'architectures': items})
            if path.startswith('/api/architecture/'):
                rel = unquote(path[len('/api/architecture/'):])
                p = safe_data_path(ROOT, rel)
                if not p.exists(): return self.send_json({'error': 'not found'}, 404)
                arch = load_architecture(p)
                return self.send_json(arch)
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
                arch = load_architecture(p)
                plantuml_src = generate_bdd_plantuml(arch)
                encoded = plantuml_encode(plantuml_src)
                return self.send_json({
                    'plantuml': plantuml_src,
                    'url': f'http://www.plantuml.com/plantuml/png/{encoded}'
                })
            if path.startswith('/api/diagram/ibd/'):
                rel = unquote(path[len('/api/diagram/ibd/'):])
                p = safe_data_path(ROOT, rel)
                if not p.exists(): return self.send_json({'error': 'not found'}, 404)
                arch = load_architecture(p)
                plantuml_src = generate_ibd_plantuml(arch)
                encoded = plantuml_encode(plantuml_src)
                return self.send_json({
                    'plantuml': plantuml_src,
                    'url': f'http://www.plantuml.com/plantuml/png/{encoded}'
                })
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
