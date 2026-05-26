#!/usr/bin/env bash
set -euo pipefail

echo "[check_env] Checking Claude Code..."
if ! command -v claude >/dev/null 2>&1; then
  echo "[check_env] ERROR: claude command not found on PATH."
  exit 1
fi

echo "[check_env] Claude found: $(command -v claude)"

echo "[check_env] Checking project files..."
test -f tasks/mega_task.md
test -f ralph/run_mvp_checks.sh
test -d .claude/agents

echo "[check_env] OK"
