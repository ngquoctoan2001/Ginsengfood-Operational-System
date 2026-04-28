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

| code | HTTP | Meaning | Typical UI behavior |
| --- | --- | --- | --- |
| `UNAUTHORIZED` | 401 | Missing/invalid token | Redirect/login prompt. |
| `FORBIDDEN` | 403 | User lacks permission | Disable action/show permission message. |
| `NOT_FOUND` | 404 | Resource not found | Not found state. |
| `VALIDATION_FAILED` | 422 | Field validation failed | Show field errors. |
| `DUPLICATE_KEY` | 409 | Unique constraint violation | Show duplicate message. |
| `IDEMPOTENCY_CONFLICT` | 409 | Same key, different payload | Stop retry and show conflict. |
| `STATE_CONFLICT` | 409 | Invalid state transition | Refresh detail/state. |
| `REASON_REQUIRED` | 422 | Reason missing for reject/hold/cancel/correction/reprint | Focus reason field. |
| `APPROVAL_REQUIRED` | 422 | Action requires approval first | Link to approval request. |
| `APPROVAL_POLICY_VIOLATION` | 403/422 | Approval actor/policy invalid | Show policy message. |
| `SOURCE_ORIGIN_NOT_VERIFIED` | 422 | `SELF_GROWN` source not verified | Block intake. |
| `SUPPLIER_REQUIRED` | 422 | `PURCHASED` missing supplier | Focus supplier field. |
| `NON_OPERATIONAL_RECIPE_VERSION` | 422 | Non-operational recipe version attempted in operational flow | Block and report hard lock. |
| `INVALID_RECIPE_GROUP` | 422 | Recipe group not one of four required groups | Focus recipe line. |
| `RECIPE_INCOMPLETE` | 422 | Missing recipe lines/required ingredient | Show readiness checklist. |
| `ACTIVE_RECIPE_NOT_FOUND` | 422 | SKU has no active approved recipe | Block PO. |
| `ACTIVE_RECIPE_CONFLICT` | 409 | Multiple/overlap active recipe version | Admin intervention. |
| `SNAPSHOT_INCOMPLETE` | 422 | PO snapshot missing required fields | Block PO/print. |
| `OUTSIDE_SNAPSHOT_MATERIAL` | 422 | Material not in PO snapshot | Require exception approval. |
| `RAW_MATERIAL_LOT_NOT_READY` | 422 | Raw material lot is not `READY_FOR_PRODUCTION`; `QC_PASS` alone is insufficient for issue | Select/mark a ready lot. |
| `RAW_MATERIAL_LOT_QC_NOT_PASSED` | 422 | Raw material lot cannot be marked ready because QC result is not `QC_PASS` | Send lot to QC or select another lot. |
| `LOT_QUARANTINED` | 422 | Raw material lot is quarantined and cannot be issued | Show quarantine/hold detail. |
| `INSUFFICIENT_BALANCE` | 422 | Not enough inventory | Show balance detail. |
| `VARIANCE_REASON_REQUIRED` | 422 | Receipt variance missing reason | Focus variance reason. |
| `PROCESS_STEP_ORDER_INVALID` | 409 | Process step order violated | Show required previous step. |
| `INVALID_PACKAGING_LEVEL` | 422 | Packaging level not BOX/CARTON | Correct level. |
| `GTIN_REQUIRED` | 422 | Commercial print requires GTIN | Link GTIN config. |
| `GTIN_MAPPING_MISSING` | 422 | Trade item has no active GTIN mapping for commercial print | Link trade item GTIN config. |
| `DUPLICATE_GTIN` | 409 | GTIN already used | Show duplicate GTIN. |
| `PRINT_TRADE_ITEM_BARCODE_CONFLICT` | 409 | Trade item would receive more than one commercial barcode | Block print/config change. |
| `QR_INVALID_STATE` | 409 | QR transition not allowed | Refresh QR state. |
| `QR_INVALID` | 404/422 | Public QR invalid | Safe public invalid message. |
| `QR_NOT_PUBLIC` | 404/422 | QR state not public-trace eligible | Safe public invalid message. |
| `QC_NOT_PASS` | 422 | Release attempted without QC pass | Block release. |
| `HOLD_ACTIVE` | 409 | Object has active hold | Show hold reason/status. |
| `BATCH_NOT_RELEASED` | 422 | Warehouse receipt before release | Block receipt. |
| `BATCH_SCAN_REQUIRED` | 422 | Warehouse/QC operation requires batch/QR/barcode scan before confirmation | Focus scan input. |
| `TRACE_GAP_DETECTED` | 422 | Blocking trace chain gap in state-changing command | Show gap warning; block command. |
| `RECOVERY_OPEN` | 409 | Recall close with open recovery item | Show open items. |
| `CAPA_REQUIRED` | 422 | Recall close requires CAPA | Show CAPA form. |
| `RECALL_RESIDUAL_RISK_NOTE_REQUIRED` | 422 | `CLOSED_WITH_RESIDUAL_RISK` close type requires residual note | Focus residual note field. |
| `MISA_MAPPING_MISSING` | 422 | MISA sync lacks mapping | Move to reconcile/mapping UI. |
| `RECONCILE_NOT_REQUIRED` | 409 | Reconcile action not applicable | Refresh sync status. |
| `OVERRIDE_EXPIRED` | 403 | Override or break-glass activation expired | Require a new approval/activation. |
| `UPSTREAM_UNAVAILABLE` | 503 | External service unavailable | Retry later. |

## 3. Public Trace Error Policy

- Public trace errors must not reveal internal QR state reason, supplier, personnel, QC defects, MISA data, or ledger ids.
- Public response for invalid/void/failed QR should use safe message and `correlationId`.
- Trace query endpoints may return `200` with structured `gaps[]` in the response body. State-changing commands such as recall close must return `422 TRACE_GAP_DETECTED` when policy says unresolved gaps block the action.
