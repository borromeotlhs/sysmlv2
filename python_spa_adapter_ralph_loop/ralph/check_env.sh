#!/usr/bin/env bash
set -euo pipefail
PYTHON_CMD=${PYTHON_CMD:-python3}
if ! command -v "$PYTHON_CMD" >/dev/null 2>&1; then
  echo "ERROR: Python command '$PYTHON_CMD' not found." >&2
  exit 1
fi
"$PYTHON_CMD" - <<'PY'
import sys, json, http.server
print('python ok:', sys.version.split()[0])
PY
echo "Environment check passed: Python-only SPA runtime is available."
