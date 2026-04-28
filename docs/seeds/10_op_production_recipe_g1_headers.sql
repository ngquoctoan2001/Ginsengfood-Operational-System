-- Seed G1 production recipe headers from canonical 20 SKU pack.
-- G0 is retired/tombstoned and must not be active operational configuration.

BEGIN;

UPDATE op_production_recipe
SET recipe_status = 'DEPRECATED', formula_status = 'RETIRED', source_of_truth = FALSE, retired_at = COALESCE(retired_at, NOW()), updated_at = NOW()
WHERE is_deleted = FALSE AND (formula_version = 'G0' OR recipe_code LIKE 'FML-%-G0');

CREATE TEMP TABLE seed_g1_recipe (recipe_code text, recipe_name text, sku_code text, recipe_status text, version_number integer, formula_version text, formula_status text, source_of_truth boolean, approved_by_actor_id bigint, approved_at timestamptz, effective_from timestamptz, recipe_note text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_g1_recipe VALUES
('FML-A1-G1', 'Cháo Sâm – Diêm mạch & Hạt sen (Cháo Sâm Mùa Xuân) (G1)', 'A1/CS/DM/HS', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-A2-G1', 'Cháo Sâm – Cá Basa (Cháo Sâm Mùa Hạ) (G1)', 'A2/CS/BASA', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-A3-G1', 'Cháo Sâm – Cá hồi (Cháo Sâm Mùa Thu – Dưỡng âm) (G1)', 'A3/CS/CAHOI', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-A4-G1', 'Cháo Sâm – Lươn đồng (Cháo Sâm Mùa Thu – Dưỡng âm) (G1)', 'A4/CS/LUON', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-A5-G1', 'Cháo Sâm – Thịt cừu & Táo tàu (Cháo Sâm Mùa Đông) (G1)', 'A5/CS/CUU', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-B1-G1', 'Cháo Sâm – Rau má & Đậu xanh (G1)', 'B1/CS/RM/ĐX', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-B2-G1', 'Cháo Sâm – DHA Não bộ (G1)', 'B2/CS/DHA', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-B3-G1', 'Cháo Sâm – Cá cơm & Vừng (G1)', 'B3/CS/CACOM', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-B4-G1', 'Cháo Sâm – Thịt heo & Da heo (G1)', 'B4/CS/COLAGEN', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-B5-G1', 'Cháo Sâm – Hàu biển (G1)', 'B5/CS/SINHLUC', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-B6-G1', 'Cháo Sâm – Gà ác (G1)', 'B6/CS/GAAC', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C1-G1', 'Cháo Sâm – Bào ngư (G1)', 'C1/CS/BAONGU', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C2-G1', 'Cháo Sâm – Đông trùng hạ thảo (G1)', 'C2/CS/DONGTRUNG', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C3-G1', 'Cháo Sâm – Nấm đông cô (G1)', 'C3/CS/NAMDONGCO', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C4-G1', 'Cháo Sâm – Cua biển (G1)', 'C4/CS/CUABIEN', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C5-G1', 'Cháo Sâm – Cá ngừ (G1)', 'C5/CS/CANGU', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C6-G1', 'Cháo Sâm – Tôm & Rong biển (G1)', 'C6/CS/TOM/RONGBIEN', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C7-G1', 'Cháo Sâm – Thịt gà (G1)', 'C7/CS/THITGA', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C8-G1', 'Cháo Sâm – Thịt heo (G1)', 'C8/CS/THITHEO', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FML-C9-G1', 'Cháo Sâm – Thịt bò (G1)', 'C9/CS/THITBO', 'ACTIVE', 1, 'G1', 'ACTIVE_OPERATIONAL', TRUE, 1, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz, 'Canonical G1 operational go-live baseline from SKU/recipe source pack.', '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO op_production_recipe (recipe_code, recipe_name, sku_id, recipe_status, version_number, formula_version, formula_status, source_of_truth, approved_by_actor_id, approved_at, effective_from, recipe_note, created_at, is_deleted)
SELECT s.recipe_code, s.recipe_name, sku.id, s.recipe_status, s.version_number, s.formula_version, s.formula_status, s.source_of_truth, s.approved_by_actor_id, s.approved_at, s.effective_from, s.recipe_note, s.created_at, FALSE
FROM seed_g1_recipe s
JOIN ref_sku sku ON sku.sku_code = s.sku_code AND sku.is_deleted = FALSE
ON CONFLICT (recipe_code) DO UPDATE SET
    recipe_name = EXCLUDED.recipe_name,
    sku_id = EXCLUDED.sku_id,
    recipe_status = EXCLUDED.recipe_status,
    version_number = EXCLUDED.version_number,
    formula_version = EXCLUDED.formula_version,
    formula_status = EXCLUDED.formula_status,
    source_of_truth = EXCLUDED.source_of_truth,
    approved_by_actor_id = EXCLUDED.approved_by_actor_id,
    approved_at = EXCLUDED.approved_at,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    retired_by_actor_id = NULL,
    retired_at = NULL,
    recipe_note = EXCLUDED.recipe_note,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

COMMIT;
