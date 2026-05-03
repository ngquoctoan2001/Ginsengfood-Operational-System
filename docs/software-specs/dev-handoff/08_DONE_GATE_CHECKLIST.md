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
| DG-006 | Seed validation | Seed changes pass validation and the full sorted seed chain runs twice without duplicate/idempotency drift if seed touched |
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

## 7. PF-04 Production Freeze Ops Gate

PF-04 is mandatory before marking the source pack `READY_FOR_PRODUCTION_FREEZE`. It verifies that release readiness covers runtime operations, not only business specs.

### 7.1 Deployment Topology Gate

| gate_id | Required evidence |
|---|---|
| PF04-DEP-001 | Build/deploy plan lists all runtime apps: `apps/admin-web`, `apps/public-trace`, `apps/shopfloor-pwa`, Operational API/backend, background workers, PostgreSQL, evidence storage adapter and printer/device adapter. |
| PF04-DEP-002 | Environment variables are documented for API, workers and frontend apps, including `ConnectionStrings__DefaultConnection`, auth/JWT refs, `MisaSyncOptions__*`, `PrinterOptions__*`, `EvidenceStorage__*`, `BackupOptions__*`, and frontend API base URLs. |
| PF04-DEP-003 | Secret management uses refs or platform secret injection only; no tenant credential, printer secret, storage key, database password or JWT secret is committed in repo, seed, Dockerfile, compose or docs. |
| PF04-DEP-004 | Evidence binary storage is bound through an adapter: local filesystem allowed only for `DEV_TEST_ONLY`; production uses company storage server or object-store compatible mount with encryption, access log and backup refs. |
| PF04-DEP-005 | Printer/device network boundary is documented: device/edge adapter has no direct DB access; callbacks go through API/worker with `DEVICE_CALLBACK` and HMAC credential refs. |

### 7.2 Runbook Gate

| gate_id | Required evidence |
|---|---|
| PF04-RUN-001 | Clean DB bootstrap runbook exists: create database, apply baseline migration, run seed in sorted order, run seed validation, rerun seed once to prove idempotency. |
| PF04-RUN-002 | Migration apply and failure policy exists: pre-data-write rollback allowed only when safe; post-data-write failures prefer forward-fix migration or owner-approved repair. |
| PF04-RUN-003 | Rollback, forward-fix, incident freeze and non-rollbackable data rules are documented for audit, ledger, QR/print, outbox, recall snapshots and evidence. |
| PF04-RUN-004 | Restore drill runbook validates DB schema, seed counts, ledger/balance, QR/print history, internal trace, public trace denylist, recall/CAPA evidence, MISA continuity and evidence binary restore. |
| PF04-RUN-005 | MISA `DryRun`/`Production` switch is documented with secret refs and a guard preventing dry-run status from being treated as production sync success. |
| PF04-RUN-006 | Evidence scan worker runbook covers pending scan, clean, infected, scan failed, retry/reupload, storage unavailable and alert paths. |
| PF04-RUN-007 | Outbox retry runbook covers retry/backoff, dead-letter or failed state, replay/reconcile command, idempotency and dashboard visibility. |

### 7.3 Monitoring Gate

| gate_id | Required evidence |
|---|---|
| PF04-MON-001 | `/health/live` and `/health/ready` or equivalent health endpoints cover API, DB, outbox/queue, MISA adapter, printer/device registry, evidence storage and scan worker where configured. |
| PF04-MON-002 | Alert rules exist for MISA failures, printer/QR failures, storage unavailable, evidence scan malware or failed scan, public trace leakage, inventory negative risk and recall SLA risk. |
| PF04-MON-003 | Recall SLA measurement point is clear: Operational must emit/store `NOTIFICATION_REQUESTED` and `notification_job_id`; external sales/notification system owns delivery. |

### 7.4 Smoke Gate

| gate_id | Required evidence |
|---|---|
| PF04-SMK-001 | Production freeze smoke covers the full path source origin to raw intake, raw lot readiness, PO snapshot, material issue, process steps, QC, release, warehouse receipt, trace, public trace, recall/CAPA and MISA sync/reconcile. |
| PF04-SMK-002 | Mandatory negative smoke covers public leakage, `QC_PASS` not `RELEASED`, raw lot not ready, missing MISA mapping, QR void, supplier scope isolation and production fixture block. |
| PF04-SMK-003 | Smoke report records entity ids, audit ids, ledger ids, trace snapshot ids, recall ids, sync event ids and public trace evidence. |
