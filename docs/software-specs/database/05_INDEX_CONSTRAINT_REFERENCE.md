# Index Constraint Reference

> Mục đích: liệt kê unique, FK, check constraint, append-only guard và idempotency key để DBA/backend chuyển thành migration.

## 1. Unique Constraints

| constraint_id | Table | Columns | Rule |
| --- | --- | --- | --- |
| UQ-AUTH-USER-USERNAME | `auth_user` | `username` | Username unique. |
| UQ-IDEMPOTENCY | `idempotency_registry` | `scope`, `idempotency_key` | Prevent duplicate commands per scope. |
| UQ-EVENT-SCHEMA | `event_schema_registry` | `event_type`, `event_version` | Event schema version unique. |
| UQ-UOM | `ref_uom` | `uom_code` | UOM code unique. |
| UQ-SUPPLIER | `op_supplier` | `supplier_code` | Supplier code unique. |
| UQ-WAREHOUSE | `op_warehouse` | `warehouse_code` | Warehouse code unique. |
| UQ-WH-LOCATION | `op_warehouse_location` | `warehouse_id`, `location_code` | Location unique within warehouse. |
| UQ-SKU | `ref_sku` | `sku_code` | SKU code unique. |
| UQ-INGREDIENT | `ref_ingredient` | `ingredient_code` | Ingredient code unique. |
| UQ-INGREDIENT-ALIAS | `ref_ingredient_alias` | `alias_code` | Alias code unique across ingredients. |
| UQ-RECIPE-ACTIVE | `op_production_recipe` | `sku_id` where `formula_status='ACTIVE_OPERATIONAL'` | Only one active recipe per SKU. |
| UQ-RECIPE-VERSION | `op_production_recipe` | `sku_id`, `formula_version` | One version per SKU. |
| UQ-RECIPE-LINE | `op_recipe_ingredient` | `recipe_id`, `ingredient_id`, `group_code` | Avoid duplicate ingredient line in same group. |
| UQ-SOURCE-ZONE | `op_source_zone` | `source_zone_code` | Source zone code unique. |
| UQ-RAW-RECEIPT | `op_raw_material_receipt` | `receipt_no` | Receipt number unique. |
| UQ-RAW-LOT | `op_raw_material_lot` | `raw_material_lot_code` | Raw lot code unique. |
| UQ-PO | `op_production_order` | `production_order_no` | PO number unique. |
| UQ-BATCH | `op_batch` | `batch_no` | Batch number unique. |
| UQ-BATCH-RELEASE-APPROVED | `op_batch_release` | `batch_id` where `release_status='APPROVED_RELEASED'` | At most one approved release record per batch. |
| UQ-GTIN | `op_trade_item_gtin` | `gtin` | GTIN unique. |
| UQ-QR | `op_qr_registry` | `qr_code` | QR code unique. |
| UQ-TRACE-LINK | `op_trace_link` | `from_object_type`, `from_object_id`, `to_object_type`, `to_object_id`, `trace_link_type` | Avoid duplicate trace link. |
| UQ-RECALL-SNAPSHOT | `op_recall_exposure_snapshot` | `recall_case_id`, `snapshot_version` | Snapshot versions unique. |
| UQ-MISA-MAPPING | `misa_mapping` | `internal_object_type`, `internal_object_id`, `misa_object_type` | Mapping unique per object. |
| UQ-UI-SCREEN | `ui_screen_registry` | `screen_id` | Screen id unique. |
| UQ-UI-ACTION | `ui_action_registry` | `action_code` | Action code unique. |

## 2. Required Foreign Keys

| FK group | Required FK |
| --- | --- |
| Auth | `auth_user_role.user_id -> auth_user`, `auth_user_role.role_code -> auth_role`, `role_action_permission.role_code -> auth_role` |
| Recipe | `op_production_recipe.sku_id -> ref_sku`, `op_recipe_ingredient.recipe_id -> op_production_recipe`, `ingredient_id -> ref_ingredient`, `group_code -> ref_recipe_line_group` |
| Source/raw | `op_source_origin.source_zone_id -> op_source_zone`, `op_raw_material_lot.source_origin_id -> op_source_origin`, `supplier_id -> op_supplier`, `ingredient_id -> ref_ingredient` |
| Production | `op_production_order.sku_id -> ref_sku`, `recipe_id -> op_production_recipe`, `op_production_order_item.production_order_id -> op_production_order` |
| Material | `op_material_request.production_order_id -> op_production_order`, `op_material_issue.material_request_id -> op_material_request`, `op_material_issue_line.raw_material_lot_id -> op_raw_material_lot` |
| Packaging | `op_packaging_job.batch_id -> op_batch`, `op_packaging_unit.trade_item_id -> op_trade_item`, `op_qr_registry.packaging_unit_id -> op_packaging_unit` |
| Release/warehouse | `op_batch_release.batch_id -> op_batch`, `op_warehouse_receipt.batch_id -> op_batch`, `op_warehouse_receipt.batch_release_id -> op_batch_release`, `op_warehouse_receipt.warehouse_id -> op_warehouse` |
| Recall | `op_recall_case.incident_case_id -> op_incident_case`, recall child tables -> `op_recall_case`, recall batch -> `op_batch` |
| MISA | `misa_sync_event.outbox_event_id -> outbox_event`, logs/reconcile -> `misa_sync_event` |
| UI/forms | `ui_action_registry.screen_id -> ui_screen_registry`, `op_form_instance.form_template_id -> op_form_template` |

## 3. Check Constraints

| constraint_id | Table | Rule |
| --- | --- | --- |
| CK-OPERATIONAL-RECIPE-VERSION | `op_production_recipe` | `formula_version` phải thuộc registry/version policy được phê duyệt cho operational status; G0/research/baseline token không được `APPROVED` hoặc `ACTIVE_OPERATIONAL`. |
| CK-RECIPE-GROUP | `ref_recipe_line_group` | group_code in 4 required values. |
| CK-PROCUREMENT-TYPE | `op_raw_material_lot` | `procurement_type IN ('SELF_GROWN','PURCHASED')`. |
| CK-PROCUREMENT-FIELDS | `op_raw_material_lot` | `SELF_GROWN` requires `source_origin_id` and null `supplier_id`; `PURCHASED` requires `supplier_id` and null `source_origin_id`. |
| CK-RAW-LOT-STATUS | `op_raw_material_lot` | `lot_status IN ('CREATED','IN_QC','ON_HOLD','REJECTED','READY_FOR_PRODUCTION','CONSUMED','EXPIRED','QUARANTINED')`; `READY_FOR_PRODUCTION` is distinct from `lot_qc_status = 'QC_PASS'`. |
| CK-MATERIAL-ISSUE-LOT-READY | `op_material_issue_line` | Issue line insert/update must verify referenced raw lot has `lot_status = 'READY_FOR_PRODUCTION'`; implement as service guard plus DB trigger/deferred constraint if cross-table checks are supported. |
| CK-QC-STATUS | QC tables | Only `PENDING_QC`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`. |
| CK-BATCH-STATUS | `op_batch` | Only `CREATED`, `IN_PROCESS`, `PACKAGED`, `QC_PENDING`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`, `RELEASED`, `BLOCKED`, `CLOSED`. |
| CK-RECALL-STATUS | `op_recall_case` | Includes `CLOSED_WITH_RESIDUAL_RISK`; when selected, `residual_note` is required. |
| CK-WAREHOUSE-RECEIPT-RELEASED | `op_warehouse_receipt` | Receipt confirmation must reference an `op_batch_release` row for the same batch with `release_status = 'APPROVED_RELEASED'`; implement with trigger/deferred validation if FK cannot include the status predicate. |
| CK-PROCESS-STEP | `op_production_process_event` | Only `PREPROCESSING`, `FREEZING`, `FREEZE_DRYING`. |
| CK-QR-STATUS | `op_qr_registry` | Only `GENERATED`, `QUEUED`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED`. |
| CK-WAREHOUSE-TYPE | `op_warehouse` | Only `RAW_MATERIAL`, `FINISHED_GOODS`. |
| CK-QTY-POSITIVE | Quantity columns | `quantity > 0` except reversal/adjustment rows where signed quantity is explicit. |
| CK-GTIN-FIXTURE | `op_trade_item_gtin` | DB stores and constrains the `is_test_fixture` flag; production commercial print block is service-level policy using this flag, no SKU-code fallback. |

## 4. Append-Only Guards

| guard_id | Table | Guard |
| --- | --- | --- |
| AO-AUDIT | `audit_log` | No UPDATE/DELETE. |
| AO-STATE | `state_transition_log` | No UPDATE/DELETE. |
| AO-LEDGER | `op_inventory_ledger` | No UPDATE/DELETE after insert; correction via reversal/adjustment. |
| AO-QR-HISTORY | `op_qr_state_history` | No UPDATE/DELETE. |
| AO-PRINT-LOG | `op_print_log` | No UPDATE/DELETE. |
| AO-RECALL-SNAPSHOT | `op_recall_exposure_snapshot` | No UPDATE/DELETE; new `snapshot_version` for rerun. |
| AO-EVENT | `event_store` | No UPDATE/DELETE; for `outbox_event`, only `status`, `retry_count`, `next_retry_at`, `dispatched_at` may update after insert. `payload`, `event_type`, `event_version`, `aggregate_type`, `aggregate_id` and `privacy_class` are immutable. |

Implementation option: DB trigger `prevent_update_delete_append_only()` on append-only tables plus restricted DB role permissions.

## 5. Index Recommendations

| index_id | Table | Columns | Purpose |
| --- | --- | --- | --- |
| IDX-AUDIT-OBJECT | `audit_log` | `object_type`, `object_id`, `created_at DESC` | Audit lookup by object. |
| IDX-STATE-OBJECT | `state_transition_log` | `object_type`, `object_id`, `created_at DESC` | Workflow history. |
| IDX-OUTBOX-STATUS | `outbox_event` | `status`, `next_retry_at`, `created_at` | Worker dispatch. |
| IDX-RAW-LOT-ISSUABLE | `op_raw_material_lot` | `ingredient_id`, `lot_status`, `lot_qc_status`, `procurement_type` | Issue lot selection; prefer partial index where `lot_status='READY_FOR_PRODUCTION' AND lot_qc_status='QC_PASS'`. |
| IDX-PO-STATUS | `op_production_order` | `production_order_status`, `created_at DESC` | PO queue. |
| IDX-BATCH-STATUS | `op_batch` | `batch_status`, `created_at DESC` | Batch/release queue. |
| IDX-ISSUE-REQUEST | `op_material_issue` | `material_request_id`, `issue_status` | Issue workflow. |
| IDX-MATERIAL-ISSUE-LINE-LOT | `op_material_issue_line` | `raw_material_lot_id`, `material_issue_id` | Trace raw lot consumption to issue/batch. |
| IDX-BATCH-RELEASE-APPROVED | `op_batch_release` | `batch_id`, `release_status`, `released_at` | Warehouse receipt eligibility lookup; supports `APPROVED_RELEASED` validation. |
| IDX-LEDGER-ITEM | `op_inventory_ledger` | `item_type`, `item_id`, `warehouse_id`, `created_at` | Ledger reconstruction. |
| IDX-BALANCE-ITEM | `op_inventory_lot_balance` | `item_type`, `item_id`, `warehouse_id`, `balance_status` | Balance query/allocation. |
| IDX-TRACE-FROM | `op_trace_link` | `from_object_type`, `from_object_id` | Forward trace. |
| IDX-TRACE-TO | `op_trace_link` | `to_object_type`, `to_object_id` | Backward trace. |
| IDX-QR-CODE | `op_qr_registry` | `qr_code` | Public trace resolve. |
| IDX-RECALL-STATUS | `op_recall_case` | `recall_status`, `created_at DESC` | Recall queue. |
| IDX-MISA-STATUS | `misa_sync_event` | `sync_status`, `next_retry_at` | Retry/reconcile. |


