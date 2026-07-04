---
name: long-task-scheduler
description: >
  Long-horizon task scheduler and orchestrator. Use when a task spans multiple
  phases or sessions: migrations, large refactors, feature epics, batch
  remediation, or anything the user asks to "plan out and execute over time".
  Creates a per-batch ledger directory (plan / issues / progress / archives),
  orchestrates serial/parallel dispatch by dependency and conflict domain,
  separates execution from adversarial review, and resumes from disk. Also use
  when the user says "continue the plan" / "resume".
---

# Long-Horizon Task Scheduler

Run work that outlives a single session by externalizing ALL state into a
**batch ledger directory** on disk, orchestrating subagents against it, and
committing phase by phase. The conversation is a cache; the ledger is truth.

## Batch ledger layout

Each long-horizon effort gets its own directory:

```
.whet/plan/{YYYYMMDD}-{NNN}-{slug}/
├── plan.md       # phases, conflict domains, batches, acceptance, tiers, recovery points
├── issues.md     # live blockers, decisions, gaps — anything needing human review
├── progress.md   # per-round convergence log: status, commits, next step
└── {YYYYMMDD}-{topic}-{decision|blocker}.md   # major decision/blocker archives (as needed)
```

- `{YYYYMMDD}` start date, `{NNN}` same-day sequence from 001, `{slug}` short
  kebab-case name. Templates: [templates/](templates/) in this skill.
- `plan.md` is written once at start (confirm with the user), then updated
  incrementally. `issues.md` and `progress.md` are updated **every round** —
  never let documents lag behind reality.

## Execution model: one continuous run, zero mid-run prompts

Human interaction happens at exactly two points:

1. **Before start** — clarify goal, constraints, concurrency, and collect a
   **one-time pre-authorization list**: every irreversible external action and
   writable target this effort needs. Ask once, get approval once.
2. **After finish** — the user reviews `issues.md`, where every autonomous
   decision and blocker was archived.

During execution: in-list actions run without re-asking; out-of-list actions
are **never executed** — record in `issues.md` as "needs human review", route
around, keep going. Hard bans regardless of authorization: deleting business
data, leaking secrets, faking verification results.

## Orchestration loop (every round)

1. **Sync to truth**: read `plan.md`, `issues.md`, `progress.md`, latest
   archives, `git status --short`. Never assume progress from memory.
2. **Pick the next batch** by dependency and **conflict domain**: tasks
   touching the same file / config version / DB write target / port / gate /
   stateful resource **must run serially**; disjoint tasks run in parallel in
   one batch. If conflict spreads mid-run, fall back to serial.
3. **Dispatch executors** — delegate each task to the matching specialist
   (frontend-dev / backend-dev / mobile-dev / devops-engineer / quick-scout…)
   with: task ID, precise inputs (paths + line ranges, not pasted file bodies),
   forbidden actions, acceptance criteria, verification commands, and a model
   tier per [model-router](../model-router/SKILL.md) — pass the chosen tier as
   an explicit `model` parameter; while the ledger is active a PreToolUse hook
   blocks whet-agent dispatches that omit it. Executors report
   "ready for review" — they never self-declare done. Record each dispatch's
   tier, actual model, and (once it finishes) reported token usage into
   `progress.md` — a resumed session cannot recover a prior subagent's usage,
   so it is captured now or lost.
4. **Verify, then adversarial-review** — the orchestrator first re-runs the
   acceptance gate itself and checks tree integrity (`git status` / `git diff` /
   reflog: no stray reverts, stashes, or out-of-scope edits). An executor's
   prose ("BUILD SUCCESS", "all green", "the other module is still broken") is a
   claim, not proof — stale baselines and mistaken self-reports happen, so the
   load-bearing assertions get machine-confirmed, not trusted. Only verified
   output advances to **task-reviewer** (read-only, presumption of
   incompleteness). Only its explicit "commit allowed" verdict unlocks a commit.
   The orchestrator may itself supply the verification pass for low-risk or
   already-substantiated claims; capability-sensitive red-lines (silent data
   loss, security, invariant breaks) still get an independent adversarial pass.
5. **Converge**: pass → update ledger docs → commit this phase (message
   includes phase ID, scope limited to this phase's changes, pushed only to the
   pre-authorized target — never a deploy-triggering branch unless the pre-auth
   list says so) → next batch.
   Fail-but-continuable → record the gap in `issues.md`, redispatch (escalate
   one tier if it's a repeat failure). External blocker → archive it, mark
   "needs human review", advance everything not depending on it.
6. Loop until **all phases done or only external blockers remain**. Then emit
   a closing brief: phase end-states, all commits, and the consolidated
   "needs human review" list — the single artifact the user audits.

## Major decisions (decide, archive, don't stall)

Tech choices, trade-offs, interpretation calls encountered mid-run:

- Clear impact + solid evidence → decide autonomously.
- Complex / high-stakes → escalate to the strongest available tier for a
  decision memo (conclusion + rationale + risks + rejected options).
- **Either way**: archive background, options, conclusion, rationale, and risk
  into `issues.md` (major ones get their own archive file), then continue.
  Reversible decisions take effect immediately; irreversible ones outside the
  pre-auth list can only resolve to "route around + record".

## Task rules

- Each task ≤ one focused session; each has a **verifiable completion
  criterion** and a **recovery point** (what must be true to resume here).
- Executors verify their own work (build/tests) AND re-read final state
  independently — tool success messages are not proof.
- **Gates mask each other.** A full quality gate (lint → static analysis →
  coverage → tests) fails one layer at a time: fixing the first unmasks the
  next. When acceptance is "gate fully green" and the codebase hasn't run the
  full gate before, scope for several fix→re-run rounds, not one, and name the
  known gate stages up front so the layering is expected, not a surprise.
- **Edits made only to satisfy a gate are prime regression sites.** A change
  that silences a linter or static-analysis rule (null→empty-collection,
  broadened/narrowed catch, signature tweak) can alter behavior while the gate
  goes green — the green gate then hides the regression. Treat these as
  semantic changes: state the behavior-equivalence claim explicitly and make the
  reviewer check callers, not just that the rule passed.
- Nesting limits are handled honestly: if this skill runs where subagents
  can't spawn subagents, degrade to a **dispatch planner** — output the exact
  batch/prompt/tier list for the top-level session to execute. Never claim
  parallel execution that didn't happen.

## Resuming ("continue" / "resume")

1. Find the newest batch dir in `.whet/plan/`; read its three core docs.
2. Cheaply re-verify recently "done" tasks (files exist, tests green);
   reconcile the ledger if reality disagrees.
3. Report in ≤ 5 lines: current phase, last completed, next action, open
   blockers. Then continue the loop — don't re-ask what `plan.md` answers.

## Anti-patterns

- ❌ Plan state living only in conversation.
- ❌ "Done" without running the acceptance check, or committing without a
  reviewer verdict.
- ❌ Trusting an executor's "all green" prose without re-running the gate — or
  a reviewer's "pass" without spot-checking its load-bearing evidence.
- ❌ Pushing a phase commit to a deploy-triggering branch the pre-auth list
  never named.
- ❌ Losing per-dispatch model/token usage by not recording it the round it
  completes — it is unrecoverable next session.
- ❌ Pausing mid-run to ask something the pre-auth list already answers —
  or executing something it doesn't.
- ❌ Parallel-dispatching tasks that share a conflict domain.
- ❌ Rewriting the whole plan when one task changes — edit incrementally.
