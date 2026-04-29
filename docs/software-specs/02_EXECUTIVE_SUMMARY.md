# 02 - Executive Summary

## 1. Tóm Tắt

Operational Domain của Ginsengfood quản lý chuỗi vận hành vật lý từ nguồn nguyên liệu đến thành phẩm, tồn kho, truy vết và thu hồi:

```text
Source Origin
→ Raw Material Intake
→ Raw Material QC / Lot Ready
→ Recipe Snapshot (PILOT G1 / FIXED G2)
→ Production Order
→ Material Issue Execution
→ Material Receipt Confirmation
→ Production / Batch
→ Packaging / Printing / QR
→ QC Inspection
→ Batch Release
→ Warehouse Receipt
→ Inventory Ledger / Lot Balance
→ Internal/Public Trace
→ Recall / Recovery
→ MISA Integration Layer
```

Nguồn chính: `SRC-FILE01`, `SRC-FILE03`, `SRC-FILE04-1`, `SRC-RECIPE-NEW`, `SRC-LOCK5`.

## 2. Mục Tiêu Kinh Doanh

| Mục tiêu                          | Ý nghĩa                                                                                                                                                                                              |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Truy xuất nguồn gốc 2 chiều       | Từ finished batch truy ngược về raw material lot/source origin và truy xuôi đến warehouse/shipment/customer exposure.                                                                                |
| Sản xuất theo công thức versioned | G1 (PILOT_PERCENT_BASED) là baseline pilot go-live; G2 (FIXED_QUANTITY_BATCH) là baseline production cố định mẻ và có thể coexist với G1; G3/G4... phải được approve/activate/snapshot/audit/retire. |
| Kiểm soát inventory thật          | Inventory chỉ tăng/giảm ở checkpoint đã khóa: raw receipt, material issue execution, warehouse receipt, adjustment/recall.                                                                           |
| Tách QC và release                | `QC_PASS` chỉ là kết quả kiểm; `RELEASED` là quyết định riêng để nhập kho/bán.                                                                                                                       |
| Public trace an toàn              | Người tiêu dùng thấy thông tin minh bạch, không thấy dữ liệu nội bộ.                                                                                                                                 |
| Recall sẵn sàng                   | Khi có sự cố, hệ thống xác định batch/lot/customer exposure, hold/sale lock, notification, recovery, disposition, CAPA và clean CAPA evidence.                                                       |
| Kế toán không điều khiển vận hành | MISA nhận dữ liệu từ integration layer, không là source of truth vận hành.                                                                                                                           |

## 3. Scope Nghiệp Vụ

In-scope:

- Source origin/source zone.
- Raw material intake, raw material lot, incoming QC.
- SKU/ingredient/recipe baseline G1 và versioning tương lai.
- Production order, work order, material issue, material receipt, production process, batch.
- Packaging, print job, QR registry, trade item/GTIN.
- QC inspection, batch release.
- Warehouse receipt, inventory ledger, lot balance, allocation reference.
- Traceability, public trace, recall.
- MISA integration layer, event/outbox, audit, role/permission, admin UI.

Out-of-scope:

- CRM/customer master.
- Order/cart/checkout/payment.
- Pricing/promotion/campaign.
- Membership/commission.
- AI recommendation/decisioning.
- HR/payroll/personnel master.

Operational chỉ giữ reference keys như `customer_id`, `order_id`, `order_item_id`, `shipment_id`, `notification_job_id` khi cần trace/recall/allocation.

## 4. Hard Locks Cần Owner/Dev Ghi Nhớ

| Nhóm              | Lock                                                                                                                                                                                                                                                 |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Recipe            | G1 PILOT_PERCENT_BASED là pilot operational baseline cho go-live; G2 FIXED_QUANTITY_BATCH là production baseline cố định mẻ 400 và có thể coexist với G1 cho cùng SKU; G0 cấm vận hành; hỗ trợ G3/G4... với approval/activate/snapshot/audit/retire. |
| Recipe line group | Chỉ dùng `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`.                                                                                                                                                             |
| SKU               | 20 SKU là baseline go-live; không hard-code thành giới hạn vĩnh viễn.                                                                                                                                                                                |
| Ingredient        | Bắt buộc có `ING_MI_CHINH`, `HRB_SAM_SAVIGIN`; `ING_THIT_HEO_NAC` đã được owner chốt là ingredient riêng theo lot.                                                                                                                                   |
| Raw material      | Lot có `procurement_type`: `SELF_GROWN` hoặc `PURCHASED`; `SELF_GROWN` cần source origin `VERIFIED`.                                                                                                                                                 |
| Inventory         | Material Issue Execution là điểm decrement raw inventory; Material Receipt Confirmation không decrement.                                                                                                                                             |
| QC/release        | `QC_PASS` không phải `RELEASED`; release là action/record riêng.                                                                                                                                                                                     |
| Warehouse         | Warehouse receipt chỉ nhận batch `RELEASED`.                                                                                                                                                                                                         |
| QR                | QR lifecycle phải đủ 6 state.                                                                                                                                                                                                                        |
| Public trace      | Không expose supplier nội bộ, nhân sự, costing, QC defect, loss, MISA data.                                                                                                                                                                          |
| MISA              | Module nghiệp vụ không gọi MISA trực tiếp.                                                                                                                                                                                                           |

## 5. Module Chuẩn

| Module | Tên                    | Vai trò                                                           |
| ------ | ---------------------- | ----------------------------------------------------------------- |
| M01    | Foundation Core        | Audit, idempotency, error, event, outbox, base governance.        |
| M02    | Auth Permission        | User, role, permission, approval gate, SSO mapping nếu có.        |
| M03    | Master Data            | UOM, warehouse, supplier, source reference, reason/config chung.  |
| M04    | SKU Ingredient Recipe  | SKU baseline, ingredient, recipe G1, versioning, snapshot source. |
| M05    | Source Origin          | Source zone, source origin, evidence, verification.               |
| M06    | Raw Material           | Intake, raw lot, incoming QC, raw ledger receipt.                 |
| M07    | Production             | Production order, work order, production process, batch.          |
| M08    | Material Issue Receipt | Material issue execution, receipt confirmation, variance.         |
| M09    | QC Release             | QC inspection, disposition, batch release.                        |
| M10    | Packaging Printing     | Packaging, print job, QR registry, trade item/GTIN handoff.       |
| M11    | Warehouse Inventory    | Warehouse receipt, ledger, lot balance, allocation reference.     |
| M12    | Traceability           | Internal trace, public trace, genealogy query.                    |
| M13    | Recall                 | Incident, hold, sale lock, recall, recovery, disposition, CAPA, CAPA evidence. |
| M14    | MISA Integration       | Mapping, sync event/log, retry, reconcile.                        |
| M15    | Reporting Dashboard    | Operational dashboard, alert, monitoring view.                    |
| M16    | Admin UI               | Menu, screen registry, form/table/action UI, API client contract. |

## 6. Phase Plan

Kế hoạch triển khai dùng CODE01-CODE17 từ `SRC-FILE04-1`, nhưng được map lại vào 16 module chuẩn ở [06_MODULE_MAP.md](06_MODULE_MAP.md) và chi tiết ở [07_PHASE_PLAN.md](07_PHASE_PLAN.md).

| CODE   | Mục tiêu                                                                          |
| ------ | --------------------------------------------------------------------------------- |
| CODE01 | Foundation + Source Origin                                                        |
| CODE02 | Raw Material Intake + Lot + Incoming QC                                           |
| CODE03 | Manufacturing Execution + Batch + Genealogy Foundation                            |
| CODE04 | Packaging & Printing Control                                                      |
| CODE05 | QC & Batch Release                                                                |
| CODE06 | Warehouse Receipt & Inventory Control                                             |
| CODE07 | Traceability & Batch Genealogy Engine                                             |
| CODE08 | Recall & Product Recovery Engine                                                  |
| CODE09 | Role-Based Admin UI Engine + Screen Registry + Permission                         |
| CODE10 | API Contract + Query/Command Boundary + Error/Permission/Audit Middleware         |
| CODE11 | Mobile/Internal App Contract + Offline/Idempotency + Device Header Standard       |
| CODE12 | Device/Printer/IoT Integration + Heartbeat + Error/Incident Bridge                |
| CODE13 | Event Schema Registry + Outbox/Event Bus Adapter + Compatibility Lock             |
| CODE14 | Monitoring/Alert Rule Engine + Incident Response + Dashboard Health               |
| CODE15 | Manual Override + Break-Glass + Human-in-the-Loop Governance                      |
| CODE16 | Data Retention + Archival + Restore / Archive Search Boundary                     |
| CODE17 | Final Close-Out Gate + Integration Smoke + Release Readiness + Handover Checklist |

## 7. Owner Decisions Còn Mở

| OD    | Nội dung                                                  | Tác động                                              |
| ----- | --------------------------------------------------------- | ----------------------------------------------------- |
| OD-11 | Trace query technical SLA                                 | Chặn index/cache/SLO final cho trace.                 |
| OD-12 | Backup/DR RPO/RTO                                         | Chặn CODE16 release hardening.                        |
| OD-13 | Audit log retention duration                              | Chặn retention/archive/storage sizing.                |
| OD-14 | Public trace multi-language policy                        | Ảnh hưởng public trace UI/API.                        |
| OD-17 | Production printer model + driver                         | Ảnh hưởng CODE12 device/printer adapter.              |
| OD-20 | MISA AMIS tenant/credential/endpoint thật cho production  | Ảnh hưởng CODE13/CODE17 real sync enablement.         |
| OD-21 | PWA task taxonomy và endpoint inbox `/api/admin/tasks/my` | Ảnh hưởng CODE11 shopfloor PWA task routing.          |
| OD-22 | UI mutation route taxonomy phụ                            | Ảnh hưởng CODE09/CODE10/CODE11 route contract freeze. |

Chi tiết conflict/decision: [09_CONFLICT_AND_OWNER_DECISIONS.md](09_CONFLICT_AND_OWNER_DECISIONS.md).
