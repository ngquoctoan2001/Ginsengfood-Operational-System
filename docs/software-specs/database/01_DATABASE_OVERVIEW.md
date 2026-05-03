# Database Overview

> Mục đích: định nghĩa database target cho Operational Domain để DBA/backend có thể chuyển thành migration/schema. Đây là spec đích, không phải đối chiếu implementation hiện hữu.

## 1. Design Principles

| principle_id | Principle                    | DB impact                                                                                                                                                                   |
| ------------ | ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DBP-001      | Source policy locked         | Schema theo `docs/software-specs/database`, các pack operational đã chốt và extract được owner cung cấp; current code/schema không phải source of truth cho batch docs này. |
| DBP-002      | Text enum + check constraint | Trạng thái lưu `text`, ràng buộc bằng `CHECK` để migration linh hoạt.                                                                                                       |
| DBP-003      | UUID primary key             | Transaction/audit/integration tables dùng `uuid` PK trừ bảng reference có natural code.                                                                                     |
| DBP-004      | Business key unique          | SKU code, ingredient code, QR code, GTIN, idempotency key phải unique theo scope.                                                                                           |
| DBP-005      | Append-only evidence         | `audit_log`, `state_transition_log`, `op_inventory_ledger`, QR history, recall exposure snapshot không update/delete nghiệp vụ.                                             |
| DBP-006      | Snapshot required            | Production order snapshot, print snapshot, recall impact snapshot lưu dữ liệu tại thời điểm action.                                                                         |
| DBP-007      | Balance projection           | `op_inventory_lot_balance` là projection từ ledger, không là nguồn lịch sử.                                                                                                 |
| DBP-008      | Public/private separation    | Public trace dùng projection/view/policy riêng.                                                                                                                             |
| DBP-009      | Integration decoupled        | MISA dùng `outbox_event` + `misa_*`, module nghiệp vụ không giữ sync logic riêng.                                                                                           |
| DBP-010      | Idempotent commands          | High-risk command dùng `idempotency_registry`.                                                                                                                              |

## 2. Table Manifest Reconciliation

`database/03_TABLE_SPECIFICATION.md` là manifest schema authoritative để scaffold migration. Khi đếm theo manifest hiện tại:

| Metric                  | Count | Source of truth                      | Notes                                                                                                                                                                                                                                                                                       |
| ----------------------- | ----: | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Physical tables         |   102 | `database/03_TABLE_SPECIFICATION.md` | Không tính các `vw_*` projection/view. **Reconcile verified 2026-05-04**: grep manifest đếm đủ 102 dòng phân theo prefix: `op_` 72, `ref_` 7, `ui_` 5, `auth_` 4, `misa_` 4, `approval_` 3, `event_` 2, `audit_` 1, `idempotency_` 1, `outbox_` 1, `role_` 1, `state_` 1. Khớp với số tổng. |
| View/projection objects |     5 | `database/03_TABLE_SPECIFICATION.md` | `vw_batch_release_readiness`, `vw_internal_traceability`, `vw_inventory_balance_current`, `vw_public_traceability`, `vw_recall_exposure_current`.                                                                                                                                           |
| Total schema objects    |   107 | `database/03_TABLE_SPECIFICATION.md` | Dùng để reconcile với ERD và migration manifest.                                                                                                                                                                                                                                            |

`database/02_ERD.md` là logical ERD để thể hiện dependency chính, không phải bảng đếm đầy đủ. Nếu ERD, overview summary hoặc migration manifest lệch nhau, DBA/backend phải lấy `database/03_TABLE_SPECIFICATION.md` làm nguồn đếm và cập nhật lại tài liệu còn lại trước scaffold.

## 3. Table Categories

Các dòng dưới đây là summary theo domain để đọc nhanh, không phải danh sách exhaustive. Migration scaffold phải dùng manifest đầy đủ trong `database/03_TABLE_SPECIFICATION.md`.

| Category            | Tables                                                                                                                                                                                                                                                                                                                                                                   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Master              | `ref_uom`, `op_supplier`, `op_warehouse`, `op_warehouse_location`, `ref_sku`, `ref_ingredient`, `ref_ingredient_alias`, `ref_recipe_line_group`, `op_trade_item`, `op_trade_item_gtin`                                                                                                                                                                                   |
| Config              | `op_config`, `ref_adjustment_reason`, `ref_sku_operational_config`, `approval_policy`, `ui_screen_registry`, `ui_action_registry`, `ui_menu_item`, `ui_form_schema`, `ui_table_view_config`, `op_public_trace_policy`                                                                                                                                                    |
| Transaction         | `op_source_origin`, `op_raw_material_receipt`, `op_raw_material_lot`, `op_production_order`, `op_work_order`, `op_batch`, `op_material_request`, `op_material_issue`, `op_material_receipt`, `op_packaging_job`, `op_qc_inspection`, `op_batch_release`, `op_warehouse_receipt`, `op_incident_case`, `op_recall_case`, `op_batch_hold_registry`, `op_sale_lock_registry` |
| Snapshot            | `op_production_order_item`, `op_print_job.print_payload_snapshot`, `op_recall_exposure_snapshot`                                                                                                                                                                                                                                                                         |
| Ledger              | `op_inventory_ledger`                                                                                                                                                                                                                                                                                                                                                    |
| Projection          | `op_inventory_lot_balance`, `op_trace_search_index`, `op_dashboard_metric`, `op_health_snapshot`, `vw_internal_traceability`, `vw_public_traceability`                                                                                                                                                                                                                   |
| Audit/history       | `audit_log`, `state_transition_log`, `op_qr_state_history`, `op_print_log`, `op_form_action_log`, `op_recall_timeline`                                                                                                                                                                                                                                                   |
| Mapping/integration | `event_schema_registry`, `outbox_event`, `event_store`, `misa_mapping`, `misa_sync_event`, `misa_sync_log`, `misa_reconcile_record`                                                                                                                                                                                                                                      |
| Workflow/form       | `approval_request`, `approval_action`, `op_form_template`, `op_form_instance`                                                                                                                                                                                                                                                                                            |

## 4. Cross-Cutting Columns

Mutable business tables should include:

| column           | type          | Rule                                  |
| ---------------- | ------------- | ------------------------------------- |
| `created_at`     | `timestamptz` | NOT NULL DEFAULT now()                |
| `created_by`     | `uuid`/`text` | User reference when actor exists      |
| `updated_at`     | `timestamptz` | Nullable or maintained by app         |
| `updated_by`     | `uuid`/`text` | Nullable                              |
| `status`         | `text`        | Check constraint per enum             |
| `version_no`     | `int`         | Optional optimistic/versioned records |
| `correlation_id` | `text`        | For command/workflow tracing          |

Append-only tables should include:

| column           | type          | Rule                                        |
| ---------------- | ------------- | ------------------------------------------- |
| `created_at`     | `timestamptz` | Insert timestamp                            |
| `actor_user_id`  | `uuid`/`text` | Actor if user action                        |
| `source_channel` | `text`        | `ADMIN_WEB`, `PWA`, `SYSTEM`, `INTEGRATION` |
| `correlation_id` | `text`        | Required for command actions                |

## 5. Schema Readiness Gates

| gate              | Required DB capability                                                                                                                                           |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Gate-SKU-recipe   | 20 SKU, required ingredients, G1 active recipes, 4 recipe groups; G0 is research/baseline only and must not be active operational.                               |
| Gate-source-raw   | Source origin verification, procurement type constraints, incoming QC result and raw `lot_status` lifecycle with `READY_FOR_PRODUCTION` distinct from `QC_PASS`. |
| Gate-production   | PO snapshot immutable, process event order support, batch genealogy.                                                                                             |
| Gate-inventory    | Material issue ledger debit only on executed issue; warehouse receipt ledger credit only after approved batch release; append-only ledger.                       |
| Gate-QC-release   | Separate QC inspection and batch release records.                                                                                                                |
| Gate-trace-recall | Trace links, genealogy, public policy, recall exposure snapshot, hold/sale lock.                                                                                 |
| Gate-integration  | Outbox, event schema registry, MISA mapping/sync/reconcile.                                                                                                      |
| Gate-UI-workflow  | Role/action/screen registry, approval request/action, form template/instance/action log.                                                                         |
