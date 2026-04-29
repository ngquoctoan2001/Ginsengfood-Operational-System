# ERD

> Mermaid ERD mục tiêu, nhóm theo module. Một số view/projection được biểu diễn như entity để thể hiện dependency dữ liệu.

## Mục lục

- [1. Mermaid ERD](#1-mermaid-erd)
- [2. Notes](#2-notes)

## 1. Mermaid ERD

```mermaid
erDiagram
  auth_user {
    uuid user_id PK
    text username UK
    text display_name
    text status
  }
  auth_role {
    text role_code PK
    text role_name
    text status
  }
  auth_permission {
    text permission_code PK
    text action_code
    text module_code
  }
  auth_user_role {
    uuid user_id FK
    text role_code FK
  }
  role_action_permission {
    text role_code FK
    text action_code
    text permission_scope
  }
  approval_policy {
    uuid approval_policy_id PK
    text object_type
    text action_code
    text required_role_code
  }
  approval_request {
    uuid approval_request_id PK
    text object_type
    uuid object_id
    text action_code
    text approval_status
  }
  approval_action {
    uuid approval_action_id PK
    uuid approval_request_id FK
    text action_result
  }

  audit_log {
    uuid audit_id PK
    text event_type
    text actor_role_codes
    text object_type
    uuid object_id
  }
  state_transition_log {
    uuid transition_id PK
    text object_type
    uuid object_id
    text from_state
    text to_state
  }
  idempotency_registry {
    text idempotency_key PK
    text scope
    text request_hash
  }
  event_schema_registry {
    text event_type PK
    int event_version PK
    text status
  }
  outbox_event {
    uuid event_id PK
    text event_type
    text status
    text privacy_class
  }
  event_store {
    uuid event_id PK
    text event_type
    text aggregate_type
  }

  ref_uom {
    text uom_code PK
    text display_name
    text status
  }
  op_supplier {
    uuid supplier_id PK
    text supplier_code UK
    text supplier_name
  }
  op_warehouse {
    uuid warehouse_id PK
    text warehouse_code UK
    text warehouse_type
  }
  op_warehouse_location {
    uuid location_id PK
    uuid warehouse_id FK
    text location_code
  }
  ref_adjustment_reason {
    text reason_code PK
    text reason_name
  }
  op_config {
    text config_key PK
    text config_value
  }

  ref_sku {
    uuid sku_id PK
    text sku_code UK
    text sku_name_vi
    text sku_type
  }
  ref_ingredient {
    uuid ingredient_id PK
    text ingredient_code UK
    text default_uom FK
  }
  ref_ingredient_alias {
    uuid alias_id PK
    uuid ingredient_id FK
    text alias_code
  }
  ref_recipe_line_group {
    text group_code PK
    int sort_order
  }
  op_production_recipe {
    uuid recipe_id PK
    uuid sku_id FK
    text formula_code
    text formula_version
    text formula_kind
    text formula_status
    uuid anchor_ingredient_id FK
    numeric anchor_baseline_quantity
    text anchor_uom_code
    numeric anchor_ratio_percent
  }
  op_recipe_ingredient {
    uuid recipe_line_id PK
    uuid recipe_id FK
    uuid ingredient_id FK
    text group_code FK
    bool is_anchor
    numeric quantity_per_batch_400
    numeric ratio_percent
  }
  ref_sku_operational_config {
    uuid sku_operational_config_id PK
    uuid sku_id FK
    text readiness_status
  }

  op_source_zone {
    uuid source_zone_id PK
    text source_zone_code UK
    text province
    text ward
  }
  op_source_origin {
    uuid source_origin_id PK
    uuid source_zone_id FK
    text verification_status
  }
  op_source_origin_evidence {
    uuid evidence_id PK
    uuid source_origin_id FK
    text evidence_type
    text evidence_uri
    text mime_type
    bigint file_size_bytes
    text scan_status
    text original_filename
  }
  op_source_origin_verification {
    uuid verification_id PK
    uuid source_origin_id FK
    text verification_result
  }

  op_raw_material_receipt {
    uuid raw_material_receipt_id PK
    text receipt_no UK
    uuid warehouse_id FK
  }
  op_raw_material_receipt_item {
    uuid raw_material_receipt_item_id PK
    uuid raw_material_receipt_id FK
    uuid ingredient_id FK
  }
  op_raw_material_lot {
    uuid raw_material_lot_id PK
    uuid raw_material_receipt_item_id FK
    uuid ingredient_id FK
    text procurement_type
    text lot_qc_status
    text lot_status
  }
  op_raw_material_qc_inspection {
    uuid raw_material_qc_id PK
    uuid raw_material_lot_id FK
    text qc_status
  }

  op_production_order {
    uuid production_order_id PK
    text production_order_no UK
    uuid sku_id FK
    uuid recipe_id FK
    text production_order_status
  }
  op_production_order_item {
    uuid production_order_item_id PK
    uuid production_order_id FK
    uuid ingredient_id FK
    text formula_version
    text formula_kind_snapshot
    text recipe_line_group_code
    bool is_anchor
    numeric snapshot_quantity
    text snapshot_basis
  }
  op_work_order {
    uuid work_order_id PK
    uuid production_order_id FK
    text work_order_status
  }
  op_batch {
    uuid batch_id PK
    uuid production_order_id FK
    uuid work_order_id FK
    text batch_status
  }
  op_production_process_event {
    uuid process_event_id PK
    uuid batch_id FK
    text process_step
    text process_status
  }
  op_batch_material_usage {
    uuid usage_id PK
    uuid batch_id FK
    uuid raw_material_lot_id FK
    uuid material_issue_line_id FK
  }

  op_material_request {
    uuid material_request_id PK
    uuid production_order_id FK
    text request_status
  }
  op_material_request_line {
    uuid material_request_line_id PK
    uuid material_request_id FK
    uuid production_order_item_id FK
  }
  op_material_issue {
    uuid material_issue_id PK
    uuid material_request_id FK
    text issue_status
  }
  op_material_issue_line {
    uuid material_issue_line_id PK
    uuid material_issue_id FK
    uuid raw_material_lot_id FK
  }
  op_material_receipt {
    uuid material_receipt_id PK
    uuid material_issue_id FK
    text receipt_status
  }
  op_material_receipt_line {
    uuid material_receipt_line_id PK
    uuid material_receipt_id FK
    uuid material_issue_line_id FK
  }
  op_material_receipt_variance {
    uuid variance_id PK
    uuid material_receipt_line_id FK
    text variance_reason_code
  }

  op_trade_item {
    uuid trade_item_id PK
    uuid sku_id FK
    text packaging_level
    int units_per_box
    int boxes_per_carton
    bool carton_enabled
  }
  op_trade_item_gtin {
    uuid trade_item_gtin_id PK
    uuid trade_item_id FK
    text identifier_type
    text identifier_value
    bool is_test_fixture
  }
  op_packaging_job {
    uuid packaging_job_id PK
    uuid batch_id FK
    uuid trade_item_id FK
    text packaging_level
    bool carton_requested
    int units_per_box_snapshot
    int boxes_per_carton_snapshot
    text packaging_status
  }
  op_packaging_unit {
    uuid packaging_unit_id PK
    uuid packaging_job_id FK
    uuid trade_item_id FK
  }
  op_print_job {
    uuid print_job_id PK
    uuid packaging_unit_id FK
    text print_status
  }
  op_print_log {
    uuid print_log_id PK
    uuid print_job_id FK
    text print_result
  }
  op_qr_registry {
    uuid qr_id PK
    uuid packaging_unit_id FK
    text qr_code UK
    text qr_status
  }
  op_qr_state_history {
    uuid qr_state_history_id PK
    uuid qr_id FK
    text from_state
    text to_state
  }
  op_device_registry {
    uuid device_id PK
    text device_code UK
    text device_type
  }

  op_qc_inspection {
    uuid qc_inspection_id PK
    text object_type
    uuid object_id
    text qc_result
  }
  op_qc_inspection_item {
    uuid qc_inspection_item_id PK
    uuid qc_inspection_id FK
    text check_code
  }
  op_batch_disposition {
    uuid batch_disposition_id PK
    uuid batch_id FK
    text disposition_status
  }
  op_batch_release {
    uuid batch_release_id PK
    uuid batch_id FK
    text release_status
  }

  op_warehouse_receipt {
    uuid warehouse_receipt_id PK
    uuid warehouse_id FK
    uuid batch_id FK
    uuid batch_release_id FK
    text receipt_status
  }
  op_warehouse_receipt_line {
    uuid warehouse_receipt_line_id PK
    uuid warehouse_receipt_id FK
    uuid packaging_unit_id FK
  }
  op_inventory_ledger {
    uuid inventory_ledger_id PK
    uuid warehouse_id FK
    text item_type
    uuid item_id
    text ledger_direction
  }
  op_inventory_lot_balance {
    uuid inventory_lot_balance_id PK
    uuid warehouse_id FK
    text item_type
    uuid item_id
    text lot_code
  }
  op_inventory_allocation {
    uuid allocation_id PK
    uuid inventory_lot_balance_id FK
    text allocation_status
  }
  op_inventory_adjustment {
    uuid inventory_adjustment_id PK
    text adjustment_status
    text reason_code FK
  }

  op_trace_link {
    uuid trace_link_id PK
    text from_object_type
    uuid from_object_id
    text to_object_type
    uuid to_object_id
  }
  op_batch_genealogy_link {
    uuid genealogy_link_id PK
    uuid parent_batch_id FK
    uuid child_batch_id FK
  }
  op_trace_search_index {
    uuid trace_search_index_id PK
    text object_type
    uuid object_id
  }
  op_public_trace_policy {
    uuid public_trace_policy_id PK
    text field_code
    bool is_public
  }
  vw_internal_traceability {
    uuid trace_row_id PK
    uuid batch_id
    uuid raw_material_lot_id
    uuid qr_id
  }
  vw_public_traceability {
    text qr_code PK
    text sku_public_name
    text public_status
  }
  vw_batch_release_readiness {
    uuid batch_id PK
    text qc_status
    text release_readiness_status
  }
  vw_inventory_balance_current {
    uuid inventory_lot_balance_id PK
    numeric available_quantity
    numeric hold_quantity
  }
  vw_recall_exposure_current {
    uuid recall_case_id PK
    int snapshot_version
    text exposure_status
  }

  op_incident_case {
    uuid incident_case_id PK
    text incident_status
  }
  op_recall_case {
    uuid recall_case_id PK
    uuid incident_case_id FK
    text recall_status
    text residual_note
  }
  op_recall_case_batch {
    uuid recall_case_batch_id PK
    uuid recall_case_id FK
    uuid batch_id FK
  }
  op_recall_exposure_snapshot {
    uuid exposure_snapshot_id PK
    uuid recall_case_id FK
    int snapshot_version
  }
  op_batch_hold_registry {
    uuid hold_id PK
    uuid batch_id FK
    uuid recall_case_id FK
    text hold_status
  }
  op_sale_lock_registry {
    uuid sale_lock_id PK
    uuid recall_case_id FK
    text lock_status
  }
  op_recall_recovery_item {
    uuid recovery_item_id PK
    uuid recall_case_id FK
    text recovery_status
  }
  op_recall_disposition_record {
    uuid disposition_record_id PK
    uuid recall_case_id FK
    text disposition_status
  }
  op_recall_capa {
    uuid capa_id PK
    uuid recall_case_id FK
    text capa_status
  }
  op_recall_capa_evidence {
    uuid evidence_id PK
    uuid capa_id FK
    text evidence_type
    text evidence_uri
    text mime_type
    bigint file_size_bytes
    text scan_status
  }
  op_recall_timeline {
    uuid timeline_id PK
    uuid recall_case_id FK
    text event_type
  }

  misa_mapping {
    uuid misa_mapping_id PK
    text internal_object_type
    text misa_object_type
  }
  misa_sync_event {
    uuid misa_sync_event_id PK
    uuid outbox_event_id FK
    text sync_status
  }
  misa_sync_log {
    uuid misa_sync_log_id PK
    uuid misa_sync_event_id FK
    text sync_result
  }
  misa_reconcile_record {
    uuid reconcile_record_id PK
    uuid misa_sync_event_id FK
    text reconcile_status
  }

  op_dashboard_metric {
    uuid dashboard_metric_id PK
    text metric_code
  }
  op_alert_rule {
    uuid alert_rule_id PK
    text alert_code UK
  }
  op_alert_event {
    uuid alert_event_id PK
    uuid alert_rule_id FK
    text alert_status
  }
  op_health_snapshot {
    uuid health_snapshot_id PK
    text component_code
    text health_status
  }

  ui_screen_registry {
    text screen_id PK
    text module_code
  }
  ui_action_registry {
    text action_code PK
    text screen_id FK
  }
  ui_menu_item {
    uuid menu_item_id PK
    text screen_id FK
  }
  ui_form_schema {
    uuid form_schema_id PK
    text screen_id FK
  }
  ui_table_view_config {
    uuid table_view_config_id PK
    text screen_id FK
  }
  op_form_template {
    uuid form_template_id PK
    text form_code UK
  }
  op_form_instance {
    uuid form_instance_id PK
    uuid form_template_id FK
    text object_type
    uuid object_id
  }
  op_form_action_log {
    uuid form_action_log_id PK
    uuid form_instance_id FK
    text action_code
  }

  auth_user ||--o{ auth_user_role : has
  auth_role ||--o{ auth_user_role : assigned
  auth_role ||--o{ role_action_permission : grants
  auth_permission ||--o{ role_action_permission : maps
  approval_policy ||--o{ approval_request : governs
  approval_request ||--o{ approval_action : records

  op_warehouse ||--o{ op_warehouse_location : contains
  op_warehouse ||--o{ op_raw_material_receipt : receives
  op_warehouse ||--o{ op_warehouse_receipt : receives
  op_warehouse ||--o{ op_inventory_ledger : posts

  ref_sku ||--o{ op_production_recipe : has
  ref_sku ||--o{ ref_sku_operational_config : configures
  ref_sku ||--o{ op_trade_item : commercializes
  ref_ingredient ||--o{ ref_ingredient_alias : aliases
  ref_ingredient ||--o{ op_recipe_ingredient : used_by
  ref_recipe_line_group ||--o{ op_recipe_ingredient : groups
  op_production_recipe ||--o{ op_recipe_ingredient : lines

  op_source_zone ||--o{ op_source_origin : contains
  op_source_origin ||--o{ op_source_origin_evidence : has
  op_source_origin ||--o{ op_source_origin_verification : verifies
  op_supplier ||--o{ op_raw_material_lot : supplies
  op_source_origin ||--o{ op_raw_material_lot : origins

  op_raw_material_receipt ||--o{ op_raw_material_receipt_item : has
  op_raw_material_receipt_item ||--o{ op_raw_material_lot : creates
  ref_ingredient ||--o{ op_raw_material_receipt_item : received
  op_raw_material_lot ||--o{ op_raw_material_qc_inspection : inspected

  ref_sku ||--o{ op_production_order : produces
  op_production_recipe ||--o{ op_production_order : snapshots
  op_production_order ||--o{ op_production_order_item : snapshot_lines
  op_production_order ||--o{ op_work_order : creates
  op_production_order ||--o{ op_batch : creates
  op_work_order ||--o{ op_batch : executes
  op_batch ||--o{ op_production_process_event : has

  op_production_order ||--o{ op_material_request : requests
  op_material_request ||--o{ op_material_request_line : has
  op_material_request ||--o{ op_material_issue : approved_for
  op_material_issue ||--o{ op_material_issue_line : has
  op_raw_material_lot ||--o{ op_material_issue_line : issued_from
  op_material_issue ||--o{ op_material_receipt : confirmed_by
  op_material_receipt ||--o{ op_material_receipt_line : has
  op_material_receipt_line ||--o{ op_material_receipt_variance : variance
  op_material_issue_line ||--o{ op_batch_material_usage : consumes
  op_batch ||--o{ op_batch_material_usage : uses

  op_batch ||--o{ op_packaging_job : packaged_by
  op_packaging_job ||--o{ op_packaging_unit : creates
  op_trade_item ||--o{ op_packaging_unit : identifies
  op_trade_item ||--o{ op_trade_item_gtin : has
  op_packaging_unit ||--o{ op_print_job : printed_by
  op_print_job ||--o{ op_print_log : logs
  op_packaging_unit ||--o{ op_qr_registry : labels
  op_qr_registry ||--o{ op_qr_state_history : history

  op_batch ||--o{ op_qc_inspection : inspected
  op_qc_inspection ||--o{ op_qc_inspection_item : has
  op_batch ||--o{ op_batch_disposition : disposition
  op_batch ||--o{ op_batch_release : release
  op_batch_release ||--o{ op_warehouse_receipt : enables

  op_warehouse_receipt ||--o{ op_warehouse_receipt_line : has
  op_packaging_unit ||--o{ op_warehouse_receipt_line : received
  op_inventory_ledger ||--o{ op_inventory_lot_balance : projects
  op_inventory_lot_balance ||--o{ op_inventory_allocation : allocates
  ref_adjustment_reason ||--o{ op_inventory_adjustment : explains

  op_trace_link }o--|| op_trace_search_index : indexes
  op_batch ||--o{ op_recall_case_batch : affected
  op_incident_case ||--o{ op_recall_case : opens
  op_recall_case ||--o{ op_recall_case_batch : includes
  op_recall_case ||--o{ op_recall_exposure_snapshot : snapshots
  op_recall_case ||--o{ op_batch_hold_registry : holds
  op_recall_case ||--o{ op_sale_lock_registry : locks
  op_recall_case ||--o{ op_recall_recovery_item : recovers
  op_recall_case ||--o{ op_recall_disposition_record : disposes
  op_recall_case ||--o{ op_recall_capa : capa
  op_recall_capa ||--o{ op_recall_capa_evidence : evidence
  op_recall_case ||--o{ op_recall_timeline : timeline

  outbox_event ||--o{ misa_sync_event : consumed_by
  misa_sync_event ||--o{ misa_sync_log : logs
  misa_sync_event ||--o{ misa_reconcile_record : reconciles
  misa_mapping ||--o{ misa_sync_event : maps

  op_alert_rule ||--o{ op_alert_event : triggers
  ui_screen_registry ||--o{ ui_action_registry : has
  ui_screen_registry ||--o{ ui_menu_item : menu
  ui_screen_registry ||--o{ ui_form_schema : forms
  ui_screen_registry ||--o{ ui_table_view_config : tables
  op_form_template ||--o{ op_form_instance : instantiates
  op_form_instance ||--o{ op_form_action_log : actions
```

## 2. Notes

- `op_raw_material_lot.lot_qc_status` is the QC result; `op_raw_material_lot.lot_status` is the lifecycle/readiness state. Material issue selection requires `lot_status = READY_FOR_PRODUCTION`.
- Allowed operational object types for polymorphic `object_type/object_id` and `item_type/item_id` checks include: `SOURCE_ORIGIN`, `RAW_MATERIAL_LOT`, `PRODUCTION_ORDER`, `MATERIAL_ISSUE`, `BATCH`, `PACKAGING_UNIT`, `QR`, `QC_INSPECTION`, `BATCH_RELEASE`, `WAREHOUSE_RECEIPT`, `INVENTORY_LEDGER`, `RECALL_CASE`.
- `vw_internal_traceability` và `vw_public_traceability` là view/projection từ `op_trace_link`, `op_trace_search_index`, `op_public_trace_policy` và transaction tables.
- Polymorphic columns như `object_type/object_id`, `item_type/item_id` cần check constraint về allowed object types và app-level FK validation hoặc typed link table nếu implementation chọn chặt hơn.
- `op_inventory_lot_balance` là projection từ `op_inventory_ledger`; không dùng thay ledger history.
