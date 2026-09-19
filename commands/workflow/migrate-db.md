---
description: >
  Author and land a new database migration safely.
  Usage: /workflow:migrate-db <what the migration does>
---

[WORKFLOW: DB_MIGRATION]
TARGET: Change $ARGUMENTS

1. DESIGN:
- Next sequential `NNN` in migrations dir (follow project numbering; respect gaps).
- Identify target backends/adapters.
- Cloud/enterprise tables default OFF via `(master_flag ∧ sub_flag)` pattern.

2. AUTHOR:
- Format: `NNN_<slug>` — forward-only, idempotent (`IF NOT EXISTS`, guarded).
- Adapter-agnostic: Single-backend breakage ≡ incomplete.
- APPROVAL_GATE: Present migration; await explicit approval before applying.

3. APPLY:
- Detect migrate runner via `.opencode/tools/facts.sh`; execute under `.opencode/tools/watch.sh`.
- Confirm application via project migrate-status command.

4. GATE:
- Add/extend gate (`scripts/verify/` or CI) actively exercising new schema.
- Anti-vacuity: Vacuous passes strictly invalid.

5. REPORT (`docs/migrations/db-<date>.md`):
- Log: migration number, backends touched, feature flag (if any), proving gate.