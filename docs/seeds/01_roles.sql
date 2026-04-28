-- Seed roles. Source: current local Operational DB after migration cleanup.
-- Idempotent: updates existing active role rows by code, inserts missing rows.

BEGIN;

WITH seed(code, name, description, is_active, created_at) AS (
    VALUES
    ('admin', 'Admin', 'Global administrator', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('system-admin', 'System Admin', 'System configuration and governance', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('foundation-manager', 'Foundation Manager', 'Metadata and foundational reference management', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('system-integration', 'System Integration', 'Integration references and external system mapping', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('traceability-manager', 'Traceability Manager', 'Traceability lifecycle and genealogy oversight', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('verifier', 'Verifier', 'Verification and review role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('raw-material-manager', 'RawMaterial Manager', 'Raw material setup and procurement operations', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('manufacturing-manager', 'Manufacturing Manager', 'Manufacturing setup and execution governance', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('production-manager', 'Production Manager', 'Production scheduling and execution', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('packaging-manager', 'Packaging Manager', 'Packaging and print operations', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('print-operator', 'Print Operator', 'Print line operation role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('qc-manager', 'QC Manager', 'Quality control governance', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('qc-inspector', 'QC Inspector', 'Quality inspection execution role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('qc-approver', 'QC Approver', 'QC final approval role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('warehouse-manager', 'Warehouse Manager', 'Warehouse stock and inventory management', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('inventory-officer', 'Inventory Officer', 'Inventory reconciliation and monitoring role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('recall-manager', 'Recall Manager', 'Recall and incident response management', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('quality-control-manager', 'Quality Control Manager', 'Cross-module quality governance role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('quality-lead', 'Quality Lead', 'Quality leadership and escalation role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('approval-authority', 'Approval Authority', 'Formal approval authority role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('sales-manager', 'Sales Manager', 'Sales coordination role in recall processes', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('customer-service', 'Customer Service', 'Customer communication role in recalls', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('warehouse', 'Warehouse', 'Warehouse operator role for recall operations', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('operations', 'Operations', 'Operations support role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('material-handler', 'Material Handler', 'Material handling role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('operator', 'Operator', 'Operational execution role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('supervisor', 'Supervisor', 'Supervisory role across production areas', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('auditor', 'Auditor', 'Read-only audit access', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz)
)
UPDATE roles r
SET name = s.name,
    description = s.description,
    is_active = s.is_active,
    updated_at = NOW()
FROM seed s
WHERE r.code = s.code
  AND r.is_deleted = FALSE;

WITH seed(code, name, description, is_active, created_at) AS (
    VALUES
    ('admin', 'Admin', 'Global administrator', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('system-admin', 'System Admin', 'System configuration and governance', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('foundation-manager', 'Foundation Manager', 'Metadata and foundational reference management', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('system-integration', 'System Integration', 'Integration references and external system mapping', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('traceability-manager', 'Traceability Manager', 'Traceability lifecycle and genealogy oversight', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('verifier', 'Verifier', 'Verification and review role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('raw-material-manager', 'RawMaterial Manager', 'Raw material setup and procurement operations', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('manufacturing-manager', 'Manufacturing Manager', 'Manufacturing setup and execution governance', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('production-manager', 'Production Manager', 'Production scheduling and execution', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('packaging-manager', 'Packaging Manager', 'Packaging and print operations', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('print-operator', 'Print Operator', 'Print line operation role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('qc-manager', 'QC Manager', 'Quality control governance', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('qc-inspector', 'QC Inspector', 'Quality inspection execution role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('qc-approver', 'QC Approver', 'QC final approval role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('warehouse-manager', 'Warehouse Manager', 'Warehouse stock and inventory management', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('inventory-officer', 'Inventory Officer', 'Inventory reconciliation and monitoring role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('recall-manager', 'Recall Manager', 'Recall and incident response management', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('quality-control-manager', 'Quality Control Manager', 'Cross-module quality governance role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('quality-lead', 'Quality Lead', 'Quality leadership and escalation role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('approval-authority', 'Approval Authority', 'Formal approval authority role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('sales-manager', 'Sales Manager', 'Sales coordination role in recall processes', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('customer-service', 'Customer Service', 'Customer communication role in recalls', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('warehouse', 'Warehouse', 'Warehouse operator role for recall operations', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('operations', 'Operations', 'Operations support role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('material-handler', 'Material Handler', 'Material handling role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('operator', 'Operator', 'Operational execution role', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('supervisor', 'Supervisor', 'Supervisory role across production areas', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz),
    ('auditor', 'Auditor', 'Read-only audit access', TRUE, '2026-04-11T14:54:24.543967+07:00'::timestamptz)
)
INSERT INTO roles (code, name, description, is_active, created_at, is_deleted)
SELECT s.code, s.name, s.description, s.is_active, s.created_at, FALSE
FROM seed s
WHERE NOT EXISTS (
    SELECT 1 FROM roles r WHERE r.code = s.code AND r.is_deleted = FALSE
);

COMMIT;
