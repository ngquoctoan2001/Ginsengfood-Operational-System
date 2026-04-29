-- Seed canonical Phase 5 packaging trade items + identifiers cho 20 SKU baseline.
-- 2 cấp PACKET + BOX per SKU = 40 trade items. CARTON KHÔNG seed: `carton_enabled = false`
-- mặc định, owner sẽ enable từng SKU cho kênh sỉ qua SCR-TRADE-ITEMS (Phase 5 mandate).
-- BOX trade item lấy default `units_per_box = 4` (sửa được, không hard-code source).
-- Identifiers seed dạng `INTERNAL_BARCODE` placeholder, `status = 'INACTIVE'` ⇒ không thể dùng
-- in commercial cho tới khi owner cung cấp GTIN_13/GTIN_14/SSCC thật và đổi sang `ACTIVE`.
-- Constraint UNIQUE `(identifier_type, identifier_value) WHERE status = 'ACTIVE'` không bị
-- trigger bởi placeholder INACTIVE; an toàn idempotent.
BEGIN;

CREATE TEMP TABLE seed_trade_item (
    trade_item_code text,
    sku_code text,
    packaging_level text,
    display_name text,
    units_per_box int,
    boxes_per_carton int,
    carton_enabled boolean,
    status text,
    notes text,
    created_at timestamptz
) ON COMMIT DROP;

INSERT INTO seed_trade_item VALUES
-- PACKET (cấp 1) — không units_per_box, không boxes_per_carton, carton_enabled=FALSE
('TI-A1-PACKET-PENDING',  'A1/CS/DM/HS',         'PACKET', 'A1 Cháo súp Đậu mơ Hạt sen — gói',           NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A2-PACKET-PENDING',  'A2/CS/BASA',          'PACKET', 'A2 Cháo súp Cá Basa — gói',                  NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A3-PACKET-PENDING',  'A3/CS/CAHOI',         'PACKET', 'A3 Cháo súp Cá hồi — gói',                   NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A4-PACKET-PENDING',  'A4/CS/LUON',          'PACKET', 'A4 Cháo súp Lươn — gói',                     NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A5-PACKET-PENDING',  'A5/CS/CUU',           'PACKET', 'A5 Cháo súp Cừu — gói',                      NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B1-PACKET-PENDING',  'B1/CS/RM/ĐX',         'PACKET', 'B1 Cháo súp Rau má Đậu xanh — gói',          NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B2-PACKET-PENDING',  'B2/CS/DHA',           'PACKET', 'B2 Cháo súp DHA — gói',                      NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B3-PACKET-PENDING',  'B3/CS/CACOM',         'PACKET', 'B3 Cháo súp Cá cơm — gói',                   NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B4-PACKET-PENDING',  'B4/CS/COLAGEN',       'PACKET', 'B4 Cháo súp Collagen — gói',                 NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B5-PACKET-PENDING',  'B5/CS/SINHLUC',       'PACKET', 'B5 Cháo súp Sinh lực — gói',                 NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B6-PACKET-PENDING',  'B6/CS/GAAC',          'PACKET', 'B6 Cháo súp Gà ác — gói',                    NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C1-PACKET-PENDING',  'C1/CS/BAONGU',        'PACKET', 'C1 Cháo súp Bào ngư — gói',                  NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C2-PACKET-PENDING',  'C2/CS/DONGTRUNG',     'PACKET', 'C2 Cháo súp Đông trùng — gói',               NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C3-PACKET-PENDING',  'C3/CS/NAMDONGCO',     'PACKET', 'C3 Cháo súp Nấm đông cô — gói',              NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C4-PACKET-PENDING',  'C4/CS/CUABIEN',       'PACKET', 'C4 Cháo súp Cua biển — gói',                 NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C5-PACKET-PENDING',  'C5/CS/CANGU',         'PACKET', 'C5 Cháo súp Cá ngừ — gói',                   NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C6-PACKET-PENDING',  'C6/CS/TOM/RONGBIEN',  'PACKET', 'C6 Cháo súp Tôm Rong biển — gói',            NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C7-PACKET-PENDING',  'C7/CS/THITGA',        'PACKET', 'C7 Cháo súp Thịt gà — gói',                  NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C8-PACKET-PENDING',  'C8/CS/THITHEO',       'PACKET', 'C8 Cháo súp Thịt heo — gói',                 NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C9-PACKET-PENDING',  'C9/CS/THITBO',        'PACKET', 'C9 Cháo súp Thịt bò — gói',                  NULL, NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: PACKET trade item — owner cấp GTIN_13/GTIN_14 trước khi ACTIVE.', '2025-01-01T07:00:00+07:00'::timestamptz),
-- BOX (cấp 2) — units_per_box = 4 default seed, boxes_per_carton=NULL (CARTON disabled), carton_enabled=FALSE
('TI-A1-BOX-PENDING',     'A1/CS/DM/HS',         'BOX',    'A1 Cháo súp Đậu mơ Hạt sen — hộp 4 gói',     4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A2-BOX-PENDING',     'A2/CS/BASA',          'BOX',    'A2 Cháo súp Cá Basa — hộp 4 gói',            4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A3-BOX-PENDING',     'A3/CS/CAHOI',         'BOX',    'A3 Cháo súp Cá hồi — hộp 4 gói',             4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A4-BOX-PENDING',     'A4/CS/LUON',          'BOX',    'A4 Cháo súp Lươn — hộp 4 gói',               4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A5-BOX-PENDING',     'A5/CS/CUU',           'BOX',    'A5 Cháo súp Cừu — hộp 4 gói',                4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B1-BOX-PENDING',     'B1/CS/RM/ĐX',         'BOX',    'B1 Cháo súp Rau má Đậu xanh — hộp 4 gói',    4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B2-BOX-PENDING',     'B2/CS/DHA',           'BOX',    'B2 Cháo súp DHA — hộp 4 gói',                4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B3-BOX-PENDING',     'B3/CS/CACOM',         'BOX',    'B3 Cháo súp Cá cơm — hộp 4 gói',             4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B4-BOX-PENDING',     'B4/CS/COLAGEN',       'BOX',    'B4 Cháo súp Collagen — hộp 4 gói',           4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B5-BOX-PENDING',     'B5/CS/SINHLUC',       'BOX',    'B5 Cháo súp Sinh lực — hộp 4 gói',           4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B6-BOX-PENDING',     'B6/CS/GAAC',          'BOX',    'B6 Cháo súp Gà ác — hộp 4 gói',              4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C1-BOX-PENDING',     'C1/CS/BAONGU',        'BOX',    'C1 Cháo súp Bào ngư — hộp 4 gói',            4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C2-BOX-PENDING',     'C2/CS/DONGTRUNG',     'BOX',    'C2 Cháo súp Đông trùng — hộp 4 gói',         4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C3-BOX-PENDING',     'C3/CS/NAMDONGCO',     'BOX',    'C3 Cháo súp Nấm đông cô — hộp 4 gói',        4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C4-BOX-PENDING',     'C4/CS/CUABIEN',       'BOX',    'C4 Cháo súp Cua biển — hộp 4 gói',           4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C5-BOX-PENDING',     'C5/CS/CANGU',         'BOX',    'C5 Cháo súp Cá ngừ — hộp 4 gói',             4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C6-BOX-PENDING',     'C6/CS/TOM/RONGBIEN',  'BOX',    'C6 Cháo súp Tôm Rong biển — hộp 4 gói',      4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C7-BOX-PENDING',     'C7/CS/THITGA',        'BOX',    'C7 Cháo súp Thịt gà — hộp 4 gói',            4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C8-BOX-PENDING',     'C8/CS/THITHEO',       'BOX',    'C8 Cháo súp Thịt heo — hộp 4 gói',           4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C9-BOX-PENDING',     'C9/CS/THITBO',        'BOX',    'C9 Cháo súp Thịt bò — hộp 4 gói',            4,    NULL, FALSE, 'INACTIVE', 'OWNER_PENDING_GTIN: BOX trade item — units_per_box=4 default; owner enable carton_enabled + boxes_per_carton khi sẵn sàng kênh sỉ.', '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO op_trade_item (
    sku_id, trade_item_code, packaging_level, display_name,
    units_per_box, boxes_per_carton, carton_enabled,
    status, notes, created_at, is_deleted
)
SELECT sku.id, s.trade_item_code, s.packaging_level, s.display_name,
       s.units_per_box, s.boxes_per_carton, s.carton_enabled,
       s.status, s.notes, s.created_at, FALSE
FROM seed_trade_item s
JOIN ref_sku sku ON sku.sku_code = s.sku_code AND sku.is_deleted = FALSE
ON CONFLICT (trade_item_code) DO UPDATE SET
    sku_id = EXCLUDED.sku_id,
    packaging_level = EXCLUDED.packaging_level,
    display_name = EXCLUDED.display_name,
    units_per_box = EXCLUDED.units_per_box,
    boxes_per_carton = EXCLUDED.boxes_per_carton,
    carton_enabled = EXCLUDED.carton_enabled,
    status = EXCLUDED.status,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

-- Identifiers placeholder INACTIVE: 1 INTERNAL_BARCODE per trade item.
-- Real GTIN_13 (PACKET/BOX), GTIN_14/SSCC (CARTON) sẽ do owner cấp khi enable commercial print.
INSERT INTO op_trade_item_gtin (
    trade_item_id, identifier_type, identifier_value, is_test_fixture,
    effective_from, effective_to, status, created_at, is_deleted
)
SELECT
    ti.id,
    'INTERNAL_BARCODE',
    'PENDING-' || ti.trade_item_code,
    FALSE,
    '2025-01-01T00:00:00+07:00'::timestamptz,
    NULL,
    'INACTIVE',
    '2025-01-01T07:00:00+07:00'::timestamptz,
    FALSE
FROM op_trade_item ti
WHERE ti.is_deleted = FALSE
  AND ti.trade_item_code LIKE 'TI-%-PENDING'
ON CONFLICT (trade_item_id, identifier_type, identifier_value) DO UPDATE SET
    is_test_fixture = FALSE,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    status = 'INACTIVE',
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

COMMIT;
