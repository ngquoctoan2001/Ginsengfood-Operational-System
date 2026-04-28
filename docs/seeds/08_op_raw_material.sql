-- Seed canonical ingredient/raw material master from docs/ginsengfood_sku_recipe_md_pack/02_INGREDIENT_CANONICAL_MASTER_GINSENGFOOD.md.
-- Canonical material_code = ingredient_code (HRB_* / ING_*). Legacy MAT-* values are aliases only.

BEGIN;

CREATE TEMP TABLE seed_raw_material (material_code text, ingredient_code text, material_name text, canonical_name text, scientific_name text, raw_material_group text, uom_code text, shelf_life_days integer, spec_json jsonb, material_status text, ingredient_status text, ingredient_notes text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_raw_material VALUES
('HRB_SAM_SAVIGIN', 'HRB_SAM_SAVIGIN', 'Sâm Savigin', 'Sâm Savigin', 'Pouzolzia zeylanica (L.) Benn.', 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Dược liệu trung tâm toàn hệ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_HOAI_SON', 'HRB_HOAI_SON', 'Hoài sơn', 'Hoài sơn', 'Dioscorea opposita', 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Dược liệu hỗ trợ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_BACH_LINH', 'HRB_BACH_LINH', 'Bạch linh', 'Bạch linh', 'Poria cocos', 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Dược liệu hỗ trợ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_KY_TU', 'HRB_KY_TU', 'Kỷ tử', 'Kỷ tử', 'Lycium barbarum', 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Dược liệu hỗ trợ.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_TAO_TAU', 'HRB_TAO_TAU', 'Táo tàu', 'Táo tàu', 'Ziziphus jujuba Mill.', 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Có thể xuất hiện ở vai trò đặc thù SKU hoặc nước hầm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_GUNG_NUONG', 'HRB_GUNG_NUONG', 'Gừng nướng', 'Gừng nướng', 'Zingiber officinale', 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Có thể xuất hiện ở vai trò đặc thù SKU hoặc nêm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_TRAN_BI', 'HRB_TRAN_BI', 'Trần bì', 'Trần bì', 'Citrus reticulata Blanco – Pericarpium', 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Dược liệu điều hòa.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_QUE_CHI', 'HRB_QUE_CHI', 'Quế chi', 'Quế chi', NULL, 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'NEEDS_METADATA', 'Thiếu tên khoa học/mô tả trong nguyên liệu master.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_DONG_TRUNG', 'HRB_DONG_TRUNG', 'Đông trùng hạ thảo', 'Đông trùng hạ thảo', 'Cordyceps militaris', 'HERB', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU C2.', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_HUONG_SAM', 'HRB_HUONG_SAM', 'Hương sâm', 'Hương sâm', NULL, 'HERB', 'kg', NULL, NULL::jsonb, 'INACTIVE', 'INACTIVE_NOT_USED_IN_G1', 'Có trong nguyên liệu master cũ nhưng không dùng trong G1. Không seed vào recipe active.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_DIEM_MACH', 'ING_DIEM_MACH', 'Diêm mạch', 'Diêm mạch', 'Chenopodium quinoa Willd.', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU A1.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_HAT_SEN', 'ING_HAT_SEN', 'Hạt sen', 'Hạt sen', 'Nelumbo nucifera', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU A1.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_BASA', 'ING_CA_BASA', 'Cá Basa', 'Cá Basa', 'Pangasius bocourti', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU A2.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_HOI', 'ING_CA_HOI', 'Cá hồi', 'Cá hồi', 'Salmo spp. / Oncorhynchus spp.', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU A3/B2.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_LUON_DONG', 'ING_LUON_DONG', 'Lươn đồng', 'Lươn đồng', 'Monopterus albus', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU A4.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_CUU', 'ING_THIT_CUU', 'Thịt cừu', 'Thịt cừu', 'Lamb / mutton', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU A5.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_RAU_MA', 'ING_RAU_MA', 'Rau má', 'Rau má', 'Centella asiatica', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU B1.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_DAU_XANH_KHONG_VO', 'ING_DAU_XANH_KHONG_VO', 'Đậu xanh không vỏ', 'Đậu xanh không vỏ', 'Vigna radiata', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nền dinh dưỡng; B1 có vai trò đặc thù.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_VUNG', 'ING_VUNG', 'Vừng', 'Vừng', 'Sesamum indicum L.', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU B2/B3.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_COM', 'ING_CA_COM', 'Cá cơm', 'Cá cơm', 'Stolephorus spp.', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU B3.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_HEO', 'ING_THIT_HEO', 'Thịt heo', 'Thịt heo', 'Sus scrofa domesticus', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU C8; B4 dùng biến thể thịt heo nạc.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_HEO_NAC', 'ING_THIT_HEO_NAC', 'Thịt heo nạc', 'Thịt heo nạc', 'Sus scrofa domesticus', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED_OWNER_SEPARATE', 'Có trong B4 G1, chưa có như dòng riêng trong ingredient master. Owner decision: seed as a separate stock/QC ingredient for B4 G1.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_DA_HEO', 'ING_DA_HEO', 'Da heo', 'Da heo', 'Sus scrofa domesticus', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU B4.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_HAU_BIEN', 'ING_HAU_BIEN', 'Hàu biển', 'Hàu biển', 'Crassostrea belcheri', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU B5.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_GA_AC', 'ING_GA_AC', 'Gà ác', 'Gà ác', 'Gallus gallus domesticus', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU B6.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_BAO_NGU', 'ING_BAO_NGU', 'Bào ngư', 'Bào ngư', 'Haliotis spp.', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU C1.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_NAM_DONG_CO', 'ING_NAM_DONG_CO', 'Nấm đông cô', 'Nấm đông cô', 'Lentinula edodes', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU C3.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CUA_BIEN', 'ING_CUA_BIEN', 'Cua biển', 'Cua biển', 'Scylla spp.', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU C4.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_NGU', 'ING_CA_NGU', 'Cá ngừ', 'Cá ngừ', NULL, 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'NEEDS_METADATA', 'Thiếu tên khoa học/mô tả trong nguyên liệu master.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_TOM', 'ING_TOM', 'Tôm', 'Tôm', 'Litopenaeus vannamei', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU C6.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_RONG_BIEN', 'ING_RONG_BIEN', 'Rong biển', 'Rong biển', NULL, 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'NEEDS_METADATA', 'Dùng cả vai trò đặc thù SKU và nước hầm; cần mô tả/loài.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_GA', 'ING_THIT_GA', 'Thịt gà', 'Thịt gà', 'Gallus gallus domesticus', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU C7.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_BO', 'ING_THIT_BO', 'Thịt bò', 'Thịt bò', 'Bos taurus', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'SKU C9.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_GAO_LUA_TOM', 'ING_GAO_LUA_TOM', 'Gạo lúa – tôm', 'Gạo lúa – tôm', 'Gạo nền dùng chung', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nền chính.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_ROT', 'ING_CA_ROT', 'Cà rốt', 'Cà rốt', 'Rau củ nền / nước hầm', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Cần phân biệt prep/role: hạt lựu nền vs thái khúc nước hầm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_BI_DO', 'ING_BI_DO', 'Bí đỏ', 'Bí đỏ', 'Rau củ nền', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nền dinh dưỡng.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_NAM_KIM_CHAM', 'ING_NAM_KIM_CHAM', 'Nấm kim châm', 'Nấm kim châm', 'Nền dinh dưỡng', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nền dinh dưỡng.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CU_CAI_TRANG', 'ING_CU_CAI_TRANG', 'Củ cải trắng', 'Củ cải trắng', 'Rau củ nước hầm', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nước hầm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_HANH_TAY', 'ING_HANH_TAY', 'Hành tây', 'Hành tây', 'Rau củ nước hầm', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nước hầm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_NUOC_DUA', 'ING_NUOC_DUA', 'Nước dừa nguyên chất', 'Nước dừa nguyên chất', 'Nền dịch hầm', 'INGREDIENT', 'lít', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nước hầm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_MUOI_BIEN_RANG', 'ING_MUOI_BIEN_RANG', 'Muối biển rang', 'Muối biển rang', 'Nguyên liệu nêm', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nêm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_TIEU_DEN_RANG', 'ING_TIEU_DEN_RANG', 'Tiêu đen rang', 'Tiêu đen rang', 'Nguyên liệu nêm', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nêm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_TOI_NUONG', 'ING_TOI_NUONG', 'Tỏi nướng', 'Tỏi nướng', 'Nguyên liệu nêm', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nêm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_HANH_LA', 'ING_HANH_LA', 'Hành lá', 'Hành lá', 'Nguyên liệu nêm', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nêm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_RE_CAN_TAY', 'ING_RE_CAN_TAY', 'Rễ cần tây', 'Rễ cần tây', 'Nguyên liệu nêm', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Nêm.', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_MI_CHINH', 'ING_MI_CHINH', 'Mì chính', 'Mì chính', 'Nguyên liệu nêm / tạo vị umami', 'INGREDIENT', 'kg', NULL, NULL::jsonb, 'ACTIVE', 'LOCKED', 'Đã bổ sung chính thức theo G1; bắt buộc seed trước recipe G1.', '2025-01-01T07:00:00+07:00'::timestamptz);

-- Retire legacy MAT-* rows from operational truth before assigning ingredient_code uniqueness to canonical rows.
UPDATE op_raw_material
SET ingredient_code = NULL, ingredient_status = 'LEGACY_ALIAS', updated_at = NOW()
WHERE material_code LIKE 'MAT-%';

INSERT INTO op_raw_material (material_code, ingredient_code, material_name, canonical_name, scientific_name, raw_material_group, uom_code, shelf_life_days, spec_json, material_status, ingredient_status, ingredient_notes, created_at, is_deleted)
SELECT material_code, ingredient_code, material_name, canonical_name, scientific_name, raw_material_group, uom_code, shelf_life_days, spec_json, material_status, ingredient_status, ingredient_notes, created_at, FALSE
FROM seed_raw_material
ON CONFLICT (material_code) DO UPDATE SET
    ingredient_code = EXCLUDED.ingredient_code,
    material_name = EXCLUDED.material_name,
    canonical_name = EXCLUDED.canonical_name,
    scientific_name = EXCLUDED.scientific_name,
    raw_material_group = EXCLUDED.raw_material_group,
    uom_code = EXCLUDED.uom_code,
    shelf_life_days = EXCLUDED.shelf_life_days,
    spec_json = EXCLUDED.spec_json,
    material_status = EXCLUDED.material_status,
    ingredient_status = EXCLUDED.ingredient_status,
    ingredient_notes = EXCLUDED.ingredient_notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

CREATE TEMP TABLE seed_raw_material_alias (ingredient_code text, alias_code text, alias_name text, alias_type text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_raw_material_alias VALUES
('HRB_SAM_SAVIGIN', 'MAT-SAM-SAVIGIN', 'Sâm Savigin', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_HOAI_SON', 'MAT-HERB-HOAISON', 'Hoài sơn', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_BACH_LINH', 'MAT-HERB-BACHLINH', 'Bạch linh', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_KY_TU', 'MAT-HERB-KYTU', 'Kỷ tử', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_TAO_TAU', 'MAT-HERB-TAOTAU', 'Táo tàu', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_GUNG_NUONG', 'MAT-HERB-GINGNUONG', 'Gừng nướng', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_TRAN_BI', 'MAT-HERB-TRANBI', 'Trần bì', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_QUE_CHI', 'MAT-HERB-QUECCHI', 'Quế chi', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_DONG_TRUNG', 'MAT-HERB-DONGTRUNG', 'Đông trùng hạ thảo', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('HRB_HUONG_SAM', 'MAT-HERB-HUONGSAM', 'Hương sâm', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_DIEM_MACH', 'MAT-HERB-DIEUMACH', 'Diêm mạch', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_HAT_SEN', 'MAT-HERB-HATSEN', 'Hạt sen', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_BASA', 'MAT-PROT-CABASA', 'Cá Basa', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_HOI', 'MAT-PROT-CAHOI', 'Cá hồi', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_LUON_DONG', 'MAT-PROT-LUONDONQ', 'Lươn đồng', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_CUU', 'MAT-PROT-THITCUU', 'Thịt cừu', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_RAU_MA', 'MAT-HERB-RAUMA', 'Rau má', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_DAU_XANH_KHONG_VO', 'MAT-VEG-DAUXA', 'Đậu xanh không vỏ', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_VUNG', 'MAT-HERB-VUNG', 'Vừng', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_COM', 'MAT-PROT-CACOM', 'Cá cơm', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_HEO', 'MAT-PROT-THITHEO', 'Thịt heo', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_HEO_NAC', 'MAT-PROT-THITHEO-NAC', 'Thịt heo nạc', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_DA_HEO', 'MAT-PROT-DAHEO', 'Da heo', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_HAU_BIEN', 'MAT-PROT-HAUBIEN', 'Hàu biển', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_GA_AC', 'MAT-PROT-GAAC', 'Gà ác', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_BAO_NGU', 'MAT-PROT-BAONGU', 'Bào ngư', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_NAM_DONG_CO', 'MAT-HERB-NAMDONGCO', 'Nấm đông cô', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CUA_BIEN', 'MAT-PROT-CUABIEN', 'Cua biển', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_NGU', 'MAT-PROT-CANGU', 'Cá ngừ', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_TOM', 'MAT-PROT-TOM', 'Tôm', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_RONG_BIEN', 'MAT-HERB-RONGBIEN', 'Rong biển', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_GA', 'MAT-PROT-THITGA', 'Thịt gà', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_THIT_BO', 'MAT-PROT-THITBO', 'Thịt bò', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_GAO_LUA_TOM', 'MAT-GRAIN-GAOLUATOM', 'Gạo lúa – tôm', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CA_ROT', 'MAT-VEG-CARROT', 'Cà rốt', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_BI_DO', 'MAT-VEG-BIDOBI', 'Bí đỏ', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_NAM_KIM_CHAM', 'MAT-VEG-NAMKIMCHAM', 'Nấm kim châm', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_CU_CAI_TRANG', 'MAT-VEG-CUCAITRANG', 'Củ cải trắng', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_HANH_TAY', 'MAT-VEG-HANHTAY', 'Hành tây', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_NUOC_DUA', 'MAT-LIQ-NUOCDUA', 'Nước dừa nguyên chất', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_MUOI_BIEN_RANG', 'MAT-SEAS-MUOIRANG', 'Muối biển rang', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_TIEU_DEN_RANG', 'MAT-SEAS-TIEUDEN', 'Tiêu đen rang', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_TOI_NUONG', 'MAT-SEAS-TOINUONG', 'Tỏi nướng', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_HANH_LA', 'MAT-SEAS-HANHLAKUC', 'Hành lá', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_RE_CAN_TAY', 'MAT-VEG-RECANHTAY', 'Rễ cần tây', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz),
('ING_MI_CHINH', 'MAT-SEAS-MICHINH', 'Mì chính', 'LEGACY_CODE', '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO op_raw_material_alias (raw_material_id, alias_code, alias_name, alias_type, created_at, is_deleted)
SELECT m.id, a.alias_code, a.alias_name, a.alias_type, a.created_at, FALSE
FROM seed_raw_material_alias a
JOIN op_raw_material m ON m.ingredient_code = a.ingredient_code AND m.is_deleted = FALSE
ON CONFLICT (alias_code, alias_type) DO UPDATE SET
    raw_material_id = EXCLUDED.raw_material_id,
    alias_name = EXCLUDED.alias_name,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

UPDATE op_raw_material
SET material_status = 'DISCONTINUED', ingredient_status = 'LEGACY_ALIAS', is_deleted = TRUE, deleted_at = COALESCE(deleted_at, NOW()), updated_at = NOW()
WHERE material_code LIKE 'MAT-%' AND is_deleted = FALSE;

COMMIT;
