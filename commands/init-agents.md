---
description: Compose or refresh the generated AGENTS.md index from the live harness files. Usage: /init-agents
---

Request: $ARGUMENTS

Generate, or refresh in place, the repo-root `AGENTS.md`. The marker-wrapped
sections are derived from the live commands / workflows / skills / agents /
rules / tools files and from `tools/digest.sh` + `tools/facts.sh` output — never
hand-written tables. Hand-written sections outside the
`<!-- GEN:init-agents:... -->` markers survive regeneration.

## Workflow

### Phase 1 — Verify the tool

- If `.opencode/tools/mk-agents.sh` is missing or not executable, stop and say so —
  the tables are derived, never invented by hand.
- Confirm the target is a repo root; `AGENTS.md` goes there (`repo_root()`).

### Phase 2 — Compose or refresh

- Run under `.opencode/tools/watch.sh` so a hang is killed, not waited on:
  - First create / refresh-after-change: `.opencode/tools/watch.sh -- .opencode/tools/mk-agents.sh --refresh`
  - Otherwise: `.opencode/tools/watch.sh -- .opencode/tools/mk-agents.sh`
- Exit 1 report: `AGENTS.md` exists with no markers — a legacy/hand-written file. Do
  not bypass the refusal. Report it.

### Phase 3 — Verify the result

- `AGENTS.md` exists at the repo root with `## Project facts` and the tooling sections.
- Every generated section sits between its `<!-- GEN:init-agents:... -->` /
  `<!-- GEN:init-agents:end -->` markers; hand-written sections preserved verbatim.
- Spot-check the timing of the change: a new command / agent / skill shows up as a row.

### Phase 4 — Report

- Files written, marker blocks refreshed, the exit code, and any legacy refusal.
- Evidence: `ls -l AGENTS.md`, the marker lines, a diff snippet (`git diff AGENTS.md`).