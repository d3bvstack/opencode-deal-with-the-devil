---
description: Build a project-tailored library first; features are thin glue. No redundancy.
alwaysApply: true
---

[RULES: LIBRARY_FIRST]
CORE_AXIOM: Capabilities exist exactly once. Build reusable primitives before feature code; features are strictly thin glue.

DISCIPLINE:
- REUSE_FIRST: Search first via `rg` and cached `codemap` (assume primitive exists). FORBID re-implementation.
- EXTRACT_ON_COPY: On first attempted duplicate paste: extract into library, test once, call twice. FORBID second copies.
- ISOLATED_TESTS: Primitives ship with caller-independent tests. Callers trust primitives; zero caller re-testing.
- THIN_GLUE: Features wire tested primitives. IF a feature exceeds line limits ⇒ extract the hidden primitive.

TOPOLOGY:
- Structure: Exactly one home per concern, named for behavior (e.g. `tokens/`, `pagination/`).
- FORBID: `utils/`, `helpers/`, `misc/` (junk-drawer anti-pattern). Name the concrete concern.
- Purity: Domain primitives carry zero infrastructure imports (`agents/architect.md`).

TOOL_DEDUPLICATION:
- Ingest `.opencode/tools/dupes.sh` (repeated blocks) and `.opencode/tools/codemap.sh` (existing symbols).
- Remediate all candidates; retaining duplicate blocks is FORBIDDEN.

QUALITY_BAR:
- Covariance: Functions changing for identical reasons belong in one function.
- Priority: Deletion > Addition (optimal change: remove duplicate, add invocation).
- Continuous Extraction: Every block worth pasting requires an explicit name.