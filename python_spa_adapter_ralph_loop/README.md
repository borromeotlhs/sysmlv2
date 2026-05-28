# Python SPA Adapter Ralph Loop

![Tests](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Test%20Suite/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-check%20report-blue)

This is the corrected deployable for authoring adapter-training pairs by hand in a local SPA.

It does not require npm.

## Architecture Format

This project generates SysML v2 (.sysml) files as the primary output format. JSON IR is available as an optional secondary format for academic/training purposes.

## Testing

Run the complete test suite:

```bash
# Install test dependencies
pip install -r requirements-test.txt

# Run all tests
python tests/run_tests.py

# Run specific suite
python tests/run_tests.py --suite parser
python tests/run_tests.py --suite validation
python tests/run_tests.py --suite integration

# Run with coverage
python tests/run_tests.py --coverage --html

# Run in parallel
python tests/run_tests.py --parallel
```

See [tests/README.md](tests/README.md) for detailed documentation.

## Run checks

```bash
cp ralph/config.example.env ralph/config.env
bash ralph/check_env.sh
bash ralph/mega_ralph.sh
```

## Run the SPA

### Start the server:
```bash
python3 spa/server.py
```

Default address: http://127.0.0.1:5000

Or specify host/port:
```bash
python3 spa/server.py --host 127.0.0.1 --port 8765
```

Run in background:
```bash
python3 spa/server.py > logs/server.log 2>&1 &
```

### Check if server is running:
```bash
ps aux | grep "python.*server.py" | grep -v grep
```

Or check the port:
```bash
lsof -i :5000
```

### Stop the server:
```bash
pkill -f "python.*server.py"
```

Or kill specific PID:
```bash
kill <PID>
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
