---
description: Start spec-driven development for a feature (requirements → design → tasks)
argument-hint: <feature description>
---

Use the spec-workflow skill to spec out the following feature. Create
`spec/<feature-slug>/` and drive the three gated stages (requirements →
design → tasks), pausing for my confirmation at each gate. Delegate drafting
to the product-manager and architect agents where the skill says to.

If `spec/<feature-slug>/` already exists, read the existing documents and
propose incremental updates. Never overwrite a confirmed `requirements.md`
or `design.md` unless I explicitly approve.

Feature: $ARGUMENTS
