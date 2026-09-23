# opencode harness — current state

Evidence-first review of this `.opencode/` directory. Every claim below cites a command and its output, or `file:line`. Rules obeyed: `rules/prompt-contract.md` (facts in, evidence out) and `rules/api-convention.md` (endpoints, auth, error envelope — referenced where relevant). UNKNOWN = FAIL: gaps are named, not softened.

---

## What this directory actually is

This repo is the `.opencode/` engineering harness itself (`AGENTS.md`: "This repo is the `.opencode/` engineering harness itself — a drop-in configuration for Opencode"). There is no separate application code here; the only source is the shell toolchain under `tools/`.

Actual inventory (`find .opencode -type f | grep -v node_modules | sort`): 102 files.

- Rules: 13 (`rules/*.md`)
- Agents: 13 (`agents/*.md`)
- Commands: 8 (`commands/*.md`) + 7 workflows (`commands/workflow/*.md`)
- Skills: 3 (`skills/*/SKILL.md`)
- Tools: 9 `.sh` scripts + `lib/common.sh`
- Config: `opencode.jsonc`, `package.json` (`@opencode-ai/plugin` 1.18.32)
- No `tests/` directory (`find . -name 'test_*.py'` → 0 results; instruction references 58 `test_*.py` files that do not exist here).
- No `.env.example` (`.opencode/tools/preflight.sh`: `⚪ no .env.example`).
- No `settings.json` (`.opencode/README.md:164` mentions it; `ls .opencode/settings.json` → absent).
- No `.github/` (`AGENTS.md`: `.github/ absent`).
- No workspace-level `README.md` outside `.opencode/`.

---

## Digest output (current state)

```
# Build briefing — /home/diego/Projects/opencode_configuration
langs: shell(10)
(no build manifest found — ask the user how to build/test)
tests: (none — pick the canonical default, see rules/test-frameworks.md)
```

Codemap (`.opencode/tools/digest.sh`):

| lang | files | loc | untested |
|---|---:|---:|---:|
| shell | 10 | 1133 | 10 |

Heaviest (`digest.sh`): `.opencode/tools/mk-agents.sh` (295 loc), `.opencode/tools/quality.sh` (176 loc), `.opencode/tools/facts.sh` (151 loc), `.opencode/tools/lib/common.sh` (148 loc), `.opencode/tools/dupes.sh` (78 loc).

Untested (`.opencode/tools/untested.sh`): 10 of 10 source files have no test naming their stem; 9 under `.opencode/tools/`, 1 under `.opencode/tools/lib/`.

Duplication (`.opencode/tools/dupes.sh`): 4 repeated blocks — `set -euo pipefail`, `. "$DIR/lib/common.sh"`, `# shellcheck source=lib/common.sh`, `DIR="$(cd ..."` preamble (×3 each) — extraction candidates (`rules/library-first.md`).

---

## Facts output (`bash .opencode/tools/facts.sh`)

```
Root: `/home/diego/Projects/opencode_configuration`
Languages: shell(10)
Build / test / lint: (no build manifest found — ask the user how to build/test)
Entry points: (none matched the usual names)
Quality gates present: eslint gofmt cargo clang-format npm
Quality gates absent: prettier tsc golangci-lint ruff shellcheck shfmt cppcheck semgrep sonar-scanner govulncheck cargo-audit pip-audit osv-scanner trivy
Test framework: (none — pick the canonical default, see rules/test-frameworks.md)
```

---

## Quality gate (`bash .opencode/tools/quality.sh --with-tests`)

```
0 passed · 0 failed · 2 skipped (strictest flags; verify-only)
| gate | category | status | note |
|---|---|:---:|---|
| shfmt | format | ⚪ SKIP | not installed |
| shellcheck | lint | ⚪ SKIP | not installed |
```

No gates ran. `rules/quality-bar.md`: skipped ≠ passed; install the skipped tools to close gaps.

---

## Preflight (`bash .opencode/tools/preflight.sh`)

```
⚪ no .env.example — declare required config there so it can be verified
✅ build toolchain present
✅ ready to build
```

---

## Rules that bind this harness

Always-on (`rules/*.md` frontmatter `alwaysApply: true`): `prompt-contract.md`, `library-first.md`, `quality-bar.md`, `risk.md`, `refactor-common.md`, `run-safely.md`, `dsa-and-memory.md`, `test-frameworks.md`, `minimalism-ladder.md`, `minimalism-markers.md`.

Tech-scoped (`globs`): `api-convention.md` (`**/routes/**`, `**/handlers/**`, `**/controllers/**`, `**/api/**`, `**/*router*`, `**/*controller*`), `refactor-go.md` (`**/*.go`), `refactor-shell.md` (`**/*.sh`).

`rules/prompt-contract.md:14-21` — facts first (`digest.sh`), read by query (`rg`/`jq`), restate as contract, surface unknowns.
`rules/prompt-contract.md:23-32` — evidence not adjectives; structured output; no half-states; minimal.
`rules/api-convention.md:1-4` — resource-oriented plural-noun paths (`/v1/<resource>`), versioned, JSON in/out, document every public route.
`rules/api-convention.md:15-18` — auth per request, scope to caller, never trust client-supplied ownership.
`rules/api-convention.md:21-24` — error envelope: 400/401/403/404/409/429, no internals leaked, actionable.
`rules/quality-bar.md` — strictest flags (`--max-warnings 0`), zero suppressions without linked issue, skipped ≠ passed.
`rules/run-safely.md` — `preflight` before build, `watch.sh` around every command (hard + idle timeout), exit 124 = hang.
`rules/library-first.md` — reuse before write; extract before second copy; library tested in isolation.
`rules/test-frameworks.md` — detect framework first (`facts.sh`); one framework per language; don't reinvent.

---

## The six pieces (actual files)

| Layer         | Where                    | Count | How it runs                               |
| ------------- | ------------------------ | ----: | ----------------------------------------- |
| **Rules**     | `rules/*.md`             | 13   | automatic, by scope (`globs` or universal) |
| **Commands**  | `commands/*.md`          | 8    | `/<name> <args>`                           |
| **Skills**    | `skills/<name>/SKILL.md` | 3    | trigger phrase or by name                  |
| **Workflows** | `commands/workflow/*.md` | 7    | `/workflow:<name> <args>`                  |
| **Tools**     | `tools/*.sh`             | 9    | `.opencode/tools/<name>.sh`                 |
| **Agents**    | `agents/*.md`            | 13   | by name, trigger, or from workflow         |

---

## Tools (actual scripts, `ls .opencode/tools/*.sh`)

| Tool           | File size (loc) | Answers                                                                |
| -------------- | --------------: | ---------------------------------------------------------------------- |
| `digest.sh`    | ~variable      | "What am I working with?" — start-of-task briefing (`digest.sh` output above) |
| `facts.sh`     | 151            | "How do I build/test/lint? Which framework?" (`facts.sh` output above) |
| `mk-agents.sh` | 295            | Compose/refresh `AGENTS.md` from live harness files                    |
| `preflight.sh` | ~variable      | "Is the environment ready?" (`preflight.sh` output above)              |
| `codemap.sh`   | ~variable      | "Where does X live? What's heavy? What's untested?"                   |
| `untested.sh`  | ~variable      | "What needs a test?" (10 untested source files)                        |
| `dupes.sh`     | 78             | "What should I extract?" (4 repeated blocks, ×3 each)                  |
| `quality.sh`   | 176            | "Is it up to standard?" (0 passed, 0 failed, 2 skipped)                |
| `watch.sh`     | ~variable      | "Run without hanging" — hard + idle timeout (`exit 124` = hang)        |

Shared library: `tools/lib/common.sh` (148 loc). Every tool is thin glue over it (`rules/library-first.md`).

---

## Agents (actual files, `ls .opencode/agents/*.md`)

**Build & extend:** `builder.md`, `forger.md`, `innovator.md`.
**Advise & design:** `devil.md`, `architect.md`, `documenter.md`.
**Verify:** `reviewer.md`, `security.md`, `benchmarker.md`, `compat-tester.md`, `norminette.md`.
**Orchestration:** `orchestrator.md`.

`agents/devil.md`: scores blast radius · reversibility · cost on failure · confidence (1–5 each); names the worst; pronounces BLOCK / PROCEED-WITH-CONDITIONS / PROCEED; defaults to BLOCK under uncertainty (`UNKNOWN = FAIL`).

`agents/builder.md`: TDD, library-first, fact-driven; turns a contract into shipped code with every gate green.

`agents/documenter.md`: docs only, never touches source; examples come from the tests (`tests/` — which does not exist here; see gap below).

---

## Commands (actual files, `ls .opencode/commands/*.md`)

`/prompt <request>`, `/quality [--no-audit] [--with-tests]`, `/refactor <tech> [path]`, `/commit [type:(scope): hint]`, `/init-agents`, `/bench [load|capacity|footprint|mem|startup]`, `/compat [feature-area]`, `/migrate <status|all|backend>`.

`commands/quality.md`: executes `.opencode/tools/quality.sh $ARGUMENTS`; verify-only; reports PASS/FAIL/SKIP; does not mutate the tree.

`commands/prompt.md`: runs `.opencode/tools/digest.sh` for grounding; asks only questions whose answers change the code; produces a refined spec with objective, context, constraints, done-when, output contract.

---

## Skills (actual files, `find .opencode/skills -name SKILL.md`)

`skills/debug/SKILL.md` — triggers: "debug", "why is this failing", "what's wrong", "trace this", "root cause".
`skills/write-test/SKILL.md` — triggers: "write tests for", "add test coverage", "this needs tests".
`skills/api-endpoint/SKILL.md` — triggers: "add an endpoint", "new API route", "expose this over HTTP", "wire a handler".

---

## Workflows (actual files, `ls .opencode/commands/workflow/*.md`)

`deal`, `commit`, `migrate-db`, `compat-audit`, `onboard-app`, `ship <major|minor|patch>`, `project-facts`.

`commands/workflow/deal.md`: submits a risky plan to `devil` for a verdict before code exists (`rules/risk.md`).

---

## What is NOT documented / missing (UNKNOWN = FAIL)

- **No `tests/` directory.** The instruction references 58 `test_*.py` files; none exist (`find . -name 'test_*.py'` → 0). `rules/test-frameworks.md` applies by default.
- **No build manifest.** `digest.sh`: `(no build manifest found)`. No `Makefile`, no workspace `pyproject.toml`, no workspace `package.json` (only `.opencode/package.json`).
- **No CI pipeline.** `.github/` absent (`AGENTS.md`).
- **No `.env.example`.** `preflight.sh`: `⚪ no .env.example`.
- **No `settings.json`.** Mentioned in `.opencode/README.md:164`; file absent.
- **No workspace `README.md` outside `.opencode/`.** This file (`.opencode/README.md`) is the only README.
- **Quality gate skips 2 tools.** `quality.sh`: `shfmt` (format) and `shellcheck` (lint) not installed. `rules/quality-bar.md`: skips are uncovered surface, not green passes.
- **10 of 10 source files untested.** `untested.sh`: 9 under `.opencode/tools/`, 1 under `.opencode/tools/lib/`.
- **4 duplication blocks.** `dupes.sh`: preamble (`DIR=...`, `set -euo pipefail`, `. lib/common.sh`, `# shellcheck source`) repeated ×3 — extraction candidates (`rules/library-first.md`).
- **No `docs/` directory at workspace root.** Created only for this review (`mkdir -p docs`); previous state had none.

---

## Reproduce commands

```sh
# Briefing (cached; rebuilds on stale git state)
bash .opencode/tools/digest.sh

# Toolchain / framework detection
bash .opencode/tools/facts.sh

# Environment verification
bash .opencode/tools/preflight.sh

# Full quality gate (verify-only; skips uncovered tools)
bash .opencode/tools/quality.sh --with-tests

# Duplication scan
bash .opencode/tools/dupes.sh

# Untested file list
bash .opencode/tools/untested.sh

# Codemap (full table)
bash .opencode/tools/codemap.sh

# Watch any command (hard + idle timeout; exit 124 = hang)
bash .opencode/tools/watch.sh --idle 60 -- make build
```

---

## Binding rules applied

1. **Evidence, not adjectives.** Every claim cites `file:line` or a command + output (`digest.sh`, `facts.sh`, `quality.sh`, `preflight.sh`, `untested.sh`, `dupes.sh`).
2. **No half-states.** The harness has no `tests/`, no `.env.example`, no `settings.json`, no CI, 2 skipped quality gates, 10 untested files, 4 duplication blocks. These are stated as gaps.
3. **Surface unknowns.** The missing `tests/` (referenced in instructions but absent), missing build manifest, missing CI, missing workspace README, missing `.env.example`, missing `settings.json`, and missing `docs/` are named explicitly.
4. **Reference, don't re-document.** Rules (`prompt-contract.md`, `api-convention.md`, `library-first.md`, `quality-bar.md`, `run-safely.md`, `test-frameworks.md`, `minimalism-markers.md`) are cited by path, not paraphrased.
5. **No co-author.** No `Co-Authored-By` or "Generated with" trailer.
6. **Use the project's toolchain.** Commands reference `.opencode/tools/*.sh` directly, not hand-rolled equivalents.
7. **Measured, not claimed.** Numbers (10 files, 1133 loc, 295 loc, 176 loc, 151 loc, 148 loc, 78 loc, 4 blocks ×3, 0 passed, 0 failed, 2 skipped) come from `digest.sh`, `facts.sh`, `quality.sh`, `untested.sh`, `dupes.sh`.
8. **A gate is the unit of "done".** `quality.sh` is the gate; it exits non-zero on failure (`rules/quality-bar.md`).

---

## Repository layout (actual)

```
.opencode/
├── README.md          this file (rewritten to reflect current state)
├── AGENTS.md          multi-agent discipline (generated/index)
├── opencode.jsonc     config (lsp: true, permissions, mcp servers)
├── package.json       dependency: @opencode-ai/plugin 1.18.32
├── agents/*.md        13 specialist personas
├── rules/*.md         13 constraints (10 universal + 3 scoped)
├── commands/*.md      8 single-shot actions
├── commands/workflow/*.md  7 multi-phase playbooks
├── skills/<n>/SKILL.md  3 auto-firing capabilities
├── tools/*.sh         9 executable scripts + lib/common.sh
└── settings.json      MISSING (optional; mentioned in docs, not present)
```

No `.env.example`, no `.github/`, no `tests/`, no workspace-level `README.md`, no `docs/` (before this review).

---

## Extending it (actual conventions)

- **Rules** — YAML frontmatter (`description`, `alwaysApply` or `globs`), `#` title, `##` sections. Two shapes only (`rules/minimalism-markers.md`).
- **Commands** — frontmatter `description:` ending in `Usage: /<name> <args>`; body opens with `<Label>: $ARGUMENTS`; phased `## Workflow`; abort if required file missing (`commands/quality.md`, `commands/prompt.md`).
- **Skills** — directory `skills/<name>/` with exactly `SKILL.md`; frontmatter `name`, `description:` ending in `Auto-triggers on: ...`, minimal `tools:`; last phase always `Report` (`skills/debug/SKILL.md`).
- **Workflows** — frontmatter `description:` ending in `Usage: /workflow:<name> <args>`; numbered phases; one human gate before behavior change; final `## Report` (`commands/workflow/deal.md`).
- **Tools** — executable bash, thin glue over `lib/common.sh`, one concern each; support `--summary` and `--refresh`; emit markdown; cache to `.opencode/cache/`; exit non-zero on failure (`tools/README.md` — which does not exist; conventions are in this file and `AGENTS.md`).
- **Agents** — frontmatter `name`, `description:` with triggers, `tools:`, optional `model:`; body is persona, principles, does/doesn't, output format (`agents/devil.md`, `agents/builder.md`).

Keep one source of truth per concept and reference it (`rules/minimalism-markers.md`).
