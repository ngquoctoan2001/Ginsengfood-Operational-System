# OpenAPI Generation Guide

> Mục đích: hướng dẫn tạo OpenAPI contract từ bộ spec này để backend/frontend cùng dùng types/client.

## 1. Source Of OpenAPI

OpenAPI phải lấy từ:

- `api/01_API_CONVENTION.md`
- `api/02_API_ENDPOINT_CATALOG.md`
- `api/03_API_REQUEST_RESPONSE_SPEC.md`
- `api/04_API_ERROR_CODE_SPEC.md`
- `api/05_API_AUTH_PERMISSION_SPEC.md`
- `api/06_API_IDEMPOTENCY_SPEC.md`
- `database/04_ENUM_REFERENCE.md`

Không generate route từ source code hiện hữu trước khi có route impact analysis trong implementation phase.

Enum generation must include the repaired database states: `lot_status`, `batch_status` with `PACKAGED`/`BLOCKED`, and `recall_status` with `CLOSED_WITH_RESIDUAL_RISK`.

## 2. OpenAPI Structure

| Section | Content |
| --- | --- |
| `info` | Ginsengfood Operational API, versioned spec date. |
| `servers` | `/api/admin`, `/api/mobile`, `/api/public`. |
| `securitySchemes` | Bearer auth for admin/mobile, none for public trace. |
| `tags` | M01-M16 module tags. |
| `paths` | Endpoint catalog rows. |
| `components.schemas` | Request/response DTOs and enums. |
| `components.responses` | Standard errors. |
| `components.parameters` | Pagination/filter/sort/idempotency headers. |

## 3. Required Tags

```text
Foundation
AuthPermission
GovernanceOverride
MasterData
SkuIngredientRecipe
SourceOrigin
RawMaterial
Production
MaterialIssueReceipt
QcRelease
PackagingPrinting
WarehouseInventory
Traceability
Recall
MisaIntegration
ReportingDashboard
AdminUi
PublicTrace
```

## 4. Generation Rules

- Every path in `02_API_ENDPOINT_CATALOG.md` must have operationId.
- operationId format: camelCase verb-first, e.g. `createRawMaterialIntake`, `markRawLotReady`, `executeMaterialIssue`.
- Every protected operation must declare required permission/action in `x-permission`.
- Every idempotent command must declare `X-Idempotency-Key` header.
- Public trace schemas must not reference internal trace/admin schemas.
- Error responses must include shared `ErrorResponse`.
- Enum values must match `database/04_ENUM_REFERENCE.md`.

## 5. Frontend Client Handoff

Generated client must expose:

- Typed request/response DTOs.
- Typed error code union.
- Pagination helpers.
- Auth header injection for admin/mobile.
- Idempotency key helper for commands.
- Public trace client separated from admin client.

## 6. OpenAPI Done Gate

| Gate | Check |
| --- | --- |
| Endpoint coverage | Every catalog endpoint exists in OpenAPI. |
| Permission coverage | Every admin/mobile endpoint has `x-permission` or explicit `N/A`. |
| Idempotency coverage | Every required command has header parameter. |
| Error coverage | Standard errors present. |
| Public trace safety | No forbidden fields in public schema. |
| Public trace schema independence | Public trace schemas have no `$ref` to internal admin/trace schemas. |
| Route canonical coverage | Catalog paths match the route family table; legacy/adapter paths are not emitted as primary OpenAPI paths. |
| Enum hard-lock coverage | Generated enum types include `READY_FOR_PRODUCTION`, `PACKAGED`, `BLOCKED`, `CLOSED_WITH_RESIDUAL_RISK`, `QR_REPRINTED`. |
| Frontend generation | Type/client generation succeeds without manual patching. |
