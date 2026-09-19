---
description: >
  Review the codebase and regenerate the Project facts section.
  Usage: /workflow:project-facts
---

[WORKFLOW: PROJECT_FACTS]
OBJECTIVE: Regenerate `## Project facts` in `AGENTS.md` strictly from fresh tool stdout (zero memory reliance). Every claim must trace to a tool run in this session.

1. REVIEW:
- Run `.opencode/tools/digest.sh --refresh` (under `.opencode/tools/watch.sh`) + `.opencode/tools/{codemap.sh, untested.sh, dupes.sh}`.
- Extract: stack/shape (languages, file count, LOC), heaviest files, untested count, dupes, CI presence (`.github/`).

2. FACTS:
- Run `.opencode/tools/facts.sh --refresh`.
- Extract: languages, build/test/lint commands, entry points, quality gates (present/absent), test framework.

3. COMPOSE:
- Draft `## Project facts` prose: project definition (`.opencode/` harness), stack/shape, build/test/gate state, test framework, Phase 1 metrics.
- Cite producing tool for every claim.
- Terminal suffix (exact):
  `_Run `/workflow:project-facts` to review the codebase and regenerate this section._`

4. GATE:
- Present draft. HARD_BLOCK: Wait for explicit go before editing `AGENTS.md`.

5. APPLY:
- Replace `## Project facts` in `AGENTS.md`.
- Add `project-facts` row to §3.4 workflows table.

6. REPORT:
- Output updated section and delta summary.