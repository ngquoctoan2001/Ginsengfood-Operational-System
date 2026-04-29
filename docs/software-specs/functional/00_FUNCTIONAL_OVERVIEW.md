# Functional Overview

> Mục đích: mô tả bức tranh chức năng của Operational Domain sau khi đã chuẩn hóa business requirements/rules. File này là cầu nối từ business sang use case, user story, acceptance criteria và dependency matrix.

## 1. Functional Scope

Hệ thống cần cung cấp các nhóm chức năng vận hành sau:

```text
Foundation/RBAC/Audit
→ Master Data / SKU / Ingredient / Recipe
→ Source Origin
→ Raw Material Intake / QC / Lot Readiness
→ Production Order / Work Order / Batch
→ Material Issue / Material Receipt
→ Production Process Execution
→ Packaging / Printing / QR
→ QC / Batch Release
→ Warehouse / Inventory Ledger
→ Traceability / Public Trace
→ Recall / Recovery / CAPA
→ MISA Integration
→ Reporting / Dashboard / Admin UI
```

## 2. Functional Principles

| principle_id | Principle | Functional impact |
| --- | --- | --- |
| FP-001 | Requirement traceable | Mỗi function phải map được về requirement/rule/test. |
| FP-002 | Role-gated action | UI action và API command đều cần permission. |
| FP-003 | State-machine driven | Workflow không dùng trạng thái tự do nếu object có lifecycle. |
| FP-004 | Snapshot over live lookup | Production/print/recall phải dùng snapshot khi cần bảo toàn lịch sử. |
| FP-005 | Append-only evidence | Audit, ledger, state history, trace/recall snapshot không update in-place. |
| FP-006 | Public/internal separation | Public trace chỉ dùng whitelist response. |
| FP-007 | Integration boundary | MISA/device/printer qua boundary layer, không direct DB/sync từ module nghiệp vụ. |

## 3. Actor Groups

| actor_group | Roles | Primary screens |
| --- | --- | --- |
| Admin/Governance | `R-ADMIN`, `R-OPS-MGR`, `R-AUDITOR` | Role/permission, audit, screen registry, override, dashboard |
| Source/Raw Warehouse | `R-WH-RAW`, `R-QC-RAW` | Source origin, raw intake, raw QC, raw lot, material issue |
| Production | `R-PROD-MGR`, `R-PROD-OP` | Production order, work order, process execution, material receipt |
| QC/Release | `R-QC-PROD`, `R-QA-REL` | QC inspection, batch release, hold |
| Packaging/Printing | `R-PACK-OP`, `R-PRINT-OP` | Packaging job, print queue, QR registry, reprint |
| Warehouse FG | `R-WH-FG` | Warehouse receipt, inventory ledger, lot balance |
| Trace/Recall | `R-TRACE`, `R-RECALL-MGR` | Trace search, genealogy, recall case |
| Integration/DevOps | `R-ACC-INT`, `R-DEVOPS` | MISA mapping/sync/reconcile, health, backup/retention |

## 4. Functional Modules

| module | Functional responsibility | Primary output |
| --- | --- | --- |
| M01 Foundation Core | Audit, idempotency, event/outbox, state transition, error convention | Reliable command/audit/event base |
| M02 Auth Permission | User, role, permission, approval policy | Role-gated actions |
| M03 Master Data | UOM, supplier, warehouse, config/reason | Reference data |
| M04 SKU Ingredient Recipe | SKU, ingredient, recipe, G1 baseline, versioning | Approved active recipe and snapshot source |
| M05 Source Origin | Source zone/origin/evidence/verification | Verified source for raw lots/public trace |
| M06 Raw Material | Intake, raw receipt, lot, QC result, mark-ready readiness | Raw lot with separated QC and `READY_FOR_PRODUCTION` status |
| M07 Production | PO, work order, batch, process events | Production genealogy root |
| M08 Material Issue Receipt | Request/issue/receipt/variance | Lot consumption and workshop receipt |
| M09 QC Release | QC inspection, disposition, batch release | Released batch decision |
| M10 Packaging Printing | Packaging, trade item/GTIN, print/QR/reprint | Printed/registered QR and packaging units |
| M11 Warehouse Inventory | Warehouse receipt, ledger, balance, adjustment | Inventory truth |
| M12 Traceability | Internal/public trace and genealogy | Trace result / public trace response |
| M13 Recall | Incident, recall, hold, sale lock, recovery, CAPA | Managed recall case |
| M14 MISA Integration | Mapping, sync, retry, reconcile | Accounting sync status |
| M15 Reporting Dashboard | Health, dashboard, alert | Operational visibility |
| M16 Admin UI | Menu, screens, forms, tables, PWA contract | Usable operational surfaces |

## 5. Functional Surfaces

| surface | Users | Functional notes |
| --- | --- | --- |
| Admin Web | Managers, QC, warehouse, integration, admin | Full workflow screens, approval, trace, recall, dashboard. |
| Shopfloor PWA | Operators, warehouse, packaging/printing | Scan, offline/idempotent submit, compact forms, state feedback. |
| Public Trace | Consumer/customer | Read-only QR trace, whitelist fields only. |
| Integration Console | Accounting integration/DevOps | Logical admin surface for MISA mapping, sync queue, retry, reconcile and health; it may be implemented as tabs inside Admin Web unless owner chooses a separate deployment surface. |

## 6. End-to-End Happy Path

| step | Function | Key validation |
| --- | --- | --- |
| 1 | Verify source origin | `SELF_GROWN` source origin = `VERIFIED`. |
| 2 | Intake raw material | Creates raw lot `PENDING_QC`. |
| 3 | Incoming QC | Lot records QC result `QC_PASS`, `QC_HOLD`, or `QC_REJECT`; `QC_PASS` is not yet material issue readiness. |
| 4 | Mark raw lot ready | `RAW_LOT_MARK_READY` transitions eligible lot to `READY_FOR_PRODUCTION`. |
| 5 | Prepare SKU/Recipe | 20 SKU + G1 + 4 groups + required ingredients. |
| 6 | Create production order | Snapshot active recipe, chỉ dùng operational baseline hợp lệ. |
| 7 | Approve material request | Lines must belong to snapshot. |
| 8 | Execute material issue | Uses only `READY_FOR_PRODUCTION` lots and decrements raw inventory once. |
| 9 | Confirm material receipt | Workshop receipt/variance, no second decrement. |
| 10 | Execute process chain | `PREPROCESSING -> FREEZING -> FREEZE_DRYING`. |
| 11 | Package/print/QR | Packaging/printing does not create inventory, QC pass or release; QR lifecycle, GTIN/barcode uniqueness and print audit apply. |
| 12 | QC and release | `QC_PASS` then separate release action. |
| 13 | Warehouse receipt | Batch must be `RELEASED`; ledger credit created. |
| 14 | Trace | Internal/public trace from source to finished goods. |
| 15 | Recall if needed | Impact snapshot, hold, sale lock, recovery, CAPA, clean CAPA evidence. |
| 16 | MISA sync | Integration layer maps/retries/reconciles. |


