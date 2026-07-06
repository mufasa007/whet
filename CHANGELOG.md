# Changelog

All notable changes to Whet are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [SemVer](https://semver.org/).

- **MAJOR** — breaking: rename/remove an agent, skill, or command; change the
  `.whet/plan/` ledger layout; tighten hook blocking rules.
- **MINOR** — new agents/skills/commands, new capabilities, template additions.
- **PATCH** — wording fixes, prompt tuning, doc corrections.

## [Unreleased]

## [0.5.0] - 2026-07-06

### Added
- `quick-fix` skill — fast diagnose-and-fix lane for a single concrete problem (bug, error, failing build/test): evidence-based fault pinning (`file:line` + causal chain, labeled confirmed vs hypothesis), then 2–3 genuinely different fix options (change / risk / effort / verification) presented for the user to choose — the single mandatory human gate — then minimal-diff execution verified against the Phase-1 reproduction command. Single session, no ledger; hands off to `/whet:plan` when diagnosis reveals a multi-phase effort.
- `/whet:fix <problem>` command — drives the quick-fix skill.
- `/whet:do <tasks>` command — fast lane for small well-defined tasks: scope check (ambiguity → one question first; feature-sized work → recommend `/whet:spec` / `/whet:plan`; a bug to diagnose → `/whet:fix`), tier-based routing per model-router (mechanical work → quick-scout at T3, small domain edits → specialist at T2), minimal-diff execution, cheapest-proof verification with per-task reporting. Multiple tasks separated by `;`; independent tasks run in parallel, same-file tasks serially.

### Fixed
- `README.md`: both commands tables (English and 中文) were missing `/whet:status`; repository-layout comments carried stale counts (11 agents → 14, 4 skills → 5).
- `docs/guide.zh-CN.html`: content synced back to reality (body was stale since 0.3.2) — hero version badge, nav, agent roster (added security-engineer / data-engineer / tech-writer), skills section (added quick-fix), quickstart table, command reference (added `/whet:status`, `/whet:fix`, `/whet:do`), version history table.

### Changed
- `scripts/regression-test.sh`: command-presence checklist now includes `fix` and `do`.
- `CLAUDE.md`: "How the pieces fit" documents the `/whet:fix` → `quick-fix` coupling.

## [0.4.0] - 2026-07-06

### Added
- `security-engineer` agent — security audits, threat modeling, penetration testing, dependency vulnerability scanning.
- `data-engineer` agent — data modeling, SQL optimization, ETL design, schema migration, data quality validation.
- `tech-writer` agent — documentation writing, API docs, release notes, README maintenance.
- `/whet:status` command — show current state of all Whet artifacts (batch ledgers and specs) in a compact dashboard.
- `.github/workflows/ci.yml` — GitHub Actions CI workflow running regression tests, shell syntax checks, and JSON validation on every push and PR.
- `.editorconfig` — cross-platform editor configuration for consistent formatting.

### Fixed
- `hooks/scripts/session-ledger.sh`: ledger detection now uses `${CLAUDE_PROJECT_DIR:-.}/.whet/plan` for correct behavior regardless of working directory.
- `docs/guide.zh-CN.html`: added dark mode (`prefers-color-scheme: dark`) and responsive mobile navigation (hamburger menu toggle).
- `README.md`: Chinese section now mirrors the English "How the pieces fit together" architecture diagram and "Repository layout" section.

### Changed
- `scripts/regression-test.sh`: `set -uo pipefail` → `set -euo pipefail` for stricter error handling; `run_hook` uses `&& rc=0 || rc=$?` pattern to avoid premature exit.

## [0.3.2] - 2026-07-06

### Fixed
- `agents/*.md`: compressed all 11 agent `description` fields to 1–2 trigger sentences (≤200 chars) to reduce per-session fixed token cost, per token-optimizer's own recommendation.
- `skills/model-router/SKILL.md`: made mechanism #4 platform-agnostic (`ANTHROPIC_MODEL` → "platform-specific model env vars"); documented T4 authorization format (`Tier escalation authorized up to: T4`); clarified `haiku` maps to T3 and degrades gracefully if unavailable.
- `skills/spec-workflow/SKILL.md`: added Stage 3 Gate — user confirms every task maps to a requirement AC or design section and total workload estimate is reasonable.
- `spec/templates/tasks.md`: added `> Status: draft | confirmed` marker at the top for consistency with other spec templates.
- `commands/spec.md`: clarified that existing `spec/<feature-slug>/` directories trigger incremental updates rather than overwrite.
- `scripts/regression-test.sh`: `run_hook` now captures stderr to a temp file and dumps it on failure (no longer silently swallowed).

### Added
- `hooks/scripts/protect-sensitive-bash.sh`: new PreToolUse hook for `Bash` that blocks redirects (`>`, `>>`) to sensitive files, closing the Bash bypass for `protect-sensitive.sh`.
- `CONTRIBUTING.md`: new contributor guide covering environment setup, code conventions, test requirements, and bilingual sync rules.
- `.github/ISSUE_TEMPLATE/bug_report.md` & `.github/ISSUE_TEMPLATE/feature_request.md`: issue templates for bug reports and feature requests.
- `.github/pull_request_template.md`: PR checklist template enforcing regression-test results and change-level assessment.

### Changed
- `scripts/regression-test.sh`: added `docs/guide.zh-CN.html` version consistency check and `protect-sensitive-bash.sh` test cases (5 assertions, total 89).

## [0.3.1] - 2026-07-06

### Fixed
- `README.md`: corrected version badge from 0.2.0 to 0.3.1 (was stale since v0.3.0 release).
- `hooks/scripts/protect-sensitive.sh`: extended sensitive-file coverage to include `.env.local`, `id_ecdsa`, `*.token`, `*.secret`, `.secrets`, `serviceAccountKey.json`, `terraform.tfstate`, `*.tfvars`, `.netrc`, `.git-credentials`, `.htpasswd`, and path-based matches for `/.aws/`, `/.kube/`, `/.docker/`, `/.ssh/`, `/.gnupg/`, `/.terraform/`.
- `hooks/scripts/session-ledger.sh`: switched from relative `.whet/plan` to `${CLAUDE_PROJECT_DIR:-.}/.whet/plan` so ledger detection works regardless of working directory.
- `agents/task-reviewer.md`: removed `Bash` from `tools` list to align with its strictly read-only audit mandate; added explicit rule forbidding write-capable tools.
- `commands/resume.md`: added optional `[batch-id]` argument so users can resume a specific batch ledger instead of only the latest one.
- `commands/review.md` & `commands/optimize.md`: replaced bash-style parameter expansion (`${ARGUMENTS:+...}`, `${ARGUMENTS:-...}`) with safe, explicit descriptions to avoid compatibility issues with Claude Code's command parser.

### Changed
- `scripts/regression-test.sh`: added README badge version check, agent-list sync validation (`agents/*.md` ↔ `enforce-model-tier.sh`), and 18 new `protect-sensitive` + 3 new `enforce-model-tier` JSON edge-case test cases (total 79 assertions, all passing).

## [0.3.0] - 2026-07-04

### Added
- `enforce-model-tier` PreToolUse (Task/Agent) hook: while a `.whet/plan/`
  batch ledger is active, dispatching a whet agent without an explicit
  `model` parameter is blocked, so every dispatch makes a deliberate T1–T4
  tier choice per model-router. `quick-scout` is exempt (frontmatter pins the
  fast family); non-whet agents and projects without a ledger are unaffected.

### Changed
- `model-router`: documented the hook guard as mechanism #5.
- `long-task-scheduler`: dispatch step now requires passing the chosen tier
  as an explicit `model` parameter.

## [0.2.0] - 2026-07-04

### Added
- `task-reviewer` agent — adversarial completion audit; its explicit
  "commit allowed" verdict gates every phase commit.
- `quick-scout` agent — haiku-tier runner for small well-defined tasks.
- `/whet:optimize` — read-only project-level token audit.
- Batch-ledger templates under `skills/long-task-scheduler/templates/`
  (plan / issues / progress / archive).

### Changed
- `model-router`: rewritten around the platform-agnostic T1–T4 tier
  abstraction with a runtime model-selection protocol; no hardcoded model
  names, evidence-based escalation with recorded triggers.
- `long-task-scheduler`: per-batch ledger directories
  (`.whet/plan/{YYYYMMDD}-{NNN}-{slug}/`), conflict-domain serial/parallel
  batching, one-time pre-authorization list, zero mid-run prompts with
  decision archiving, per-phase commits.
- `token-optimizer`: added the four-layer project audit
  (session / project config / repo structure / process), cache-friendly
  stable-prefix rules, quality red lines with vetoed savings, and
  diagnose-vs-remediate modes.
- `session-ledger` hook now detects the latest batch directory.
- `/whet:plan` and `/whet:resume` updated to the batch-ledger flow.

## [0.1.0] - 2026-07-04

### Added
- Initial release: 9 agents (product-manager, architect, uiux-designer,
  frontend-dev, backend-dev, mobile-dev, qa-tester, devops-engineer,
  code-reviewer), 4 skills (long-task-scheduler, model-router,
  token-optimizer, spec-workflow), 4 commands (/whet:spec, /whet:plan,
  /whet:resume, /whet:review), session-ledger + protect-sensitive hooks,
  spec templates, plugin/marketplace manifests.
