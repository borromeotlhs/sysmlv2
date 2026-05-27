# Mega Ralph Task: Python-only SPA for adapter pair authoring

Build and maintain a local SPA that lets a human author prompt → architecture pairs for adapter training.

Hard requirements:
- No npm/node/vite/React dependency.
- Python standard library server only.
- Static browser UI must load architecture JSON files.
- Static browser UI must create new prompt → target pairs.
- Static browser UI must load existing completed pair JSON files for editing.
- Static browser UI must save edited pair files back to data/pairs.
- Dataset builder converts pair files into train/validation JSONL.
- Checks must verify the Python server and endpoints actually work.
- Checks must fail rather than skip the main app validation.

Use `CLAUDE_ENV` to document environment assumptions. For the user’s WORK_ENV, assume Python is available and npm may not be.
