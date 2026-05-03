# Production Freeze Readiness - 2026-05-03

> PF-03 Contract Freeze artifact. Mục tiêu: khóa DB/API/enum/permission/seed/test contracts để phase scaffold/coding không tự suy đoán hoặc drift khỏi `docs/software-specs/`.

## 1. Kết Luận

| Gate | Status | Ghi chú |
| --- | --- | --- |
| PF-03 Contract Freeze | READY_FOR_PRODUCTION_FREEZE | Contract docs đủ để bắt đầu scaffold/coding theo source pack hiện tại. |
| Production values/secrets | CONFIG_REF_REQUIRED | Secret/tenant/device/storage thật không nằm trong repo; production bind qua config/secret/device/storage refs theo PF-02. |
| Residual accepted risk | DEFERRED_WITH_ACCEPTED_RISK | Observability tooling/channel cụ thể bind sau bằng config/runbook; không block schema/API scaffold. |

## 2. Contract Checklist

| Area | Result | Evidence |
| --- | --- | --- |
| Database manifest | PASS | `database/03_TABLE_SPECIFICATION.md` là manifest authoritative: 102 physical tables, 5 view/projection objects, total 107 schema objects. `database/01_DATABASE_OVERVIEW.md` và `database/02_ERD.md` không còn dùng ERD làm nguồn đếm authoritative. |
| Database hard locks | PASS | `database/05_INDEX_CONSTRAINT_REFERENCE.md` có `UQ-RECIPE-ACTIVE-KIND` unique active recipe theo `(sku_id, formula_kind)` khi `formula_status='ACTIVE_OPERATIONAL'`; G1 PILOT và G2 FIXED có thể coexist. |
| CAPA schema | PASS | `op_recall_capa` đã freeze `capa_code`, `owner_user_id`, `due_date`, `capa_status`, `close_gate`, `evidence_count`; enum `capa_status` và `capa_close_gate` đã vào `database/04_ENUM_REFERENCE.md`. |
| API catalog | PASS | `api/02_API_ENDPOINT_CATALOG.md` có route command/read critical cho QR generate, QR void, print reprint, printer/device callback, public trace, MISA, recall, raw lot readiness. |
| API critical DTO | PASS | `api/03_API_REQUEST_RESPONSE_SPEC.md` có `PublicTracePublicResponse`, `QrGenerateRequest`, `QrGenerateResponse`, `QrVoidRequest`, `QrResponse`, `ReprintRequest`, `PrintJobRequest`, `PrintJobCallbackRequest`, `PrintJobResponse`, `LotReadinessTransitionRequest`, `EvidenceCreateRequest`. |
| Public trace contract | PASS | `PublicTracePublicResponse` whitelist-only, `additionalProperties = false`, không reuse admin/internal DTO; tests bắt public leakage. |
| QR permissions | PASS | `QR_GENERATE`, `QR_REPRINT`, `QR_VOID`, `DEVICE_CALLBACK` tách riêng trong API/permission seed; callback HMAC không được đổi QC/release/inventory/batch facts. |
| Enum/state alignment | PASS | `recall_status` dùng `NOTIFICATION_REQUESTED` theo PF-02 outbox boundary; `feedback_type` dùng final enum Batch 2; QR lifecycle đủ 6 state. |
| Permission seed | PASS | `roles_permissions.csv` có 101 rows, không duplicate `(role_code, action_code)`, phủ critical actions `RAW_LOT_MARK_READY`, `BATCH_RELEASE_REVOKE`, `QR_GENERATE`, `QR_REPRINT`, `QR_VOID`, `DEVICE_CALLBACK`, `supplier.read`, `supplier.write`. |
| Seed contract | PASS | `seed_manifest.json` parse được; CSV counts khớp manifest; fixture/production flag đã rõ theo PF-02. |
| Test coverage | PASS | `testing/02_TEST_CASE_MATRIX.md` có mandatory 1-1 `TC-HL-SUP-001..017` cho `HL-SUP-001..017`; public leakage tests có ở API/regression/HL-SUP coverage; seed idempotency chạy seed lần hai (`TC-SEED-013`, DG-006). |

## 3. Static Validation Results

| Validation | Command scope | Result |
| --- | --- | --- |
| CSV count | `docs/software-specs/data/csv/*.csv` vs `seed_manifest.json` | PASS: 17 files matched manifest counts. |
| Duplicate role permission | `roles_permissions.csv` grouped by `(role_code, action_code)` | PASS: no duplicate pairs; 101 rows. |
| Manifest JSON parse | `docs/software-specs/data/seed_manifest.json` | PASS. |
| DB manifest count | `database/03_TABLE_SPECIFICATION.md` | PASS: physical=102, views=5, total=107. |
| Markdown table pipe-count | `docs/software-specs/` + `docs/v2-decisions/` + `docs/v2-audit/` | PASS: 179 files. |
| Critical DTO presence | `api/03_API_REQUEST_RESPONSE_SPEC.md` | PASS. |
| HL-SUP 1-1 coverage | `testing/02_TEST_CASE_MATRIX.md` | PASS: `TC-HL-SUP-001..017` present. |
| Stale contract terms | API/database/workflows/modules/testing/data/v2-decisions contract scope | PASS: no match for old notification state, old supplier feedback enum, old public trace DTO, old one-active-per-SKU wording, stale dev-ready status, owner-pending contract status, or old fixture labels. |

## 4. Contract Changes Made In PF-03

| File/group | Change |
| --- | --- |
| `database/04_ENUM_REFERENCE.md` | Replaced old supplier feedback enum with final Batch 2 enum; changed recall notification state to `NOTIFICATION_REQUESTED`; added `capa_status` and `capa_close_gate`. |
| `database/03_TABLE_SPECIFICATION.md` | Froze `op_recall_capa` columns for owner, due date, close gate, evidence count, and unique `capa_code`. |
| `workflows/04_STATE_MACHINES.md`, `business/03_OPERATIONAL_RULES.md` | Aligned recall lifecycle to the PF-02 outbox notification request state. |
| `api/03_API_REQUEST_RESPONSE_SPEC.md` | Added QR generate/void response DTOs, printer callback DTO/response, and HMAC callback boundary; aligned `FeedbackCreateRequest.feedbackType`. |
| `api/05_API_AUTH_PERMISSION_SPEC.md`, `business/04_ROLE_AND_PERMISSION_MODEL.md`, `roles_permissions.csv` | Added/froze `QR_GENERATE`, `QR_VOID`, `DEVICE_CALLBACK` permission contract; `DEVICE_CALLBACK` seeded under `R-DEVOPS` operational owner with device HMAC auth note. |
| `data/seed_manifest.json`, `data/01_SEED_DATA_CANONICAL.md`, `data/04_SEED_VALIDATION_QUERIES.md` | Reconciled `roles_permissions.csv` count to 101 and added `QR_GENERATE`/`DEVICE_CALLBACK` to critical permission validation. |
| `08_REQUIREMENTS_TRACEABILITY_MATRIX.md`, `testing/02_TEST_CASE_MATRIX.md`, `testing/01_TEST_STRATEGY.md`, `workflows/06_APPROVAL_WORKFLOWS.md`, `workflows/07_EXCEPTION_FLOWS.md`, `workflows/08_SMOKE_WORKFLOW.md` | Removed stale owner-pending statuses from frozen contract areas; converted resolved/deferred items to PF-01/PF-02/PF-03 statuses or accepted risk. |
| `modules/03A_SUPPLIER_MANAGEMENT.md` | Added PF-03 note for supplier hard-lock coverage, permission seed and public leakage boundary. |

## 5. Remaining Production-Freezing Notes

| Item | Status | Impact |
| --- | --- | --- |
| Observability tooling/channel | DEFERRED_WITH_ACCEPTED_RISK | Dashboard/alert schema can scaffold now; concrete sink/escalation channel binds later via config/runbook. |
| Ingredient code stewardship | DATA_STEWARDSHIP_REVIEW_REQUIRED | Does not block schema/API scaffold; review before production master-data cutover. |
| Real MISA/printer/storage values | CONFIG_REF_REQUIRED | Do not commit secrets/IP/credentials. Production mode requires runtime refs owned by Finance/Integration, Packaging Ops and DevOps. |

## 6. Handoff To Coding

- Use `database/03_TABLE_SPECIFICATION.md`, `database/04_ENUM_REFERENCE.md`, and `database/05_INDEX_CONSTRAINT_REFERENCE.md` as frozen schema/constraint inputs for baseline migration.
- Use `api/02_API_ENDPOINT_CATALOG.md` and `api/03_API_REQUEST_RESPONSE_SPEC.md` as frozen route/DTO inputs for OpenAPI/types.
- Generate permission/action seed from `roles_permissions.csv`; seed validation must include duplicate check and critical action check.
- Public trace implementation must serialize only `PublicTracePublicResponse` and must reject extra fields by schema/test.
- Seed pipeline must run twice for idempotency before closing any seed-affecting phase.
