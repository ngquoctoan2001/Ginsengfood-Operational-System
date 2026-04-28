# 07 - CODE06 Warehouse + Inventory Prompts

## Scope

Phase `CODE06` covers warehouse receipt, inventory ledger, inventory lot balance, adjustment and allocation references.

## Prompt 07.01 - CODE06 Kickoff Audit

```text
Role: Warehouse/Inventory Audit Agent.
Mission: Audit warehouse receipt and inventory implementation. Do not edit files.
Read first: modules/11_WAREHOUSE_INVENTORY.md, database, api, ui, testing, data/warehouses_locations.csv.
Hard locks: finished goods receipt requires batch RELEASED; ledger append-only; balance derives from ledger.
Output: gap map, warehouse type assumptions, first gap, progress update.
```

## Prompt 07.02 - Warehouse Receipt Plan

```text
Role: Warehouse Planner.
Mission: Plan warehouse receipt implementation.
Rules:
- FINISHED_GOODS receipt requires batch RELEASED.
- RAW_MATERIAL and FINISHED_GOODS are go-live required warehouse types.
- PACKAGING/STAGING if present must be marked optional/assumption unless owner locks them.
Output: plan, DB/API/UI/test scope, progress update.
```

## Prompt 07.03 - Warehouse Receipt Backend/API

```text
Role: Warehouse Backend/API Agent.
Mission: Implement released-only warehouse receipt.
Workflow: implement receipt commands, validation, audit, ledger write, API tests and FE impact.
Output: files changed, released-gate evidence, commands, progress update.
```

## Prompt 07.04 - Inventory Ledger And Balance

```text
Role: Inventory Ledger Agent.
Mission: Implement append-only inventory ledger and lot balance projection.
Rules:
- Transaction taxonomy must include RAW_MATERIAL_RECEIPT, PRODUCTION_ISSUE, FINISHED_GOODS_RECEIPT, SALES_ISSUE, RETURN_RECEIPT, RECALL_HOLD, RECALL_RELEASE where in scope.
- Do not update ledger rows in place.
Output: ledger service/model/tests, balance validation, progress update.
```

## Prompt 07.05 - Inventory Adjustment And Allocation Reference

```text
Role: Inventory Adjustment Agent.
Mission: Implement adjustment/allocation references without bypassing audit.
Rules:
- Adjustment requires reason/permission/audit.
- Allocation does not rewrite ledger history.
Output: API/service/UI/tests, progress update.
```

## Prompt 07.06 - Warehouse Admin UI

```text
Role: Frontend Warehouse Agent.
Mission: Implement warehouse receipt, ledger viewer and lot balance UI.
Rules:
- Show receipt blocked reason if batch not RELEASED.
- Ledger viewer is read-only.
- Balance projections must show source ledger evidence.
Output: UI/API client/tests, progress update.
```

## Prompt 07.07 - CODE06 Review/Validate/Handoff

```text
Role: QA + Reviewer Agent.
Mission: Validate warehouse/inventory.
Required tests: unreleased batch receipt blocked; released receipt creates ledger and balance; ledger append-only; adjustment audited; transaction types match spec.
Output: verdict, validation, progress update.
```

