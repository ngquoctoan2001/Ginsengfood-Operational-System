-- Canonical Ginsengfood V2 seed validation. Phase 5 reconcile:
-- - ref_sku_operational_config: canonical fields only (readiness_status, default_batch_size,
--   qc_required, trace_public_enabled, recall_applicable). Active recipe derive từ
--   op_production_recipe.formula_status='ACTIVE_OPERATIONAL'; KHÔNG check active_recipe_code/
--   recipe_version/packaging fields ở config (đã loại bỏ Phase 5).
-- - Trade item / identifier: check canonical op_trade_item + op_trade_item_gtin (3 cấp).
--   Legacy trade_item / trade_item_gtin / packaging_trade_item_map đã bị xoá Phase 5.
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

    -- SV-006 Phase 5: ref_sku_operational_config canonical schema (no drift fields).
    SELECT COUNT(*) INTO actual
    FROM ref_sku_operational_config c
    JOIN ref_sku s ON s.id = c.sku_id AND s.is_deleted = FALSE
    WHERE c.is_deleted = FALSE
      AND c.readiness_status = 'READY'
      AND c.default_batch_size = 400.000
      AND c.qc_required = TRUE
      AND c.trace_public_enabled = TRUE
      AND c.recall_applicable = TRUE;
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected canonical ref_sku_operational_config rows 20, got %', actual; END IF;

    -- SV-006b: every SKU resolves to exactly one ACTIVE_OPERATIONAL G1 recipe (replaces
    -- the dropped active_recipe_code/recipe_version columns).
    SELECT COUNT(*) INTO actual
    FROM ref_sku s
    LEFT JOIN op_production_recipe r ON r.sku_id = s.id
        AND r.is_deleted = FALSE
        AND r.formula_version = 'G1'
        AND r.formula_status = 'ACTIVE_OPERATIONAL'
        AND r.source_of_truth = TRUE
    WHERE s.is_deleted = FALSE AND r.id IS NULL;
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected every SKU to have an active G1 recipe via op_production_recipe, missing %', actual; END IF;

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

    -- SV-018: every active G1 recipe header must declare formula_kind = 'PILOT_PERCENT_BASED'
    -- and populate all 4 anchor metadata columns; FIXED_QUANTITY_BATCH must keep them NULL.
    SELECT COUNT(*) INTO actual
    FROM op_production_recipe
    WHERE is_deleted = FALSE
      AND formula_version = 'G1'
      AND formula_status = 'ACTIVE_OPERATIONAL'
      AND (
          formula_kind <> 'PILOT_PERCENT_BASED'
          OR anchor_ingredient_id IS NULL
          OR anchor_baseline_quantity IS NULL OR anchor_baseline_quantity <= 0
          OR anchor_uom_code IS NULL
          OR anchor_ratio_percent IS NULL OR anchor_ratio_percent <= 0 OR anchor_ratio_percent > 100
      );
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected every active G1 recipe header to be PILOT_PERCENT_BASED with anchor metadata populated, bad rows %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_production_recipe
    WHERE is_deleted = FALSE
      AND formula_kind = 'FIXED_QUANTITY_BATCH'
      AND (
          anchor_ingredient_id IS NOT NULL
          OR anchor_baseline_quantity IS NOT NULL
          OR anchor_uom_code IS NOT NULL
          OR anchor_ratio_percent IS NOT NULL
      );
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected FIXED_QUANTITY_BATCH recipes to have all anchor metadata NULL, bad rows %', actual; END IF;

    -- SV-019: every PILOT_PERCENT_BASED recipe must have exactly 1 line with is_anchor = TRUE,
    -- and that line must reference the header's anchor_ingredient_id.
    SELECT COUNT(*) INTO actual
    FROM (
        SELECT r.id AS recipe_id, COUNT(*) FILTER (WHERE ri.is_anchor = TRUE) AS anchor_count
        FROM op_production_recipe r
        LEFT JOIN op_recipe_ingredient ri ON ri.recipe_id = r.id AND ri.is_deleted = FALSE
        WHERE r.is_deleted = FALSE AND r.formula_kind = 'PILOT_PERCENT_BASED' AND r.formula_status = 'ACTIVE_OPERATIONAL'
        GROUP BY r.id
        HAVING COUNT(*) FILTER (WHERE ri.is_anchor = TRUE) <> 1
    ) bad;
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected exactly 1 anchor line per active PILOT recipe, recipes with bad anchor count %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_production_recipe r
    JOIN op_recipe_ingredient ri ON ri.recipe_id = r.id AND ri.is_deleted = FALSE AND ri.is_anchor = TRUE
    WHERE r.is_deleted = FALSE
      AND r.formula_kind = 'PILOT_PERCENT_BASED'
      AND r.formula_status = 'ACTIVE_OPERATIONAL'
      AND ri.material_id IS DISTINCT FROM r.anchor_ingredient_id;
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected anchor line material_id to match recipe header anchor_ingredient_id for every active PILOT recipe, mismatched rows %', actual; END IF;

    -- SV-020: FIXED_QUANTITY_BATCH lines must have quantity_per_batch_400 > 0 and is_anchor = FALSE.
    SELECT COUNT(*) INTO actual
    FROM op_recipe_ingredient ri
    JOIN op_production_recipe r ON r.id = ri.recipe_id AND r.is_deleted = FALSE
    WHERE ri.is_deleted = FALSE
      AND r.formula_kind = 'FIXED_QUANTITY_BATCH'
      AND (ri.is_anchor = TRUE OR ri.quantity_per_batch_400 IS NULL OR ri.quantity_per_batch_400 <= 0);
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected FIXED_QUANTITY_BATCH lines to have quantity_per_batch_400 > 0 and is_anchor = FALSE, bad rows %', actual; END IF;

    -- SV-021 Phase 5: canonical op_trade_item PACKET + BOX seed cho 20 SKU.
    SELECT COUNT(*) INTO actual
    FROM op_trade_item
    WHERE is_deleted = FALSE
      AND packaging_level = 'PACKET'
      AND units_per_box IS NULL
      AND boxes_per_carton IS NULL
      AND carton_enabled = FALSE
      AND status = 'INACTIVE'
      AND trade_item_code LIKE 'TI-%-PACKET-PENDING';
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected 20 PACKET trade items (carton_enabled=false, INACTIVE), got %', actual; END IF;

    SELECT COUNT(*) INTO actual
    FROM op_trade_item
    WHERE is_deleted = FALSE
      AND packaging_level = 'BOX'
      AND units_per_box = 4
      AND boxes_per_carton IS NULL
      AND carton_enabled = FALSE
      AND status = 'INACTIVE'
      AND trade_item_code LIKE 'TI-%-BOX-PENDING';
    IF actual <> 20 THEN RAISE EXCEPTION 'Expected 20 BOX trade items (units_per_box=4, carton_enabled=false, INACTIVE), got %', actual; END IF;

    -- SV-021b: NO CARTON trade item seeded; owner enables per-SKU.
    SELECT COUNT(*) INTO actual
    FROM op_trade_item
    WHERE is_deleted = FALSE AND packaging_level = 'CARTON';
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected 0 seeded CARTON trade items (owner enables per SKU), got %', actual; END IF;

    -- SV-021c: every PACKET + BOX trade item resolves to a SKU.
    SELECT COUNT(*) INTO actual
    FROM op_trade_item ti
    LEFT JOIN ref_sku sku ON sku.id = ti.sku_id AND sku.is_deleted = FALSE
    WHERE ti.is_deleted = FALSE
      AND ti.packaging_level IN ('PACKET', 'BOX')
      AND sku.id IS NULL;
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected every PACKET/BOX trade item to resolve to a SKU, unresolved %', actual; END IF;

    -- SV-022: 1 INACTIVE INTERNAL_BARCODE placeholder per seeded trade item (40 total).
    SELECT COUNT(*) INTO actual
    FROM op_trade_item_gtin g
    JOIN op_trade_item ti ON ti.id = g.trade_item_id AND ti.is_deleted = FALSE
    WHERE g.is_deleted = FALSE
      AND g.identifier_type = 'INTERNAL_BARCODE'
      AND g.identifier_value LIKE 'PENDING-TI-%-PENDING'
      AND g.status = 'INACTIVE'
      AND g.is_test_fixture = FALSE;
    IF actual <> 40 THEN RAISE EXCEPTION 'Expected 40 INACTIVE INTERNAL_BARCODE placeholders (1 per PACKET/BOX trade item), got %', actual; END IF;

    -- SV-022b: NO ACTIVE identifier seeded; ACTIVE GTIN_13/GTIN_14/SSCC requires owner data.
    SELECT COUNT(*) INTO actual
    FROM op_trade_item_gtin
    WHERE is_deleted = FALSE AND status = 'ACTIVE';
    IF actual <> 0 THEN RAISE EXCEPTION 'Expected 0 ACTIVE op_trade_item_gtin rows in seed (owner provides production GTIN), got %', actual; END IF;
END $$;

SELECT 'canonical seed validation passed' AS result;
