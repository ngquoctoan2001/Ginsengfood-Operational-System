-- Seed canonical ref_sku_operational_config for 20 baseline SKU.
-- Phase 5 reconcile: bảng canonical là `ref_sku_operational_config` (không phải `op_sku_operational_config`).
-- Active recipe được derive từ `op_production_recipe` WHERE `formula_status = 'ACTIVE'` per SKU,
-- không lưu trùng `active_recipe_code`/`recipe_version` ở config này.
-- Packaging hierarchy (units_per_box, boxes_per_carton, carton_enabled, identifier_type) đã chuyển
-- sang `op_trade_item` + `op_trade_item_gtin` (xem seed packaging riêng — chưa scaffolded).
-- Public trace flag dùng tên canonical `trace_public_enabled` (tương đương public_trace_enabled cũ).
-- Recall applicability vẫn giữ field/policy riêng `recall_applicable` trên cùng config.
BEGIN;
CREATE TEMP TABLE seed_sku_operational_config (
    sku_code text,
    readiness_status text,
    default_batch_size numeric(18,3),
    qc_required boolean,
    trace_public_enabled boolean,
    recall_applicable boolean,
    notes text,
    created_at timestamptz
) ON COMMIT DROP;
INSERT INTO seed_sku_operational_config VALUES
('A1/CS/DM/HS', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('A2/CS/BASA', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('A3/CS/CAHOI', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('A4/CS/LUON', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('A5/CS/CUU', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('B1/CS/RM/ĐX', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('B2/CS/DHA', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('B3/CS/CACOM', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('B4/CS/COLAGEN', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('B5/CS/SINHLUC', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('B6/CS/GAAC', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C1/CS/BAONGU', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C2/CS/DONGTRUNG', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C3/CS/NAMDONGCO', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C4/CS/CUABIEN', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C5/CS/CANGU', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C6/CS/TOM/RONGBIEN', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C7/CS/THITGA', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C8/CS/THITHEO', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz),
('C9/CS/THITBO', 'READY', 400.000, TRUE, TRUE, TRUE, NULL, '2025-01-01T07:00:00+07:00'::timestamptz);

WITH resolved AS (
    SELECT sku.id AS sku_id, seed.*
    FROM seed_sku_operational_config seed
    JOIN ref_sku sku ON sku.sku_code = seed.sku_code AND sku.is_deleted = FALSE
)
INSERT INTO ref_sku_operational_config (
    sku_id, readiness_status, default_batch_size, qc_required,
    trace_public_enabled, recall_applicable, notes, created_at, is_deleted
)
SELECT sku_id, readiness_status, default_batch_size, qc_required,
       trace_public_enabled, recall_applicable, notes, created_at, FALSE
FROM resolved
ON CONFLICT (sku_id) DO UPDATE SET
    readiness_status = EXCLUDED.readiness_status,
    default_batch_size = EXCLUDED.default_batch_size,
    qc_required = EXCLUDED.qc_required,
    trace_public_enabled = EXCLUDED.trace_public_enabled,
    recall_applicable = EXCLUDED.recall_applicable,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();
COMMIT;
