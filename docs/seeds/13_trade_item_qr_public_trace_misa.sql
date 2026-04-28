-- Seed V2 non-recipe operational config from final/forms source packs.
-- Owner-approved production GTIN/GS1 values are still owner data.
-- One TEST_ONLY_DEV_FIXTURE GTIN/map is seeded for local validation and must not be used as production data.

BEGIN;

CREATE TEMP TABLE seed_trade_item_pending (trade_item_code text, sku_code text, packaging_level text, item_type text, packaging_spec text, status text, notes text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_trade_item_pending VALUES
('TI-A1-RETAIL-PENDING', 'A1/CS/DM/HS', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A2-RETAIL-PENDING', 'A2/CS/BASA', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A3-RETAIL-PENDING', 'A3/CS/CAHOI', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A4-RETAIL-PENDING', 'A4/CS/LUON', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-A5-RETAIL-PENDING', 'A5/CS/CUU', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B1-RETAIL-PENDING', 'B1/CS/RM/ĐX', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B2-RETAIL-PENDING', 'B2/CS/DHA', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B3-RETAIL-PENDING', 'B3/CS/CACOM', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B4-RETAIL-PENDING', 'B4/CS/COLAGEN', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B5-RETAIL-PENDING', 'B5/CS/SINHLUC', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-B6-RETAIL-PENDING', 'B6/CS/GAAC', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C1-RETAIL-PENDING', 'C1/CS/BAONGU', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C2-RETAIL-PENDING', 'C2/CS/DONGTRUNG', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C3-RETAIL-PENDING', 'C3/CS/NAMDONGCO', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C4-RETAIL-PENDING', 'C4/CS/CUABIEN', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C5-RETAIL-PENDING', 'C5/CS/CANGU', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C6-RETAIL-PENDING', 'C6/CS/TOM/RONGBIEN', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C7-RETAIL-PENDING', 'C7/CS/THITGA', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C8-RETAIL-PENDING', 'C8/CS/THITHEO', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('TI-C9-RETAIL-PENDING', 'C9/CS/THITBO', 'LEVEL_2', 'RETAIL', 'OWNER_PENDING_GTIN_GS1', 'INACTIVE', 'Owner must provide approved GTIN/GS1 and packaging spec before commercial print is enabled.', '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO trade_item (trade_item_code, sku_id, sku_code, packaging_level, item_type, packaging_spec, status, notes, created_at, is_deleted)
SELECT s.trade_item_code, sku.id, s.sku_code, s.packaging_level, s.item_type, s.packaging_spec, s.status, s.notes, s.created_at, FALSE
FROM seed_trade_item_pending s
JOIN ref_sku sku ON sku.sku_code = s.sku_code AND sku.is_deleted = FALSE
ON CONFLICT (trade_item_code) DO UPDATE SET
    sku_id = EXCLUDED.sku_id,
    sku_code = EXCLUDED.sku_code,
    packaging_level = EXCLUDED.packaging_level,
    item_type = EXCLUDED.item_type,
    packaging_spec = EXCLUDED.packaging_spec,
    status = EXCLUDED.status,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

-- DEV/TEST ONLY fixture for local print validation.
-- This is not owner-approved production GTIN/GS1 data.
INSERT INTO op_packaging_spec (
    spec_code,
    sku_id,
    packaging_type,
    inner_unit_qty,
    outer_unit_qty,
    label_template_code,
    spec_status,
    spec_note,
    commercial_unit_type,
    inner_unit_type,
    effective_from,
    effective_to,
    created_at,
    is_deleted
)
SELECT
    'PS-A1-SACHET-DEV-FIXTURE',
    sku.id,
    'SACHET',
    1,
    400,
    'TPL-SACHET-DEV-FIXTURE',
    'ACTIVE',
    'TEST_ONLY_DEV_FIXTURE: local/dev packaging spec for GTIN mapping validation; not production owner data.',
    'SACHET',
    'SACHET',
    '2025-01-01T00:00:00'::timestamp,
    NULL,
    '2025-01-01T07:00:00+07:00'::timestamptz,
    FALSE
FROM ref_sku sku
WHERE sku.sku_code = 'A1/CS/DM/HS' AND sku.is_deleted = FALSE
ON CONFLICT (spec_code) DO UPDATE SET
    sku_id = EXCLUDED.sku_id,
    packaging_type = EXCLUDED.packaging_type,
    inner_unit_qty = EXCLUDED.inner_unit_qty,
    outer_unit_qty = EXCLUDED.outer_unit_qty,
    label_template_code = EXCLUDED.label_template_code,
    spec_status = EXCLUDED.spec_status,
    spec_note = EXCLUDED.spec_note,
    commercial_unit_type = EXCLUDED.commercial_unit_type,
    inner_unit_type = EXCLUDED.inner_unit_type,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO trade_item (
    trade_item_code,
    sku_id,
    sku_code,
    packaging_level,
    item_type,
    packaging_spec,
    status,
    notes,
    created_at,
    is_deleted
)
SELECT
    'TI-A1-RETAIL-DEV-FIXTURE',
    sku.id,
    sku.sku_code,
    'LEVEL_2_DEV_FIXTURE',
    'TEST_ONLY',
    'PS-A1-SACHET-DEV-FIXTURE',
    'ACTIVE',
    'TEST_ONLY_DEV_FIXTURE: active local/dev trade item for print GTIN validation only; replace with owner-approved GTIN before production.',
    '2025-01-01T07:00:00+07:00'::timestamptz,
    FALSE
FROM ref_sku sku
WHERE sku.sku_code = 'A1/CS/DM/HS' AND sku.is_deleted = FALSE
ON CONFLICT (trade_item_code) DO UPDATE SET
    sku_id = EXCLUDED.sku_id,
    sku_code = EXCLUDED.sku_code,
    packaging_level = EXCLUDED.packaging_level,
    item_type = EXCLUDED.item_type,
    packaging_spec = EXCLUDED.packaging_spec,
    status = EXCLUDED.status,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO trade_item_gtin (
    trade_item_id,
    gtin,
    gs1_company_prefix,
    gtin_status,
    effective_from,
    effective_to,
    is_primary,
    notes,
    created_at,
    is_deleted
)
SELECT
    ti.trade_item_id,
    '8930000000019',
    '8930000',
    'ACTIVE',
    '2025-01-01T00:00:00+07:00'::timestamptz,
    NULL,
    TRUE,
    'TEST_ONLY_DEV_FIXTURE: local/dev GTIN fixture only; not owner-approved production GTIN.',
    '2025-01-01T07:00:00+07:00'::timestamptz,
    FALSE
FROM trade_item ti
WHERE ti.trade_item_code = 'TI-A1-RETAIL-DEV-FIXTURE' AND ti.is_deleted = FALSE
ON CONFLICT (gtin) DO UPDATE SET
    trade_item_id = EXCLUDED.trade_item_id,
    gs1_company_prefix = EXCLUDED.gs1_company_prefix,
    gtin_status = EXCLUDED.gtin_status,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    is_primary = TRUE,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

INSERT INTO packaging_trade_item_map (
    packaging_spec_id,
    trade_item_id,
    is_default,
    status,
    notes,
    created_at,
    is_deleted
)
SELECT
    ps.id,
    ti.trade_item_id,
    TRUE,
    'ACTIVE',
    'TEST_ONLY_DEV_FIXTURE: active local/dev packaging-to-trade-item map for GTIN validation only.',
    '2025-01-01T07:00:00+07:00'::timestamptz,
    FALSE
FROM op_packaging_spec ps
JOIN trade_item ti ON ti.trade_item_code = 'TI-A1-RETAIL-DEV-FIXTURE' AND ti.is_deleted = FALSE
WHERE ps.spec_code = 'PS-A1-SACHET-DEV-FIXTURE' AND ps.is_deleted = FALSE
ON CONFLICT (packaging_spec_id, trade_item_id) DO UPDATE SET
    is_default = TRUE,
    status = 'ACTIVE',
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

CREATE TEMP TABLE seed_qr_registry_status (id bigint, code text, name text, sort_order integer, is_public_trace_eligible boolean, is_terminal boolean, is_active boolean, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_qr_registry_status VALUES
(1, 'GENERATED', 'Generated', 10, FALSE, FALSE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(2, 'QUEUED', 'Queued for print', 20, FALSE, FALSE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(3, 'PRINTED', 'Printed', 30, TRUE, FALSE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(4, 'FAILED', 'Print failed', 40, FALSE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(5, 'VOID', 'Voided', 50, FALSE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(6, 'REPRINTED', 'Reprinted', 60, TRUE, FALSE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO ref_qr_registry_status (id, code, name, sort_order, is_public_trace_eligible, is_terminal, is_active, created_at, is_deleted)
SELECT id, code, name, sort_order, is_public_trace_eligible, is_terminal, is_active, created_at, FALSE
FROM seed_qr_registry_status
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    sort_order = EXCLUDED.sort_order,
    is_public_trace_eligible = EXCLUDED.is_public_trace_eligible,
    is_terminal = EXCLUDED.is_terminal,
    is_active = EXCLUDED.is_active,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

CREATE TEMP TABLE seed_public_trace_policy (id bigint, field_group text, public_allowed boolean, policy_note text, source_policy text, sort_order integer, is_active boolean, effective_from timestamptz, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_public_trace_policy VALUES
(1, 'SKU_NAME', TRUE, 'Product SKU/name can be shown publicly.', 'CANONICAL_V2', 10, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(2, 'BATCH_DISPLAY', TRUE, 'Batch display identifiers can be shown publicly.', 'CANONICAL_V2', 20, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(3, 'MFG_EXP', TRUE, 'Manufacturing and expiry display fields can be shown publicly.', 'CANONICAL_V2', 30, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(4, 'PROCESS_PUBLIC_STEP', TRUE, 'Approved public process steps can be shown.', 'CANONICAL_V2', 60, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(5, 'SUPPLIER_SENSITIVE', FALSE, 'Supplier-sensitive details are internal only.', 'CANONICAL_V2', 70, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(6, 'PERSONNEL', FALSE, 'Internal personnel fields are internal only.', 'CANONICAL_V2', 80, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(7, 'COSTING_MISA', FALSE, 'Costing and MISA fields are internal only.', 'CANONICAL_V2', 90, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(8, 'QC_DEFECT_DETAIL', FALSE, 'QC defect details are internal only.', 'CANONICAL_V2', 100, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(9, 'LOSS_VARIANCE', FALSE, 'Loss and variance details are internal only.', 'CANONICAL_V2', 110, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(10, 'VERIFICATION_STATUS', TRUE, 'Public verification status can be shown.', 'CANONICAL_V2', 40, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(11, 'USAGE_INSTRUCTION', TRUE, 'Approved public usage instructions can be shown.', 'CANONICAL_V2', 50, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO op_public_trace_field_policy (id, field_group, public_allowed, policy_note, source_policy, sort_order, is_active, effective_from, effective_to, created_at, is_deleted)
SELECT id, field_group, public_allowed, policy_note, source_policy, sort_order, is_active, effective_from, NULL, created_at, FALSE
FROM seed_public_trace_policy
ON CONFLICT (field_group) DO UPDATE SET
    public_allowed = EXCLUDED.public_allowed,
    policy_note = EXCLUDED.policy_note,
    source_policy = EXCLUDED.source_policy,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    effective_from = EXCLUDED.effective_from,
    effective_to = NULL,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

CREATE TEMP TABLE seed_misa_document_mapping (internal_document_type text, misa_document_type text, module_code text, retry_policy_code text, reconcile_policy_code text, is_active boolean, notes text, created_at timestamptz) ON COMMIT DROP;
INSERT INTO seed_misa_document_mapping VALUES
('RAW_MATERIAL_RECEIPT', 'OWNER_PENDING_RAW_MATERIAL_RECEIPT', 'RAW_MATERIAL', 'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('RAW_MATERIAL_ISSUE', 'OWNER_PENDING_RAW_MATERIAL_ISSUE', 'MANUFACTURING', 'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FINISHED_GOODS_RECEIPT', 'OWNER_PENDING_FINISHED_GOODS_RECEIPT', 'WAREHOUSE_INVENTORY', 'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO op_misa_document_mapping (internal_document_type, misa_document_type, module_code, retry_policy_code, reconcile_policy_code, is_active, notes, created_at, is_deleted)
SELECT internal_document_type, misa_document_type, module_code, retry_policy_code, reconcile_policy_code, is_active, notes, created_at, FALSE
FROM seed_misa_document_mapping
ON CONFLICT (internal_document_type) DO UPDATE SET
    misa_document_type = EXCLUDED.misa_document_type,
    module_code = EXCLUDED.module_code,
    retry_policy_code = EXCLUDED.retry_policy_code,
    reconcile_policy_code = EXCLUDED.reconcile_policy_code,
    is_active = EXCLUDED.is_active,
    notes = EXCLUDED.notes,
    is_deleted = FALSE,
    deleted_at = NULL,
    updated_at = NOW();

COMMIT;
