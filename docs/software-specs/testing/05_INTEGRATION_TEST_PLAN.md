# 05 - Integration Test Plan

## 1. Mục tiêu

Integration test plan kiểm tra contract xuyên module và dữ liệu: approval/audit, recipe snapshot, inventory ledger, trace genealogy, recall snapshot, QR/public trace, MISA integration layer. Đây là lớp bắt lỗi mà unit/API đơn lẻ thường bỏ sót.

## 2. Integration Boundaries

| boundary_id | Boundary | Modules | Tables/objects chính |
|---|---|---|---|
| INT-B01 | Recipe -> Production snapshot | M04, M07 | `op_production_recipe`, `op_recipe_ingredient`, `op_production_order`, `op_production_order_item` |
| INT-B02 | Raw lot QC -> `mark_ready` -> Material issue -> Inventory ledger | M06, M08, M11 | `op_raw_material_lot`, `lot_status`, `state_transition_log`, `op_material_issue`, `op_inventory_ledger`, `op_inventory_lot_balance` |
| INT-B03 | Material issue -> Batch genealogy -> Trace | M08, M07, M12 | `op_batch_material_usage`, `op_trace_link`, `op_batch_genealogy_link` |
| INT-B04 | QC -> Release -> Warehouse receipt | M09, M11 | `op_qc_inspection`, `op_batch_release`, `op_warehouse_receipt` |
| INT-B05 | QR -> Public trace policy | M10, M12 | `op_qr_registry`, `op_qr_state_history`, `vw_public_traceability`, `op_public_trace_policy` |
| INT-B06 | Trace -> Recall impact snapshot -> Hold/sale lock | M12, M13, M11 | `op_recall_exposure_snapshot`, `op_batch_hold_registry`, `op_sale_lock_registry` |
| INT-B07 | Business event -> Outbox -> MISA sync | M01, M14 | `outbox_event`, `misa_sync_event`, `misa_sync_log`, `misa_mapping`, `misa_reconcile_record` |

## 3. Integration Test Cases

| test_id | module | scenario | precondition | steps | expected result | data required | priority | requirement_id |
|---|---|---|---|---|---|---|---|---|
| TC-INT-REC-001 | M04/M07 | G1 recipe snapshot copied into PO and isolated from future changes | Active G1 recipe, SKU baseline | Create PO; capture snapshot; create/activate future recipe version; re-read PO | PO keeps original snapshot fields; no historical mutation | SKU, G1 recipe, future recipe | P0 | REQ-M04-007 |
| TC-INT-REC-002 | M04/M07/M08 | Material request lines derive only from PO snapshot | PO snapshot exists | Create material request from snapshot; attempt extra ingredient | Snapshot lines accepted; outside ingredient rejected unless approved exception | PO snapshot | P0 | REQ-M08-003 |
| TC-INT-LOT-READY | M06/M08/M01 | Mark-ready promotes raw lot into production-usable state | Raw lot `QC_PASS` with valid source and balance | POST mark-ready; attempt issue from marked lot and from another `QC_PASS` not-ready lot | Marked lot becomes `READY_FOR_PRODUCTION` and is allocatable/issuable; not-ready lot rejected; state_transition_log/audit exists | Raw lot state fixtures | P0 | REQ-M06-004 |
| TC-INT-INV-001 | M06/M08/M11 | Material issue is sole raw inventory decrement | Raw lot `READY_FOR_PRODUCTION` with balance | Execute issue; confirm material receipt; query ledger and balance | One raw debit at issue; receipt has no second debit; balance equals initial - issued | Raw lot, issue, receipt | P0 | REQ-M08-001, REQ-M08-002 |
| TC-INT-INV-002 | M08/M11/M01 | Idempotent issue replay does not double decrement | Issue ready | Execute same issue same idempotency key twice | One ledger debit; same response/replay marker; audit/idempotency registry captured | Issue fixture | P0 | REQ-M01-002, REQ-M08-001 |
| TC-INT-TRACE-001 | M06/M08/M07/M12 | Lot-level consumption creates trace chain | Issue executed into batch | Query internal trace by raw lot and batch | Trace includes raw lot -> material issue -> batch with quantities and timestamps | Raw lot, batch | P0 | REQ-M08-004, REQ-M12-001 |
| TC-INT-REL-001 | M09/M11 | QC_PASS does not open warehouse receipt until release | Batch QC_PASS | Attempt warehouse receipt; approve release; retry receipt | First reject; after release receipt pass and FG ledger credit | QC_PASS batch | P0 | REQ-M09-002, REQ-M11-001 |
| TC-INT-REL-002 | M09/M10/M11 | Release blocks active hold or incomplete packaging/print gate | Batch has hold or incomplete required docs | Approve release | Reject with clear state error; no release record approved | Batch gate fixtures | P0 | REQ-M09-003 |
| TC-INT-QR-001 | M10/M12 | QR state controls public trace eligibility | QR printed, failed, void | Resolve public trace for each | Printed valid resolves; failed/void returns safe invalid/not public | QR states | P0 | REQ-M10-003, REQ-M12-003 |
| TC-INT-PTRACE-001 | M05/M12 | Public trace strips internal source/supplier/QC/cost/MISA data | Internal trace has rich data | Build public projection/GET public trace | Only whitelist fields appear; denylist absent | Public policy, trace chain | P0 | REQ-M05-003, REQ-M12-002 |
| TC-INT-RECALL-001 | M12/M13 | Recall impact analysis uses snapshot, not live mutable query only | Trace chain exists | Run impact; modify downstream reference; re-run | Snapshot v1 unchanged; v2 created if re-run; audit actor/time | Recall case, trace chain | P0 | REQ-M13-002 |
| TC-INT-RECALL-002 | M13/M11 | Recall hold/sale lock visible to inventory/warehouse flow | Recall case with affected batch | Apply hold/sale lock; attempt warehouse/allocation/release | Downstream block/warn per policy; audit reason captured | Recall hold | P0 | REQ-M13-003 |
| TC-INT-MISA-001 | M01/M14 | Business module emits event to integration layer, not direct sync | Transaction that should sync | Inspect outbox and MISA sync event | Outbox event created; MISA sync layer owns mapping/status/retry | Business transaction event | P0 | REQ-M14-001 |
| TC-INT-MISA-002 | M14 | Missing mapping becomes reconcile pending with log | MISA event lacks mapping | Dispatch/retry | `MISA_MAPPING_MISSING`; sync log row; manual retry/reconcile available; event not dropped | Missing mapping fixture | P0 | REQ-M14-002 |
| TC-INT-AUD-001 | M01/M02/M09/M11/M13 | Sensitive transitions create audit and state logs | Transitions approve/reject/release/hold/adjust | Execute transitions | State log has from/to/actor/reason; audit append-only | Workflow fixtures | P0 | REQ-M01-001, REQ-M01-005 |

## 4. Integration Data Assertions

| area | Required assertions |
|---|---|
| Snapshot | PO item stores formula code, `formula_version`, group, ingredient code/display name, qty per batch 400, UOM, prep note, usage role. |
| Lot readiness | `QC_PASS` alone is not allocatable; `READY_FOR_PRODUCTION` requires mark-ready with audit/state transition. |
| Ledger | Posted ledger rows are append-only; corrections use new reversal/adjustment rows. |
| Trace | Trace link records direction/type and does not depend on public projection. |
| Release | Release record is distinct from QC inspection result. |
| Public trace | Whitelist-only projection, QR public eligibility, safe error for invalid QR. |
| MISA | Mapping status, retry count, error log, reconcile status, audit. |

## 5. Done Gate

- All P0 integration tests pass before E2E smoke is accepted.
- Every test case in this file maps to one or more RTM `REQ-*`.
- Integration failures must identify owning boundary `INT-Bxx` and affected module.
