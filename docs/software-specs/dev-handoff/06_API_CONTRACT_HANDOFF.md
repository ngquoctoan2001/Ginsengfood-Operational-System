# 06 - API Contract Handoff

## 1. Mục tiêu

Handoff này giúp backend/frontend/QA đồng bộ endpoint, DTO, error, permission, idempotency, pagination/filter/sort và public/private field policy.

## 2. Route Family Ownership

| module | Route family |
|---|---|
| M01 | `/api/admin/audit/*`, `/api/admin/events/*`, `/api/admin/system/*` |
| M02 | `/api/admin/auth/*`, `/api/admin/roles/*`, `/api/admin/approvals/*` |
| M03 | `/api/admin/master-data/*`, `/api/admin/suppliers`, `/api/admin/warehouses` |
| M04 | `/api/admin/skus`, `/api/admin/ingredients`, `/api/admin/recipes` |
| M05 | `/api/admin/source-zones`, `/api/admin/source-origins` |
| M06 | `/api/admin/raw-material/intakes`, `/api/admin/raw-material/lots`, `/api/admin/raw-material/lots/{lotId}/readiness`, raw lot QC endpoints |
| M07 | `/api/admin/production/orders`, `/api/admin/production/work-orders`, `/api/admin/production/process-events` |
| M08 | `/api/admin/production/material-requests`, `/api/admin/production/material-issues`, `/api/admin/production/material-receipts` |
| M09 | `/api/admin/qc/inspections`, `/api/admin/qc/releases` |
| M10 | `/api/admin/trade-items`, `/api/admin/packaging/jobs`, `/api/admin/qr/*`, `/api/admin/printing/*` |
| M11 | `/api/admin/warehouse/receipts`, `/api/admin/inventory/*` |
| M12 | `/api/admin/trace/*`, `/api/public/trace/{qrCode}` |
| M13 | `/api/admin/incidents`, `/api/admin/recall/*` |
| M14 | `/api/admin/integrations/misa/*` |
| M15 | `/api/admin/dashboard/*`, `/api/admin/alerts/*` |
| M16 | `/api/admin/ui/*`, `/api/mobile/offline-submissions` |

## 3. Contract Change Checklist

| change | Backend action | Frontend action | QA action |
|---|---|---|---|
| New endpoint | Add route/service/permission/error/idempotency | Add client/types/hook/screen action | Add API/UI test |
| DTO field added | Document default/nullability/public/private | Update type and render/ignore policy | Add response assertion |
| DTO field removed | Check consumers and deprecation | Remove UI usage | Regression route/screen |
| Error code changed | Update error spec | Update error mapper | Negative test |
| State enum changed | Update state machine/API docs | Update badges/actions/filters | State transition test |
| Permission changed | Update action registry/RBAC | Update menu/action visibility | 403 + UI permission test |

## 4. Idempotency Contract

| endpoint type | Idempotency |
|---|---|
| Query `GET` | Not required |
| Create command | Required unless explicitly read-only |
| State transition command | Required |
| Raw lot mark-ready | Required for `POST /api/admin/raw-material/lots/{lotId}/readiness`; replay must not create duplicate state/audit/event rows |
| Approval/reject/release/hold/retry/reconcile | Required |
| Public trace resolve | Not required |
| Offline/PWA submit | Required |

Expected behavior:

- Same key + same payload returns same result/replay.
- Same key + different payload returns conflict.
- Side effects such as ledger, audit, event, QR, release must not duplicate.
- Material issue contract must use error `RAW_MATERIAL_LOT_NOT_READY` when `lotStatus != READY_FOR_PRODUCTION`; `QC_PASS` alone is not a valid issue gate.

## 5. Public Trace API Policy

`GET /api/public/trace/{qrCode}`:

- No auth required.
- Response is whitelist-only.
- Must not expose supplier, personnel, cost, QC defect detail, loss, MISA/internal sync, private notes.
- QR `VOID`/`FAILED`/not public returns safe invalid/not found response.
- Admin/internal trace DTO must not be reused as public DTO.

## 6. API Done Gate

- Endpoint exists in `api/02_API_ENDPOINT_CATALOG.md`.
- Request/response exists in `api/03_API_REQUEST_RESPONSE_SPEC.md`.
- Error codes exist in `api/04_API_ERROR_CODE_SPEC.md`.
- Permission exists in `api/05_API_AUTH_PERMISSION_SPEC.md`.
- Idempotency requirement exists in `api/06_API_IDEMPOTENCY_SPEC.md`.
- Pagination/filter/sort follows `api/07_API_PAGINATION_FILTER_SORT_SPEC.md`.
- FE client/types/screens/tests updated or no-impact evidence provided.
