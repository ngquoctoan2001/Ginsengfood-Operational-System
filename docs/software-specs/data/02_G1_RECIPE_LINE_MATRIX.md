# 02 - G1 Recipe Line Matrix

## Mục Lục

- [1. Mục đích](#1-mục-đích)
- [2. File dữ liệu](#2-file-dữ-liệu)
- [3. Thống kê](#3-thống-kê)
- [4. Schema CSV](#4-schema-csv)
- [5. Quy tắc import](#5-quy-tắc-import)
- [6. Kiểm soát sai lệch](#6-kiểm-soát-sai-lệch)

## 1. Mục Đích

File này mô tả full G1 recipe matrix dùng để seed `op_production_recipe` và `op_recipe_ingredient`.

Full data nằm trong CSV để dev có thể import trực tiếp, thay vì copy bảng dài vào Markdown.

## 2. File Dữ Liệu

| file                        | vai trò                                |
| --------------------------- | -------------------------------------- |
| `csv/g1_recipe_headers.csv` | 20 header công thức G1 theo SKU        |
| `csv/g1_recipe_lines.csv`   | 433 dòng nguyên liệu công thức G1      |
| `csv/recipe_groups.csv`     | 4 recipe groups chuẩn                  |
| `csv/skus.csv`              | SKU master liên kết công thức          |
| `csv/ingredients.csv`       | Ingredient master liên kết recipe line |

## 3. Thống Kê

Các số dưới đây là **derived validation counts** từ parser/CSV hiện tại, dùng để phát hiện drift seed. Đây không phải business cap vĩnh viễn cho SKU/recipe tương lai.

| metric                              | value |
| ----------------------------------- | ----: |
| SKU baseline                        |    20 |
| Recipe headers                      |    20 |
| Recipe lines                        |   433 |
| Ingredients unique                  |    52 |
| Group `SPECIAL_SKU_COMPONENT` lines |   114 |
| Group `NUTRITION_BASE` lines        |    99 |
| Group `BROTH_EXTRACT` lines         |   100 |
| Group `SEASONING_FLAVOR` lines      |   120 |

## 4. Schema CSV

### `g1_recipe_headers.csv`

| column                     | type kỳ vọng | rule                                                                                                                                 |
| -------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| `sku_code`                 | text         | FK logical tới `ref_sku.sku_code`                                                                                                    |
| `formula_code`             | text         | Unique business code, ví dụ `FML-A1-G1`                                                                                              |
| `formula_version`          | enum/text    | Bắt buộc `G1` cho seed go-live; tương lai mở `G2/G3/...`                                                                             |
| `formula_kind`             | enum/text    | Bắt buộc. G1 baseline = `PILOT_PERCENT_BASED`; G2 baseline = `FIXED_QUANTITY_BATCH`.                                                 |
| `anchor_ingredient_code`   | text         | FK logical tới `ref_ingredient.ingredient_code`. NOT NULL khi `formula_kind = PILOT_PERCENT_BASED`; NULL khi `FIXED_QUANTITY_BATCH`. |
| `anchor_baseline_quantity` | numeric      | NOT NULL > 0 khi PILOT; NULL khi FIXED. Đơn vị tham chiếu khi seed.                                                                  |
| `anchor_uom_code`          | text         | FK logical tới `ref_uom.uom_code`. NOT NULL khi PILOT; NULL khi FIXED.                                                               |
| `anchor_ratio_percent`     | numeric      | NOT NULL khi PILOT, phải `> 0` và `<= 100`; NULL khi FIXED.                                                                          |
| `formula_status`           | enum/text    | Seed baseline dùng `ACTIVE_OPERATIONAL`                                                                                              |
| `approval_status`          | enum/text    | Seed baseline dùng `APPROVED_SEED_BASELINE`                                                                                          |
| `is_active`                | bool         | `true` cho baseline active                                                                                                           |
| `batch_size_standard`      | numeric      | `400` cho FIXED baseline; PILOT có thể NULL hoặc giữ `400` cho tương thích đọc.                                                      |
| `effective_from`           | timestamptz  | Dev/QA technical effective date; production cần owner chốt                                                                           |
| `source_status`            | text         | Trích từ file nguồn                                                                                                                  |
| `source_document`          | text         | File nguồn                                                                                                                           |
| `owner_review_required`    | bool         | `true` vì công thức seed cần owner/dev review trước production                                                                       |

### `g1_recipe_lines.csv`

| column                   | type kỳ vọng | rule                                                                                                                                                          |
| ------------------------ | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sku_code`               | text         | FK logical tới SKU                                                                                                                                            |
| `formula_code`           | text         | FK logical tới recipe header                                                                                                                                  |
| `formula_version`        | text         | Bắt buộc khớp header                                                                                                                                          |
| `formula_kind`           | text         | Bắt buộc khớp header                                                                                                                                          |
| `line_no`                | int          | Thứ tự dòng trong một recipe                                                                                                                                  |
| `group_code`             | enum         | 1 trong 4 group chuẩn                                                                                                                                         |
| `group_sort_order`       | int          | `10/20/30/40`                                                                                                                                                 |
| `group_line_no`          | int          | Thứ tự trong group                                                                                                                                            |
| `ingredient_code`        | text         | FK logical tới `ref_ingredient.ingredient_code`                                                                                                               |
| `ingredient_name_vi`     | text         | Snapshot display name từ nguồn                                                                                                                                |
| `is_anchor`              | bool         | `true` cho đúng 1 line per recipe khi `formula_kind = PILOT_PERCENT_BASED` và line trùng `anchor_ingredient_code`; `false` ngược lại. Luôn `false` khi FIXED. |
| `quantity_per_batch_400` | numeric      | Bắt buộc `> 0` khi `formula_kind = FIXED_QUANTITY_BATCH`. NULL hoặc bỏ qua khi PILOT.                                                                         |
| `uom_code`               | text         | FK logical tới `ref_uom`                                                                                                                                      |
| `ratio_percent`          | numeric      | Bắt buộc `> 0` khi PILOT; SUM(ratio_percent) per recipe ∈ `[99.95, 100.05]`. Tham khảo/hiển thị khi FIXED.                                                    |
| `prep_note`              | text         | Ghi chú vận hành                                                                                                                                              |
| `usage_role`             | text         | Vai trò sử dụng, lấy cùng ghi chú vận hành nếu nguồn không tách riêng                                                                                         |
| `sort_order`             | int          | `line_no * 10`                                                                                                                                                |
| `source_section`         | text         | Section trong file công thức                                                                                                                                  |
| `source_document`        | text         | File nguồn                                                                                                                                                    |
| `line_checksum`          | text         | Hash ngắn để phát hiện drift seed                                                                                                                             |

## 5. Quy Tắc Import

| rule_id    | rule                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| G1-IMP-001 | Import `ref_sku` và `ref_ingredient` trước recipe header/line.                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| G1-IMP-002 | Với mỗi `sku_code`, chỉ có một active recipe per `(formula_kind)`; G1 PILOT và G2 FIXED có thể cùng active.                                                                                                                                                                                                                                                                                                                                                                                                           |
| G1-IMP-003 | Không import recipe nếu thiếu bất kỳ group nào trong 4 group chuẩn.                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| G1-IMP-004 | Không import PILOT line có `ratio_percent <= 0`; không import FIXED line có `quantity_per_batch_400 <= 0`. PILOT recipe `SUM(ratio_percent) ∈ [99.95, 100.05]` và đúng 1 line `is_anchor = true` trùng `anchor_ingredient_code`.                                                                                                                                                                                                                                                                                      |
| G1-IMP-005 | Không tự đổi `ingredient_code` sau khi đã snapshot vào production order.                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| G1-IMP-006 | Production order phải copy `formula_code`, `formula_version`, `formula_kind`, `group_code`, `ingredient_code`, `ingredient_name_vi`, `uom_code`, `prep_note`, `usage_role` vào snapshot. PILOT branch thêm `is_anchor`, `ratio_percent`, `anchor_*_snapshot`, `anchor_quantity_input`, `total_batch_quantity`, `snapshot_quantity`, `snapshot_basis = PILOT_RATIO_OF_ANCHOR`. FIXED branch thêm `quantity_per_batch_400`, `batch_size`, `snapshot_quantity = qty × batch_size`, `snapshot_basis = FIXED_PER_BATCH_N`. |
| G1-IMP-007 | `batch_size_standard = 400` và `quantity_per_batch_400` chỉ áp dụng cho `FIXED_QUANTITY_BATCH`; không được diễn giải mặc định là 400 kg thành phẩm.                                                                                                                                                                                                                                                                                                                                                                   |

## 6. Kiểm Soát Sai Lệch

| check                                                         | expected |
| ------------------------------------------------------------- | -------- |
| Count SKU                                                     | 20       |
| Count recipe headers                                          | 20       |
| Count recipe lines                                            | 433      |
| Count recipe groups                                           | 4        |
| Count unique ingredients                                      | 52       |
| Invalid group code                                            | 0        |
| Missing ingredient reference                                  | 0        |
| FIXED line `quantity_per_batch_400 <= 0`                      | 0        |
| PILOT line `ratio_percent <= 0`                               | 0        |
| PILOT recipe với anchor count `<> 1`                          | 0        |
| PILOT recipe với `SUM(ratio_percent)` ngoài `[99.95, 100.05]` | 0        |
| Active operational formula version `G0` trong seed            | 0        |
