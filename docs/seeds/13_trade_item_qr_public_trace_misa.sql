-- Seed V2 non-recipe operational reference data: QR registry status, public trace field policy,
-- MISA document mapping. Phase 5 reconcile: legacy `trade_item` / `trade_item_gtin` /
-- `packaging_trade_item_map` / `op_packaging_spec` dev fixtures đã được loại bỏ; canonical
-- `op_trade_item` + `op_trade_item_gtin` (3 cấp PACKET/BOX/CARTON) seed nằm ở
-- `docs/seeds/16_op_trade_item_packaging.sql`.

BEGIN;

CREATE TEMP TABLE seed_qr_registry_status (
    id bigint, code text, name text, sort_order integer,
    is_public_trace_eligible boolean, is_terminal boolean, is_active boolean,
    created_at timestamptz
) ON COMMIT DROP;
INSERT INTO seed_qr_registry_status VALUES
(1, 'GENERATED', 'Generated', 10, FALSE, FALSE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(2, 'QUEUED', 'Queued for print', 20, FALSE, FALSE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(3, 'PRINTED', 'Printed', 30, TRUE, FALSE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(4, 'FAILED', 'Print failed', 40, FALSE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(5, 'VOID', 'Voided', 50, FALSE, TRUE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz),
(6, 'REPRINTED', 'Reprinted', 60, TRUE, FALSE, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO ref_qr_registry_status (
    id, code, name, sort_order,
    is_public_trace_eligible, is_terminal, is_active,
    created_at, is_deleted
)
SELECT id, code, name, sort_order,
       is_public_trace_eligible, is_terminal, is_active,
       created_at, FALSE
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

CREATE TEMP TABLE seed_public_trace_policy (
    id bigint, field_group text, public_allowed boolean,
    policy_note text, source_policy text, sort_order integer,
    is_active boolean, effective_from timestamptz, created_at timestamptz
) ON COMMIT DROP;
INSERT INTO seed_public_trace_policy VALUES
(1,  'SKU_NAME',            TRUE,  'Product SKU/name can be shown publicly.',                  'CANONICAL_V2',  10, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(2,  'BATCH_DISPLAY',       TRUE,  'Batch display identifiers can be shown publicly.',         'CANONICAL_V2',  20, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(3,  'MFG_EXP',             TRUE,  'Manufacturing and expiry display fields can be shown publicly.', 'CANONICAL_V2', 30, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(4,  'PROCESS_PUBLIC_STEP', TRUE,  'Approved public process steps can be shown.',              'CANONICAL_V2',  60, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(5,  'SUPPLIER_SENSITIVE',  FALSE, 'Supplier-sensitive details are internal only.',            'CANONICAL_V2',  70, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(6,  'PERSONNEL',           FALSE, 'Internal personnel fields are internal only.',             'CANONICAL_V2',  80, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(7,  'COSTING_MISA',        FALSE, 'Costing and MISA fields are internal only.',               'CANONICAL_V2',  90, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(8,  'QC_DEFECT_DETAIL',    FALSE, 'QC defect details are internal only.',                     'CANONICAL_V2', 100, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(9,  'LOSS_VARIANCE',       FALSE, 'Loss and variance details are internal only.',             'CANONICAL_V2', 110, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(10, 'VERIFICATION_STATUS', TRUE,  'Public verification status can be shown.',                 'CANONICAL_V2',  40, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz),
(11, 'USAGE_INSTRUCTION',   TRUE,  'Approved public usage instructions can be shown.',         'CANONICAL_V2',  50, TRUE, '2025-01-01T07:00:00+07:00'::timestamptz, '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO op_public_trace_field_policy (
    id, field_group, public_allowed, policy_note, source_policy,
    sort_order, is_active, effective_from, effective_to,
    created_at, is_deleted
)
SELECT id, field_group, public_allowed, policy_note, source_policy,
       sort_order, is_active, effective_from, NULL,
       created_at, FALSE
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

CREATE TEMP TABLE seed_misa_document_mapping (
    internal_document_type text, misa_document_type text, module_code text,
    retry_policy_code text, reconcile_policy_code text,
    is_active boolean, notes text, created_at timestamptz
) ON COMMIT DROP;
INSERT INTO seed_misa_document_mapping VALUES
('RAW_MATERIAL_RECEIPT',   'OWNER_PENDING_RAW_MATERIAL_RECEIPT',   'RAW_MATERIAL',        'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('RAW_MATERIAL_ISSUE',     'OWNER_PENDING_RAW_MATERIAL_ISSUE',     'MANUFACTURING',       'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', '2025-01-01T07:00:00+07:00'::timestamptz),
('FINISHED_GOODS_RECEIPT', 'OWNER_PENDING_FINISHED_GOODS_RECEIPT', 'WAREHOUSE_INVENTORY', 'STANDARD_RETRY', 'STANDARD_RECONCILE', FALSE, 'Owner must approve the exact MISA document type before sync can be enabled.', '2025-01-01T07:00:00+07:00'::timestamptz);

INSERT INTO op_misa_document_mapping (
    internal_document_type, misa_document_type, module_code,
    retry_policy_code, reconcile_policy_code,
    is_active, notes, created_at, is_deleted
)
SELECT internal_document_type, misa_document_type, module_code,
       retry_policy_code, reconcile_policy_code,
       is_active, notes, created_at, FALSE
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
