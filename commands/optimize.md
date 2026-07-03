---
description: Run a project-level token consumption audit (read-only)
argument-hint: "[scope: session | config | full]"
---

Use the token-optimizer skill to run a read-only token audit of this project
(scope: ${ARGUMENTS:-full}). Work through the four diagnostic layers —
session/task waste, always-injected project config, repo structure, process —
and produce the skill's "Token Audit" report: every finding with concrete
evidence (file/config/dispatch site), an impact estimate, and a directly
executable fix, plus any vetoed savings that would hurt quality.

Do NOT apply any changes; present the ranked fix list and wait for my
authorization before remediating.
