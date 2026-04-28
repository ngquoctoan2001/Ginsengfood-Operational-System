# Migration Strategy

> Mục đích: hướng dẫn DBA/backend chuyển DB spec thành migration an toàn, có thứ tự, có validation và rollback/restore gate.

## 1. Migration Principles

| principle_id | Principle |
| --- | --- |
| MIG-001 | Migration phải chạy theo dependency order: foundation -> master -> transaction -> trace/recall -> integration/projection. |
| MIG-002 | Mỗi migration có forward script, validation check và rollback/restore note. |
| MIG-003 | Check/unique/FK constraints tạo cùng migration nếu dữ liệu seed/transaction cho phép. |
| MIG-004 | Append-only guard tạo trước khi production data ghi vào bảng. |
| MIG-005 | Seed migration idempotent, tách dev fixture và production baseline. |
| MIG-006 | Không seed G0/research/baseline token làm operational; G0 không được `APPROVED` hoặc `ACTIVE_OPERATIONAL`. |

## 2. Recommended Migration Order

| order | Migration group | Tables |
| --- | --- | --- |
| 01 | Foundation/auth/audit | `auth_*`, `role_action_permission`, `approval_policy`, `approval_request`, `approval_action`, `audit_log`, `state_transition_log`, `idempotency_registry` |
| 02 | Event/outbox | `event_schema_registry`, `outbox_event`, `event_store` |
| 03 | Master data | `ref_uom`, `op_supplier`, `op_warehouse`, `op_warehouse_location`, `ref_adjustment_reason`, `op_config` |
| 04 | SKU/ingredient/recipe | `ref_sku`, `ref_ingredient`, `ref_ingredient_alias`, `ref_recipe_line_group`, `op_production_recipe`, `op_recipe_ingredient`, `ref_sku_operational_config` |
| 05 | Source origin | `op_source_zone`, `op_source_origin`, `op_source_origin_evidence`, `op_source_origin_verification` |
| 06 | Raw material/QC | `op_raw_material_receipt`, `op_raw_material_receipt_item`, `op_raw_material_lot`, `op_raw_material_qc_inspection` |
| 07 | Production/material | `op_production_order`, `op_production_order_item`, `op_work_order`, `op_batch`, `op_production_process_event`, `op_material_*`, `op_batch_material_usage`; create `op_batch` and material issue/line tables before `op_batch_material_usage` |
| 08 | Packaging/QR | `op_trade_item`, `op_trade_item_gtin`, `op_packaging_job`, `op_packaging_unit`, `op_print_job`, `op_print_log`, `op_qr_registry`, `op_qr_state_history`, `op_device_registry` |
| 09 | QC/release/warehouse/inventory | `op_qc_inspection`, `op_qc_inspection_item`, `op_batch_disposition`, `op_batch_release`, `op_warehouse_receipt`, `op_warehouse_receipt_line`, `op_inventory_*`; include warehouse receipt guard requiring `APPROVED_RELEASED` release record |
| 10 | Trace/recall | `op_trace_link`, `op_batch_genealogy_link`, `op_trace_search_index`, `op_public_trace_policy`, recall/hold/sale lock tables |
| 11 | MISA integration | `misa_mapping`, `misa_sync_event`, `misa_sync_log`, `misa_reconcile_record` |
| 12 | Dashboard/UI/forms | `op_dashboard_metric`, `op_alert_*`, `op_health_snapshot`, `ui_*`, `op_form_*` |
| 13 | Views/projections | `vw_internal_traceability`, `vw_public_traceability`, dashboard projections |
| 14 | Seed baseline | Run ordered seeds: `01_uom` -> `02_roles_permissions` -> `03_warehouses` -> `04_recipe_groups` -> `05_ingredients` -> `06_sku` -> `07_g1_recipes` -> `08_sku_config` -> `09_event_schemas` -> `10_public_trace_policy` -> `11_gtin_fixture` -> `12_misa_fixture` |
| 15 | Validation gates | Seed validation, forbidden-baseline guard, append-only guard tests, public leakage checks |

## 3. Migration Validation

| validation | Required command/check |
| --- | --- |
| Schema compile | All migrations apply to empty DB. |
| FK/check validation | Insert invalid enum/procurement/recipe group fails. |
| Forbidden-baseline validation | Active/approved research baseline recipe insert fails or seed validation fails. |
| Raw lot readiness validation | `lot_status` exists and is distinct from `lot_qc_status`; material issue attempt against `QC_PASS` but non-`READY_FOR_PRODUCTION` lot fails with readiness error. |
| Warehouse release validation | Warehouse receipt insert/confirm fails unless the referenced batch has `op_batch_release.release_status = APPROVED_RELEASED`. |
| Append-only validation | UPDATE/DELETE on ledger/audit/state history rejected. |
| Idempotency validation | Duplicate scope/key rejected or returns existing record policy. |
| Seed validation | Run seed twice; no duplicates; 20 SKU/G1/4 groups present. |
| Public trace leakage | Public view/API projection excludes forbidden fields. |
| Restore validation | Restore drill before CODE16/CODE17 production readiness/final handover close. |

## 4. Rollback / Restore Policy

| scenario | Strategy |
| --- | --- |
| Pre-production migration failure | Roll back schema migration if no data, or recreate dev DB. |
| Production migration failure before write | Use transactional DDL where possible; stop deploy. |
| Production migration after data write | Prefer forward fix migration; do not destructive rollback operational data. |
| Bad seed | Correct with idempotent seed fix migration; do not delete transaction data. |
| Bad ledger/audit data | Correction/reversal migration with audit note, not in-place mutation unless owner-approved data repair. |

## 5. Handoff To Implementation

- Each migration must cite the spec section/table names it implements.
- Each table must include PK, FK, unique/check constraints from [05_INDEX_CONSTRAINT_REFERENCE.md](05_INDEX_CONSTRAINT_REFERENCE.md).
- Each enum check must match [04_ENUM_REFERENCE.md](04_ENUM_REFERENCE.md).
- Each seed migration must map to [07_SEED_DATA_SPECIFICATION.md](07_SEED_DATA_SPECIFICATION.md).
- Current source code/schema is not source of truth for this docs batch; implementation phase may create a separate gap report.




