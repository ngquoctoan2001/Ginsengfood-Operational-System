-- Seed unit-of-measure codes used by current SKU/raw-material/recipe seed data.

BEGIN;

WITH seed(uom_code, uom_name, conversion_factor, created_at) AS (
    VALUES
    ('EA', 'Each', 1, '2025-01-01T00:00:00+00:00'::timestamptz),
    ('kg', 'Kilogram', 1, '2025-01-01T00:00:00+00:00'::timestamptz),
    ('KG', 'Kilogram (legacy uppercase)', 1, '2025-01-01T00:00:00+00:00'::timestamptz),
    ('L', 'Liter', 1, '2025-01-01T00:00:00+00:00'::timestamptz),
    ('lít', 'Liter (Vietnamese label)', 1, '2025-01-01T00:00:00+00:00'::timestamptz)
)
UPDATE ref_uom u
SET uom_name = s.uom_name,
    conversion_factor = s.conversion_factor,
    is_active = TRUE,
    updated_at = NOW()
FROM seed s
WHERE u.uom_code = s.uom_code
  AND u.is_deleted = FALSE;

WITH seed(uom_code, uom_name, conversion_factor, created_at) AS (
    VALUES
    ('EA', 'Each', 1, '2025-01-01T00:00:00+00:00'::timestamptz),
    ('kg', 'Kilogram', 1, '2025-01-01T00:00:00+00:00'::timestamptz),
    ('KG', 'Kilogram (legacy uppercase)', 1, '2025-01-01T00:00:00+00:00'::timestamptz),
    ('L', 'Liter', 1, '2025-01-01T00:00:00+00:00'::timestamptz),
    ('lít', 'Liter (Vietnamese label)', 1, '2025-01-01T00:00:00+00:00'::timestamptz)
)
INSERT INTO ref_uom (uom_code, uom_name, conversion_factor, is_active, created_at, is_deleted)
SELECT s.uom_code, s.uom_name, s.conversion_factor, TRUE, s.created_at, FALSE
FROM seed s
WHERE NOT EXISTS (
    SELECT 1 FROM ref_uom u WHERE u.uom_code = s.uom_code
);

COMMIT;
