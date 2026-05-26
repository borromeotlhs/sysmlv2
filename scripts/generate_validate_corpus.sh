#!/usr/bin/env bash
# End-to-end pipeline: generate -> render -> validate -> corpus
set -euo pipefail

# Defaults
COUNT=5
SEED=42
PREFIX="model"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --count)
      COUNT="$2"
      shift 2
      ;;
    --seed)
      SEED="$2"
      shift 2
      ;;
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--count N] [--seed S] [--prefix P]"
      exit 1
      ;;
  esac
done

echo "======================================"
echo "SysML v2 Generator Pipeline"
echo "======================================"
echo "Count: $COUNT"
echo "Seed: $SEED"
echo "Prefix: $PREFIX"
echo ""

# Step 1: Extract rules
echo "[pipeline] Step 1: Extracting rules..."
python3 scripts/extract_rules.py \
  --output output/rules/rules.json
echo ""

# Step 2: Generate IR
echo "[pipeline] Step 2: Generating IR..."
python3 scripts/generate_ir.py \
  --rules output/rules/rules.json \
  --output-dir output/candidates \
  --count "$COUNT" \
  --seed "$SEED" \
  --prefix "$PREFIX"
echo ""

# Step 3: Render to SysML
echo "[pipeline] Step 3: Rendering to SysML..."
python3 scripts/render_ir.py \
  output/candidates \
  --output output/candidates
echo ""

# Step 4: Validate and sort
echo "[pipeline] Step 4: Validating SysML files..."

# Clear previous outputs
rm -rf output/valid/* output/invalid/* 2>/dev/null || true
mkdir -p output/valid output/invalid

valid_count=0
invalid_count=0

for sysml_file in output/candidates/*.sysml; do
  if [ ! -f "$sysml_file" ]; then
    continue
  fi

  basename=$(basename "$sysml_file" .sysml)
  validation_file="${basename}.validation.json"

  echo "  Validating: $basename"

  # Run validator
  if python3 scripts/validate_sysml.py \
      "$sysml_file" \
      --output "output/valid/${validation_file}" \
      > /dev/null 2>&1; then
    # Valid - move to valid/
    cp "$sysml_file" "output/valid/"
    valid_count=$((valid_count + 1))
    echo "    ✓ VALID"
  else
    # Invalid - move to invalid/
    cp "$sysml_file" "output/invalid/"
    mv "output/valid/${validation_file}" "output/invalid/" 2>/dev/null || true
    # Re-run validator to get validation JSON in invalid dir
    python3 scripts/validate_sysml.py \
      "$sysml_file" \
      --output "output/invalid/${validation_file}" \
      > /dev/null 2>&1 || true
    invalid_count=$((invalid_count + 1))
    echo "    ✗ INVALID"
  fi
done

echo ""
echo "[pipeline] Validation complete:"
echo "  Valid: $valid_count"
echo "  Invalid: $invalid_count"
echo ""

# Step 5: Build corpus
echo "[pipeline] Step 5: Building corpus..."
python3 scripts/build_corpus.py \
  --valid-dir output/valid \
  --invalid-dir output/invalid \
  --candidates-dir output/candidates \
  --output output/corpus/train.jsonl \
  --repair-output output/corpus/repair.jsonl
echo ""

echo "======================================"
echo "Pipeline complete!"
echo "======================================"
echo "Results:"
echo "  Valid examples: output/valid/"
echo "  Invalid examples: output/invalid/"
echo "  Training corpus: output/corpus/train.jsonl"
echo "  Repair corpus: output/corpus/repair.jsonl"
echo ""
