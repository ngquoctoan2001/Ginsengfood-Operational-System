-- Seed categories aligned with accepted raw_material_group values.

BEGIN;

WITH seed(category_code, category_name, description, created_at) AS (
    VALUES
    ('HERB', 'Herb raw materials', 'Canonical raw material group HERB', '2025-01-01T00:00:00+00:00'::timestamptz),
    ('INGREDIENT', 'Ingredient raw materials', 'Canonical raw material group INGREDIENT', '2025-01-01T00:00:00+00:00'::timestamptz)
)
UPDATE ref_category c
SET category_name = s.category_name,
    description = s.description,
    is_active = TRUE,
    updated_at = NOW()
FROM seed s
WHERE c.category_code = s.category_code
  AND c.is_deleted = FALSE;

WITH seed(category_code, category_name, description, created_at) AS (
    VALUES
    ('HERB', 'Herb raw materials', 'Canonical raw material group HERB', '2025-01-01T00:00:00+00:00'::timestamptz),
    ('INGREDIENT', 'Ingredient raw materials', 'Canonical raw material group INGREDIENT', '2025-01-01T00:00:00+00:00'::timestamptz)
)
INSERT INTO ref_category (category_code, category_name, description, is_active, created_at, is_deleted)
SELECT s.category_code, s.category_name, s.description, TRUE, s.created_at, FALSE
FROM seed s
WHERE NOT EXISTS (
    SELECT 1 FROM ref_category c WHERE c.category_code = s.category_code
);

COMMIT;
