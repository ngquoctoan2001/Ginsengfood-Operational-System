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
      "evidenceRef": "local://evidence/dev/source-origin/field-2026-04-27.jpg",
      "evidenceHash": "sha256:...",
      "mimeType": "image/jpeg",
      "fileSizeBytes": 184320,
      "originalFilename": "field-2026-04-27.jpg",
      "scanStatus": "CLEAN",
      "capturedAt": "2026-04-27T00:00:00Z"
    },
    {
      "evidenceId": "uuid",
      "evidenceType": "FIELD_VIDEO",
      "evidenceRef": "local://evidence/dev/source-origin/field-walk-2026-04-27.mp4",
      "evidenceHash": "sha256:...",
      "mimeType": "video/mp4",
      "fileSizeBytes": 52428800,
      "originalFilename": "field-walk-2026-04-27.mp4",
      "scanStatus": "CLEAN",
      "capturedAt": "2026-04-27T00:00:00Z"
    }
  ],
  "verifiedAt": "2026-04-27T00:00:00Z"
}
```

`EvidenceCreateRequest` (`POST /api/admin/source-origins/{sourceOriginId}/evidence`)

```json
{
  "evidenceType": "FIELD_VIDEO",
  "evidenceRef": "local://evidence/dev/source-origin/field-walk-2026-04-27.mp4",
  "evidenceHash": "sha256:...",
  "mimeType": "video/mp4",
  "fileSizeBytes": 52428800,
  "originalFilename": "field-walk-2026-04-27.mp4",
  "capturedAt": "2026-04-27T00:00:00Z",
  "notes": "Walk-through vùng trồng sáng 27/04"
}
```

Validation:

- `evidenceType` phải thuộc enum `FIELD_PHOTO`, `FIELD_VIDEO`, `CERTIFICATE_DOC`, `LAB_REPORT`, `CONTRACT_DOC`, `OTHER`.
- `mimeType` phải thuộc allowlist `image/jpeg`,`image/png`,`image/webp`,`video/mp4`,`video/quicktime`; ngoài allowlist trả `EVIDENCE_MIME_NOT_ALLOWED`.
- `fileSizeBytes` > 0; image ≤ 10×1024×1024 (10MB); video ≤ 100×1024×1024 (100MB); vượt cap trả `EVIDENCE_FILE_TOO_LARGE`.
- `evidenceRef` phải trỏ tới storage adapter đã upload; backend không nhận binary inline. Dev/test dùng `local://...` hoặc local path key do backend cấp; production dùng company storage server URI/key qua cấu hình.
- Upload tạo evidence ở trạng thái `PENDING_SCAN` trừ khi local/dev/test được cấu hình mock/dev-skip scanner để trả kết quả `CLEAN`; source verification và CAPA/recall close chỉ chấp nhận `scanStatus = CLEAN`.
- M05 source origin verification yêu cầu ít nhất 1 evidence hợp lệ trước khi `verify`; thiếu → `EVIDENCE_REQUIRED`; pending/failed/malware scan trả `EVIDENCE_SCAN_PENDING`, `EVIDENCE_SCAN_FAILED` hoặc `EVIDENCE_MALWARE_DETECTED`.

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

### 3.1 Supplier Collaboration (Admin)

`RawIntakeDetailResponse`

```json
{
  "rawMaterialReceiptId": "uuid",
  "warehouseId": "uuid",
  "supplierId": "uuid",
  "createdByParty": "COMPANY",
  "supplierCollaborationStatus": "SUPPLIER_CONFIRMED",
  "rawReceiptStatus": "WAITING_DELIVERY",
  "receivedAt": null,
  "closedAt": null,
  "lines": [
    {
      "lineId": "uuid",
      "ingredientId": "uuid",
      "declaredQuantity": 100.0,
      "receivedQuantity": null,
      "acceptedQuantity": null,
      "rejectedQuantity": null,
      "returnedQuantity": null,
      "uomCode": "kg",
      "procurementType": "PURCHASED",
      "lineStatus": "WAITING_DELIVERY"
    }
  ],
  "evidenceCount": 3,
  "feedbackCount": 1
}
```

`RawIntakeReceiveRequest`

```json
{
  "receivedAt": "2026-04-27T08:30:00Z",
  "lines": [
    {
      "lineId": "uuid",
      "receivedQuantity": 98.5
    }
  ]
}
```

Validation:

- Yêu cầu `raw_receipt_status` thuộc `{WAITING_DELIVERY}`; ngoài ra trả `RECEIPT_LOCKED_AFTER_RECEIVE`.
- `receivedQuantity` ≥ 0; tổng theo line không được vượt `declaredQuantity` × hệ số dung sai cấu hình; vi phạm → `LOT_QUANTITY_EXCEEDS_RECEIVED`.
- Nếu collaboration yêu cầu evidence (`HL-SUP-009`) mà `evidenceCount = 0` hoặc evidence chưa `CLEAN` → `SUPPLIER_EVIDENCE_REQUIRED`.

`LineAcceptRequest`

```json
{
  "acceptedQuantity": 98.5,
  "reasonText": "QC visual pass",
  "lots": [{ "lotCode": "LOT-2026-04-27-001", "quantity": 98.5 }]
}
```

Validation: `sum(lots.quantity) = acceptedQuantity`; vi phạm → `RECEIPT_QUANTITY_INVARIANT_FAILED`.

`LineRejectRequest`

```json
{
  "rejectedQuantity": 98.5,
  "rejectionType": "QUALITY",
  "reasonText": "Mốc bề mặt > 5%",
  "evidenceRefs": ["evidence-uri"]
}
```

Validation: `rejectionType` ∈ `{QUALITY, QUANTITY, DOCUMENT, OTHER}`; reason bắt buộc; ít nhất 1 evidence `CLEAN`.

`LineReturnRequest`

```json
{
  "returnedQuantity": 30.0,
  "reasonText": "Trả lại NCC do thiếu chứng từ",
  "evidenceRefs": ["evidence-uri"]
}
```

Validation: `returnedQuantity` ≤ `rejectedQuantity` (canonical invariant — only rejected goods can be returned); ghi đè đường EX-RECEIPT-RETURN.

`CloseReceiptRequest`

```json
{
  "reasonText": "Đã hoàn tất đối chiếu với NCC"
}
```

Validation: yêu cầu `raw_receipt_status` ∈ `{ACCEPTED, PARTIALLY_ACCEPTED, REJECTED}`; không cho close khi còn line PENDING.

`EvidenceUploadRequest`

```json
{
  "evidenceType": "FIELD_PHOTO",
  "evidenceRef": "local://supplier/2026-04/abc.jpg",
  "mimeType": "image/jpeg",
  "fileSizeBytes": 845123,
  "capturedAt": "2026-04-27T07:55:00Z",
  "capturedByParty": "SUPPLIER"
}
```

Validation: dùng chung allowlist mime/size như Source Origin (mục 2). `capturedByParty` ∈ `{COMPANY, SUPPLIER}`. Sau upload trạng thái `PENDING_SCAN` → `CLEAN/INFECTED`.

`FeedbackCreateRequest`

```json
{
  "feedbackType": "QUANTITY_VARIANCE",
  "body": "Thiếu 1.5kg so với khai báo",
  "attachments": ["evidence-uri"]
}
```

Validation: `feedbackType` ∈ `{QUALITY_ISSUE, DELIVERY_LATE, DELIVERY_EARLY, QUANTITY_VARIANCE, DOCUMENTATION_INCOMPLETE, PACKAGING_DAMAGE, TEMPERATURE_BREACH, OTHER}`; body bắt buộc, ≤ 4000 ký tự.

### 3.2 Supplier Portal (Supplier Self-Service)

`SupplierIntakeListResponse`

```json
{
  "items": [
    {
      "rawMaterialReceiptId": "uuid",
      "createdByParty": "COMPANY",
      "supplierCollaborationStatus": "PENDING_SUPPLIER_CONFIRMATION",
      "rawReceiptStatus": "DRAFT",
      "declaredAt": "2026-04-26T10:00:00Z",
      "lineCount": 3
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

Scope: chỉ trả receipt thuộc `supplier_id` của user; vi phạm → `SUPPLIER_SCOPE_VIOLATION`.

`SupplierIntakeSubmitRequest`

```json
{
  "declaredAt": "2026-04-27T00:00:00Z",
  "items": [
    {
      "ingredientId": "uuid",
      "declaredQuantity": 100.0,
      "uomCode": "kg"
    }
  ],
  "evidenceRefs": ["evidence-uri"]
}
```

Validation:

- `ingredientId` phải nằm trong `op_supplier_ingredient` của supplier; vi phạm → `SUPPLIER_INGREDIENT_NOT_ALLOWED`.
- Supplier ở trạng thái `SUSPENDED` → `SUPPLIER_SUSPENDED`.
- Bắt buộc evidence theo `HL-SUP-009`; thiếu → `SUPPLIER_EVIDENCE_REQUIRED`.

`SupplierConfirmRequest`

```json
{
  "confirmedAt": "2026-04-26T15:30:00Z",
  "note": "Xác nhận đúng kế hoạch giao"
}
```

Validation: chỉ cho phép khi `supplier_collaboration_status = PENDING_SUPPLIER_CONFIRMATION`; sau xác nhận lock chỉnh sửa supplier → `SUPPLIER_EDIT_LOCKED_AFTER_CONFIRMED`.

`SupplierDeclineRequest`

```json
{
  "reasonText": "Không đủ hàng giao đợt này",
  "declinedAt": "2026-04-26T15:30:00Z"
}
```

Validation: bắt buộc `reasonText`; chuyển sang `SUPPLIER_DECLINED` và đường EX-SUP-DECLINE; phía company nhận event và đóng receipt → `SUPPLIER_DECLINED_BLOCKED` cho mọi action thay đổi line.

`SupplierSelfResponse`

```json
{
  "supplierId": "uuid",
  "supplierCode": "SUP-0001",
  "displayName": "NCC Đông Bắc",
  "collaborationStatus": "ACTIVE",
  "allowedIngredientCount": 5,
  "openReceiptCount": 2
}
```

## 3A. Supplier Management (M03A)

`SupplierCreateRequest`

```json
{
  "supplierCode": "SUP-0001",
  "displayName": "NCC Đông Bắc",
  "contactEmail": "contact@dongbac.example.com",
  "contactPhone": "+84-...",
  "address": "Lạng Sơn, Việt Nam",
  "taxCode": "0102030405"
}
```

Validation: `supplierCode` unique; `taxCode` chuẩn; trùng → `DUPLICATE_SUPPLIER_INGREDIENT` không áp dụng (đó là cho ingredient); trùng supplierCode → `DUPLICATE_KEY`.

`SupplierUpdateRequest` — như `SupplierCreateRequest` nhưng `supplierCode` không sửa được sau khi tạo.

`SupplierSuspendRequest` / `SupplierReactivateRequest`

```json
{
  "reasonText": "Vi phạm chất lượng đợt 2026-Q1"
}
```

Validation: `SUSPEND` chỉ áp dụng khi không còn open receipt → `SUPPLIER_HAS_OPEN_RECEIPT`.

`SupplierIngredientCreateRequest`

```json
{
  "ingredientId": "uuid",
  "effectiveFrom": "2026-04-01",
  "note": "Hợp đồng khung 2026"
}
```

Validation: trùng cặp `(supplierId, ingredientId)` còn hiệu lực → `DUPLICATE_SUPPLIER_INGREDIENT`.

`SupplierUserCreateRequest`

```json
{
  "username": "sup0001-admin",
  "displayName": "Trần Văn A",
  "email": "a.tran@dongbac.example.com",
  "role": "R-SUPPLIER",
  "initialPassword": "<bcrypt-target>"
}
```

Validation:

- `role` bắt buộc `R-SUPPLIER`; khác → `SUPPLIER_USER_INVALID_ROLE`.
- Mật khẩu phải qua chính sách `HL-SUP-008` (≥ 12 ký tự, đa ký tự loại); vi phạm → `WEAK_PASSWORD`.
- User M03A bị ràng buộc scope `supplier_id` qua `op_supplier_user_link`; truy cập ngoài scope → `SUPPLIER_SCOPE_VIOLATION`.

`SupplierUserResetPasswordRequest`

```json
{
  "newPassword": "<bcrypt-target>",
  "forceChangeOnNextLogin": true
}
```

Validation: cùng chính sách `WEAK_PASSWORD`.

## 4. Recipe And Production

`RecipeCreateRequest`

```json
{
  "skuId": "uuid",
  "formulaCode": "FML-A1-G1",
  "formulaVersion": "G1",
  "formulaKind": "PILOT_PERCENT_BASED",
  "anchorIngredientId": "uuid",
  "anchorBaselineQuantity": 9.0,
  "anchorUomCode": "kg",
  "anchorRatioPercent": 4.62,
  "effectiveFrom": "2026-04-27T00:00:00Z",
  "lines": [
    {
      "lineNo": 10,
      "groupCode": "SPECIAL_SKU_COMPONENT",
      "ingredientId": "uuid",
      "isAnchor": true,
      "ratioPercent": 4.62,
      "quantityPerBatch400": null,
      "uomCode": "kg",
      "prepNote": "Thành phần đặc thù SKU",
      "usageRole": "SPECIAL_COMPONENT"
    }
  ]
}
```

`RecipeCreateRequest` - biến thể FIXED_QUANTITY_BATCH (G2)

```json
{
  "skuId": "uuid",
  "formulaCode": "FML-A1-G2",
  "formulaVersion": "G2",
  "formulaKind": "FIXED_QUANTITY_BATCH",
  "anchorIngredientId": null,
  "anchorBaselineQuantity": null,
  "anchorUomCode": null,
  "anchorRatioPercent": null,
  "effectiveFrom": "2026-08-01T00:00:00Z",
  "lines": [
    {
      "lineNo": 10,
      "groupCode": "SPECIAL_SKU_COMPONENT",
      "ingredientId": "uuid",
      "isAnchor": false,
      "ratioPercent": null,
      "quantityPerBatch400": 9.0,
      "uomCode": "kg",
      "prepNote": "Thành phần đặc thù SKU",
      "usageRole": "SPECIAL_COMPONENT"
    }
  ]
}
```

API phải validate:

- `formulaKind = PILOT_PERCENT_BASED` ⇒ anchor 4 fields NOT NULL > 0 (`anchorRatioPercent <= 100`); mỗi line phải có `ratioPercent > 0` và SUM(ratioPercent) per recipe ∈ `[99.95, 100.05]`; đúng 1 line `isAnchor = true` với `ingredientId = anchorIngredientId`; `quantityPerBatch400` cho phép NULL.
- `formulaKind = FIXED_QUANTITY_BATCH` ⇒ anchor 4 fields NULL; mọi line `quantityPerBatch400 > 0`; `isAnchor = false`; `ratioPercent` cho phép NULL.
- `formulaKind` ngoài 2 enum trả `FORMULA_KIND_INVALID`.
- Vi phạm anchor: `RECIPE_ANCHOR_REQUIRED` hoặc `RECIPE_ANCHOR_DUPLICATE`.
- SUM ratio sai: `RECIPE_RATIO_SUM_INVALID`.

`ProductionOrderCreateRequest`

```json
{
  "skuId": "uuid",
  "formulaVersion": "G1",
  "formulaKind": "PILOT_PERCENT_BASED",
  "anchorQuantityInput": 12.5,
  "batchSize": null,
  "plannedStartAt": "2026-04-27T08:00:00Z"
}
```

`ProductionOrderCreateRequest` - biến thể FIXED_QUANTITY_BATCH

```json
{
  "skuId": "uuid",
  "formulaVersion": "G2",
  "formulaKind": "FIXED_QUANTITY_BATCH",
  "anchorQuantityInput": null,
  "batchSize": 400,
  "plannedStartAt": "2026-08-01T08:00:00Z"
}
```

Validate:

- Resolve recipe theo `(skuId, formulaVersion, formulaKind)`. Thiếu ⇒ `ACTIVE_RECIPE_NOT_FOUND`.
- PILOT yêu cầu `anchorQuantityInput > 0` (đơn vị = `recipe.anchorUomCode`); thiếu ⇒ `PRODUCTION_ORDER_ANCHOR_QUANTITY_REQUIRED`.
- FIXED yêu cầu `batchSize > 0`.
- `formulaKind` ngoài enum ⇒ `FORMULA_KIND_INVALID`.

`ProductionOrderResponse` must include immutable `snapshotLines` và `formulaKindSnapshot`:

```json
{
  "productionOrderId": "uuid",
  "productionOrderNo": "PO-2026-0001",
  "skuId": "uuid",
  "formulaCode": "FML-A1-G1",
  "formulaVersion": "G1",
  "formulaKindSnapshot": "PILOT_PERCENT_BASED",
  "anchorIngredientIdSnapshot": "uuid",
  "anchorQuantityInput": 12.5,
  "anchorUomCodeSnapshot": "kg",
  "anchorRatioPercentSnapshot": 4.62,
  "totalBatchQuantity": 270.5,
  "batchSize": null,
  "productionOrderStatus": "OPEN",
  "snapshotLines": [
    {
      "recipeLineGroupCode": "SPECIAL_SKU_COMPONENT",
      "ingredientCode": "HRB_SAM_SAVIGIN",
      "ingredientDisplayName": "Sâm Savigin",
      "isAnchor": true,
      "ratioPercent": 4.62,
      "quantityPerBatch400": null,
      "snapshotQuantity": 12.5,
      "snapshotBasis": "PILOT_RATIO_OF_ANCHOR",
      "uomCode": "kg",
      "prepNote": "Thành phần đặc thù SKU",
      "usageRole": "SPECIAL_COMPONENT"
    }
  ]
}
```

FIXED branch tương ứng trả `formulaKindSnapshot = FIXED_QUANTITY_BATCH`, `batchSize = 400`, anchor fields NULL, mỗi line có `quantityPerBatch400`, `snapshotQuantity = quantityPerBatch400 * batchSize`, `snapshotBasis = FIXED_PER_BATCH_N`.

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

`QrGenerateResponse`

```json
{
  "items": [
    {
      "qrId": "uuid",
      "packagingUnitId": "uuid",
      "qrCode": "QR-2026-000001",
      "qrStatus": "GENERATED",
      "publicTraceEnabled": true
    }
  ]
}
```

`QrVoidRequest`

```json
{
  "reasonCode": "PRINTING_ERROR",
  "reasonText": "Void before replacement print",
  "voidedAt": "2026-04-27T12:30:00Z"
}
```

`QrResponse`

```json
{
  "qrId": "uuid",
  "packagingUnitId": "uuid",
  "qrCode": "QR-2026-000001",
  "qrStatus": "VOID",
  "publicTraceEnabled": false,
  "stateHistoryRef": "uuid"
}
```

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

`PrintJobCallbackRequest`

```json
{
  "deviceId": "PRINTER-001",
  "printJobId": "uuid",
  "callbackStatus": "PRINTED",
  "callbackAt": "2026-04-27T12:40:00Z",
  "deviceSequenceNo": "000123",
  "errorCode": null,
  "errorMessage": null
}
```

Device callback auth: endpoint `POST /api/admin/printing/jobs/{printJobId}/callback` must require `DEVICE_CALLBACK`, `X-Device-Id`, timestamp, nonce/idempotency key and HMAC-SHA256 signature over the canonical request body. Callback may update print/QR technical state only; it must not change QC, release, inventory, batch or trace business facts.

`PrintJobResponse`

```json
{
  "printJobId": "uuid",
  "packagingUnitId": "uuid",
  "qrId": "uuid",
  "printStatus": "PRINTED",
  "qrStatus": "PRINTED",
  "deviceId": "PRINTER-001",
  "stateHistoryRef": "uuid"
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

`PublicTracePublicResponse`

Explicit public DTO for `GET /api/public/trace/{qrCode}` and `GET /api/admin/trace/public-preview/{qrCode}`. This schema is whitelist-only, must be generated in OpenAPI with `additionalProperties = false`, and must not reuse `InternalTraceResponse`, `GenealogyTraceResponse`, admin DTOs, or ORM/entity shapes.

```json
{
  "schemaVersion": "public-trace.v1",
  "traceStatus": "VALID",
  "qr": {
    "qrStatusPublic": "PRINTED"
  },
  "product": {
    "productName": "Cháo Sâm - Diêm mạch & Hạt sen"
  },
  "batch": {
    "batchPublicCode": "BATCH-PUBLIC-20260427-001",
    "releasePublicStatus": "RELEASED"
  },
  "source": {
    "sourceZoneName": "Vùng trồng Sâm Savigin Lâm Đồng",
    "province": "Lâm Đồng",
    "ward": "Xã ...",
    "addressDetail": "Thông tin public đã duyệt"
  }
}
```

Allowed public fields are only the active `is_public = true` rows in `docs/software-specs/data/csv/public_trace_policy.csv`: `product_name`, `batch_public_code`, `qr_status_public`, `source_zone_name`, `province`, `ward`, `address_detail`, `release_public_status`, plus non-DB envelope fields `schemaVersion` and `traceStatus`.

Forbidden in public trace: `supplier_id`, `supplier_name`, supplier internal detail, `operator_user_id`, personnel names, costing, MISA ids, QC defect detail, loss/waste, raw ledger ids, `internal_batch_id`, `raw_material_lot_internal_code`, evidence URI/hash/original filename/storage path/scan payload, formula details, customer/order/shipment data. `producedAt` and `releasedAt` are not public fields until owner adds explicit whitelist rows to `public_trace_policy.csv`.

`RecallImpactRequest`

```json
{
  "traceQuery": {
    "batchId": "uuid"
  },
  "reasonText": "Suspected issue"
}
```

`RecallCapaResponse`

```json
{
  "capaId": "uuid",
  "recallCaseId": "uuid",
  "capaStatus": "OPEN",
  "ownerUserId": "uuid",
  "dueAt": "2026-04-30T00:00:00Z",
  "evidence": [
    {
      "evidenceId": "uuid",
      "evidenceType": "FIELD_PHOTO",
      "evidenceRef": "local://evidence/dev/recall-capa/capa-cleanup.jpg",
      "evidenceHash": "sha256:...",
      "mimeType": "image/jpeg",
      "fileSizeBytes": 184320,
      "originalFilename": "capa-cleanup.jpg",
      "scanStatus": "CLEAN",
      "createdAt": "2026-04-29T00:00:00Z"
    }
  ]
}
```

`EvidenceCreateRequest` is reused for `POST /api/admin/recall/capas/{capaId}/evidence`. CAPA evidence follows the same MIME/size/storage rules as source-origin evidence and is stored in `op_recall_capa_evidence`.

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
