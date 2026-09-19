---
description: Run every strict quality gate in the repo and report PASS/FAIL/SKIP. Usage: /quality [--no-audit] [--with-tests]
---

[WORKFLOW: QUALITY_GATE]
PARAM: $ARGUMENTS
SCOPE: Static gate execution (`rules/quality-bar.md`).
GUARD: IF `.opencode/tools/quality.sh` is missing ⇒ HALT and report.

1. RUN:
- Execute `.opencode/tools/quality.sh $ARGUMENTS`.
- Purity: Verify-only; zero file writes (`--with-tests` adds test suite, `--no-audit` skips network audits).

2. REPORT:
- Output raw table verbatim (never soften):
  * ❌ (Blocker): Cite `file:line` + strict rule broken.
  * ⚪ (Uncovered surface): Name installation tool for critical gaps (SAST, audit, a11y).

3. FIX:
- Reporting only; tree mutations FORBIDDEN.
- Remediation belongs to `builder` under TDD. IF asked to fix ⇒ hand off to `agents/builder.md`.