---
description: Turn a rough request into a precise, fact-grounded spec the builder can execute. Usage: /prompt <rough request>
---

[WORKFLOW: SHARPEN_REQUEST]
PARAM: Request=$ARGUMENTS
GUARD: IF $ARGUMENTS is empty ⇒ request input from user and HALT.

1. GROUND:
- Run `.opencode/tools/digest.sh` (toolchain, codemap, untested list, duplication candidates). Read facts; zero guesswork.
- If digest reports no source (not a code repo), state so and proceed with known context.

2. CLARIFY:
- Identify ambiguities altering implementation: [scope, inputs/outputs, edge cases, success signal].
- Ask ONLY code-altering questions; state sensible defaults for remainder (interrogation FORBIDDEN).

3. FORGE:
Emit refined specification for `agents/builder.md`:
- Objective: 1-sentence goal in user terms.
- Context: Digest facts (languages, build/test commands, files in scope, existing primitives).
- Constraints: Mandatory rules (`library-first`, `quality-bar`, `dsa-and-memory`, `test-frameworks`, `refactor-<tech>`).
- Done-when: Machine-verifiable gate: target passing test(s), `quality.sh` green.
- Output contract: Deliverables contract per `rules/prompt-contract.md`.

4. HANDOFF:
- Offer dispatch to `builder`.
- BOUNDARY: FORBID building within `/prompt` (command produces spec; `builder` executes).