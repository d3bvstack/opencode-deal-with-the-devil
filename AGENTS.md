# AGENTS.md — orientation, harness & multiagent workflow

This file is the project's orientation home: the engineering harness, the multiagent workflow,
and the full inventory of what's available under `.opencode/`. It loads at the start of every
session. Each concern below has one home in `.opencode/` — this file indexes it, it does not
re-document it (one source of truth per concept).

## Project facts

This repo is the `.opencode/` engineering harness itself — a drop-in configuration for Opencode
(README.md:5) whose only code is the shell toolchain under `tools/`: 9 source files, 820 lines,
thin glue over the shared `tools/lib/common.sh` (`.opencode/tools/codemap.sh`). There is no build
manifest, no test suite, and no CI pipeline (`.github/` absent): `facts.sh` reports no
build/test/lint command and no detected test framework, so the canonical defaults in
`rules/test-frameworks.md` apply. The quality gate `.opencode/tools/quality.sh` runs the strictest
flags for the tools that are present (eslint, gofmt, cargo, clang-format, npm); the absent
linters — shellcheck, shfmt, and the rest — are named gaps, not green passes
(`rules/quality-bar.md`). Review observations from `digest.sh`: 9 of 9 source files are untested,
the heaviest tool is `tools/quality.sh` at 176 loc, and `dupes.sh` flags 4 repeated boilerplate
blocks (the `DIR=…` / `set -euo pipefail` / `. lib/common.sh` / `# shellcheck source` preamble,
×3 each) as extraction candidates for the library.

_Run `/workflow:project-facts` to review the codebase and regenerate this section._

## 1. The engineering harness

Before changing code, work through this protocol in order. Facts first, evidence out —
`rules/prompt-contract.md` makes it binding.

1. **Get the briefing.** Run `.opencode/tools/digest.sh` (cached; `--refresh` after big changes).
2. **Detect the toolchain.** Run `.opencode/tools/facts.sh` for build/test/lint commands and which gates/frameworks exist.
3. **Verify the environment.** Run `.opencode/tools/preflight.sh`. Config is checked, never assumed; an unset required var is a blocker, not a warning.
4. **Read what exists.** Inspect existing implementations before creating new ones. A primitive that exists is used, not re-implemented (`rules/library-first.md` — run `.opencode/tools/dupes.sh` and `.opencode/tools/codemap.sh`).
5. **Write the failing test first.** Write or update a failing test before implementation, in the detected framework (`rules/test-frameworks.md`).
6. **Check smallest after each change.** Run the smallest relevant check after each change.
7. **Gate before done.** Run `.opencode/tools/quality.sh --with-tests` before declaring completion.
8. **Report faithfully.** Report commands, results, and remaining failures — failures stated, skips stated. Never call work complete based only on inspection.

Run every build, test, install, or deploy under `.opencode/tools/watch.sh`: it enforces a hard
timeout **and** an idle timeout so a hang is killed, not waited on (exit 124 = it hung; diagnose,
don't blind-re-run). Verify before you run, never hang — `rules/run-safely.md`.

## 2. Multiagent workflow

Use subagents without making a mess. This is a **standalone** config with **no orchestrator
kernel** — keep multi-agent work **lean and disposable**: fan out for the task, converge, throw
the scaffolding away. Do **not** build half a kernel.

### 2.1 Decompose, then pick a shape

- **Fan out (parallel)** only for genuinely independent slices — separate files, separate modules,
  separate review dimensions. No shared write target.
- **Sequence** dependency chains (order → invoice; migrate → verify). Parallelizing them corrupts state.
- **Right-size.** A trivial or conversational task needs zero subagents. Reserve fan-out for breadth
  (sweep many files) or confidence (independent perspectives before an irreversible step).
- **Hybrid is normal:** scout inline to discover the work-list, _then_ fan out over it.

### 2.2 Every subagent gets

- **One job, one "done when."** An objective with no verifiable done-condition is not a task.
- **The context it needs + the binding rules.** Assume it shares none of your memory. State the cwd,
  the paths, and the non-negotiables (§2.5) explicitly.
- **A schema, when you'll act on the result.** Force structured output so you consume data, not prose.
- **Read-by-query discipline.** Subagents `tail`/`rg`/`jq`/`awk` and return the _conclusion_, never
  the dump. The cheapest read returns only what you need. Logs are JSONL — filter, don't slurp. The
  `tools/` layer (§3.1) is this made executable: run `.opencode/tools/digest.sh` before hand-reading a tree.

### 2.3 Verify before you trust — and before you act

- **Cross-check claims. UNKNOWN = FAIL.** A finding without evidence (command + output, file + line)
  is a hypothesis, not a fact.
- **Re-verify state right before any destructive or irreversible step.** Files, branches, and data
  change under you — a human may be editing in parallel. A stale inventory is how you clobber
  someone's work or delete the wrong thing. Confirm the target _now_, not from a scan you ran five
  steps ago.
- **Adversarial pass for high-stakes findings.** Spawn skeptics prompted to _refute_; default to
  refuted when uncertain. Diverse lenses (correctness / security / does-it-reproduce) beat N
  identical voices. For an irreversible or high-blast plan, get the `devil`'s verdict first
  (`rules/risk.md`, `/workflow:deal`).

### 2.4 Converge on a gate

- Funnel parallel work into **one** quality gate — a tester + a reviewer (`reviewer`), or the
  project's verify gate (`make check`, CI) and `.opencode/tools/quality.sh`. A gate that passes
  vacuously is not a gate.
- **Measured, not claimed.** Every perf/capacity statement cites an artifact + the command that
  reproduces it. No invented numbers.
- Land behind a gate; sync the docs you touched; then stop.

### 2.5 Non-negotiables (binding for every subagent, even one-off slices)

- **Never co-author** a commit/PR (no `Co-Authored-By` / "Generated with").
- **Use the project's toolchain** — detect it with `.opencode/tools/facts.sh`; run commands under `.opencode/tools/watch.sh`.
- **Backward-compatible by default** — new behavior is additive/opt-in until proven; don't break existing callers.
- **Backend-agnostic** — a fix for one adapter/platform that breaks another is not done.
- **Confirm the irreversible** — pushes, deploys, deletions, publishes, data migrations, security cutovers → explicit human trigger.
- **Stage risky changes** — verify the new path against the old before deleting the old; UNKNOWN = FAIL.
- **Verify before you run** — `preflight` the config, never hang (`run-safely`); the quality gate is green before "done".
- **Report faithfully** — failures stated, skips stated; a clean result claimed only when verified.

### 2.6 The agent roster

Pick the narrowest agent for the job; compose them at a gate (§2.4). Each obeys §2.5. The eleven
agents below are defined in `.opencode/agents/` — read the file before dispatching for its full
prompt and constraints.

**Build & extend**

- `builder` — TDD, library-first, fact-driven; turns a contract into shipped code with every gate green.
- `forger` — toolsmith; forges the scripts/commands that make rules self-enforcing, iterates on feedback.
- `innovator` — vision; 10x ideas grounded in facts, each with a cheap experiment and a kill criterion.

**Advise & design**

- `architect` — boundaries, contracts, data flow; produces decisions and interfaces, not code.
- `devil` — risk magistrate; scores risk and pronounces a verdict (BLOCK / PROCEED-WITH-CONDITIONS / PROCEED) before risky code exists.
- `documenter` — docs only; never touches source, examples copied from tests.

**Verify (converge here)**

- `reviewer` — strict merge review: correctness, leaks, contract violations, bloat.
- `security` — white-box attacker; finds the exploit, rates it, names the minimal fix.
- `benchmarker` — performance in numbers against a baseline; no adjectives.
- `compat-tester` — measured behavioral parity against a reference (spec, prior version, or competitor), endpoint by endpoint.
- `norminette` — strict 42 C-norm enforcer, opt-in for C and 42 projects; runs the real CLI, rules PASS/FAIL.

Agents with **no project file** (e.g. `explore`, `general`) are runtime/built-in as
available in the environment but are **not defined in this repo** — do not claim a project spec for
them; verify their behavior before use.

## 3. Available tools

### 3.1 `tools/` — the parsing layer (`.opencode/tools/`, index in `tools/README.md`)

Scripts that pre-digest the repo so agents read conclusions, not raw trees. Cached + fingerprinted
(rebuild on stale), pure bash + coreutils, honest `ponytail` heuristics (points you at a file; you
read the file).

| Tool | Answers |
| --- | --- |
| `digest.sh` | "What am I working with?" — the start-of-task briefing (composes the rest) |
| `facts.sh` | "How do I build/test/lint? Which gates and test frameworks exist?" |
| `preflight.sh` | "Is the environment ready?" — `.env` / secrets / toolchain before building |
| `codemap.sh` | "Where does X live? What's heavy? What's untested?" |
| `untested.sh` | "What needs a test before I touch it?" (the TDD worklist) |
| `dupes.sh` | "What should I extract into the library?" (repeated blocks) |
| `quality.sh` | "Is it the highest quality — strictly?" (the gate; exit 1 = a real failure) |
| `watch.sh` | "Run this without ever hanging" — wraps any command with hard + idle timeouts |
| `lib/common.sh` | shared library the tools are thin glue over (library-first, dogfooded) |

### 3.2 `commands/` — one-shot actions (invoked `/name <args>`)

| Command | Does |
| --- | --- |
| `/bench [load\|capacity\|footprint\|mem\|startup]` | comparative benchmarks vs the reference baseline, flag regressions |
| `/commit [type:(scope): hint]` | commit all pending changes as one Conventional Commits message; deep pass → `/workflow:commit` |
| `/compat [feature-area]` | feature-parity comparison vs the reference; deep pass → `/workflow:compat-audit` |
| `/migrate <status\|all\|backend>` | run/inspect migrations across backends; author via `/workflow:migrate-db` |
| `/prompt <rough request>` | turn a rough request into a precise, fact-grounded spec the builder can execute |
| `/quality [--no-audit] [--with-tests]` | run every strict gate, report PASS/FAIL/SKIP |
| `/refactor <technology> [path]` | deep refactor at the strictest standard per `rules/refactor-<tech>.md` |

### 3.3 `skills/` — auto-firing capabilities (`.opencode/skills/<name>/SKILL.md`)

| Skill | Triggers on |
| --- | --- |
| `api-endpoint` | "add an endpoint", "new API route", "expose this over HTTP", "wire a handler" |
| `write-test` | "write tests for", "add test coverage", "this needs tests" |
| `debug` | "debug", "why is this failing", "what's wrong", "trace this", "root cause" |

### 3.4 `workflows/` — reusable procedures (invoked `/workflow:<name>`)

| Workflow | Does |
| --- | --- |
| `commit [scope...]` | organize working-tree changes into logical commits behind the `reviewer` gate; push stays human-gated |
| `deal` | submit a risky plan to the `devil` for a verdict **before** code exists (`rules/risk.md`) |
| `migrate-db` | author and land a new DB migration safely |
| `compat-audit` | endpoint-by-endpoint behavioral parity audit against the reference spec |
| `onboard-app` | migrate an external app onto the project (recon → schema → rewiring → validation) |
| `ship <major\|minor\|patch>` | full release pipeline (preflight, benchmark + parity gates, version bump, tag) |
| `project-facts` | review the codebase and regenerate the Project facts section |

### 3.5 `rules/` — durable constraints (`.opencode/rules/`, applied on every task)

`alwaysApply`: `prompt-contract`, `library-first`, `quality-bar`, `risk`, `refactor-common`,
`run-safely`, `dsa-and-memory`, `test-frameworks`, `minimalism-ladder`, `minimalism-markers`.
Scoped: `api-convention` (routes/handlers/API),
`refactor-go` (`**/*.go`), `refactor-shell` (`**/*.sh`).

## 4. Where things live

- Orientation + conventions → **this file**.
- Tools index → `tools/README.md`.
- Reusable procedures → `workflows/<name>.md` — not hard-coded into these instructions.
- Auto-firing capabilities → `skills/<name>/SKILL.md`.
- One-shot actions → `commands/<name>.md`.
- Durable constraints → `rules/*.md`.
- Recurring parse or enforceable check → `tools/<name>.sh`; the `forger` builds and maintains these.
- One source of truth per concept — reference it, don't re-document it.