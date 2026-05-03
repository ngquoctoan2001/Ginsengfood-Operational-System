# Seed Data Specification

> Mục đích: định nghĩa seed baseline G1 và config tối thiểu. Seed phải idempotent, không seed G0/research/baseline token làm operational.

## 1. Seed Principles

| principle_id | Principle                                                                                                                                             |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| SEED-001     | Seed chain idempotent; chạy lại không tạo duplicate.                                                                                                  |
| SEED-002     | Không seed G0/research/baseline token làm active/approved operational formula; G0 nếu cần chỉ nằm ở archive/reference ngoài active operational chain. |
| SEED-003     | G1 là baseline go-live; future G2/G3 qua workflow versioning.                                                                                         |
| SEED-004     | Fake GTIN/MISA credentials phải đánh dấu fixture/dev only.                                                                                            |
| SEED-005     | Seed validation phải fail nếu thiếu hard lock data.                                                                                                   |

## 2. Required Seed Groups

| seed_group             | Tables                                                                                                                                             | Required data                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| UOM                    | `ref_uom`                                                                                                                                          | `kg`, `g`, `lít`, `ml`, `khay`, `gói`, `lọ`, `hũ`, `hộp`, `thùng`, `%`                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Roles/permissions      | `auth_role`, `auth_permission`, `role_action_permission`                                                                                           | Role codes in business role model; action codes for source/raw/recipe/PO/issue/QC/release/warehouse/trace/recall/MISA/override. Starter seed must include hard-lock action codes referenced by module specs, including `RAW_LOT_MARK_READY`, `BATCH_RELEASE_REVOKE`, `QR_REPRINT`, `QR_VOID`, M03A admin `supplier.*` permissions and external `R-SUPPLIER` scoped permissions.                                                                                                                                         |
| Warehouses             | `op_warehouse`, `op_warehouse_location`                                                                                                            | At least one `RAW_MATERIAL`, one `FINISHED_GOODS`                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Recipe groups          | `ref_recipe_line_group`                                                                                                                            | 4 groups with sort 10/20/30/40                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Ingredients            | `ref_ingredient`, `ref_ingredient_alias`                                                                                                           | Required `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`, `ING_THIT_HEO_NAC`; additional ingredients from G1 recipe source                                                                                                                                                                                                                                                                                                                                                                                                          |
| SKU baseline           | `ref_sku`, `ref_sku_operational_config`                                                                                                            | 20 SKU list below                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| G1 recipes             | `op_production_recipe`, `op_recipe_ingredient`                                                                                                     | Active operational G1 for each baseline SKU, 4 group lines                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Source sample          | `op_source_zone`, `op_source_origin`                                                                                                               | Dev/sample source zones; production actual owner-provided                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| GTIN fixture           | `op_trade_item`, `op_trade_item_gtin`                                                                                                              | BOX/CARTON fixture with `identifier_type` using real identifier categories (`GTIN_13`, `GTIN_14`, `SSCC`, `INTERNAL_BARCODE`) and `is_test_fixture=true` until real GTIN; do not encode fixture status as `identifier_type`.                                                                                                                                                                                                                                                                                         |
| UI/action              | `ui_screen_registry`, `ui_action_registry`, `ui_menu_item`                                                                                         | Screens/actions for modules M01-M16                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| Public trace policy    | `op_public_trace_policy`                                                                                                                           | Public allowed/forbidden field whitelist                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| Event schema           | `event_schema_registry`                                                                                                                            | Canonical events from architecture event catalog                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| MISA fixture           | `misa_mapping`, config/secret refs                                                                                                                 | Dev mapping/secret refs only, no real credential in seed                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| Supplier collab (M03A) | `auth_role`, `auth_permission`, `role_action_permission`, `op_supplier`, `op_supplier_user` (hoặc `auth_user` extension), `op_supplier_ingredient` | Seed role `R-SUPPLIER` + namespace permission `supplier.self.read`, `supplier.receipt.read`, `supplier.receipt.create`, `supplier.receipt.submit`, `supplier.receipt.confirm`, `supplier.receipt.decline`, `supplier.receipt.evidence.upload`, `supplier.receipt.cancel-draft`, `supplier.receipt.feedback.write`. Seed ít nhất 2 supplier dev fixture (`SUP_DEV_001`, `SUP_DEV_002`) với 1 supplier user mỗi supplier (mật khẩu tạm hash/ref, đánh dấu `is_dev_fixture = true`). Seed `op_supplier_ingredient` mapping cho ingredient `PURCHASED` baseline (xem Section 4A). |

## 3. 20 SKU Baseline

| sku_code             | sku_name_vi                    | sku_group_name     | sku_type | formula_code | formula_version |
| -------------------- | ------------------------------ | ------------------ | -------- | ------------ | --------------- |
| `A1/CS/DM/HS`        | Cháo Sâm - Diêm mạch & Hạt sen | Cháo sâm theo mùa  | `VEGAN`  | `FML-A1-G1`  | `G1`            |
| `A2/CS/BASA`         | Cháo Sâm - Cá Basa             | Cháo sâm theo mùa  | `SAVORY` | `FML-A2-G1`  | `G1`            |
| `A3/CS/CAHOI`        | Cháo Sâm - Cá hồi              | Cháo sâm theo mùa  | `SAVORY` | `FML-A3-G1`  | `G1`            |
| `A4/CS/LUON`         | Cháo Sâm - Lươn đồng           | Cháo sâm theo mùa  | `SAVORY` | `FML-A4-G1`  | `G1`            |
| `A5/CS/CUU`          | Cháo Sâm - Thịt cừu & Táo tàu  | Cháo sâm theo mùa  | `SAVORY` | `FML-A5-G1`  | `G1`            |
| `B1/CS/RM/ĐX`        | Cháo Sâm - Rau má & Đậu xanh   | Cháo sâm chức năng | `VEGAN`  | `FML-B1-G1`  | `G1`            |
| `B2/CS/DHA`          | Cháo Sâm - DHA Não bộ          | Cháo sâm chức năng | `SAVORY` | `FML-B2-G1`  | `G1`            |
| `B3/CS/CACOM`        | Cháo Sâm - Cá cơm & Vừng       | Cháo sâm chức năng | `SAVORY` | `FML-B3-G1`  | `G1`            |
| `B4/CS/COLAGEN`      | Cháo Sâm - Thịt heo & Da heo   | Cháo sâm chức năng | `SAVORY` | `FML-B4-G1`  | `G1`            |
| `B5/CS/SINHLUC`      | Cháo Sâm - Hàu biển            | Cháo sâm chức năng | `SAVORY` | `FML-B5-G1`  | `G1`            |
| `B6/CS/GAAC`         | Cháo Sâm - Gà ác               | Cháo sâm chức năng | `SAVORY` | `FML-B6-G1`  | `G1`            |
| `C1/CS/BAONGU`       | Cháo Sâm - Bào ngư             | Cháo sâm bổ dưỡng  | `SAVORY` | `FML-C1-G1`  | `G1`            |
| `C2/CS/DONGTRUNG`    | Cháo Sâm - Đông trùng hạ thảo  | Cháo sâm bổ dưỡng  | `VEGAN`  | `FML-C2-G1`  | `G1`            |
| `C3/CS/NAMDONGCO`    | Cháo Sâm - Nấm đông cô         | Cháo sâm bổ dưỡng  | `VEGAN`  | `FML-C3-G1`  | `G1`            |
| `C4/CS/CUABIEN`      | Cháo Sâm - Cua biển            | Cháo sâm bổ dưỡng  | `SAVORY` | `FML-C4-G1`  | `G1`            |
| `C5/CS/CANGU`        | Cháo Sâm - Cá ngừ              | Cháo sâm bổ dưỡng  | `SAVORY` | `FML-C5-G1`  | `G1`            |
| `C6/CS/TOM/RONGBIEN` | Cháo Sâm - Tôm & Rong biển     | Cháo sâm bổ dưỡng  | `SAVORY` | `FML-C6-G1`  | `G1`            |
| `C7/CS/THITGA`       | Cháo Sâm - Thịt gà             | Cháo sâm bổ dưỡng  | `SAVORY` | `FML-C7-G1`  | `G1`            |
| `C8/CS/THITHEO`      | Cháo Sâm - Thịt heo            | Cháo sâm bổ dưỡng  | `SAVORY` | `FML-C8-G1`  | `G1`            |
| `C9/CS/THITBO`       | Cháo Sâm - Thịt bò             | Cháo sâm bổ dưỡng  | `SAVORY` | `FML-C9-G1`  | `G1`            |

## 4. Recipe Group Seed

| group_code              | name_vi                        | sort_order |
| ----------------------- | ------------------------------ | ---------- |
| `SPECIAL_SKU_COMPONENT` | Thành phần đặc thù SKU         | 10         |
| `NUTRITION_BASE`        | Nguyên liệu nền dinh dưỡng     | 20         |
| `BROTH_EXTRACT`         | Rau củ chiết dịch tạo nước hầm | 30         |
| `SEASONING_FLAVOR`      | Nguyên liệu nêm & tạo hương vị | 40         |

## 4A. Supplier-Ingredient Mapping Seed (M03A, dev fixture)

Mục đích: cho phép dev/test luồng Supplier Portal cho ingredient `PURCHASED`. Seed phải idempotent và đánh dấu `is_dev_fixture = true`.

| supplier_code | ingredient_code    | default_uom_code | status   | requires_photo | requires_video | requires_coa | requires_lab_report | min_photo_count | min_video_count | effective_from | effective_to |
| ------------- | ------------------ | ---------------- | -------- | -------------- | -------------- | ------------ | ------------------- | --------------- | --------------- | -------------- | ------------ |
| `SUP_DEV_001` | `ING_MI_CHINH`     | `kg`             | `ACTIVE` | true           | false          | false        | false               | 1               | 0               | go-live        | NULL         |
| `SUP_DEV_001` | `ING_THIT_HEO_NAC` | `kg`             | `ACTIVE` | true           | false          | true         | false               | 2               | 0               | go-live        | NULL         |
| `SUP_DEV_002` | `HRB_SAM_SAVIGIN`  | `kg`             | `ACTIVE` | true           | true           | true         | true                | 2               | 1               | go-live        | NULL         |

Rule: seed mapping chỉ áp dụng cho ingredient có `procurement_type = PURCHASED` được phép. Ingredient `SELF_GROWN` (ví dụ rau củ vùng trồng) KHÔNG được seed mapping supplier. Production seed thật do owner cung cấp danh sách supplier-ingredient sau go-live.

## 5. Seed Validation Queries / Checks

| validation_id | Check                                                                                                                                                                                                                                                                                                                                                                |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SV-001        | Count active baseline SKU = 20.                                                                                                                                                                                                                                                                                                                                      |
| SV-002        | No active/approved operational recipe uses a research/baseline token (`G0`). G1 (`PILOT_PERCENT_BASED`) và G2 (`FIXED_QUANTITY_BATCH`) đều hợp lệ ACTIVE_OPERATIONAL.                                                                                                                                                                                                |
| SV-003        | Mỗi baseline SKU có nhiều nhất một active recipe per `(sku_id, formula_kind)`. Trong giai đoạn pilot baseline, mỗi SKU baseline có đúng một active recipe `formula_version = 'G1'` + `formula_kind = 'PILOT_PERCENT_BASED'`.                                                                                                                                         |
| SV-019        | PILOT recipe có đúng 1 line `is_anchor = true`, line đó có `ingredient_id = recipe.anchor_ingredient_id` và `ratio_percent > 0`.                                                                                                                                                                                                                                     |
| SV-020        | PILOT recipe `SUM(ratio_percent) ∈ [99.95, 100.05]` per `recipe_id`.                                                                                                                                                                                                                                                                                                 |
| SV-004        | Each G1 recipe has lines in all 4 recipe groups.                                                                                                                                                                                                                                                                                                                     |
| SV-005        | Required ingredients exist and are active, specifically `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`, `ING_THIT_HEO_NAC`.                                                                                                                                                                                                                                                       |
| SV-006        | At least one `RAW_MATERIAL` and one `FINISHED_GOODS` warehouse active.                                                                                                                                                                                                                                                                                               |
| SV-007        | Public trace policy has explicit deny for supplier/personnel/costing/QC defect/loss/MISA fields.                                                                                                                                                                                                                                                                     |
| SV-008        | Event schema registry includes the required event types listed in Section 6.                                                                                                                                                                                                                                                                                         |
| SV-AUTH-001   | `auth_permission` / `role_action_permission` seed includes `RAW_LOT_MARK_READY`, `BATCH_RELEASE_REVOKE`, `QR_REPRINT`, `QR_VOID`, `supplier.read`, `supplier.write`, `supplier.create`, `supplier.update`, `supplier.suspend`, `supplier.reactivate`, `supplier.user.manage`; missing action code blocks seed closeout.                                                                     |
| SV-SUP-001    | Role `R-SUPPLIER` tồn tại và có đủ permission `supplier.self.read`, `supplier.receipt.read`, `supplier.receipt.create`, `supplier.receipt.submit`, `supplier.receipt.confirm`, `supplier.receipt.decline`, `supplier.receipt.evidence.upload`, `supplier.receipt.cancel-draft`, `supplier.receipt.feedback.write`; KHÔNG có quyền nội bộ như `raw_intake.read`, `inventory.*`, `recipe.*`, `misa.*`, `trace.internal.*`. |
| SV-SUP-002    | Tồn tại tối thiểu 2 supplier dev fixture với ít nhất 1 supplier user mỗi supplier; mật khẩu lưu hash, không plaintext.                                                                                                                                                                                                                                               |
| SV-SUP-003    | Mọi `op_supplier_ingredient` seed có `status = ACTIVE`, `effective_from <= NOW()`, `(effective_to IS NULL OR effective_to > NOW())`, ingredient tồn tại trong `ref_ingredient` và `is_active = true`.                                                                                                                                                                |
| SV-SUP-004    | Không seed mapping supplier cho ingredient `SELF_GROWN`-only.                                                                                                                                                                                                                                                                                                        |
| SV-SUP-005    | Chạy seed chain 2 lần liên tiếp không sinh duplicate `op_supplier_ingredient`, `auth_role.R-SUPPLIER`, `role_action_permission` cho `supplier.*`.                                                                                                                                                                                                                    |
| SV-009        | GTIN fixtures are flagged `is_test_fixture=true` and use real identifier categories (`GTIN_13`, `GTIN_14`, `SSCC`, `INTERNAL_BARCODE`); `identifier_type = TEST_FIXTURE` is not valid in V2.                                                                                                                                                                       |
| SV-010        | Seed can run twice without duplicate rows.                                                                                                                                                                                                                                                                                                                           |
| SV-011        | `lot_status` CHECK/seed reference includes `READY_FOR_PRODUCTION`, `CONSUMED`, `EXPIRED`, `QUARANTINED` and material issue validation rejects QC-pass-only lots.                                                                                                                                                                                                     |
| SV-012        | `recall_status` CHECK/seed reference includes `CLOSED_WITH_RESIDUAL_RISK`.                                                                                                                                                                                                                                                                                           |

## 6. Required Event Schema Seed

`event_schema_registry` seed must include at minimum:

| event_type                         |
| ---------------------------------- |
| `SOURCE_ORIGIN_VERIFIED`           |
| `RAW_LOT_CREATED`                  |
| `RAW_LOT_QC_SIGNED`                |
| `RAW_LOT_READY_FOR_PRODUCTION`     |
| `RECIPE_ACTIVATED`                 |
| `PRODUCTION_ORDER_OPENED`          |
| `MATERIAL_ISSUED`                  |
| `MATERIAL_RECEIVED_BY_WORKSHOP`    |
| `PRODUCTION_PROCESS_COMPLETED`     |
| `QR_PRINTED`                       |
| `QR_REPRINTED`                     |
| `QR_VOIDED`                        |
| `QC_INSPECTION_SIGNED`             |
| `BATCH_QC_HOLD`                    |
| `BATCH_QC_REJECTED`                |
| `BATCH_RELEASED`                   |
| `WAREHOUSE_RECEIPT_CONFIRMED`      |
| `TRACE_GAP_DETECTED`               |
| `RECALL_OPENED`                    |
| `RECALL_HOLD_APPLIED`              |
| `RECALL_CLOSED`                    |
| `RECALL_CLOSED_WITH_RESIDUAL_RISK` |
| `MISA_SYNC_STATUS_CHANGED`         |
