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

ROOT = Path(__file__).resolve().parents[1]
STATIC = Path(__file__).resolve().parent / 'static'
ARCH_DIR = ROOT / 'data' / 'architectures'
PAIR_DIR = ROOT / 'data' / 'pairs'


def safe_data_path(base: Path, rel: str) -> Path:
    candidate = (base / rel).resolve()
    if base.resolve() not in candidate.parents and candidate != base.resolve():
        raise ValueError('path escapes data directory')
    return candidate


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
    """Generate Internal Block Diagram PlantUML from architecture JSON"""
    lines = ['@startuml', '']

    # Build port ownership map
    port_owners = {}
    for port in arch.get('proxy_ports', []):
        owner = port.get('owner', '')
        if owner not in port_owners:
            port_owners[owner] = []
        port_owners[owner].append(port)

    # Add components with ports as interfaces
    for block in arch.get('blocks', []):
        name = block.get('name', 'Unknown')
        lines.append(f'component [{name}] as {name}')

    lines.append('')

    # Add ports as separate interface elements
    for port in arch.get('proxy_ports', []):
        owner = port.get('owner', '')
        port_name = port.get('name', '')
        port_type = port.get('type', '')
        port_id = f'{owner}_{port_name}'
        lines.append(f'interface "{port_name}\\n:{port_type}" as {port_id}')
        lines.append(f'{owner} -- {port_id}')

    lines.append('')

    # Add connectors
    for conn in arch.get('connectors', []):
        end_a = conn.get('end_a', '').replace('.', '_')  # e.g., MissionComputer.cmdOut -> MissionComputer_cmdOut
        end_b = conn.get('end_b', '').replace('.', '_')
        flow = conn.get('item_flow', '')
        lines.append(f'{end_a} --> {end_b} : {flow}')

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
                for p in sorted(ARCH_DIR.glob('*.json')):
                    try:
                        data = json.loads(p.read_text(encoding='utf-8'))
                        items.append({'id': data.get('id', p.stem), 'name': data.get('name', p.name), 'path': str(p.relative_to(ROOT)).replace('\\','/'), 'domain': data.get('domain','')})
                    except Exception as e:
                        items.append({'id': p.stem, 'name': p.name, 'path': str(p.relative_to(ROOT)).replace('\\','/'), 'error': str(e)})
                return self.send_json({'architectures': items})
            if path.startswith('/api/architecture/'):
                rel = unquote(path[len('/api/architecture/'):])
                p = safe_data_path(ROOT, rel)
                if not p.exists(): return self.send_json({'error': 'not found'}, 404)
                return self.send_json(json.loads(p.read_text(encoding='utf-8')))
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
                arch = json.loads(p.read_text(encoding='utf-8'))
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
                arch = json.loads(p.read_text(encoding='utf-8'))
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
