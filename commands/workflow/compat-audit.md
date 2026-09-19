---
description: >
  Behavioral parity audit against a reference spec.
  Usage: /workflow:compat-audit
---

[WORKFLOW: BEHAVIORAL_PARITY_AUDIT]

1. SURFACE_EXTRACTION:
- Ingest pinned reference API spec/OpenAPI (citation mandatory).
- Map endpoints [method, path, params, response_shape] across: [records, auth, files, realtime, settings, admin].

2. TEST_GENERATION:
- Generate requests via target backend's native SDK/client.
- Matrix per endpoint: [happy_path, auth_required, forbidden, not_found].

3. EXECUTION:
- Seed schema collections: [users, posts, files].
- Dispatch requests; record verdict:
  * PASS: Identical response.
  * PARTIAL: Status matches; shape diverges.
  * FAIL: Wrong status ∨ runtime crash.

4. GAP_ANALYSIS:
- Per discrepancy: Compare expected (reference) vs actual (target).
- Severity:
  * BREAKING: Application crash.
  * DEGRADED: Functional malfunction.
  * COSMETIC: Format variance (functional).

5. REPORT (`docs/compat/audit-<date>.md`):
- Metrics: Total endpoints, counts [Pass, Partial, Fail], Coverage %.
- Parity-blocking issues (prerequisites for reference compatibility).
- Full endpoint-by-endpoint audit table.