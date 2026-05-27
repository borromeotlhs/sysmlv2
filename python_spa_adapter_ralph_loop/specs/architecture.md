# Architecture

This deployable uses a Python standard-library HTTP server:

- `spa/server.py` serves static files from `spa/static`.
- API endpoints expose architecture target files and pair files.
- `spa/static/app.js` implements the pair-authoring UI.
- `scripts/prepare_dataset.py` converts edited pair records into chat-message JSONL for adapter training.

No external Python packages, npm packages, or build system are required.
