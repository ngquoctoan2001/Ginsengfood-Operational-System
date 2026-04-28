# 08 - Done Gate Checklist

## 1. Mục tiêu

Checklist này là gate bắt buộc trước khi đánh dấu một phase/gap/module là done.

## 2. Universal Done Gate

| gate_id | Gate | Required evidence |
|---|---|---|
| DG-001 | Requirement mapped | `REQ-*`, business rule, module, phase, test case |
| DG-002 | Source discipline | Không dùng source bị cấm; owner decision surfaced |
| DG-003 | Scope controlled | Files/layers touched match bounded gap; no broad refactor |
| DG-004 | API/FE sync | API/DTO change has FE client/types/screens/tests or no-impact evidence |
| DG-005 | DB migration | Migration applies and has validation/rollback note if schema touched |
| DG-006 | Seed validation | Seed changes pass validation and idempotency if seed touched |
| DG-007 | Backend build/test | Backend build and relevant tests pass |
| DG-008 | Frontend build/test | Frontend build and relevant tests pass if FE touched |
| DG-009 | Smoke/regression | Required smoke/regression tests pass |
| DG-010 | Handoff | Summary, files, commands, risks, owner decisions, rollback documented |

## 3. Layer Gates

| layer | Done condition |
|---|---|
| Database | Migration order correct, constraints/indexes/checks included, append-only guards covered |
| Backend | Domain invariants enforced server-side, including raw lot `READY_FOR_PRODUCTION` before material issue; permission/idempotency/audit/event tests pass |
| API | Catalog/request/response/error/auth/idempotency updated |
| Frontend | Screen catalog/form/table/client updated, states and permission behavior tested |
| Seed | 20 SKU, required ingredients, 4 groups, G1 active, public policy, warehouses validated |
| Integration | Outbox/MISA retry/reconcile, trace/recall snapshot, ledger projection tested |
| Security | Public/private boundary, secret handling, destructive action and override audited |

## 4. Hard Lock Gates

| gate_id | Must pass |
|---|---|
| DG-HL-001 | No active/approved operational formula uses forbidden baseline token |
| DG-HL-002 | G1 PO snapshot is immutable |
| DG-HL-003 | Material issue is the only raw inventory decrement |
| DG-HL-004 | Material receipt does not decrement raw inventory |
| DG-HL-005 | `QC_PASS` does not imply `RELEASED` |
| DG-HL-006 | Warehouse receipt requires batch `RELEASED` |
| DG-HL-007 | Public trace denylist enforced |
| DG-HL-008 | QR `VOID`/`FAILED` not public-valid |
| DG-HL-009 | MISA missing mapping becomes review/reconcile pending |
| DG-HL-010 | Seed baseline: 20 SKU, required ingredients, 4 recipe groups, G1 active |
| DG-HL-011 | Material issue requires raw lot `READY_FOR_PRODUCTION`; lot only at `QC_PASS` must fail with `RAW_MATERIAL_LOT_NOT_READY` |
| DG-HL-012 | Raw lot readiness transition uses `RAW_LOT_MARK_READY`, permission/idempotency, state transition and audit evidence |

## 5. Command Evidence Template

| category | Command/evidence |
|---|---|
| Backend build | Actual command and result, or blocker |
| Backend tests | Test command, passed/failed tests, residual risk |
| Frontend build | Actual command and result, or no FE impact evidence |
| Frontend tests | UI/API client tests, or no FE impact evidence |
| Migration | Apply/update command, DB target, validation |
| Seed | Seed command, seed validation, idempotency rerun |
| Smoke | E2E smoke IDs run, evidence links |
| Process cleanup | Agent-started process stopped or none started |

## 6. Release Gate

- All P0 requirements have tests.
- All P0 tests pass.
- Migration and seed run from clean DB.
- Seed run twice without duplicate.
- E2E smoke happy path and mandatory negative smoke pass.
- Public trace leakage test pass.
- MISA missing mapping/reconcile test pass.
- Rollback/restore plan reviewed.
- Open owner decisions are closed or explicitly deferred with accepted risk.
