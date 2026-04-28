-- Seed operational event type registry.

BEGIN;

WITH seed(event_type_code, event_type_name, event_group, schema_version, description, is_active, created_at) AS (
    VALUES
    ('BATCH_RELEASED', 'Batch Được Release', 'Manufacturing', 1, 'QC passed, batch released', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('BATCH_BLOCKED', 'Batch Bị Block', 'Manufacturing', 1, 'Batch blocked by QC', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('RECEIPT_CONFIRMED', 'Nhập Kho Xác Nhận', 'WarehouseInventory', 1, 'Warehouse receipt confirmed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('RECALL_CASE_OPENED', 'Thu Hồi Mở', 'Recall', 1, 'Recall case opened', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('RECALL_CASE_CLOSED', 'Thu Hồi Đóng', 'Recall', 1, 'Recall case closed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('LOT_QC_PASSED', 'Lô RM QC Đạt', 'RawMaterial', 1, 'Raw material lot QC passed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('WORK_ORDER_COMPLETED', 'Work Order Hoàn Thành', 'Manufacturing', 1, 'Work order completed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('PACKAGING_JOB_COMPLETED', 'Đóng Gói Hoàn Thành', 'Packaging', 1, 'Packaging job completed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('STOCK_ADJUSTMENT', 'Điều Chỉnh Tồn Kho', 'WarehouseInventory', 1, 'Stock adjustment ledger entry', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('TRACE_INDEX_REBUILT', 'Chỉ Mục Truy Vết Cập Nhật', 'Traceability', 1, 'Trace search index rebuilt', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('PRODUCTION_ORDER_APPROVED', 'Lệnh SX Duyệt', 'Manufacturing', 1, 'Production order approved', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('PRODUCTION_ORDER_RELEASED', 'Lệnh SX Phát Hành', 'Manufacturing', 1, 'Production order released', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('BATCH_HOLD_ACTIVATED', 'Batch Bị Giữ', 'Recall', 1, 'Batch hold activated', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('QR_ISSUED', 'QR Phát Hành', 'Traceability', 1, 'QR token issued for batch', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('SHIPMENT_ALLOCATED', 'Phân Bổ Lô Hàng', 'WarehouseInventory', 1, 'Batch allocated to shipment', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('SHIPMENT_STOCK_ISSUED', 'Shipment Stock Issued', 'TRACEABILITY', 1, 'Stock issued against shipment allocation.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('SHIPMENT_ALLOCATION_ASSIGNED', 'Shipment Allocation Assigned', 'TRACEABILITY', 1, 'Batch allocation assigned to shipment.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('BATCH_MATERIAL_USAGE_RECORDED', 'Batch Material Usage Recorded', 'TRACEABILITY', 1, 'Material usage line recorded for batch genealogy.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('SHIPMENT_CONFIRMED', 'Shipment Confirmed', 'TRACEABILITY', 1, 'Shipment allocation confirmed/released.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('MATERIAL_ISSUED', 'Material Issued to Production', 'TRACEABILITY', 1, 'Raw material lot issued into production flow.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('WAREHOUSE_RECEIPT_CONFIRMED', 'Warehouse Receipt Confirmed', 'TRACEABILITY', 1, 'Warehouse receipt confirmed; used to automate public QR and genealogy projection.', TRUE, '2026-04-24T15:32:01.685072+07:00'::timestamptz)
)
UPDATE ref_operational_event_type e
SET event_type_name = s.event_type_name,
    event_group = s.event_group,
    schema_version = s.schema_version,
    description = s.description,
    is_active = s.is_active,
    updated_at = NOW()
FROM seed s
WHERE e.event_type_code = s.event_type_code
  AND e.is_deleted = FALSE;

WITH seed(event_type_code, event_type_name, event_group, schema_version, description, is_active, created_at) AS (
    VALUES
    ('BATCH_RELEASED', 'Batch Được Release', 'Manufacturing', 1, 'QC passed, batch released', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('BATCH_BLOCKED', 'Batch Bị Block', 'Manufacturing', 1, 'Batch blocked by QC', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('RECEIPT_CONFIRMED', 'Nhập Kho Xác Nhận', 'WarehouseInventory', 1, 'Warehouse receipt confirmed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('RECALL_CASE_OPENED', 'Thu Hồi Mở', 'Recall', 1, 'Recall case opened', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('RECALL_CASE_CLOSED', 'Thu Hồi Đóng', 'Recall', 1, 'Recall case closed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('LOT_QC_PASSED', 'Lô RM QC Đạt', 'RawMaterial', 1, 'Raw material lot QC passed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('WORK_ORDER_COMPLETED', 'Work Order Hoàn Thành', 'Manufacturing', 1, 'Work order completed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('PACKAGING_JOB_COMPLETED', 'Đóng Gói Hoàn Thành', 'Packaging', 1, 'Packaging job completed', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('STOCK_ADJUSTMENT', 'Điều Chỉnh Tồn Kho', 'WarehouseInventory', 1, 'Stock adjustment ledger entry', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('TRACE_INDEX_REBUILT', 'Chỉ Mục Truy Vết Cập Nhật', 'Traceability', 1, 'Trace search index rebuilt', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('PRODUCTION_ORDER_APPROVED', 'Lệnh SX Duyệt', 'Manufacturing', 1, 'Production order approved', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('PRODUCTION_ORDER_RELEASED', 'Lệnh SX Phát Hành', 'Manufacturing', 1, 'Production order released', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('BATCH_HOLD_ACTIVATED', 'Batch Bị Giữ', 'Recall', 1, 'Batch hold activated', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('QR_ISSUED', 'QR Phát Hành', 'Traceability', 1, 'QR token issued for batch', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('SHIPMENT_ALLOCATED', 'Phân Bổ Lô Hàng', 'WarehouseInventory', 1, 'Batch allocated to shipment', TRUE, '2026-04-11T14:54:24.361542+07:00'::timestamptz),
    ('SHIPMENT_STOCK_ISSUED', 'Shipment Stock Issued', 'TRACEABILITY', 1, 'Stock issued against shipment allocation.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('SHIPMENT_ALLOCATION_ASSIGNED', 'Shipment Allocation Assigned', 'TRACEABILITY', 1, 'Batch allocation assigned to shipment.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('BATCH_MATERIAL_USAGE_RECORDED', 'Batch Material Usage Recorded', 'TRACEABILITY', 1, 'Material usage line recorded for batch genealogy.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('SHIPMENT_CONFIRMED', 'Shipment Confirmed', 'TRACEABILITY', 1, 'Shipment allocation confirmed/released.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('MATERIAL_ISSUED', 'Material Issued to Production', 'TRACEABILITY', 1, 'Raw material lot issued into production flow.', TRUE, '2026-04-21T15:46:36.462312+07:00'::timestamptz),
    ('WAREHOUSE_RECEIPT_CONFIRMED', 'Warehouse Receipt Confirmed', 'TRACEABILITY', 1, 'Warehouse receipt confirmed; used to automate public QR and genealogy projection.', TRUE, '2026-04-24T15:32:01.685072+07:00'::timestamptz)
)
INSERT INTO ref_operational_event_type (event_type_code, event_type_name, event_group, schema_version, description, is_active, created_at, is_deleted)
SELECT s.event_type_code, s.event_type_name, s.event_group, s.schema_version, s.description, s.is_active, s.created_at, FALSE
FROM seed s
WHERE NOT EXISTS (
    SELECT 1 FROM ref_operational_event_type e WHERE e.event_type_code = s.event_type_code
);

COMMIT;
