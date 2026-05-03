# READY_FOR_PRODUCTION_FREEZE - 2026-05-03

> PF-05 Final Freeze Review. This is the single-page decision artifact for entering greenfield scaffold/coding from the frozen `docs/software-specs/` source pack.

## 1. Freeze Verdict

| Verdict | Decision date | Scope | Decision |
|---|---|---|---|
| `READY_FOR_PRODUCTION_FREEZE` | 2026-05-03 | Source specs, owner decisions, production config boundaries, DB/API/seed/test contracts, release/ops runbooks | Approved to start scaffold/coding from zero. Production real integrations remain gated by runtime config/secret/device/storage refs and pre-go-live smoke evidence. |

## 2. Owner Decisions Frozen

| OD id | Final value | Owner | Date | Affected CODE |
|---|---|---|---|---|
| OD-11 | Trace SLA configurable; public trace and internal genealogy metrics required. | Owner / Tech Lead | 2026-05-03 | CODE07/CODE17 |
| OD-12 | DB RPO 15m/RTO 4h; evidence RPO 1h/RTO 8h; audit/outbox RPO 5m/RTO 2h. | DevOps/DBA | 2026-05-03 | CODE16/CODE17 |
| OD-13 | Retention: operational 7y, recall/CAPA/evidence 10y, outbox/request operational logs 90d active then archive. | Owner / Compliance | 2026-05-03 | CODE16/CODE17 |
| OD-14 | Public trace MVP language `vi`; schema is i18n-ready. | Owner / Product | 2026-05-03 | CODE07/CODE17 |
| OD-17 | HTTP/ZPL-compatible printer adapter, HMAC callback, physical device details by registry/config refs. | Packaging Ops + DevOps | 2026-05-03 | CODE12/CODE17 |
| OD-20 | MISA AMIS `DryRun`/`Production` mode; tenant/endpoint/credential via `MisaSyncOptions.*` and secret refs. | Finance/Integration + DevOps | 2026-05-03 | CODE13/CODE17 |
| OD-21 | PWA task taxonomy and `/api/admin/tasks/my` baseline accepted. | Owner / Ops | 2026-05-03 | CODE11 |
| OD-22 | UI mutation route family baseline accepted: REST resources plus action sub-resource. | Owner / Tech Lead | 2026-05-03 | CODE09/CODE10/CODE11 |
| CONFLICT-18 | Formula coexistence is canonical: G1 `PILOT_PERCENT_BASED` and G2 `FIXED_QUANTITY_BATCH`, active per `(sku_id, formula_kind)`. | Owner / Product | 2026-05-03 | CODE03/CODE04/CODE07 |
| OD-G2-001 | G2 fixed batch variance policy accepted; tolerance/config/audit controls required. | Owner / QA/Ops | 2026-05-03 | CODE03/CODE07 |
| OD-FORMULA-PICK-001 | Planner chooses formula by config/explicit selection; audited override required. | Owner / Ops | 2026-05-03 | CODE03/CODE07 |
| OD-M03-OWNERSHIP-001 | M03A owns supplier CRUD, allowlist, user link and `R-SUPPLIER`; M03 keeps reference grouping. | Owner / Master Data | 2026-05-03 | CODE01A/CODE02 |
| OD-EVIDENCE-STORAGE-001 | Production evidence on company server via adapter/config; dev/test local filesystem allowed. | Owner + DevOps/Security | 2026-05-03 | CODE05/CODE13/CODE17 |
| OD-NOTIFY-OWNERSHIP-001 | Operational creates notification job/outbox only; sales/external notification system owns delivery. | Recall Owner + Sales/Notification Owner | 2026-05-03 | CODE13/CODE17 |
| OD-EVIDENCE-SCAN-001 | Evidence scanner is pluggable worker; clean scan required for verification/close gates. | QA/Security/DevOps | 2026-05-03 | CODE05/CODE06/CODE13 |
| OD-INVENTORY-ALLOC-001 | FEFO allocation default with deterministic tie-breakers and audited override. | Warehouse/Ops | 2026-05-03 | CODE08/CODE11 |
| OD-WAREHOUSE-3RD-001 | Keep two warehouse types; use zone/location/status for quarantine, return and hold. | Warehouse/Ops | 2026-05-03 | CODE11/CODE13 |
| OD-SUP-AUTH-001 | Supplier auth/session policy accepted; MFA remains configurable production hardening. | Owner / Security | 2026-05-03 | CODE01A |
| OD-SUP-EVIDENCE-RETRY-001 | Supplier evidence retry/replacement is append-only; failed/infected metadata remains auditable. | Owner / QA | 2026-05-03 | CODE02/CODE06 |
| OD-SUP-FEEDBACK-ENUM-001 | Final feedback enum accepted. | Owner / Ops | 2026-05-03 | CODE02/CODE06 |
| OD-SUP-CONFIRM-TIMEOUT-001 | Supplier confirmation timeout/escalation policy accepted. | Owner / Procurement | 2026-05-03 | CODE02/CODE06 |
| OD-PACKET-TRACE-001 | PACKET has no QR; PACKET inherits BOX/CARTON trace. | Owner / Packaging | 2026-05-03 | CODE10/CODE12/CODE17 |
| OD-PACKAGING-DEFAULT-001 | Packaging defaults accepted with SKU-level override. | Owner / Packaging | 2026-05-03 | CODE10/CODE12 |
| OD-CAPA-MODEL-001 | CAPA table/status/close gate accepted. | Recall Owner / QA | 2026-05-03 | CODE13 |
| OD-MISA-DOC-OWNER-001 | M14 owns MISA document lifecycle from operational events; business modules do not call MISA directly. | Finance/Integration | 2026-05-03 | CODE08/CODE13 |
| OD-ADJUSTMENT-APPROVAL-001 | Inventory adjustment approval tiers accepted. | Warehouse/Ops | 2026-05-03 | CODE11 |
| OD-WH-CORRECT-IDEMPO-001 | Warehouse receipt correction is append-only; idempotency prevents duplicate command replay only. | Warehouse/Ops | 2026-05-03 | CODE11 |
| OD-RATE-LIMIT-SCOPE-001 | Rate limit scopes accepted for public trace, auth, supplier portal, callbacks, admin/PWA commands. | Security/Tech Lead | 2026-05-03 | CODE02/CODE07/CODE13/CODE17 |
| OD-PRINTER-PROTO-001 | HMAC callback baseline accepted; extra hardening follows actual printer/infrastructure ADR. | Packaging Ops + DevOps | 2026-05-03 | CODE12/CODE17 |

## 3. Production Config Freeze

| Area | Frozen production value | Owner | Go-live gate |
|---|---|---|---|
| GTIN/GS1 | Dev/test fixture allowed only with `DEV_TEST_ONLY` and `is_test_fixture=true`; production GTIN rows/import use `is_test_fixture=false`. | Packaging/Ops + Data Steward | Block production print if fixture GTIN is selected. |
| MISA | `DryRun` for dev/test; production uses `MisaSyncOptions__Mode=Production`, endpoint/tenant/client refs and secret refs. | Finance/Integration + DevOps | Validate refs and mapping before production sync; dry-run result cannot count as production success. |
| Printer/device | HTTP/ZPL adapter and HMAC callback; model/IP/serial/secret by device registry/config refs. | Packaging Ops + DevOps | Factory device smoke must pass; no direct DB access from device/edge adapter. |
| Storage | Evidence binary storage via adapter; dev/test local filesystem, production company storage server/object-compatible mount with encryption, access log and backup refs. | DevOps + Security | Evidence upload/read/scan/restore smoke must pass. |
| Notification | Operational emits `NOTIFICATION_REQUESTED`, outbox/job and `notification_job_id`; external system owns channel delivery. | Recall Owner + Sales/Notification Owner | Operational SLA measured to handoff point only. |
| Backup/DR | DB RPO 15m/RTO 4h; evidence RPO 1h/RTO 8h; audit/outbox RPO 5m/RTO 2h. | DevOps/DBA | Pre-go-live restore drill validates DB, evidence, ledger, trace, recall, QR/print and MISA continuity. |
| Retention | 7y operational/ledger/audit/trace; 10y recall/CAPA/evidence; 5y MISA sync/reconcile; 90d active outbox/request logs then archive. | Compliance + DevOps/DBA | Archive search by approved trace keys remains permission-gated and audited. |

## 4. Contract Checksum

| Contract | Frozen count | Source | Status |
|---|---:|---|---|
| DB physical tables | 102 | `docs/software-specs/database/03_TABLE_SPECIFICATION.md` | PASS |
| DB views/projections | 5 | `docs/software-specs/database/03_TABLE_SPECIFICATION.md` | PASS |
| DB schema objects total | 107 | `docs/software-specs/database/03_TABLE_SPECIFICATION.md` | PASS |
| Seed CSV groups | 17 | `docs/software-specs/data/seed_manifest.json` | PASS |
| Seed CSV rows total | 768 | `docs/software-specs/data/seed_manifest.json` | PASS |
| G1 recipe lines | 433 | `docs/software-specs/data/csv/g1_recipe_lines.csv` | PASS |
| Public trace policy rows | 17 | `docs/software-specs/data/csv/public_trace_policy.csv` | PASS |
| Role-permission rows | 101 | `docs/software-specs/data/csv/roles_permissions.csv` | PASS |
| Unique action codes | 81 | `docs/software-specs/data/csv/roles_permissions.csv` | PASS |
| Unique test IDs across testing docs | 261 | `docs/software-specs/testing/*.md` | PASS |
| Canonical test matrix IDs | 114 | `docs/software-specs/testing/02_TEST_CASE_MATRIX.md` | PASS |
| API test plan IDs | 31 | `docs/software-specs/testing/03_API_TEST_PLAN.md` | PASS |
| E2E/PF smoke IDs | 43 | `docs/software-specs/testing/06_E2E_SMOKE_TEST_PLAN.md` | PASS |
| HL-SUP hard-lock test IDs | 17 | `docs/software-specs/testing/02_TEST_CASE_MATRIX.md` | PASS |

## 5. Remaining Accepted Risks

| Risk | Status | Production control |
|---|---|---|
| Observability tooling/channel vendor not selected | `DEFERRED_WITH_ACCEPTED_RISK` | Health endpoints, metrics, alerts and runbook are frozen; concrete sink/channel binds by config/runbook before go-live. |
| Real MISA/printer/storage values are not in repo | `CONFIG_REF_REQUIRED` | Use secret/device/storage refs owned by Finance/Integration, Packaging Ops, DevOps and Security; no literal secret committed. |
| Ingredient code stewardship review remains data-governance work | `DATA_STEWARDSHIP_REVIEW_REQUIRED` | Does not block schema/API scaffold; production master data cutover requires data steward review. |
| Runtime implementation not scaffolded yet | `NOT_SCAFFOLDED` | PF-00..PF-05 freeze source truth only; build/test/migration/seed/smoke evidence becomes mandatory once layers exist. |

## 6. Hard No-Go List

Any item below blocks release until fixed.

| No-go | Enforcement source | Required result |
|---|---|---|
| No G0 operational formula, seed, PO, issue, trace or recall usage. | DB checks, seed validation, API tests | 0 active/approved operational `G0`. |
| No public private leakage. | `PublicTracePublicResponse`, public trace policy, leakage tests | Public trace exposes whitelist-only fields and `additionalProperties=false`. |
| No direct MISA call from business modules. | M14 integration boundary, outbox architecture | M08/M11/M13 emit events only; M14 owns MISA adapter/sync/reconcile. |
| No `QC_PASS = RELEASED`. | QC/release state machine and smoke negative tests | Batch release is a distinct action/record after QC pass. |
| No material issue from non-ready lot. | Raw lot readiness hard lock and smoke negative tests | Issue requires raw lot `READY_FOR_PRODUCTION`; `QC_PASS` alone is rejected. |
| No production print with fixture GTIN. | GTIN fixture flags and production print gate | `DEV_TEST_ONLY` or `is_test_fixture=true` identifiers are blocked in production print/sync paths. |

## 7. Final Handoff

- Start scaffold from `docs/software-specs/` using PF-05 as the final freeze index.
- Use PF-03 for DB/API/seed/test contract freeze and PF-04 for release/ops runbook requirements.
- Do not introduce new production behavior outside frozen contracts without adding an ADR/OD update.
- Before go-live, convert config refs into environment-specific values and run the PF-04 production freeze smoke suite.
