---
description: Start spec-driven development for a feature (requirements → design → tasks)
argument-hint: <feature description>
---

Use the spec-workflow skill to spec out the following feature. Create
`.whet/spec/{YYYYMMDD}-{NNN}-{feature-slug}/` for new specs and drive the
three gated stages (requirements → design → tasks), pausing for my
confirmation at each gate. Delegate drafting to the product-manager and
architect agents where the skill says to.

If legacy `spec/<feature-slug>/` already exists, read the existing documents
there and propose incremental updates in place. Never overwrite a confirmed
`requirements.md` or `design.md` unless I explicitly approve.

Feature: $ARGUMENTS
