[SYSTEM_SPEC: .opencode/ ENGINEERING_HARNESS]

[HARNESS_CONTEXT]
REPO: `.opencode/` self-contained engineering harness (`tools/`, `rules/`, `agents/`, `commands/`, `skills/`).
STATE: 10 shell files (~1133 LOC via `digest.sh`, 10 untested via `untested.sh`). No manifest/test suite/CI (`.github/` NIL).
SHARED_LIB: `tools/lib/common.sh` (148 LOC); repeated preambles (`DIR=...`, `set -euo pipefail`, `. lib/common.sh`, `# shellcheck source`) are extraction targets (`dupes.sh`, `rules/library-first.md`).
GATES: PRESENT=[eslint, gofmt, cargo, clang-format, npm]; ABSENT=[shellcheck, shfmt, prettier, tsc, golangci-lint, ruff, cppcheck, semgrep, sonar-scanner, govulncheck, cargo-audit, pip-audit, osv-scanner, trivy] (`facts.sh`). Test framework absent -> apply canonical defaults (`rules/test-frameworks.md`).
BUILD_SYSTEMS: No npm/make/pnpm. If added -> register in `commands/`, run `/init-agents --refresh`.

[GLOBAL_AXIOMS]
EPISTEMIC_GATE: ∀claim ⟹ REQUIRE(command + stdout). Hypothesis := claim lacking proof (`file:line` | cmd+stdout). UNKNOWN = FAIL (Risk context: UNKNOWN = BLOCK).
EMPIRICAL_METRICS: Perf/capacity claims REQUIRE artifact + reproduction command. Qualitative adjectives without numbers FORBIDDEN (`rules/benchmarker.md`).
EXEC_TIMEOUT: ∀unbounded_cmd ⟹ EXEC: `.opencode/tools/watch.sh --idle 60 -- <cmd>` (exit 124 = HANG; `rules/run-safely.md`).
TRANSACTION_ATOMICITY: Reach 100% green gate OR `git revert` to last green commit. Zero red states allowed (`rules/builder.md`).
ORCHESTRATION_PRINCIPIUM: Standalone harness; ZERO orchestrator kernel. Multiagent coordination is lean, disposable; discard scaffolding.

[FORBIDDEN_OPERATIONS]
FORBID: MUTATE(node_modules/ | .git/ | generated_artifacts).
FORBID: MANUAL_EDIT(package-lock.json) ⟹ MUST execute via PM CLI.
FORBID: DESTRUCTIVE_GIT(reset --hard | clean -fd | push --force) without EXPLICIT_HUMAN_TRIGGER (`rules/run-safely.md`).
FORBID: GATE_BYPASS(commit --no-verify | lint suppressions lacking linked issue; `rules/quality-bar.md`).
FORBID: EXPOSE_CREDENTIALS(real/mock credentials, secrets, API keys in code or commits).
FORBID: UNVERIFIED_PASS(asserting pass without proof command + stdout; `rules/prompt-contract.md`).
FORBID: HALF_STATES(leaving broken/red verification bars; `rules/builder.md`).
FORBID: ATTRIBUTION_METADATA("Co-Authored-By" | "Generated with").
FORBID: MIXED_COMMITS(merging refactor + feature in identical commit; `rules/refactor-common.md`).
FORBID: UNWATCHED_EXEC(executing commands outside `tools/watch.sh`).

[CODE_INVARIANTS]
SHELL (`rules/refactor-shell.md`): Shebang `#!/bin/sh` (`#!/bin/bash` only if bash-required). Enforce: `"$var"`, `set -euo pipefail`, LOC/fn ≤ 25, `printf` > `echo`, `command -v` > `which`, `local` vars, `trap` cleanup.
LIBRARY_FIRST (`rules/library-first.md`): Tools must be thin glue over `tools/lib/common.sh`. Query `rg` + `tools/codemap.sh` pre-authoring. Rule of Two: Extract before 2nd copy (`tools/dupes.sh`).
HYGIENE (`rules/refactor-common.md`): 0 dead/commented code. `TODO` requires linked issue. Naming: behavioral over implementation; uniform vocabulary (standardize: fetch | get | retrieve); no single-letter vars outside loops/math.
ERRORS: Explicit handling on all fallible operations. Structure: `[WHAT_FAILED, WHY, CALLER_ACTION]`. Zero swallowing.
RESOURCES: Explicit owner + free path per allocation. Zero leaks (file descriptors, goroutines, subscriptions).
DEPENDENCIES: Stdlib preferred. Inline single-use dependency logic (`rules/library-first.md`).
MINIMALISM_LADDER (`rules/minimalism-ladder.md`): YAGNI → stdlib → platform → existing dep → one-liner → minimum code. Hot-path perf overrides require measured profiler deltas (`rules/benchmarker.md`), not adjectives.
DSA_MEMORY (`rules/dsa-and-memory.md`): Access pattern defines structure. Zero O(n²) on unbounded input. Slices: pre-size (`make([]T, 0, n)`). Pooling: `sync.Pool` (Go), arenas (C), buffer reuse (TS).

[EXECUTION_LIFECYCLE]
Sequence strictly required prior to completion:

1. BRIEF: `.opencode/tools/digest.sh` (start of task; `--refresh` post-mutation).
2. PREFLIGHT: `.opencode/tools/preflight.sh` (unset required env var = BLOCKER; abort).
3. CONTRACT: Formalize: INPUTS → OUTPUTS → EXACT_DONE_WHEN. Sharpen vague requests via `/prompt` (`rules/prompt-contract.md`).
4. REUSE_AUDIT: Query `rg`, `.opencode/tools/codemap.sh`, `.opencode/tools/dupes.sh`. Reuse existing primitives.
5. TDD: Failing test first (`rules/test-frameworks.md`): RED → GREEN (minimal code) → REFACTOR (`rules/refactor-<tech>.md`).
6. SMALLEST_CHECK: Run targeted test immediately post-mutation.
7. QUALITY_GATE: `.opencode/tools/quality.sh --with-tests` (strictest flags; record skips; exit 1 = FAILURE; `rules/quality-bar.md`).
8. SCOPE_AUDIT: `git status -s` (0 untracked files, 0 unintended mutations, 0 lingering artifacts).
9. REPORT: Emit exact commands + outputs confirming all claims. Explicitly state failures and skipped checks (`rules/prompt-contract.md`).

[MULTIAGENT_PROTOCOL]
TOPOLOGY: Standalone harness; DISPOSABLE subagents; NO kernel expansion.
CONCURRENCY: Fan-out ONLY for mutually independent slices (disjoint files/modules/review dimensions). Shared write target FORBIDDEN. Dependency chains (e.g., migrate → verify) MUST sequence linearly.
SIZING: Trivial tasks = 0 subagents. Fan-out reserved for wide breadth or pre-destructive consensus.
SUBAGENT_CONTRACT: Exactly 1 task + 1 verifiable completion criterion + [FORBIDDEN_OPERATIONS] + structured schema + targeted querying (`rg`/`jq`/`awk`, 0 context dumps).
STATE_VALIDATION: Target state must be re-verified immediately before destructive/irreversible steps (anti-stale scan).
ADVERSARIAL_GATE: High-stakes assertions require skeptic refutation agents (uncertain = default refuted). High-blast/irreversible plans require `devil` sign-off (`/workflow:deal`, `rules/risk.md`).
CONVERGENCE: Single gate convergence (tester + `reviewer` OR `.opencode/tools/quality.sh`). Vacuous pass = FAIL.
BINDING_NON_NEGOTIABLES: Project toolchain under `watch.sh`; backward-compatible default (additive/opt-in); backend-agnostic; irreversible operations (push, deploy, delete, migrate, security cutover) require human confirmation; stage risky mutations (verify new path vs old before decommissioning old; UNKNOWN = FAIL).

[AGENT_ROSTER] (Inspect `.opencode/agents/<name>.md` pre-dispatch)

- builder: TDD, library-first; ships 100% green; atomic green-or-revert (`builder.md`).
- forger: Toolsmith; builds self-enforcing shell scripts; extract before dup (`forger.md`, `library-first.md`).
- innovator: Fact-grounded 10x ideas + cheap experiment + kill criterion; measured claims (`innovator.md`, `benchmarker.md`).
- architect: System boundaries, contracts, dataflow; specs & interfaces, zero implementation; no infra types in domain sigs (`architect.md`, `refactor-go.md`).
- devil: Risk magistrate: BLOCK | PROCEED-WITH-CONDITIONS | PROCEED; UNKNOWN = BLOCK (`devil.md`, `risk.md`).
- documenter: Documentation only; zero source code mutation; examples sourced strictly from tests (`documenter.md`).
- reviewer: Merge reviewer: correctness, resource leaks, contracts, bloat; zero suppressions without linked issue (`reviewer.md`, `quality-bar.md`).
- security: White-box attacker; exploit analysis + rating + minimal fix; READ_ONLY (`security.md`).
- benchmarker: Quantified performance vs baseline; cites artifact + repro command; zero adjectives (`benchmarker.md`).
- compat-tester: Behavioral parity auditing vs reference per endpoint; additive/opt-in (`compat-tester.md`).
- norminette: 42 C-norm enforcement (C/42 codebases); PASS/FAIL only (`norminette.md`).
- orchestrator: Multiagent coordinator; lightweight, disposable (`orchestrator.md`).
- BUILTIN (explore, general): Runtime built-ins lacking harness spec; verify runtime behavior; no project spec claim.

[REGISTRY]
COMMANDS (`/<cmd> <args>`):
/bench [load|capacity|footprint|mem|startup]: Comparative baseline benchmarks; detect regressions.
/commit [type:(scope): hint]: Conventional commit; deep pass -> `/workflow:commit`.
/compat [feature-area]: Feature parity vs reference; deep pass -> `/workflow:compat-audit`.
/init-agents: Regenerate `AGENTS.md` dynamic sections (`tools/mk-agents.sh --refresh`).
/migrate <status|all|backend>: Migration ops; authoring via `/workflow:migrate-db`.
/prompt <rough request>: Refine ambiguous request into exact contract (`rules/prompt-contract.md`).
/quality [--no-audit] [--with-tests]: Strict quality gate check; PASS/FAIL/SKIP (`tools/quality.sh`).
/refactor <technology> [path]: Deep refactor to strict standards (`rules/refactor-<tech>.md`).

WORKFLOWS (`/workflow:<name>`):
commit [scope...]: Stage working tree behind `reviewer` gate; push remains human-gated.
deal: Submit risky proposal to `devil` for verdict before implementation (`rules/risk.md`).
migrate-db: Author and land safe database migration.
compat-audit: Endpoint-by-endpoint behavioral parity audit vs reference spec.
onboard-app: App migration (recon → schema → rewiring → validation).
ship <major|minor|patch>: Release pipeline (preflight → benchmark/parity gates → version bump → tag).
project-facts: Re-evaluate codebase & regenerate project facts block.

SKILLS (`skills/<name>/SKILL.md` auto-triggers):
api-endpoint: MATCH("add an endpoint" | "new API route" | "expose this over HTTP" | "wire a handler")
write-test: MATCH("write tests for" | "add test coverage" | "this needs tests")
debug: MATCH("debug" | "why is this failing" | "what's wrong" | "trace this" | "root cause")

RULES (`rules/*.md`):
ALWAYS_APPLIED: [prompt-contract.md, library-first.md, quality-bar.md, risk.md, refactor-common.md, run-safely.md, dsa-and-memory.md, test-frameworks.md, minimalism-ladder.md, minimalism-markers.md]
SCOPED_GLOBS:
rules/api-convention.md: `**/routes/**`, `**/handlers/**`, `**/controllers/**`, `**/api/**`, `**/*router*`, `**/*controller*`
rules/refactor-go.md: `**/*.go`
rules/refactor-shell.md: `**/*.sh`

TOOLS (`.opencode/tools/*.sh`):
digest.sh: Start-of-task briefing context (composes rest; accepts `--refresh`).
facts.sh: Introspect build/test/lint configurations and gates.
mk-agents.sh: Update `AGENTS.md` dynamic blocks (`<!-- GEN:... -->`).
preflight.sh: Validate runtime env, secrets, and toolchain readiness.
codemap.sh: Codebase topology, LOC mass, untested map.
untested.sh: TDD worklist (test gap).
dupes.sh: Identify repeated code and extraction candidates.
quality.sh: Strict gate runner (`--with-tests`, exit 1 = fail).
watch.sh: Process watchdog (`--idle 60 -- <cmd>`, exit 124 = timeout/hang).
lib/common.sh: Shared shell primitive (all tools wrap this).

HARNESS_TOPOLOGY & SSOT:
Root rules/orientation: `AGENTS.md`
Dynamic inventory: `<!-- GEN:init-agents:... -->` via `tools/mk-agents.sh`
Tools documentation: `tools/README.md`
Procedures: `commands/workflow/*.md` | Skills: `skills/<name>/SKILL.md`
Commands: `commands/*.md` | Durable rules: `rules/*.md`
Enforcement automations: `tools/*.sh` (maintained by `forger`)
SSOT PRINCIPLE: Exactly 1 definition per concept. Reference path (`rules/minimalism-markers.md`); duplicate documentation FORBIDDEN.
