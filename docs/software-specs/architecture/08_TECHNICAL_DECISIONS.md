# Technical Decisions

> Mục đích: khóa các decision kỹ thuật ảnh hưởng DB/API/migration để nhóm triển khai không tự suy đoán.

## 1. Decision Record

| decision_id | Decision | Rationale | Impact | Status |
| --- | --- | --- | --- | --- |
| ADR-001 | Use 16 module boundaries M01-M16 from top-level module map. | Boundary follows data ownership and authorization domains; M06/M09 are separate because lot intake/readiness and QC disposition are distinct controls. | DB/API/UI/test grouped by module. | Accepted |
| ADR-002 | Use text enum + check constraints instead of native DB enum. | Dễ migration/versioning khi trạng thái thay đổi. | `database/04_ENUM_REFERENCE.md`, check constraints. | Accepted |
| ADR-003 | Use append-only ledger/audit/state history. | Traceability and compliance. | Reversal/correction instead of update/delete. | Accepted |
| ADR-004 | Use immutable snapshots for PO, print, recall impact. | Future recipe/version changes cannot rewrite history. | Snapshot columns/tables required. | Accepted |
| ADR-005 | Inventory balance is projection from ledger. | Avoid hidden mutable inventory truth. | `op_inventory_ledger` source, `op_inventory_lot_balance` projection. | Accepted |
| ADR-006 | MISA sync via outbox/integration layer only. | Mapping/retry/reconcile/audit required; MISA-relevant events include `MATERIAL_ISSUED`, `WAREHOUSE_RECEIPT_CONFIRMED` and any owner-approved accounting/release handoff. | `misa_*` tables and worker. | Accepted |
| ADR-007 | Public trace uses separate view/projection. | Prevent data leakage. | `vw_public_traceability`/policy table. | Accepted |
| ADR-008 | Use idempotency registry for high-risk commands. | Prevent duplicate issue/receipt/print/offline submit. | Unique idempotency key per actor/scope. | Accepted |
| ADR-009 | Keep SKU transitional master in Operational for G1 go-live. | Catalog domain not in scope; PO needs SKU snapshot. Transitional until Catalog domain is in scope; Operational retains immutable snapshots/references after migration. | `ref_sku` exists but ownership is transitional. | Accepted with boundary note |
| ADR-010 | Use fake GTIN fixture only with explicit `is_test_fixture`. | Real GTIN not supplied to dev yet. | Service/DB rejects production print job where trade item mapping is `is_test_fixture=true`; no SKU-code fallback for commercial barcode. | Accepted |
| ADR-011 | `READY_FOR_PRODUCTION` is a distinct raw-lot readiness state, not an alias of `QC_PASS`. | QC decision and production readiness are separate gates; material issue on QC-pass-only lot must fail with `RAW_MATERIAL_LOT_NOT_READY`. | Separate readiness transition command, audit/state row and `RAW_LOT_READY_FOR_PRODUCTION` event. | Accepted |
| ADR-012 | Evidence binary storage uses a storage adapter: dev/test local filesystem, production company storage server; DB stores metadata only and clean scan is required for verify/close gates. | Keeps code ready for production server config without binding specs to S3/MinIO/Azure; prevents DB blob storage and unsafe evidence acceptance. | `op_source_origin_evidence`, `op_recall_capa_evidence`, evidence API, storage config, scan-status validation. | Accepted |

## 2. Open Technical Decisions

| decision_id | Needed decision | Affected docs/modules | Current default |
| --- | --- | --- | --- |
| OTD-001 | Trace query SLA/volume | M12, DB indexes, dashboard | Design index-ready; no hard SLO. |
| OTD-002 | Backup RPO/RTO | Deployment, retention, migration | Mark release blocker. |
| OTD-003 | Retention duration per data class | Audit/ledger/trace/recall/MISA | Configurable policy, no hard-coded duration. |
| OTD-004 | Public trace i18n | Public trace DB/API/UI | Single-language safe default; i18n-ready if needed. |
| OTD-005 | Printer model/driver/protocol | M10, deployment, tests | Adapter abstraction only. |
| OTD-006 | Observability tooling | M15, deployment | Generic logs/metrics/alerts contract. |
| OTD-007 | MISA retry/backoff exact policy | M14, outbox worker, integration tests | Do not hard-code unapproved retry count. |
| OTD-008 | Break-glass session auto-expiry final policy | M01, M02, M15 | Security default <= 15 minutes pending owner confirmation. |
| OTD-009 | Lot readiness workflow owner/action policy | M06, M08, M09 | Default: explicit `RAW_LOT_MARK_READY` by authorized QA/release or ops manager role. |
| OTD-010 | Production evidence storage endpoint/credentials and malware scan engine | M05, M13, deployment, security | Dev/test local filesystem + `dev-skip`/mock scan only; production requires company storage server config and real scanner before go-live. |

## 3. Migration-Relevant Decisions

| decision | DB consequence |
| --- | --- |
| Only operational baseline | Check/seed validation; no active recipe with a research/baseline token. |
| G1 supports future G2/G3 | Recipe version table with status/effective dates and active uniqueness. |
| 4 recipe groups | Seed `ref_recipe_line_group`; FK/check on recipe lines/snapshot. |
| `QC_PASS != READY_FOR_PRODUCTION` | Separate raw lot readiness state, transition command and `RAW_MATERIAL_LOT_NOT_READY` enforcement at service/DB boundary. |
| Material issue decrement point | Ledger row type for material issue debit; receipt confirmation no decrement. |
| QC pass != release | Separate QC inspection and batch release tables/states. |
| Warehouse requires release | FK/check/service validation against release record. |
| Recall snapshot | Dedicated snapshot table or JSON snapshot with version. |
| Evidence metadata | Dedicated source-origin and CAPA evidence metadata tables; binary file refs only; scan status check enum and clean scan gates. |
| Public trace whitelist | Dedicated projection/view and policy table. |


