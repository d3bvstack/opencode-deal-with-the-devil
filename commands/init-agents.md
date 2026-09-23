---
description: Discover repository invariants and compile the canonical AGENTS.md using the live harness. Usage: /init-agents [--refresh|--check|--adopt]
globs: ["**/*"]
---

[ROLE] SystemArchitect :: EXEC(`/init-agents`) -> initialize/sync repository canonical `AGENTS.md`.

[DUALITY]

- DynamicHarness (Automated): `$MK_SCRIPT` inside `<!-- GEN:init-agents:<id> -->...<!-- GEN:init-agents:end -->`
- CognitiveGuardrails (Curated/Static): Configured outside markers (tests, invariants, constraints, lifecycles)

[PROTOCOL: 5-PHASE DETERMINISTIC]

### PHASE 1: LOCATOR & STATE CLASSIFICATION

MK_SCRIPT = find_executable(["tools/mk-agents.sh", ".opencode/tools/mk-agents.sh"]) || ABORT("Error: mk-agents.sh not found.", exit=1)
STATE = (!-f "AGENTS.md") ? NEW : (grep -q '<!-- GEN:init-agents:' "AGENTS.md") ? MANAGED : LEGACY

DISPATCH:

- IF ARGV == "--check" -> EXEC($MK_SCRIPT --check) -> EXIT($?)
- IF ARGV == "--refresh" && STATE == MANAGED -> EXEC($MK_SCRIPT --refresh && git diff) -> EXIT(0)
- IF STATE == LEGACY -> INGEST("AGENTS.md") -> EXTRACT(rules, invariants, constraints) -> BUFFER -> GOTO PHASE 2
- IF STATE == NEW -> GOTO PHASE 2

### PHASE 2: NON-DESTRUCTIVE EVIDENCE GATHERING (Zero assumption/invention)

1. TOOLCHAIN: Detect lockfile -> PM [FORBID defaulting to npm if alternative lockfile present]:
   `pnpm-lock.yaml`:pnpm | `bun.lockb`:bun | `yarn.lock`:yarn | `package-lock.json`:npm | `Cargo.lock`:cargo | `poetry.lock`|`pyproject.toml`:poetry | `go.mod`:go
2. TEST_CLI (CRITICAL): Configs: `vitest.config.*` | `jest.config.*` | `pytest.ini` | `playwright.config.*` | `go.mod`
   Extract exact syntax: [all_tests, single_file: `<path>`, single_test: `-t "<name>"`].
3. CI_GROUND_TRUTH: Inspect `.github/workflows/*` or `.gitlab-ci.yml` (authoritative flags for build, lint, typecheck).
4. SCOPE_BOUNDARIES:
   - Dirs: `dist/`, `build/`, `.next/`, `coverage/`
   - Generated: `*.generated.*`, Prisma client, GraphQL types
   - Sensitive: `.env*`, secrets, service credentials

### PHASE 3: STRUCTURE & INVARIANT AUTHORING

Emit `AGENTS.md` scaffold below. Migrate extracted LEGACY constraints into Sec 2–4; populate `<...>` with Phase 2 ground-truth:

```markdown
# AGENTS.md — System Specification & Agent Orientation

<!-- GEN:init-agents:project-facts -->
<!-- GEN:init-agents:end -->

## 1. Fast-Path Operational Commands

| Action                   | Command                          | Context / Notes                         |
| :----------------------- | :------------------------------- | :-------------------------------------- |
| **Install Dependencies** | <exact install command>          | Run when package manifests change       |
| **Typecheck**            | <exact typecheck command>        | CI-blocking; zero error tolerance       |
| **Lint (Check)**         | <exact lint command>             | Verifies formatting and static analysis |
| **Lint (Fix)**           | <exact lint fix command>         | Run before committing                   |
| **Test (All)**           | <exact test all command>         | Suite-wide validation                   |
| **Test (Single File)**   | <exact single test file pattern> | Primary development feedback loop       |
| **Test (Single Case)**   | <exact single test name pattern> | Pinpoint debugging                      |
| **Build**                | <exact build command>            | Production bundle compilation           |

## 2. Code Style & Architectural Invariants

- **Type Safety**: <Strict rules; e.g., No `any`, `unknown` + narrowing/Zod schemas at boundaries, explicit return types on exported domain functions>
- **Error Handling**: <Error contract; e.g., Return `Result<T, E>` or domain `AppError`; never swallow caught errors with empty blocks>
- **Architectural Boundaries**: <Decouple domain core from adapters/transport; enforce `@/` path aliases>
- **State & Mutability**: <Immutable state updates only; forbid parameter mutation>

## 3. Agent Boundaries & Negative Constraints

- **FORBIDDEN**: Never manually edit auto-generated files: <exact globs: e.g., src/generated/**, prisma/client/**>.
- **FORBIDDEN**: Never modify lockfiles directly (`pnpm-lock.yaml`, `package-lock.json`, etc.). Always install via the package manager CLI.
- **FORBIDDEN**: Never execute destructive git operations (`reset --hard`, `clean -fd`, `push --force`) without explicit confirmation.
- **FORBIDDEN**: Never bypass verification gates (`git commit --no-verify`, lint bypass comments).
- **FORBIDDEN**: Never introduce external dependencies without checking manifest compatibility.
- **FORBIDDEN**: Never hardcode secrets, mock credentials, or API keys in code or commits.

## 4. Execution & Verification Lifecycle

Every agent modifying this codebase MUST complete this loop in order before declaring a task done:

1. **Targeted Test**: Run `<exact single test file command>` covering the modified module. Ensure pass.
2. **Typecheck**: Run `<exact typecheck command>`. Exit code must be `0`.
3. **Lint Verification**: Run `<exact lint command>`. Correct any introduced style regressions.
4. **Scope Audit**: Run `git status -s` to guarantee no leftover debugging artifacts, unintentional mutations, or untracked temporary files exist.

<!-- GEN:init-agents:commands -->
<!-- GEN:init-agents:end -->
<!-- GEN:init-agents:workflows -->
<!-- GEN:init-agents:end -->
<!-- GEN:init-agents:skills -->
<!-- GEN:init-agents:end -->
<!-- GEN:init-agents:agents -->
<!-- GEN:init-agents:end -->
<!-- GEN:init-agents:rules -->
<!-- GEN:init-agents:end -->
<!-- GEN:init-agents:tools -->
<!-- GEN:init-agents:end -->
```

### PHASE 4: HARNESS COMPILATION

EXEC: `$MK_SCRIPT --refresh`
ASSERT: STDOUT matches `mk-agents.sh: refreshed GEN:init-agents blocks in .../AGENTS.md`

### PHASE 5: POST-GENERATION INTEGRITY CHECK

1. MARKER INTEGRITY: Verify all 7 blocks (`project-facts`, `commands`, `workflows`, `skills`, `agents`, `rules`, `tools`) populated with matching `:end` tags.
2. RUNTIME PROBE: Run discovered Typecheck & Single-Test on repository target; assert exit code 0, zero config/invocation errors.
3. CONCISENESS AUDIT: Assert zero conversational filler or repetitive guidance.
4. USER BRIEFING: Emit summary with:
   - Toolchain and PM detected
   - Verified single-test syntax
   - Pending manual inputs marked `<TODO: ...>`
