---
name: debug
description: >
  Find and fix a failure, root cause first.
  Auto-triggers on: "debug", "why is this failing", "what's wrong", "trace this", "root cause"
---

# Debug

## 1. Reproduce

- Reproduce the failure first, with the exact failing input. Run the command
  under `.opencode/tools/watch.sh` so a hang is killed, not waited on
  (`rules/run-safely.md`).
- No reproduction, no fix: a failure you can't trigger is a hypothesis.

## 2. Read ground truth

- Run `.opencode/tools/digest.sh`, `.opencode/tools/facts.sh`, and
  `.opencode/tools/codemap.sh` before reading code.
- Read by query (`rg`, `jq`) — never slurp whole files to answer what a query answers.

## 3. Isolate

- Bisect by boundary: input → parse → logic → output. Narrow the failing
  stage before touching code.
- Name the hypothesis, the failing input, and the evidence as `file:line`.

## 4. Fix

- Library-first: reuse or extract the primitive (`rules/library-first.md`).
- Write the failing test first, then the minimal change that passes
  (`rules/minimalism-ladder.md`).

## 5. Verify

- Run the smallest relevant check after each change.
- Finish with `.opencode/tools/quality.sh` green.

## 6. Report

- Commands and their output as evidence; failures stated, skips stated
  (`rules/prompt-contract.md`).