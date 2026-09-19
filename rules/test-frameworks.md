---
description: Detect and use the project's test framework; don't reinvent it. Reference per language.
alwaysApply: true
---

[RULES: TEST_FRAMEWORK_MANDATE]
ASSERT: PASS := framework_runner.exec() == 0. Hand-rolled test infrastructure FORBIDDEN.

OPERATIONAL_RULES:
1. DETECT_FIRST: Execute `.opencode/tools/facts.sh` || inspect repo manifest. Match framework AND existing style.
2. CARDINALITY: MAX 1 framework per language per repo. FORBID suite fragmentation.
3. ANTI_REINVENTION: FORBID custom assertions/mocks/runners. REQUIRE native fixtures/matchers/parameterization.
4. UNCONFIGURED_STACK: Select CANONICAL_DEFAULT (marked *). EMIT: 1-line justification.
5. CI_PARITY: Tests MUST run via project test command (`facts.sh`), not local-only.

AGENT_INTEGRATION:
- `agents/builder.md`: Implements tests in detected framework during TDD RED phase.
- `write-test`: Generates framework-idiomatic coverage.
- PARSER_GATE: input_parser == TRUE -> REQUIRE property-based tests for "done" state (`quality-bar.md`).

STACK_MATRIX (ORDER: [Canonical_Default*, Alternatives]):
| Lang | Unit / Runner* | Property-Based | Mock | E2E / Integration | Bench |
|---|---|---|---|---|---|
| C | Unity*, Criterion, CMocka, Check | theft | CMocka, FFF | — | custom + `clock_gettime` |
| C++ | GoogleTest(+GoogleMock)*, Catch2, doctest | rapidcheck | GoogleMock, trompeloeil | — | Google Benchmark, nanobench |
| Go | testing(stdlib, table-driven)* + testify | testing/quick, rapid, gopter | gomock(`go.uber.org/mock`), testify/mock | httptest, testcontainers-go | testing.B + benchstat |
| Rust | cargo test(+rstest)* | proptest, quickcheck | mockall | tests/ integration, doctests | criterion, divan |
| TS / JS | Vitest(new)* / Jest(existing); node:test(zero-dep) | fast-check | vi.mock/jest.mock, msw | Playwright(preferred) / Cypress | Vitest bench, tinybench |
| Python | pytest*, unittest(stdlib) | Hypothesis | unittest.mock, pytest-mock | Playwright-python, Selenium | pytest-benchmark |
| Shell | Bats-core(bash)*, shUnit2(POSIX), ShellSpec(BDD) | — | shellmock | Bats + real CLI | hyperfine |

SECONDARY_STACKS:
- Java: JUnit 5* + Mockito + AssertJ
- C#/.NET: xUnit* / NUnit + Moq
- Ruby: RSpec* / Minitest
- PHP: PHPUnit* / Pest
- Swift: Swift Testing* / XCTest
- Elixir: ExUnit*