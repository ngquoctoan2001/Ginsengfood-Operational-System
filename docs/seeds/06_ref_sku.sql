-- Seed canonical 20 SKU master rows from docs/ginsengfood_sku_recipe_md_pack/01_SKU_CANONICAL_MASTER_GINSENGFOOD.md.
-- Metadata is folded into this file; 07_ref_sku_metadata.sql is archived.

BEGIN;

CREATE TEMP TABLE seed_ref_sku (
    id bigint, sku_code text, sku_name text, sku_name_vi text, sku_name_en text, unit text, is_active boolean,
    vegan_classification text, sku_group text, sku_group_code text, sku_group_name text, sku_type text,
    is_sellable boolean, is_advisory_enabled boolean, is_producible boolean, is_trace_public_enabled boolean,
    protein_source text, created_at timestamptz
) ON COMMIT DROP;

INSERT INTO seed_ref_sku VALUES
(1, 'A1/CS/DM/HS', 'Cháo Sâm – Diêm mạch & Hạt sen (Cháo Sâm Mùa Xuân)', 'Cháo Sâm – Diêm mạch & Hạt sen (Cháo Sâm Mùa Xuân)', 'Ocean Ginseng Porridge – Quinoa & Lotus Seed (Spring Recipe)', 'EA', TRUE, 'VEGAN', 'A', 'SEASONAL', 'Sản phẩm Cháo Sâm Theo Mùa', 'VEGAN', TRUE, TRUE, TRUE, TRUE, 'Thuần chay', '2025-01-01T07:00:00+07:00'::timestamptz),
(2, 'A2/CS/BASA', 'Cháo Sâm – Cá Basa (Cháo Sâm Mùa Hạ)', 'Cháo Sâm – Cá Basa (Cháo Sâm Mùa Hạ)', 'Ocean Ginseng Porridge – Pangasius (Summer Recipe)', 'EA', TRUE, 'NON_VEGAN', 'A', 'SEASONAL', 'Sản phẩm Cháo Sâm Theo Mùa', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Cá Basa', '2025-01-01T07:00:00+07:00'::timestamptz),
(3, 'A3/CS/CAHOI', 'Cháo Sâm – Cá hồi (Cháo Sâm Mùa Thu – Dưỡng âm)', 'Cháo Sâm – Cá hồi (Cháo Sâm Mùa Thu – Dưỡng âm)', 'Ocean Ginseng Porridge – Salmon (Autumn Recipe – Yin Nourishing)', 'EA', TRUE, 'NON_VEGAN', 'A', 'SEASONAL', 'Sản phẩm Cháo Sâm Theo Mùa', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Cá hồi', '2025-01-01T07:00:00+07:00'::timestamptz),
(4, 'A4/CS/LUON', 'Cháo Sâm – Lươn đồng (Cháo Sâm Mùa Thu – Dưỡng âm)', 'Cháo Sâm – Lươn đồng (Cháo Sâm Mùa Thu – Dưỡng âm)', 'Ocean Ginseng Porridge – Eel (Autumn Recipe – Yin Nourishing)', 'EA', TRUE, 'NON_VEGAN', 'A', 'SEASONAL', 'Sản phẩm Cháo Sâm Theo Mùa', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Lươn đồng', '2025-01-01T07:00:00+07:00'::timestamptz),
(5, 'A5/CS/CUU', 'Cháo Sâm – Thịt cừu & Táo tàu (Cháo Sâm Mùa Đông)', 'Cháo Sâm – Thịt cừu & Táo tàu (Cháo Sâm Mùa Đông)', 'Ocean Ginseng Porridge – Lamb & Jujube (Winter Recipe)', 'EA', TRUE, 'NON_VEGAN', 'A', 'SEASONAL', 'Sản phẩm Cháo Sâm Theo Mùa', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Thịt cừu & Táo tàu', '2025-01-01T07:00:00+07:00'::timestamptz),
(6, 'B1/CS/RM/ĐX', 'Cháo Sâm – Rau má & Đậu xanh', 'Cháo Sâm – Rau má & Đậu xanh', 'Ocean Ginseng Porridge – Centella & Mung Bean', 'EA', TRUE, 'VEGAN', 'B', 'FUNCTIONAL', 'Sản phẩm Cháo Sâm Chức Năng', 'VEGAN', TRUE, TRUE, TRUE, TRUE, 'Thuần chay', '2025-01-01T07:00:00+07:00'::timestamptz),
(7, 'B2/CS/DHA', 'Cháo Sâm – DHA Não bộ', 'Cháo Sâm – DHA Não bộ', 'Ocean Ginseng Porridge – Brain Nutrition (DHA)', 'EA', TRUE, 'NON_VEGAN', 'B', 'FUNCTIONAL', 'Sản phẩm Cháo Sâm Chức Năng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'DHA Não bộ', '2025-01-01T07:00:00+07:00'::timestamptz),
(8, 'B3/CS/CACOM', 'Cháo Sâm – Cá cơm & Vừng', 'Cháo Sâm – Cá cơm & Vừng', 'Ocean Ginseng Porridge – Anchovy & Sesame', 'EA', TRUE, 'NON_VEGAN', 'B', 'FUNCTIONAL', 'Sản phẩm Cháo Sâm Chức Năng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Cá cơm & Vừng', '2025-01-01T07:00:00+07:00'::timestamptz),
(9, 'B4/CS/COLAGEN', 'Cháo Sâm – Thịt heo & Da heo', 'Cháo Sâm – Thịt heo & Da heo', 'Ocean Ginseng Porridge – Pork & Pork Skin', 'EA', TRUE, 'NON_VEGAN', 'B', 'FUNCTIONAL', 'Sản phẩm Cháo Sâm Chức Năng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Thịt heo & Da heo', '2025-01-01T07:00:00+07:00'::timestamptz),
(10, 'B5/CS/SINHLUC', 'Cháo Sâm – Hàu biển', 'Cháo Sâm – Hàu biển', 'Ocean Ginseng Porridge – Oyster', 'EA', TRUE, 'NON_VEGAN', 'B', 'FUNCTIONAL', 'Sản phẩm Cháo Sâm Chức Năng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Hàu biển', '2025-01-01T07:00:00+07:00'::timestamptz),
(11, 'B6/CS/GAAC', 'Cháo Sâm – Gà ác', 'Cháo Sâm – Gà ác', 'Ocean Ginseng Porridge – Black Chicken', 'EA', TRUE, 'NON_VEGAN', 'B', 'FUNCTIONAL', 'Sản phẩm Cháo Sâm Chức Năng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Gà ác', '2025-01-01T07:00:00+07:00'::timestamptz),
(12, 'C1/CS/BAONGU', 'Cháo Sâm – Bào ngư', 'Cháo Sâm – Bào ngư', 'Ocean Ginseng Porridge – Abalone', 'EA', TRUE, 'NON_VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Bào ngư', '2025-01-01T07:00:00+07:00'::timestamptz),
(13, 'C2/CS/DONGTRUNG', 'Cháo Sâm – Đông trùng hạ thảo', 'Cháo Sâm – Đông trùng hạ thảo', 'Ocean Ginseng Porridge – Cordyceps', 'EA', TRUE, 'VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'VEGAN', TRUE, TRUE, TRUE, TRUE, 'Thuần chay', '2025-01-01T07:00:00+07:00'::timestamptz),
(14, 'C3/CS/NAMDONGCO', 'Cháo Sâm – Nấm đông cô', 'Cháo Sâm – Nấm đông cô', 'Ocean Ginseng Porridge – Shiitake Mushroom', 'EA', TRUE, 'VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'VEGAN', TRUE, TRUE, TRUE, TRUE, 'Thuần chay', '2025-01-01T07:00:00+07:00'::timestamptz),
(15, 'C4/CS/CUABIEN', 'Cháo Sâm – Cua biển', 'Cháo Sâm – Cua biển', 'Ocean Ginseng Porridge – Crab', 'EA', TRUE, 'NON_VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Cua biển', '2025-01-01T07:00:00+07:00'::timestamptz),
(16, 'C5/CS/CANGU', 'Cháo Sâm – Cá ngừ', 'Cháo Sâm – Cá ngừ', 'Ocean Ginseng Porridge – Tuna', 'EA', TRUE, 'NON_VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Cá ngừ', '2025-01-01T07:00:00+07:00'::timestamptz),
(17, 'C6/CS/TOM/RONGBIEN', 'Cháo Sâm – Tôm & Rong biển', 'Cháo Sâm – Tôm & Rong biển', 'Ocean Ginseng Porridge – Shrimp & Seaweed', 'EA', TRUE, 'NON_VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Tôm & Rong biển', '2025-01-01T07:00:00+07:00'::timestamptz),
(18, 'C7/CS/THITGA', 'Cháo Sâm – Thịt gà', 'Cháo Sâm – Thịt gà', 'Ocean Ginseng Porridge – Chicken', 'EA', TRUE, 'NON_VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Thịt gà', '2025-01-01T07:00:00+07:00'::timestamptz),
(19, 'C8/CS/THITHEO', 'Cháo Sâm – Thịt heo', 'Cháo Sâm – Thịt heo', 'Ocean Ginseng Porridge – Pork', 'EA', TRUE, 'NON_VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Thịt heo', '2025-01-01T07:00:00+07:00'::timestamptz),
(20, 'C9/CS/THITBO', 'Cháo Sâm – Thịt bò', 'Cháo Sâm – Thịt bò', 'Ocean Ginseng Porridge – Beef', 'EA', TRUE, 'NON_VEGAN', 'C', 'NOURISHING', 'Sản phẩm Cháo Sâm Bổ Dưỡng', 'SAVORY', TRUE, TRUE, TRUE, TRUE, 'Thịt bò', '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO ref_sku (id, sku_code, sku_name, sku_name_vi, sku_name_en, unit, is_active, vegan_classification, sku_group, sku_group_code, sku_group_name, sku_type, is_sellable, is_advisory_enabled, is_producible, is_trace_public_enabled, protein_source, created_at, is_deleted)
SELECT id, sku_code, sku_name, sku_name_vi, sku_name_en, unit, is_active, vegan_classification, sku_group, sku_group_code, sku_group_name, sku_type, is_sellable, is_advisory_enabled, is_producible, is_trace_public_enabled, protein_source, created_at, FALSE
FROM seed_ref_sku
ON CONFLICT (sku_code) DO UPDATE SET
    sku_name = EXCLUDED.sku_name,
    sku_name_vi = EXCLUDED.sku_name_vi,
    sku_name_en = EXCLUDED.sku_name_en,
    unit = EXCLUDED.unit,
    is_active = EXCLUDED.is_active,
    vegan_classification = EXCLUDED.vegan_classification,
    sku_group = EXCLUDED.sku_group,
    sku_group_code = EXCLUDED.sku_group_code,
    sku_group_name = EXCLUDED.sku_group_name,
    sku_type = EXCLUDED.sku_type,
    is_sellable = EXCLUDED.is_sellable,
    is_advisory_enabled = EXCLUDED.is_advisory_enabled,
    is_producible = EXCLUDED.is_producible,
    is_trace_public_enabled = EXCLUDED.is_trace_public_enabled,
    protein_source = EXCLUDED.protein_source,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

COMMIT;
