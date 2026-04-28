# API Convention

> Mục đích: chuẩn hóa API contract đích để backend/frontend đồng bộ. Đây là target contract, không xác nhận route đã tồn tại trong source code.

## 1. Source And Route Policy

- Chỉ dùng route family đã chuẩn hóa trong `06_MODULE_MAP.md`, `07_PHASE_PLAN.md`, `08_REQUIREMENTS_TRACEABILITY_MATRIX.md`, `architecture/`, `database/`.
- Không tạo route song song từ tài liệu cũ khi chưa có impact analysis ở phase implementation.
- Các route legacy/generated như `/api/admin/raw-material/source-zones` chỉ được xem là adapter/deprecation candidate; contract đích dùng `/api/admin/source-zones`.
- Một route được coi là migrated khi endpoint catalog, permission spec, request/response spec, OpenAPI và UI/client đều dùng cùng path; route cũ chỉ được giữ dưới dạng adapter có deprecation note và test tương thích.
- Material issue/receipt primary target dùng `/api/admin/production/material-issues/*` và `/api/admin/production/material-receipts`; nested work-order action route chỉ là adapter nếu implementation phase có route impact analysis.
- Public trace API tách riêng `/api/public/trace/*` và không dùng DTO/entity nội bộ.

## 2. URL Prefix

| Prefix | Auth | Purpose |
| --- | --- | --- |
| `/api/admin/*` | Required | Internal admin/operations APIs. |
| `/api/mobile/*` | Required | PWA/shopfloor compact command APIs if separated from admin. |
| `/api/public/*` | Anonymous read-only | Public trace. |
| `/health` | Optional/internal policy | Health checks, no sensitive data; must not expose connection strings, credentials, internal service names or raw downstream error payloads. |

## 3. Naming Rules

| Rule | Convention |
| --- | --- |
| Resource names | plural, lowercase, kebab-case |
| IDs in path | `{resourceId}` using camelCase placeholder in docs |
| Actions | `POST /{resource}/{id}/{action}` for state changes such as `approve`, `execute`, `release`, `hold`, `retry` |
| Nested action routes | Use only when the child action is scoped by a parent owner, e.g. `/api/admin/recall/cases/{recallCaseId}/close`; avoid 3-level nesting unless listed in endpoint catalog. |
| Query params | camelCase |
| JSON keys | camelCase |
| Enum values | UPPER_SNAKE_CASE |
| Timestamps | ISO-8601 UTC |

## 4. Standard Response Envelope

Success single:

```json
{
  "data": {
    "id": "uuid",
    "status": "ACTIVE"
  },
  "meta": {
    "correlationId": "req-..."
  }
}
```

Success collection:

```json
{
  "data": [],
  "meta": {
    "page": 1,
    "pageSize": 50,
    "total": 0,
    "sort": "createdAt:desc",
    "correlationId": "req-..."
  }
}
```

Error:

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Validation failed.",
    "details": [
      {
        "field": "quantity",
        "issue": "MUST_BE_POSITIVE"
      }
    ],
    "correlationId": "req-..."
  }
}
```

## 5. HTTP Status

| Status | Usage |
| --- | --- |
| `200` | Successful query/update/action with response body. |
| `201` | Resource created. |
| `202` | Async command accepted, e.g. MISA retry/print dispatch. |
| `204` | Successful action with no body, rarely used. |
| `400` | Malformed request. |
| `401` | Missing/invalid auth. |
| `403` | Authenticated but missing permission. |
| `404` | Resource not found. |
| `409` | Duplicate key, idempotency conflict, state conflict. |
| `422` | Valid JSON but violates business rule. |
| `429` | Rate limit. |
| `500` | Unexpected server error. |
| `503` | Downstream temporarily unavailable. |

## 6. Required Headers

| Header | Required | Applies to | Rule |
| --- | --- | --- | --- |
| `Authorization: Bearer <token>` | Yes | `/api/admin/*`, `/api/mobile/*` | Local account/RBAC phase 1. |
| `X-Idempotency-Key` | Yes for high-risk commands | create/execute/confirm/release/print/retry/offline | See `06_API_IDEMPOTENCY_SPEC.md`. |
| `X-Correlation-Id` | Recommended | All | Server may generate if absent. |
| `X-Device-Id` | Required when PWA/device submit | `/api/mobile/*`, print callbacks if any | Device/session trace. |

## 7. State-Changing Command Rules

- Must check auth/permission in backend.
- Must validate state machine and hard locks.
- Hard locks must be explicit in service validation: material issue requires `lotStatus = READY_FOR_PRODUCTION`; warehouse receipt requires `op_batch_release.releaseStatus = APPROVED_RELEASED`; batch release requires finished-goods QC pass and no active hold; public trace must use whitelist projection only.
- Must write audit/state transition when sensitive.
- Must be idempotent if duplicate submit can create side effects.
- Must not mutate append-only/audit/ledger/snapshot records in-place.

## 8. Public Trace API Rules

- Only endpoint family: `/api/public/trace/*`.
- Response is whitelist-only from public trace policy/projection.
- Forbidden fields: supplier internal detail, personnel, costing, QC defect/loss, MISA/accounting/private integration data, internal raw lot/ledger ids.
- Invalid QR states `FAILED`/`VOID` return safe invalid/not-found response.
