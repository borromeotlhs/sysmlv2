#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
if [ -f ralph/config.env ]; then
  # shellcheck disable=SC1091
  source ralph/config.env
elif [ -f ralph/config.example.env ]; then
  # shellcheck disable=SC1091
  source ralph/config.example.env
fi
MAX_ITERATIONS=${MAX_ITERATIONS:-8}
CHECK_CMD=${CHECK_CMD:-bash ralph/run_mvp_checks.sh}
CLAUDE_CMD=${CLAUDE_CMD:-claude}
CLAUDE_ENV=${CLAUDE_ENV:-WORK_ENV}
mkdir -p logs
for i in $(seq 1 "$MAX_ITERATIONS"); do
  echo "=== Ralph iteration $i/$MAX_ITERATIONS ==="
  if bash -lc "$CHECK_CMD"; then
    echo "Ralph loop complete: checks passed on iteration $i."
    exit 0
  fi
  status=$?
  echo "Checks failed with status $status; preparing Claude repair prompt."
  PROMPT="logs/ralph_prompt_${i}.md"
  cat > "$PROMPT" <<PROMPT_EOF
You are repairing a Python-only SPA Ralph loop deployable for adapter-training pair authoring.

Environment: ${CLAUDE_ENV}

Hard constraints:
- Do not require npm, node, vite, React, or external packages.
- The SPA must be served by Python standard library only.
- The browser UI must allow authoring prompt → architecture pairs.
- The UI must load an existing completed pair JSON for editing.
- Checks must fail if the Python server or app API does not work.
- Do not skip the main app test and then report success.

Run this check command until it passes:

\`\`\`bash
${CHECK_CMD}
\`\`\`
PROMPT_EOF
  if command -v "$CLAUDE_CMD" >/dev/null 2>&1; then
    echo "Calling Claude Code with $PROMPT"
    "$CLAUDE_CMD" < "$PROMPT" || true
  else
    echo "Claude command '$CLAUDE_CMD' not found. Repair prompt written to $PROMPT" >&2
    exit "$status"
  fi
done
echo "Ralph loop failed: checks did not pass after $MAX_ITERATIONS iterations." >&2
exit 1
