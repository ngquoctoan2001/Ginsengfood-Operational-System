# 02 - Backend Implementation Guide

## 1. Mục tiêu

Hướng dẫn backend triển khai domain/service/API/workflow đúng spec, không tạo duplicate business truth và không bypass các gate vận hành.

## 2. Backend Layer Contract

| layer | Trách nhiệm | Không được làm |
|---|---|---|
| API handler/controller | Auth, permission, request validation, idempotency header, response/error shape | Không chứa nghiệp vụ phức tạp hoặc gọi MISA trực tiếp |
| Application service | Orchestrate transaction, state transition, audit, event/outbox | Không mutate append-only records |
| Domain service | Rule: recipe snapshot, issue decrement, release gate, trace, recall | Không phụ thuộc UI state |
| Repository/data access | Atomic read/write, constraints, projections | Không bypass service validation cho command |
| Worker/integration | Outbox dispatch, retry, reconcile, external boundary | Không để business module sync trực tiếp |

## 3. Cross-Cutting Rules

| rule_id | Rule | Required tests |
|---|---|---|
| BE-RULE-001 | Mọi command P0 phải kiểm permission backend | TC-M02-PERM-002 |
| BE-RULE-002 | Command có side effect phải dùng `Idempotency-Key` nếu API catalog yêu cầu | TC-M01-API-002 |
| BE-RULE-003 | State transition ghi `from_state`, `to_state`, actor, reason, source object | TC-M01-STATE-005 |
| BE-RULE-004 | Sensitive command ghi audit append-only | TC-M01-AUD-001 |
| BE-RULE-005 | Event xuất ngoài module đi qua `outbox_event`/integration layer | TC-M14-MISA-001 |
| BE-RULE-006 | Error response dùng code ổn định từ API spec | API regression |

## 4. Module Implementation Notes

| module | Backend focus | Critical invariant |
|---|---|---|
| M01 | Audit, idempotency, state log, event/outbox, error convention | Audit/event/ledger/history append-only |
| M02 | Local auth, RBAC, role-action permission, approval | Backend is permission gate |
| M03 | UOM, supplier, warehouse, config | Master used by transaction cannot be deleted, only inactive |
| M04 | SKU, ingredient, recipe versioning, recipe lines | G1 active baseline; future version approved/activated; 4 groups only |
| M05 | Source zone/origin/evidence/verification | `SELF_GROWN` raw lot requires verified source origin if policy enabled |
| M06 | Raw intake, receipt item, raw lot, incoming QC, readiness transition | Lot not ready until `QC_PASS` plus `RAW_LOT_MARK_READY` transition creates `lot_status = READY_FOR_PRODUCTION`; balance sufficient; no hold/reject/quarantine |
| M07 | PO, snapshot, work order, batch, process events | PO snapshot immutable; process order enforced |
| M08 | Material request, issue, receipt, variance | Material issue is only raw decrement; receipt does not decrement |
| M09 | QC inspection, disposition, batch release | `QC_PASS` is not `RELEASED` |
| M10 | Packaging, trade item, QR, print/reprint | QR state history append-only; reprint links original |
| M11 | Warehouse receipt, inventory ledger, balance, adjustment | Warehouse receipt requires batch `RELEASED`; ledger append-only |
| M12 | Internal trace, public trace, genealogy | Public trace whitelist-only; invalid QR safe response |
| M13 | Incident, recall, impact snapshot, hold/sale lock, CAPA | Recall impact uses snapshot; close blocked while recovery/CAPA open |
| M14 | MISA mapping, sync event/log, retry, reconcile | Missing mapping creates review/reconcile pending, not dropped event |
| M15 | Dashboard, alert, health | Metrics derived from operational truth, not duplicate truth |
| M16 | UI registry, mobile/PWA command | Offline submit idempotent |

## 5. Transaction Boundaries

| flow | Transaction rule |
|---|---|
| Recipe activate | Validate approved/effective; activate/deactivate as rule; audit/state in same transaction |
| PO create | Read active G1 recipe and snapshot all required fields in same transaction |
| Material issue execute | Validate `lot_status = READY_FOR_PRODUCTION` and balance; write issue execution, ledger debit, trace usage, audit atomically |
| Raw lot mark ready | Validate QC pass/source/balance/hold state; transition lot to `READY_FOR_PRODUCTION`; write state transition/audit/event atomically |
| Material receipt confirm | Write receipt/variance/audit; no raw inventory debit |
| Batch release approve | Validate QC pass, no active hold, required packaging/print gates; write release/action/audit atomically |
| Warehouse receipt | Validate released batch; write receipt, FG ledger credit, balance projection trigger/update |
| Recall impact | Create immutable exposure snapshot/version, not overwrite previous snapshot |
| MISA retry | Lock sync event; validate mapping; update retry/log/status atomically |

## 6. Error Handling

| condition | Expected backend behavior |
|---|---|
| Missing active G1 recipe | Reject PO create with `ACTIVE_RECIPE_NOT_FOUND` |
| Invalid recipe group | Reject with `INVALID_RECIPE_GROUP` |
| Material outside snapshot | Reject with `OUTSIDE_SNAPSHOT_MATERIAL` |
| Lot not `READY_FOR_PRODUCTION` | Reject material issue with `RAW_MATERIAL_LOT_NOT_READY` |
| Lot QC not pass when marking ready | Reject readiness transition with `RAW_MATERIAL_LOT_QC_NOT_PASSED` |
| Lot quarantined/held | Reject mark-ready or issue with `LOT_QUARANTINED` or hold-specific error from API spec |
| Insufficient balance | Reject material issue with `INSUFFICIENT_BALANCE` |
| QC pass but no release | Reject warehouse receipt with `BATCH_NOT_RELEASED` |
| QR not public-valid | Public trace returns safe `QR_INVALID`/`QR_NOT_PUBLIC`/`NOT_FOUND` |
| MISA mapping missing | Sync status review/pending and error log; event retained |

## 7. Backend Done Gate

- Domain rule has unit/integration coverage.
- API contract, error code, idempotency and permission tests pass.
- Audit/state/event/ledger side effects asserted.
- If API/DTO changed, frontend client/type/screen/test updated in same phase or evidence says no FE impact.
- If schema changed, migration and seed validation run.
- No direct MISA call from business module.
- No private field in public trace DTO.
- Material issue negative tests include lot with `QC_PASS` but not `READY_FOR_PRODUCTION`; backend must reject with `RAW_MATERIAL_LOT_NOT_READY`.
- Raw lot readiness command requires action permission `RAW_LOT_MARK_READY`, idempotency, `state_transition_log`, audit and event/outbox evidence.
