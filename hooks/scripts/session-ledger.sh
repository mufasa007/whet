#!/usr/bin/env bash
# SessionStart hook: if the project has an active long-horizon batch ledger,
# surface it so the session resumes from the ledger instead of from memory.
set -euo pipefail

PLAN_ROOT="${CLAUDE_PROJECT_DIR:-.}/.whet/plan"

if [[ -d "$PLAN_ROOT" ]]; then
  # 优先按修改时间排序，字典序作为 fallback。
  LATEST=""
  if find "$PLAN_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' >/dev/null 2>&1; then
    # GNU find
    LATEST="$(find "$PLAN_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n1 | cut -d' ' -f2-)"
  elif stat -f '%m' /dev/null >/dev/null 2>&1; then
    # BSD stat (macOS)
    LATEST="$(find "$PLAN_ROOT" -mindepth 1 -maxdepth 1 -type d -exec stat -f '%m %N' {} + 2>/dev/null | sort -rn | head -n1 | cut -d' ' -f2-)"
  else
    # GNU stat
    LATEST="$(find "$PLAN_ROOT" -mindepth 1 -maxdepth 1 -type d -exec stat -c '%Y %n' {} + 2>/dev/null | sort -rn | head -n1 | cut -d' ' -f2-)"
  fi
  [[ -z "$LATEST" ]] && LATEST="$(find "$PLAN_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n1)"
  if [[ -n "$LATEST" && -f "$LATEST/plan.md" ]]; then
    echo "This project has a long-horizon task ledger; latest batch: ${LATEST}."
    echo "Before starting work, read ${LATEST}/plan.md, issues.md, and progress.md"
    echo "to resume from recorded state (see the long-task-scheduler skill)."
  fi
fi

exit 0
