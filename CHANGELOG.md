# Changelog

All notable changes to Whet are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [SemVer](https://semver.org/).

- **MAJOR** — breaking: rename/remove an agent, skill, or command; change the
  `.whet/plan/` ledger layout; tighten hook blocking rules.
- **MINOR** — new agents/skills/commands, new capabilities, template additions.
- **PATCH** — wording fixes, prompt tuning, doc corrections.

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
