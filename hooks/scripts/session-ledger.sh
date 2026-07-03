#!/usr/bin/env bash
# SessionStart hook: if the project has an active long-horizon task ledger,
# surface it so the session resumes from the ledger instead of from memory.
set -euo pipefail

LEDGER=".whet/plan/tasks.md"

if [[ -f "$LEDGER" ]]; then
  echo "This project has an active long-horizon task ledger at ${LEDGER}."
  echo "Before starting work, read .whet/plan/PLAN.md and ${LEDGER} to resume"
  echo "from recorded state (see the long-task-scheduler skill)."
fi

exit 0
