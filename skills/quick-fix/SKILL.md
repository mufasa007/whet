---
name: quick-fix
description: >
  Fast diagnose-and-fix workflow for a single concrete problem: a bug, error
  message, failing test/build, or misbehaving feature. Use when the user asks
  to "find out why X fails", "troubleshoot this", or "fix this error" and the
  work fits one session — it pins the fault point with evidence, presents 2–3
  fix options for the user to choose, then applies exactly the chosen one.
  For multi-phase efforts use long-task-scheduler instead.
---

# Quick Fix

Diagnose one concrete problem fast, let the human pick the fix, apply it with
a minimal diff. Single session, no ledger. Exactly **one human gate**:
choosing the fix option.

## Scope test (run first)

Quick-fix fits one observable failure with a suspected local cause. It does
NOT fit what diagnosis reveals to be multi-module redesign, migration, or
cross-session work — stop there, hand the diagnosis so far to `/whet:plan`
(long-task-scheduler), and say so. Never stretch a quick fix into a hidden
long task.

## Phase 1 — Diagnose (evidence, not vibes)

1. **Capture the failure signature**: exact error message, failing command,
   expected vs actual. If reproduction costs one command, reproduce it now —
   that command becomes the verification gate in Phase 3.
2. **Narrow with evidence**, cheapest probes first: recent changes
   (`git log` / `git diff` around the failing area) → the failure trail
   (stack trace, logs, config) → targeted indexed search from symptom to
   source. Fan independent read-only lookups out to quick-scout (T3) in
   parallel; reason at T2; escalate to T1 only after two honest attempts
   leave the root cause stuck (per [model-router](../model-router/SKILL.md)).
3. **Pin the fault point**: root cause as `file:line` plus a one-sentence
   causal chain (trigger → defect → observed failure). Label it
   **confirmed** (evidence reproduces the causal link) or **hypothesis**
   (best explanation; list what would confirm it). Never present a
   hypothesis as confirmed.

## Phase 2 — Propose options (the human gate)

Present the diagnosis plus **2–3 genuinely different fix options** — not one
option padded with strawmen. For each:

- **Change** — what edits where (files, approach)
- **Risk / blast radius** — what else could break
- **Effort** — rough diff size
- **Verification** — the exact command/check proving it worked

Mark one **Recommended** with a one-line reason, then **stop and let the user
choose** (AskUserQuestion where available, else a numbered list). This gate
is mandatory — never auto-execute a fix, even an obvious one. A user-supplied
variant counts as the chosen option.

## Phase 3 — Execute & verify

1. Apply exactly the chosen option, minimal diff — no drive-by refactors, no
   scope growth. Small diffs apply directly; domain-heavy edits go to the
   matching specialist agent with an explicit tier. If execution shows the
   chosen option is wrong, return to the gate with what was learned instead
   of improvising a different fix.
2. Verify with the Phase-1 reproduction / chosen option's verification
   command. A tool's success message is a claim, not proof.
3. Report: root cause (one line), chosen option, files changed, verification
   evidence (command + output). Leave committing to the user unless asked.

## Anti-patterns

- ❌ Patching where the error *surfaces* instead of where it's *caused*.
- ❌ One real option plus strawmen — the gate needs genuine alternatives.
- ❌ Executing before the user picked, "because it was obvious".
- ❌ Skipping reproduction when it costs one command.
- ❌ Widening into refactor/cleanup during the fix.
- ❌ Forcing a multi-phase problem through quick-fix — hand off to `/whet:plan`.
