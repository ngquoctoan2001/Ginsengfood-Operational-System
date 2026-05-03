# 09 - Release Rollback Guide

## 1. Mục tiêu

Hướng dẫn release, rollback, forward-fix, restore và hotfix cho các phase/gap trong `docs/software-specs/`.

## 2. Release Stages

| stage | Required checks |
|---|---|
| Pre-merge | Bounded gap done gate, unit/API/UI tests, no open hard lock failure |
| QA deploy | Migration applies, seed validates, API/UI smoke starts |
| Staging release candidate | Full regression P0/P1, E2E smoke, public trace security, MISA reconcile |
| Production readiness | PF-02 config/secret refs present, backup/restore check, rollback plan, monitoring/alert readiness |
| Post-release | Health checks, audit/event/outbox monitoring, smoke subset |

## 3. Rollback Principles

| scenario | Preferred strategy |
|---|---|
| Code-only failure before data write | Roll back deployment artifact |
| Migration failure before data write | Stop deploy; rollback migration if safe |
| Migration after data write | Prefer forward-fix migration; avoid destructive rollback |
| Bad seed | Idempotent seed fix; do not delete transaction data |
| Bad ledger/audit/history | Owner-approved repair migration or reversal/correction, not in-place mutation |
| Public trace leakage | Disable public route/projection if possible, hotfix DTO/policy, audit exposure |
| MISA sync issue | Pause dispatcher, keep events, fix mapping/retry/reconcile |
| QR/print issue | Void affected QR/print jobs through workflow; do not delete history |

## 4. Release Checklist

| item | Evidence |
|---|---|
| Build artifacts | Backend build result plus frontend build results for `apps/admin-web`, `apps/public-trace`, `apps/shopfloor-pwa` |
| Migration | Applied migration list and validation output |
| Seed | Seed validation and idempotency rerun |
| Smoke | E2E smoke report |
| Regression | P0/P1 regression report |
| Public trace | Denylist response evidence |
| MISA | Sync/retry/reconcile status evidence |
| Monitoring | Dashboard/alert/health endpoint evidence |
| Rollback | Exact rollback/forward-fix decision tree |
| PF-02 production config | GTIN production import or fixture-block evidence; MISA secret refs; printer device refs; evidence storage refs; notification outbox consumer boundary; backup/retention refs; user-role assignment import |

## 5. Hotfix Flow

| step | Action |
|---|---|
| 1 | Triage issue and affected module/phase/test case |
| 2 | Check whether issue touches hard lock or public/private boundary |
| 3 | Freeze related risky operations if needed: raw material readiness/material issue queue, public trace, MISA dispatcher, print queue, warehouse receipt |
| 4 | Patch smallest safe layer |
| 5 | Run targeted regression plus affected smoke subset |
| 6 | Record incident, evidence, owner decision if required |

## 6. Rollback/Handoff Template

```markdown
## Release/Rollback Handoff

- Release id:
- Phase/gap:
- Modules:
- Migration ids:
- Seed version:
- Build artifacts:
- Tests passed:
- Smoke evidence:
- Known risks:
- Rollback option:
- Forward-fix option:
- Data repair needed:
- Owner decisions:
- PF-02 config refs:
- Monitoring checks:
```

## 7. Non-Rollbackable Data

Do not destructive rollback these without owner-approved repair plan:

- `audit_log`
- `state_transition_log`
- `op_inventory_ledger`
- `op_qr_state_history`
- `op_recall_exposure_snapshot`
- `op_source_origin_evidence`
- `op_recall_capa_evidence`
- referenced evidence files in local/dev storage or company storage server
- dispatched `outbox_event`/MISA sync logs
- raw lot readiness state transition/audit records once accepted

Use reversal, compensation, void/reprint, recall hold, reconcile or forward-fix migration instead.

## 8. PF-02 Production Readiness Runbook Addendum

| area | release check | rollback/restore note |
|---|---|---|
| GTIN/GS1 | Verify production print cannot use `DEV_TEST_ONLY`/`is_test_fixture=true` identifiers; production import rows use `is_test_fixture=false`. | Bad GTIN import is corrected by deactivating/importing new mapping, not deleting print/QR history. |
| MISA AMIS | Verify `MisaSyncOptions.Mode`, endpoint/tenant and secret refs resolve; dry-run cannot be mistaken for production success. | Pause dispatcher, keep outbox/sync events, fix mapping/secret refs, retry/reconcile. |
| Printer/device | Verify device registry active, HMAC callback auth, label format per PACKET/BOX/CARTON and no direct DB access. | Pause print queue, mark failed jobs, reprint/void with audit. |
| Evidence storage | Verify company storage server path/bucket, encryption/access-log refs, scan worker and backup target; local FS is only `DEV_TEST_ONLY`. | Restore DB metadata and evidence files together; missing evidence blocks verification/close until restored or owner repair runbook. |
| Notification | Verify M13 emits `NOTIFICATION_REQUESTED`/`notification_job_id`; external sales/notification system owns delivery. | Operational rollback only affects outbox/job creation; delivery correction belongs external owner. |
| Backup/DR | Verify RPO/RTO monitors and pre-go-live restore drill log. | Restore drill must validate ledger, trace, recall, QR/print, MISA and evidence continuity. |
| Retention/archive | Verify retention jobs use PF-02 duration and archive search keys. | Archive restore must be permission-gated and audited. |
| Production users/roles | Verify action baseline unchanged and user-role assignment imported from owner-approved environment data. | Disable/adjust user assignment, not action permission truth, unless ADR approves permission change. |

## 9. PF-04 Deployment Readiness Runbook

### 9.1 Runtime Topology

| runtime | release requirement | health or smoke evidence |
|---|---|---|
| `apps/admin-web` | Build against frozen OpenAPI/API client contract; use `VITE_API_BASE_URL` from environment. | Admin login/menu smoke and action permission visibility. |
| `apps/public-trace` | Build public-only trace UI; call public trace API with `PublicTracePublicResponse`; no admin DTO or auth context. | Public trace happy path plus leakage/invalid QR negative smoke. |
| `apps/shopfloor-pwa` | Build PWA for shopfloor submit/scan flows; commands use idempotency keys and handle weak network. | PWA submit smoke or API-level equivalent until UI scaffold exists. |
| Operational API/backend | Expose admin, supplier, PWA and public API routes; enforce auth, permission, idempotency and audit. | `/health/live`, `/health/ready`, API smoke and security checks. |
| Background workers | Run outbox dispatch, MISA sync, printer/QR job processing, evidence scan, projection, archive/retention and alert jobs. | Worker health plus outbox/retry/scan/MISA/print smoke evidence. |
| PostgreSQL | Apply migrations, constraints, indexes, seed baseline and backup/PITR refs. | Migration list, seed validation, restore drill. |
| Evidence storage adapter | Store binaries by URI/object key; DB stores metadata only. | Upload, scan, read-back and restore evidence smoke. |
| Printer/device adapter | Use HTTP/ZPL-compatible adapter and HMAC callback; no direct DB access. | Device callback auth smoke and print failure alert smoke. |

### 9.2 Environment And Secret Checklist

| area | required refs or variables | rule |
|---|---|---|
| API | `ConnectionStrings__DefaultConnection`, `ASPNETCORE_ENVIRONMENT`, `ASPNETCORE_URLS`, auth/JWT issuer/audience/secret refs | Secrets must be injected by platform or secret manager, never committed. |
| Frontend | `VITE_API_BASE_URL` for `admin-web`; public trace and PWA API base URL variables per app framework | Public trace must point only to public API routes. |
| MISA | `MisaSyncOptions__Mode`, `BaseUrl`, `TenantId`, `ClientId`, `ClientSecretRef`, `WebhookSecretRef`, retry/backoff settings | `DryRun` is explicit and cannot mark production sync as `SYNCED`. |
| Printer/device | `PrinterOptions__Protocol=HTTP_ZPL`, `CallbackAuth=HMAC_SHA256`, `DeviceSecretRef`, device registry model/endpoint/status | Device callbacks require `DEVICE_CALLBACK`; device/edge agent has no DB credentials. |
| Evidence storage | `EvidenceStorage__Provider`, `BasePathOrBucket`, `EncryptionKeyRef`, `AccessLogSinkRef`, backup policy ref | Local filesystem is allowed only for local/dev/test with `DEV_TEST_ONLY`. |
| Backup/DR | backup target refs, encryption key refs, RPO/RTO monitor refs, restore drill log path | Backup artifacts and logs must not expose secret literals. |
| Notification outbox | external consumer binding or queue ref owned outside Operational | Operational emits `NOTIFICATION_REQUESTED` and stores `notification_job_id`; delivery SLA belongs external owner. |

### 9.3 Clean DB Release Rehearsal

| step | command/evidence placeholder | pass condition |
|---|---|---|
| 1 | Create empty target database for rehearsal. | Database exists with no application schema objects except platform baseline. |
| 2 | Apply baseline migrations in order. | Migration history matches release artifact; no failed partial migration. |
| 3 | Run sorted seed chain once. | Required seed groups load: auth/RBAC, warehouses, 20 SKU, 433 G1 lines, public policy, event schema and safe fixtures. |
| 4 | Run seed validation queries. | Counts and hard locks pass; no active forbidden formula token; dev/test fixtures are visibly marked. |
| 5 | Run sorted seed chain second time. | No duplicate business keys, no idempotency drift. |
| 6 | Run production freeze smoke subset. | Happy path and mandatory negative smoke pass or release is blocked. |

### 9.4 Migration Failure Decision Tree

| failure timing | action |
|---|---|
| Before data write | Stop deployment; rollback migration if migration tool supports safe down and DBA confirms no partial side effect. |
| During migration with unknown state | Freeze application writes; snapshot DB state; inspect migration history and logs; choose forward-fix unless safe rollback is proven. |
| After production data write | Do not destructive rollback; prepare forward-fix migration or owner-approved repair migration with audit evidence. |
| Constraint/index performance issue | Disable traffic if needed; create forward-fix index/constraint adjustment; rerun affected API and smoke tests. |
| Bad seed in production | Apply idempotent seed correction; never delete transaction, ledger, audit, QR/print or recall history to “fix” seed. |

### 9.5 Restore Drill Runbook

| area | restore validation |
|---|---|
| Database schema | Restored DB migration version matches release artifact. |
| Seed baseline | Validate 20 SKU, 433 G1 lines, four recipe groups, no active forbidden formula token and required permissions. |
| Inventory | Sample raw/FG ledger and balance projection rebuild/query correctly. |
| QR/print | QR registry, state history, print job and device registry/history are present. |
| Trace/recall | Internal trace chain and recall exposure snapshot can be queried; recall hold/sale lock state remains consistent. |
| Evidence | DB evidence metadata can resolve restored binary object/file; scan status and hash refs remain readable. |
| Public trace | Public response remains whitelist-only after restore. |
| MISA/outbox | Outbox, sync event, sync log and reconcile record continuity is intact; dispatcher can resume idempotently. |

### 9.6 Worker And Incident Operations

| worker or flow | normal operation | failure operation |
|---|---|---|
| Outbox retry | Retry by configurable backoff and preserve idempotency/correlation id. | Move to failed/dead-letter/reconcile-visible state; replay only by permissioned command. |
| MISA sync | `DryRun` records simulated result; `Production` posts with secret refs and mapping validation. | Pause dispatcher, keep events, correct mapping/secret refs, replay or reconcile. |
| Evidence scan | New evidence starts pending scan; clean evidence can be used for verification/close gates. | Infected or failed scan blocks close/verification; alert QA/Security/DevOps and allow retry/reupload by policy. |
| Printer/device | Queue jobs, update QR/print state through API/worker, accept signed callback only. | Pause queue, mark job failed, reprint or void by workflow; alert packaging/device owner. |
| Recall notification handoff | Create outbox/job and `notification_job_id` when state reaches notification request point. | Operational verifies job/outbox creation; downstream delivery incident belongs external notification owner. |

### 9.7 Monitoring And Alerts

| signal | required alert or dashboard evidence |
|---|---|
| Health | API live/ready, DB, outbox/queue, MISA adapter, printer/device registry, evidence storage and scan worker. |
| Public trace | Leakage violation, invalid QR spike, public trace latency breach. |
| MISA | Failed sync beyond retry policy, missing mapping unresolved, reconcile pending too long. |
| Printer/QR | Print failure rate, stale queued job, device callback auth failure, QR void/reprint spike. |
| Evidence | Storage unavailable, scan failed, malware detected, CAPA/source-origin evidence pending beyond policy. |
| Recall | SLA risk for impact, hold, notification handoff, CAPA overdue or recovery/disposition overdue. |
| Inventory | Ledger posting failure, negative balance risk, duplicate issue attempt/idempotency collision. |
