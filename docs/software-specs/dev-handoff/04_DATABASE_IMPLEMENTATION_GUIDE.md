# 04 - Database Implementation Guide

## 1. Mục tiêu

Hướng dẫn DBA/backend chuyển database spec thành migration/schema an toàn, có constraint, index, seed, validation và rollback/restore gate.

## 2. Migration Order

| order | Group | Main tables |
|---|---|---|
| 01 | Foundation/auth/audit | `auth_*`, `role_action_permission`, `approval_*`, `audit_log`, `state_transition_log`, `idempotency_registry` |
| 02 | Event/outbox | `event_schema_registry`, `outbox_event`, `event_store` |
| 03 | Master data | `ref_uom`, `op_supplier`, `op_warehouse`, `op_warehouse_location`, `ref_adjustment_reason`, `op_config` |
| 04 | SKU/ingredient/recipe | `ref_sku`, `ref_ingredient`, `ref_ingredient_alias`, `ref_recipe_line_group`, `op_production_recipe`, `op_recipe_ingredient` |
| 05 | Source origin/raw material | `op_source_zone`, `op_source_origin`, `op_raw_material_receipt`, `op_raw_material_lot` with `lot_status`, raw QC tables, readiness state transition/audit support |
| 06 | Production/material | `op_production_order`, `op_production_order_item`, `op_work_order`, `op_batch`, `op_material_*`, `op_batch_material_usage` |
| 07 | Packaging/QR/print | `op_trade_item`, `op_packaging_job`, `op_packaging_unit`, `op_print_job`, `op_qr_registry`, `op_qr_state_history` |
| 08 | QC/release/warehouse/inventory | `op_qc_inspection`, `op_batch_release`, `op_warehouse_receipt`, `op_inventory_ledger`, `op_inventory_lot_balance` |
| 09 | Trace/recall | `op_trace_link`, `op_batch_genealogy_link`, `op_public_trace_policy`, recall/hold/sale lock tables |
| 10 | Integration/dashboard/UI/projections | `misa_*`, `op_dashboard_*`, `op_alert_*`, `ui_*`, `vw_internal_traceability`, `vw_public_traceability` |

## 3. Table Class Rules

| class | Examples | Rule |
|---|---|---|
| Master | `ref_sku`, `ref_ingredient`, `ref_uom`, `op_supplier` | Soft inactive if referenced; unique business code |
| Transaction | `op_production_order`, `op_material_issue`, `op_warehouse_receipt` | State machine + audit + idempotent command |
| Ledger | `op_inventory_ledger` | Append-only; correction via reversal/adjustment |
| Audit/history | `audit_log`, `state_transition_log`, `op_qr_state_history` | Append-only; actor/reason/time required |
| Mapping | `misa_mapping`, `role_action_permission`, `ref_ingredient_alias` | Unique source-target key; active/inactive |
| Snapshot | `op_production_order_item`, `op_recall_exposure_snapshot` | Immutable after creation; new version for changes |
| Projection/view | `op_inventory_lot_balance`, `vw_public_traceability` | Derived/rebuildable; not source of truth |

## 4. Constraint Requirements

| area | Constraint |
|---|---|
| Recipe group | Check enum: `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR` |
| Recipe active | Unique active operational recipe per SKU/scope/effective window |
| Production snapshot | Required formula version, group, ingredient code/name, qty, UOM, prep note, usage role |
| Raw lot readiness | `op_raw_material_lot.lot_status` includes `READY_FOR_PRODUCTION`; `READY_FOR_PRODUCTION` is distinct from `lot_qc_status = QC_PASS`; readiness transition must create state/audit evidence |
| Material issue | FK to approved request/PO snapshot/raw lot; referenced raw lot must have `lot_status = READY_FOR_PRODUCTION`; quantity > 0; idempotency unique key |
| Inventory ledger | No update/delete for posted rows; movement type enum; reference document required |
| Batch release | FK to QC inspection/batch; release state enum; approver/reason/time |
| Warehouse receipt | FK to released batch; positive qty; ledger reference |
| Public trace | View/projection excludes private fields by design |
| MISA | Mapping unique; sync event status enum; retry count; error log |

## 5. Append-Only Guard

Append-only tables must reject normal business updates/deletes:

- `audit_log`
- `state_transition_log`
- `event_store`
- `op_inventory_ledger`
- `op_qr_state_history`
- `op_recall_exposure_snapshot`

Data repair for these tables requires owner-approved migration/runbook and must create evidence.

## 6. Validation Queries

| validation | Expected result |
|---|---|
| Active baseline SKU count | 20 active baseline SKU |
| Required ingredients | `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`, `ING_THIT_HEO_NAC` active |
| Recipe groups | Exactly 4 required group codes |
| Active G1 recipes | Each baseline SKU has active G1 operational recipe |
| Operational forbidden token | Zero active/approved operational formula using forbidden baseline token |
| Warehouse baseline | At least one active `RAW_MATERIAL` and `FINISHED_GOODS` warehouse |
| Public denylist | Supplier/personnel/cost/QC defect/loss/MISA/private fields denied |
| Raw lot readiness enum | `lot_status` includes `READY_FOR_PRODUCTION` and material issue guard rejects non-ready lots |
| Seed idempotency | Running seed twice creates no duplicate business keys |

## 7. Database Done Gate

- Migration applies cleanly to empty DB.
- Migration applies safely to existing QA/staging DB.
- Constraints/indexes/checks implemented or explicitly deferred with owner decision.
- Cross-table material issue readiness guard is implemented in service and, where feasible, DB trigger/deferred constraint; any DB-level deferral must be documented with owner risk.
- Seed validation passes.
- Public trace projection checked for leakage.
- Rollback/forward-fix note included for each migration.
