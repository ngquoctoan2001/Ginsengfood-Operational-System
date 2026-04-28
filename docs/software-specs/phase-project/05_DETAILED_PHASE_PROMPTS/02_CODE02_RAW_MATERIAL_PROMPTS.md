# 02 - CODE02 Raw Material Prompts

## Scope

Phase `CODE02` covers raw material intake, procurement type, raw material lot, incoming QC, lot readiness and raw receipt ledger boundary.

## Prompt 02.01 - CODE02 Kickoff Audit

```text
Role: BA/SA + Tech Lead Audit Agent.
Mission: Audit CODE02 target vs current implementation. Do not edit files.
Read first: modules/06_RAW_MATERIAL.md, modules/05_SOURCE_ORIGIN.md, modules/11_WAREHOUSE_INVENTORY.md, business rules, api, database, ui, testing, data/source_origin_fixture.csv.
Workflow:
1. Extract rules for SELF_GROWN and PURCHASED intake.
2. Map intake, lot, incoming QC, raw ledger receipt, UI and tests.
3. Verify QC vocabulary uses QC_PASS/QC_HOLD/QC_REJECT.
4. Pick first bounded gap.
Output: gap table, recommended gap, blocker list, progress update.
```

## Prompt 02.02 - Intake Procurement Type Plan

```text
Role: Planner Agent.
Mission: Plan gap {gap_id} for procurement_type validation and intake creation.
Rules:
- SELF_GROWN requires VERIFIED source origin.
- PURCHASED requires supplier/COA and must not require source zone.
- Source/supplier semantics must not be mixed in UI labels, DTOs or DB constraints.
Output: DB/API/FE/seed/test plan, write scope, non-goals, validation gate, progress update.
```

## Prompt 02.03 - Raw Intake DB/Backend/API

```text
Role: Raw Intake Backend/API Agent.
Mission: Implement raw material intake for approved gap {gap_id}.
Workflow:
1. Update schema/model/constraints if needed.
2. Implement create/update/submit/approve commands where specified.
3. Enforce procurement type validation backend-side.
4. Add idempotency for side-effect commands.
5. Emit audit/state transition.
6. Add API tests for SELF_GROWN and PURCHASED paths.
Output: files changed, API contract, validation, progress update.
```

## Prompt 02.04 - Raw Lot Lifecycle And Incoming QC

```text
Role: Raw Lot/QC Agent.
Mission: Implement raw lot lifecycle and incoming QC readiness.
Rules:
- Raw lot cannot become READY until incoming QC_PASS.
- QC_HOLD and QC_REJECT block issue/ready.
- QC_PASS must be recorded as QC result, not as downstream production approval.
Workflow: implement lot state, QC inspection/result commands, transition log/audit, API tests, UI impact.
Output: lifecycle evidence, negative tests, progress update.
```

## Prompt 02.05 - Raw Receipt Ledger Boundary

```text
Role: Inventory Boundary Agent.
Mission: Implement raw material receipt ledger boundary without confusing it with material issue decrement.
Rules:
- Raw intake/receipt can add raw inventory according to spec.
- Material Issue Execution later is the production decrement point.
- Ledger append-only.
Workflow: audit ledger model, implement receipt transaction type, balance projection, tests.
Output: ledger entries, balance validation, no double-decrement evidence, progress update.
```

## Prompt 02.06 - Raw Material Admin UI

```text
Role: Frontend/Admin UI Agent.
Mission: Implement raw intake, raw lot and incoming QC screens.
Rules:
- UI copy must say supplier if PURCHASED, source origin if SELF_GROWN.
- UI must block/disable invalid actions but backend remains authoritative.
- Show QC_HOLD/QC_REJECT reasons and lot not-ready state.
Output: UI/API client changes, tests, frontend validation, progress update.
```

## Prompt 02.07 - CODE02 Seed And Fixture Validation

```text
Role: Seed/Data Agent.
Mission: Ensure CODE02 seed/fixtures support SELF_GROWN and PURCHASED smoke tests.
Read first: data/source_origin_fixture.csv, data/uom.csv, data/04_SEED_VALIDATION_QUERIES.md.
Workflow: validate supplier/source fixture, UOM, COA placeholder policy, seed idempotency.
Output: seed changes or no-change evidence, validation commands, progress update.
```

## Prompt 02.08 - CODE02 Test, Review, Validate, Handoff

```text
Role: QA + Reviewer Agent.
Mission: Validate CODE02 implementation.
Required tests: SELF_GROWN verified pass, SELF_GROWN unverified fail, PURCHASED with supplier/COA pass, PURCHASED missing supplier/COA fail, QC_HOLD/QC_REJECT block ready/issue, duplicate command idempotent.
Output: verdict, findings, commands, handoff, progress update.
```

