---
description: Plan a long-horizon effort and create a persistent batch ledger
argument-hint: <goal description>
---

Use the long-task-scheduler skill to set up a persistent batch ledger for the
following goal:

1. Clarify goal, constraints, concurrency, and collect the **one-time
   pre-authorization list** (every irreversible action / writable target this
   effort needs) — this is the only point where you may ask me questions.
2. Create `.whet/plan/{YYYYMMDD}-{NNN}-{slug}/` with plan.md, issues.md, and
   progress.md from the skill's templates; decompose into phases with conflict
   domains, acceptance criteria, recovery points, and model tiers.
3. Confirm the plan with me, then start the orchestration loop on the first
   batch.

Goal: $ARGUMENTS
