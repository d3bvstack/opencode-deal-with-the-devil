---
description: Run the feature-parity comparison against the reference baseline for the project. Usage: /compat [feature-area]
---

[WORKFLOW: FEATURE_COMPARE]
SCOPE: $ARGUMENTS ? $ARGUMENTS : ALL (defer deep endpoint passes to `/workflow:compat-audit`).

1. ENUMERATE:
- List reference baseline capabilities in scope vs project equivalents (cite project reference docs).

2. COMPARE:
- Verdict per capability: WIN | PARITY | honest-LOSS ("choose them if" discipline).
- Invariant: Zero invented numbers; cite concrete artifacts.

3. REPORT:
Emit markdown table:
| Capability | Reference baseline | The project | Verdict |