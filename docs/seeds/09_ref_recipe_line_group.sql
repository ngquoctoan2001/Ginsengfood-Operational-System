-- Seed canonical G1 recipe line groups from docs/ginsengfood_sku_recipe_md_pack/07_SEED_DATA_SPEC_SKU_INGREDIENT_RECIPE_GINSENGFOOD.md.
BEGIN;
INSERT INTO ref_recipe_line_group (id, code, name, sort_order, is_active, created_at, is_deleted) VALUES
(1, 'SPECIAL_SKU_COMPONENT', 'Thành phần đặc thù SKU', 10, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, FALSE),
(2, 'NUTRITION_BASE', 'Nguyên liệu nền dinh dưỡng', 20, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, FALSE),
(3, 'BROTH_EXTRACT', 'Rau củ chiết dịch tạo nước hầm', 30, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, FALSE),
(4, 'SEASONING_FLAVOR', 'Nguyên liệu nêm và tạo hương vị', 40, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, FALSE)
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, sort_order = EXCLUDED.sort_order, is_active = TRUE, is_deleted = FALSE, deleted_at = NULL, updated_at = NOW();
COMMIT;
