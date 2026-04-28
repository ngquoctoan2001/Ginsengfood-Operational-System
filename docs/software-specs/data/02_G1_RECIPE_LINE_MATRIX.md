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

| file | vai trò |
|---|---|
| `csv/g1_recipe_headers.csv` | 20 header công thức G1 theo SKU |
| `csv/g1_recipe_lines.csv` | 433 dòng nguyên liệu công thức G1 |
| `csv/recipe_groups.csv` | 4 recipe groups chuẩn |
| `csv/skus.csv` | SKU master liên kết công thức |
| `csv/ingredients.csv` | Ingredient master liên kết recipe line |

## 3. Thống Kê

Các số dưới đây là **derived validation counts** từ parser/CSV hiện tại, dùng để phát hiện drift seed. Đây không phải business cap vĩnh viễn cho SKU/recipe tương lai.

| metric | value |
|---|---:|
| SKU baseline | 20 |
| Recipe headers | 20 |
| Recipe lines | 433 |
| Ingredients unique | 52 |
| Group `SPECIAL_SKU_COMPONENT` lines | 114 |
| Group `NUTRITION_BASE` lines | 99 |
| Group `BROTH_EXTRACT` lines | 100 |
| Group `SEASONING_FLAVOR` lines | 120 |

## 4. Schema CSV

### `g1_recipe_headers.csv`

| column | type kỳ vọng | rule |
|---|---|---|
| `sku_code` | text | FK logical tới `ref_sku.sku_code` |
| `formula_code` | text | Unique business code, ví dụ `FML-A1-G1` |
| `formula_version` | enum/text | Bắt buộc `G1` |
| `formula_status` | enum/text | Seed baseline dùng `ACTIVE_OPERATIONAL` |
| `approval_status` | enum/text | Seed baseline dùng `APPROVED_SEED_BASELINE` |
| `is_active` | bool | `true` cho G1 baseline |
| `batch_size_standard` | numeric | `400` |
| `effective_from` | timestamptz | Dev/QA technical effective date; production cần owner chốt |
| `source_status` | text | Trích từ file nguồn |
| `source_document` | text | File nguồn |
| `owner_review_required` | bool | `true` vì công thức seed cần owner/dev review trước production |

### `g1_recipe_lines.csv`

| column | type kỳ vọng | rule |
|---|---|---|
| `sku_code` | text | FK logical tới SKU |
| `formula_code` | text | FK logical tới recipe header |
| `formula_version` | text | Bắt buộc `G1` |
| `line_no` | int | Thứ tự dòng trong một recipe |
| `group_code` | enum | 1 trong 4 group chuẩn |
| `group_sort_order` | int | `10/20/30/40` |
| `group_line_no` | int | Thứ tự trong group |
| `ingredient_code` | text | FK logical tới `ref_ingredient.ingredient_code` |
| `ingredient_name_vi` | text | Snapshot display name từ nguồn |
| `quantity_per_batch_400` | numeric | Bắt buộc `> 0` |
| `uom_code` | text | FK logical tới `ref_uom` |
| `ratio_percent` | numeric | Tỷ lệ từ nguồn, dùng tham khảo/hiển thị |
| `prep_note` | text | Ghi chú vận hành |
| `usage_role` | text | Vai trò sử dụng, lấy cùng ghi chú vận hành nếu nguồn không tách riêng |
| `sort_order` | int | `line_no * 10` |
| `source_section` | text | Section trong file công thức |
| `source_document` | text | File nguồn |
| `line_checksum` | text | Hash ngắn để phát hiện drift seed |

## 5. Quy Tắc Import

| rule_id | rule |
|---|---|
| G1-IMP-001 | Import `ref_sku` và `ref_ingredient` trước recipe header/line. |
| G1-IMP-002 | Với mỗi `sku_code`, chỉ có một active `formula_version = G1`. |
| G1-IMP-003 | Không import recipe nếu thiếu bất kỳ group nào trong 4 group chuẩn. |
| G1-IMP-004 | Không import recipe line có `quantity_per_batch_400 <= 0`. |
| G1-IMP-005 | Không tự đổi `ingredient_code` sau khi đã snapshot vào production order. |
| G1-IMP-006 | Production order phải copy `formula_code`, `formula_version`, `group_code`, `ingredient_code`, `ingredient_name_vi`, `quantity_per_batch_400`, `uom_code`, `prep_note`, `usage_role` vào snapshot. |
| G1-IMP-007 | `batch_size_standard = 400` và `quantity_per_batch_400` là basis số lượng mẻ chuẩn, không được diễn giải mặc định là 400 kg thành phẩm. |

## 6. Kiểm Soát Sai Lệch

| check | expected |
|---|---|
| Count SKU | 20 |
| Count recipe headers | 20 |
| Count recipe lines | 433 |
| Count recipe groups | 4 |
| Count unique ingredients | 52 |
| Invalid group code | 0 |
| Missing ingredient reference | 0 |
| Quantity `<= 0` | 0 |
| Active non-G1 baseline formula in seed | 0 |
