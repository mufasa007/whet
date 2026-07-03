#!/usr/bin/env bash
# SessionStart hook: if the project has an active long-horizon batch ledger,
# surface it so the session resumes from the ledger instead of from memory.
set -euo pipefail

PLAN_ROOT=".whet/plan"

if [[ -d "$PLAN_ROOT" ]]; then
  # Latest batch dir by name ({YYYYMMDD}-{NNN}-{slug} sorts chronologically).
  LATEST="$(find "$PLAN_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n1)"
  if [[ -n "$LATEST" && -f "$LATEST/plan.md" ]]; then
    echo "This project has a long-horizon task ledger; latest batch: ${LATEST}."
    echo "Before starting work, read ${LATEST}/plan.md, issues.md, and progress.md"
    echo "to resume from recorded state (see the long-task-scheduler skill)."
  fi
fi

exit 0
