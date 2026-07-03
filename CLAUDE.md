# Whet — development guide

This repo is a Claude Code plugin: agents, skills, commands, hooks, and spec
templates. There is no build step; Markdown and JSON are the product.

## Layout

- `agents/*.md` — subagent definitions (YAML frontmatter + system prompt)
- `skills/<name>/SKILL.md` — skills (frontmatter `name` must match dir name)
- `commands/*.md` — slash commands, exposed as `/whet:<file-stem>`
- `hooks/hooks.json` + `hooks/scripts/` — hook config and shell scripts
- `spec/templates/` — requirements/design/tasks templates used by spec-workflow
- `.claude-plugin/plugin.json` — plugin manifest (bump `version` on release)

## Conventions

- Content language: English. README carries a Chinese section — keep both in
  sync when features change.
- Agent frontmatter: `name` matches file stem; `description` states WHEN to
  invoke (it drives automatic delegation); default `model: inherit`.
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
