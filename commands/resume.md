---
description: Resume the latest long-horizon batch ledger from where it left off
---

Use the long-task-scheduler skill's resume procedure: locate the newest batch
directory under `.whet/plan/`, read its plan.md, issues.md, and progress.md;
cheaply re-verify recently completed tasks against reality and reconcile the
ledger if they disagree; summarize current phase, last completed task, next
action, and open blockers in ≤ 5 lines; then continue the orchestration loop
without re-asking anything plan.md already answers.

If no ledger exists, say so and offer to create one with /whet:plan.
