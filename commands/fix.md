---
description: Quickly diagnose a problem, pick a fix from proposed options, apply and verify
argument-hint: <problem description | error message | failing command>
---

Use the quick-fix skill on the following problem:

1. **Diagnose** — capture the failure signature (reproduce it if it costs one
   command), narrow with evidence, and pin the fault point as `file:line` +
   causal chain, labeled confirmed vs hypothesis.
2. **Propose** — present 2–3 genuinely different fix options (change / risk /
   effort / verification), mark one Recommended, and wait for my choice.
   Never auto-execute a fix.
3. **Execute** — apply exactly the option I chose with a minimal diff, run
   the verification command, and report files changed + evidence. Do not
   commit unless I ask.

If diagnosis reveals a multi-phase effort, stop and recommend `/whet:plan`
with the diagnosis so far.

Problem: $ARGUMENTS
