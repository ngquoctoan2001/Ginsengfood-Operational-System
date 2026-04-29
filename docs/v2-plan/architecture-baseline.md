# Operational V2 Architecture Baseline

> Status: Architecture baseline ready for Owner/Tech Lead review.
> Mode: PLAN_ONLY. This document does not authorize implementation by itself.

## 1. Source Basis

This baseline is derived from:

| Source | Purpose used |
| --- | --- |
| `docs/software-specs/architecture/` | Target architecture, module boundary, event/integration/deployment views, accepted technical decisions |
| `docs/software-specs/06_MODULE_MAP.md` | M01-M16 module scope, route families, P0/P1/P2 phase mapping |
| `docs/software-specs/api/` | API route policy, envelope, errors, auth/permission, idempotency, pagination/filter/sort, OpenAPI guide |
| `docs/software-specs/database/` | Operational DB ownership, schema groups, enum policy, constraints/indexes, seeds, migration strategy |
| `docs/software-specs/non-functional/` | Security, audit, performance, observability, backup/retention, scalability/availability requirements |

## 2. Architecture Baseline

Operational V2 is a greenfield operational domain system for source origin, raw material lot intake, incoming QC, production, material issue/receipt, packaging/printing/QR, QC/release, warehouse inventory, traceability, recall and MISA integration.

The Operational Domain owns batch, lot, genealogy, traceability, recall data, operational inventory ledger and inventory lot balance. It must not own customer, order, CRM, payment, membership, commission, campaign, pricing or AI decision data. External domains are referenced by keys only.

The system must preserve immutable operational history. Production order, recipe, print and recall flows use snapshots so later master/recipe changes do not rewrite historical evidence. Inventory truth comes from append-only ledger records, with balance tables treated as projections.

G1 is the initial operational recipe baseline for factory go-live. G0 is historical/research context only and must not be seeded or used as an active operational formula.

MISA synchronization, device/printer work and public trace are boundary integrations. They must go through the integration/public-safe layers and must not bypass domain state, audit, ledger, QC/release or permission controls.

## 3. Runtime Containers

| Container | Responsibility |
| --- | --- |
| Admin Web | Back-office UI for master data, source/raw material, production, QC, release, warehouse, trace, recall, integration and reporting workflows |
| Shopfloor PWA | Internal task UI for operators and shopfloor execution; uses permissioned task/detail/action APIs |
| Public Trace UI/API | Public QR trace surface backed by a public-safe projection only |
| Operational API | Authenticated API boundary for admin/mobile commands and queries |
| Background Worker | Outbox dispatch, MISA retry/reconcile, QR/print async work, scheduled validation/maintenance jobs |
| PostgreSQL Operational DB | Operational transaction store, append-only audit/state/ledger/history, snapshots, outbox, projections and seeds |
| Evidence Storage Adapter | Source-origin and CAPA evidence binary storage by reference; local filesystem in dev/test, company storage server in production |
| Printer/Device Adapter | Isolated adapter for printer/scanner protocol, callbacks and retry/error states |
| Observability/Health | Health endpoints, logs, metrics, alerts and validation evidence |
| External Systems | MISA AMIS, printer/scanner hardware, commerce/order/shipment reference systems, notification/CRM references |

## 4. Logical Layers

| Layer | Baseline responsibility |
| --- | --- |
| UI | Admin, PWA and public trace screens. UI hiding is not a security boundary. |
| API Boundary | Route taxonomy, request validation, authn/authz, idempotency header enforcement, response/error envelope, pagination/filter/sort. |
| Application Services | Use-case orchestration, transaction boundary, state transition coordination, event/outbox creation. |
| Domain Services | Business invariants for G1 recipe, lot readiness, material issue/receipt, QC/release, warehouse ledger, trace/recall and public exposure rules. |
| Persistence | EF/PostgreSQL schema, migrations, constraints, indexes, append-only guards, projections and seeds. |
| Storage | Evidence binary adapter; DB owns metadata and scan status, not blobs. |
| Event/Outbox Worker | Reliable async processing after DB commit; retries, reconcile, callback state and failure logging. |
| Integration Layer | MISA mapping/sync/reconcile, printer/device adapter and external reference integration. |
| Validation/Ops | Build/test gates, seed validation, smoke, monitoring, backup/restore and release evidence. |

## 5. Module Layer Map

| Module | Primary layers | Architecture note |
| --- | --- | --- |
| M01 Foundation Core | API, Application, Persistence, Event/Ops | Audit, idempotency, event/outbox, state transition framework and shared conventions. |
| M02 Auth Permission | UI, API, Application, Persistence | Role/permission enforcement at API/service layer; UI visibility is secondary. |
| M03 Master Data | UI, API, Application, Persistence | Shared reference data, UOM and baseline operational masters. |
| M04 SKU Ingredient Recipe | UI, API, Application, Domain, Persistence, Seed | G1 SKU/ingredient/recipe baseline, recipe versioning and snapshots. |
| M05 Source Origin | UI, API, Application, Domain, Persistence, Storage | Supplier/source declarations and source-origin evidence metadata/scan gate. |
| M06 Raw Material | UI/PWA, API, Application, Domain, Persistence | Raw lot intake, incoming QC outcome, readiness gate and lot status history. |
| M07 Production | UI/PWA, API, Application, Domain, Persistence, Event | Production order/batch, G1 snapshot and batch lifecycle. |
| M08 Material Issue Receipt | UI/PWA, API, Application, Domain, Persistence, Event | Real raw material inventory decrement/inbound variance confirmation. |
| M09 QC Release | UI/PWA, API, Application, Domain, Persistence, Event | QC_PASS is not RELEASED; release is a distinct action/record. |
| M10 Packaging Printing | UI/PWA, API, Application, Domain, Persistence, Event, Integration | QR registry/print queue lifecycle and printer adapter boundary. |
| M11 Warehouse Inventory | UI/PWA, API, Application, Domain, Persistence, Event | Finished-goods receipt requires RELEASED batch; ledger append-only, balance projection. |
| M12 Traceability | UI/Public, API, Application, Domain, Persistence, Projection | Internal genealogy plus public-safe trace projection with denylist/whitelist policy. |
| M13 Recall | UI, API, Application, Domain, Persistence, Storage, Event | Recall impact snapshot, recovery/CAPA, CAPA evidence metadata/scan gate, exposure state and audit evidence. |
| M14 MISA Integration | API/Ops, Application, Persistence, Worker, Integration | Common integration layer only; mapping, retry, reconcile and logs. |
| M15 Reporting Dashboard | UI, API, Application, Persistence, Ops | Dashboard projections, health/metrics/alerts and operational reporting. |
| M16 Admin UI | UI, API client, Auth/Permission | Admin shell, screen/action registry, PWA task inbox and frontend contract alignment. |

## 6. Cross-Cutting Decisions

| Decision area | Baseline |
| --- | --- |
| Auth/authz | Protected APIs use bearer/session authentication and permission checks. UI hiding cannot replace API/service authorization. |
| Audit/history | State transition, audit, ledger, QR/print and recall history are append-only. Corrections use reversal/correction records. |
| Idempotency | High-risk commands require `X-Idempotency-Key` and a registry scoped by actor/operation. Duplicate safe replay must return the original outcome. |
| Events/outbox | Business transaction commits first; event/outbox processing happens asynchronously with retry/reconcile evidence. |
| API envelope | Success response uses `data` and `meta.correlationId`; errors use `error.code`, `message`, `details`, `correlationId`. |
| API route taxonomy | Use canonical API catalog routes as the implementation baseline until conflicts are closed. Avoid parallel route families. |
| Pagination/filter/sort | List/search endpoints use explicit pagination/filter/sort contracts, never unbounded operational scans. |
| OpenAPI/frontend client | OpenAPI is generated from canonical API specs and enum references; frontend client/types follow the frozen API contract. |
| DB migration | PostgreSQL, UUID PKs, business-key uniqueness, text enums plus check constraints, idempotent migration/seed validation gates. |
| Seed | G1 baseline only; 20 canonical SKU, required ingredients and four G1 groups. Dev/test fixtures must be marked as fixtures. |
| Public trace | Public trace uses a separate projection/view and must not expose supplier/personnel/cost/QC-defect/loss/internal notes. |
| MISA | MISA sync goes through common integration tables/workers with mapping, retry and reconcile. Modules do not sync directly. |
| Printer/device | Printer/scanner callbacks can update adapter/print states only; they cannot create inventory, QC pass or release truth. |
| Evidence storage | Dev/test stores evidence binaries on local filesystem. Production stores evidence binaries on the company's storage server via configuration. Verify/close gates accept only clean scanned evidence metadata. |
| Observability | Health, logs, metrics and alerts must cover P0 flows; tooling/retention/escalation still need approval. |
| Backup/retention | Backup/restore and data retention must be approved before production readiness and CODE16/CODE17 closure. |

## 7. Known Conflicts

| Conflict ID | Source A | Source B | Impact | Baseline handling |
| --- | --- | --- | --- | --- |
| ARCH-CONFLICT-001 | `06_MODULE_MAP.md` maps M04 to `/api/admin/master-data/skus/*`, `/api/admin/master-data/ingredients/*`, `/api/admin/master-data/recipes/*`. | `api/02_API_ENDPOINT_CATALOG.md` and `api/05_API_AUTH_PERMISSION_SPEC.md` use `/api/admin/skus`, `/api/admin/ingredients`, `/api/admin/recipes`; the catalog says duplicate `/master-data/skus/*` requires adapter/deprecation. | API/OpenAPI/frontend client drift if both families are implemented as primary routes. | Prefer the more specific API catalog for API contract baseline, but require Owner/Tech Lead confirmation before CODE10/OpenAPI freeze. |

## 8. Risks And Open Decisions

| ID | Risk/open decision | Blocks | Owner |
| --- | --- | --- | --- |
| ADR-013 | Auth/session token implementation strategy and session lifecycle. | CODE09/CODE10/CODE11 contract and security design | Owner + Tech Lead |
| ADR-014 | Outbox worker locking, retry/backoff, dead-letter and reconcile policy. | CODE13 and production reliability | Tech Lead + Integration Lead |
| ADR-016 | Observability tooling, log/metric retention and escalation channels. | CODE14 and production operations | Owner + DevOps |
| ADR-017 | Backup schedule, RPO/RTO, restore drill and retention/archive duration. | CODE16/CODE17 production readiness | Owner + DevOps |
| ADR-018 | Printer/device model, protocol, callback/ack/failure semantics and test device. | CODE12 hardware smoke | Owner + Tech Lead |
| ADR-019 | Public trace rate limits, cache policy, language policy and public response SLA. | CODE07 public trace freeze | Owner + Tech Lead |
| ADR-020 | M04 route family conflict closure. | CODE10/OpenAPI/frontend client freeze | Tech Lead + Owner |
