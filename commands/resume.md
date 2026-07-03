---
description: Resume the active long-horizon task ledger from where it left off
---

Use the long-task-scheduler skill's resume procedure: read `.whet/plan/PLAN.md`,
`.whet/plan/tasks.md`, and the tail of `.whet/plan/journal.md`; verify recently
completed tasks against reality; summarize current phase, last completed task,
and next action in a few lines; then continue executing the next unblocked task.

If no ledger exists, say so and offer to create one with /whet:plan.
