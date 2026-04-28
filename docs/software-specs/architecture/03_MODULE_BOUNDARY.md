# Module Boundary

> Mục đích: xác định boundary sở hữu dữ liệu và trách nhiệm giữa 16 module để tránh tạo duplicate business truth.

## 1. Boundary Matrix

| Module | Owns | May reference | Must not own |
| --- | --- | --- | --- |
| M01 Foundation Core | `audit_log`, `idempotency_registry`, `state_transition_log`, `outbox_event` | Any object type/id | Domain-specific business state |
| M02 Auth Permission | Users, roles, permissions, approval policy | Screen/action codes | Business transaction records |
| M03 Master Data | UOM, supplier, warehouse, reason/config | SKU/source ids | Transaction state |
| M04 SKU Ingredient Recipe | SKU transitional master, ingredients, recipe versions/lines | UOM, approval policy | Production order history |
| M05 Source Origin | Source zone/origin/evidence/verification | Supplier for display only if needed | Raw lot inventory |
| M06 Raw Material | Raw receipts, raw lots, raw lot readiness, QC inspection reference link | Ingredient, supplier, source origin, warehouse, M09 inspection reference | Production batch or QC inspection truth |
| M07 Production | PO, snapshot, work order, batch, process events | SKU/recipe snapshot, issue/receipt refs | Inventory ledger |
| M08 Material Issue Receipt | Material request, issue, issue line, receipt, variance | Raw lot in `READY_FOR_PRODUCTION` state only, PO snapshot, warehouse | Balance projection |
| M09 QC Release | QC inspection, disposition, batch release | Batch, packaging, hold | Warehouse receipt |
| M10 Packaging Printing | Trade item, GTIN, packaging unit, print, QR | SKU, batch | Public trace policy |
| M11 Warehouse Inventory | Warehouse receipt, inventory ledger, lot balance, allocation, adjustment | Batch release, recall hold | QC decision |
| M12 Traceability | Trace links, genealogy links, trace index/views, public trace policy | Source, lot, issue, batch, QR, warehouse, external shipment/customer refs | Recall disposition |
| M13 Recall | Incident, recall case states (`OPEN`, impact/hold/recovery/CAPA, `CLOSED`, `CLOSED_WITH_RESIDUAL_RISK`), exposure snapshot, hold, sale lock, recovery, CAPA | Trace result, inventory, external notification/customer refs | Trace source data |
| M14 MISA Integration | MISA mapping, sync event/log, reconcile | Outbox business events | Business transaction truth |
| M15 Reporting Dashboard | Metrics, alerts, health snapshots | Read models/events | Source of truth transaction tables |
| M16 Admin UI | Screen/action/menu/form/table configuration | Module APIs, permissions | Business state |

## 2. Cross-Domain Reference Policy

| External object | Stored as | Owner | Rule |
| --- | --- | --- | --- |
| Customer | `customer_id` | CRM/Commerce | No customer master copy in Operational. |
| Order | `order_id` | Commerce | Operational stores reference for trace/recall only. |
| Order item | `order_item_id` | Commerce | Used for exposure/allocation reference. |
| Shipment | `shipment_id` | Logistics/Commerce | Used for downstream trace/exposure. |
| Notification job | `notification_job_id` | Notification/CRM | Recall stores reference, not notification payload ownership. |
| MISA document | `misa_external_id` | MISA | Stored in sync log/mapping only. |

## 3. Boundary Invariants

| invariant | Enforcement |
| --- | --- |
| No direct MISA sync from M06/M07/M08/M09/M11/M13 | Outbox + M14 integration only. |
| No public trace from internal trace table directly | Use public projection/view/policy. |
| M12 public API must not expose raw internal trace entity | Public DTO/view is separate and field-whitelisted. |
| No recipe live lookup for historical PO print/trace | Use PO snapshot. |
| No inventory balance update without ledger | Balance derived/projected from ledger. |
| No recall trace truth duplication | Recall stores exposure snapshot, references trace source. |
| No SKU hard limit at 20 | 20 SKU seed baseline, schema/API allow future SKU. |
| M04 SKU ownership is transitional | Until Catalog domain is in scope; Operational retains immutable snapshots/references after ownership migration. |
