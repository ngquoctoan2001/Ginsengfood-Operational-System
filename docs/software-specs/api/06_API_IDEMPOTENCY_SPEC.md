# API Idempotency Spec

> Mục đích: chống submit trùng ở các command tạo side effect như intake, issue, receipt, print, release, recall, MISA retry, PWA offline.

## 1. Header

```text
X-Idempotency-Key: <client-generated-stable-key>
```

Recommended key format:

```text
<surface>:<actionCode>:<clientUuid>
```

## 2. Required Endpoints

| Endpoint/action | Why required |
| --- | --- |
| `POST /api/admin/raw-material/intakes` | Avoid duplicate receipt/lot. |
| `POST /api/admin/source-origins/{id}/verify` | Avoid duplicate verification action. |
| `POST /api/admin/raw-material/lots/{id}/readiness` | Avoid duplicate mark-ready transition/audit. |
| `POST /api/admin/approvals/{id}/approve` and `reject` | Avoid duplicate approval action records. |
| `POST /api/admin/recipes/*` actions | Avoid duplicate version/approval/action. |
| `POST /api/admin/production/orders` | Avoid duplicate PO/snapshot. |
| `POST /api/admin/production/material-issues/{id}/execute` | Avoid duplicate ledger debit. |
| `POST /api/admin/production/material-receipts` | Avoid duplicate receipt/variance. |
| `POST /api/admin/qr/generate` | Avoid duplicate QR set. |
| `POST /api/admin/printing/jobs` and `reprint` | Avoid duplicate print/reprint. |
| `POST /api/admin/qc/releases/*` | Avoid duplicate release action. |
| `POST /api/admin/warehouse/receipts` | Avoid duplicate ledger credit. |
| `POST /api/admin/inventory/adjustments` | Avoid duplicate adjustment. |
| Recall actions | Avoid duplicate hold/snapshot/sale lock. |
| MISA retry/reconcile | Avoid duplicate retry/reconcile. |
| Override/break-glass submit/approve/activate/revoke | Avoid duplicate high-risk governance actions. |
| `POST /api/mobile/offline-submissions` | Required for offline replay. |

## 3. Server Behavior

| Case | Response |
| --- | --- |
| First request with key | Execute command, store request hash/result ref. |
| Same key, same payload, completed | Return original result or stable reference with `200/201`. |
| Same key, same payload, processing | Return `202` or current command status. |
| Same key, different payload | Return `409 IDEMPOTENCY_CONFLICT`. |
| Missing key on required endpoint | Return `400/422 VALIDATION_FAILED`. |

## 4. Registry Fields

Table: `idempotency_registry`

| field | Rule |
| --- | --- |
| `scope` | API family/action/user scope. |
| `idempotency_key` | Unique with scope. |
| `request_hash` | Hash of normalized payload. |
| `response_ref_type` / `response_ref_id` | Stable result reference. |
| `command_status` | `PROCESSING`, `COMPLETED`, `FAILED`. |
| `expires_at` | For ordinary command replay retention, optional/long-lived by policy. For break-glass/override activation, mandatory short expiry such as `now() + 15 minutes` unless owner policy sets a stricter value. |

## 5. PWA Offline Rules

- Offline command must include UUID `localCommandId`, action code, payload hash, device id, captured timestamp.
- Server must not double-post material issue/receipt/print if PWA replays.
- Conflict must be visible to operator with resolution state.
