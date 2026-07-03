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
- `python3 -m json.tool < .claude-plugin/plugin.json` — validate JSON
- Load locally: `claude --plugin-dir .` then check `/agents`, `/help` for the
  whet commands, and trigger a skill to confirm frontmatter parses.

## Release process

Users install from GitHub via `/plugin marketplace add mufasa007/whet`;
updates are pulled from `main`, so **main must always be installable**.

1. Develop on a feature branch; merge to `main` only after local validation
   (`claude --plugin-dir .`).
2. On release: bump `version` in `.claude-plugin/plugin.json` AND
   `.claude-plugin/marketplace.json` (keep them identical), add a CHANGELOG.md
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
