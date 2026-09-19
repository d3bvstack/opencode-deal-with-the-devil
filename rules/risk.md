---
description: When a decision must face the devil's verdict before it becomes code, and how risk is scored.
alwaysApply: true
---

[RULES: RISK_GATE_DEVIL]
ORDER_OF_PRECEDENCE: DECISION_GATE(devil | /deal) >> CODE_QUALITY_GATES(quality-bar, TDD)

EXTERNALIZATION_PRECONDITION:
MANDATORY: Plan externalization required prior to verdict.
SCHEMA: {assumptions, inputs_and_edge_cases, failure_modes, epistemic_gaps_unknowns}

ROUTING_TRIGGERS:
EVAL_REQUIRED := (
    MATCHES_ANY(
        IRREVERSIBLE(deploy, delete, data_migration, publish, force_push, secret_rotation),
        SECURITY(auth, access_control, crypto, secrets, untrusted_input),
        DATA_SCHEMA(migration, destructive_query, format_change, backfill),
        PUBLIC_SURFACE(shipped_api, contract, shared_lib_dependency),
        CONCURRENCY(shared_state, locks, async_ordering, race_hazards),
        WIDE_BLAST(multi_file_module, hot_path)
    ) OR UNCERTAIN(qualifies)
) AND NOT (trivial AND reversible AND local_scope)

SCORING_VECTORS (ref: agents/devil.md):
EVALUATE: scale=[1..5], identify=ARGMAX(worst_axis)
AXES: [blast_radius, reversibility, cost_on_failure, confidence_unverified_assumptions]

VERDICT_ACTION_GATES:
- BLOCK: HALT execution. Remediate named flaws -> re-submit. BYPASS=FORBIDDEN.
- PROCEED-WITH-CONDITIONS: Inject conditions into `builder.acceptance_criteria`.
- PROCEED: EXECUTE.
- FAILSAFE: unproven_safety_claim | UNKNOWN -> VERDICT=BLOCK