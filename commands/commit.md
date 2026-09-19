---
description: Commit all pending working-tree changes as a single Conventional Commits message, after your OK. Usage: /commit [type:(scope): hint]
---

[WORKFLOW: FAST_COMMIT]
INTENT: Fast single-commit path (reviewer-gated multi-commit shaping uses `/workflow:commit`).
INPUT: $ARGUMENTS (refines intent; diff remains ground truth).

1. INVENTORY:
- Run: `git status --porcelain`, `git diff`, `git diff --cached`.
- IF nothing pending ⇒ HALT and report.
- Classify diff into 1 Conventional Commit type + dominant plane scope:
  * Type: feat (behavior added), fix (repair), docs (docs/tree only), refactor (no behavior change), chore (maintenance/config), perf, test, ci, build, revert.
  * Scope: Dominant plane ∈ {tools, workflows, agents, rules, commands, skills, docs}; omit scope if none dominates.

2. DRAFT_MESSAGE:
- Subject: `<type>[(<scope>)]: <imperative subject>` (lowercase, no trailing period, ≤50 chars; e.g. `feat(rules): add minimalism ladder + markers`).
- Body: Blank line, then 1–3 diff-grounded bullets (what changed + why; FORBID subject paraphrasing).
- INVARIANT: FORBID trailers (`Co-Authored-By:`, "Generated with"; `AGENTS.md §2.5`).

3. CONFIRM:
- Display: Drafted message and full file list.
- HARD_BLOCK: Zero commits before explicit go. Choices: [commit as drafted | edit message | abort].

4. EXECUTE:
- Run under `.opencode/tools/watch.sh`: `git add -A` then `git commit -F <message file>`.

5. REPORT:
- Output: `git log -1 --format='%h %s'` plus file count.
- INVARIANT: FORBID git push (push requires separate explicit human trigger).