-- Canonical Ginsengfood V2 seed validation.
-- Run after docs/seeds/*.sql in sorted non-recursive order.

DO $$
DECLARE
    actual integer;
BEGIN
    SELECT COUNT(*) INTO actual FROM ref_sku WHERE is_deleted = FALSE;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected ref_sku count 20, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_raw_material
    WHERE is_deleted = FALSE
      AND ingredient_code IS NOT NULL
      AND material_code = ingredient_code
      AND (ingredient_code LIKE 'HRB_%' OR ingredient_code LIKE 'ING_%');
    IF actual <> 46 THEN RAISE EXCEPTION 'Expected canonical ingredient master count 46, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_production_recipe
    WHERE is_deleted = FALSE AND formula_version = 'G1' AND formula_status = 'ACTIVE_OPERATIONAL' AND source_of_truth = TRUE;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected active source-of-truth G1 recipe headers 20, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1';
    IF actual <> 433 THEN RAISE EXCEPTION 'Expected active G1 recipe lines 433, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_production_recipe
    WHERE is_deleted = FALSE
      AND (formula_version = 'G0' OR recipe_code LIKE 'FML-%-G0')
      AND (formula_status = 'ACTIVE_OPERATIONAL' OR source_of_truth = TRUE OR recipe_status = 'ACTIVE');
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected active operational G0 recipe count 0, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_sku_operational_config c
    JOIN ref_sku s ON s.id = c.sku_id AND s.is_deleted = FALSE
    WHERE c.is_deleted = FALSE AND c.recipe_version = 'G1' AND c.active_recipe_code LIKE 'FML-%-G1';
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected SKU operational config G1 count 20, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1' AND ri.recipe_line_group_code = 'SPECIAL_SKU_COMPONENT';
    IF actual <> 114 THEN RAISE EXCEPTION 'Expected SPECIAL_SKU_COMPONENT lines 114, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1' AND ri.recipe_line_group_code = 'NUTRITION_BASE';
    IF actual <> 99 THEN RAISE EXCEPTION 'Expected NUTRITION_BASE lines 99, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1' AND ri.recipe_line_group_code = 'BROTH_EXTRACT';
    IF actual <> 100 THEN RAISE EXCEPTION 'Expected BROTH_EXTRACT lines 100, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1' AND ri.recipe_line_group_code = 'SEASONING_FLAVOR';
    IF actual <> 120 THEN RAISE EXCEPTION 'Expected SEASONING_FLAVOR lines 120, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE
      AND r.formula_version = 'G1'
      AND ri.recipe_line_group_code NOT IN ('SPECIAL_SKU_COMPONENT', 'NUTRITION_BASE', 'BROTH_EXTRACT', 'SEASONING_FLAVOR');
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected every G1 recipe_line_group_code to be canonical, bad rows %', actual; END IF;

    SELECT COUNT(DISTINCT r.id) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1'
      AND ri.ingredient_code = 'HRB_SAM_SAVIGIN'
      AND ri.quantity_per_batch_400 = 9.000;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected Sam Savigin 9.00 kg in 20 G1 recipes, got %', actual; END IF;

    SELECT COUNT(DISTINCT r.id) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE AND r.formula_version = 'G1'
      AND ri.ingredient_code = 'ING_MI_CHINH'
      AND ri.quantity_per_batch_400 = 1.900;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected Mi chinh 1.90 kg in 20 G1 recipes, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE
      AND r.recipe_code = 'FML-B4-G1'
      AND ri.ingredient_code = 'ING_THIT_HEO_NAC'
      AND ri.quantity_per_batch_400 = 10.500;
    IF actual <> 1 THEN RAISE EXCEPTION 'Expected FML-B4-G1 to contain Thit heo nac 10.50 kg once, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_raw_material
    WHERE is_deleted = FALSE
      AND material_code = 'MAT-SAM-SAVIGIN'
      AND (material_name ILIKE '%Kỉ tử%' OR material_name ILIKE '%Kỷ tử%' OR material_name ILIKE '%Ky tu%');
    IF actual <> 0 THEN RAISE EXCEPTION 'Bad active legacy MAT-SAM-SAVIGIN -> Ky tu row still exists'; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE AND r.formula_version = 'G1'
    LEFT JOIN op_raw_material m ON m.id = ri.material_id AND m.is_deleted = FALSE AND m.ingredient_code = ri.ingredient_code
    WHERE ri.is_deleted = FALSE AND m.id IS NULL;
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected every G1 recipe ingredient to resolve to canonical ingredient master, unresolved %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM ref_qr_registry_status
    WHERE is_deleted = FALSE
      AND is_active = TRUE
      AND code IN ('GENERATED', 'QUEUED', 'PRINTED', 'FAILED', 'VOID', 'REPRINTED');
    IF actual <> 6 THEN RAISE EXCEPTION 'Expected QR registry canonical status count 6, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_public_trace_field_policy
    WHERE is_deleted = FALSE
      AND is_active = TRUE
      AND public_allowed = TRUE
      AND field_group IN ('SKU_NAME', 'BATCH_DISPLAY', 'MFG_EXP', 'VERIFICATION_STATUS', 'USAGE_INSTRUCTION');
    IF actual <> 5 THEN RAISE EXCEPTION 'Expected public trace allowed field policy count 5, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_public_trace_field_policy
    WHERE is_deleted = FALSE
      AND is_active = TRUE
      AND public_allowed = FALSE
      AND field_group IN ('SUPPLIER_SENSITIVE', 'PERSONNEL', 'COSTING_MISA', 'QC_DEFECT_DETAIL', 'LOSS_VARIANCE');
    IF actual <> 5 THEN RAISE EXCEPTION 'Expected public trace blocked sensitive field policy count 5, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_misa_document_mapping
    WHERE is_deleted = FALSE
      AND internal_document_type IN ('RAW_MATERIAL_RECEIPT', 'RAW_MATERIAL_ISSUE', 'FINISHED_GOODS_RECEIPT')
      AND retry_policy_code = 'STANDARD_RETRY'
      AND reconcile_policy_code = 'STANDARD_RECONCILE';
    IF actual <> 3 THEN RAISE EXCEPTION 'Expected MISA document mapping scaffold count 3, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM trade_item
    WHERE is_deleted = FALSE
      AND status = 'INACTIVE'
      AND packaging_spec = 'OWNER_PENDING_GTIN_GS1'
      AND trade_item_code LIKE 'TI-%-RETAIL-PENDING';
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected owner-pending trade item seed rows 20, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM trade_item_gtin g
    JOIN trade_item ti ON ti.trade_item_id = g.trade_item_id AND ti.is_deleted = FALSE
    WHERE g.is_deleted = FALSE
      AND g.gtin_status = 'ACTIVE'
      AND g.is_primary = TRUE
      AND g.gtin = '8930000000019'
      AND g.notes ILIKE '%TEST_ONLY_DEV_FIXTURE%'
      AND ti.trade_item_code = 'TI-A1-RETAIL-DEV-FIXTURE'
      AND ti.status = 'ACTIVE'
      AND ti.notes ILIKE '%TEST_ONLY_DEV_FIXTURE%';
    IF actual <> 1 THEN RAISE EXCEPTION 'Expected active TEST_ONLY_DEV_FIXTURE GTIN row 1, got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM packaging_trade_item_map m
    JOIN op_packaging_spec ps ON ps.id = m.packaging_spec_id AND ps.is_deleted = FALSE
    JOIN trade_item ti ON ti.trade_item_id = m.trade_item_id AND ti.is_deleted = FALSE
    JOIN trade_item_gtin g ON g.trade_item_id = ti.trade_item_id AND g.is_deleted = FALSE
    WHERE m.is_deleted = FALSE
      AND m.status = 'ACTIVE'
      AND m.is_default = TRUE
      AND m.notes ILIKE '%TEST_ONLY_DEV_FIXTURE%'
      AND ps.spec_code = 'PS-A1-SACHET-DEV-FIXTURE'
      AND ps.spec_note ILIKE '%TEST_ONLY_DEV_FIXTURE%'
      AND ti.trade_item_code = 'TI-A1-RETAIL-DEV-FIXTURE'
      AND g.gtin = '8930000000019'
      AND g.gtin_status = 'ACTIVE';
    IF actual <> 1 THEN RAISE EXCEPTION 'Expected active TEST_ONLY_DEV_FIXTURE packaging_trade_item_map row 1, got %', actual; END IF;
END $$;

SELECT 'canonical seed validation passed' AS result;
