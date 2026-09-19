---
description: Universal refactoring rules — applies to all technologies
alwaysApply: true
---

[RULES: REFACTOR_COMMON]

STRUCTURAL_INVARIANTS:
- SRP: 1 function = 1 responsibility (split if described with "and").
- Limits: Function lines ≤ tech limit; File lines ≤ 300 (beyond: split into ≥2 modules).
- Complexity: Parameters ≤ 4 (beyond: use struct/object); Nesting depth ≤ 3 (beyond: extract helper).
- Hygiene: FORBID dead code, commented-out code, and unlinked TODOs.

NAMING:
- Behavior over Implementation: Names describe behavior, not mechanics.
- Identifiers: Single-letter names FORBIDDEN (except loop indices and math formulas).
- Lexicon: Consistent across codebase (FORBID mixing fetch/get/retrieve). Acronyms follow tech convention (e.g. HTTP in Go, http in Rust).

ERROR_HANDLING:
- Explicit: Handle every fallible operation. Silent swallows FORBIDDEN (log, propagate, or convert).
- Message Contract: Detail what failed, why, and caller remediation.

MEMORY_&_RESOURCES:
- Lifecycles: Every allocation requires an explicit owner and free path.
- Zero Leaks: Memory, FDs, goroutines, subscriptions. Validate via tooling (`valgrind`, `go vet`, `clippy`, etc.).

DEPENDENCIES:
- Purge unused imports. Prefer stdlib over external packages. Inline single-function dependencies.

TESTING:
- Invariance: Behavior unchanged; tests pass before AND after. Write missing tests FIRST.
- Edge Matrix: Empty input, max input, null/nil/undefined, concurrent access.

COMMITS:
- Atomicity: 1 logical change per commit (`refactor(<scope>): <what> — <which rule>`).
- Isolation: FORBID mixing refactoring with feature modifications.

CRAFT_PRINCIPLES:
- Simplicity first; premature abstraction FORBIDDEN. Deletion > Refactoring.
- Optimal refactor reduces net LOC. Extract reusable pieces (nothing lost, everything transforms).