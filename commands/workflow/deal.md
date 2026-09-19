---
description: >
  Deal with the devil — submit a risky plan to the risk magistrate before it becomes code.
  The decision-quality gate. Usage: /workflow:deal <the plan or decision>
---

[WORKFLOW: RISK_ADJUDICATION ("DEAL WITH THE DEVIL")]
TARGET: Plan $ARGUMENTS
GATE: Pre-code gate for `rules/risk.md` decisions. SKIP iff change is trivial, reversible, and localized (e.g., 1-line fix).

1. EXTERNALIZE:
- Format: `INPUTS → OUTPUTS → EXACT DONE_WHEN`.
- Itemize explicitly: [assumptions, edge cases, failure modes, UNKNOWNS].

2. GATHER_EVIDENCE:
- Run `.opencode/tools/digest.sh` (plus `quality.sh` / `dupes.sh` if relevant).
- Document matched `risk.md` triggers.

3. DISPATCH_DEVIL:
- Invoke `devil` agent with [plan + evidence].
- Expected assessment: steel-man → score risk (blast, reversibility, cost, confidence) → expose unstated failure → pronounce verdict.

4. HONOR_SENTENCE:
- BLOCK ⇒ Resolve cited issues → restart at Step 1 (routing around verdict FORBIDDEN).
- PROCEED-WITH-CONDITIONS ⇒ Bind conditions as mandatory build acceptance criteria.
- PROCEED ⇒ Advance directly.
- HUMAN_GATE: Irreversible decisions strictly require final HUMAN approval (devil advises; does not deploy).

5. BUILD:
- Hand verdict + conditions to `builder`.
- Invariants: TDD + library-first, satisfy 100% of conditions, ensure quality gate is green before "done".

6. RECORD:
- Irreversible or high-blast decisions: log verdict + conditions in PR / decision log (one short paragraph).