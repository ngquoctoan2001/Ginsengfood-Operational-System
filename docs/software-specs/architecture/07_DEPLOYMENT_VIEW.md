# Deployment View

> Mục đích: deployment target view cho DevOps/Backend/DBA. Đây là architecture-level spec, chưa phải runbook triển khai thật.

## 1. Logical Deployment

```mermaid
flowchart LR
  User[Internal Users] --> AdminWeb[Admin Web]
  Operator[Shopfloor Operators] --> PWA[Shopfloor PWA]
  Consumer[Consumers] --> PublicTrace[Public Trace Page]

  AdminWeb --> Api[Operational API]
  PWA --> Api
  PublicTrace --> PublicApi[Public Trace API]

  Api --> Pg[(PostgreSQL)]
  PublicApi --> Pg
  Api --> Worker[Background Worker]
  Worker --> Pg
  Worker --> MISA[MISA AMIS]
  Worker --> PrinterAgent[Printer/Device Adapter]
  PrinterAgent --> Worker
  Api --> Health[Health Endpoint]
  Worker --> Health

  Api --> EvidenceStore[Evidence Storage Adapter]
  EvidenceStore --> EvidenceFiles[(Local Dev/Test Files or Company Storage Server)]
  Api --> Log[Central Logs/Metrics]
  Worker --> Log
  PrinterAgent --> Log
  Pg --> Backup[Backup/Restore Storage]
```

## 2. Runtime Components

| Runtime component | Responsibility | Scaling note |
| --- | --- | --- |
| Admin Web | Internal UI workflows | Stateless frontend. |
| Shopfloor PWA | Operator workflow, scan/offline submit | Must handle weak network via idempotency. |
| Public Trace Page/API | Public QR trace | Separate route/DTO/public projection. |
| Operational API | Admin/PWA/public API boundary | Stateless; DB transaction boundary. |
| Background Worker | Outbox dispatch, MISA sync, alerts, projections, printer/device callback consumption | Horizontal worker uses `SELECT FOR UPDATE SKIP LOCKED` or an approved equivalent locking decision before parallel dispatch. |
| PostgreSQL | Source of truth operational DB | Needs indexes, FK/check constraints, backup/restore. |
| Printer/Device Adapter | Local/edge integration to printer/scanner and callback forwarding | Must not direct DB access; all callbacks go through API/worker boundary. |
| Evidence Storage Adapter | Store source-origin and CAPA evidence binaries by reference; DB stores metadata only | Dev/test uses local filesystem storage. Production uses company storage server configured by DevOps without changing domain/API contracts. |
| Health Endpoint | Runtime health for app, DB, outbox/queue, MISA adapter, printer/device registry | Must be visible to monitoring/dashboard. |
| Observability | Logs, metrics, alerts | Tooling owner decision remains open. |

## 3. Environment Requirements

| environment | Purpose | Data policy |
| --- | --- | --- |
| `local` | Developer docs/migration/unit validation | Fake GTIN/MISA credentials allowed, clearly marked; evidence binary storage uses local filesystem path. |
| `dev` | Integration development | Seed baseline + fixtures; no production secrets; evidence binary storage can use local/dev server path. |
| `staging` | Smoke and release rehearsal | Production-like schema; masked/safe data; evidence storage points to staging company/server path. |
| `production` | Factory operation | Real secrets, backup, monitoring, owner-approved retention; evidence storage points to company production storage server configured by DevOps. |

## 4. Deployment Gates

| gate | Requirement |
| --- | --- |
| Migration gate | Migration applies cleanly from baseline and rollback/restore plan exists. |
| Seed gate | Seed chain idempotent; G1 baseline seeded; G0 not active; GTIN fixtures carry `is_test_fixture=true` and are blocked from production printer. |
| API gate | OpenAPI/API contract updated and smoke-tested. |
| Worker gate | Outbox retry/reconcile and dead-letter visible. |
| Public trace gate | Leakage tests pass. |
| Backup gate | RPO/RTO/restore drill owner decision before final release. |
| Printer gate | Driver/model/protocol owner decision before factory device smoke. |
| Health gate | App/DB/outbox/MISA/printer-device health endpoint available before staging smoke. |


