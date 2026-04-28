# Table Specification

> Mục đích: đặc tả bảng/cột/ràng buộc theo nhóm master, transaction, ledger, audit, mapping, history, projection, snapshot. DBA/backend có thể dùng file này cùng ERD/enum/index để viết migration.

## 1. Column Conventions

| convention | Applies to | Columns |
| --- | --- | --- |
| Mutable business table | Master/config/transaction/projection | `created_at timestamptz not null`, `created_by uuid/text null`, `updated_at timestamptz null`, `updated_by uuid/text null`, `status text` nếu có lifecycle |
| Append-only history | Audit/ledger/state/QR/print/history | `created_at timestamptz not null`, `actor_user_id uuid/text null`, `source_channel text`, `correlation_id text` |
| Money/quantity | Quantity fields | `numeric(18,3)` unless implementation needs higher precision |
| JSON snapshot | Snapshot payloads | `jsonb not null` plus typed search columns where needed |
| Enum | State/status fields | `text not null` + check constraint from [04_ENUM_REFERENCE.md](04_ENUM_REFERENCE.md) |

## 2. Foundation / Auth / Audit / Workflow

| table | category | PK | Core columns | FK / constraints | Notes |
| --- | --- | --- | --- | --- | --- |
| `auth_user` | master/security | `user_id uuid` | `username text`, `display_name text`, `email text null`, `status text`, `last_login_at timestamptz null` | `UNIQUE(username)`, status in `ACTIVE/INACTIVE/LOCKED` | Local account phase 1. |
| `auth_role` | master/security | `role_code text` | `role_name text`, `description text`, `status text` | `UNIQUE(role_code)` | Seed roles from role model. |
| `auth_permission` | master/security | `permission_code text` | `module_code text`, `action_code text`, `description text`, `status text` | `UNIQUE(action_code)` | Backend permission source. |
| `auth_user_role` | mapping/security | `(user_id, role_code)` | `assigned_at timestamptz`, `assigned_by uuid/text` | FK `auth_user`, FK `auth_role` | No duplicate assignment. |
| `role_action_permission` | mapping/security | `role_action_permission_id uuid` | `role_code text`, `action_code text`, `permission_scope text`, `effect text`, `status text` | `UNIQUE(role_code, action_code, permission_scope)` | `effect` default `ALLOW`; deny policy optional. |
| `approval_policy` | config/workflow | `approval_policy_id uuid` | `object_type text`, `action_code text`, `required_role_code text`, `separation_required bool`, `dual_approval_required bool`, `auto_expiry_minutes int null`, `threshold_config jsonb`, `status text` | FK role optional; unique active policy per object/action/scope; `auto_expiry_minutes` required for break-glass policy | Policy, not approval instance; break-glass TTL must be typed, not only free-form JSON. |
| `approval_request` | transaction/workflow | `approval_request_id uuid` | `object_type text`, `object_id uuid`, `action_code text`, `submitted_by uuid/text`, `approval_status text`, `reason_text text`, `requested_payload jsonb` | status in `PENDING/APPROVED/REJECTED/CANCELLED`; index object/action | Approval instance. |
| `approval_action` | history/workflow | `approval_action_id uuid` | `approval_request_id uuid`, `actor_user_id uuid/text`, `action_result text`, `reason_code text`, `reason_text text`, `created_at timestamptz` | FK `approval_request`; action_result in `APPROVED/REJECTED/CANCELLED` | Append-only approval decision log. |
| `audit_log` | audit | `audit_id uuid` | `event_type text`, `actor_user_id uuid/text`, `actor_role_codes text[]`, `object_type text`, `object_id uuid`, `parent_object_type text null`, `parent_object_id uuid null`, `from_state text null`, `to_state text null`, `reason_code text null`, `reason_text text null`, `before_snapshot jsonb null`, `after_snapshot jsonb null`, `correlation_id text`, `idempotency_key text null`, `source_channel text`, `created_at timestamptz` | Append-only guard | Required for sensitive actions; capture all effective roles used for authorization evidence. |
| `state_transition_log` | history | `transition_id uuid` | `object_type text`, `object_id uuid`, `action_code text`, `from_state text`, `to_state text`, `actor_user_id uuid/text`, `reason_code text null`, `reason_text text null`, `created_at timestamptz`, `correlation_id text` | Append-only guard | State evidence. |
| `idempotency_registry` | system | `(scope, idempotency_key)` | `actor_user_id uuid/text null`, `request_hash text`, `response_ref_type text null`, `response_ref_id uuid null`, `original_response_payload jsonb null`, `command_status text`, `expires_at timestamptz null`, `created_at timestamptz` | Unique PK; same key different hash rejected | Used by PWA/API commands; replay may return original payload without recomputing side effects. |
| `event_schema_registry` | integration/config | `(event_type, event_version)` | `schema_name text`, `payload_schema jsonb`, `privacy_class text`, `compatibility_rule text`, `status text`, `created_at timestamptz` | status active/inactive | Versioned event contract. |
| `outbox_event` | integration/queue | `event_id uuid` | `event_type text`, `event_version int`, `aggregate_type text`, `aggregate_id uuid`, `payload jsonb`, `privacy_class text`, `status text`, `retry_count int`, `next_retry_at timestamptz null`, `created_at timestamptz`, `dispatched_at timestamptz null`, `correlation_id text` | FK logical to event schema; status enum; `privacy_class` matches event envelope | Worker dispatch source. |
| `event_store` | history/integration | `event_id uuid` | `event_type text`, `event_version int`, `aggregate_type text`, `aggregate_id uuid`, `payload jsonb`, `occurred_at timestamptz`, `created_at timestamptz` | Append-only guard | Optional durable event history. |

## 3. Master / Config

| table | category | PK | Core columns | FK / constraints | Notes |
| --- | --- | --- | --- | --- | --- |
| `ref_uom` | master | `uom_code text` | `display_name text`, `uom_type text`, `status text` | `UNIQUE(uom_code)` | Seed kg, g, lít, ml, hộp, thùng, %. |
| `op_supplier` | master | `supplier_id uuid` | `supplier_code text`, `supplier_name text`, `tax_code text null`, `contact_info jsonb null`, `status text` | `UNIQUE(supplier_code)` | For `PURCHASED` raw lots only. |
| `op_warehouse` | master | `warehouse_id uuid` | `warehouse_code text`, `warehouse_name text`, `warehouse_type text`, `status text` | `UNIQUE(warehouse_code)`, type in `RAW_MATERIAL/FINISHED_GOODS` | At least 1 active per type. |
| `op_warehouse_location` | master | `location_id uuid` | `warehouse_id uuid`, `location_code text`, `location_name text`, `status text` | FK warehouse, `UNIQUE(warehouse_id, location_code)` | Optional location/bin. |
| `ref_adjustment_reason` | master/config | `reason_code text` | `reason_name text`, `reason_group text`, `requires_approval bool`, `status text` | `UNIQUE(reason_code)` | Inventory/correction reasons. |
| `op_config` | config | `config_key text` | `config_value jsonb`, `config_group text`, `is_secret_reference bool`, `status text` | `UNIQUE(config_key)` | Store secret reference only, not secret value. |
| `ref_sku` | master/transitional | `sku_id uuid` | `sku_code text`, `sku_name_vi text`, `sku_name_en text null`, `sku_group_code text`, `sku_group_name text`, `sku_type text`, `is_sellable bool`, `is_producible bool`, `is_trace_public_enabled bool`, `status text` | `UNIQUE(sku_code)`, sku_type in `VEGAN/SAVORY` | 20 SKU baseline, not hard limit. |
| `ref_ingredient` | master | `ingredient_id uuid` | `ingredient_code text`, `ingredient_name_vi text`, `ingredient_name_en text null`, `scientific_name text null`, `default_uom text`, `ingredient_status text`, `notes text null` | `UNIQUE(ingredient_code)`, FK UOM | Must include required ingredients. |
| `ref_ingredient_alias` | mapping/master | `alias_id uuid` | `ingredient_id uuid`, `alias_code text`, `alias_source text`, `status text` | FK ingredient, `UNIQUE(alias_code)` | Legacy `MAT-*` alias only. |
| `ref_recipe_line_group` | master/config | `group_code text` | `name_vi text`, `source_label_vi text`, `sort_order int`, `is_active bool` | group code check in 4 required values; sort in 10/20/30/40 | Seed hard lock. |
| `ref_sku_operational_config` | config | `sku_operational_config_id uuid` | `sku_id uuid`, `readiness_status text`, `default_batch_size numeric(18,3)`, `qc_required bool`, `trace_public_enabled bool`, `notes text null` | FK SKU, unique active per SKU | Production readiness. |

## 4. Recipe / Source / Raw Material

| table | category | PK | Core columns | FK / constraints | Notes |
| --- | --- | --- | --- | --- | --- |
| `op_production_recipe` | master/versioned | `recipe_id uuid` | `sku_id uuid`, `formula_code text`, `formula_version text`, `formula_status text`, `effective_from timestamptz null`, `effective_to timestamptz null`, `approved_by uuid/text null`, `approved_at timestamptz null`, `activated_at timestamptz null`, `retired_at timestamptz null`, `source_note text null` | FK SKU, unique `(sku_id, formula_version)`, partial unique active per SKU, no active research baseline token | G1 baseline and future G2/G3. |
| `op_recipe_ingredient` | master/versioned | `recipe_line_id uuid` | `recipe_id uuid`, `line_no int`, `group_code text`, `ingredient_id uuid`, `ingredient_code_snapshot text`, `ingredient_display_name text`, `quantity_per_batch_400 numeric(18,3)`, `uom_code text`, `ratio_percent numeric(10,4) null`, `prep_note text null`, `usage_role text null`, `sort_order int` | FK recipe, ingredient, group, UOM; qty > 0 | Source of PO snapshot. |
| `op_source_zone` | master/source | `source_zone_id uuid` | `source_zone_code text`, `source_zone_name text`, `province text`, `ward text`, `address_detail text`, `public_display_name text null`, `status text` | `UNIQUE(source_zone_code)` | Public source fields. |
| `op_source_origin` | transaction/source | `source_origin_id uuid` | `source_zone_id uuid`, `origin_code text`, `verification_status text`, `submitted_by uuid/text null`, `verified_by uuid/text null`, `verified_at timestamptz null`, `rejected_reason text null`, `status text` | FK source zone; verification enum | `SELF_GROWN` lot requires `VERIFIED`. |
| `op_source_origin_evidence` | history/source | `evidence_id uuid` | `source_origin_id uuid`, `evidence_type text`, `evidence_uri text`, `evidence_hash text null`, `notes text null`, `created_at timestamptz` | FK source origin | Append-only evidence preferred. |
| `op_source_origin_verification` | history/source | `verification_id uuid` | `source_origin_id uuid`, `verification_result text`, `verified_by uuid/text`, `reason_code text null`, `reason_text text null`, `created_at timestamptz` | FK source origin | Verification history. |
| `op_raw_material_receipt` | transaction | `raw_material_receipt_id uuid` | `receipt_no text`, `warehouse_id uuid`, `received_at timestamptz`, `received_by uuid/text`, `receipt_status text`, `supplier_document_ref text null`, `notes text null` | FK warehouse, unique receipt_no | Creates raw lots. |
| `op_raw_material_receipt_item` | transaction | `raw_material_receipt_item_id uuid` | `raw_material_receipt_id uuid`, `ingredient_id uuid`, `quantity numeric(18,3)`, `uom_code text`, `line_no int`, `notes text null` | FK receipt, ingredient, UOM, qty > 0 | Receipt lines. |
| `op_raw_material_lot` | transaction | `raw_material_lot_id uuid` | `raw_material_lot_code text`, `raw_material_receipt_item_id uuid`, `ingredient_id uuid`, `procurement_type text`, `source_origin_id uuid null`, `source_zone_id uuid null`, `supplier_id uuid null`, `warehouse_id uuid`, `received_quantity numeric(18,3)`, `uom_code text`, `lot_qc_status text`, `lot_status text`, `hold_status text null`, `expiry_date date null` | Unique lot code; procurement field check; FK ingredient/source/supplier/warehouse/UOM; `lot_status` check | Lot-level trace and issue source; `lot_qc_status = QC_PASS` is prerequisite, only `lot_status = READY_FOR_PRODUCTION` is issue-eligible. |
| `op_raw_material_qc_inspection` | transaction/qc | `raw_material_qc_id uuid` | `raw_material_lot_id uuid`, `qc_status text`, `inspection_payload jsonb`, `inspected_by uuid/text`, `inspected_at timestamptz`, `reason_code text null`, `reason_text text null` | FK raw lot; QC enum | Incoming QC specialized table. |

## 5. Production / Material / Process

| table | category | PK | Core columns | FK / constraints | Notes |
| --- | --- | --- | --- | --- | --- |
| `op_production_order` | transaction | `production_order_id uuid` | `production_order_no text`, `sku_id uuid`, `recipe_id uuid`, `formula_code text`, `formula_version text`, `batch_size numeric(18,3)`, `planned_start_at timestamptz null`, `production_order_status text`, `approved_by uuid/text null`, `approved_at timestamptz null` | FK SKU/recipe, unique PO no, only approved operational snapshot | PO header. |
| `op_production_order_item` | snapshot | `production_order_item_id uuid` | `production_order_id uuid`, `line_no int`, `recipe_line_id uuid null`, `recipe_line_group_code text`, `ingredient_id uuid`, `ingredient_code text`, `ingredient_display_name text`, `quantity_per_batch_400 numeric(18,3)`, `uom_code text`, `ratio_percent numeric(10,4) null`, `prep_note text null`, `usage_role text null`, `formula_code text`, `formula_version text` | FK PO/ingredient/UOM/group; immutable guard after PO open | Required immutable snapshot. |
| `op_work_order` | transaction | `work_order_id uuid` | `work_order_no text`, `production_order_id uuid`, `batch_id uuid null`, `work_order_status text`, `assigned_to uuid/text null`, `started_at timestamptz null`, `completed_at timestamptz null` | FK PO, unique WO no | Work execution. |
| `op_batch` | transaction | `batch_id uuid` | `batch_no text`, `production_order_id uuid`, `work_order_id uuid null`, `sku_id uuid`, `batch_status text`, `created_at timestamptz`, `released_at timestamptz null`, `closed_at timestamptz null` | FK PO/WO/SKU, unique batch_no | Genealogy root. |
| `op_production_process_event` | history/transaction | `process_event_id uuid` | `batch_id uuid`, `work_order_id uuid`, `process_step text`, `process_status text`, `started_at timestamptz null`, `completed_at timestamptz null`, `actor_user_id uuid/text`, `payload jsonb`, `reason_text text null` | FK batch/WO; step/status checks; order enforced by service/constraint where feasible | Required process chain. |
| `op_material_request` | transaction/workflow | `material_request_id uuid` | `material_request_no text`, `production_order_id uuid`, `requested_by uuid/text`, `request_status text`, `submitted_at timestamptz null`, `approved_at timestamptz null`, `approved_by uuid/text null` | FK PO, unique request_no | Request before issue. |
| `op_material_request_line` | transaction | `material_request_line_id uuid` | `material_request_id uuid`, `production_order_item_id uuid`, `ingredient_id uuid`, `requested_quantity numeric(18,3)`, `uom_code text`, `line_status text` | FK request/PO item/ingredient/UOM | Must derive from snapshot. |
| `op_material_issue` | transaction/ledger-source | `material_issue_id uuid` | `material_issue_no text`, `material_request_id uuid`, `warehouse_id uuid`, `issue_status text`, `executed_by uuid/text null`, `executed_at timestamptz null` | FK request/warehouse, unique issue_no | Decrement point. |
| `op_material_issue_line` | transaction/ledger-source | `material_issue_line_id uuid` | `material_issue_id uuid`, `material_request_line_id uuid`, `raw_material_lot_id uuid`, `ingredient_id uuid`, `issued_quantity numeric(18,3)`, `uom_code text`, `inventory_ledger_id uuid null` | FK issue/request line/raw lot/ingredient/UOM/ledger | Lot-level consumption. |
| `op_material_receipt` | transaction | `material_receipt_id uuid` | `material_receipt_no text`, `material_issue_id uuid`, `received_by uuid/text`, `received_at timestamptz`, `receipt_status text`, `notes text null` | FK issue, unique receipt_no | No second decrement. |
| `op_material_receipt_line` | transaction | `material_receipt_line_id uuid` | `material_receipt_id uuid`, `material_issue_line_id uuid`, `received_quantity numeric(18,3)`, `uom_code text`, `variance_quantity numeric(18,3) default 0` | FK receipt/issue line/UOM | Workshop receipt detail. |
| `op_material_receipt_variance` | transaction/history | `variance_id uuid` | `material_receipt_line_id uuid`, `variance_type text`, `variance_quantity numeric(18,3)`, `reason_code text`, `reason_text text`, `review_status text` | FK receipt line | Variance audit/review. |
| `op_batch_material_usage` | trace/transaction | `usage_id uuid` | `batch_id uuid`, `material_issue_line_id uuid`, `raw_material_lot_id uuid`, `ingredient_id uuid`, `used_quantity numeric(18,3)`, `uom_code text` | FK batch/issue line/raw lot/ingredient/UOM | Material-to-batch genealogy. |

## 6. Packaging / QC / Warehouse / Inventory

| table | category | PK | Core columns | FK / constraints | Notes |
| --- | --- | --- | --- | --- | --- |
| `op_trade_item` | master | `trade_item_id uuid` | `sku_id uuid`, `trade_item_code text`, `packaging_level text`, `display_name text`, `status text` | FK SKU; unique trade_item_code; level BOX/CARTON | Trade identity separate from SKU. |
| `op_trade_item_gtin` | master/mapping | `trade_item_gtin_id uuid` | `trade_item_id uuid`, `gtin text`, `is_test_fixture bool`, `effective_from timestamptz null`, `effective_to timestamptz null`, `status text` | FK trade item; unique gtin | Fake fixture allowed dev only. |
| `op_packaging_job` | transaction | `packaging_job_id uuid` | `packaging_job_no text`, `batch_id uuid`, `packaging_level text`, `planned_quantity numeric(18,3)`, `completed_quantity numeric(18,3)`, `packaging_status text` | FK batch, unique job no | BOX/CARTON. |
| `op_packaging_unit` | transaction | `packaging_unit_id uuid` | `packaging_job_id uuid`, `batch_id uuid`, `trade_item_id uuid`, `unit_code text`, `quantity numeric(18,3)`, `uom_code text`, `unit_status text` | FK packaging job/batch/trade item/UOM, unique unit_code | Unit tracked by QR. |
| `op_print_job` | transaction/snapshot | `print_job_id uuid` | `packaging_unit_id uuid`, `qr_id uuid null`, `print_job_no text`, `print_status text`, `print_payload_snapshot jsonb`, `requested_by uuid/text`, `requested_at timestamptz`, `printed_at timestamptz null`, `original_print_job_id uuid null`, `reprint_reason text null` | FK packaging unit/QR/self; unique print_job_no | Snapshot print payload. |
| `op_print_log` | history | `print_log_id uuid` | `print_job_id uuid`, `device_id uuid null`, `print_result text`, `message text null`, `created_at timestamptz` | FK print job/device; append-only | Device/callback log. |
| `op_qr_registry` | transaction | `qr_id uuid` | `packaging_unit_id uuid`, `qr_code text`, `qr_status text`, `generated_at timestamptz`, `printed_at timestamptz null`, `voided_at timestamptz null`, `public_trace_enabled bool` | FK packaging unit, unique qr_code, QR status check | Public trace entry point. |
| `op_qr_state_history` | history | `qr_state_history_id uuid` | `qr_id uuid`, `from_state text null`, `to_state text`, `action_code text`, `actor_user_id uuid/text`, `reason_text text null`, `created_at timestamptz` | FK QR, append-only | QR lifecycle evidence. |
| `op_device_registry` | master/integration | `device_id uuid` | `device_code text`, `device_type text`, `device_name text`, `adapter_config_ref text null`, `status text`, `last_heartbeat_at timestamptz null` | unique device_code | Printer/scanner adapter. |
| `op_qc_inspection` | transaction/qc | `qc_inspection_id uuid` | `object_type text`, `object_id uuid`, `qc_type text`, `qc_result text`, `inspection_payload jsonb`, `inspected_by uuid/text`, `inspected_at timestamptz`, `reason_code text null`, `reason_text text null` | QC result check; object type check | Generic in-process/finished QC. |
| `op_qc_inspection_item` | transaction/qc | `qc_inspection_item_id uuid` | `qc_inspection_id uuid`, `check_code text`, `check_name text`, `result text`, `value_text text null`, `value_numeric numeric(18,3) null`, `notes text null` | FK inspection | Checklist items. |
| `op_batch_disposition` | transaction/qc | `batch_disposition_id uuid` | `batch_id uuid`, `disposition_status text`, `disposition_reason text`, `decided_by uuid/text`, `decided_at timestamptz` | FK batch | QC disposition before release. |
| `op_batch_release` | transaction/qc | `batch_release_id uuid` | `batch_id uuid`, `release_status text`, `released_by uuid/text null`, `released_at timestamptz null`, `rejected_reason text null`, `release_payload jsonb` | FK batch; release status check; one active release per batch | `QC_PASS != RELEASED`. |
| `op_warehouse_receipt` | transaction/ledger-source | `warehouse_receipt_id uuid` | `warehouse_receipt_no text`, `warehouse_id uuid`, `batch_id uuid`, `batch_release_id uuid`, `receipt_status text`, `confirmed_by uuid/text null`, `confirmed_at timestamptz null` | FK warehouse/batch/release; unique receipt_no; release eligibility guard must verify `op_batch_release.release_status = APPROVED_RELEASED` | Requires released batch; warehouse receipt must not rely on batch `QC_PASS` alone. |
| `op_warehouse_receipt_line` | transaction/ledger-source | `warehouse_receipt_line_id uuid` | `warehouse_receipt_id uuid`, `packaging_unit_id uuid`, `trade_item_id uuid`, `received_quantity numeric(18,3)`, `uom_code text`, `inventory_ledger_id uuid null` | FK receipt/packaging/trade item/UOM/ledger | FG receipt detail. |
| `op_inventory_ledger` | ledger | `inventory_ledger_id uuid` | `warehouse_id uuid`, `location_id uuid null`, `item_type text`, `item_id uuid`, `lot_code text`, `ledger_direction text`, `ledger_source_type text`, `source_object_type text`, `source_object_id uuid`, `quantity numeric(18,3)`, `uom_code text`, `posted_at timestamptz`, `posted_by uuid/text`, `correlation_id text` | FK warehouse/location/UOM; append-only; quantity sign/direction checks | Source of inventory truth. |
| `op_inventory_lot_balance` | projection | `inventory_lot_balance_id uuid` | `warehouse_id uuid`, `location_id uuid null`, `item_type text`, `item_id uuid`, `lot_code text`, `available_quantity numeric(18,3)`, `reserved_quantity numeric(18,3)`, `hold_quantity numeric(18,3)`, `uom_code text`, `balance_status text`, `last_ledger_id uuid` | Unique warehouse/item/lot/status scope; FK ledger/UOM | Derived/projection. |
| `op_inventory_allocation` | transaction/projection | `allocation_id uuid` | `inventory_lot_balance_id uuid`, `source_object_type text`, `source_object_id uuid`, `allocated_quantity numeric(18,3)`, `allocation_status text`, `expires_at timestamptz null` | FK balance | Shipment/recall allocation refs. |
| `op_inventory_adjustment` | transaction/ledger-source | `inventory_adjustment_id uuid` | `warehouse_id uuid`, `item_type text`, `item_id uuid`, `lot_code text`, `adjustment_quantity numeric(18,3)`, `uom_code text`, `reason_code text`, `adjustment_status text`, `approved_by uuid/text null`, `inventory_ledger_id uuid null` | FK warehouse/UOM/reason/ledger | Adjustment creates ledger row. |

## 7. Trace / Recall

| table | category | PK | Core columns | FK / constraints | Notes |
| --- | --- | --- | --- | --- | --- |
| `op_trace_link` | transaction/trace | `trace_link_id uuid` | `from_object_type text`, `from_object_id uuid`, `to_object_type text`, `to_object_id uuid`, `trace_link_type text`, `link_source_type text`, `link_source_id uuid`, `created_at timestamptz` | Unique from/to/type; link type check | Genealogy edge. |
| `op_batch_genealogy_link` | transaction/trace | `genealogy_link_id uuid` | `parent_batch_id uuid`, `child_batch_id uuid`, `genealogy_type text`, `created_at timestamptz` | FK batch parent/child, no self link | If future batch split/merge. |
| `op_trace_search_index` | projection | `trace_search_index_id uuid` | `object_type text`, `object_id uuid`, `search_key text`, `search_value text`, `batch_id uuid null`, `raw_material_lot_id uuid null`, `qr_id uuid null`, `indexed_at timestamptz` | Index object/search fields | Performance/search projection. |
| `op_public_trace_policy` | config/projection | `public_trace_policy_id uuid` | `field_code text`, `field_group text`, `is_public bool`, `display_label_vi text`, `policy_status text`, `effective_from timestamptz` | Unique active field_code | Public whitelist/deny policy. |
| `vw_internal_traceability` | view/projection | N/A | batch/lot/QR/source/warehouse/recall chain fields | Built from trace links + transaction tables | Internal only. |
| `vw_public_traceability` | view/projection | N/A | QR, SKU display, source public fields, release/public status | Built from public policy and internal tables | Public safe only. |
| `op_incident_case` | transaction/recall | `incident_case_id uuid` | `incident_no text`, `incident_type text`, `severity text`, `incident_status text`, `reported_by uuid/text`, `reported_at timestamptz`, `description text` | Unique incident_no | Recall may start from incident. |
| `op_recall_case` | transaction/recall | `recall_case_id uuid` | `recall_no text`, `incident_case_id uuid null`, `recall_status text`, `severity text`, `opened_by uuid/text`, `opened_at timestamptz`, `closed_by uuid/text null`, `closed_at timestamptz null`, `reason_text text`, `residual_note text null` | FK incident, unique recall_no; `residual_note` required when `recall_status = CLOSED_WITH_RESIDUAL_RISK` | Recall lifecycle root. |
| `op_recall_case_batch` | mapping/recall | `recall_case_batch_id uuid` | `recall_case_id uuid`, `batch_id uuid`, `impact_level text`, `action_status text` | FK recall/batch, unique recall+batch | Affected batches. |
| `op_recall_exposure_snapshot` | snapshot/recall | `exposure_snapshot_id uuid` | `recall_case_id uuid`, `snapshot_version int`, `trace_query_ref jsonb`, `exposure_payload jsonb`, `created_by uuid/text`, `created_at timestamptz` | Unique recall+version; append-only | Re-run creates new version. |
| `op_batch_hold_registry` | transaction/recall | `hold_id uuid` | `batch_id uuid`, `recall_case_id uuid null`, `hold_status text`, `hold_reason text`, `held_by uuid/text`, `held_at timestamptz`, `released_at timestamptz null` | FK batch/recall; active hold uniqueness per batch optional | Release/warehouse/allocation gate. |
| `op_sale_lock_registry` | transaction/recall | `sale_lock_id uuid` | `recall_case_id uuid`, `scope_type text`, `scope_id uuid`, `lock_status text`, `locked_by uuid/text`, `locked_at timestamptz`, `released_at timestamptz null` | FK recall | Downstream sale/shipment lock reference. |
| `op_recall_recovery_item` | transaction/recall | `recovery_item_id uuid` | `recall_case_id uuid`, `object_type text`, `object_id uuid`, `target_quantity numeric(18,3) null`, `recovered_quantity numeric(18,3) null`, `recovery_status text` | FK recall | Recovery tracking. |
| `op_recall_disposition_record` | transaction/recall | `disposition_record_id uuid` | `recall_case_id uuid`, `object_type text`, `object_id uuid`, `disposition_status text`, `disposition_reason text`, `decided_by uuid/text`, `decided_at timestamptz` | FK recall | Disposition evidence. |
| `op_recall_capa` | transaction/recall | `capa_id uuid` | `recall_case_id uuid`, `capa_no text`, `capa_status text`, `owner_user_id uuid/text null`, `due_at timestamptz null`, `closed_at timestamptz null`, `description text` | FK recall, unique capa_no | CAPA follow-up. |
| `op_recall_timeline` | history/recall | `timeline_id uuid` | `recall_case_id uuid`, `event_type text`, `event_payload jsonb`, `actor_user_id uuid/text`, `created_at timestamptz` | FK recall, append-only | Recall audit/timeline. |

## 8. Integration / Dashboard / UI / Forms

| table | category | PK | Core columns | FK / constraints | Notes |
| --- | --- | --- | --- | --- | --- |
| `misa_mapping` | mapping/integration | `misa_mapping_id uuid` | `internal_object_type text`, `internal_object_id uuid`, `misa_object_type text`, `misa_external_id text null`, `mapping_payload jsonb`, `mapping_status text` | Unique internal object + misa object | Mapping before sync. |
| `misa_sync_event` | transaction/integration | `misa_sync_event_id uuid` | `outbox_event_id uuid`, `misa_mapping_id uuid null`, `sync_status text`, `retry_count int`, `next_retry_at timestamptz null`, `last_error_code text null`, `last_error_message text null` | FK outbox/mapping; status check | MISA consumer state. |
| `misa_sync_log` | history/integration | `misa_sync_log_id uuid` | `misa_sync_event_id uuid`, `attempt_no int`, `request_payload jsonb null`, `response_payload jsonb null`, `sync_result text`, `error_code text null`, `created_at timestamptz` | FK sync event; append-only | Attempt log. |
| `misa_reconcile_record` | transaction/integration | `reconcile_record_id uuid` | `misa_sync_event_id uuid`, `reconcile_status text`, `internal_payload jsonb`, `misa_payload jsonb`, `diff_payload jsonb`, `resolved_by uuid/text null`, `resolved_at timestamptz null` | FK sync event | Reconcile mismatches. |
| `op_dashboard_metric` | projection/reporting | `dashboard_metric_id uuid` | `metric_code text`, `metric_group text`, `metric_value numeric(18,3) null`, `metric_payload jsonb`, `measured_at timestamptz` | Index metric/time | Dashboard projection. |
| `op_alert_rule` | config/reporting | `alert_rule_id uuid` | `alert_code text`, `alert_name text`, `condition_payload jsonb`, `severity text`, `status text` | Unique alert_code | Configurable alerts. |
| `op_alert_event` | transaction/reporting | `alert_event_id uuid` | `alert_rule_id uuid`, `object_type text`, `object_id uuid`, `alert_status text`, `severity text`, `message text`, `created_at timestamptz`, `acknowledged_by uuid/text null` | FK alert rule | Alert history. |
| `op_health_snapshot` | projection/reporting | `health_snapshot_id uuid` | `component_code text`, `health_status text`, `health_payload jsonb`, `measured_at timestamptz` | Index component/time | Health view. |
| `ui_screen_registry` | config/ui | `screen_id text` | `module_code text`, `screen_name text`, `route text`, `required_permission text null`, `status text` | Unique route optional | Screen source for UI. |
| `ui_action_registry` | config/ui | `action_code text` | `screen_id text`, `module_code text`, `action_name text`, `http_method text null`, `api_path text null`, `is_sensitive bool`, `status text` | FK screen, unique action_code | Permission/action map. |
| `ui_menu_item` | config/ui | `menu_item_id uuid` | `screen_id text`, `parent_menu_item_id uuid null`, `label text`, `sort_order int`, `required_permission text null`, `status text` | FK screen/self | Menu/sidebar. |
| `ui_form_schema` | config/ui | `form_schema_id uuid` | `screen_id text`, `form_code text`, `schema_payload jsonb`, `validation_payload jsonb`, `version_no int`, `status text` | FK screen, unique form_code+version | Dynamic form specs if used. |
| `ui_table_view_config` | config/ui | `table_view_config_id uuid` | `screen_id text`, `table_code text`, `columns_payload jsonb`, `filters_payload jsonb`, `actions_payload jsonb`, `version_no int`, `status text` | FK screen | Table/filter/action config. |
| `op_form_template` | config/workflow | `form_template_id uuid` | `form_code text`, `form_name text`, `module_code text`, `template_payload jsonb`, `version_no int`, `status text` | Unique form_code+version | Operational form template. |
| `op_form_instance` | transaction/workflow | `form_instance_id uuid` | `form_template_id uuid`, `object_type text`, `object_id uuid`, `form_status text`, `form_payload_snapshot jsonb`, `submitted_by uuid/text null`, `submitted_at timestamptz null`, `locked_at timestamptz null` | FK template; object index | Generated form instance. |
| `op_form_action_log` | history/workflow | `form_action_log_id uuid` | `form_instance_id uuid`, `action_code text`, `from_status text`, `to_status text`, `actor_user_id uuid/text`, `reason_text text null`, `created_at timestamptz` | FK instance; append-only | Form workflow history. |

## 9. Required Views / Projections

| view/projection | Source tables | Purpose | Public? |
| --- | --- | --- | --- |
| `vw_internal_traceability` | trace links, source, raw lot, issue, batch, QR, warehouse, recall refs | Internal backward/forward trace | No |
| `vw_public_traceability` | public trace policy, QR, SKU, batch release, source zone public fields | Public QR trace response | Yes, whitelist-only |
| `vw_inventory_balance_current` | `op_inventory_lot_balance` | Current balance query | No |
| `vw_batch_release_readiness` | batch, QC, hold, packaging, release | Release queue/readiness | No |
| `vw_recall_exposure_current` | recall snapshot latest, recall case, affected batches | Recall dashboard | No |

## 10. Migration Notes

- Tables with `object_type/object_id` are polymorphic by design for audit/trace/workflow. Implementation may add typed bridge tables where stricter FK is required.
- Append-only guard should be implemented with DB trigger and restricted DB role permissions before production data is written.
- Public trace view must be audited by leakage tests before release.
- No table should require research/baseline token for operational seed or transaction.




