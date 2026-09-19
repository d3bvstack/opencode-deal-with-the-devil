---
description: >
  Review the codebase and regenerate the Project facts section.
  Usage: /workflow:project-facts
---

# Project Facts

Regenerate the `## Project facts` section of AGENTS.md from tool output, not memory. Every claim
in the section must trace to a tool run in this workflow.

## Phase 1 — Review

- Run `.opencode/tools/digest.sh --refresh` under `.opencode/tools/watch.sh`, plus
  `.opencode/tools/codemap.sh`, `.opencode/tools/untested.sh`, and `.opencode/tools/dupes.sh`.
- Record: the stack and shape (languages, file count, LOC), the heaviest files, the untested
  count, the duplication candidates, and CI presence (`.github/`).

## Phase 2 — Facts

- Run `.opencode/tools/facts.sh --refresh` for the authoritative languages, build/test/lint
  command, entry points, quality gates (present and absent), and test framework.

## Phase 3 — Compose

- Write the `## Project facts` section as descriptive prose: what the project is (the
  `.opencode/` engineering harness), its stack and shape, build/test state, quality-gate state,
  test framework, plus the review observations from Phase 1 — each claim traceable to the tool
  that produced it.
- End the section with exactly:
  `_Run `/workflow:project-facts` to review the codebase and regenerate this section._`

## Phase 4 — Gate

- Present the composed section.
- **Wait for explicit go before editing AGENTS.md.**

## Phase 5 — Apply

- Replace the `## Project facts` content in AGENTS.md with the composed section.
- Add the `project-facts` row to the §3.4 workflows table.

## Phase 6 — Report

- Output the resulting section and what changed.