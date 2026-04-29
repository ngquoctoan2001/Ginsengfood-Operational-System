# 05 - Scope and Boundary

## 1. Nguyên Tắc Boundary

Operational Domain là source of truth cho dữ liệu vật lý và vận hành: source origin, raw material lot, production, batch, packaging/QR, QC/release, warehouse inventory, traceability, recall và integration events.

Operational Domain không sở hữu master data ngoài phạm vi vận hành như customer, order, payment, pricing, membership, commission, campaign, AI decisioning. Khi cần, Operational chỉ lưu reference key.

## 2. In-Scope

### 2.1 Master / Reference / Configuration

| Dữ liệu | Module owner | Ghi chú |
| --- | --- | --- |
| Source zone/source origin | M05 | Gồm evidence, verification, public source fields. |
| Supplier reference | M03/M06 | Dùng cho lot `PURCHASED`. |
| UOM/reference values | M03 | Dùng cho recipe, lot, ledger. |
| SKU baseline/proxy | M04 | Transitional cho G1 go-live; Catalog/Product là owner dài hạn nếu có. |
| Ingredient master/alias | M04 | `HRB_*`, `ING_*`, alias lịch sử nếu cần. |
| Recipe formula/version/line group | M04 | G1 baseline và future versioning. |
| Warehouse/location | M03/M11 | `RAW_MATERIAL`, `FINISHED_GOODS`. |
| Trade item/GTIN/packaging config | M10 | Tách khỏi SKU. |
| QC checklist/config | M09 | Checklist stage-specific. |
| MISA mapping/config | M14 | Mapping object/account/code, retry/reconcile. |
| Role/permission/screen registry | M02/M16 | RBAC, approval gate, UI action gate. |

### 2.2 Transaction / Workflow

| Dữ liệu | Module owner |
| --- | --- |
| Raw material intake/receipt/lot/QC | M06 |
| Production order/work order/process events/batch | M07 |
| Material issue/material receipt/variance | M08 |
| Packaging job/print job/QR registry | M10 |
| QC inspection/batch release | M09 |
| Warehouse receipt/inventory ledger/lot balance | M11 |
| Traceability links/public trace/internal trace | M12 |
| Incident/recall/hold/sale lock/recovery/disposition/CAPA | M13 |
| MISA sync event/log/reconcile | M14 |
| Audit/event/outbox/idempotency | M01 |

## 3. Out-Of-Scope

| Domain | Không sở hữu | Reference key nếu cần |
| --- | --- | --- |
| Catalog/Product | Product lifecycle, merchandising, category, long-term SKU ownership | `sku_id` |
| Commerce/Order | Cart, checkout, payment, order master | `order_id`, `order_item_id`, `shipment_id` |
| Customer/CRM | Customer profile, segmentation, membership | `customer_id` |
| Notification | Notification engine/template/channel delivery | `notification_job_id` |
| Accounting | Accounting ledger chính thức bên MISA | MISA mapping/sync IDs |
| HR/Payroll | Personnel master, payroll | `actor_user_id` trong audit |
| Analytics/AI | Recommendation, prediction, AI decisions | Chỉ nhận event/projection nếu owner yêu cầu sau |

## 4. Boundary Cứng Trong Operational

| Boundary | Rule |
| --- | --- |
| Source origin vs supplier | `SELF_GROWN` dùng source zone/source origin; `PURCHASED` dùng supplier. Không trộn field. |
| Raw material QC vs production | Lot chưa `QC_PASS` không được issue. |
| Production vs inventory | Production output chưa làm tăng inventory. |
| Material issue approval vs execution | Approval không decrement; execution mới decrement. |
| Material issue vs receipt | Receipt confirmation không decrement thêm. |
| Packaging/printing vs release | In/đóng gói không release batch. |
| QC pass vs release | `QC_PASS` không phải `RELEASED`. |
| Release vs warehouse receipt | Batch phải `RELEASED` trước khi nhập kho thành phẩm. |
| Inventory ledger vs balance | Ledger là source of truth; balance là projection. |
| Internal trace vs public trace | Internal đầy đủ; public bị giới hạn field. |
| Recall vs trace | Recall dùng trace/exposure snapshot, không tạo trace truth riêng. |
| MISA vs Operational | MISA là accounting system, không owner business truth nguồn. |

## 5. Public / Internal Data Policy

| Loại dữ liệu | Public trace | Internal trace |
| --- | --- | --- |
| SKU name, batch code, NSX/HSD | Có | Có |
| QR status valid | Có, chỉ nếu token hợp lệ | Có |
| Source zone public fields | Có nếu policy cho phép | Có |
| Supplier nội bộ | Không | Có theo quyền |
| Personnel/operator | Không | Có theo quyền/audit |
| Costing/pricing | Không | Chỉ domain có quyền, nếu tồn tại |
| QC defect/loss | Không | Có theo quyền QC/compliance |
| MISA data | Không | Có theo quyền integration/accounting |
| Recall public notice | Có nếu owner duyệt | Có |

## 6. Scope Theo 16 Module

| Module | In-scope chính | Out-of-scope chính |
| --- | --- | --- |
| M01 Foundation Core | Audit, event, idempotency, outbox, error/id conventions | Business workflow cụ thể |
| M02 Auth Permission | Role, permission, approval gate, screen action gate | HR/payroll |
| M03 Master Data | Shared reference/config | Long-term external catalog ownership |
| M04 SKU Ingredient Recipe | SKU baseline, ingredient, recipe G1/versioning | Product marketing/catalog full lifecycle |
| M05 Source Origin | Source zone/origin/evidence/verification | Supplier accounting |
| M06 Raw Material | Intake, lot, incoming QC | Production execution |
| M07 Production | PO, WO, process, batch | Warehouse inventory activation |
| M08 Material Issue Receipt | Issue/receipt/variance | Recipe governance |
| M09 QC Release | QC, disposition, release | Warehouse receipt |
| M10 Packaging Printing | Packaging, print, QR, GTIN handoff | Batch release |
| M11 Warehouse Inventory | Receipt, ledger, balance, allocation reference | Order master |
| M12 Traceability | Internal/public trace, genealogy | Recall decision workflow |
| M13 Recall | Incident, recall case, hold, sale lock, recovery, CAPA, CAPA evidence metadata | Notification delivery engine, binary evidence storage server operation |
| M14 MISA Integration | Mapping, sync, retry, reconcile | MISA master accounting ownership |
| M15 Reporting Dashboard | Operational dashboard/health/KPI | BI/AI analytics full platform |
| M16 Admin UI | Screens, menus, forms, tables, API client contract | Native app implementation if not approved |

## 7. Source Boundary

Tài liệu này không đối chiếu codebase. Route/API/table names trong spec là target contract từ nguồn được phép dùng và kiến thức thiết kế, không phải xác nhận implementation hiện tại.

Nếu sau này có phase đối chiếu code, phải tách riêng thành implementation audit và không sửa ngược source truth nếu code cũ mâu thuẫn với spec đã owner duyệt.

Các prompt trong `phase-project/` thuộc phase implementation/handoff nên có thể yêu cầu đọc current code để lập gap map và write scope. Điều đó không làm thay đổi boundary ở trên: code hiện tại không phải source-of-truth cho requirement.
