# Long-Horizon Execution Plan

> Batch: `{YYYYMMDD}-{NNN}-{slug}`
> Created: {YYYY-MM-DD HH:mm}
> Status: ☐ not started / ☐ running / ☐ paused / ☐ done / ☐ aborted
> Current phase: {phase ID}

## 0. Execution Principles

- One continuous run: zero human prompts mid-run; clarification and
  authorization are front-loaded, review is post-run via issues.md.
- Orchestrator dispatches only — never implements or reviews itself.
- Orchestrator re-runs the acceptance gate and checks tree integrity before
  review; an executor's "green" prose is a claim, not proof.
- Execute → verify → adversarial review → commit, per phase. No review, no commit.
- Conflicting tasks serial, disjoint tasks parallel.
- Dispatch by model tier (T1–T4), lowest sufficient tier first, escalate on
  failure. T4 requires user consent (pre-authorized or not at all).
- Major blockers/decisions auto-archived here and flagged "needs human review".

## 0.1 One-Time Pre-Authorization List

<!-- EVERY irreversible external action and writable target this effort needs.
     Confirmed by the user before start. Out-of-list = route around + record.
     Record the EXACT target (branch / remote / env) and whether it triggers a
     deploy/CI pipeline — "push authorized" is not enough if one branch is safe
     and another ships to production. -->

| # | Action | Exact target (branch / remote / env) | Triggers deploy/CI? | Scope | Authorized |
|---|---|---|---|---|---|
| A1 | | | | | ☐ |

## 0.2 Key References

<!-- Source-of-truth paths only — no pasted content; agents Read on demand. -->

- Project constraints: `CLAUDE.md`
- ...

## 1. Phase Overview

| Phase | Status | Goal | Recovery precondition | Tier | Batch |
|---|---|---|---|---|---|
| P1 | ☐ | | | T2 | B1 |

## 2. Phase Details

### P{N}: {title}

- **Inputs**: {paths + line ranges}
- **Actions**:
- **Outputs**:
- **Acceptance criteria**: {verifiable — test/build/file, never "improve X"}
- **Recovery point**: {what must be true to resume here}
- **Tier**: T{?} (escalate on: {condition} / de-escalate: no|{condition})
- **Conflict domain**: {files / config / DB targets / ports / gates}
- **Safety gates**: {pre-auth items used, read-only boundaries}
- **Verification commands**: `{command}`

---

## Appendix

- Issues: `issues.md` · Progress: `progress.md`
- Archives: `{YYYYMMDD}-{topic}-{decision|blocker}.md` in this directory
