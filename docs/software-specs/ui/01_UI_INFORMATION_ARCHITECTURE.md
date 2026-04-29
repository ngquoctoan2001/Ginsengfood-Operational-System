# 01 UI Information Architecture

## 1. Phạm vi và nguồn

Tài liệu này chuẩn hóa kiến trúc thông tin UI cho `docs/software-specs/` theo prompt gốc, `docs-software/`, `.tmp-docx-extract/`, kiến thức chuyên môn và phê duyệt owner.

Không dùng source code, `AGENTS.md` hoặc các pack `docs/ginsengfood_*` làm nguồn cho batch tài liệu này.

## 2. Nguyên tắc UI tổng thể

| Nhóm                  | Quy tắc                                                                                                                                                                                                                                                          |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Route family          | UI phải gọi API theo route family đã chuẩn hóa trong `api/02_API_ENDPOINT_CATALOG.md`. Không tạo màn hình gọi route song song như `/api/admin/raw-material/source-zones` hoặc `/api/admin/master-data/skus` nếu chưa có route impact analysis và owner approval. |
| Business logic        | UI chỉ điều phối nhập liệu, hiển thị, xác nhận thao tác và gọi API. Rule nghiệp vụ bắt buộc nằm ở backend/service/database.                                                                                                                                      |
| Permission            | Mọi menu, button, bulk action, command panel phải kiểm tra permission/action. Ẩn action không đủ quyền và backend vẫn phải chặn.                                                                                                                                 |
| State machine         | UI chỉ cho phép action hợp lệ theo state hiện tại. Nếu state stale, reload record trước khi submit command.                                                                                                                                                      |
| Idempotency           | Mọi command tạo/sửa trạng thái nghiệp vụ phải gửi `Idempotency-Key`. FE phải chống double-click và hiển thị trạng thái đang xử lý.                                                                                                                               |
| Public/internal split | Public trace dùng client/DTO riêng. Không dùng DTO admin cho public trace.                                                                                                                                                                                       |
| Traceability          | Các màn hình vận hành phải thể hiện link giữa `source_origin`, `raw_material_lot`, `production_order`, `material_issue`, `batch`, `qr_code`, `shipment`, `recall_case` khi có dữ liệu.                                                                           |
| G1 baseline           | UI recipe/production/material issue chỉ hiển thị công thức vận hành từ G1 trở đi. Không tạo lựa chọn vận hành cho phiên bản cũ không còn hiệu lực.                                                                                                               |
| Offline/PWA           | Shopfloor PWA nếu offline chỉ được queue command có idempotency key và phải sync lại theo thứ tự.                                                                                                                                                                |

## 3. UI Surfaces

| Surface             | Route prefix            | Người dùng chính                                                      | Mục đích                                                                                                                                                             | API client          |
| ------------------- | ----------------------- | --------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| Admin Web           | `/admin/*`              | Admin, PM, QA/QC, Warehouse, Production Manager, Integration Operator | Quản trị master data, kế hoạch, QC, release, inventory, trace, recall, MISA, audit                                                                                   | `adminClient`       |
| Shopfloor PWA       | `/pwa/*`                | Production Operator, Warehouse Operator, QC Inspector                 | Nhập liệu nhanh tại xưởng/kho, scan QR/lot, xác nhận issue/receipt/QC                                                                                                | `mobileClient`      |
| Public Trace        | `/trace/{qrCode}`       | Khách hàng/đối tác ngoài hệ thống                                     | Tra cứu thông tin public của QR/lô thành phẩm                                                                                                                        | `publicTraceClient` |
| Integration Console | `/admin/integrations/*` | Integration Operator, Admin                                           | Theo dõi MISA sync, mapping, retry, reconcile, error log                                                                                                             | `adminClient`       |
| Supplier Portal     | `/supplier/*`           | Supplier user (R-SUPPLIER)                                            | Đăng nhập NCC, khai báo intake, xác nhận/decline đơn từ company, đính kèm evidence, xem lịch sử/feedback. Scope cứng theo `supplier_id` qua `op_supplier_user_link`. | `supplierClient`    |

## 4. Top-Level Navigation

| Nhóm menu              | Module                                            | Route chính                                | Mục tiêu                                                                                         |
| ---------------------- | ------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| Dashboard              | Foundation/Core, Reporting                        | `/admin/dashboard`                         | Tổng quan vận hành, cảnh báo, KPI, việc cần xử lý.                                               |
| Master Data            | Master Data, SKU/Ingredient/Recipe, Source Origin | `/admin/master-data/*`                     | Quản lý dữ liệu nền trước khi phát sinh giao dịch.                                               |
| Raw Material           | Source Origin, Raw Material, QC                   | `/admin/raw-material/*`                    | Tiếp nhận nguyên liệu, xác thực nguồn, QC đầu vào, mark lot `READY_FOR_PRODUCTION`, quản lý lot. |
| Production             | Production, Material Issue/Receipt                | `/admin/production/*`                      | Lệnh sản xuất, snapshot recipe G1, cấp phát/nhận vật tư, theo dõi batch.                         |
| Packaging & Printing   | Packaging, QR Registry, Trade Item                | `/admin/packaging/*`, `/admin/printing/*`  | Đóng gói, danh tính thương phẩm, QR, in/reprint/void.                                            |
| QC & Release           | QC/Release                                        | `/admin/qc/*`, `/admin/release/*`          | Kiểm nghiệm, hold/reject/pass, release batch.                                                    |
| Warehouse & Inventory  | Warehouse/Inventory                               | `/admin/warehouse/*`, `/admin/inventory/*` | Nhập kho thành phẩm, ledger, lot balance, điều chỉnh.                                            |
| Traceability           | Traceability, Public Trace                        | `/admin/traceability/*`                    | Truy vết nội bộ, genealogy, kiểm tra public trace preview.                                       |
| Recall                 | Recall                                            | `/admin/recall/*`                          | Sự cố, phân tích ảnh hưởng, hold/sale lock, phục hồi, CAPA, evidence scan gate.                  |
| Integrations           | MISA Integration, Event/Outbox                    | `/admin/integrations/*`                    | Mapping, sync, retry, reconcile, outbox event.                                                   |
| Admin/System           | Auth/Permission, Audit, Admin UI                  | `/admin/system/*`                          | User/role, screen registry, audit log, cấu hình.                                                 |
| Supplier Master (M03A) | Supplier Management                               | `/admin/master-data/suppliers/*`           | Quản lý NCC, danh sách ingredient được phép, user NCC, suspend/reactivate.                       |
| Supplier Portal        | Supplier Collaboration (M06 + M03A)               | `/supplier/*`                              | NCC tự khai intake, xác nhận/decline, đính kèm evidence, theo dõi feedback.                      |

## 5. Information Hierarchy Theo Module

| Module                     | List screen                                                              | Detail/edit screen                                                                     | Command/action screen                                                                                                                                           | Public/PWA liên quan                                                            |
| -------------------------- | ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| M01 Foundation/Core        | Audit Log, Event Outbox, Dashboard                                       | Event Detail, Audit Detail                                                             | Retry outbox, acknowledge alert                                                                                                                                 | Không áp dụng                                                                   |
| M02 Auth/Permission        | Users/Roles                                                              | User Detail, Role Permission                                                           | Assign role, revoke session                                                                                                                                     | Không áp dụng                                                                   |
| M03 Master Data            | UOM, Supplier, Warehouse                                                 | Master Data Detail                                                                     | Activate/deactivate                                                                                                                                             | Không áp dụng                                                                   |
| M03A Supplier Management   | Supplier List, Allowed Ingredient List, Supplier User List               | Supplier Detail, Ingredient Allowlist Detail, Supplier User Detail                     | Create/Update supplier, Suspend/Reactivate, Add/Remove allowed ingredient, Create/Reset supplier user                                                           | Supplier Portal login (`/supplier/login`)                                       |
| M04 SKU/Ingredient/Recipe  | SKU, Ingredient, Recipe Versions                                         | Recipe Detail, Recipe Lines                                                            | Submit/approve/activate/retire recipe                                                                                                                           | Production order chọn active version                                            |
| M05 Source Origin          | Source Zones, Source Origins                                             | Source Origin Detail                                                                   | Upload evidence, verify/reject source origin                                                                                                                    | Raw intake chọn source origin verified                                          |
| M06 Raw Material           | Raw Intakes, Raw Lots, Lot Readiness Queue, Supplier Collaboration Queue | Intake Detail (2-axis), Lot Detail, Readiness Detail, Supplier Portal Intakes/Evidence | Receive, line accept/reject/return, close receipt, upload evidence, feedback, supplier confirm/decline, mark `READY_FOR_PRODUCTION`, hold, release hold, cancel | PWA scan raw lot; Supplier Portal `/supplier/intakes/*`, `/supplier/evidence/*` |
| M09 QC/Release             | Incoming QC, Batch QC, Release Queue                                     | QC Detail, Release Detail                                                              | QC_PASS, QC_HOLD, QC_REJECT, release batch                                                                                                                      | PWA QC checklist                                                                |
| M07 Production             | Production Orders, Work Orders, Workforce Check-in/out                   | PO Detail, Snapshot Detail, Workforce Attendance Detail                                | Plan, start, cancel, close, check-in, check-out                                                                                                                 | PWA work execution; PWA workforce check-in/out                                  |
| M08 Material Issue/Receipt | Material Requests, Issues, Receipts                                      | Issue/Receipt Detail                                                                   | Issue, receive, confirm variance                                                                                                                                | PWA issue/receipt; material issue chỉ chọn raw lot `READY_FOR_PRODUCTION`       |
| M10 Packaging/Printing     | Packaging Jobs, QR Registry, Print Queue                                 | QR Detail, Print Job Detail                                                            | Generate, queue, print, reprint, void                                                                                                                           | Public trace QR                                                                 |
| M11 Warehouse/Inventory    | Warehouse Receipts, Ledger, Lot Balance                                  | Receipt Detail, Ledger Detail                                                          | Receive released batch, adjust with approval                                                                                                                    | PWA warehouse scan                                                              |
| M12 Traceability           | Trace Search, Genealogy                                                  | Trace Detail                                                                           | Export internal trace                                                                                                                                           | Public Trace Preview                                                            |
| M13 Recall                 | Incidents, Recall Cases                                                  | Recall Detail, Impact Analysis, Recovery / CAPA                                        | Hold, sale lock, recover, attach CAPA evidence, close                                                                                                           | Không áp dụng                                                                   |
| M14 MISA Integration       | Sync Jobs, Mapping, Reconcile                                            | Sync Detail, Mapping Detail                                                            | Retry, reconcile, mark resolved                                                                                                                                 | Không áp dụng                                                                   |
| M15 Reporting/Dashboard    | Operational Dashboard, Alerts                                            | Report Detail                                                                          | Export report                                                                                                                                                   | Không áp dụng                                                                   |
| M16 Admin UI               | Menu/Screen Registry                                                     | Screen Detail                                                                          | Change visibility/order                                                                                                                                         | Không áp dụng                                                                   |

## 6. Page Layout Chuẩn

| Loại trang        | Thành phần bắt buộc                                                                                     | Ghi chú                                                                |
| ----------------- | ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| List page         | Title, status summary, filter bar, table, row action, bulk action nếu có, pagination, empty/error state | Filter phải map được sang `api/07_API_PAGINATION_FILTER_SORT_SPEC.md`. |
| Detail page       | Header identity, status badge, core fields, timeline/audit, related records, permitted commands         | Command phải kiểm tra state và permission.                             |
| Edit/Create form  | Field groups, validation, dirty state, submit/cancel, idempotency key nếu command                       | Form không được tự tính inventory/trace ngoài hiển thị preview.        |
| Approval queue    | Pending item list, compare snapshot, approve/reject comment, audit reason                               | Reject phải có reason.                                                 |
| PWA task          | Scan/input first, minimal fields, big action buttons, offline queue status                              | Không thay thế backend validation.                                     |
| Public trace page | QR identity, public SKU/batch/origin summary, public status, customer-safe message                      | Không có admin navigation, không expose internal fields.               |

## 7. Route Prefix Chuẩn

| Prefix                 | Ý nghĩa                               | Ví dụ                                  |
| ---------------------- | ------------------------------------- | -------------------------------------- |
| `/admin/dashboard`     | Dashboard vận hành                    | `/admin/dashboard`                     |
| `/admin/master-data`   | Master data nền                       | `/admin/master-data/uom`               |
| `/admin/catalog`       | SKU, ingredient, recipe               | `/admin/catalog/recipes`               |
| `/admin/source-origin` | Source zone/source origin             | `/admin/source-origin/origins`         |
| `/admin/raw-material`  | Nguyên liệu đầu vào và raw lot        | `/admin/raw-material/lots`             |
| `/admin/production`    | Production order/work order/execution | `/admin/production/orders`             |
| `/admin/material`      | Material request/issue/receipt        | `/admin/material/issues`               |
| `/admin/qc`            | QC inspection                         | `/admin/qc/inspections`                |
| `/admin/release`       | Batch release                         | `/admin/release/batches`               |
| `/admin/packaging`     | Packaging job/trade item              | `/admin/packaging/jobs`                |
| `/admin/printing`      | QR registry/print queue               | `/admin/printing/queue`                |
| `/admin/warehouse`     | Warehouse receipt                     | `/admin/warehouse/receipts`            |
| `/admin/inventory`     | Ledger/balance/adjustment             | `/admin/inventory/ledger`              |
| `/admin/traceability`  | Internal trace/genealogy              | `/admin/traceability/search`           |
| `/admin/recall`        | Recall lifecycle                      | `/admin/recall/cases`                  |
| `/admin/integrations`  | MISA/outbox/mapping/reconcile         | `/admin/integrations/misa/sync-jobs`   |
| `/admin/system`        | User/role/audit/screen registry       | `/admin/system/audit-log`              |
| `/pwa`                 | Shopfloor/mobile workflow             | `/pwa/material-issue`                  |
| `/trace`               | Public trace                          | `/trace/{qrCode}`                      |
| `/supplier`            | Supplier Portal (M06 + M03A)          | `/supplier/intakes`, `/supplier/login` |

## 8. Public Trace Field Policy

Public trace UI chỉ được dùng response từ `/api/public/trace/{qrCode}`. Không dùng admin trace API cho public page.

| Nhóm dữ liệu                                               | Public trace                      | Ghi chú                                                           |
| ---------------------------------------------------------- | --------------------------------- | ----------------------------------------------------------------- |
| SKU display name, batch public code, QR status public-safe | Được hiển thị                     | Chỉ hiển thị dữ liệu đã whitelist.                                |
| Origin summary đã được public hóa                          | Được hiển thị nếu owner phê duyệt | Không hiển thị supplier nội bộ hoặc vùng nhạy cảm nếu chưa duyệt. |
| Supplier internal data                                     | Không hiển thị                    | Forbidden.                                                        |
| Personnel/operator/QC inspector                            | Không hiển thị                    | Forbidden.                                                        |
| Costing, loss, variance                                    | Không hiển thị                    | Forbidden.                                                        |
| QC defect detail/internal result note                      | Không hiển thị                    | Forbidden.                                                        |
| MISA document/status/error                                 | Không hiển thị                    | Forbidden.                                                        |

## 9. Done Gate UI IA

- Mỗi screen trong `ui/03_SCREEN_CATALOG.md` phải có route, role, API source và permission.
- Mọi route UI admin phải map được sang một route family API trong `api/02_API_ENDPOINT_CATALOG.md`.
- Public trace phải dùng DTO/client riêng và whitelist-only field policy.
- Các command form phải có idempotency key nếu làm phát sinh transaction/state change.
