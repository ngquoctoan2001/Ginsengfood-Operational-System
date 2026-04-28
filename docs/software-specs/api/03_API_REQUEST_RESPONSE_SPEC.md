# API Request Response Spec

> Mục đích: định nghĩa payload chuẩn cho các endpoint trọng yếu. Chi tiết field có thể tách thành OpenAPI schema, nhưng không được phá các field/rule ở đây.

## Mục lục

- [1. Common Types](#1-common-types)
- [2. Source Origin](#2-source-origin)
- [3. Raw Material](#3-raw-material)
- [4. Recipe And Production](#4-recipe-and-production)
- [5. Material Issue / Receipt](#5-material-issue--receipt)
- [6. Packaging / QR / Release / Warehouse](#6-packaging--qr--release--warehouse)
- [7. Trace / Recall](#7-trace--recall)
- [8. MISA / Dashboard / UI](#8-misa--dashboard--ui)

## 1. Common Types

```json
{
  "id": "uuid",
  "createdAt": "2026-04-27T00:00:00Z",
  "updatedAt": "2026-04-27T00:00:00Z",
  "status": "ACTIVE"
}
```

## 2. Source Origin

`SourceZoneCreateRequest`

```json
{
  "sourceZoneCode": "SZ-LD-001",
  "sourceZoneName": "Vùng trồng Sâm Savigin Lâm Đồng",
  "province": "Lâm Đồng",
  "ward": "Xã ...",
  "addressDetail": "Thôn/khu vực cụ thể",
  "publicDisplayName": "Vùng trồng Sâm Savigin Lâm Đồng"
}
```

`SourceOriginResponse`

```json
{
  "sourceOriginId": "uuid",
  "sourceZoneId": "uuid",
  "verificationStatus": "VERIFIED",
  "evidence": [
    {
      "evidenceId": "uuid",
      "evidenceType": "FIELD_PHOTO",
      "evidenceRef": "object-storage://...",
      "evidenceHash": "sha256:...",
      "capturedAt": "2026-04-27T00:00:00Z"
    }
  ],
  "verifiedAt": "2026-04-27T00:00:00Z"
}
```

## 3. Raw Material

`RawIntakeCreateRequest`

```json
{
  "warehouseId": "uuid",
  "receivedAt": "2026-04-27T00:00:00Z",
  "items": [
    {
      "ingredientId": "uuid",
      "quantity": 100.0,
      "uomCode": "kg",
      "procurementType": "SELF_GROWN",
      "sourceOriginId": "uuid",
      "supplierId": null
    }
  ]
}
```

Validation:

- `SELF_GROWN` requires `sourceOriginId` with `VERIFIED`, forbids `supplierId`.
- `PURCHASED` requires `supplierId`, forbids `sourceOriginId`.
- Quantity must be positive.

`RawLotReadinessResponse`

```json
{
  "rawMaterialLotId": "uuid",
  "lotStatus": "READY_FOR_PRODUCTION",
  "isReadyForIssue": true,
  "qcStatus": "QC_PASS",
  "availableQuantity": 50.0,
  "blockingReasons": []
}
```

Rule: `isReadyForIssue` is derived from `lotStatus === "READY_FOR_PRODUCTION"` plus balance/source/hold checks, not from `qcStatus === "QC_PASS"` alone.

`LotReadinessTransitionRequest`

```json
{
  "targetLotStatus": "READY_FOR_PRODUCTION",
  "actionCode": "RAW_LOT_MARK_READY",
  "reasonText": "QC pass, source valid, balance available",
  "evidenceRef": "optional-evidence-ref"
}
```

## 4. Recipe And Production

`RecipeCreateRequest`

```json
{
  "skuId": "uuid",
  "formulaCode": "FML-A1-G1",
  "formulaVersion": "G1",
  "effectiveFrom": "2026-04-27T00:00:00Z",
  "lines": [
    {
      "lineNo": 10,
      "groupCode": "SPECIAL_SKU_COMPONENT",
      "ingredientId": "uuid",
      "quantityPerBatch400": 9.0,
      "uomCode": "kg",
      "ratioPercent": 4.62,
      "prepNote": "Thành phần đặc thù SKU",
      "usageRole": "SPECIAL_COMPONENT"
    }
  ]
}
```

`ProductionOrderCreateRequest`

```json
{
  "skuId": "uuid",
  "batchSize": 400,
  "plannedStartAt": "2026-04-27T08:00:00Z"
}
```

`ProductionOrderResponse` must include immutable `snapshotLines`:

```json
{
  "productionOrderId": "uuid",
  "productionOrderNo": "PO-2026-0001",
  "skuId": "uuid",
  "formulaCode": "FML-A1-G1",
  "formulaVersion": "G1",
  "productionOrderStatus": "OPEN",
  "snapshotLines": [
    {
      "recipeLineGroupCode": "SPECIAL_SKU_COMPONENT",
      "ingredientCode": "HRB_SAM_SAVIGIN",
      "ingredientDisplayName": "Sâm Savigin",
      "quantityPerBatch400": 9.0,
      "uomCode": "kg",
      "prepNote": "Thành phần đặc thù SKU",
      "usageRole": "SPECIAL_COMPONENT"
    }
  ]
}
```

## 5. Material Issue / Receipt

`MaterialIssueExecuteRequest`

```json
{
  "materialRequestId": "uuid",
  "lines": [
    {
      "materialRequestLineId": "uuid",
      "rawMaterialLotId": "uuid",
      "issuedQuantity": 9.0,
      "uomCode": "kg"
    }
  ],
  "executedAt": "2026-04-27T09:00:00Z"
}
```

Response must include ledger reference:

```json
{
  "materialIssueId": "uuid",
  "issueStatus": "EXECUTED",
  "ledgerEntries": [
    {
      "inventoryLedgerId": "uuid",
      "ledgerDirection": "DEBIT",
      "quantity": 9.0
    }
  ]
}
```

`MaterialReceiptConfirmRequest`

```json
{
  "materialIssueId": "uuid",
  "lines": [
    {
      "materialIssueLineId": "uuid",
      "receivedQuantity": 8.9,
      "varianceReasonCode": "WORKSHOP_LOSS",
      "varianceReasonText": "Sai lệch khi bàn giao"
    }
  ]
}
```

## 6. Packaging / QR / Release / Warehouse

`QrGenerateRequest`

```json
{
  "packagingUnitIds": ["uuid"],
  "tradeItemId": "uuid",
  "commercialPrint": true,
  "publicTraceEnabled": true
}
```

Rule: if `commercialPrint = true`, the service must validate active GTIN/trade-item mapping and must not fallback to SKU code.

`ReprintRequest`

```json
{
  "reasonCode": "LABEL_DAMAGED",
  "reasonText": "Tem bị rách trong quá trình dán"
}
```

`PrintJobRequest`

```json
{
  "packagingUnitId": "uuid",
  "qrId": "uuid",
  "tradeItemId": "uuid",
  "templateCode": "BOX_LEVEL_2",
  "commercialPrint": true
}
```

`BatchReleaseApproveRequest`

```json
{
  "releaseNote": "QC đạt, không có hold",
  "approvedAt": "2026-04-27T12:00:00Z"
}
```

`WarehouseReceiptCreateRequest`

```json
{
  "warehouseId": "uuid",
  "batchId": "uuid",
  "batchReleaseId": "uuid",
  "lines": [
    {
      "packagingUnitId": "uuid",
      "receivedQuantity": 100,
      "uomCode": "hộp"
    }
  ]
}
```

`WarehouseReceiptResponse`

```json
{
  "warehouseReceiptId": "uuid",
  "receiptStatus": "CONFIRMED",
  "batchReleaseId": "uuid",
  "ledgerEntries": [
    {
      "inventoryLedgerId": "uuid",
      "ledgerDirection": "CREDIT",
      "quantity": 100,
      "uomCode": "hộp"
    }
  ],
  "balanceProjectionRefs": ["uuid"]
}
```

## 7. Trace / Recall

`InternalTraceResponse`

```json
{
  "query": {
    "qrCode": "QR..."
  },
  "chain": {
    "sourceOrigins": [],
    "rawMaterialLots": [],
    "materialIssues": [],
    "batches": [],
    "packagingUnits": [],
    "warehouseReceipts": [],
    "shipments": []
  },
  "gaps": [
    {
      "gapType": "MISSING_TRACE_LINK",
      "missingObject": "RAW_MATERIAL_LOT",
      "chainPosition": "BATCH_TO_RAW_LOT",
      "severity": "BLOCKING"
    }
  ]
}
```

`PublicTraceResponse`

```json
{
  "skuName": "Cháo Sâm - Diêm mạch & Hạt sen",
  "batchPublicStatus": "RELEASED",
  "source": {
    "sourceZoneName": "Vùng trồng Sâm Savigin Lâm Đồng",
    "province": "Lâm Đồng",
    "ward": "Xã ...",
    "addressDetail": "Thông tin public đã duyệt"
  },
  "producedAt": "2026-04-27",
  "releasedAt": "2026-04-27"
}
```

Forbidden in public trace: `supplierId`, supplier name/internal detail, `actorUserId`, personnel names, costing, MISA ids, QC defect detail, loss/waste, raw ledger ids.

`RecallImpactRequest`

```json
{
  "traceQuery": {
    "batchId": "uuid"
  },
  "reasonText": "Suspected issue"
}
```

`RecallCloseRequest`

```json
{
  "closeType": "CLOSED_WITH_RESIDUAL_RISK",
  "residualNote": "Required when closeType is CLOSED_WITH_RESIDUAL_RISK",
  "reasonText": "Residual customer exposure accepted by authorized approver"
}
```

## 8. MISA / Dashboard / UI

`MisaRetryRequest`

```json
{
  "reasonText": "Mapping fixed, retry sync"
}
```

`AccountingDocumentPostRequest`

```json
{
  "reasonText": "Post material issue accounting document after warehouse issue execution",
  "postingDate": "2026-04-27"
}
```

`AccountingDocumentResponse`

```json
{
  "documentId": "uuid",
  "documentType": "MATERIAL_ISSUE_ACCOUNTING",
  "documentStatus": "POSTED",
  "syncStatus": "PENDING",
  "misaSyncEventId": "uuid"
}
```

`OverrideRequestSubmitRequest`

```json
{
  "targetActionCode": "WAREHOUSE_RECEIPT_CONFIRM",
  "targetObjectType": "BATCH",
  "targetObjectId": "uuid",
  "reasonText": "Break-glass request for approved exception",
  "requestedTtlMinutes": 15
}
```

`OverrideRequestResponse`

```json
{
  "overrideRequestId": "uuid",
  "approvalStatus": "PENDING",
  "activationStatus": "NOT_ACTIVE",
  "expiresAt": null
}
```

`MenuResponse`

```json
{
  "items": [
    {
      "screenId": "SCR-RAW-INTAKE",
      "label": "Raw Material Intake",
      "route": "/admin/raw-material/intakes",
      "actions": ["RAW_INTAKE_CREATE"]
    }
  ]
}
```
