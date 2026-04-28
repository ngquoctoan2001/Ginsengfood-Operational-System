# 08 Frontend API Client Contract

## Mục lục

- [1. Mục tiêu](#1-mục-tiêu)
- [2. Client Boundaries](#2-client-boundaries)
- [3. Route Family Contract](#3-route-family-contract)
- [4. Common Response Types](#4-common-response-types)
- [5. Client Method Conventions](#5-client-method-conventions)
- [6. DTO Families](#6-dto-families)
- [7. Public Trace DTO](#7-public-trace-dto)
- [8. Idempotency Contract](#8-idempotency-contract)
- [9. Error Handling Contract](#9-error-handling-contract)
- [10. Query Key And Cache Invalidation](#10-query-key-and-cache-invalidation)
- [11. Permission And Action Gating](#11-permission-and-action-gating)
- [12. OpenAPI Type Generation](#12-openapi-type-generation)
- [13. Offline/PWA Sync Contract](#13-offlinepwa-sync-contract)
- [14. FE/BE Contract Done Gate](#14-febe-contract-done-gate)

## 1. Mục tiêu

Tài liệu này định nghĩa hợp đồng FE API client để backend/frontend đồng bộ route, DTO, permission, idempotency, error handling, cache invalidation và public/internal data boundary.

## 2. Client Boundaries

| Client | Base path | Auth | Dùng cho | Không được dùng cho |
|---|---|---|---|---|
| `adminClient` | `/api/admin` | Required | Admin Web, Integration Console, internal trace, recall, inventory, MISA | Public trace page |
| `mobileClient` | `/api/admin` hoặc mobile gateway [OWNER DECISION NEEDED] | Required | Shopfloor PWA commands, scan, offline queue | Anonymous access |
| `publicTraceClient` | `/api/public` | Anonymous/public | `/trace/{qrCode}` public page | Admin trace, internal genealogy, supplier/personnel/cost/QC defect/loss/MISA fields |

## 3. Route Family Contract

FE phải dùng route family đã chuẩn hóa trong `api/02_API_ENDPOINT_CATALOG.md`.

| Domain | FE route group | API route family |
|---|---|---|
| Source Origin | `/admin/source-origin/*` | `/api/admin/source-zones`, `/api/admin/source-origins` |
| Raw Material | `/admin/raw-material/*` | `/api/admin/raw-material/intakes`, `/api/admin/raw-material/lots`, `/api/admin/raw-material/lots/{lotId}/readiness` |
| SKU/Recipe | `/admin/catalog/*` | `/api/admin/skus`, `/api/admin/ingredients`, `/api/admin/recipes` |
| Production | `/admin/production/*` | `/api/admin/production-orders`, `/api/admin/work-orders`, `/api/admin/batch-executions` |
| Material Flow | `/admin/material/*` | `/api/admin/material-requests`, `/api/admin/material-issues`, `/api/admin/material-receipts` |
| QC/Release | `/admin/qc/*`, `/admin/release/*` | `/api/admin/qc-inspections`, `/api/admin/batch-releases`, `/api/admin/batches/{id}/release` |
| Packaging/Printing | `/admin/packaging/*`, `/admin/printing/*` | `/api/admin/trade-items`, `/api/admin/packaging-jobs`, `/api/admin/qr-registry`, `/api/admin/print-jobs` |
| Warehouse/Inventory | `/admin/warehouse/*`, `/admin/inventory/*` | `/api/admin/warehouse-receipts`, `/api/admin/inventory-ledger`, `/api/admin/lot-balances`, `/api/admin/inventory-adjustments` |
| Traceability | `/admin/traceability/*` | `/api/admin/trace/*` |
| Public Trace | `/trace/{qrCode}` | `/api/public/trace/{qrCode}` |
| Recall | `/admin/recall/*` | `/api/admin/incidents`, `/api/admin/recall-cases`, `/api/admin/recall-holds` |
| MISA Integration | `/admin/integrations/misa/*` | `/api/admin/integrations/misa/*` |
| System | `/admin/system/*` | `/api/admin/users`, `/api/admin/roles`, `/api/admin/audit-logs`, `/api/admin/ui/screens` |

Legacy/generated route families như `/api/admin/raw-material/source-zones` hoặc `/api/admin/master-data/skus` không được thêm vào FE client mới nếu chưa có route impact analysis và owner approval.

## 4. Common Response Types

```ts
export type ApiSuccess<T> = {
  data: T;
  meta?: {
    page?: number;
    page_size?: number;
    total?: number;
    sort?: string;
    correlation_id?: string;
    warnings?: ApiWarning[];
  };
};

export type ApiError = {
  error: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
    field_errors?: Record<string, string[]>;
    correlation_id?: string;
  };
};

export type ApiWarning = {
  code: string;
  message: string;
};
```

## 5. Client Method Conventions

```ts
type RequestOptions = {
  signal?: AbortSignal;
  idempotencyKey?: string;
  correlationId?: string;
  headers?: Record<string, string>;
};

type ListParams = {
  page?: number;
  page_size?: number;
  sort?: string;
  q?: string;
  [filter: string]: string | number | boolean | undefined;
};
```

| Method type | Naming | Behavior |
|---|---|---|
| List | `listX(params)` | GET list, returns `ApiSuccess<Page<X>>` or `{data: X[], meta}` according API spec. |
| Detail | `getX(id)` | GET detail. |
| Create | `createX(payload, options)` | POST; idempotency required for transaction/stateful create. |
| Patch | `updateX(id, payload, options)` | PATCH; include optimistic version if API supports. |
| Command | `approveX`, `issueMaterial`, `releaseBatch` | POST action endpoint; idempotency required. |
| Public | `getPublicTrace(qrCode)` | GET public trace with public DTO only. |

## 6. DTO Families

| DTO family | Scope | Notes |
|---|---|---|
| `Admin*Dto` | Admin Web/Internal | Có thể chứa internal status, internal ids, audit refs; không dùng cho public. |
| `Command*Request` | Mutate command | Luôn có typed payload, reason nếu cần, idempotency qua header. |
| `PublicTraceDto` | Public trace | Whitelist-only; không extend từ admin trace DTO. |
| `LookupOptionDto` | Select/combobox | `id`, `code`, `label`, `status`, `disabled_reason?`. |
| `Page<T>` | List response | Dùng chung pagination/filter/sort. |
| `ErrorDto` | Error handling | Map theo `api/04_API_ERROR_CODE_SPEC.md`. |
| `RecallCloseCommandRequest` | Recall close | `closeType` phải là `CLOSED` hoặc `CLOSED_WITH_RESIDUAL_RISK`; `residualNote` required khi close residual risk. |

## 7. Public Trace DTO

```ts
export type PublicTraceResponse = {
  qr_code: string;
  qr_status: "GENERATED" | "QUEUED" | "PRINTED" | "FAILED" | "VOID" | "REPRINTED";
  public_status: "VALID" | "VOID" | "RECALLED" | "UNKNOWN";
  sku: {
    sku_code: string;
    public_name: string;
  };
  batch?: {
    public_batch_code: string;
    release_status?: "RELEASED";
    manufacture_date?: string;
  };
  origin_summary?: {
    display_text: string;
  };
  messages?: Array<{
    type: "INFO" | "WARNING";
    text: string;
  }>;
};
```

Forbidden in `PublicTraceResponse` and public UI:

- supplier internal identifier/detail;
- personnel/operator/QC inspector;
- cost/price/costing;
- QC defect detail/internal QC note;
- loss/variance;
- MISA document/status/error;
- internal audit payload.

## 8. Idempotency Contract

| Flow | FE requirement |
|---|---|
| Create transaction | Generate `Idempotency-Key` before submit and keep it until response resolved. |
| Command action | Always pass `Idempotency-Key` in header. |
| Retry after timeout | Reuse same key for same payload. |
| Payload changed | Generate new key and treat as new command. |
| PWA offline | Persist endpoint, payload, key, created_at, attempt_count. |
| Duplicate response | Render existing result and refresh detail/list. |

Example:

```ts
await adminClient.post(
  `/material-issues/${issueId}/issue`,
  payload,
  { idempotencyKey }
);
```

## 9. Error Handling Contract

| Error category | FE behavior |
|---|---|
| Field validation | Show field errors and summary. |
| Permission | Remove forbidden action after reload; show permission denied. |
| State conflict | Reload entity and show stale state message. |
| Inventory/QC/release gate | Show blocking reason and link to relevant screen if allowed. |
| MISA mapping/sync | Link to mapping/sync screen if allowed. |
| Public trace not found/void/recalled | Show public-safe message only. |
| Unknown error | Show generic message + correlation id; no raw stack/payload. |

## 10. Query Key And Cache Invalidation

| Entity | Query key pattern | Invalidate after |
|---|---|---|
| SKU | `["skus", params]`, `["sku", id]` | create/update/deactivate SKU, recipe activation if displayed |
| Recipe | `["recipes", params]`, `["recipe", id]`, `["recipe-lines", id]` | line change, submit, approve, activate, retire |
| Source Origin | `["source-origins", params]`, `["source-origin", id]` | create/update/verify/reject |
| Raw Intake | `["raw-intakes", params]`, `["raw-intake", id]` | create/receive/cancel |
| Raw Lot | `["raw-lots", params]`, `["raw-lot", id]`, `["raw-lot-readiness", id]` | receive intake, QC result, mark_ready, hold/release |
| Production Order | `["production-orders", params]`, `["production-order", id]` | create/start/cancel/close, material request updates |
| Material Issue | `["material-issues", params]`, `["material-issue", id]` | issue/cancel |
| Material Receipt | `["material-receipts", params]`, `["material-receipt", id]` | confirm/cancel |
| QC Inspection | `["qc-inspections", params]`, `["qc-inspection", id]` | result/hold/reject |
| Batch Release | `["batch-releases", params]`, `["batch", id]` | release/reject release |
| QR Registry | `["qr-registry", params]`, `["qr", id]` | generate/queue/print/fail/void/reprint |
| Inventory | `["inventory-ledger", params]`, `["lot-balances", params]` | material issue, warehouse receipt, adjustment |
| Trace | `["trace-search", params]`, `["genealogy", entityType, id]` | material issue/receipt, batch release, QR, warehouse receipt, recall hold |
| Recall | `["recall-cases", params]`, `["recall-case", id]`, `["recall-impact", id]` | create/start/hold/recover/close/close_with_residual_risk |
| MISA | `["misa-sync", params]`, `["misa-mapping", params]`, `["misa-reconcile", params]` | mapping change, retry, reconcile |

## 11. Permission And Action Gating

FE must evaluate permissions in two layers:

1. Route/menu gating: user cannot navigate to screens without read permission.
2. Action gating: button visibility/enabled state depends on permission + entity state.

Example:

```ts
const canReleaseBatch =
  hasPermission("batch_release.release") &&
  batch.qc_status === "QC_PASS" &&
  batch.release_status !== "RELEASED";
```

Material issue uses a different gate. `QC_PASS` alone must not enable issue:

```ts
const canIssueMaterial =
  hasPermission("material_issue.issue") &&
  rawLot.lotStatus === "READY_FOR_PRODUCTION" &&
  rawLot.availableQuantity > 0 &&
  !rawLot.isHeld;
```

Backend must still enforce the same rule. FE gating is only UX.

## 12. OpenAPI Type Generation

| Step | Rule |
|---|---|
| 1 | Generate OpenAPI from accepted API spec, not from unreviewed parallel code routes. |
| 2 | Generate TS types into a dedicated API types folder [path OWNER DECISION NEEDED]. |
| 3 | Do not manually duplicate DTO types if generated type exists. |
| 4 | Public trace DTO must stay separate from admin trace DTO even if fields overlap. |
| 5 | Regenerate types whenever `api/03_API_REQUEST_RESPONSE_SPEC.md` changes. |

## 13. Offline/PWA Sync Contract

| Requirement | Rule |
|---|---|
| Queue storage | Store endpoint, method, payload, idempotency key, created_at, attempt_count, last_error. |
| Command ordering | Sync in order per workflow/entity where ordering matters. |
| Conflict | If stale state, stop command and require user review. |
| Retry | Retry retryable network/server errors with backoff. |
| Security | Offline storage must not include forbidden public/private sensitive payload beyond task needs. |
| Audit | Backend creates audit when command is accepted, not when queued. |

## 14. FE/BE Contract Done Gate

- Every screen in `ui/03_SCREEN_CATALOG.md` maps to at least one API source.
- Every command endpoint in UI uses typed request, typed response and error handling.
- Every critical command sends `Idempotency-Key`.
- No FE client calls legacy/parallel route family without route impact analysis.
- Public trace uses `publicTraceClient` and `PublicTraceResponse` only.
- MISA sync actions are exposed only through integration layer endpoints.
- Query keys and invalidation cover affected list/detail screens after command success.
