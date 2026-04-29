# 01 - Seed Data Canonical

## Mục Lục

- [1. Mục đích](#1-mục-đích)
- [2. Nguồn dữ liệu được dùng](#2-nguồn-dữ-liệu-được-dùng)
- [3. Artifact triển khai](#3-artifact-triển-khai)
- [4. Thứ tự import seed](#4-thứ-tự-import-seed)
- [5. Hard lock dữ liệu](#5-hard-lock-dữ-liệu)
- [6. Quy tắc idempotency](#6-quy-tắc-idempotency)
- [7. Giả định và owner decision](#7-giả-định-và-owner-decision)

## 1. Mục Đích

Tài liệu này chốt data pack để dev có thể chuyển sang migration, seed script, API test và E2E smoke mà không tự đoán dữ liệu nền.

Data pack này không thay thế nghiệp vụ trong các file spec chính. Nó là lớp triển khai dữ liệu đã chuẩn hóa từ nguồn được phép dùng và phải được đọc bằng `UTF-8`.

Source discipline:

- `docs/software-specs/` là handoff baseline cho coding.
- `docs/software-specs/01_SOURCE_INDEX.md` là nơi tra source anchor khi cần kiểm chứng.
- `.tmp-docx-extract/` là extraction evidence, chỉ dùng khi source index hoặc file data này cite rõ.
- Current codebase chỉ là audit baseline, không override data lock.
- Old seed SQL/route cũ chỉ là historical reference.

## 2. Nguồn Dữ Liệu Được Dùng

| source_id   | file                                                              | vai trò                                                           | cách dùng                                                                                                             |
| ----------- | ----------------------------------------------------------------- | ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| DATA-SRC-01 | `.tmp-docx-extract/CÔNG THỨC 20 SKU MỚI.txt`                      | Nguồn công thức G1, 20 SKU, ingredient line, quantity, UOM, group | Parse cơ học thành `skus.csv`, `g1_recipe_headers.csv`, `g1_recipe_lines.csv`, `ingredients.csv`, `recipe_groups.csv` |
| DATA-SRC-02 | `docs/software-specs/database/07_SEED_DATA_SPECIFICATION.md`      | Seed rules và required seed groups                                | Dùng làm seed order và validation baseline                                                                            |
| DATA-SRC-03 | `docs/software-specs/dev-handoff/05_SEED_IMPLEMENTATION_GUIDE.md` | Seed order, failure policy, done gate                             | Dùng làm hướng dẫn import                                                                                             |
| DATA-SRC-04 | `docs/software-specs/business/04_ROLE_AND_PERMISSION_MODEL.md`    | Role/action baseline                                              | Dùng tạo `roles_permissions.csv` dạng starter seed                                                                    |
| DATA-SRC-05 | `docs/software-specs/09_CONFLICT_AND_OWNER_DECISIONS.md`          | Warehouse, MISA, public trace decisions                           | Dùng tạo warehouse fixture, MISA fixture, public trace policy                                                         |
| DATA-SRC-06 | `docs/software-specs/api/02_API_ENDPOINT_CATALOG.md`              | API fixture route examples                                        | Dùng để giữ smoke/API payload theo route catalog hiện hành                                                            |

## 3. Artifact Triển Khai

| artifact                        |                                     vai trò | số dòng dữ liệu | trạng thái                                                                      |
| ------------------------------- | ------------------------------------------: | --------------: | ------------------------------------------------------------------------------- |
| `csv/uom.csv`                   |                       Required UOM baseline |              11 | READY                                                                           |
| `csv/recipe_groups.csv`         |                     4 group công thức chuẩn |               4 | READY                                                                           |
| `csv/skus.csv`                  |                     20 SKU baseline go-live |              20 | READY                                                                           |
| `csv/ingredients.csv`           |  Ingredient master trích từ G1 recipe lines |              52 | READY, một số `ingredient_code` cần owner/dev review                            |
| `csv/g1_recipe_headers.csv`     |                Header công thức G1 theo SKU |              20 | READY                                                                           |
| `csv/g1_recipe_lines.csv`       |                     Full recipe line matrix |             433 | READY                                                                           |
| `csv/roles_permissions.csv`     |                    Starter RBAC action seed |              66 | READY cho dev seed, bao gồm `RAW_LOT_MARK_READY` cho gate mark-ready của QA/OPS |
| `csv/warehouses_locations.csv`  | Kho nguyên liệu và kho thành phẩm tối thiểu | 4 location rows | READY                                                                           |
| `csv/source_origin_fixture.csv` |         SELF_GROWN/PURCHASED source fixture |               2 | READY cho dev/QA; production source/supplier thật cần owner data                |
| `csv/gtin_fixture.csv`          |     BOX/CARTON fake GTIN fixture cho 20 SKU |              40 | DEV/TEST ONLY                                                                   |
| `csv/event_schema_registry.csv` |                       Event schema baseline |              18 | READY_FOR_DEV                                                                   |
| `csv/ui_registry_fixture.csv`   |             Minimum screen registry M01-M16 |              16 | READY_FOR_DEV                                                                   |
| `csv/misa_mapping_fixture.csv`  |               Mapping MISA dev/test fixture |               5 | READY cho test, không phải production credential                                |
| `csv/public_trace_policy.csv`   |       Public trace field whitelist/denylist |              17 | READY                                                                           |
| `seed_manifest.json`            |                 Metadata generate data pack |             N/A | READY                                                                           |

## 4. Thứ Tự Import Seed

| order | CSV                         | target table đề xuất                                                               | dependency                                   |
| ----: | --------------------------- | ---------------------------------------------------------------------------------- | -------------------------------------------- |
|    01 | `uom.csv`                   | `ref_uom`                                                                          | none                                         |
|    02 | `roles_permissions.csv`     | `auth_role`, `auth_permission`, `role_action_permission`                           | auth schema                                  |
|    03 | `warehouses_locations.csv`  | `op_warehouse`, `op_warehouse_location`                                            | UOM/config base                              |
|    04 | `source_origin_fixture.csv` | `op_supplier`, `op_source_zone`, `op_source_origin`, evidence/verification fixture | warehouse/source schema                      |
|    05 | `recipe_groups.csv`         | `ref_recipe_line_group`                                                            | none                                         |
|    06 | `skus.csv`                  | `ref_sku`, `ref_sku_operational_config`                                            | UOM/config base                              |
|    07 | `ingredients.csv`           | `ref_ingredient`                                                                   | UOM base                                     |
|    08 | `g1_recipe_headers.csv`     | `op_production_recipe`                                                             | SKU                                          |
|    09 | `g1_recipe_lines.csv`       | `op_recipe_ingredient`                                                             | recipe header, ingredient, recipe group, UOM |
|    10 | `gtin_fixture.csv`          | `op_trade_item`, `op_trade_item_gtin`                                              | SKU                                          |
|    11 | `public_trace_policy.csv`   | `op_public_trace_policy`                                                           | trace schema                                 |
|    12 | `event_schema_registry.csv` | `event_schema_registry`                                                            | event/outbox foundation                      |
|    13 | `misa_mapping_fixture.csv`  | `misa_mapping`                                                                     | integration schema                           |
|    14 | `ui_registry_fixture.csv`   | `ui_screen_registry`, `ui_action_registry`, `ui_menu_item`                         | UI schema, permissions                       |

## 5. Hard Lock Dữ Liệu

| lock_id       | lock                                                                                                                                                                                | validation                                                                                                                                                                                                                                                                    |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DATA-LOCK-001 | G1 PILOT_PERCENT_BASED là baseline operational pilot đầu tiên; G2 FIXED_QUANTITY_BATCH là production baseline cố định mẻ 400 và có thể coexist với G1 cho cùng SKU; G0 cấm vận hành | `g1_recipe_headers.csv.formula_version = G1` và `formula_kind = PILOT_PERCENT_BASED` cho toàn bộ 20 SKU baseline go-live; mọi row seed `formula_version = G0` phải bị bỏ; nếu seed tương lai bổ sung G2 phải có `formula_kind = FIXED_QUANTITY_BATCH` và anchor fields = NULL |
| DATA-LOCK-002 | 20 SKU là baseline go-live, không phải giới hạn vĩnh viễn                                                                                                                           | `skus.csv` có đúng 20 dòng seed baseline; schema/API vẫn phải cho phép thêm SKU sau approval                                                                                                                                                                                  |
| DATA-LOCK-003 | Công thức chỉ dùng 4 group                                                                                                                                                          | `recipe_groups.csv` chỉ có `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`                                                                                                                                                                     |
| DATA-LOCK-004 | Full recipe line không được sửa lịch sử                                                                                                                                             | Dev phải snapshot recipe line vào production order, không join live recipe khi chạy PO cũ                                                                                                                                                                                     |
| DATA-LOCK-005 | Public trace chỉ expose whitelist                                                                                                                                                   | `public_trace_policy.csv` deny supplier/personnel/cost/QC defect/loss/MISA/internal ID                                                                                                                                                                                        |
| DATA-LOCK-006 | MISA là integration layer                                                                                                                                                           | `misa_mapping_fixture.csv` chỉ seed mapping fixture; module nghiệp vụ không sync trực tiếp                                                                                                                                                                                    |
| DATA-LOCK-007 | UOM required list phải đủ trước khi import ingredient/recipe/warehouse                                                                                                              | `uom.csv` có `kg`, `g`, `lít`, `ml`, `khay`, `gói`, `lọ`, `hũ`, `hộp`, `thùng`, `%`                                                                                                                                                                                           |
| DATA-LOCK-008 | GTIN fixture không phải GTIN production                                                                                                                                             | `gtin_fixture.csv.is_test_fixture = true` cho toàn bộ row                                                                                                                                                                                                                     |
| DATA-LOCK-009 | Source fixture phải cover `SELF_GROWN` và `PURCHASED`                                                                                                                               | `source_origin_fixture.csv` có 1 `SELF_GROWN` verified và 1 `PURCHASED` supplier path                                                                                                                                                                                         |
| DATA-LOCK-010 | Event/UI seed không được thiếu gate tối thiểu                                                                                                                                       | `event_schema_registry.csv` và `ui_registry_fixture.csv` có baseline M01-M16/event P1                                                                                                                                                                                         |
| DATA-LOCK-011 | Raw lot mark-ready là gate riêng trước material issue                                                                                                                               | `event_schema_registry.csv` có `RAW_LOT_READY_FOR_PRODUCTION`, `roles_permissions.csv` có `RAW_LOT_MARK_READY`, UI M06 hiển thị action mark-ready                                                                                                                             |

## 6. Quy Tắc Idempotency

| seed area                  | business key                                                               | duplicate policy                                                                                        |
| -------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| UOM                        | `uom_code`                                                                 | upsert                                                                                                  |
| SKU                        | `sku_code`                                                                 | upsert theo `sku_code`; không tạo duplicate                                                             |
| Ingredient                 | `ingredient_code`                                                          | upsert theo `ingredient_code`; không đổi code khi name giữ nguyên                                       |
| Recipe header              | `(sku_code, formula_version, formula_kind)`                                | upsert; một active per `(sku_code, formula_kind)`; G1 PILOT và G2 FIXED có thể cùng active cho cùng SKU |
| Recipe line                | `(formula_code, formula_version, line_no)` hoặc `(recipe_id, line_no)`     | replace chỉ khi seed reset/dev; production không rewrite active historical recipe                       |
| Recipe group               | `group_code`                                                               | immutable code                                                                                          |
| Warehouse                  | `warehouse_code`                                                           | upsert                                                                                                  |
| Warehouse location         | `(warehouse_code, location_code)`                                          | upsert                                                                                                  |
| Source/procurement fixture | `fixture_code` hoặc `(procurement_type, source_origin_code/supplier_code)` | upsert fixture only                                                                                     |
| GTIN fixture               | `(sku_code, trade_item_level)` và `gtin`                                   | upsert fixture only; production GTIN must replace fixture                                               |
| Role permission            | `(role_code, action_code)`                                                 | upsert                                                                                                  |
| Public trace policy        | `field_code`                                                               | upsert active policy                                                                                    |
| Event schema               | `(event_type, event_version)`                                              | upsert compatible schema version                                                                        |
| UI registry                | `screen_id`                                                                | upsert screen/action/menu fixture                                                                       |
| MISA mapping fixture       | `(internal_object_type, internal_object_key, misa_object_type)`            | upsert fixture only                                                                                     |

## 7. Giả Định Và Owner Decision

| id              | nội dung                                                                                                                                                                                                                      | trạng thái            | tác động                                                                         |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | -------------------------------------------------------------------------------- |
| DATA-ASSUMP-001 | `effective_from = 2026-04-27T00:00:00+07:00` trong `g1_recipe_headers.csv` là ngày seed kỹ thuật cho dev/QA, không phải ngày go-live sản xuất cuối cùng.                                                                      | GIẢ ĐỊNH              | Production seed cần owner chốt ngày hiệu lực thật.                               |
| DATA-ASSUMP-002 | `ingredient_code` không được nguồn khóa cứng sẽ được generate từ tên nguyên liệu tiếng Việt.                                                                                                                                  | OWNER REVIEW NEEDED   | Nếu công ty đã có mã nguyên liệu ERP/kho, cần map lại trước production seed.     |
| DATA-ASSUMP-003 | `roles_permissions.csv` là starter seed theo action baseline, không phải ma trận quyền cuối cùng cho mọi biến thể UI. `RAW_LOT_MARK_READY` được seed riêng cho `R-QA-REL` và `R-OPS-MGR`, không đồng nghĩa với `RAW_QC_SIGN`. | ACCEPTED_FOR_DEV      | Trước go-live cần review theo user/role thật, nhưng coding không bị block.       |
| DATA-ASSUMP-004 | `misa_mapping_fixture.csv` là fixture dev/test, không chứa credential hay endpoint thật.                                                                                                                                      | OWNER DECISION NEEDED | MISA production cần tenant/credential/endpoint thật.                             |
| DATA-ASSUMP-005 | Toàn bộ CSV trong thư mục này phải được đọc/ghi bằng `UTF-8`.                                                                                                                                                                 | ACCEPTED_FOR_DEV      | Seed loader/test runner phải chỉ định encoding để không làm hỏng tên tiếng Việt. |
| DATA-ASSUMP-006 | `batch_size_standard = 400` là số lượng mẻ chuẩn/quantity-per-batch basis, không phải mặc định 400 kg thành phẩm.                                                                                                             | ACCEPTED_FOR_DEV      | API/seed không được suy diễn đơn vị khối lượng từ số 400.                        |
