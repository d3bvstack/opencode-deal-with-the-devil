---
description: >
  Full release pipeline. Usage: /workflow:ship <major|minor|patch>
---

[PIPELINE: SHIP]
PARAM: Bump_Type=$ARGUMENTS

GATES:
1. PREFLIGHT: Invariants: all tests pass, zero linter warnings, git tree clean, branch synced with main.
2. BENCHMARK: Run benchmark suite vs last release tag. IF regression > 5% ⇒ ABORT(report specifics).
3. PARITY: Run behavioral parity vs reference spec. IF new failures vs last release > 0 ⇒ ABORT(report diff).

MUTATIONS:
4. BUMP: Bump version across all manifests per Bump_Type. Update `CHANGELOG.md` via `/changelog`.
5. COMMIT: Commit `chore(release): vX.Y.Z` and tag `vX.Y.Z`.

APPROVAL_GATE:
6. PRESENT: Display [version, changelog summary, benchmark comparison, parity comparison].
   HARD_BLOCK: Await explicit "ship it" before pushing tag.