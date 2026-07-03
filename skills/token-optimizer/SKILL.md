---
name: token-optimizer
description: >
  Token consumption optimization. Use when the user asks to reduce token usage /
  cost, when context is filling up on a long task, or when designing prompts,
  subagent fan-outs, or CLAUDE.md files where token efficiency matters. Provides
  concrete techniques for context hygiene, delegation, and output discipline.
---

# Token Optimizer

Cut token spend without cutting quality. Tokens are consumed by: (1) context
you load, (2) output you generate, (3) redundant round-trips. Attack all three.

## 1. Context hygiene (input tokens)

- **Read narrow**: read the specific line ranges/symbols you need, not whole
  files. Use search (grep/glob/indexed search) to locate first, then read the
  hit ± a small window. Never read a file twice when the first read is still
  in context.
- **Delegate bulk reading**: when a question requires scanning many files,
  spawn a subagent to read them and return a distilled answer — the raw file
  contents never enter the main context. This is the single biggest lever on
  long tasks.
- **Externalize state**: for long-horizon work, keep plans/findings in files
  (see [long-task-scheduler](../long-task-scheduler/SKILL.md)) instead of
  re-deriving them in context each session.
- **Lean CLAUDE.md**: project memory is loaded EVERY session. Keep it under
  ~60 lines: conventions, commands, gotchas. Move long docs into skills or
  `docs/` and link them — they'll be loaded on demand.
- **Compact deliberately**: when a long session shifts topic, that's the cheap
  moment to `/compact` (or start a fresh session) rather than dragging dead
  context forward.

## 2. Output discipline (output tokens)

Output tokens cost ~5× input tokens. 

- Answer first, explain only if asked; no restating the question, no summary
  of what you're "about to do" before doing it.
- When editing files, edit the delta — never rewrite an entire file to change
  three lines.
- No defensive verbosity: don't paste large code blocks back to the user that
  they can open themselves; reference `file:line` instead.
- In subagent prompts, demand structured, minimal returns ("return a JSON list
  of file:line findings, no prose").

## 3. Round-trip economy

- **Batch independent tool calls** in one turn (parallel reads, parallel
  searches) instead of serial call → wait → call.
- **One good prompt beats three refinements**: when delegating, include the
  goal, constraints, relevant paths, and expected output format up front.
- **Validate an exemplar, then fan out**: for repetitive changes, perfect one
  instance, then batch the rest mechanically (cheaper model, tighter prompt —
  see [model-router](../model-router/SKILL.md)).
- **Cache-aware pacing**: prompt cache TTL is ~5 minutes; long pauses between
  turns in huge-context sessions re-read everything cold. Group interactive
  work into bursts.

## 4. Fan-out cost control

Subagents multiply cost. Before spawning N agents ask:
- Could plain code/grep answer this instead of an agent?
- Does each agent get a *scoped* slice (files, dirs) instead of "the repo"?
- Is the return schema minimal?
- Is a cheaper model sufficient per the routing rubric?

Rule of thumb: fan out for **breadth** (many independent reads), stay inline
for **depth** (one hard chain of reasoning).

## Quick checklist

- [ ] CLAUDE.md < ~60 lines, no duplicated docs
- [ ] Bulk reads delegated to subagents
- [ ] File edits are deltas, not rewrites
- [ ] Independent tool calls batched
- [ ] Repetitive work: exemplar → cheap-model fan-out
- [ ] Long-horizon state on disk, not in context
