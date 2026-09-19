---
description: Commit all pending working-tree changes as a single Conventional Commits message, after your OK. Usage: /commit [type:(scope): hint]
---

Args: $ARGUMENTS

Fast single-commit path. For reviewer-gated, multi-commit shaping use `/workflow:commit`.

## Phase 1 — Inventory

- Run `git status --porcelain`, `git diff`, and `git diff --cached`.
- Nothing pending → stop and say so.
- Classify the whole diff into one Conventional Commits type + scope (harness planes:
  `tools`, `workflows`, `agents`, `rules`, `commands`, `skills`, `docs`):

  | Type | Use when |
  | --- | --- |
  | `feat` | adds behavior |
  | `fix` | repairs behavior |
  | `docs` | docs/readme/tree only |
  | `refactor` | no behavior change |
  | `chore` | toolchain, config, maintenance |
  | `perf` / `test` / `ci` / `build` / `revert` | their obvious meaning |

  Scope = dominant plane; omit scope when none dominates.

## Phase 2 — Draft the message

- Subject: `<type>[(<scope>)]: <imperative subject>` — lowercase, no trailing period,
  ~50 chars or fewer. e.g. `feat(rules): add minimalism ladder + markers`.
- Body: blank line, then 1–3 bullets, each naming what a group adds/changes and why —
  grounded in the actual diff, not a paraphrase of the subject.
- `$ARGUMENTS` (if given) refines intent; the diff stays the source of truth.
- No `Co-Authored-By:` / "Generated with" trailer — never co-author (AGENTS.md §2.5).

## Phase 3 — Confirm

- Show the exact message and the full file list.
- No commit before explicit go. Offer: commit as drafted / edit the message / abort.

## Phase 4 — Execute

- `git add -A`, then `git commit -F <message file>` — run under `.opencode/tools/watch.sh`.

## Phase 5 — Report

- `git log -1 --format='%h %s'` plus the file count.
- Push is the human's step — a separate explicit trigger, never on this path.