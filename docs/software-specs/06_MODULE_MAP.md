# 06 - Module Map

> Mục tiêu: thống nhất module cuối cùng cho `docs/software-specs/`, không để lệch giữa cây `modules/` theo prompt gốc và phase CODE01-CODE17.

## 1. Nguyên Tắc Module

- Module là bounded capability để BA/SA/Dev/QA lập đặc tả, triển khai và test.
- CODE01-CODE17 là phase delivery; một CODE có thể chạm nhiều module.
- Không dùng module legacy `M1`, `M2`, `MX*` làm module chính thức trong cây chuẩn; chúng chỉ còn là mapping lịch sử trong [00_LEGACY_FILE_MAPPING.md](00_LEGACY_FILE_MAPPING.md).
- Module chuẩn phải map được sang database, API, UI, workflow, test và done gate.

## 2. Danh Sách 16 Module Chuẩn

| Module ID | File                                   | Tên module             | Mục đích                                                                                      | Source chính                                          |
| --------- | -------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| M01       | `modules/01_FOUNDATION_CORE.md`        | Foundation Core        | Audit, event/outbox, idempotency, error convention, base governance, append-only rules.       | `SRC-FILE05`, `SRC-FILE04-1`                          |
| M02       | `modules/02_AUTH_PERMISSION.md`        | Auth Permission        | Local account/RBAC, role/action permission, approval gate, screen/action permission.          | `SRC-FILE03`, `SRC-FORM-AUTO`, owner OD-15            |
| M03       | `modules/03_MASTER_DATA.md`            | Master Data            | UOM, warehouse, supplier/reference config, reason/config chung không thuộc SKU/recipe riêng.  | `SRC-FILE02`, `HIST-SPECS` fallback                   |
| M04       | `modules/04_SKU_INGREDIENT_RECIPE.md`  | SKU Ingredient Recipe  | 20 SKU baseline, ingredient master, G1 recipe, recipe versioning, production snapshot source. | `SRC-FILE02`, `SRC-RECIPE-NEW`, `SRC-LOCK5`           |
| M05       | `modules/05_SOURCE_ORIGIN.md`          | Source Origin          | Source zone, source origin, evidence, verification, public source fields.                     | `SRC-FILE01`, `SRC-FILE02`                            |
| M06       | `modules/06_RAW_MATERIAL.md`           | Raw Material           | Raw material intake, receipt, lot, incoming QC, procurement type, raw inventory receipt.      | `SRC-FILE03`, `SRC-FORM-AUTO`                         |
| M07       | `modules/07_PRODUCTION.md`             | Production             | Production order, work order, required process events, batch creation, genealogy root.        | `SRC-FILE01`, `SRC-FILE03`, `SRC-PRINT-CMD`           |
| M08       | `modules/08_MATERIAL_ISSUE_RECEIPT.md` | Material Issue Receipt | Material request/approval, issue execution, material receipt confirmation, variance.          | `SRC-FILE01`, `SRC-FILE03`, `SRC-FORM-AUTO`           |
| M09       | `modules/09_QC_RELEASE.md`             | QC Release             | Incoming/post-process/finished QC, disposition, batch release record/action.                  | `SRC-FILE03`, `SRC-FORM-AUTO`, `SRC-LOCK5`            |
| M10       | `modules/10_PACKAGING_PRINTING.md`     | Packaging Printing     | Packaging level, print job, QR registry, reprint, trade item/GTIN handoff.                    | `SRC-FILE01`, `SRC-FILE03`, `SRC-FORM-AUTO`           |
| M11       | `modules/11_WAREHOUSE_INVENTORY.md`    | Warehouse Inventory    | Warehouse receipt, inventory ledger, lot balance, allocation references.                      | `SRC-FILE01`, `SRC-FILE03`, `SRC-FILE05`              |
| M12       | `modules/12_TRACEABILITY.md`           | Traceability           | Internal trace, public trace, genealogy search, field policy.                                 | `SRC-FILE01`, `SRC-FORM-AUTO`                         |
| M13       | `modules/13_RECALL.md`                 | Recall                 | Incident, recall case, hold, sale lock, exposure, recovery, disposition, CAPA, CAPA evidence. | `SRC-FILE01`, `SRC-FILE03`, owner decision 2026-04-29 |
| M14       | `modules/14_MISA_INTEGRATION.md`       | MISA Integration       | Mapping, sync event/log, retry, reconcile, audit.                                             | `SRC-FILE01`, `SRC-FORM-AUTO`, owner OD-04            |
| M15       | `modules/15_REPORTING_DASHBOARD.md`    | Reporting Dashboard    | Operational dashboard, alert/health, monitoring summary.                                      | `SRC-FILE04-1`, `HIST-SPECS` fallback                 |
| M16       | `modules/16_ADMIN_UI.md`               | Admin UI               | Menu/sidebar, screen catalog, forms, tables, action state, API client contract.               | `SRC-FILE03`, `SRC-FILE04-1`, `HIST-SPECS` fallback   |

### 2.1. Sub-Capability Đăng Ký Ngoài Numbering M01-M16

Không tạo M17 mới. Đăng ký sub-capability sau và bind cứng vào M03/M02/M16:

| Module ID | File                                 | Tên module          | Mục đích                                                                                                                                                                                                                               | Source chính                                                                                                                                          |
| --------- | ------------------------------------ | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| M03A      | `modules/03A_SUPPLIER_MANAGEMENT.md` | Supplier Management | Supplier master extension, supplier user (`user_type = SUPPLIER_USER`) + role `R_SUPPLIER`, supplier-ingredient capability/policy (`op_supplier_ingredient`), Supplier Portal foundation (auth, scope, IA). M06 chỉ consume read-only. | `OD-MODULE-M03A-001`, `OD-M03-SUP-ING-001`, `docs/v2-decisions/OD-M06-SUP-COLLAB.md`, `docs/DAC_TA_NGHIEP_VU_SUPPLIER_COLLAB_RAW_MATERIAL_RECEIPT.md` |

M03A là sub-capability của nhóm Master Data/Auth/Admin UI, không phá numbering 16 module chuẩn. Phase delivery: `CODE01A` (depend `CODE01`) trước `CODE02`.

## 3. Module Dependency Flow

```text
M01 Foundation Core
  ├─ M02 Auth Permission
  ├─ M03 Master Data
  ├─ M03A Supplier Management (sub-capability M02 + M03 + M16)
  └─ M16 Admin UI foundation

M04 SKU Ingredient Recipe
  ↓
M05 Source Origin → M06 Raw Material (consume M03A supplier-ingredient mapping read-only) → M08 Material Issue Receipt
                                      ↓
                                  M07 Production
                                      ↓
                                  M10 Packaging Printing
                                      ↓
                                  M09 QC Release
                                      ↓
                                  M11 Warehouse Inventory
                                      ↓
                                  M12 Traceability
                                      ↓
                                  M13 Recall

Cross-cutting:
M14 MISA Integration
M15 Reporting Dashboard
M16 Admin UI
M03A Supplier Management (Supplier Portal IA + Admin Supplier Mgmt screens)
```

## 4. CODE Phase → Module Mapping

| CODE   | Phase goal                                                                        | Module chính | Module phụ thuộc/cross-cutting              |
| ------ | --------------------------------------------------------------------------------- | ------------ | ------------------------------------------- |
| CODE01 | Foundation + Source Origin                                                        | M01, M05     | M02, M03, M16                               |
| CODE02 | Raw Material Intake + Lot + Incoming QC                                           | M06          | M01, M02, M03, M05, M11, M16                |
| CODE03 | Manufacturing Execution + Batch + Genealogy Foundation                            | M07, M08     | M01, M02, M04, M06, M11, M12, M16           |
| CODE04 | Packaging & Printing Control                                                      | M10          | M01, M02, M04, M07, M14, M16                |
| CODE05 | QC & Batch Release                                                                | M09          | M01, M02, M07, M10, M11, M16                |
| CODE06 | Warehouse Receipt & Inventory Control                                             | M11          | M01, M02, M09, M12, M14, M16                |
| CODE07 | Traceability & Batch Genealogy Engine                                             | M12          | M01, M02, M05, M06, M07, M08, M10, M11, M16 |
| CODE08 | Recall & Product Recovery Engine                                                  | M13          | M01, M02, M11, M12, M14, M16                |
| CODE09 | Role-Based Admin UI Engine + Screen Registry + Permission                         | M02, M16     | M01, all workflow modules                   |
| CODE10 | API Contract + Query/Command Boundary + Error/Permission/Audit Middleware         | M01          | M02, all API-owning modules                 |
| CODE11 | Mobile/Internal App Contract + Offline/Idempotency + Device Header Standard       | M16          | M01, M02, M06, M08, M10                     |
| CODE12 | Device/Printer/IoT Integration + Heartbeat + Error/Incident Bridge                | M10          | M01, M02, M14, M15                          |
| CODE13 | Event Schema Registry + Outbox/Event Bus Adapter + Compatibility Lock             | M01, M14     | All event producers/consumers               |
| CODE14 | Monitoring/Alert Rule Engine + Incident Response + Dashboard Health               | M15          | M01, M14, M16                               |
| CODE15 | Manual Override + Break-Glass + Human-in-the-Loop Governance                      | M01, M02     | M09, M11, M13, M16                          |
| CODE16 | Data Retention + Archival + Restore / Archive Search Boundary                     | M01          | M11, M12, M13, M14, M15                     |
| CODE17 | Final Close-Out Gate + Integration Smoke + Release Readiness + Handover Checklist | All          | All                                         |

## 5. Module → Database Area

| Module | Tables/views dự kiến                                                                                                                                                                                                    |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| M01    | `audit_log`, `idempotency_registry`, `event_schema_registry`, `outbox_event`, `event_store`, `state_transition_log`                                                                                                     |
| M02    | `auth_user`, `auth_role`, `auth_permission`, `auth_user_role`, `role_action_permission`, `approval_policy`                                                                                                              |
| M03    | `ref_uom`, `op_supplier`, `op_warehouse`, `op_warehouse_location`, `ref_adjustment_reason`, `op_config`                                                                                                                 |
| M03A   | `op_supplier_ingredient` (sở hữu); mở rộng `auth_user`/`op_supplier_user` với `user_type = SUPPLIER_USER`; future `op_supplier_evidence_policy`. Tham chiếu `op_supplier` (M03) và `ref_ingredient` (M04).              |
| M04    | `ref_sku`, `ref_ingredient`, `ref_ingredient_alias`, `ref_recipe_line_group`, `op_production_recipe`, `op_recipe_ingredient`, `ref_sku_operational_config`                                                              |
| M05    | `op_source_zone`, `op_source_origin`, `op_source_origin_evidence`, `op_source_origin_verification`                                                                                                                      |
| M06    | `op_raw_material_receipt`, `op_raw_material_receipt_item`, `op_raw_material_receipt_evidence`, `op_raw_material_receipt_feedback`, `op_raw_material_lot`, `op_raw_material_qc_inspection`                               |
| M07    | `op_production_order`, `op_production_order_item`, `op_work_order`, `op_production_process_event`, `op_batch`, `op_batch_material_usage`                                                                                |
| M08    | `op_material_request`, `op_material_issue`, `op_material_issue_line`, `op_material_receipt`, `op_material_receipt_variance`                                                                                             |
| M09    | `op_qc_inspection`, `op_qc_inspection_item`, `op_batch_disposition`, `op_batch_release`, `op_batch_state_transition_log`                                                                                                |
| M10    | `op_trade_item`, `op_trade_item_gtin`, `op_packaging_job`, `op_packaging_unit`, `op_print_job`, `op_print_log`, `op_qr_registry`, `op_qr_state_history`                                                                 |
| M11    | `op_warehouse_receipt`, `op_inventory_ledger`, `op_inventory_lot_balance`, `op_inventory_allocation`, `op_inventory_adjustment`                                                                                         |
| M12    | `op_trace_link`, `op_batch_genealogy_link`, `op_trace_search_index`, `vw_internal_traceability`, `vw_public_traceability`                                                                                               |
| M13    | `op_incident_case`, `op_recall_case`, `op_recall_case_batch`, `op_batch_hold_registry`, `op_sale_lock_registry`, `op_recall_recovery_item`, `op_recall_disposition_record`, `op_recall_capa`, `op_recall_capa_evidence` |
| M14    | `misa_mapping`, `misa_sync_event`, `misa_sync_log`, `misa_reconcile_record`                                                                                                                                             |
| M15    | `op_dashboard_metric`, `op_alert_rule`, `op_alert_event`, `op_health_snapshot`                                                                                                                                          |
| M16    | `ui_screen_registry`, `ui_action_registry`, `ui_menu_item`, `ui_form_schema`, `ui_table_view_config`                                                                                                                    |

## 6. Module → API Route Family

| Module | Route family                                                                                                                                                                                                                                 |
| ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| M01    | `/api/admin/system/*`, `/api/admin/events/*`, `/api/admin/audit/*`                                                                                                                                                                           |
| M02    | `/api/admin/auth/*`, `/api/admin/roles/*`, `/api/admin/permissions/*`                                                                                                                                                                        |
| M03    | `/api/admin/master-data/*`                                                                                                                                                                                                                   |
| M03A   | `/api/admin/suppliers/*` (supplier CRUD, supplier user lifecycle create/reset/lock/unlock, `op_supplier_ingredient` CRUD/approve), `/api/supplier/auth/*`, `/api/supplier/raw-material/intakes/*` (Supplier Portal scope theo `supplier_id`) |
| M04    | `/api/admin/master-data/skus/*`, `/api/admin/master-data/ingredients/*`, `/api/admin/master-data/recipes/*`                                                                                                                                  |
| M05    | `/api/admin/source-zones/*`, `/api/admin/source-origins/*`                                                                                                                                                                                   |
| M06    | `/api/admin/raw-material/intakes/*` (mở rộng action `submit/request-supplier-evidence/supplier-confirmation/receive/start-qc/qc-result/return/cancel/evidence`), `/api/admin/raw-material/lots/*`, `/api/admin/raw-material/qc/*`            |
| M07    | `/api/admin/production/orders/*`, `/api/admin/production/work-orders/*`, `/api/admin/production/batches/*`                                                                                                                                   |
| M08    | `/api/admin/production/material-requests/*`, `/api/admin/production/material-issues/*`, `/api/admin/production/material-receipts/*`                                                                                                          |
| M09    | `/api/admin/qc/inspections/*`, `/api/admin/qc/releases/*`                                                                                                                                                                                    |
| M10    | `/api/admin/packaging/*`, `/api/admin/printing/*`, `/api/admin/qr/*`, `/api/admin/trade-items/*`                                                                                                                                             |
| M11    | `/api/admin/warehouse/*`, `/api/admin/inventory/*`                                                                                                                                                                                           |
| M12    | `/api/admin/trace/*`, `/api/public/trace/*`                                                                                                                                                                                                  |
| M13    | `/api/admin/incidents/*`, `/api/admin/recall/*`                                                                                                                                                                                              |
| M14    | `/api/admin/integrations/misa/*`                                                                                                                                                                                                             |
| M15    | `/api/admin/reports/*`, `/api/admin/dashboard/*`, `/api/admin/alerts/*`                                                                                                                                                                      |
| M16    | `/api/admin/ui/*`                                                                                                                                                                                                                            |

## 7. Module → UI Screen Group

| Module | Screen group                                                                                                                                                                                               |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| M01    | System audit, event/outbox, idempotency diagnostics                                                                                                                                                        |
| M02    | User, role, permission, approval policy                                                                                                                                                                    |
| M03    | Master data reference                                                                                                                                                                                      |
| M03A   | Supplier Management (admin): supplier list/detail, supplier user lifecycle, supplier-ingredient mapping/policy. Supplier Portal: login, raw-material intake list/detail, evidence upload, confirm/decline. |
| M04    | SKU, ingredient, recipe, formula version                                                                                                                                                                   |
| M05    | Source zone, source origin verification                                                                                                                                                                    |
| M06    | Raw material intake (admin pre-receipt + receive + line QC + evidence review + feedback), raw material QC, raw lot                                                                                         |
| M07    | Production order, work order, batch execution                                                                                                                                                              |
| M08    | Material request, issue execution, receipt confirmation                                                                                                                                                    |
| M09    | QC inspection, batch release                                                                                                                                                                               |
| M10    | Packaging, print queue, QR lifecycle, trade item/GTIN                                                                                                                                                      |
| M11    | Warehouse receipt, inventory ledger, lot balance                                                                                                                                                           |
| M12    | Internal trace, public trace preview, genealogy                                                                                                                                                            |
| M13    | Incident, recall case, recovery, disposition, CAPA, CAPA evidence                                                                                                                                          |
| M14    | MISA mapping, sync queue, reconcile                                                                                                                                                                        |
| M15    | Dashboard, alert, health                                                                                                                                                                                   |
| M16    | Menu/sidebar, screen registry, form/table/action registry                                                                                                                                                  |

## 8. Hard Locks Giữa Module

| From | To  | Lock                                                                                                                                                                                                                 |
| ---- | --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| M04  | M07 | Production order chỉ mở khi SKU có active operational formula/version và snapshot được.                                                                                                                              |
| M05  | M06 | Lot `SELF_GROWN` phải có source origin `VERIFIED`.                                                                                                                                                                   |
| M03A | M06 | M06 chỉ consume `op_supplier_ingredient` read-only; supplier chỉ tạo receipt item khi mapping `ACTIVE` và còn `effective_from/to` (HL-SUP-002, HL-SUP-013).                                                          |
| M03A | M02 | Supplier user dùng `user_type = SUPPLIER_USER` + role `R_SUPPLIER`; namespace `supplier.*` tách hẳn, không kế thừa `raw_intake.read` của staff role (HL-SUP-007, HL-SUP-008).                                        |
| M06  | M06 | Lot chỉ tạo khi action `receive` chuyển phiếu sang `RECEIVED_PENDING_QC`; khởi tạo `lot_status = CREATED` + `lot_qc_status = PENDING_QC`; `SUM(lot.initial_quantity) <= received_quantity` (HL-SUP-004, HL-SUP-014). |
| M06  | M12 | Supplier evidence và receipt evidence không expose qua public trace; whitelist DTO/projection (HL-SUP-017, OD-M12-PTRACE-SUP-EVIDENCE-001).                                                                          |
| M06  | M08 | Chỉ raw material lot `QC_PASS` (đã `RAW_LOT_MARK_READY` → `READY_FOR_PRODUCTION`) mới được issue; phần `rejected`/`returned` không tạo lot usable (HL-SUP-010).                                                      |
| M08  | M11 | Material Issue Execution tạo raw inventory decrement. Receipt confirmation không decrement.                                                                                                                          |
| M07  | M10 | Packaging chỉ mở sau production/batch đủ điều kiện.                                                                                                                                                                  |
| M10  | M12 | QR `VOID`/`FAILED` không public trace như valid QR.                                                                                                                                                                  |
| M09  | M11 | Warehouse receipt chỉ nhận batch `RELEASED`.                                                                                                                                                                         |
| M11  | M12 | Trace/recall dùng ledger/balance/receipt như evidence downstream.                                                                                                                                                    |
| M12  | M13 | Recall reuse trace/exposure snapshot, không tạo trace truth song song.                                                                                                                                               |
| M14  | All | Module nghiệp vụ phát event; MISA integration layer xử lý sync/retry/reconcile.                                                                                                                                      |
