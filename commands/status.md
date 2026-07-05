---
description: Show status of all active batch ledgers and spec workflows
argument-hint: "[filter: plan | spec | all]"
---

Summarize the current state of all active Whet work streams.

Filter: $ARGUMENTS
(Valid filters: `plan`, `spec`, `all`. Defaults to `all` if omitted.)

1. **Batch ledgers** — scan `.whet/plan/` for active directories. For each:
   - read `plan.md` header (batch name, overall status, current phase);
   - read `progress.md` for latest round (last completed task, next action, open blockers);
   - read `issues.md` for unresolved issues marked ☐ or ▶;
   - report in ≤ 3 lines per batch: name, status, next action, blockers.

2. **Specs** — scan `spec/` for feature directories. For each:
   - check which stage documents exist (`requirements.md`, `design.md`, `tasks.md`);
   - read the top status marker if present;
   - report in 1 line per spec: feature, stage, status.

3. **If nothing is active**, say so clearly and offer to create one with `/whet:plan` or `/whet:spec`.

Keep the output compact and scannable — this is a status dashboard, not a deep dive.
