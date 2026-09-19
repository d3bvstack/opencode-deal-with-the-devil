---
description: >
  Take an external app and migrate it to run entirely on the project.
  Usage: /workflow:onboard-app <repo-url-or-path>
---

[WORKFLOW: ONBOARD_EXTERNAL_APP]
TARGET: $ARGUMENTS

PHASE_1: RECON (Read-only; mutations FORBIDDEN)
1. Ingest app (clone/locate).
2. Profile stack:
   - Frontend: [React, Vue, Svelte, etc.]
   - Backend: [Express, Django, Rails, Firebase, Supabase, etc.]
   - Database: [Postgres, MySQL, MongoDB, SQLite, etc.]
   - Auth: [JWT, sessions, OAuth providers]
   - Storage: [local, S3, etc.]
   - Realtime: [websockets, SSE, polling, none]
3. Map backend interface:
   - Frontend API endpoints, data models/schemas, auth flows, file upload paths, server-side logic (cron, webhooks, triggers).
4. Output Compatibility Matrix:
   | Feature | App uses | Project supports | Gap |
   | ------- | -------- | ---------------- | --- |
   Rows: CRUD, Auth (email/pass), OAuth providers, Realtime, File storage, API rules / ACL, Server-side logic, Fulltext search, Joins / expand.
5. Verdict:
   - FULL: Complete migration sans custom backend.
   - PARTIAL: Migration viable via hooks/workarounds.
   - BLOCKED: Critical unsupported dependency.
HARD_GATE: STOP. Present matrix. Await explicit human go/no-go.

PHASE_2: SCHEMA_MIGRATION
1. Convert models to project collection schemas (JSON).
2. Field typing: [string, number, bool, email, url, date, file, relation, select, json].
3. Define collection API rules: [list, view, create, update, delete].
4. Configure auth collection if users exist.
5. Import schemas into fresh instance; seed 10 records per collection.

PHASE_3: FRONTEND_REWIRING
1. Install/detect target backend SDK.
2. Refactor network calls to SDK equivalents:
   - REST → SDK list/get/create/update/delete
   - Auth → SDK password/OAuth2 sign-in
   - Realtime → SDK subscribe API
   - Uploads → SDK create-with-form-data
3. Set API base URL to project backend.
4. Purge legacy backend dependencies completely.

PHASE_4: VALIDATION
1. Boot project (migrated schema + seed) + frontend dev server.
2. Verify user journeys:
   - Auth (signup/login/logout), CRUD across all collections, file upload/download, realtime sync, ACL (non-owner edit permissions).
3. Execute existing app test suite (if present).
4. Run `/bench` load test against project backend with new schema.

PHASE_5: REPORT (`docs/migrations/<app-name>.md`)
- App name + source URL
- Stack transition: Before → After
- Collections created (with field summary)
- Endpoints mapped (count + list)
- Gaps identified & remediation strategy
- Performance numbers + total migration time
- Difficulty rating: [trivial | medium | hard | required-custom-hooks]