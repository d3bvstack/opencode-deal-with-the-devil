---
description: Verify the environment before building; bound every command so nothing hangs.
alwaysApply: true
---

[RULES: EXECUTION_SAFETY]
SEQUENCE: `.opencode/tools/preflight.sh` -> FIX_CONFIG -> `.opencode/tools/watch.sh [CMD]` -> `quality.sh`
INVARIANT: LATE_VERIFICATION == NULL_VERIFICATION

PHASE 1: PREFLIGHT (`.opencode/tools/preflight.sh`)
- TRIGGER: MANDATORY prior to {compile, build, run}.
- SCOPE: Explicit verification of {.env, secrets, credentials}.
- SEVERITY: unset(required_var) => BLOCKER (NOT WARNING).
- SANITIZATION: FORBID printing secret values; LOG {name, status: SET|UNSET} only.

PHASE 2: EXECUTION_WATCHDOG (`.opencode/tools/watch.sh`)
- TARGETS: MANDATORY wrapper for {build, test, install, migration, deploy}.
- CONTROLS: Enforces hard timeout + idle timeout (kills hangs; prevents session stall).
- PARAMS: Calibrate `--idle` for prolonged silent tasks.
- FORBID: Wrapping interactive prompts.
- ON_EXIT(124):
  - DIAGNOSE hang/overrun root cause.
  - FORBID blind re-execution.