---
description: Run comparative benchmarks (the project vs the reference baseline) and flag regressions. Usage: /bench [load|capacity|footprint|mem|startup]
---

[WORKFLOW: BENCHMARK]
PARAM: Scope=$ARGUMENTS

RUNNER:
Detect task runner via `.opencode/tools/facts.sh`; execute on current branch under `.opencode/tools/watch.sh`.

1. RUN:
- Map Scope → target ∈ {load, capacity, footprint, mem, startup}.
- IF Scope is empty ⇒ execute full suite.

2. ANALYZE:
- Ingest project benchmark artifact (cite measured data exclusively; claims FORBIDDEN).
- Vectors: read, write, login, boot time, memory (compare against reference baseline where relevant).
- Threshold: Flag regressions > 5% from baseline.

3. REPORT:
Emit markdown table:
| Operation | Before | After | Delta | Status (✅ / ⚠️ / ❌) |