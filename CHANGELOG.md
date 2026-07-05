# Changelog

All notable changes to Whet are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [SemVer](https://semver.org/).

- **MAJOR** — breaking: rename/remove an agent, skill, or command; change the
  `.whet/plan/` ledger layout; tighten hook blocking rules.
- **MINOR** — new agents/skills/commands, new capabilities, template additions.
- **PATCH** — wording fixes, prompt tuning, doc corrections.

# Changelog

All notable changes to Whet are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [SemVer](https://semver.org/).

- **MAJOR** — breaking: rename/remove an agent, skill, or command; change the
  `.whet/plan/` ledger layout; tighten hook blocking rules.
- **MINOR** — new agents/skills/commands, new capabilities, template additions.
- **PATCH** — wording fixes, prompt tuning, doc corrections.

## [Unreleased]

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
