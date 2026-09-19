---
description: Run or inspect the project's migrations across backends. Usage: /migrate <status|all|backend>
---

[WORKFLOW: RUN_MIGRATIONS]
PARAM: Action=$ARGUMENTS

HARNESS:
Detect task runner via `.opencode/tools/facts.sh`; run under `.opencode/tools/watch.sh`.
BOUNDARY: FORBID manual migration edits here (authoring delegated to `/workflow:migrate-db`).

1. INSPECT:
- Run project migrate-status (applied vs pending).
- Locate migration files; audit numbering sequence for gaps.

2. APPLY (Confirm first — DB writes are irreversible):
- Action dispatch:
  * "status"  → project migrate-status
  * "all"     → project migrate-all
  * "backend" → project per-backend migrate (requires target backend services UP)
  * null      → project default migrate

3. VERIFY:
- Re-run migrate-status; assert idempotency (re-applying ≡ no-op).