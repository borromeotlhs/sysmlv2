#!/usr/bin/env bash
set -euo pipefail
PYTHON_CMD=${PYTHON_CMD:-python3}
APP_HOST=${APP_HOST:-127.0.0.1}
APP_PORT=${APP_PORT:-8765}
PAIR_FILE=${PAIR_FILE:-data/pairs/sample_pairs.json}

echo "Running Python-only SPA adapter MVP checks..."
[ -f spa/server.py ] || { echo "ERROR: missing spa/server.py" >&2; exit 1; }
[ -f spa/static/index.html ] || { echo "ERROR: missing SPA index.html" >&2; exit 1; }
[ -f spa/static/app.js ] || { echo "ERROR: missing SPA app.js" >&2; exit 1; }
[ -f scripts/validate_pairs.py ] || { echo "ERROR: missing validate_pairs.py" >&2; exit 1; }
echo "scaffold checks passed"

"$PYTHON_CMD" scripts/generate_sample_architectures.py
"$PYTHON_CMD" scripts/generate_demo_pairs.py
"$PYTHON_CMD" scripts/validate_pairs.py "$PAIR_FILE"
"$PYTHON_CMD" scripts/prepare_dataset.py "$PAIR_FILE"
"$PYTHON_CMD" scripts/evaluate_dataset.py

# Hard app test: start the Python SPA server and verify real endpoints.
export SPA_QUIET=1
"$PYTHON_CMD" spa/server.py --host "$APP_HOST" --port "$APP_PORT" > logs/spa_server_test.log 2>&1 &
SERVER_PID=$!
cleanup() {
  kill "$SERVER_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

"$PYTHON_CMD" - <<PY
import json, time, urllib.request, urllib.error, sys
base = 'http://${APP_HOST}:${APP_PORT}'
last = None
for _ in range(30):
    try:
        with urllib.request.urlopen(base + '/api/health', timeout=1) as r:
            data = json.loads(r.read().decode())
        if data.get('ok') and data.get('npm_required') is False:
            break
    except Exception as e:
        last = e
        time.sleep(0.2)
else:
    raise SystemExit(f'ERROR: Python SPA server did not become healthy: {last}')

for endpoint in ['/','/api/architectures','/api/pair-files','/api/pairs/data%2Fpairs%2Fsample_pairs.json']:
    with urllib.request.urlopen(base + endpoint, timeout=2) as r:
        body = r.read().decode()
        if r.status != 200:
            raise SystemExit(f'ERROR: {endpoint} returned {r.status}')
        if endpoint == '/' and 'Adapter Pair Authoring SPA' not in body:
            raise SystemExit('ERROR: SPA index did not load expected title')

payload = json.dumps({'filename':'mvp_saved_pairs.json','records': json.load(open('${PAIR_FILE}', encoding='utf-8'))}).encode()
req = urllib.request.Request(base + '/api/save-pairs', data=payload, headers={'Content-Type':'application/json'}, method='POST')
with urllib.request.urlopen(req, timeout=2) as r:
    saved = json.loads(r.read().decode())
if not saved.get('ok'):
    raise SystemExit('ERROR: save-pairs endpoint failed')
print('Python SPA server/API checks passed')
PY

"$PYTHON_CMD" scripts/validate_pairs.py data/pairs/mvp_saved_pairs.json

echo "MVP checks passed."
