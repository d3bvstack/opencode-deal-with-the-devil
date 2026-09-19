---
description: Marker and comment conventions — front-matter, citations, and what is not a marker.
alwaysApply: true
---

[RULES: MINIMALISM_MARKERS]
CONTEXT: Complements `rules/prompt-contract.md` (proof standard). Governs comments and docs. Use existing markers; inventing new ones FORBIDDEN.

METADATA:
- YAML front-matter: `description:` in 1 line; `alwaysApply: true` (general) or `globs:` (scoped only).
- Atomicity: 1 concept per home; reference `rules/<name>.md` (FORBID re-documenting).

CITATIONS:
- Evidence: Cite command + stdout, or `file:line` (bare claims FORBIDDEN).
- Cross-references: Use `rules/<name>.md` paths, not prose descriptions.

PROHIBITIONS:
- FORBID: Dead code, commented-out code, and TODOs lacking linked issues (`rules/refactor-common.md`).
- UNRECOGNIZED_MARKERS: Unestablished markers must be codified in a rule before comment use.