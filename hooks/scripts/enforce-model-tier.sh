#!/usr/bin/env bash
# PreToolUse hook (Task|Agent): while a long-horizon batch ledger exists
# (.whet/plan/), dispatching a whet agent without an explicit `model`
# parameter is blocked (exit 2) so the tier choice stays deliberate instead
# of silently inheriting the session flagship. See skills/model-router.
# quick-scout is exempt: its frontmatter already pins the fast family.
# Parse failures and non-whet agents always pass (never break normal flow).
set -euo pipefail

# Only guard projects with an active batch ledger.
[[ -d "${CLAUDE_PROJECT_DIR:-.}/.whet/plan" ]] || exit 0

INPUT="$(cat)"

# Extract fields from tool_input JSON without requiring jq. Escaped quotes
# inside string values (\") cannot match the '"key"' patterns, so content
# in `prompt` cannot spoof these keys.
SUBAGENT="$(printf '%s' "$INPUT" | sed -n 's/.*"subagent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
MODEL="$(printf '%s' "$INPUT" | sed -n 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"

[[ -z "$SUBAGENT" ]] && exit 0

# Strip the plugin namespace if present (whet:backend-dev -> backend-dev).
SUBAGENT="${SUBAGENT##*:}"

case "$SUBAGENT" in
  architect|backend-dev|frontend-dev|mobile-dev|devops-engineer|qa-tester|code-reviewer|task-reviewer|product-manager|uiux-designer|security-engineer|data-engineer|tech-writer)
    if [[ -z "$MODEL" ]]; then
      {
        echo "[model-tier guard] Dispatching ${SUBAGENT} without an explicit \`model\` while a"
        echo "batch ledger is active — blocked so the tier choice stays deliberate."
        echo "Score the task per the model-router rubric (reasoning depth / blast radius /"
        echo "context integration), then redispatch with model=<family alias>, mapping the"
        echo "tier onto what the Agent tool's model parameter currently exposes:"
        echo "  T3 fast           — read-only scouting, mechanical edits, reconciliation"
        echo "  T2 balanced       — routine implementation, tests, routine review (default)"
        echo "  T1 deep reasoning — architecture, stuck root-cause, gate/security review"
        echo "  T0 extreme        — top flagship, above T1 (Claude Code: model=fable);"
        echo "                      architecture design & blocking decisions pre-authorized"
        echo "Note tier + model + one-line reason in the dispatch, per the batch ledger."
      } >&2
      exit 2
    fi
    ;;
esac

exit 0
