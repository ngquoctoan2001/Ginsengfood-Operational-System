# 02 Menu Sidebar Structure

## 1. Mục tiêu

Tài liệu này định nghĩa menu/sidebar cho Admin Web, Shopfloor PWA, Integration Console và Public Trace. Menu là lớp điều hướng; không phải nguồn quyền cuối cùng. Backend vẫn phải kiểm tra permission/action theo `api/05_API_AUTH_PERMISSION_SPEC.md`.

## 2. Quy tắc hiển thị menu

| Rule | Mô tả |
|---|---|
| `menu.requiresPermission` | Menu chỉ hiển thị khi user có ít nhất một permission đọc dữ liệu trong nhóm. |
| `menu.requiresAction` | Action button trong menu/detail chỉ hiển thị khi user có action tương ứng. |
| `menu.badge` | Badge chỉ dùng cho số pending/failed/hold/retry, lấy từ API dashboard hoặc list summary. |
| `menu.hiddenWhenEmpty` | Không áp dụng cho module bắt buộc; chỉ áp dụng menu phụ tùy chọn khi owner chưa bật. |
| `menu.routePolicy` | Route UI phải map sang API route family chuẩn; không tạo route song song để né quyền hoặc state. |

## 3. Admin Sidebar

| order | menu_id | label | route | module | default roles | required_permission | badge source | ghi chú |
|---:|---|---|---|---|---|---|---|---|
| 10 | MENU_DASHBOARD | Dashboard | `/admin/dashboard` | M01, M15 | Admin, PM, QA Manager, Production Manager, Warehouse Manager | `report.read` | `/api/admin/dashboard/operational` | Màn hình đầu sau đăng nhập. |
| 20 | MENU_MASTER_DATA | Master Data | `/admin/master-data` | M03 | Admin, Master Data Steward | `master_data.read` | Không | Nhóm menu cha. |
| 21 | MENU_UOM | UOM | `/admin/master-data/uom` | M03 | Admin, Master Data Steward | `uom.read` | Không | Đơn vị tính. |
| 22 | MENU_SUPPLIER | Supplier | `/admin/master-data/suppliers` | M03 | Admin, Master Data Steward | `supplier.read` | Không | Nhà cung cấp nội bộ. |
| 23 | MENU_WAREHOUSE | Warehouse | `/admin/master-data/warehouses` | M03, M11 | Admin, Warehouse Manager | `warehouse.read` | Không | Kho/vị trí. |
| 30 | MENU_CATALOG | SKU / Ingredient / Recipe | `/admin/catalog` | M04 | Admin, R&D, QA Manager, Production Manager | `catalog.read` | `/api/admin/recipes?status=PENDING_APPROVAL` | Nhóm menu cha. |
| 31 | MENU_SKU | SKU Master | `/admin/catalog/skus` | M04 | Admin, R&D, Master Data Steward | `sku.read` | Không | Danh mục SKU baseline. |
| 32 | MENU_INGREDIENT | Ingredient Master | `/admin/catalog/ingredients` | M04 | Admin, R&D, QA Manager | `ingredient.read` | Không | Danh mục nguyên liệu. |
| 33 | MENU_RECIPE | Recipe Versions | `/admin/catalog/recipes` | M04 | Admin, R&D, QA Manager, Production Manager | `recipe.read` | pending approval | G1 baseline và version tương lai. |
| 40 | MENU_SOURCE_ORIGIN | Source Origin | `/admin/source-origin` | M05 | Admin, QA Manager, Source Manager | `source_origin.read` | pending verify | Source zone và source origin. |
| 41 | MENU_SOURCE_ZONE | Source Zones | `/admin/source-origin/zones` | M05 | Admin, Source Manager | `source_zone.read` | Không | Vùng nguồn. |
| 42 | MENU_SOURCE_ORIGIN_LIST | Source Origins | `/admin/source-origin/origins` | M05 | Admin, QA Manager, Source Manager | `source_origin.read` | pending verify | Hồ sơ nguồn. |
| 50 | MENU_RAW_MATERIAL | Raw Material | `/admin/raw-material` | M06, M09 | Warehouse Operator, QA Inspector, QA Manager | `raw_material.read` | hold/reject count | Tiếp nhận và QC đầu vào. |
| 51 | MENU_RAW_INTAKE | Raw Intakes | `/admin/raw-material/intakes` | M06 | Warehouse Operator, QA Inspector | `raw_intake.read` | pending receive | Phiếu tiếp nhận. |
| 52 | MENU_RAW_LOT | Raw Lots | `/admin/raw-material/lots` | M06 | Warehouse Operator, QA Inspector | `raw_lot.read` | hold count, waiting-ready count | Lot nguyên liệu; detail/action bar phải expose `raw_lot.mark_ready` khi lot đủ điều kiện. |
| 53 | MENU_INCOMING_QC | Incoming QC | `/admin/qc/incoming` | M09 | QA Inspector, QA Manager | `qc_inspection.read` | pending QC | QC đầu vào. |
| 54 | MENU_LOT_READINESS | Lot Readiness | `/admin/raw-material/lots/readiness` | M06, M09 | QA Manager, Warehouse Manager | `raw_lot.mark_ready` | waiting-ready count | Queue mark raw lot `READY_FOR_PRODUCTION`; dùng API `/api/admin/raw-material/lots/{lotId}/readiness`. |
| 60 | MENU_PRODUCTION | Production | `/admin/production` | M07 | Production Planner, Production Manager, QA Manager | `production_order.read` | open PO | Lệnh sản xuất. |
| 61 | MENU_PROD_ORDER | Production Orders | `/admin/production/orders` | M07 | Production Planner, Production Manager | `production_order.read` | open PO | Snapshot recipe. |
| 62 | MENU_WORK_ORDER | Work Orders | `/admin/production/work-orders` | M07 | Production Manager, Production Operator | `work_order.read` | in progress | Lệnh công việc. |
| 63 | MENU_PROCESS_EXEC | Process Execution | `/admin/production/process-execution` | M07 | Production Operator, QA Inspector | `batch_execution.read` | active batch | Theo dõi batch execution. |
| 64 | MENU_WORKFORCE_CHECK | Workforce Check-in/out | `/admin/production/workforce-check` | M07 | Production Operator, Production Manager | `workforce_check.read` | active check-in | Phiếu check-in/check-out nhân sự theo lệnh/mẻ/công đoạn. |
| 70 | MENU_MATERIAL | Material Issue / Receipt | `/admin/material` | M08 | Production Operator, Warehouse Operator, Warehouse Manager | `material_flow.read` | pending issue/receipt | Cấp phát và nhận vật tư. |
| 71 | MENU_MATERIAL_REQUEST | Material Requests | `/admin/material/requests` | M08 | Production Operator, Warehouse Operator | `material_request.read` | pending approve | Yêu cầu vật tư. |
| 72 | MENU_MATERIAL_ISSUE | Material Issues | `/admin/material/issues` | M08 | Warehouse Operator, Production Manager | `material_issue.read` | pending issue | Điểm trừ kho nguyên liệu thật. |
| 73 | MENU_MATERIAL_RECEIPT | Material Receipts | `/admin/material/receipts` | M08 | Production Operator, Warehouse Operator | `material_receipt.read` | pending confirm | Xác nhận nhận tại xưởng. |
| 80 | MENU_PACKAGING | Packaging & Printing | `/admin/packaging` | M10 | Packaging Operator, QA Manager, Admin | `packaging.read` | print failures | Đóng gói, QR, in. |
| 81 | MENU_TRADE_ITEM | Trade Items / GTIN | `/admin/packaging/trade-items` | M10 | Admin, Packaging Manager | `trade_item.read` | Không | GTIN/GS1 tách khỏi SKU. |
| 82 | MENU_PACKAGING_JOB | Packaging Jobs | `/admin/packaging/jobs` | M10 | Packaging Operator, Packaging Manager | `packaging_job.read` | queued jobs | Job đóng gói. |
| 83 | MENU_QR_REGISTRY | QR Registry | `/admin/printing/qr-registry` | M10, M12 | Packaging Operator, QA Manager | `qr.read` | void/reprint count | Vòng đời QR. |
| 84 | MENU_PRINT_QUEUE | Print Queue | `/admin/printing/queue` | M10 | Packaging Operator | `print_job.read` | failed print | Hàng đợi in. |
| 90 | MENU_QC_RELEASE | QC & Release | `/admin/release` | M09 | QA Inspector, QA Manager | `batch_release.read` | pending release | QC batch và release. |
| 91 | MENU_QC_INSPECTION | QC Inspections | `/admin/qc/inspections` | M09 | QA Inspector, QA Manager | `qc_inspection.read` | pending QC | Mọi QC inspection. |
| 92 | MENU_BATCH_RELEASE | Batch Release | `/admin/release/batches` | M09 | QA Manager | `batch_release.read` | pending release | Release riêng, không đồng nhất QC_PASS. |
| 100 | MENU_WAREHOUSE | Warehouse & Inventory | `/admin/warehouse` | M11 | Warehouse Operator, Warehouse Manager | `inventory.read` | pending receipt | Nhập kho và tồn. |
| 101 | MENU_WH_RECEIPT | Warehouse Receipts | `/admin/warehouse/receipts` | M11 | Warehouse Operator, Warehouse Manager | `warehouse_receipt.read` | pending receipt | Chỉ nhận batch RELEASED. |
| 102 | MENU_INVENTORY_LEDGER | Inventory Ledger | `/admin/inventory/ledger` | M11 | Warehouse Manager, Finance Viewer | `inventory_ledger.read` | Không | Ledger append-only. |
| 103 | MENU_LOT_BALANCE | Lot Balance | `/admin/inventory/lot-balance` | M11 | Warehouse Manager | `lot_balance.read` | low stock/hold | Projection tồn theo lot. |
| 104 | MENU_INVENTORY_ADJ | Inventory Adjustments | `/admin/inventory/adjustments` | M11 | Warehouse Manager, Admin | `inventory_adjustment.read` | pending approval | Điều chỉnh cần duyệt. |
| 110 | MENU_TRACEABILITY | Traceability | `/admin/traceability` | M12 | QA Manager, Trace Operator, Admin | `trace.read` | Không | Truy vết nội bộ. |
| 111 | MENU_TRACE_SEARCH | Trace Search | `/admin/traceability/search` | M12 | QA Manager, Trace Operator | `trace.read` | Không | Search batch/lot/QR. |
| 112 | MENU_GENEALOGY | Genealogy | `/admin/traceability/genealogy` | M12 | QA Manager, Trace Operator | `trace.genealogy.read` | Không | Material-to-batch-to-shipment. |
| 113 | MENU_PUBLIC_TRACE_PREVIEW | Public Trace Preview | `/admin/traceability/public-preview` | M12 | QA Manager, Admin | `public_trace.preview` | Không | Preview whitelist. |
| 120 | MENU_RECALL | Recall | `/admin/recall` | M13 | QA Manager, Recall Manager, Admin | `recall_case.read` | open recall | Thu hồi. |
| 121 | MENU_INCIDENT | Incidents | `/admin/recall/incidents` | M13 | QA Inspector, QA Manager | `incident.read` | open incident | Ghi nhận sự cố. |
| 122 | MENU_RECALL_CASE | Recall Cases | `/admin/recall/cases` | M13 | Recall Manager, QA Manager | `recall_case.read` | active case | Hồ sơ recall. |
| 123 | MENU_RECALL_IMPACT | Impact Analysis | `/admin/recall/impact-analysis` | M13 | Recall Manager, QA Manager | `recall_impact.read` | pending analysis | Exposure chain. |
| 124 | MENU_HOLD_SALE_LOCK | Hold / Sale Lock | `/admin/recall/holds` | M13, M11 | Recall Manager, Warehouse Manager | `recall_hold.read` | active hold | Hold/sale lock. |
| 125 | MENU_RECOVERY_CAPA | Recovery / CAPA | `/admin/recall/recovery-capa` | M13 | Recall Manager, QA Manager | `capa.read` | open CAPA | Recovery/disposition/CAPA. |
| 130 | MENU_INTEGRATIONS | Integrations | `/admin/integrations` | M14, M01 | Integration Operator, Admin | `integration.read` | failed sync | MISA và outbox. |
| 131 | MENU_MISA_SYNC | MISA Sync Jobs | `/admin/integrations/misa/sync-jobs` | M14 | Integration Operator, Admin | `misa_sync.read` | failed sync | Sync qua integration layer. |
| 132 | MENU_MISA_MAPPING | MISA Mapping | `/admin/integrations/misa/mapping` | M14 | Integration Operator, Admin | `misa_mapping.read` | unmapped count | Mapping bắt buộc. |
| 133 | MENU_MISA_RECONCILE | MISA Reconcile | `/admin/integrations/misa/reconcile` | M14 | Integration Operator, Finance Viewer | `misa_reconcile.read` | mismatch count | Đối soát. |
| 134 | MENU_EVENT_OUTBOX | Event Outbox | `/admin/integrations/outbox` | M01, M14 | Admin, Integration Operator | `event_outbox.read` | failed event | Retry event. |
| 140 | MENU_SYSTEM | Admin / System | `/admin/system` | M02, M16 | Admin | `system.read` | Không | Quản trị hệ thống. |
| 141 | MENU_USERS_ROLES | Users / Roles | `/admin/system/users-roles` | M02 | Admin | `user.read` | Không | RBAC. |
| 142 | MENU_SCREEN_REGISTRY | Screen Registry | `/admin/system/screens` | M16 | Admin | `screen_registry.read` | Không | Cấu hình menu/screen. |
| 143 | MENU_AUDIT_LOG | Audit Log | `/admin/system/audit-log` | M01 | Admin, QA Manager | `audit_log.read` | Không | Audit append-only. |
| 144 | MENU_ALERTS | Alerts | `/admin/system/alerts` | M15, M01 | Admin, PM | `alert.read` | open alert | Cảnh báo. |

## 4. Shopfloor PWA Navigation

| order | pwa_menu_id | label | route | default roles | API source | offline allowed | ghi chú |
|---:|---|---|---|---|---|---|---|
| 10 | PWA_TASKS | My Tasks | `/pwa/tasks` | Production Operator, Warehouse Operator, QA Inspector | `/api/admin/tasks/my` | Có, read cache | API cần được xác nhận nếu chưa có trong backend scope. |
| 20 | PWA_RAW_SCAN | Raw Lot Scan | `/pwa/raw-lot-scan` | Warehouse Operator, QA Inspector | `/api/admin/raw-material/lots/{id}` | Có, read cache | Scan lot nguyên liệu. |
| 25 | PWA_LOT_MARK_READY | Lot Mark Ready | `/pwa/lot-mark-ready` | QA Inspector, Warehouse Manager | `/api/admin/raw-material/lots/{lotId}/readiness` | Có, queue command | Chỉ queue khi có `raw_lot.mark_ready`; backend vẫn enforce `QC_PASS` + readiness policy. |
| 30 | PWA_MATERIAL_ISSUE | Material Issue | `/pwa/material-issue` | Warehouse Operator | `/api/admin/material-issues/{id}/issue` | Có, queue command | Bắt buộc idempotency; raw lot phải `READY_FOR_PRODUCTION`. |
| 40 | PWA_MATERIAL_RECEIPT | Material Receipt | `/pwa/material-receipt` | Production Operator | `/api/admin/material-receipts/{id}/confirm` | Có, queue command | Xác nhận nhận tại xưởng. |
| 50 | PWA_QC_CHECKLIST | QC Checklist | `/pwa/qc-checklist` | QA Inspector | `/api/admin/qc-inspections/{id}/result` | Có, queue command | QC_PASS/HOLD/REJECT. |
| 60 | PWA_WAREHOUSE_RECEIPT | Warehouse Receipt | `/pwa/warehouse-receipt` | Warehouse Operator | `/api/admin/warehouse-receipts/{id}/confirm` | Có, queue command | Chỉ batch RELEASED. |
| 70 | PWA_WORKFORCE_CHECK | Workforce Check-in/out | `/pwa/workforce-check` | Production Operator | `/api/admin/production/workforce/check-ins` | Có, queue command | Check-in/check-out theo lệnh/mẻ/công đoạn; cần idempotency và stale-state reload. |
| 80 | PWA_QR_SCAN | QR Scan | `/pwa/qr-scan` | Packaging Operator, QA Inspector | `/api/admin/qr-registry/{id}` | Có, read cache | Kiểm tra lifecycle QR. |

## 5. Public Trace Navigation

| route | label | access | API source | policy |
|---|---|---|---|---|
| `/trace/{qrCode}` | Public Trace | Anonymous/public | `/api/public/trace/{qrCode}` | Whitelist-only field policy; không gọi admin API; không hiển thị supplier/personnel/cost/QC defect/loss/MISA. |

## 6. Menu Permission Done Gate

- Mỗi menu có `required_permission` hoặc ghi rõ anonymous public.
- Button/action trong từng screen phải dùng permission/action chi tiết ở `ui/03_SCREEN_CATALOG.md`.
- Badge không được gọi endpoint transaction riêng lẻ từng row; dùng summary/list API có filter.
- Menu MISA không cho module nghiệp vụ sync trực tiếp; mọi thao tác đi qua integration layer.
