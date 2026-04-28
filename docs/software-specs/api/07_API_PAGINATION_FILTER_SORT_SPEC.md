# API Pagination Filter Sort Spec

> Mục đích: chuẩn hóa list/query API để frontend table/filter nhất quán.

## 1. Pagination

| Param | Default | Rule |
| --- | --- | --- |
| `page` | `1` | 1-based page number. |
| `pageSize` | `50` | Max default `100` unless endpoint-specific. |
| `cursor` | optional | May be used for high-volume audit/ledger/trace. |

Response:

```json
{
  "data": [],
  "meta": {
    "page": 1,
    "pageSize": 50,
    "total": 123,
    "sort": "createdAt:desc"
  }
}
```

## 2. Sorting

Format:

```text
sort=createdAt:desc,status:asc
```

Allowed default sort:

| Resource | Default sort |
| --- | --- |
| Audit/state/ledger/history | `createdAt:desc` |
| Queue screens | Explicit queue ordering, e.g. approval queue `approvalStatus:pending_first,createdAt:asc`; no undocumented "priority first" behavior. |
| Master data | `code:asc` or `displayName:asc` |
| Trace results | Domain chain order, not arbitrary sort |

## 3. Common Filters

| Param | Applies to | Example |
| --- | --- | --- |
| `status` | lifecycle resources | `status=ACTIVE` |
| `fromDate`, `toDate` | date-range resources | `fromDate=2026-04-01` |
| `q` | text search | `q=FML-A1` |
| `skuId` | SKU-linked resources | `skuId=uuid` |
| `batchId` | batch-linked resources | `batchId=uuid` |
| `warehouseId` | inventory/warehouse | `warehouseId=uuid` |
| `ingredientId` | raw/material/recipe | `ingredientId=uuid` |
| `procurementType` | raw lot/intake | `procurementType=SELF_GROWN` |
| `qcStatus` | lot/QC | `qcStatus=QC_PASS` |
| `lotStatus` | raw lot lifecycle/readiness | `lotStatus=READY_FOR_PRODUCTION` |
| `releaseStatus` | release | `releaseStatus=APPROVED_RELEASED` |
| `qrStatus` | QR | `qrStatus=PRINTED` |
| `syncStatus` | MISA/outbox | `syncStatus=FAILED_NEEDS_REVIEW` |

## 4. Endpoint-Specific Query Notes

| Endpoint | Required/allowed filters |
| --- | --- |
| `/api/admin/raw-material/lots` | `ingredientId`, `qcStatus`, `lotStatus`, `procurementType`, `warehouseId`, `sourceOriginId`, `supplierId`; valid `lotStatus` includes `CREATED`, `IN_QC`, `ON_HOLD`, `REJECTED`, `READY_FOR_PRODUCTION`, `CONSUMED`, `EXPIRED`, `QUARANTINED` |
| `/api/admin/production/orders` | `status`, `skuId`, `fromDate`, `toDate` |
| `/api/admin/inventory/ledger` | `warehouseId`, `itemType`, `itemId`, `lotCode`, `ledgerDirection`, `fromDate`, `toDate`; `ledgerDirection` includes `DEBIT`, `CREDIT`, `REVERSAL`, `ADJUSTMENT` |
| `/api/admin/trace/search` | `qrCode`, `batchId`, `rawMaterialLotId`, `sourceOriginId`; at least one required |
| `/api/admin/recall/cases` | `recallStatus`, `severity`, `fromDate`, `toDate`; valid `recallStatus` includes `CLOSED_WITH_RESIDUAL_RISK` |
| `/api/admin/integrations/misa/sync-events` | `syncStatus`, `eventType`, `fromDate`, `toDate` |

## 5. Validation

- Unknown filter param may return `400 VALIDATION_FAILED` or be ignored only if documented.
- Invalid enum filter returns `422 VALIDATION_FAILED`.
- Large unfiltered audit/ledger queries should require date range or cursor.
