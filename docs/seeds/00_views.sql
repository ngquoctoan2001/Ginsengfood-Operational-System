-- Ginsengfood Operational seed step 00.
-- Run this after `dotnet ef database update` on a fresh database.
-- EF Core model snapshots do not store view definitions, so the squashed
-- InitialCreate migration creates tables/indexes/constraints only.

CREATE OR REPLACE VIEW op_inventory_availability_by_sku AS
SELECT
    b.sku_id,
    SUM(ilb.available_qty) AS total_available_qty,
    MAX(ilb.updated_at) AS last_updated
FROM op_inventory_lot_balance ilb
JOIN op_batch b ON b.id = ilb.batch_id
WHERE ilb.stock_status = 'AVAILABLE'
  AND ilb.is_deleted = FALSE
  AND NOT EXISTS (
      SELECT 1 FROM op_batch_hold_registry h
      WHERE h.batch_id = b.id AND h.hold_status = 'ACTIVE'
  )
GROUP BY b.sku_id;

CREATE OR REPLACE VIEW vw_admin_warehouse_batch_stock AS
SELECT
    ilb.batch_id,
    ilb.warehouse_id,
    ilb.location_id,
    SUM(ilb.on_hand_qty) AS balance_qty,
    SUM(ilb.available_qty) AS available_qty,
    SUM(ilb.allocated_qty) AS allocated_qty,
    MIN(ilb.nearest_exp_date) AS nearest_exp_date
FROM op_inventory_lot_balance ilb
WHERE ilb.is_deleted = FALSE
GROUP BY ilb.batch_id, ilb.warehouse_id, ilb.location_id;

CREATE OR REPLACE VIEW vw_public_traceability AS
SELECT
    r.id,
    r.batch_id,
    r.qr_token,
    r.qr_type,
    r.public_trace_url,
    r.qr_status,
    r.is_public,
    r.issued_at,
    r.expired_at,
    r.generation_source,
    r.invalidated_at
FROM op_trace_qr_registry r
WHERE r.is_deleted = FALSE
  AND r.is_public = TRUE
  AND r.qr_status = 'ACTIVE'
  AND r.invalidated_at IS NULL;

CREATE OR REPLACE VIEW vw_internal_traceability AS
SELECT
    r.id,
    r.batch_id,
    r.qr_token,
    r.qr_type,
    r.public_trace_url,
    r.qr_status,
    r.is_public,
    r.issued_at,
    r.expired_at,
    r.generation_source,
    r.invalidated_at,
    r.invalidation_reason,
    r.packaging_job_unit_id,
    r.qr_note,
    r.created_at,
    r.created_by,
    r.updated_at,
    r.updated_by,
    (
        SELECT COUNT(*)
        FROM op_production_step ps
        WHERE ps.batch_id = r.batch_id
          AND ps.is_deleted = FALSE
    ) AS step_count,
    (
        SELECT COUNT(*)
        FROM op_batch_genealogy_link bgl
        WHERE bgl.descendant_id = r.batch_id
          AND bgl.is_deleted = FALSE
    ) AS genealogy_link_count
FROM op_trace_qr_registry r
WHERE r.is_deleted = FALSE;

CREATE OR REPLACE VIEW vw_admin_executive_production_summary AS
SELECT
    CURRENT_DATE AS snapshot_date,
    COUNT(DISTINCT po.id) AS production_order_count,
    COALESCE(SUM(po.planned_qty), 0) AS total_planned_qty,
    COALESCE(SUM(b.produced_qty), 0) AS total_produced_qty,
    COALESCE(SUM(qi.accepted_qty), 0) AS total_accepted_qty,
    COALESCE(SUM(qi.rejected_qty), 0) AS total_rejected_qty,
    CASE
        WHEN COALESCE(SUM(b.produced_qty), 0) = 0 THEN 0
        ELSE ROUND(
            (COALESCE(SUM(qi.accepted_qty), 0)::numeric / SUM(b.produced_qty)) * 100, 2
        )
    END AS yield_percent,
    CASE
        WHEN COALESCE(SUM(b.produced_qty), 0) = 0 THEN 0
        ELSE ROUND(
            (COALESCE(SUM(qi.rejected_qty), 0)::numeric / SUM(b.produced_qty)) * 100, 2
        )
    END AS defect_rate_percent
FROM op_production_order po
LEFT JOIN op_batch b
    ON b.production_order_id = po.id AND b.is_deleted = FALSE
LEFT JOIN op_qc_inspection qi
    ON qi.batch_id = b.id AND qi.is_deleted = FALSE
WHERE po.is_deleted = FALSE;

CREATE OR REPLACE VIEW vw_admin_executive_batch_risk AS
SELECT
    b.id AS batch_id,
    b.batch_code,
    b.sku_id,
    bhr.hold_status,
    bsl.lock_status AS sale_lock_status,
    rc.case_status AS recall_case_status,
    rc.severity_level,
    rc.recall_case_no
FROM op_batch b
LEFT JOIN op_batch_hold_registry bhr
    ON bhr.batch_id = b.id
   AND bhr.hold_status = 'ACTIVE'
   AND bhr.is_deleted = FALSE
LEFT JOIN op_batch_sale_lock_registry bsl
    ON bsl.batch_id = b.id
   AND bsl.lock_status IN ('REQUESTED', 'ACTIVE')
   AND bsl.is_deleted = FALSE
LEFT JOIN op_recall_case_batch rcb
    ON rcb.batch_id = b.id AND rcb.is_deleted = FALSE
LEFT JOIN op_recall_case rc
    ON rc.id = rcb.recall_case_id
   AND rc.case_status NOT IN ('CLOSED', 'CLOSED_WITH_RESIDUAL_RISK')
   AND rc.is_deleted = FALSE
WHERE b.is_deleted = FALSE
  AND (
        bhr.id IS NOT NULL
     OR bsl.id IS NOT NULL
     OR rc.id IS NOT NULL
  );

CREATE OR REPLACE VIEW vw_admin_production_execution_queue AS
SELECT
    po.id AS production_order_id,
    po.production_order_no,
    po.sku_id,
    po.production_status AS order_status,
    po.planned_qty,
    b.id AS batch_id,
    b.produced_qty,
    b.batch_status,
    b.mfg_date,
    b.exp_date
FROM op_production_order po
LEFT JOIN op_batch b
    ON b.production_order_id = po.id AND b.is_deleted = FALSE
WHERE po.is_deleted = FALSE
  AND po.production_status IN ('RELEASED', 'IN_PROGRESS');

-- vw_admin_packaging_line_monitor: REMOVED Phase 5.
-- Lý do: schema cũ tham chiếu `op_packaging_order` + `packaging_spec_id` + `packed_box_qty` / `packed_sachet_qty` không còn tồn tại.
-- Canonical Phase 5: dùng `op_packaging_job` (snapshot fields `trade_item_id_snapshot`,
-- `packaging_level`, `units_per_box_snapshot`, `boxes_per_carton_snapshot`, `carton_requested`)
-- join `op_trade_item` cho `packaging_level` (PACKET/BOX/CARTON). Recreate khi schema Phase 5 stable.

CREATE OR REPLACE VIEW vw_admin_qc_review_queue AS
SELECT
    b.id AS batch_id,
    b.batch_code,
    b.sku_id,
    b.batch_status,
    qi.id AS qc_inspection_id,
    qi.inspection_no,
    qi.qc_result AS inspection_status,
    qi.qc_stage,
    qi.inspected_qty,
    qi.accepted_qty,
    qi.rejected_qty,
    qi.hold_qty,
    (qi.accepted_qty > 0) AS accepted_flag,
    (qi.rejected_qty > 0) AS rejected_flag,
    (qi.hold_qty > 0) AS hold_flag,
    qi.inspected_at
FROM op_batch b
INNER JOIN op_qc_inspection qi
    ON qi.batch_id = b.id AND qi.is_deleted = FALSE
WHERE b.is_deleted = FALSE
  AND qi.qc_result = 'PENDING';

CREATE OR REPLACE VIEW vw_admin_recall_contact_queue AS
SELECT
    rci.id AS recall_customer_impact_id,
    rci.recall_case_id,
    rci.customer_id,
    rci.order_id,
    rci.shipment_id,
    rci.batch_id,
    rci.contact_priority,
    rci.contact_status,
    rci.resolution_status,
    rct.id AS recall_contact_task_id,
    rct.task_status,
    rct.assigned_to_actor_id AS assigned_to,
    rct.next_attempt_at
FROM op_recall_customer_impact rci
LEFT JOIN op_recall_contact_task rct
    ON rct.customer_impact_id = rci.id AND rct.is_deleted = FALSE
WHERE rci.is_deleted = FALSE
  AND rci.resolution_status IN ('OPEN', 'PARTIALLY_RESOLVED');

CREATE OR REPLACE VIEW vw_admin_trace_search_projection AS
SELECT
    tsi.search_type,
    tsi.search_value,
    tsi.batch_id,
    tsi.production_order_id AS order_id,
    tsi.shipment_id,
    tsi.customer_id,
    tsi.raw_material_lot_id,
    tsi.qr_registry_id,
    tsi.source_entity_type,
    tsi.source_entity_id,
    tsi.indexed_at
FROM op_trace_search_index tsi
WHERE tsi.is_deleted = FALSE;

-- vw_packaging_print_level: REMOVED Phase 5.
-- Lý do: schema cũ tham chiếu `op_packaging_spec` (sachet_template_id, box_template_id) +
-- `op_packaging_order` không còn tồn tại trong Phase 5.
-- Canonical Phase 5: print level suy ra từ `op_packaging_job.packaging_level` (PACKET/BOX/CARTON)
-- + `op_trade_item.packaging_level` (đã snapshot vào job). Print template chọn theo packaging_level
-- + trade_item_id snapshot, không qua bảng spec trung gian.

CREATE OR REPLACE VIEW vw_recall_impact_summary AS
SELECT
    rc.id AS recall_case_id,
    rc.recall_case_no,
    rc.case_status,
    rc.recall_type,
    rc.severity_level,
    rc.opened_at,
    rcb.batch_id,
    b.batch_code,
    b.sku_id,
    COALESCE(SUM(rii.impacted_qty), 0) AS total_impacted_qty,
    COUNT(DISTINCT rii.warehouse_id) AS affected_warehouse_count,
    CASE
        WHEN COUNT(CASE WHEN bhr.hold_status = 'ACTIVE'
                         AND bhr.is_deleted = FALSE THEN 1 END) > 0
        THEN TRUE ELSE FALSE
    END AS is_on_hold,
    CASE
        WHEN COUNT(CASE WHEN bslr.lock_status IN ('REQUESTED', 'CONFIRMED')
                         AND bslr.is_deleted = FALSE THEN 1 END) > 0
        THEN TRUE ELSE FALSE
    END AS is_sale_locked
FROM op_recall_case rc
JOIN op_recall_case_batch rcb
    ON rcb.recall_case_id = rc.id AND rcb.is_deleted = FALSE
JOIN op_batch b
    ON b.id = rcb.batch_id AND b.is_deleted = FALSE
LEFT JOIN op_recall_inventory_impact rii
    ON rii.recall_case_id = rc.id AND rii.batch_id = rcb.batch_id AND rii.is_deleted = FALSE
LEFT JOIN op_batch_hold_registry bhr
    ON bhr.batch_id = rcb.batch_id
LEFT JOIN op_batch_sale_lock_registry bslr
    ON bslr.batch_id = rcb.batch_id
WHERE rc.is_deleted = FALSE
GROUP BY
    rc.id, rc.recall_case_no, rc.case_status, rc.recall_type,
    rc.severity_level, rc.opened_at,
    rcb.batch_id, b.batch_code, b.sku_id;

CREATE OR REPLACE VIEW vw_recall_recovery_summary AS
SELECT
    rc.id AS recall_case_id,
    rc.recall_case_no,
    rc.case_status,
    COUNT(DISTINCT rri.id) AS recovery_item_count,
    COALESCE(SUM(rri.recovered_qty), 0) AS total_recovered_qty,
    COUNT(DISTINCT rri.batch_id) AS recovered_batch_count,
    COUNT(DISTINCT CASE WHEN rri.recovery_status = 'COMPLETED' THEN rri.id END) AS completed_recovery_count,
    COUNT(DISTINCT CASE WHEN rri.recovery_status = 'DISPOSED' THEN rri.id END) AS disposed_recovery_count,
    COALESCE(
        SUM(CASE WHEN rrd.disposition_status IN ('EXECUTED', 'VERIFIED')
                  AND rrd.is_deleted = FALSE
                 THEN rrd.disposition_qty END),
        0
    ) AS total_disposed_qty,
    COUNT(DISTINCT CASE WHEN rrd.is_deleted = FALSE THEN rrd.id END) AS disposition_count
FROM op_recall_case rc
LEFT JOIN op_recall_recovery_item rri
    ON rri.recall_case_id = rc.id AND rri.is_deleted = FALSE
LEFT JOIN op_recall_disposition_record rrd
    ON rrd.recall_case_id = rc.id AND rrd.is_deleted = FALSE
WHERE rc.is_deleted = FALSE
GROUP BY rc.id, rc.recall_case_no, rc.case_status;
