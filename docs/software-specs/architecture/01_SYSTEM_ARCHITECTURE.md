# System Architecture

> Mục đích: mô tả kiến trúc mục tiêu cho Operational Domain đủ để backend/DBA thiết kế schema, service, API, event và integration. Không đối chiếu source code hiện tại trong batch này.

## 1. Architecture Scope

Operational Domain là hệ lõi cho chuỗi:

```text
Source Origin -> Raw Material -> Incoming QC -> Lot Readiness
-> Production -> Material Issue/Receipt -> Packaging/Printing/QR -> QC/Release -> Warehouse/Inventory
-> Traceability -> Recall -> MISA Integration
```

Out-of-scope ownership:

- Customer, CRM, order, checkout, payment, promotion, membership, commission.
- Operational chỉ giữ reference keys như `customer_id`, `order_id`, `order_item_id`, `shipment_id`, `notification_job_id`.

## 2. Logical Layers

| Layer | Responsibility | Không được làm |
| --- | --- | --- |
| Admin Web / PWA / Public Trace UI | UI workflows, role-aware actions, offline/idempotent submit, public trace display | Không tự enforce business truth thay backend |
| API Boundary | Auth, permission, validation, idempotency, error contract, DTO/request-response | Không bypass domain service hoặc direct integration MISA |
| Application Services | Use case orchestration, transaction boundary, approval/action workflow | Không chứa duplicated database truth |
| Domain Services | Business rules, state machine, invariant validation | Không gọi external systems trực tiếp |
| Persistence | PostgreSQL schema, constraints, ledger, audit, snapshots, projections | Không update append-only records in-place |
| Event/Outbox | Integration event capture, retry/replay, compatibility | Không thay thế transaction state machine |
| Integration Layer | MISA, printer/device adapters, reconcile, callback handling | Không direct DB coupling từ external systems |

## 3. Core Architecture Decisions

| decision | Rule |
| --- | --- |
| Recipe | G1 là operational baseline; G0 research/baseline formula version must not be seeded or activated as operational baseline. |
| Snapshot | Production order, print payload, recall impact phải dùng snapshot để không rewrite history. |
| Ledger | Inventory ledger append-only; balance là projection. |
| QC/Release | `QC_PASS` khác `RELEASED`; warehouse receipt chỉ nhận batch released. |
| Integration | MISA sync qua integration layer, không module nào sync trực tiếp. |
| Public Trace | Public API dùng whitelist view/policy, không expose internal trace entity. |
| Eventing | Business transaction commit trước; outbox event dùng cho downstream sync/monitoring. |

## 4. Module Ownership

| Module | Owns data | Emits events | Consumes events |
| --- | --- | --- | --- |
| M01 Foundation Core | Audit, idempotency, event/outbox, state transition | Audit/state/outbox events | All module events |
| M02 Auth Permission | User/role/permission/approval policy | Permission/approval events | Admin config events |
| M03 Master Data | UOM, supplier, warehouse, config | Master data changed | None |
| M04 SKU Ingredient Recipe | SKU, ingredient, recipe, recipe lines | Recipe approved/activated | Master data changed |
| M05 Source Origin | Source zone/origin/evidence metadata/verification | Source origin verified/rejected | Master data changed |
| M06 Raw Material | Raw receipt, raw lot, raw lot readiness, reference to incoming QC inspection | Raw lot created, raw lot ready for production | Source origin verified, raw QC signed |
| M07 Production | PO, snapshot, work order, batch, process | PO opened, batch created/process done | Recipe active, material issue events |
| M08 Material Issue Receipt | Material request/issue/receipt/variance | Material issued/received | PO snapshot, `RAW_LOT_READY_FOR_PRODUCTION` |
| M09 QC Release | Incoming/finished QC inspection, disposition, release | QC signed, batch released, batch QC hold/reject | Batch/process/packaging events |
| M10 Packaging Printing | Trade item, packaging, print, QR | QR printed/voided/reprinted | Batch/process events |
| M11 Warehouse Inventory | Warehouse receipt, inventory ledger/balance | Ledger posted, warehouse receipt confirmed | Issue/release/recall hold |
| M12 Traceability | Trace links, genealogy, public trace policy/projection | Trace gap, public trace updated | Source/raw/issue/batch/QR/warehouse events |
| M13 Recall | Incident, recall, hold, exposure snapshot, recovery, CAPA, CAPA evidence metadata | Recall opened/hold/sale lock/recovery | Trace results, inventory state |
| M14 MISA Integration | Mapping, sync events/logs, reconcile | MISA sync status | Outbox events |
| M15 Reporting Dashboard | Metrics, alerts, health | Alert events | All health/event streams |
| M16 Admin UI | Screen/action/menu/form/table config | UI config changed | Permission/module metadata |

## 5. Transaction Boundary

| Workflow | Transaction boundary | Outbox timing |
| --- | --- | --- |
| Raw intake | Receipt + item + lot + audit in one transaction | After commit: `RAW_LOT_CREATED` |
| Raw QC sign | QC inspection + lot state + audit | After commit: `RAW_LOT_QC_SIGNED` |
| Lot readiness | Raw lot readiness state -> `READY_FOR_PRODUCTION` + audit/state transition | After commit: `RAW_LOT_READY_FOR_PRODUCTION` |
| PO create | PO + immutable snapshot + audit | After commit: `PRODUCTION_ORDER_OPENED` |
| Material issue | Issue + issue lines + ledger debit + usage links + audit | After commit: `MATERIAL_ISSUED` |
| Material receipt | Receipt + variance + audit | After commit: `MATERIAL_RECEIVED_BY_WORKSHOP` |
| Batch release | QC/release state + audit | After commit: `BATCH_RELEASED` |
| Warehouse receipt | Receipt + ledger credit + balance projection update + audit | After commit: `WAREHOUSE_RECEIPT_CONFIRMED` |
| Recall impact | Recall state + exposure snapshot + audit | After commit: `RECALL_IMPACT_SNAPSHOT_CREATED` |
| Recall close | Recall close state + close evidence; CAPA evidence must include at least 1 clean scanned metadata row when policy requires; `CLOSED_WITH_RESIDUAL_RISK` requires `residual_note` in same transaction | After commit: `RECALL_CLOSED` or `RECALL_CLOSED_WITH_RESIDUAL_RISK` |
| MISA sync | Sync log/status/reconcile in integration transaction | After commit: sync status event |

## 6. Security Boundary

- Admin/PWA endpoints require authenticated local account + RBAC.
- Public trace endpoint is anonymous/read-only and must not share DTO/entity with internal trace.
- Integration credentials are secret references; never returned by API.
- Permission check is backend-enforced; UI hiding is secondary.
- Export/action with sensitive data requires explicit permission and audit.

## 7. Implementation Handoff Notes

- Use PostgreSQL schema constraints for key invariants: unique business keys, check enums, FK relationships, research-baseline guard, active recipe uniqueness, idempotency uniqueness.
- Use app/domain service plus DB trigger/policy for append-only records where feasible.
- Database spec in `docs/software-specs/database/` is target schema design, not current implementation evidence.



