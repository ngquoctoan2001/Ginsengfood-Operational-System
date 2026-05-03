# Enum Reference

> Mục đích: chuẩn hóa enum/state values dùng trong DB/API/UI/workflow. Lưu dạng `text` + `CHECK` constraint, không dùng native enum để migration linh hoạt.

## 1. Quality / Release

| enum_name        | Values                                                                                                                | Applies to                                          |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| `qc_status`      | `PENDING_QC`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`                                                                       | raw lot, raw QC, QC inspection                      |
| `qc_result`      | `QC_PASS`, `QC_HOLD`, `QC_REJECT`                                                                                     | `op_qc_inspection`, `op_raw_material_qc_inspection` |
| `release_status` | `PENDING`, `APPROVED_RELEASED`, `REJECTED`, `REVOKED`                                                                 | `op_batch_release`                                  |
| `lot_status`     | `CREATED`, `IN_QC`, `ON_HOLD`, `REJECTED`, `READY_FOR_PRODUCTION`, `CONSUMED`, `EXPIRED`, `QUARANTINED`               | `op_raw_material_lot`                               |
| `batch_status`   | `CREATED`, `IN_PROCESS`, `PACKAGED`, `QC_PENDING`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`, `RELEASED`, `BLOCKED`, `CLOSED` | `op_batch`                                          |

Rule: `QC_PASS` không bằng `RELEASED`; chỉ `op_batch_release.release_status = APPROVED_RELEASED` mới làm batch eligible cho warehouse receipt.

Rule: raw material `QC_PASS` không bằng `READY_FOR_PRODUCTION`; material issue chỉ được chọn `op_raw_material_lot.lot_status = READY_FOR_PRODUCTION`.

## 2. Recipe / SKU

| enum_name                | Values                                                                                                         | Applies to                          |
| ------------------------ | -------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `sku_status`             | `ACTIVE_BASELINE`, `ACTIVE`, `INACTIVE`                                                                        | `ref_sku`                           |
| `sku_type`               | `VEGAN`, `SAVORY`                                                                                              | `ref_sku`, `op_production_recipe`   |
| `recipe_line_group_code` | `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`                                 | recipe lines, PO snapshot           |
| `formula_status`         | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `APPROVED_SEED_BASELINE`, `ACTIVE_OPERATIONAL`, `RETIRED`, `REJECTED` | `op_production_recipe`              |
| `formula_version`        | Extensible values such as `G1`, future `G2`, `G3`, ...                                                         | `op_production_recipe`, PO snapshot |
| `formula_kind`           | `PILOT_PERCENT_BASED`, `FIXED_QUANTITY_BATCH`                                                                  | `op_production_recipe`, PO snapshot |
| `snapshot_basis`         | `PILOT_RATIO_OF_ANCHOR`, `FIXED_PER_BATCH_N`                                                                   | `op_production_order_item`          |

Rule: `formula_version` không phải CHECK-constrained enum cố định; DB chỉ chặn G0/research baseline khỏi `APPROVED`, `APPROVED_SEED_BASELINE` và `ACTIVE_OPERATIONAL`, còn version hợp lệ được validate bằng approved recipe version registry.

Rule: `sku_status = ACTIVE_BASELINE` là trạng thái canonical seed/bootstrap (20 SKU baseline post-bootstrap); `ACTIVE` dùng cho SKU phát sinh sau go-live qua quy trình approval thông thường; `INACTIVE` ngừng kinh doanh/sản xuất. Seed validation (xem `data/04_SEED_VALIDATION_QUERIES.md` SV-001) đếm `ACTIVE_BASELINE` = 20.

Rule: `formula_status = APPROVED_SEED_BASELINE` là trạng thái pre-go-live của recipe được seed canonical (G1 PILOT) chờ activation; `ACTIVE_OPERATIONAL` là trạng thái post-activation thực sự dùng cho production. Seed có thể tạo recipe ở `APPROVED_SEED_BASELINE` HOẶC `ACTIVE_OPERATIONAL`; ràng buộc unique-active per `(sku_id, formula_kind)` chỉ áp cho `ACTIVE_OPERATIONAL` (xem `database/05_INDEX_CONSTRAINT_REFERENCE.md` UQ-RECIPE-ACTIVE-KIND). Cả hai đều bị chặn khỏi `formula_version = G0`.

Rule: G0 research/baseline formula version không được dùng trong operational seed/PO/material issue/trace/recall.

Rule: `formula_kind` xác định mô hình tính lượng nguyên liệu. `PILOT_PERCENT_BASED` (mặc định cho G1 giai đoạn pilot) yêu cầu recipe có đúng 1 anchor ingredient và `SUM(ratio_percent) ∈ [99.95, 100.05]`; snapshot quantity per line tính bằng `ratio_percent / 100 × total_batch_quantity`, với `total_batch_quantity = anchor_quantity_input × 100 / anchor_ratio_percent`. `FIXED_QUANTITY_BATCH` (mặc định cho G2 giai đoạn production) dùng `quantity_per_batch_400` cố định cho mẻ chuẩn 400; snapshot quantity = `quantity_per_batch_400 × số mẻ`.

Rule: G1 (`PILOT_PERCENT_BASED`) và G2 (`FIXED_QUANTITY_BATCH`) có thể cùng `ACTIVE_OPERATIONAL` cho cùng 1 SKU trong giai đoạn chuyển giao pilot → production; planner phải chọn rõ `formula_version` + `formula_kind` khi tạo Production Order. Hard lock 1-active-per-SKU cũ được nới thành 1-active-per-`(sku_id, formula_kind)`.

Rule: `snapshot_basis` của mỗi `op_production_order_item` phải khớp `formula_kind_snapshot` của PO (PILOT ⇒ `PILOT_RATIO_OF_ANCHOR`, FIXED ⇒ `FIXED_PER_BATCH_N`).

## 3. Source / Raw Material

| enum_name                       | Values                                                                                                                                                                             | Applies to                                                                                        |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `procurement_type`              | `SELF_GROWN`, `PURCHASED`                                                                                                                                                          | `op_raw_material_lot`, `op_raw_material_receipt`                                                  |
| `source_origin_status`          | `DRAFT`, `SUBMITTED`, `VERIFIED`, `REJECTED`, `SUSPENDED`                                                                                                                          | `op_source_origin`                                                                                |
| `receipt_status`                | `DRAFT`, `CONFIRMED`, `CANCELLED`, `CORRECTED`                                                                                                                                     | receipt tables (legacy generic)                                                                   |
| `raw_receipt_status`            | `DRAFT`, `WAITING_DELIVERY`, `DELIVERED_PENDING_RECEIPT`, `RECEIVED_PENDING_QC`, `QC_IN_PROGRESS`, `ACCEPTED`, `PARTIALLY_ACCEPTED`, `REJECTED`, `RETURNED`, `CANCELLED`, `CLOSED` | `op_raw_material_receipt`                                                                         |
| `supplier_collaboration_status` | `NOT_REQUIRED`, `PENDING_SUPPLIER_CONFIRMATION`, `EVIDENCE_REQUIRED`, `SUPPLIER_SUBMITTED`, `SUPPLIER_CONFIRMED`, `SUPPLIER_DECLINED`, `SUPPLIER_CANCELLED`                        | `op_raw_material_receipt`                                                                         |
| `lot_qc_status`                 | `PENDING_QC`, `IN_QC`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`                                                                                                                           | `op_raw_material_lot` (khởi tạo `PENDING_QC` khi action `receive`)                                |
| `created_by_party`              | `COMPANY`, `SUPPLIER`                                                                                                                                                              | `op_raw_material_receipt`, `op_raw_material_receipt_evidence`, `op_raw_material_receipt_feedback` |
| `feedback_type`                 | `QUALITY_ISSUE`, `DELIVERY_LATE`, `DELIVERY_EARLY`, `QUANTITY_VARIANCE`, `DOCUMENTATION_INCOMPLETE`, `PACKAGING_DAMAGE`, `TEMPERATURE_BREACH`, `OTHER`                             | `op_raw_material_receipt_feedback`                                                                |
| `user_type`                     | `INTERNAL_USER`, `SUPPLIER_USER`                                                                                                                                                   | `auth_user` (extension); `SUPPLIER_USER` bắt buộc gắn `supplier_id`, dùng role `R-SUPPLIER`       |
| `material_request_status`       | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `REJECTED`, `CANCELLED`                                                                                                                   | `op_material_request`                                                                             |
| `material_issue_status`         | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `EXECUTED`, `ON_HOLD`, `CANCELLED`, `REVERSED`                                                                                            | `op_material_issue`                                                                               |

Rule: `raw_receipt_status` × `supplier_collaboration_status` là 2 trục độc lập trên cùng `op_raw_material_receipt`. `SELF_GROWN` luôn `supplier_collaboration_status = NOT_REQUIRED`.

Rule: `lot_qc_status` là trục QC của raw material lot, tách khỏi `lot_status` (lifecycle). Lot được tạo khi `op_raw_material_receipt.raw_receipt_status` chuyển sang `RECEIVED_PENDING_QC` với khởi tạo `lot_status = CREATED` + `lot_qc_status = PENDING_QC`. `QC_PASS` chưa usable; phải qua `RAW_LOT_MARK_READY` để chuyển `lot_status = READY_FOR_PRODUCTION`.

Rule: `ON_HOLD` và `QUARANTINED` không đồng nghĩa. `ON_HOLD` là operational/investigation hold nội bộ, có thể release sau review/audit. `QUARANTINED` là safety/legal isolation mạnh hơn, mặc định block material issue và cần disposition hoặc quarantine-release approval riêng trước khi quay về trạng thái usable.

Rule: `created_by_party = SUPPLIER` chỉ hợp lệ khi `procurement_type = PURCHASED` và `supplier_id` khớp account của user; supplier không được set `procurement_type = SELF_GROWN`.

Rule: raw inventory ledger debit chỉ ghi khi `op_material_issue.issue_status` chuyển sang `EXECUTED`; `APPROVED` chưa phải decrement point.

## 4. Production / Packaging / QR

| enum_name                 | Values                                                                                    | Applies to                                                           |
| ------------------------- | ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `production_order_status` | `DRAFT`, `OPEN`, `APPROVED`, `IN_PROGRESS`, `ON_HOLD`, `CANCELLED`, `COMPLETED`, `CLOSED` | `op_production_order`                                                |
| `work_order_status`       | `DRAFT`, `READY`, `IN_PROGRESS`, `ON_HOLD`, `COMPLETED`, `CANCELLED`                      | `op_work_order`                                                      |
| `process_step`            | `PREPROCESSING`, `FREEZING`, `FREEZE_DRYING`                                              | `op_production_process_event`                                        |
| `process_status`          | `NOT_STARTED`, `IN_PROGRESS`, `DONE`, `HALTED`, `REJECTED`, `CORRECTED`                   | process events                                                       |
| `packaging_level`         | `PACKET`, `BOX`, `CARTON`                                                                 | trade item, packaging unit, packaging job, packaging config          |
| `identifier_type`         | `GTIN_13`, `GTIN_14`, `SSCC`, `INTERNAL_BARCODE`                                          | `op_trade_item_gtin` (recommended rename `op_trade_item_identifier`) |
| `packaging_status`        | `DRAFT`, `READY`, `IN_PROGRESS`, `COMPLETED`, `HALTED`, `CANCELLED`                       | `op_packaging_job`                                                   |
| `print_status`            | `DRAFT`, `QUEUED`, `PRINTING`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED`                   | `op_print_job`                                                       |
| `qr_status`               | `GENERATED`, `QUEUED`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED`                           | `op_qr_registry`, `op_qr_state_history`                              |

Rule: `process_step` mô tả công đoạn; `process_status` mô tả trạng thái thực thi của công đoạn. `HALTED` là `process_status`, không phải `process_step`.

## 5. Warehouse / Inventory

| enum_name            | Values                                                                                                      | Applies to                 |
| -------------------- | ----------------------------------------------------------------------------------------------------------- | -------------------------- |
| `warehouse_type`     | `RAW_MATERIAL`, `FINISHED_GOODS`                                                                            | `op_warehouse`             |
| `ledger_direction`   | `DEBIT`, `CREDIT`, `REVERSAL`, `ADJUSTMENT`                                                                 | `op_inventory_ledger`      |
| `ledger_source_type` | `RAW_RECEIPT`, `MATERIAL_ISSUE`, `WAREHOUSE_RECEIPT`, `INVENTORY_ADJUSTMENT`, `RECALL_RECOVERY`, `REVERSAL` | `op_inventory_ledger`      |
| `balance_status`     | `AVAILABLE`, `HOLD`, `RESERVED`, `CONSUMED`, `REJECTED`                                                     | `op_inventory_lot_balance` |
| `allocation_status`  | `RESERVED`, `CONFIRMED`, `RELEASED`, `CANCELLED`                                                            | `op_inventory_allocation`  |

## 6. Trace / Recall / Integration / UI

| enum_name              | Values                                                                                                                                                                   | Applies to                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| `trace_link_type`      | `SOURCE_TO_RAW_LOT`, `RAW_LOT_TO_ISSUE`, `ISSUE_TO_BATCH`, `BATCH_TO_PACKAGING`, `PACKAGING_TO_QR`, `BATCH_TO_WAREHOUSE`, `WAREHOUSE_TO_SHIPMENT`, `BATCH_TO_RECALL`     | `op_trace_link`                                                                            |
| `recall_status`        | `OPEN`, `IMPACT_ANALYSIS`, `HOLD_ACTIVE`, `SALE_LOCK_ACTIVE`, `NOTIFICATION_REQUESTED`, `RECOVERY`, `DISPOSITION`, `CAPA`, `CLOSED`, `CLOSED_WITH_RESIDUAL_RISK`, `CANCELLED` | `op_recall_case`                                                                           |
| `capa_status`          | `OPEN`, `IN_PROGRESS`, `EVIDENCE_PENDING`, `REVIEW_PENDING`, `CLOSED`, `REJECTED`                                                                                       | `op_recall_capa`                                                                           |
| `capa_close_gate`      | `EVIDENCE_REVIEWED`, `QC_SIGNED`, `QA_MANAGER_APPROVED`                                                                                                                  | `op_recall_capa`                                                                           |
| `hold_status`          | `ACTIVE`, `RELEASED`, `CANCELLED`                                                                                                                                        | `op_batch_hold_registry`                                                                   |
| `sale_lock_status`     | `ACTIVE`, `RELEASED`, `CANCELLED`                                                                                                                                        | `op_sale_lock_registry`                                                                    |
| `misa_sync_status`     | `PENDING`, `MAPPED`, `SYNCING`, `SYNCED`, `FAILED_RETRYABLE`, `FAILED_NEEDS_REVIEW`, `RECONCILED`                                                                        | MISA tables                                                                                |
| `outbox_status`        | `PENDING`, `DISPATCHING`, `DISPATCHED`, `FAILED_RETRYABLE`, `FAILED_DEAD_LETTER`, `ACKNOWLEDGED`, `MANUAL_RETRY`                                                         | `outbox_event`                                                                             |
| `approval_status`      | `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`                                                                                                                           | approval tables                                                                            |
| `source_channel`       | `ADMIN_WEB`, `PWA`, `PUBLIC_API`, `SYSTEM`, `INTEGRATION`                                                                                                                | audit/state/action logs                                                                    |
| `evidence_type`        | `FIELD_PHOTO`, `FIELD_VIDEO`, `CERTIFICATE_DOC`, `LAB_REPORT`, `CONTRACT_DOC`, `PHOTO`, `VIDEO`, `COA`, `DELIVERY_DOC`, `DAMAGE_PHOTO`, `OTHER`                          | `op_source_origin_evidence`, `op_recall_capa_evidence`, `op_raw_material_receipt_evidence` |
| `evidence_status`      | `ACTIVE`, `VOID`                                                                                                                                                         | `op_raw_material_receipt_evidence`                                                         |
| `evidence_scan_status` | `PENDING_SCAN`, `CLEAN`, `INFECTED`, `SCAN_FAILED`                                                                                                                       | `op_source_origin_evidence`, `op_recall_capa_evidence`, `op_raw_material_receipt_evidence` |

Rule: `evidence_type = FIELD_VIDEO` chỉ chấp nhận khi storage policy đã chốt MIME allowlist video (`video/mp4`, `video/quicktime`) và size cap (xem `ui/05_FORM_FIELD_SPECIFICATION.md` Section 2). FE/BE phải reject MIME ngoài allowlist với `EVIDENCE_MIME_NOT_ALLOWED`.

Rule: `OTHER` chỉ dùng khi không match 5 loại còn lại; reviewer phải bổ sung `notes` mô tả loại evidence để audit tra cứu.

Rule: Evidence chỉ được dùng cho source verification hoặc CAPA/recall close khi `evidence_scan_status = CLEAN`. Dev/test có thể dùng mock/dev-skip scanner để tạo kết quả `CLEAN`; production phải dùng scanner thật.
