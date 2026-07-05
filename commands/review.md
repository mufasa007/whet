---
description: Run a full team review of the current changes (QA + code review)
argument-hint: "[base branch, default: default branch]"
---

Run a team review of the current branch's changes.

If a base branch is provided, scope the diff to commits ahead of that branch;
otherwise review staged + unstaged changes only.

Base: $ARGUMENTS

1. Determine the diff scope with git (staged + unstaged + commits ahead of the
   base branch).
2. In parallel, delegate to:
   - the **code-reviewer** agent — full review of the diff (correctness,
     security, performance, maintainability);
   - the **qa-tester** agent — identify untested changed logic, run the
     relevant test suite, and report gaps with suggested test cases.
3. Merge both reports, deduplicate findings, sort by severity, and present a
   single review with a clear verdict and a prioritized fix list.
