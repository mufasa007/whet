---
name: spec-workflow
description: >
  Spec-driven development workflow. Use when starting a non-trivial feature:
  turns an idea into requirements → design → task list before any code is
  written, keeping specs in spec/ as versioned artifacts. Also use when the
  user says "write a spec", "spec this out", or asks to implement against an
  existing spec.
---

# Spec-Driven Development Workflow

Write the contract before the code. A feature flows through three gated
documents; each gate needs user confirmation before proceeding.

```
idea → requirements.md → design.md → tasks.md → implementation → verification
```

## Directory convention

```
spec/
└── <feature-slug>/
    ├── requirements.md   # WHAT and WHY
    ├── design.md         # HOW
    └── tasks.md          # execution checklist
```

Specs are versioned with the code. A merged feature's spec is documentation;
an unmerged spec is the plan.

## Stage 1 — Requirements (`requirements.md`)

Delegate drafting to the **product-manager** agent for user-facing features.

```markdown
# <Feature>: Requirements
## Problem & Motivation
## User Stories
- As a <role>, I want <capability>, so that <benefit>.
  - AC1: GIVEN <context> WHEN <action> THEN <outcome>
## Non-goals
## Constraints (perf, compat, security, deadline)
## Open Questions
```

Gate: every story has testable acceptance criteria; non-goals are explicit;
user confirms. **No design before the gate.**

## Stage 2 — Design (`design.md`)

Delegate to the **architect** agent for cross-module work.

```markdown
# <Feature>: Design
## Overview (approach in 3 sentences)
## Architecture (Mermaid diagram if multi-component)
## Data Model / Schema Changes
## API / Interface Contracts
## Error Handling & Edge Cases
## Test Strategy
## Alternatives Considered
```

Gate: design covers every acceptance criterion; edge cases from the AC list
are addressed; user confirms.

## Stage 3 — Tasks (`tasks.md`)

```markdown
# <Feature>: Tasks
> Status: draft | confirmed

> Design: ./design.md

- [ ] 1. <task> (refs: AC1, AC2)
- [ ] 2. <task> (refs: design §API)
```

Rules: each task ≤ ~half a day, independently verifiable, ordered by
dependency, and **traceable back to an AC or design section** — a task that
maps to nothing gets cut. For multi-session efforts, hand this ledger to
[long-task-scheduler](../long-task-scheduler/SKILL.md).

Gate: every task maps to a requirement AC or design section; total workload
estimate is reasonable; user confirms.

## Stage 4 — Implementation & verification

- Implement task by task (delegate to the matching dev agent: frontend-dev /
  backend-dev / mobile-dev); check items off in `tasks.md` as they complete.
- **qa-tester** verifies each acceptance criterion has a passing test.
- **code-reviewer** reviews the final diff against the design — deviations
  are either fixed or written back into `design.md` with rationale.

## When to skip

Not everything needs this ceremony:

| Change | Process |
|---|---|
| Bug fix, small tweak | Just fix it (with a test) |
| Single-module feature, clear requirements | Lightweight: AC list in the PR + tasks |
| Multi-module feature, new API, or vague requirements | Full spec workflow |

## Anti-patterns

- ❌ Writing code "to explore" and back-filling the spec after.
- ❌ Specs with no acceptance criteria ("improve performance").
- ❌ Skipping gates — a design built on unconfirmed requirements is rework.
- ❌ Letting spec/ rot: if implementation diverged, update the spec in the
  same PR.
