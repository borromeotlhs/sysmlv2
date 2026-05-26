#!/usr/bin/env bash
set -euo pipefail

echo "[mvp-check] Checking required directories..."
for d in scripts tools tests specs output; do
  if [ ! -d "$d" ]; then
    echo "[mvp-check] Missing directory: $d"
    exit 1
  fi
done

echo "[mvp-check] Checking required scripts..."
required_scripts=(
  "scripts/generate_validate_corpus.sh"
  "scripts/render_ir.py"
  "scripts/generate_ir.py"
  "scripts/validate_sysml.py"
  "scripts/extract_rules.py"
  "scripts/build_corpus.py"
)

for f in "${required_scripts[@]}"; do
  if [ ! -f "$f" ]; then
    echo "[mvp-check] Missing required file: $f"
    exit 1
  fi
done

echo "[mvp-check] Checking Python syntax..."
python3 -m py_compile scripts/*.py

echo "[mvp-check] Running unit tests if present..."
if [ -d tests ]; then
  if command -v pytest >/dev/null 2>&1 && find tests -name 'test_*.py' | grep -q .; then
    pytest -q
  else
    echo "[mvp-check] pytest or tests not found; skipping pytest."
  fi
fi

echo "[mvp-check] Running end-to-end corpus generation smoke test..."
chmod +x scripts/generate_validate_corpus.sh
./scripts/generate_validate_corpus.sh --count 5 --seed 42

echo "[mvp-check] Checking generated outputs..."
valid_count=$(find output/valid -name '*.sysml' 2>/dev/null | wc -l | tr -d ' ')
if [ "$valid_count" -lt 1 ]; then
  echo "[mvp-check] Expected at least one valid .sysml file in output/valid"
  exit 1
fi

test -f output/corpus/train.jsonl

echo "[mvp-check] PASS"
