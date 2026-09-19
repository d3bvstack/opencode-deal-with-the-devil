---
globs: ["**/routes/**", "**/handlers/**", "**/controllers/**", "**/api/**", "**/*router*", "**/*controller*"]
description: REST API conventions — endpoints, auth, access control, errors
---

[RULES: API_CONVENTIONS]

SHAPE:
- Routing: Resource-oriented, plural-noun paths under `/v1/<resource>`. Formats: JSON in/out.
- Contracts: Versioned (add, don't mutate; breaking shipped contracts FORBIDDEN).
- Docs: Document every public route in project OpenAPI / API spec.

AUTH_AND_ACCESS:
- AuthN: Authenticate all requests; resolve identity from credential (FORBID path `{id}`).
- AuthZ: Authorize per request; scope reads/writes to caller (FORBID client-supplied ownership).
- Ownership: Derive owner from credential, not request body (zero cross-owner access).

ERRORS:
- Status: 400 bad input, 401 unauthenticated, 403 denied, 404 not-found, 409 conflict, 429 rate-limit.
- Envelope: Unified envelope; leaking internals (stack traces, SQL, DSNs, file paths) FORBIDDEN.
- Content: Actionable: what failed, why, caller remediation.

PAGINATION_AND_IDEMPOTENCY:
- Lists: Default pagination (cursor or limit/offset); unbounded sets FORBIDDEN.
- Mutations: Idempotent verbs (`PUT`/`DELETE`); accept idempotency key for unsafe retries.

FLAG_GATING:
- Mount new/risky behavior behind flag (default OFF; missing flag ≡ unchanged legacy behavior).

AFTER_CHANGES:
- Update OpenAPI spec + regenerate SDKs.
- Add/extend verification gate (`scripts/verify/` check or CI job).
