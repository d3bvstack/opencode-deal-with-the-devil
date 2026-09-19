---
description: Pick the optimal data structure and algorithm; pool allocations. Rust manages its own.
alwaysApply: true
---

[RULES: DSA_AND_MEMORY]
HIERARCHY: Correctness > Data Structure > Algorithm. Structure selection is an upfront design decision, not an afterthought.
INTERPLAY: `minimalism-ladder.md` dictates WHEN performance overrides simplicity; this rule dictates WHAT to reach for.

ACCESS_PATTERN_MAPPING:
- Sequential / index: array / slice / Vec (contiguous, cache-aligned; default).
- Key lookup: hash map (O(1) avg). Exception: N < ~20 ⇒ flat slice scan (faster, allocates less).
- Membership: set (FORBID: map-to-bool, list with `contains`).
- Work at ends: queue / deque / ring buffer (FORBID: shifting an array).
- Repeated extremes: heap / priority queue (FORBID: re-sorting each time).
- Ordered range scan: balanced tree OR sorted slice + binary search.
- Prefix / autocomplete: trie. Relations: graph + targeted traversal.
AXIOM: Name access pattern first; structure follows directly.

ALGORITHMIC_COMPLEXITY:
- State Big-O before coding. Superior Big-O overrides minimalism ladder on growing data.
- Negative Invariants:
  * FORBID: O(n²) on unbounded input.
  * FORBID: Linear scans on indexed data.
  * FORBID: Re-sorting in loops (sort once, reuse order).
- Profiling: Measure before micro-optimizing (`agents/benchmarker.md`); NEVER ship known-worse complexity on growing data.

MEMORY_MANAGEMENT:
- Pool High-Churn Allocations (per-request buffers, parse scratch, transient objects):
  * Go: `sync.Pool` (`rules/refactor-go.md`)
  * C: arena / freelist / slab
  * TS/JS: reuse buffers, `TypedArray`s, hot-path objects
- Size Upfront: Pre-allocate known capacity (`make([]T, 0, n)`, `Vec::with_capacity`, geometric `realloc`). Single-item growth in hot loops ≡ bug.
- Lifecycles: Every allocation requires an explicit owner and free path (`rules/refactor-common.md`).
- Rust Exceptions: Ownership/RAII governs lifetimes. FORBID hand-rolling pools to fight borrow checker. Restructure lifetimes first; use arenas (`bumpalo`) ONLY when profiler proves allocation bottleneck.