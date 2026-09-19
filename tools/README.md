# `.opencode/tools/` — the parsing layer

Scripts that pre-digest the repo so agents read conclusions, not raw trees. Run one
command, get structured facts; the cache means you don't re-parse each time. This is
the "read-by-query" discipline (`AGENTS.md`) made executable.

## The tools

| Tool           | Answers                                                                    | Reads                              |
| -------------- | -------------------------------------------------------------------------- | ---------------------------------- |
| `digest.sh`    | "What am I working with?" — the start-of-task briefing                     | composes the summaries below       |
| `facts.sh`     | "How do I build/test/lint? Which gates and test frameworks exist?"         | manifests, toolchain               |
| `mk-agents.sh` | "Compose/refresh the generated AGENTS.md index from the live harness files" | commands/ (incl. workflow/), skills/, agents/, rules/, tools/ |
| `preflight.sh` | "Is the environment ready?" — `.env` / secrets / toolchain before building | manifests, `.env.example`          |
| `codemap.sh`   | "Where does X live? What's heavy? What's untested?"                        | every source file                  |
| `untested.sh`  | "What needs a test before I touch it?" (the TDD worklist)                  | source vs tests                    |
| `dupes.sh`     | "What should I extract into the library?"                                  | repeated blocks                    |
| `quality.sh`   | "Is it the highest quality — strictly?" (the gate)                         | every strict linter / SAST / audit |
| `watch.sh`     | "Run this without ever hanging" — hard + idle timeouts around any command  | wraps a command                    |

## Use

```sh
.opencode/tools/digest.sh             # brief yourself first (cached)
.opencode/tools/digest.sh --refresh   # rebuild after big changes
.opencode/tools/codemap.sh            # full queryable index
.opencode/tools/quality.sh            # the strict gate (exit 1 = a real failure)
.opencode/tools/quality.sh --with-tests --no-audit
.opencode/tools/preflight.sh          # verify .env / secrets / toolchain before building
.opencode/tools/watch.sh --idle 60 -- make build   # run anything without hanging (exit 124 = killed)
```

## How they're built

- **Pure `bash` + coreutils.** `rg` / `jq` used when present; degrade gracefully when not.
- **Library-first, dogfooded.** Shared logic lives in `lib/common.sh`; each tool is thin
  glue over it — the rule they enforce (`rules/library-first.md`).
- **Cached + fingerprinted.** Output caches to `.opencode/cache/` (gitignored), keyed to
  `git HEAD` + dirty tree; a stale cache rebuilds itself.
- **Best-effort, honest.** Symbol / dup / coverage extraction is regex-heuristic (marked
  `ponytail`), not an AST. It points you at the file; you read the file.

## Extending

Add a tool? Put shared logic in `lib/common.sh`, support `--summary` (so `digest.sh` can
compose it) and `--refresh`, emit markdown, cache via `emit_cached`. One concern per tool.
Register it in the table above and the root `README.md`.
