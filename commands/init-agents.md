---
description: Discover repository invariants and compile the canonical AGENTS.md using the live harness. Usage: /init-agents [--refresh|--check|--adopt]
globs: ["**/*"]
---

You are an expert system architect executing `/init-agents`. Your mission is to initialize or synchronize the repository's canonical `AGENTS.md`.

You must bridge two distinct layers:
1. **Dynamic Harness Inventory (Automated)**: Managed via `tools/mk-agents.sh` inside `<!-- GEN:init-agents:<id> -->` blocks (commands, workflows, skills, rules, tools, facts).
2. **Cognitive Guardrails (Curated/Static)**: Defined outside the markers (targeted test commands, architectural invariants, negative constraints, and verification lifecycles).

Follow this deterministic 5-phase execution protocol.

---

### PHASE 1: HARNESS LOCATOR & STATE CLASSIFICATION

Locate the harness script and evaluate the state of `AGENTS.md`:

```bash
# 1. Locate harness script
MK_SCRIPT=""
[ -x "tools/mk-agents.sh" ] && MK_SCRIPT="tools/mk-agents.sh"
[ -x ".opencode/tools/mk-agents.sh" ] && MK_SCRIPT=".opencode/tools/mk-agents.sh"
[ -n "$MK_SCRIPT" ] || { echo "Error: mk-agents.sh not found." >&2; exit 1; }

# 2. Inspect target file state
if [ ! -f "AGENTS.md" ]; then
  echo "STATE: NEW"
elif grep -q -- '<!-- GEN:init-agents:' "AGENTS.md"; then
  echo "STATE: MANAGED"
else
  echo "STATE: LEGACY"
fi
```

- **If argument is `--check`**: Run `$MK_SCRIPT --check` and exit immediately with its exit code.
- **If argument is `--refresh` AND state is `MANAGED`**: Run `$MK_SCRIPT --refresh`, run a git diff to verify changes, and exit.
- **If state is `LEGACY`**: Read `AGENTS.md` completely. Extract all handwritten rules, invariants, and constraints. You will migrate them into Phase 3.
- **If state is `NEW` or migrating `LEGACY`**: Proceed to Phase 2.

---

### PHASE 2: EVIDENCE GATHERING & COMMAND EXTRACTION

Inspect the codebase using non-destructive terminal commands. Do not assume or invent tooling configs.

1. **Package Manager & Toolchain**:
   - Inspect lockfiles: `pnpm-lock.yaml` (pnpm), `bun.lockb` (bun), `yarn.lock` (yarn), `package-lock.json` (npm), `Cargo.lock` (cargo), `poetry.lock`/`pyproject.toml` (poetry/python), `go.mod` (go).
   - Never default to `npm` if another package manager's lockfile exists.

2. **Single-Test & Execution Patterns (CRITICAL)**:
   - Identify test runner configs (`vitest.config.*`, `jest.config.*`, `pytest.ini`, `playwright.config.*`, `go.mod`).
   - Extract the exact CLI invocations for:
     - **All tests**: Suite-wide run.
     - **Targeted Single File**: e.g., `pnpm vitest run path/to/file.test.ts`.
     - **Targeted Single Test Name**: e.g., `pnpm vitest run -t "matches name"`.

3. **Ground-Truth CI Verification**:
   - Inspect `.github/workflows/` or `.gitlab-ci.yml`. CI commands are the single source of truth for build, lint, and typecheck flags.

4. **Directory Semantics & Prohibited Zones**:
   - Identify generated directories (`dist/`, `build/`, `.next/`, `coverage/`).
   - Identify generated code artifacts (`*.generated.*`, Prisma clients, GraphQL types).
   - Identify sensitive patterns (`.env*`, secrets, service credentials).

---

### PHASE 3: STRUCTURE & INVARIANT AUTHORING

Construct the complete scaffold for `AGENTS.md`. Place all static architectural rules outside the markers, and position the exact `<!-- GEN:init-agents:<id> -->` placeholders where the harness data belongs.

If migrating from **LEGACY**, integrate all prior constraints into Sections 2, 3, or 4.

Write the following layout to `AGENTS.md`:

```markdown
# AGENTS.md — System Specification & Agent Orientation

<!-- GEN:init-agents:project-facts -->
<!-- GEN:init-agents:end -->

## 1. Fast-Path Operational Commands

| Action | Command | Context / Notes |
| :--- | :--- | :--- |
| **Install Dependencies** | `<exact install command>` | Run when package manifests change |
| **Typecheck** | `<exact typecheck command>` | CI-blocking; zero error tolerance |
| **Lint (Check)** | `<exact lint command>` | Verifies formatting and static analysis |
| **Lint (Fix)** | `<exact lint fix command>` | Run before committing |
| **Test (All)** | `<exact test all command>` | Suite-wide validation |
| **Test (Single File)** | `<exact single test file pattern>` | Primary development feedback loop |
| **Test (Single Case)** | `<exact single test name pattern>` | Pinpoint debugging |
| **Build** | `<exact build command>` | Production bundle compilation |

## 2. Code Style & Architectural Invariants
- **Type Safety**: <Strict rule; e.g., "No `any`. Use `unknown` + type narrowing or Zod schemas at system boundaries. Explicit return types required on exported domain functions.">
- **Error Handling**: <Error contract; e.g., "Functions return `Result<T, E>` or raise domain-specific subclasses of `AppError`. Never swallow caught errors with empty blocks.">
- **Architectural Boundaries**: <Layering rules; e.g., "Core domain logic must not import database adapters or transport layers. Use `@/` path aliases for cross-module imports.">
- **State & Mutability**: <State boundaries; e.g., "Immutable state updates only. No parameter mutation.">

## 3. Agent Boundaries & Negative Constraints
- **FORBIDDEN**: Never manually edit auto-generated files: `<list exact globs: e.g., src/generated/**, prisma/client/**>`.
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

---

### PHASE 4: HARNESS COMPILATION

Run the compilation script to populate the marker blocks with live catalog data:

```bash
# Execute compilation
$MK_SCRIPT --refresh
```

Confirm that the output confirms successful execution:
`mk-agents.sh: refreshed GEN:init-agents blocks in .../AGENTS.md`

---

### PHASE 5: POST-GENERATION INTEGRITY CHECK

Perform immediate verification before closing the task:
1. **Marker Completeness**: Ensure all 7 markers (`project-facts`, `commands`, `workflows`, `skills`, `agents`, `rules`, `tools`) have matching `:end` tags and are populated.
2. **Command Validation**: Run the discovered **Typecheck** and **Single-Test** commands on a valid target in the repository. Confirm they execute with zero argument/config errors.
3. **Token Density Audit**: Ensure no conversational filler or repetitive guidance exists.
4. **Summary**: Provide the user with a concise briefing:
   - Toolchain and package manager established.
   - Exact single-test pattern verified.
   - Any manual inputs required (marked with `<TODO: ...>`).