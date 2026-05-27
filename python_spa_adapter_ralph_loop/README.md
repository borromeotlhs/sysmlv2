# Python SPA Adapter Ralph Loop

This is the corrected deployable for authoring adapter-training pairs by hand in a local SPA.

It does not require npm.

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

## Workflow

1. Load an architecture target.
2. Write a human-authored prompt.
3. Add it as a pair.
4. Save to `data/pairs/authored_pairs.json` or another filename.
5. Later, reload that completed pair file for editing.
6. Convert to dataset:

```bash
python3 scripts/validate_pairs.py data/pairs/authored_pairs.json
python3 scripts/prepare_dataset.py data/pairs/authored_pairs.json
```
