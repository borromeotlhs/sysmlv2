# Claude Instructions

This project is a Ralph loop deployable for a Python-only SPA.

Use `CLAUDE_ENV` from `ralph/config.env` to guide environment assumptions. In WORK_ENV, assume npm/node may be unavailable. Do not change the acceptance checks to skip the actual app test.

Primary check:

```bash
bash ralph/run_mvp_checks.sh
```
