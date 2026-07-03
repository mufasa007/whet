---
name: token-optimizer
description: >
  Token consumption optimization. Use when the user asks to reduce token usage
  or cost, when context is filling up on a long task, when designing prompts or
  subagent fan-outs, or for a periodic project-level token audit. Provides
  in-flight techniques plus a four-layer project diagnostic (session, project
  config, repo structure, process). Read-only diagnosis by default; only
  applies project-wide changes when the user explicitly authorizes it.
---

# Token Optimizer

Cut token spend **without cutting quality**. Any "saving" that would degrade
architecture judgment, gate verification, root-cause analysis, or safety
boundaries is vetoed outright — a cheap wrong answer costs more than an
expensive right one.

Two modes:

- **Diagnose (default)** — read-only audit producing an evidence-backed waste
  list with an estimated impact per item.
- **Remediate (only on explicit user authorization)** — apply project-level
  fixes; verify the project still loads/builds after each change.

## In-flight techniques (apply always)

### Input minimization
- Read narrow: locate with indexed/glob search first, then read hit ± small
  window. Never re-read what's already in context.
- **Pass paths + line ranges, not pasted bodies** — especially never paste the
  same large file into both an executor prompt and a reviewer prompt.
- Delegate bulk reading to subagents that return distilled answers — raw file
  contents never enter the main context. Biggest single lever on long tasks.
- Externalize long-horizon state to disk
  ([long-task-scheduler](../long-task-scheduler/SKILL.md)), don't re-derive.

### Cache friendliness
- Keep dispatch-prompt **stable prefixes byte-identical** (role, constraints,
  source-of-truth list); put volatile content (IDs, timestamps) at the tail.
- Batch same-type, same-tier, same-prefix tasks into one parallel wave to
  maximize prompt-cache reuse; group interactive work into bursts (cache TTL
  is ~5 min).

### Output discipline
- Answer first; no restating, no pre-narration. Edit deltas, never rewrite
  files. Reference `file:line` instead of pasting code back.
- Demand lean subagent returns: "conclusion + evidence (file:line / command),
  no prose".

### Dispatch economy
- Route tiers first ([model-router](../model-router/SKILL.md)) — model choice
  dominates cost, and a cheap model retried 4× out-spends one strong pass.
- Before spawning N agents: could plain grep answer it? does each agent get a
  scoped slice? is the return schema minimal?
- Review only the current diff, never full re-scans. Check existing
  findings/archives before re-investigating.

## Project-level diagnostic (four layers)

For each finding give: **evidence (file/config/dispatch site) + impact
estimate (high/mid/low) + concrete fix**. "Could be optimized" without
evidence is not a finding.

### Layer 1 — Session/task (per-dispatch waste)
1. Tier mismatch: T1 doing lookups/archiving, or T3 grinding a hard task into
   repeated rework.
2. Context redundancy: pasted large files, same file fed to multiple agents,
   wholesale ingestion instead of targeted reads.
3. Cache misses: volatile content breaking stable prefixes.
4. Repeated labor: re-scouting settled conclusions, full-scan reviews,
   same-tier same-prompt retries after failure.

### Layer 2 — Project config (fixed cost paid EVERY session)
5. Always-injected files (CLAUDE.md / rule files): stale content, duplicated
   sections, **historical changelogs** — the most common bloat source. Keep
   "current conclusion + archive pointer", move history out.
6. Agent `description` length: descriptions sit in the main context
   permanently — compress to 1–2 trigger sentences; details belong in the
   body (loaded only on invocation).
7. Hook output verbosity; identical content re-injected every round.
8. MCP mounts: tool schemas of unused servers are permanent context — unmount
   or defer-load.
9. Ignore rules: keep build artifacts / deps / generated files out of search.

### Layer 3 — Repo structure
10. Single source of truth: the same fact maintained in N places makes agents
    read and cross-check N times.
11. Archives pasting code the repo already has (should cite `file:line`).
12. Hot large files agents read often: split, or index/summarize.

### Layer 4 — Process
13. Dispatch/report templates: conclusion + evidence only, no boilerplate.
14. Review scope: current changes only.
15. Batching: same-type/tier/prefix tasks merged per wave.

## Quality red lines (never trade for tokens)

- No tier downgrades or context cuts on: architecture decisions, security/gate
  judgments, invariant verification, irreversible-action decisions.
- Never skip adversarial review, final-state re-reads, or gate verification to
  save tokens.
- If a saving risks silent failure, veto it and say why.

## Diagnostic output format

```markdown
## Token Audit
- Scope: <session / project config / full project>
- Verdict: <healthy / N waste points / over-optimization risk found>

### High-priority savings (no quality impact)
- [evidence] current state → fix → impact (high/mid/low)

### Tier adjustments
- <task>: current T? → suggested T?, reason

### Fixed-cost reductions (config / agents / MCP)
### Context & cache improvements
### ⚠️ Vetoed savings (would hurt quality)
- <item> — why it must not be cut

- Conclusion: ranked, directly executable fix list
```
