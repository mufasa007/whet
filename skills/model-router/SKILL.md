---
name: model-router
description: >
  Automatic model selection. Use when deciding which Claude model tier (haiku /
  sonnet / opus) should handle a task or subagent, when the user asks to
  "optimize model usage" or "route models automatically", or when spawning
  subagents whose cost/quality trade-off matters. Provides a routing rubric and
  concrete configuration mechanisms.
---

# Model Router

Route every piece of work to the cheapest model tier that can do it reliably.
Escalate on evidence, not on vibes.

## Routing rubric

Score the task on three axes, take the highest tier any axis demands:

| Axis | haiku | sonnet | opus |
|---|---|---|---|
| **Reasoning depth** | mechanical / pattern-match (rename, format, extract, simple lookup) | standard engineering (implement a spec'd feature, write tests, fix a clear bug) | ambiguous, multi-constraint (architecture, gnarly debugging, security analysis, novel algorithms) |
| **Blast radius** | wrong answer is cheap & obvious | wrong answer costs a review cycle | wrong answer is expensive or hard to detect (migrations, auth, concurrency, public API design) |
| **Context integration** | single file / snippet | a module and its neighbors | whole-system reasoning across many subsystems |

Default when unsure: **sonnet**. It is the correct answer for ~70% of
engineering tasks.

### Typical assignments

- **haiku**: log summarization, commit-message drafting, file listing triage,
  mass mechanical edits after one exemplar is validated, format conversion,
  simple extraction from docs.
- **sonnet**: feature implementation from a clear spec, test writing, code
  review of small diffs, refactors with existing tests, doc writing.
- **opus**: system design, cross-cutting refactors without test coverage,
  race-condition/memory-corruption debugging, security-sensitive code, plan
  synthesis from conflicting requirements, final review of high-risk diffs.

## Escalation & de-escalation

- **Escalate** one tier when: two attempts failed, output contradicts itself,
  or the task revealed hidden complexity (touching auth, money, concurrency).
- **De-escalate** for the long tail: once a strong model has produced a
  validated exemplar (e.g. one migrated file + passing tests), fan the
  remaining repetitive instances out to a cheaper tier with the exemplar in
  the prompt.
- Never silently downgrade quality-critical final outputs (user-facing review
  verdicts, architecture decisions) to save cost.

## Mechanisms in Claude Code

1. **Session model**: `/model` or `claude --model <model>`.
2. **Subagent frontmatter**: set `model: haiku|sonnet|opus|inherit` in an
   agent's `.md` frontmatter. Whet agents default to `inherit`; override per
   project if a role is always mechanical (rarely true).
3. **Per-spawn override**: the Agent tool accepts a `model` parameter — use it
   when delegating, applying the rubric above to the delegated prompt, e.g.
   exploration/search → haiku or sonnet; deep analysis → keep the session model.
4. **Env defaults**: `ANTHROPIC_MODEL` and `ANTHROPIC_SMALL_FAST_MODEL` in
   settings control the main and background models.

## Pairing with token optimization

Model choice dominates cost: opus tokens cost ~5× sonnet, ~25–75× haiku.
Route first, then apply [token-optimizer](../token-optimizer/SKILL.md)
techniques within the chosen tier.

## Anti-patterns

- ❌ Opus for everything "to be safe" — burns budget on mechanical work.
- ❌ Haiku for anything whose failure is silent (it will fail confidently).
- ❌ Escalating after one failure without changing the prompt/context — fix
  the input first.
- ❌ Per-message model churn — pick a tier per task, not per turn.
