# Python SPA Adapter Ralph Loop

This is the corrected deployable for authoring adapter-training pairs by hand in a local SPA.

It does not require npm.

## Architecture Format

This project generates SysML v2 (.sysml) files as the primary output format. JSON IR is available as an optional secondary format for academic/training purposes.

## Run checks

```bash
cp ralph/config.example.env ralph/config.env
bash ralph/check_env.sh
bash ralph/mega_ralph.sh
```

## Run the SPA

```bash
python3 spa/server.py --host 127.0.0.1 --port 8765
```

Open:

```text
http://127.0.0.1:8765
```

## Generate Architectures

Generate sample architectures (primary output is .sysml files):

```bash
# Generate 3 sample architectures as .sysml
python3 scripts/generate_sample_architectures.py

# Also generate JSON IR for academic purposes
python3 scripts/generate_sample_architectures.py --json

# Generate varied architectures
python3 scripts/generate_varied_architectures.py --count 50

# With JSON IR
python3 scripts/generate_varied_architectures.py --count 50 --json
```

Convert existing JSON IR to .sysml (for legacy/academic files):

```bash
python3 scripts/json_to_sysml.py
python3 scripts/json_to_sysml.py --input data/architectures_json/arch_000001.json
```

## Workflow

1. Load an architecture target (.sysml or .json).
2. Write a human-authored prompt.
3. Add it as a pair.
4. Save to `data/pairs/authored_pairs.json` or another filename.
5. Later, reload that completed pair file for editing.
6. Convert to dataset:

```bash
python3 scripts/validate_pairs.py data/pairs/authored_pairs.json
python3 scripts/prepare_dataset.py data/pairs/authored_pairs.json
```
