# `.opencode/tools/` — the parsing layer

Scripts that pre-digest the repo so agents read conclusions, not raw trees. Run one
command, get structured facts; the cache means you don't re-parse each time. This is
the "read-by-query" discipline (`AGENTS.md`) made executable.

## The tools

| Tool           | Answers                                                                    | Reads                              |
| -------------- | -------------------------------------------------------------------------- | ---------------------------------- |
| `digest.sh`    | "What am I working with?" — the start-of-task briefing                     | composes the summaries below       |
| `facts.sh`     | "How do I build/test/lint? Which gates and test frameworks exist?"         | manifests, toolchain               |
| `mk-agents.sh` | "How do I sync `AGENTS.md` with live harness files without clobbering rules?" | commands/, skills/, agents/, rules/, tools/, facts, digest |
| `preflight.sh` | "Is the environment ready?" — `.env` / secrets / toolchain before building | manifests, `.env.example`          |
| `codemap.sh`   | "Where does X live? What's heavy? What's untested?"                        | every source file                  |
| `untested.sh`  | "What needs a test before I touch it?" (the TDD worklist)                  | source vs tests                    |
| `dupes.sh`     | "What should I extract into the library?"                                  | repeated blocks                    |
| `quality.sh`   | "Is it the highest quality — strictly?" (the gate)                         | every strict linter / SAST / audit |
| `watch.sh`     | "Run this without ever hanging" — hard + idle timeouts around any command  | wraps a command                    |
| `mcp-servers.sh` | "Which MCP servers are configured?" — reads `.opencode/opencode.jsonc`     | `.opencode/opencode.jsonc`         |

## Use

```sh
# Orientation & discovery
.opencode/tools/digest.sh                        # brief yourself first (cached)
.opencode/tools/digest.sh --refresh              # rebuild briefing after big changes
.opencode/tools/codemap.sh                       # full queryable architectural index

# Harness management & synchronization
.opencode/tools/mk-agents.sh                     # update AGENTS.md marker blocks in-place
.opencode/tools/mk-agents.sh --refresh           # force rebuild of harness catalog tables
.opencode/tools/mk-agents.sh --check             # CI gate: exit 1 if AGENTS.md has drifted
.opencode/tools/mk-agents.sh --adopt             # migrate a legacy/handwritten AGENTS.md

# Preflight & quality gates
.opencode/tools/preflight.sh                     # verify .env / secrets / toolchain before building
.opencode/tools/quality.sh                       # the strict gate (exit 1 = a real failure)
.opencode/tools/quality.sh --with-tests --no-audit

# Safe execution wrapper
.opencode/tools/watch.sh --idle 60 -- make build # run without hanging (exit 124 = killed)