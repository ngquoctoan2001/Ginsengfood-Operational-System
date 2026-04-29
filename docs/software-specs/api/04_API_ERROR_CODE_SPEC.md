# API Error Code Spec

> Mục đích: chuẩn hóa error code để frontend hiển thị đúng và QA test negative paths.

## 1. Error Shape

```json
{
  "error": {
    "code": "STATE_CONFLICT",
    "message": "The requested state transition is not allowed.",
    "details": [
      {
        "field": "status",
        "issue": "BATCH_NOT_RELEASED"
      }
    ],
    "correlationId": "req-..."
  }
}
```

## 2. Error Codes

| code                                        | HTTP    | Meaning                                                                                                                | Typical UI behavior                                       |
| ------------------------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `UNAUTHORIZED`                              | 401     | Missing/invalid token                                                                                                  | Redirect/login prompt.                                    |
| `FORBIDDEN`                                 | 403     | User lacks permission                                                                                                  | Disable action/show permission message.                   |
| `NOT_FOUND`                                 | 404     | Resource not found                                                                                                     | Not found state.                                          |
| `VALIDATION_FAILED`                         | 422     | Field validation failed                                                                                                | Show field errors.                                        |
| `DUPLICATE_KEY`                             | 409     | Unique constraint violation                                                                                            | Show duplicate message.                                   |
| `IDEMPOTENCY_CONFLICT`                      | 409     | Same key, different payload                                                                                            | Stop retry and show conflict.                             |
| `STATE_CONFLICT`                            | 409     | Invalid state transition                                                                                               | Refresh detail/state.                                     |
| `REASON_REQUIRED`                           | 422     | Reason missing for reject/hold/cancel/correction/reprint                                                               | Focus reason field.                                       |
| `APPROVAL_REQUIRED`                         | 422     | Action requires approval first                                                                                         | Link to approval request.                                 |
| `APPROVAL_POLICY_VIOLATION`                 | 403/422 | Approval actor/policy invalid                                                                                          | Show policy message.                                      |
| `SOURCE_ORIGIN_NOT_VERIFIED`                | 422     | `SELF_GROWN` source not verified                                                                                       | Block intake.                                             |
| `SUPPLIER_REQUIRED`                         | 422     | `PURCHASED` missing supplier                                                                                           | Focus supplier field.                                     |
| `SUPPLIER_INGREDIENT_NOT_ALLOWED`           | 422     | `(supplier_id, ingredient_id)` không có trong `op_supplier_ingredient_allowed` (HL-SUP-001 / BR-M03A-004 / BR-M06-006) | Block receipt; gợi ý liên hệ procurement bổ sung mapping. |
| `SUPPLIER_SUSPENDED`                        | 422     | Supplier `SUSPENDED` không tạo receipt mới (BR-M03A-002)                                                               | Block submit; show supplier status.                       |
| `SUPPLIER_HAS_OPEN_RECEIPT`                 | 409     | Suspend supplier khi có receipt còn OPEN (VAL-M03A-004)                                                                | Đóng/cancel receipt trước, hoặc dùng override.            |
| `DUPLICATE_SUPPLIER_INGREDIENT`             | 409     | Mapping `(supplier_id, ingredient_id, effective_from)` trùng (VAL-M03A-003)                                            | Show existing mapping; choose new effective date.         |
| `SUPPLIER_USER_INVALID_ROLE`                | 422     | Supplier user thiếu role `R-SUPPLIER` hoặc `supplier_id` không hợp lệ (VAL-M03A-002)                                   | Block create; chọn role đúng.                             |
| `WEAK_PASSWORD`                             | 422     | Password supplier user không đạt policy HL-SUP-007 (min 12 ký tự, mixed case + digit + symbol)                         | Show password rule; require stronger password.            |
| `SUPPLIER_SCOPE_VIOLATION`                  | 403     | Supplier user truy cập resource ngoài `supplier_id` của session (HL-SUP-007 / BR-M03A-005 / BR-M06-014)                | Trả 403 không leak detail; redirect supplier portal home. |
| `SUPPLIER_EDIT_LOCKED_AFTER_CONFIRMED`      | 409     | Edit receipt sau supplier confirm hoặc supplier-submit ở `PENDING_RECEIVE` (HL-SUP-002 / BR-M06-007)                   | Block edit; gợi ý tạo correction/feedback.                |
| `SUPPLIER_DECLINED_BLOCKED`                 | 409     | Tác động lên receipt đã `SUPPLIER_DECLINED` (HL-SUP-003 / BR-M06-008)                                                  | Block; tạo receipt mới nếu cần.                           |
| `RECEIPT_LOCKED_AFTER_RECEIVE`              | 409     | Edit quantity/ingredient sau khi receipt `RECEIVED` (HL-SUP-004 / BR-M06-009)                                          | Block edit; chỉ cho accept/reject/return/close.           |
| `SUPPLIER_EVIDENCE_REQUIRED`                | 422     | Receive khi policy yêu cầu evidence trước nhưng chưa có evidence `CLEAN` (HL-SUP-005 / BR-M06-010)                     | Block receive; focus evidence uploader.                   |
| `LOT_QUANTITY_EXCEEDS_RECEIVED`             | 422     | Sum(lot quantity per line) vượt `received_quantity` của line (HL-SUP-006 / BR-M06-012)                                 | Block receive; điều chỉnh lot quantity.                   |
| `RECEIPT_QUANTITY_INVARIANT_FAILED`         | 422     | Sum(received + rejected + returned) per line ≠ expected khi close (HL-SUP-006 / BR-M06-013)                            | Block close; show line invariant detail.                  |
| `NON_OPERATIONAL_RECIPE_VERSION`            | 422     | Non-operational recipe version attempted in operational flow                                                           | Block and report hard lock.                               |
| `INVALID_RECIPE_GROUP`                      | 422     | Recipe group not one of four required groups                                                                           | Focus recipe line.                                        |
| `RECIPE_INCOMPLETE`                         | 422     | Missing recipe lines/required ingredient                                                                               | Show readiness checklist.                                 |
| `ACTIVE_RECIPE_NOT_FOUND`                   | 422     | SKU has no active approved recipe                                                                                      | Block PO.                                                 |
| `ACTIVE_RECIPE_CONFLICT`                    | 409     | Multiple/overlap active recipe version                                                                                 | Admin intervention.                                       |
| `SNAPSHOT_INCOMPLETE`                       | 422     | PO snapshot missing required fields                                                                                    | Block PO/print.                                           |
| `FORMULA_KIND_INVALID`                      | 422     | `formula_kind` ngoài `{PILOT_PERCENT_BASED, FIXED_QUANTITY_BATCH}` hoặc không khớp `formula_version` snapshot          | Block recipe/PO; show enum hint.                          |
| `RECIPE_ANCHOR_REQUIRED`                    | 422     | PILOT recipe thiếu anchor metadata hoặc thiếu line `is_anchor = true` trùng anchor                                     | Focus anchor fields/anchor line.                          |
| `RECIPE_ANCHOR_DUPLICATE`                   | 422     | PILOT recipe có nhiều hơn 1 line `is_anchor = true` hoặc anchor line không trùng `recipe.anchor_ingredient_id`         | Show duplicate anchor; chỉ 1 line.                        |
| `RECIPE_RATIO_SUM_INVALID`                  | 422     | PILOT recipe `SUM(ratio_percent)` ngoài `[99.95, 100.05]`                                                              | Show running SUM và delta trên form.                      |
| `PRODUCTION_ORDER_ANCHOR_QUANTITY_REQUIRED` | 422     | PILOT PO thiếu `anchorQuantityInput > 0` hoặc đơn vị sai                                                               | Focus anchor input; hiển thị UOM đúng.                    |
| `OUTSIDE_SNAPSHOT_MATERIAL`                 | 422     | Material not in PO snapshot                                                                                            | Require exception approval.                               |
| `RAW_MATERIAL_LOT_NOT_READY`                | 422     | Raw material lot is not `READY_FOR_PRODUCTION`; `QC_PASS` alone is insufficient for issue                              | Select/mark a ready lot.                                  |
| `RAW_MATERIAL_LOT_QC_NOT_PASSED`            | 422     | Raw material lot cannot be marked ready because QC result is not `QC_PASS`                                             | Send lot to QC or select another lot.                     |
| `LOT_QUARANTINED`                           | 422     | Raw material lot is quarantined and cannot be issued                                                                   | Show quarantine/hold detail.                              |
| `INSUFFICIENT_BALANCE`                      | 422     | Not enough inventory                                                                                                   | Show balance detail.                                      |
| `VARIANCE_REASON_REQUIRED`                  | 422     | Receipt variance missing reason                                                                                        | Focus variance reason.                                    |
| `EVIDENCE_REQUIRED`                         | 422     | Evidence required trước khi verify/close (M05 source origin verification, M13 CAPA close)                              | Block submit; focus evidence uploader.                    |
| `EVIDENCE_MIME_NOT_ALLOWED`                 | 422     | MIME type của evidence file ngoài allowlist (`image/jpeg`,`image/png`,`image/webp`,`video/mp4`,`video/quicktime`)      | Show MIME allowlist; reject upload.                       |
| `EVIDENCE_FILE_TOO_LARGE`                   | 422     | Evidence file vượt size cap (image ≤10MB, video ≤100MB)                                                                | Show size cap theo MIME; reject upload.                   |
| `EVIDENCE_SCAN_PENDING`                     | 422     | Evidence đã upload nhưng antivirus/malware scan chưa hoàn tất; chưa được dùng để verify/close                          | Show pending scan state; retry later.                     |
| `EVIDENCE_SCAN_FAILED`                      | 422     | Evidence scan lỗi hoặc không có kết quả scan tin cậy                                                                   | Show retry scan/upload action.                            |
| `EVIDENCE_MALWARE_DETECTED`                 | 422     | Evidence scan phát hiện malware/virus                                                                                  | Reject evidence; require replacement.                     |
| `PROCESS_STEP_ORDER_INVALID`                | 409     | Process step order violated                                                                                            | Show required previous step.                              |
| `INVALID_PACKAGING_LEVEL`                   | 422     | Packaging level not in `PACKET` (cấp 1, gói nhỏ), `BOX` (cấp 2, hộp), `CARTON` (cấp 2.1, thùng — optional)             | Correct level.                                            |
| `CARTON_PACKAGING_NOT_CONFIGURED`           | 422     | Người dùng yêu cầu đóng `CARTON` nhưng `op_trade_item.boxes_per_carton` của SKU/trade item NULL hoặc ≤ 0               | Yêu cầu cấu hình quy cách thùng trước khi tạo CARTON job. |
| `GTIN_REQUIRED`                             | 422     | Commercial print requires GTIN                                                                                         | Link GTIN config.                                         |
| `GTIN_MAPPING_MISSING`                      | 422     | Trade item has no active GTIN mapping for commercial print                                                             | Link trade item GTIN config.                              |
| `DUPLICATE_GTIN`                            | 409     | GTIN already used                                                                                                      | Show duplicate GTIN.                                      |
| `PRINT_TRADE_ITEM_BARCODE_CONFLICT`         | 409     | Trade item would receive more than one commercial barcode                                                              | Block print/config change.                                |
| `QR_INVALID_STATE`                          | 409     | QR transition not allowed                                                                                              | Refresh QR state.                                         |
| `QR_INVALID`                                | 404/422 | Public QR invalid                                                                                                      | Safe public invalid message.                              |
| `QR_NOT_PUBLIC`                             | 404/422 | QR state not public-trace eligible                                                                                     | Safe public invalid message.                              |
| `QC_NOT_PASS`                               | 422     | Release attempted without QC pass                                                                                      | Block release.                                            |
| `HOLD_ACTIVE`                               | 409     | Object has active hold                                                                                                 | Show hold reason/status.                                  |
| `BATCH_NOT_RELEASED`                        | 422     | Warehouse receipt before release                                                                                       | Block receipt.                                            |
| `BATCH_SCAN_REQUIRED`                       | 422     | Warehouse/QC operation requires batch/QR/barcode scan before confirmation                                              | Focus scan input.                                         |
| `TRACE_GAP_DETECTED`                        | 422     | Blocking trace chain gap in state-changing command                                                                     | Show gap warning; block command.                          |
| `RECOVERY_OPEN`                             | 409     | Recall close with open recovery item                                                                                   | Show open items.                                          |
| `CAPA_REQUIRED`                             | 422     | Recall close requires CAPA                                                                                             | Show CAPA form.                                           |
| `RECALL_RESIDUAL_RISK_NOTE_REQUIRED`        | 422     | `CLOSED_WITH_RESIDUAL_RISK` close type requires residual note                                                          | Focus residual note field.                                |
| `MISA_MAPPING_MISSING`                      | 422     | MISA sync lacks mapping                                                                                                | Move to reconcile/mapping UI.                             |
| `RECONCILE_NOT_REQUIRED`                    | 409     | Reconcile action not applicable                                                                                        | Refresh sync status.                                      |
| `OVERRIDE_EXPIRED`                          | 403     | Override or break-glass activation expired                                                                             | Require a new approval/activation.                        |
| `UPSTREAM_UNAVAILABLE`                      | 503     | External service unavailable                                                                                           | Retry later.                                              |

## 3. Public Trace Error Policy

- Public trace errors must not reveal internal QR state reason, supplier, personnel, QC defects, MISA data, or ledger ids.
- Public response for invalid/void/failed QR should use safe message and `correlationId`.
- Trace query endpoints may return `200` with structured `gaps[]` in the response body. State-changing commands such as recall close must return `422 TRACE_GAP_DETECTED` when policy says unresolved gaps block the action.
