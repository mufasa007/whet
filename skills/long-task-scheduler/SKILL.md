---
name: long-task-scheduler
description: >
  Long-horizon task scheduler. Use when a task is too large for one session or
  one context window: multi-day migrations, large refactors, feature epics, or
  any work the user asks to "plan out and execute over time". Breaks work into a
  persistent task ledger (tasks.md), tracks state across sessions, and resumes
  from the ledger. Also use when the user says "continue the plan" / "resume".
---

# Long-Horizon Task Scheduler

Manage work that outlives a single session or context window by externalizing
all state into a **task ledger** on disk, so any future session can resume
without conversational memory.

## Core principle

**The ledger is the source of truth, not the conversation.** Anything not
written to the ledger is lost. Update the ledger BEFORE reporting progress to
the user.

## Ledger layout

Keep the ledger in the project at `.whet/plan/`:

```
.whet/plan/
├── PLAN.md          # goal, scope, constraints, architecture decisions
├── tasks.md         # the task ledger (see format below)
└── journal.md       # append-only session log: what happened, what surprised us
```

### tasks.md format

```markdown
# Task Ledger: <project goal>
Updated: <ISO date>

## Phase 1: <name>            [status: done|active|blocked|pending]
- [x] T1.1 <task> — done <date>, commit <sha>
- [ ] T1.2 <task> — active. Next step: <concrete next action>
- [ ] T1.3 <task> — blocked on T1.2. Notes: <why>

## Phase 2: <name>            [status: pending]
...
```

Rules for tasks:
- Each task completable in ≤ 1 focused session; split anything bigger.
- Each task has a **verifiable completion criterion** (test passes, build green,
  file exists) — never "improve X".
- Record the *next concrete action* on the active task, so resume needs zero
  re-derivation.
- Order by dependency; mark blockers explicitly.

## Workflow

### Starting a new long-horizon effort

1. Clarify goal and constraints with the user; write `PLAN.md`.
2. Decompose into phases → tasks; write `tasks.md`.
3. Confirm the plan with the user before executing.
4. Execute the first task.

### Executing (every session)

1. **Read the ledger first**: `PLAN.md`, `tasks.md`, tail of `journal.md`.
2. Verify reality matches the ledger (run the completion checks of recently
   "done" tasks cheaply — e.g. does the file/test exist). Reconcile if not.
3. Pick the first `active`/`pending` unblocked task. Work on ONE task at a time.
4. On completion: run its verification, mark done with date+commit, pick next.
5. Before the session ends or context runs low: update `tasks.md` with precise
   state, append a `journal.md` entry (date, what was done, decisions made,
   surprises found, next step).

### Resuming ("continue" / "resume")

1. Read ledger → report current phase, last completed task, and the next action
   in one short summary.
2. Continue execution without re-asking questions already answered in `PLAN.md`.

## Scheduling across time

- If a task depends on an external event with a known ETA (CI run, deploy
  window, review), record the ETA in `tasks.md` and suggest the user schedule a
  follow-up session then.
- Batch small independent tasks into one session; keep risky/large tasks solo.
- After every 3–4 completed tasks, re-validate the remaining plan against
  reality — plans rot as code changes.

## Anti-patterns

- ❌ Holding plan state only in conversation.
- ❌ Marking a task done without running its verification criterion.
- ❌ Starting task N+1 while task N is half-done and unrecorded.
- ❌ Rewriting the whole plan when one task changes — edit incrementally.
