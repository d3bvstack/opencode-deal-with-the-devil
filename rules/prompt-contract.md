---
description: How opencode consumes a request (input) and returns work (output). The best-prompt contract.
alwaysApply: true
---

[RULES: PROMPT_CONTRACT]
AXIOM: Facts in, evidence out. Prompt quality ≡ empirical reproducibility, not eloquence. Binds all commands, skills, workflows, agents, and subagents (`AGENTS.md`).

INPUT_DISCIPLINE (Pre-action):
- Facts First: Run `.opencode/tools/digest.sh` (or domain tool) before planning. Base decisions on tool stdout; guessing FORBIDDEN.
- Read by Query: Extract conclusions via `rg`, `jq`, cached `codemap`. Slurping full files/trees FORBIDDEN.
- Contract Formulation: Formalize task as `INPUTS → OUTPUTS → EXACT DONE_WHEN`.
  * IF `done-when` is unstateable ⇒ task is underspecified ⇒ invoke `/prompt` before touching code.
- Surface Unknowns: Explicitly name missing facts; assuming or papering over gaps FORBIDDEN.

OUTPUT_DISCIPLINE (Return contract):
- Proof over Adjectives: Every claim requires empirical proof: `(command + stdout)` OR `file:line`. Unsubstantiated claims ("works", "fast", "done") are invalid.
- Machine-Actionable Structure: Return structured tables or lists for caller consumption; prose requiring re-parsing FORBIDDEN.
- Zero Half-States: Valid terminal states strictly ≡ {GATE_GREEN, REVERT_TO_LAST_GREEN}. Never return failing tests, incomplete wiring, or unlinked TODOs.
- Minimal Reporting: Emit changes + exact CLI reproduction commands (comment/doc syntax governed by `minimalism-markers.md`).
