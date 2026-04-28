# 04 - CODE03 Production + Material + Batch Prompts

## Scope

Phase `CODE03` covers production order, G1 snapshot, work order, material request/approval, material issue execution, material receipt confirmation, process events and batch genealogy root.

## Prompt 04.01 - CODE03 Kickoff Audit

```text
Role: Production Tech Lead Audit Agent.
Mission: Audit CODE03 target vs current code. Do not edit files.
Read first: modules/07_PRODUCTION.md, modules/08_MATERIAL_ISSUE_RECEIPT.md, modules/04_SKU_INGREDIENT_RECIPE.md, workflows/05_CANONICAL_OPERATIONAL_FLOW.md, database/, api/, ui/, testing/.
Hard locks:
- PO snapshot immutable.
- Material Issue Execution is the only raw inventory decrement point.
- Material Receipt Confirmation is separate and does not decrement again.
- Required process sequence: PREPROCESSING -> FREEZING -> FREEZE_DRYING.
Output: gap map, first bounded gap, dependency on MX-GATE-G1, progress update.
```

## Prompt 04.02 - Production Order G1 Snapshot Plan

```text
Role: Production Planner Agent.
Mission: Plan production order snapshot implementation for gap {gap_id}.
Workflow:
1. Define snapshot fields: sku_id, formula_code, formula_version, group, ingredient code/name, quantity_per_batch_400, UOM, prep_note, usage_role.
2. Define when snapshot is created.
3. Define immutability and audit.
4. Define API/UI/test changes.
Output: plan, write scope, validation gate, progress update.
```

## Prompt 04.03 - Production Order Backend/API

```text
Role: Production Backend/API Agent.
Mission: Implement approved production order and snapshot gap.
Rules:
- Production order cannot start without active approved operational recipe.
- Snapshot must not change when recipe master changes later.
- API must expose snapshot for downstream material issue and trace.
Workflow: implement DB/model/service/API/DTO, tests for immutable snapshot and missing recipe rejection, update FE impact.
Output: files changed, tests, commands, progress update.
```

## Prompt 04.04 - Material Request And Approval

```text
Role: Material Request Agent.
Mission: Implement material request/approval flow for production.
Rules:
- Request lines derive from PO snapshot/approved recipe, not manual arbitrary ingredient picking.
- Approval is permissioned and audited.
- Approved request does not decrement inventory.
Output: backend/API/UI/tests, audit evidence, progress update.
```

## Prompt 04.05 - Material Issue Execution Decrement

```text
Role: Inventory/Production Agent.
Mission: Implement Material Issue Execution as the raw material inventory decrement point.
Rules:
- Only QC_PASS/READY raw lots can be issued.
- Issue decrements raw inventory once.
- Duplicate issue command must be idempotent.
- Ledger append-only.
Workflow: implement lot allocation/issue lines/ledger transaction, balance validation, negative tests.
Output: no double-decrement evidence, ledger tests, progress update.
```

## Prompt 04.06 - Material Receipt Confirmation

```text
Role: Workshop Receipt Agent.
Mission: Implement Material Receipt Confirmation separately from issue.
Rules:
- Receipt records workshop receipt/variance.
- Receipt does not decrement raw inventory again.
- Variance requires reason/audit.
Output: service/API/UI/tests, variance evidence, progress update.
```

## Prompt 04.07 - Required Process Events

```text
Role: Production Process Agent.
Mission: Implement required process event chain.
Rules:
- Every product must pass PREPROCESSING -> FREEZING -> FREEZE_DRYING.
- Later process cannot be recorded before earlier required process.
- Process events must be auditable and linked to batch/work order.
Output: state machine, API commands, UI actions, tests for invalid order, progress update.
```

## Prompt 04.08 - Batch Genealogy Root

```text
Role: Batch Genealogy Agent.
Mission: Implement batch creation and genealogy root using production order, material issue and process events.
Rules:
- Batch genealogy must link source/raw lots -> issue -> production -> packaging later.
- Batch state transitions must be logged.
Output: batch model/API/UI/tests, trace handoff evidence, progress update.
```

## Prompt 04.09 - CODE03 UI Implementation

```text
Role: Production Admin UI Agent.
Mission: Implement production order, material request/issue/receipt, process event and batch screens.
Rules:
- Use API client/types from API catalog.
- Show immutable snapshot, lot selection constraints, issue/receipt variance, required process state.
- Permission-aware UI but backend remains authority.
Output: screens/forms/tables/actions/tests, FE validation, progress update.
```

## Prompt 04.10 - CODE03 Test/Review/Handoff

```text
Role: QA + Reviewer Agent.
Mission: Validate CODE03.
Required tests: missing active recipe blocks PO; snapshot immutable; manual ingredient outside snapshot rejected; issue decrements once; receipt does not decrement; process order blocks F-D before freezing; batch genealogy created.
Output: verdict, findings, commands, smoke evidence, progress update.
```

