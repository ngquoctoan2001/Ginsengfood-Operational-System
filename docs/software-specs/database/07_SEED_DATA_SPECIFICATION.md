# Seed Data Specification

> Mục đích: định nghĩa seed baseline G1 và config tối thiểu. Seed phải idempotent, không seed G0/research/baseline token làm operational.

## 1. Seed Principles

| principle_id | Principle |
| --- | --- |
| SEED-001 | Seed chain idempotent; chạy lại không tạo duplicate. |
| SEED-002 | Không seed G0/research/baseline token làm active/approved operational formula; G0 nếu cần chỉ nằm ở archive/reference ngoài active operational chain. |
| SEED-003 | G1 là baseline go-live; future G2/G3 qua workflow versioning. |
| SEED-004 | Fake GTIN/MISA credentials phải đánh dấu fixture/dev only. |
| SEED-005 | Seed validation phải fail nếu thiếu hard lock data. |

## 2. Required Seed Groups

| seed_group | Tables | Required data |
| --- | --- | --- |
| UOM | `ref_uom` | `kg`, `g`, `lít`, `ml`, `khay`, `gói`, `lọ`, `hũ`, `hộp`, `thùng`, `%` |
| Roles/permissions | `auth_role`, `auth_permission`, `role_action_permission` | Role codes in business role model; action codes for source/raw/recipe/PO/issue/QC/release/warehouse/trace/recall/MISA/override |
| Warehouses | `op_warehouse`, `op_warehouse_location` | At least one `RAW_MATERIAL`, one `FINISHED_GOODS` |
| Recipe groups | `ref_recipe_line_group` | 4 groups with sort 10/20/30/40 |
| Ingredients | `ref_ingredient`, `ref_ingredient_alias` | Required `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`, `ING_THIT_HEO_NAC`; additional ingredients from G1 recipe source |
| SKU baseline | `ref_sku`, `ref_sku_operational_config` | 20 SKU list below |
| G1 recipes | `op_production_recipe`, `op_recipe_ingredient` | Active operational G1 for each baseline SKU, 4 group lines |
| Source sample | `op_source_zone`, `op_source_origin` | Dev/sample source zones; production actual owner-provided |
| GTIN fixture | `op_trade_item`, `op_trade_item_gtin` | BOX/CARTON fixture with `is_test_fixture=true` until real GTIN |
| UI/action | `ui_screen_registry`, `ui_action_registry`, `ui_menu_item` | Screens/actions for modules M01-M16 |
| Public trace policy | `op_public_trace_policy` | Public allowed/forbidden field whitelist |
| Event schema | `event_schema_registry` | Canonical events from architecture event catalog |
| MISA fixture | `misa_mapping`, config/secret refs | Dev mapping/secret refs only, no real credential in seed |

## 3. 20 SKU Baseline

| sku_code | sku_name_vi | sku_group_name | sku_type | formula_code | formula_version |
| --- | --- | --- | --- | --- | --- |
| `A1/CS/DM/HS` | Cháo Sâm - Diêm mạch & Hạt sen | Cháo sâm theo mùa | `VEGAN` | `FML-A1-G1` | `G1` |
| `A2/CS/BASA` | Cháo Sâm - Cá Basa | Cháo sâm theo mùa | `SAVORY` | `FML-A2-G1` | `G1` |
| `A3/CS/CAHOI` | Cháo Sâm - Cá hồi | Cháo sâm theo mùa | `SAVORY` | `FML-A3-G1` | `G1` |
| `A4/CS/LUON` | Cháo Sâm - Lươn đồng | Cháo sâm theo mùa | `SAVORY` | `FML-A4-G1` | `G1` |
| `A5/CS/CUU` | Cháo Sâm - Thịt cừu & Táo tàu | Cháo sâm theo mùa | `SAVORY` | `FML-A5-G1` | `G1` |
| `B1/CS/RM/ĐX` | Cháo Sâm - Rau má & Đậu xanh | Cháo sâm chức năng | `VEGAN` | `FML-B1-G1` | `G1` |
| `B2/CS/DHA` | Cháo Sâm - DHA Não bộ | Cháo sâm chức năng | `SAVORY` | `FML-B2-G1` | `G1` |
| `B3/CS/CACOM` | Cháo Sâm - Cá cơm & Vừng | Cháo sâm chức năng | `SAVORY` | `FML-B3-G1` | `G1` |
| `B4/CS/COLAGEN` | Cháo Sâm - Thịt heo & Da heo | Cháo sâm chức năng | `SAVORY` | `FML-B4-G1` | `G1` |
| `B5/CS/SINHLUC` | Cháo Sâm - Hàu biển | Cháo sâm chức năng | `SAVORY` | `FML-B5-G1` | `G1` |
| `B6/CS/GAAC` | Cháo Sâm - Gà ác | Cháo sâm chức năng | `SAVORY` | `FML-B6-G1` | `G1` |
| `C1/CS/BAONGU` | Cháo Sâm - Bào ngư | Cháo sâm bổ dưỡng | `SAVORY` | `FML-C1-G1` | `G1` |
| `C2/CS/DONGTRUNG` | Cháo Sâm - Đông trùng hạ thảo | Cháo sâm bổ dưỡng | `VEGAN` | `FML-C2-G1` | `G1` |
| `C3/CS/NAMDONGCO` | Cháo Sâm - Nấm đông cô | Cháo sâm bổ dưỡng | `VEGAN` | `FML-C3-G1` | `G1` |
| `C4/CS/CUABIEN` | Cháo Sâm - Cua biển | Cháo sâm bổ dưỡng | `SAVORY` | `FML-C4-G1` | `G1` |
| `C5/CS/CANGU` | Cháo Sâm - Cá ngừ | Cháo sâm bổ dưỡng | `SAVORY` | `FML-C5-G1` | `G1` |
| `C6/CS/TOM/RONGBIEN` | Cháo Sâm - Tôm & Rong biển | Cháo sâm bổ dưỡng | `SAVORY` | `FML-C6-G1` | `G1` |
| `C7/CS/THITGA` | Cháo Sâm - Thịt gà | Cháo sâm bổ dưỡng | `SAVORY` | `FML-C7-G1` | `G1` |
| `C8/CS/THITHEO` | Cháo Sâm - Thịt heo | Cháo sâm bổ dưỡng | `SAVORY` | `FML-C8-G1` | `G1` |
| `C9/CS/THITBO` | Cháo Sâm - Thịt bò | Cháo sâm bổ dưỡng | `SAVORY` | `FML-C9-G1` | `G1` |

## 4. Recipe Group Seed

| group_code | name_vi | sort_order |
| --- | --- | --- |
| `SPECIAL_SKU_COMPONENT` | Thành phần đặc thù SKU | 10 |
| `NUTRITION_BASE` | Nguyên liệu nền dinh dưỡng | 20 |
| `BROTH_EXTRACT` | Rau củ chiết dịch tạo nước hầm | 30 |
| `SEASONING_FLAVOR` | Nguyên liệu nêm & tạo hương vị | 40 |

## 5. Seed Validation Queries / Checks

| validation_id | Check |
| --- | --- |
| SV-001 | Count active baseline SKU = 20. |
| SV-002 | No active/approved operational recipe uses a research/baseline token. |
| SV-003 | Each baseline SKU has exactly one recipe where `formula_status = 'ACTIVE_OPERATIONAL'` and `formula_version = 'G1'`. |
| SV-004 | Each G1 recipe has lines in all 4 recipe groups. |
| SV-005 | Required ingredients exist and are active, specifically `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`, `ING_THIT_HEO_NAC`. |
| SV-006 | At least one `RAW_MATERIAL` and one `FINISHED_GOODS` warehouse active. |
| SV-007 | Public trace policy has explicit deny for supplier/personnel/costing/QC defect/loss/MISA fields. |
| SV-008 | Event schema registry includes the required event types listed in Section 6. |
| SV-009 | GTIN fixtures are flagged `is_test_fixture=true`. |
| SV-010 | Seed can run twice without duplicate rows. |
| SV-011 | `lot_status` CHECK/seed reference includes `READY_FOR_PRODUCTION`, `CONSUMED`, `EXPIRED`, `QUARANTINED` and material issue validation rejects QC-pass-only lots. |
| SV-012 | `recall_status` CHECK/seed reference includes `CLOSED_WITH_RESIDUAL_RISK`. |

## 6. Required Event Schema Seed

`event_schema_registry` seed must include at minimum:

| event_type |
| --- |
| `SOURCE_ORIGIN_VERIFIED` |
| `RAW_LOT_CREATED` |
| `RAW_LOT_QC_SIGNED` |
| `RAW_LOT_READY_FOR_PRODUCTION` |
| `RECIPE_ACTIVATED` |
| `PRODUCTION_ORDER_OPENED` |
| `MATERIAL_ISSUED` |
| `MATERIAL_RECEIVED_BY_WORKSHOP` |
| `PRODUCTION_PROCESS_COMPLETED` |
| `QR_PRINTED` |
| `QR_REPRINTED` |
| `QR_VOIDED` |
| `QC_INSPECTION_SIGNED` |
| `BATCH_QC_HOLD` |
| `BATCH_QC_REJECTED` |
| `BATCH_RELEASED` |
| `WAREHOUSE_RECEIPT_CONFIRMED` |
| `TRACE_GAP_DETECTED` |
| `RECALL_OPENED` |
| `RECALL_HOLD_APPLIED` |
| `RECALL_CLOSED` |
| `RECALL_CLOSED_WITH_RESIDUAL_RISK` |
| `MISA_SYNC_STATUS_CHANGED` |




