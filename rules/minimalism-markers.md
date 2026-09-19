---
description: Marker and comment conventions — front-matter, citations, and what is not a marker.
alwaysApply: true
---

# Minimalism markers — comments and docs

`rules/prompt-contract.md` governs what a result must prove; this rule governs how
comments and docs mark it. Use the marker that exists — don't invent a new one.

## Rule metadata

- Every rule opens with YAML front-matter: `description:` in one line, `alwaysApply: true`
  for general rules, `globs:` only for scoped rules.
- One concept per home — reference `rules/<name>.md`, don't re-document it.

## Citations

- Evidence cites a command and its output, or `file:line` — never a bare claim.
- Cross-references use `rules/<name>.md` paths, not prose descriptions.

## What is not a marker

- No dead code. No commented-out code. No TODO without a linked issue
  (`rules/refactor-common.md`).
- A marker the repo doesn't use is a new concept — it belongs in a rule, not a comment.