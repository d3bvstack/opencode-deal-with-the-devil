---
description: The strict, multi-tool quality bar that sits on top of the per-language rules.
alwaysApply: true
---

[RULES: QUALITY_BAR]
HARNESS: Universal static analysis orchestrated via `.opencode/tools/quality.sh` (tech-specific configs in `rules/refactor-<tech>.md`).

INVARIANTS:
- Strictest Flags: Maximum strictness mandatory (`--max-warnings 0`, `-D warnings`, `-Wall -Wextra -Werror`, `--check`). Gate auto-writes FORBIDDEN. Warning ≡ Error (warning budget = 0).
- Suppressions: Zero suppressions without linked issue ID + 1-line reason (eslint-disable, //nolint, #[allow(...)], # noqa, norm waivers). Unexplained suppression ≡ defect.
- Coverage Axiom: Skipped ≠ passed. Unrun gate ≡ uncovered surface (install tool OR state gap; assuming green FORBIDDEN).

CANONICAL_LAYERS (Fail early, fix cheap):
1. FORMAT (Check-mode): prettier, gofmt/gofumpt, rustfmt, ruff format, shfmt, clang-format. Formatter owns style.
2. LINT: eslint, golangci-lint, clippy, ruff, shellcheck, cppcheck.
3. TYPES: tsc --noEmit and language's strongest type flags.
4. SAST: semgrep, SonarCloud/sonar-scanner, CodeQL. Catches taint, cyclomatic complexity, security smells.
5. SUPPLY_CHAIN: npm audit, cargo audit, govulncheck, pip-audit, osv-scanner, trivy. Known vuln fails gate.
6. A11Y (Web UI): eslint-plugin-jsx-a11y, axe/Lighthouse for rendered UI. Inaccessible ≡ NOT DONE.

DONE_CRITERIA:
- Static: `.opencode/tools/quality.sh` exits 0 with all relevant gates run.
- Dynamic: Tests pass in project framework (`rules/test-frameworks.md`, `agents/builder.md`).
- Security: Manual security reasoning (`agents/security.md`) + automated SAST required (neither substitutes).