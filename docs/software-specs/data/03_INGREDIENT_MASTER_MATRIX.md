# 03 - Ingredient Master Matrix

## Mục Lục

- [1. Mục đích](#1-mục-đích)
- [2. File dữ liệu](#2-file-dữ-liệu)
- [3. Quy tắc mã nguyên liệu](#3-quy-tắc-mã-nguyên-liệu)
- [4. Schema CSV](#4-schema-csv)
- [5. Validation](#5-validation)
- [6. Owner review](#6-owner-review)

## 1. Mục Đích

`ingredients.csv` là ingredient master seed được dẫn xuất từ toàn bộ 433 dòng recipe G1.

Mục tiêu là bảo đảm mọi `ingredient_code` trong `g1_recipe_lines.csv` đều có bản ghi master trước khi dev viết seed script, migration test và production order snapshot.

## 2. File Dữ Liệu

| file | count | mô tả |
|---|---:|---|
| `csv/ingredients.csv` | 52 | Ingredient master unique theo `ingredient_code` |
| `csv/g1_recipe_lines.csv` | 433 | Nguồn phát sinh ingredient usage |

## 3. Quy Tắc Mã Nguyên Liệu

| nhóm | rule |
|---|---|
| Code đã được khóa trong spec | Giữ nguyên code nguồn, ví dụ `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`, `ING_THIT_HEO_NAC`. |
| Code chưa có mã chính thức | Generate từ tên tiếng Việt: bỏ dấu, uppercase, thay ký tự không phải chữ/số bằng `_`, thêm prefix `ING_`. |
| Code sinh tự động | Đánh dấu `code_status = GENERATED_FROM_SOURCE_NAME_NEEDS_OWNER_CONFIRMATION`. |
| Production seed | Không dùng production nếu owner hoặc master-data steward chưa review mã chính thức. |

## 4. Schema CSV

| column | rule |
|---|---|
| `ingredient_code` | Business key seed. |
| `ingredient_name_vi` | Tên nguyên liệu từ recipe source. |
| `ingredient_name_en` | Để trống nếu nguồn không cung cấp. |
| `default_uom_code` | UOM mặc định từ lần xuất hiện đầu tiên trong G1 matrix. |
| `ingredient_type` | Phân loại triển khai: `HERB`, `ANIMAL_PROTEIN`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING`, `SPECIAL_COMPONENT`. |
| `is_qc_required` | Seed mặc định `true` vì nguyên liệu vận hành cần QC/lot gate. |
| `is_lot_tracked` | Seed mặc định `true` để phục vụ trace/recall. |
| `ingredient_status` | Seed mặc định `ACTIVE`. |
| `code_status` | `LOCKED_BY_SOURCE` hoặc `GENERATED_FROM_SOURCE_NAME_NEEDS_OWNER_CONFIRMATION`. |
| `source_document` | File nguồn. |
| `notes` | Ghi chú generate. |

## 5. Validation

| validation_id | query/check | expected |
|---|---|---|
| ING-VAL-001 | Mọi `g1_recipe_lines.ingredient_code` tồn tại trong `ingredients.csv`. | 0 missing |
| ING-VAL-002 | `ingredient_code` unique. | 52 unique |
| ING-VAL-003 | Required ingredient `HRB_SAM_SAVIGIN` tồn tại. | 1 |
| ING-VAL-004 | Required ingredient `ING_MI_CHINH` tồn tại. | 1 |
| ING-VAL-005 | Required ingredient `ING_THIT_HEO_NAC` tồn tại. | 1 |
| ING-VAL-006 | Không có ingredient inactive được dùng trong active G1 recipe. | 0 |

## 6. Owner Review

| owner_review_id | nội dung | trạng thái |
|---|---|---|
| ING-OD-001 | Owner/master-data steward xác nhận có dùng generated `ingredient_code` hay map sang mã kho/ERP hiện hữu. | OWNER DECISION NEEDED |
| ING-OD-002 | Xác nhận toàn bộ ingredient có `is_qc_required = true` và `is_lot_tracked = true` trong phase go-live. | OWNER DECISION NEEDED |
| ING-OD-003 | Xác nhận `ingredient_type` chỉ là phân loại vận hành nội bộ, không thay thế taxonomy kế toán/MISA nếu MISA có mã riêng. | OWNER DECISION NEEDED |

