---
name: write-test
description: >
  Generate tests for existing code. Auto-triggers on:
  "write tests for", "add test coverage", "this needs tests"
---

# PROTOCOL: DEBUG
INVARIANT: NO_REPRO -> NO_FIX (untriggered failure == hypothesis).

1. REPRODUCE:
   - Execute exact failing input under `.opencode/tools/watch.sh` (terminate hangs; `rules/run-safely.md`).
2. GROUND_TRUTH:
   - Run `.opencode/tools/{digest,facts,codemap}.sh` before inspecting code.
   - FORBID: Whole-file slurping; query strictly via targeted tools (`rg`, `jq`).
3. ISOLATE:
   - Bisect boundary (`input -> parse -> logic -> output`) prior to editing code.
   - Declare: hypothesis, failing input, and evidence (`file:line`).
4. FIX:
   - Architecture: Library-first (reuse/extract primitive; `rules/library-first.md`).
   - Sequence: Failing test first -> minimal passing change (`rules/minimalism-ladder.md`).
5. VERIFY:
   - Run smallest relevant check after each modification.
   - HARD_GATE: Terminate only when `.opencode/tools/quality.sh` passes green.
6. REPORT:
   - Provide executed commands + raw output as evidence; explicitly declare failures and skips (`rules/prompt-contract.md`).