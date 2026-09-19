---
description: When complexity is justified — the six-rung ladder, with a measured hot-path override.
alwaysApply: true
---

[RULES: MINIMALISM_LADDER]
AXIOM: Governs WHEN complexity is justified (`rules/dsa-and-memory.md` dictates WHAT to select).
HEURISTIC: Ascend sequentially; lowest functional rung is mandatory.

RUNGS:
1. YAGNI: Don't build it. FORBID unrequested features, abstractions, or options.
2. STDLIB: Standard library before any import.
3. PLATFORM: Platform capabilities before third-party code.
4. EXISTING_DEP: Existing project dependency before adding a new one.
5. ONE_LINER: Expression, not a function.
6. MINIMUM: Minimum code that passes.

HOT_PATH_OVERRIDE:
- Escalation: Permitted strictly on measured hot paths citing numbers, not adjectives (`agents/benchmarker.md`).
- Baseline: Unmeasured code defaults to the simple rung.
- Asymptotics: On growing data, asymptotically superior algorithms override lower rungs (`rules/dsa-and-memory.md`).

EXTENSIONS:
- Per-tech rung instantiations ("Rung N: ...") and performance guardrails codified in `rules/refactor-go.md` and `rules/refactor-shell.md`.