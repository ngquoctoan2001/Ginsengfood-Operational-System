-- Seed per-SKU operational configuration. Initial go-live active formula version is G1.
BEGIN;
CREATE TEMP TABLE seed_sku_operational_config (sku_code text, active_recipe_code text, recipe_version text, packaging_l1_unit text, packaging_l2_unit text, qc_required boolean, public_trace_enabled boolean, recall_applicable boolean, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_sku_operational_config VALUES
('A1/CS/DM/HS', 'FML-A1-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('A2/CS/BASA', 'FML-A2-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('A3/CS/CAHOI', 'FML-A3-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('A4/CS/LUON', 'FML-A4-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('A5/CS/CUU', 'FML-A5-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('B1/CS/RM/ĐX', 'FML-B1-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('B2/CS/DHA', 'FML-B2-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('B3/CS/CACOM', 'FML-B3-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('B4/CS/COLAGEN', 'FML-B4-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('B5/CS/SINHLUC', 'FML-B5-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('B6/CS/GAAC', 'FML-B6-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C1/CS/BAONGU', 'FML-C1-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C2/CS/DONGTRUNG', 'FML-C2-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C3/CS/NAMDONGCO', 'FML-C3-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C4/CS/CUABIEN', 'FML-C4-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C5/CS/CANGU', 'FML-C5-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C6/CS/TOM/RONGBIEN', 'FML-C6-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C7/CS/THITGA', 'FML-C7-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C8/CS/THITHEO', 'FML-C8-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
('C9/CS/THITBO', 'FML-C9-G1', 'G1', 'gói', 'hộp', TRUE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz);

WITH resolved AS (
    SELECT sku.id AS sku_id, seed.*
    FROM seed_sku_operational_config seed
    JOIN ref_sku sku ON sku.sku_code = seed.sku_code AND sku.is_deleted = FALSE
)
INSERT INTO op_sku_operational_config (sku_id, active_recipe_code, recipe_version, packaging_l1_unit, packaging_l2_unit, qc_required, public_trace_enabled, recall_applicable, created_at, is_deleted)
SELECT sku_id, active_recipe_code, recipe_version, packaging_l1_unit, packaging_l2_unit, qc_required, public_trace_enabled, recall_applicable, created_at, FALSE FROM resolved
ON CONFLICT (sku_id) DO UPDATE SET
    active_recipe_code = EXCLUDED.active_recipe_code,
    recipe_version = EXCLUDED.recipe_version,
    packaging_l1_unit = EXCLUDED.packaging_l1_unit,
    packaging_l2_unit = EXCLUDED.packaging_l2_unit,
    qc_required = EXCLUDED.qc_required,
    public_trace_enabled = EXCLUDED.public_trace_enabled,
    recall_applicable = EXCLUDED.recall_applicable,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();
COMMIT;
