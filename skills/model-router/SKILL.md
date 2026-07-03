---
name: model-router
description: >
  Automatic model selection. Use when deciding which model tier should handle a
  task or subagent, when the user asks to "optimize model usage" or "route
  models automatically", or when spawning subagents whose cost/quality
  trade-off matters. Provides a platform-agnostic tier abstraction (T1–T4), a
  runtime model-selection protocol, and escalation rules.
---

# Model Router

Route every piece of work to the cheapest model tier that can do it reliably.
Escalate on evidence, not on vibes.

## Tier abstraction (platform-agnostic — never hardcode model names)

Model vendors iterate constantly; binding a plan to a specific model name goes
stale fast. Plans and dispatch prompts always use abstract tiers:

| Tier | Profile | Fits | Cost |
|---|---|---|---|
| **T1 deep reasoning** | strongest reasoning, long-context, high-stakes judgment | architecture, gnarly root-cause debugging, cross-module refactors, high-risk adversarial review, long-horizon orchestration | high |
| **T2 balanced coding** | solid coding + comprehension, best value | feature implementation from spec, tests, config work, routine adversarial review | mid |
| **T3 fast** | quick, cheap, fine for narrow deterministic work | lookups, read-only scouting, archiving, summaries, template filling, mechanical edits | low |
| **T4 extreme** | beyond T1; **disabled by default, needs user consent** | rare unsolvable-at-T1 problems, major decision escalation | highest |

## Runtime model-selection protocol (run before each dispatch)

1. **Probe availability** — read the model list the current tool actually
   exposes (Claude Code: the Agent tool's `model` parameter candidates and
   `/model`; other tools: their model picker/config). Never assume a model
   exists or is strongest from memory.
2. **Rank by capability** — group available models into deep-reasoning /
   balanced / fast-light using family positioning, reasoning support, context
   length, and price tier.
3. **Map tiers** — T1 → strongest available reasoning model; T2 → balanced;
   T3 → fast-light. If inheriting the session model already satisfies the
   target tier, omit the model parameter.
4. **Stay evolution-proof** — when the platform ships a stronger flagship,
   it joins the T1 candidates automatically; retired models map down to the
   nearest surviving tier.
5. **Degrade honestly** — if the platform only supports session-level model
   choice, batch same-tier tasks together and note the recommended tier in the
   dispatch prompt. If no choice at all, record the tier gap; a
   capability-sensitive task stuck below T2 gets flagged for human review
   rather than executed at low quality.

## Routing rubric

Score the task on three axes; take the highest tier any axis demands:

- **Reasoning depth** — mechanical/pattern-match → T3; standard engineering
  → T2; ambiguous multi-constraint → T1.
- **Blast radius** — wrong answer cheap & obvious → T3; costs a review cycle
  → T2; expensive or silent (migrations, auth, money, concurrency, public
  API) → T1.
- **Context integration** — single file → T3; a module + neighbors → T2;
  whole-system → T1.

Default when unsure: **T2**. It is right for ~70% of engineering tasks.

## Escalation & de-escalation

- **Start at the lowest tier that satisfies the task.** Escalate one tier when:
  review rejects the output, builds fail repeatedly, root cause stays stuck,
  or the task reveals hidden complexity (auth, money, concurrency). Record
  every escalation and its trigger in the task ledger.
- **De-escalate the long tail**: once a strong model produced a validated
  exemplar, fan the remaining repetitive instances out at T3 with the exemplar
  in the prompt.
- **Capability-sensitive work never downgrades to save cost**: architecture
  calls, security/gate judgments, invariant checks are ≥ T2, high-risk ones T1.
- **Cost-sensitive work never upgrades blindly**: read-only scouting,
  archiving, reconciliation stay T3 unless hidden complexity surfaces.
- Every dispatch notes **tier + actual model + one-line reason**.

## Mechanisms in Claude Code

1. **Session model**: `/model` or `claude --model <model>`.
2. **Subagent frontmatter**: `model:` in an agent's `.md`. Whet agents default
   to `inherit` (T1/T2 roles ride the session flagship); only intentionally
   cheap agents pin a family alias (e.g. `quick-scout` pins the fast family)
   — aliases resolve to the family's latest generation, so they don't rot.
3. **Per-dispatch override**: the Agent tool's `model` parameter beats
   frontmatter — apply the rubric per delegated prompt.
4. **Env defaults**: `ANTHROPIC_MODEL` / `ANTHROPIC_SMALL_FAST_MODEL`.
5. **Hook guard**: while a `.whet/plan/` batch ledger is active, the
   `enforce-model-tier` PreToolUse hook blocks dispatching a whet agent with
   no explicit `model` — run the rubric, then redispatch with the chosen
   family alias (quick-scout is exempt; its frontmatter pins the fast family).

## Pairing with token optimization

Model choice dominates cost: a T1 token costs multiples of T2 and an order of
magnitude more than T3 — and a T3 model retried four times can out-spend one
T1 pass. Route first, then apply [token-optimizer](../token-optimizer/SKILL.md)
within the chosen tier.

## Anti-patterns

- ❌ Hardcoding model names in plans or agent definitions.
- ❌ T1 for everything "to be safe" — burns budget on mechanical work.
- ❌ T3 for anything whose failure is silent (it will fail confidently).
- ❌ Retrying the same tier with the same prompt after failure — fix the
  input or escalate.
- ❌ Per-message tier churn — pick per task, not per turn.
