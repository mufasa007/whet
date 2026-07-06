---
description: Execute one or more small, well-defined tasks fast — route, do, verify, report
argument-hint: <task description; separate multiple tasks with ";">
---

Execute the following small task(s) as a fast lane — no spec, no ledger, no
review board.

1. **Scope check** — each task must be small and well-defined: a config
   tweak, a one-file edit, a small function, a lookup, one command. If a task
   is ambiguous, ask me one short question before touching anything. If it
   turns out to be a feature or multi-module effort, stop and recommend
   `/whet:spec` or `/whet:plan`; if it's really a bug to diagnose, recommend
   `/whet:fix`.
2. **Route & execute** — mechanical lookups and one-liners go to quick-scout
   (T3); small domain edits go to the matching specialist or run directly at
   T2, per model-router. Independent tasks run in parallel; tasks touching
   the same files run serially. Minimal diff only — no drive-by refactors,
   no bonus tests, no unrelated files.
3. **Verify & report** — run the cheapest check that proves each task worked
   (build, test, or command output — a tool's success message is a claim,
   not proof). Report per task: done / partial / blocked, files changed,
   evidence. No irreversible external actions, and don't commit unless I ask.

Tasks: $ARGUMENTS
