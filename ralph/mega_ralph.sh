#!/usr/bin/env bash
set -euo pipefail

if [ -f ralph/config.env ]; then
  # shellcheck disable=SC1091
  source ralph/config.env
else
  # shellcheck disable=SC1091
  source ralph/config.example.env
fi

MAX_ITERS="${RALPH_MAX_ITERS:-12}"
MODEL="${RALPH_MODEL:-sonnet}"
PERMISSION_MODE="${RALPH_PERMISSION_MODE:-acceptEdits}"
TASK_FILE="${RALPH_TASK_FILE:-tasks/mega_task.md}"
CHECK_CMD="${RALPH_CHECK_CMD:-./ralph/run_mvp_checks.sh}"
ALLOWED_TOOLS="${RALPH_ALLOWED_TOOLS:-Read,Write,Edit,MultiEdit,Glob,Grep,Bash,Task}"
DISALLOWED_TOOLS="${RALPH_DISALLOWED_TOOLS:-}"
VERBOSE="${RALPH_VERBOSE:-0}"

mkdir -p output/ralph_logs

if [ ! -f "$TASK_FILE" ]; then
  echo "[mega-ralph] Missing task file: $TASK_FILE"
  exit 2
fi

base_prompt="$(cat "$TASK_FILE")"

call_claude() {
  local prompt="$1"
  local log="$2"

  if [ "$VERBOSE" = "1" ]; then
    echo "===== PROMPT ====="
    echo "$prompt"
    echo "=================="
  fi

  local args=(-p "$prompt" --model "$MODEL" --permission-mode "$PERMISSION_MODE" --allowedTools "$ALLOWED_TOOLS")

  if [ -n "$DISALLOWED_TOOLS" ]; then
    args+=(--disallowedTools "$DISALLOWED_TOOLS")
  fi

  claude "${args[@]}" | tee "$log"
}

echo "[mega-ralph] Starting initial implementation pass..."
initial_prompt=$(cat <<EOF
You are running a Mega Ralph Loop for a SysML v2 generator MVP.

Read and follow:
- tasks/mega_task.md
- specs/architecture.md
- specs/ir_schema_v0.md
- specs/mvp_acceptance.md
- .claude/agents/*

Use project subagents where useful:
- sysml-validator-engineer
- grammar-rule-extractor
- ir-generator-engineer
- sysml-renderer-engineer
- corpus-pipeline-engineer
- integration-reviewer

Implement the MVP in small testable increments. Continue until this command is expected to pass:

$CHECK_CMD

Task:

$base_prompt
EOF
)

call_claude "$initial_prompt" "output/ralph_logs/iter_00_initial.log"

for i in $(seq 1 "$MAX_ITERS"); do
  echo "[mega-ralph] Running check iteration $i..."
  set +e
  bash -lc "$CHECK_CMD" >"output/ralph_logs/check_${i}.log" 2>&1
  status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    echo "[mega-ralph] PASS on iteration $i"
    cat "output/ralph_logs/check_${i}.log"
    exit 0
  fi

  echo "[mega-ralph] Check failed on iteration $i. Feeding diagnostics back to Claude..."

  diag="$(tail -n 240 output/ralph_logs/check_${i}.log)"

  repair_prompt=$(cat <<EOF
The Mega Ralph MVP check failed.

Run/inspect as needed, then repair the implementation. Use the project subagents where useful. Make the smallest coherent changes that move the MVP toward passing.

Check command:
$CHECK_CMD

Failure output:
\`\`\`
$diag
\`\`\`

Acceptance target:
- ./scripts/generate_validate_corpus.sh --count 5 --seed 42 works.
- output/valid contains at least one .sysml file.
- output/corpus/train.jsonl exists.
- Python files compile.
- Tests pass if present.

After repairs, stop and let the Ralph loop run the checks again.
EOF
)
  call_claude "$repair_prompt" "output/ralph_logs/iter_${i}_repair.log"
done

echo "[mega-ralph] FAILED after $MAX_ITERS iterations."
echo "[mega-ralph] Last check log:"
tail -n 240 "output/ralph_logs/check_${MAX_ITERS}.log" || true
exit 1
