---
description: Deep refactor at the strictest standard for the technology. Usage: /refactor <technology> [file or module path]
---

[WORKFLOW: REFACTOR]
PARAM: Technology=$ARGUMENTS

PREFLIGHT:
- Ingest: `.opencode/rules/refactor-common.md` and `.opencode/rules/refactor-$ARGUMENTS.md`.
- IF tech rule file missing ⇒ HALT and report.

1. AUDIT (Read-only; zero mutations):
- Scan all in-scope files; enumerate common + tech rule violations; tally per category.

2. PLAN:
- Rank priority: `correctness > norm > clarity > style`.
- Define one-line transformation per group.
- Explicitly flag public API modifications.
- HARD_GATE: Present plan; await approval before proceeding.

3. EXECUTE:
- Commits strictly atomic (1 per logical change; mega-commits FORBIDDEN).
- Message: cite rule fixed + rationale.
- Run linter/norm-checker and tests after each change; HALT on test failure.

4. VERIFY:
- Run full test suite + final tech norm check.
- Summary table: violations before → after per category.
- List and justify any residual violations.