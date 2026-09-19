---
name: api-endpoint
description: >
  Scaffold a new REST endpoint across the planes. Auto-triggers on:
  "add an endpoint", "new API route", "expose this over HTTP", "wire a handler"
---

# PROTOCOL: API_ENDPOINT_INTEGRATION
FORBID: route_addition UNTIL READ(nearest_handler, ".opencode/rules/api-convention.md")

1. LOCATE: Identify owner module & closest endpoint -> mirror file structure, registration pattern, owner-scoping semantics.
2. DESIGN:
   - Spec: Method, path (`/v1/...`), req/res schema.
   - Auth/Scope: `API-key -> identity` resolution; enforce per-request owner-scope.
   - Gating: Cloud/enterprise logic OFF by default: `if envBool("FLAG")` (default: false).
3. IMPLEMENT: Handler + route registration + OpenAPI/API spec entry. Enforce adapter-agnostic persistence across all supported backends.
4. VERIFY:
   - Task Runner: Auto-detect via `.opencode/tools/facts.sh`; execute relevant checks.
   - SDK Sync: IF api_spec_modified -> regenerate SDKs.
   - Gate: Implement route-exercising test (`scripts/verify/` check OR CI job).
5. REPORT: Emit changed files, route contract (method, `/v1/...`, auth, owner-scope), and verification gate proof.