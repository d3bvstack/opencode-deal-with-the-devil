---
description: >
  Organize the working-tree changes into shaped commits behind the reviewer gate.
  Usage: /workflow:commit [scope...]
---

# Commit

Scope (optional): $ARGUMENTS — when given, only matching logical-change scopes are committed;
everything else is reported as left for the human. When omitted, all scopes are in scope.

## Phase 1 — Inventory

- Run `git status --porcelain`, `git diff`, and `git diff --cached`.
- Map every working-tree change to a logical change, each scoped to a harness plane:
  `tools`, `workflows`, `agents`, `rules`, `commands`, `skills`, `docs`.
- Record which scopes match `$ARGUMENTS` (all when no scope is given).

## Phase 2 — Reviewer gate

- Dispatch the `reviewer` agent on the UNCOMMITTED diff + tree — this runs before any commit exists.
- Honor the verdict:
  - **APPROVE** → proceed to Phase 3.
  - **REQUEST-CHANGES** → fix the cited `file:line` findings locally, then re-dispatch the
    `reviewer`. No commit before the verdict flips to APPROVE.
  - **REJECT** → stop and hand back to the `builder`; do not route around the verdict.

## Phase 3 — Organize the plan

- One commit per logical change: `<type>(<scope>): <what>`.
- Never mix refactor and feature in one commit.
- Present the plan as a table: commit message → files → logical change.

## Phase 4 — Human approval

- Present the plan together with the `reviewer` verdict.
- **Wait for explicit go before executing any commit.**

## Phase 5 — Execute

- Commit each logical group with the message from the approved plan.
- Commits must contain NO `Co-Authored-By:` or "Generated with" trailer.
- Leave the groups outside the requested scope uncommitted; they are reported in Phase 6.

## Phase 6 — Report

- Commits created: message + short hash.
- What was intentionally left uncommitted.
- Push is the human's step — it happens only on a separate explicit trigger, never on this path.