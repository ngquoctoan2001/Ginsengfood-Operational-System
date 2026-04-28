# Enum Reference

> Mục đích: chuẩn hóa enum/state values dùng trong DB/API/UI/workflow. Lưu dạng `text` + `CHECK` constraint, không dùng native enum để migration linh hoạt.

## 1. Quality / Release

| enum_name | Values | Applies to |
| --- | --- | --- |
| `qc_status` | `PENDING_QC`, `QC_PASS`, `QC_HOLD`, `QC_REJECT` | raw lot, raw QC, QC inspection |
| `qc_result` | `QC_PASS`, `QC_HOLD`, `QC_REJECT` | `op_qc_inspection`, `op_raw_material_qc_inspection` |
| `release_status` | `PENDING`, `APPROVED_RELEASED`, `REJECTED`, `REVOKED` | `op_batch_release` |
| `lot_status` | `CREATED`, `IN_QC`, `ON_HOLD`, `REJECTED`, `READY_FOR_PRODUCTION`, `CONSUMED`, `EXPIRED`, `QUARANTINED` | `op_raw_material_lot` |
| `batch_status` | `CREATED`, `IN_PROCESS`, `PACKAGED`, `QC_PENDING`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`, `RELEASED`, `BLOCKED`, `CLOSED` | `op_batch` |

Rule: `QC_PASS` không bằng `RELEASED`; chỉ `op_batch_release.release_status = APPROVED_RELEASED` mới làm batch eligible cho warehouse receipt.

Rule: raw material `QC_PASS` không bằng `READY_FOR_PRODUCTION`; material issue chỉ được chọn `op_raw_material_lot.lot_status = READY_FOR_PRODUCTION`.

## 2. Recipe / SKU

| enum_name | Values | Applies to |
| --- | --- | --- |
| `sku_status` | `ACTIVE`, `INACTIVE` | `ref_sku` |
| `sku_type` | `VEGAN`, `SAVORY` | `ref_sku`, `op_production_recipe` |
| `recipe_line_group_code` | `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR` | recipe lines, PO snapshot |
| `formula_status` | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `ACTIVE_OPERATIONAL`, `RETIRED`, `REJECTED` | `op_production_recipe` |
| `formula_version` | Extensible values such as `G1`, future `G2`, `G3`, ... | `op_production_recipe`, PO snapshot |

Rule: `formula_version` không phải CHECK-constrained enum cố định; DB chỉ chặn G0/research baseline khỏi `APPROVED` và `ACTIVE_OPERATIONAL`, còn version hợp lệ được validate bằng approved recipe version registry.

Rule: G0 research/baseline formula version không được dùng trong operational seed/PO/material issue/trace/recall.

## 3. Source / Raw Material

| enum_name | Values | Applies to |
| --- | --- | --- |
| `procurement_type` | `SELF_GROWN`, `PURCHASED` | `op_raw_material_lot` |
| `source_origin_status` | `DRAFT`, `SUBMITTED`, `VERIFIED`, `REJECTED`, `SUSPENDED` | `op_source_origin` |
| `receipt_status` | `DRAFT`, `CONFIRMED`, `CANCELLED`, `CORRECTED` | receipt tables |
| `material_request_status` | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `REJECTED`, `CANCELLED` | `op_material_request` |
| `material_issue_status` | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `EXECUTED`, `ON_HOLD`, `CANCELLED`, `REVERSED` | `op_material_issue` |

Rule: raw inventory ledger debit chỉ ghi khi `op_material_issue.issue_status` chuyển sang `EXECUTED`; `APPROVED` chưa phải decrement point.

## 4. Production / Packaging / QR

| enum_name | Values | Applies to |
| --- | --- | --- |
| `production_order_status` | `DRAFT`, `OPEN`, `APPROVED`, `IN_PROGRESS`, `ON_HOLD`, `CANCELLED`, `COMPLETED`, `CLOSED` | `op_production_order` |
| `work_order_status` | `DRAFT`, `READY`, `IN_PROGRESS`, `ON_HOLD`, `COMPLETED`, `CANCELLED` | `op_work_order` |
| `process_step` | `PREPROCESSING`, `FREEZING`, `FREEZE_DRYING` | `op_production_process_event` |
| `process_status` | `NOT_STARTED`, `IN_PROGRESS`, `DONE`, `HALTED`, `REJECTED`, `CORRECTED` | process events |
| `packaging_level` | `BOX`, `CARTON` | trade item, packaging unit |
| `packaging_status` | `DRAFT`, `READY`, `IN_PROGRESS`, `COMPLETED`, `HALTED`, `CANCELLED` | `op_packaging_job` |
| `print_status` | `DRAFT`, `QUEUED`, `PRINTING`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED` | `op_print_job` |
| `qr_status` | `GENERATED`, `QUEUED`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED` | `op_qr_registry`, `op_qr_state_history` |

Rule: `process_step` mô tả công đoạn; `process_status` mô tả trạng thái thực thi của công đoạn. `HALTED` là `process_status`, không phải `process_step`.

## 5. Warehouse / Inventory

| enum_name | Values | Applies to |
| --- | --- | --- |
| `warehouse_type` | `RAW_MATERIAL`, `FINISHED_GOODS` | `op_warehouse` |
| `ledger_direction` | `DEBIT`, `CREDIT`, `REVERSAL`, `ADJUSTMENT` | `op_inventory_ledger` |
| `ledger_source_type` | `RAW_RECEIPT`, `MATERIAL_ISSUE`, `WAREHOUSE_RECEIPT`, `INVENTORY_ADJUSTMENT`, `RECALL_RECOVERY`, `REVERSAL` | `op_inventory_ledger` |
| `balance_status` | `AVAILABLE`, `HOLD`, `RESERVED`, `CONSUMED`, `REJECTED` | `op_inventory_lot_balance` |
| `allocation_status` | `RESERVED`, `CONFIRMED`, `RELEASED`, `CANCELLED` | `op_inventory_allocation` |

## 6. Trace / Recall / Integration / UI

| enum_name | Values | Applies to |
| --- | --- | --- |
| `trace_link_type` | `SOURCE_TO_RAW_LOT`, `RAW_LOT_TO_ISSUE`, `ISSUE_TO_BATCH`, `BATCH_TO_PACKAGING`, `PACKAGING_TO_QR`, `BATCH_TO_WAREHOUSE`, `WAREHOUSE_TO_SHIPMENT`, `BATCH_TO_RECALL` | `op_trace_link` |
| `recall_status` | `OPEN`, `IMPACT_ANALYSIS`, `HOLD_ACTIVE`, `SALE_LOCK_ACTIVE`, `NOTIFICATION_SENT`, `RECOVERY`, `DISPOSITION`, `CAPA`, `CLOSED`, `CLOSED_WITH_RESIDUAL_RISK`, `CANCELLED` | `op_recall_case` |
| `hold_status` | `ACTIVE`, `RELEASED`, `CANCELLED` | `op_batch_hold_registry` |
| `sale_lock_status` | `ACTIVE`, `RELEASED`, `CANCELLED` | `op_sale_lock_registry` |
| `misa_sync_status` | `PENDING`, `MAPPED`, `SYNCING`, `SYNCED`, `FAILED_RETRYABLE`, `FAILED_NEEDS_REVIEW`, `RECONCILED` | MISA tables |
| `outbox_status` | `PENDING`, `DISPATCHING`, `DISPATCHED`, `FAILED_RETRYABLE`, `FAILED_DEAD_LETTER`, `ACKNOWLEDGED`, `MANUAL_RETRY` | `outbox_event` |
| `approval_status` | `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED` | approval tables |
| `source_channel` | `ADMIN_WEB`, `PWA`, `PUBLIC_API`, `SYSTEM`, `INTEGRATION` | audit/state/action logs |


