# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Whet — development guide

This repo is a Claude Code plugin: agents, skills, commands, hooks, and spec
templates. There is no build step; Markdown and JSON are the product.

## Layout

- `agents/*.md` — subagent definitions (YAML frontmatter + system prompt)
- `skills/<name>/SKILL.md` — skills (frontmatter `name` must match dir name);
  `skills/long-task-scheduler/templates/` holds the batch-ledger templates
- `commands/*.md` — slash commands, exposed as `/whet:<file-stem>`
- `hooks/hooks.json` + `hooks/scripts/` — hook config and shell scripts
- `spec/templates/` — requirements/design/tasks templates used by spec-workflow
- `.claude-plugin/plugin.json` — plugin manifest (bump `version` on release)

## How the pieces fit

- `/whet:spec` drives `spec-workflow` → gated requirements/design/tasks docs
  in the **user's** `spec/<feature>/`. `/whet:plan` and `/whet:resume` drive
  `long-task-scheduler` → a per-batch ledger in the user's
  `.whet/plan/{YYYYMMDD}-{NNN}-{slug}/` (seeded from
  `skills/long-task-scheduler/templates/`).
- Execution/review are separated: executor agents only bring work to "ready
  for review"; only `task-reviewer`'s explicit verdict unlocks a phase commit.
- `model-router` defines the shared T1–T4 tier vocabulary referenced by
  plans, dispatch prompts, agents, and the hook message — this is why no file
  may hardcode a model name (tiers resolve to actual models at runtime).
- `hooks/hooks.json` wires: SessionStart → `session-ledger.sh` (detect latest
  batch ledger, prompt resume); PreToolUse Write|Edit →
  `protect-sensitive.sh`; PreToolUse Task|Agent → `enforce-model-tier.sh`
  (while a ledger exists, blocks dispatching a whet agent without an explicit
  `model`).

Cross-file couplings — keep in sync when changing one side:

- The whet agent list is **duplicated in the `case` statement of
  `hooks/scripts/enforce-model-tier.sh`** — adding/renaming/removing an agent
  must update it (`quick-scout` is deliberately absent: it's exempt).
- README's agent/skill/command tables exist in English AND the 中文说明
  section — update both.
- `.whet/plan/**` and `spec/**` referenced throughout are directories in the
  *user's* project, not this repo.

## Conventions

- Content language: English. README carries a Chinese section — keep both in
  sync when features change.
- Agent frontmatter: `name` matches file stem; `description` states WHEN to
  invoke (it drives automatic delegation); default `model: inherit`. Never
  hardcode specific model names — use family aliases (`haiku`, `sonnet`) only
  for intentionally cheap agents; capability tiers are expressed as T1–T4
  (see skills/model-router).
- Skill descriptions must name concrete triggers ("use when ...").
- Hook scripts: bash, `set -euo pipefail`, executable bit set, exit 2 to block
  a tool call, exit 0 otherwise. No dependency on jq.
- Keep every document tight; these files are loaded into model context —
  token-lean writing is a feature.

## Validating changes

- `bash -n hooks/scripts/*.sh` — syntax-check hook scripts
- `for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do python3 -m json.tool < "$f" > /dev/null; done` — validate all JSON
- Load locally: `claude --plugin-dir .` then check `/agents`, `/help` for the
  whet commands, and trigger a skill to confirm frontmatter parses.

## Release process

Users install from GitHub via `/plugin marketplace add mufasa007/whet`;
updates are pulled from `main`, so **main must always be installable**.

1. Develop on a feature branch; merge to `main` only after local validation
   (`claude --plugin-dir .`).
2. On release: bump `version` in `.claude-plugin/plugin.json` AND
   `.claude-plugin/marketplace.json` (keep them identical), update the README
   version badge to match, add a CHANGELOG.md
   entry (SemVer rules at the top of that file), update README if
   agents/skills/commands changed.
3. Commit as `release: vX.Y.Z`, tag `vX.Y.Z`, push with `--tags`.
4. Breaking changes (MAJOR) — renamed/removed agents, skills, commands,
   ledger-layout changes — must include a "Migration" note in CHANGELOG.md
   telling users what to update in their projects (e.g. old `.whet/plan/`
   ledgers keep working; only new batches use the new layout).

Compatibility rules:
- Never rename an agent/skill/command in a MINOR/PATCH release — users'
  muscle memory and project docs reference them.
- Ledger files already on users' disks (`.whet/plan/**`) are user data: new
  skill versions must keep reading old layouts or state the migration.
