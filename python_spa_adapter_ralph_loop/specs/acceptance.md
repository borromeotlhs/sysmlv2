# Acceptance Criteria

`bash ralph/run_mvp_checks.sh` must:

1. Confirm required files exist.
2. Generate sample architecture targets.
3. Generate a demo editable pair file.
4. Validate the pair file.
5. Prepare train/validation JSONL.
6. Start `spa/server.py`.
7. Verify `/api/health` reports Python-only runtime.
8. Verify `/`, `/api/architectures`, `/api/pair-files`, and pair loading work.
9. Verify saving edited/completed pair files works.
10. Fail if any of the above does not work.
