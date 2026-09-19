---
description: When complexity is justified — the six-rung ladder, with a measured hot-path override.
alwaysApply: true
---

# Minimalism ladder — when speed beats simplicity

The ladder decides WHEN complexity is justified; `rules/dsa-and-memory.md` decides
WHAT to reach for. Climb one rung at a time — the lowest rung that works is the answer.

## The rungs

1. **YAGNI** — don't build it. No feature, abstraction, or option nobody asked for.
2. **stdlib** — the standard library before any import.
3. **platform** — what the platform ships before third-party code.
4. **existing dep** — a dependency already in the project before a new one.
5. **one-liner** — an expression, not a function.
6. **minimum** — the minimum code that passes.

## The hot-path override

A measured hot path may climb past the simple rung — with a number, not an adjective
(`agents/benchmarker.md`). Unmeasured, the simple rung wins. On data that grows, a
lower rung that is asymptotically worse loses to the better algorithm
(`rules/dsa-and-memory.md`).

## Per-tech extensions

`rules/refactor-go.md` and `rules/refactor-shell.md` instantiate the rungs per
language ("Rung 2: …", "Rung 3: …") and carry the performance guardrails that
concretize the override.