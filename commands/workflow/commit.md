---
description: >
  Organize the working-tree changes into shaped commits behind the reviewer gate.
  Usage: /workflow:commit [scope...]
---

[WORKFLOW: COMMIT]
SCOPE: $ARGUMENTS ? match($ARGUMENTS) : ALL. Non-matching scopes deferred to human.

PHASE_1: INVENTORY
- Run: `git status --porcelain`, `git diff`, `git diff --cached`.
- Partition working-tree changes into logical units scoped to planes: {tools, workflows, agents, rules, commands, skills, docs}.
- Tag in-scope vs deferred changes per $ARGUMENTS.

PHASE_2: REVIEWER_GATE
- Dispatch `reviewer` on UNCOMMITTED diff + tree.
- Branches:
  * APPROVE ⇒ Advance to Phase 3.
  * REQUEST-CHANGES ⇒ Fix cited `file:line` findings locally → re-dispatch `reviewer` (commits FORBIDDEN until APPROVE).
  * REJECT ⇒ HALT; return to `builder` (bypassing verdict FORBIDDEN).

PHASE_3: PLAN
- Commits strictly atomic: `<type>(<scope>): <what>`.
- FORBID: Mixing refactor and feature in single commit.
- Schema: Table of `commit message → files → logical change`.

PHASE_4: HUMAN_GATE
- Present commit plan + `reviewer` verdict.
- HARD_BLOCK: Await explicit human confirmation before executing any commit.

PHASE_5: EXECUTE
- Commit each in-scope group with approved plan message.
- FORBID: Trailers (`Co-Authored-By:`, "Generated with").
- Retain out-of-scope changes uncommitted.

PHASE_6: REPORT
- Output: Created commits (`<message>` + `<short_hash>`) and uncommitted groups left behind.
- INVARIANT: FORBID git push (`push` is strictly a separate human trigger).