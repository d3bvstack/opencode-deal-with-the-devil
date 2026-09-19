---
globs: ["**/*.sh"]
description: POSIX shell refactoring rules
---

[RULES: POSIX_SHELL_REFACTORING]

POSIX_COMPLIANCE:
- FORBID bashisms: [[ ]], arrays, (( )), ${var/pat/rep}.
- Shebang: #!/bin/sh (FORBID #!/bin/bash unless explicitly bash-only).
- Quote all expansions: "$var" (not bare $var). set -u compatible.
- command -v over which. printf over echo for non-trivial output.

STRUCTURE:
- Function lines ≤ 25.
- Layout: Functions at top, execution at bottom via main() call.
- Scope: Variables local via local keyword or subshell isolation.
- Cleanup: Mandatory trap on EXIT for all temp files.

POST_REFACTOR_GATES:
- shellcheck -s sh (zero warnings).
- Test with dash (not just bash); verify under all target shells.

LADDER_EXTENSIONS:
- Rung 2: Builtins over external commands (${#var} over wc -c, ${var%.*} over basename).
- Rung 3: awk one-liner over Python script for text processing.
- Rung 4: Existing jq over sed/grep for JSON.
- Rung 5: Pipeline over temp file (always).
- FORBID function wrapper around a single command.

PERFORMANCE_GUARDRAILS (Fork/Process Minimization):
- Single awk/sed over line-by-line shell loops (1 process beats N fork+execs).
- Redirection < file over $(cat file).
- Unified single awk over chained grep | awk | sed pipelines.
- Bulk processing over command substitution in while loops.
- Minimize subshells ($() forks; assignments do not) and pipe stages (each is fork + FD pair).
- Heredoc over echo piped to a command.
- exec for final command in script (eliminates lingering parent shell).