# Use Case Catalog

> Mục đích: catalog use case đủ để BA/QA/Dev triển khai test và UI/API contract. Mỗi use case có actor, precondition, main flow, alternate/error flow, postcondition và acceptance anchor.

## Mục lục

- [UC-01 - Quản lý và xác minh Source Origin](#uc-01---quản-lý-và-xác-minh-source-origin)
- [UC-02 - Nhập nguyên liệu tự trồng hoặc mua ngoài](#uc-02---nhập-nguyên-liệu-tự-trồng-hoặc-mua-ngoài)
- [UC-03 - QC nguyên liệu đầu vào](#uc-03---qc-nguyên-liệu-đầu-vào)
- [UC-03A - Mark-ready raw lot cho sản xuất](#uc-03a---mark-ready-raw-lot-cho-sản-xuất)
- [UC-04 - Quản lý SKU, Ingredient và Recipe G1](#uc-04---quản-lý-sku-ingredient-và-recipe-g1)
- [UC-05 - Mở Production Order và snapshot công thức](#uc-05---mở-production-order-và-snapshot-công-thức)
- [UC-06 - Duyệt material request](#uc-06---duyệt-material-request)
- [UC-07 - Thực hiện Material Issue](#uc-07---thực-hiện-material-issue)
- [UC-08 - Xác nhận xưởng nhận nguyên liệu](#uc-08---xác-nhận-xưởng-nhận-nguyên-liệu)
- [UC-09 - Thực hiện chuỗi sản xuất](#uc-09---thực-hiện-chuỗi-sản-xuất)
- [UC-10 - Đóng gói, in và QR lifecycle](#uc-10---đóng-gói-in-và-qr-lifecycle)
- [UC-11 - QC thành phẩm và Batch Release](#uc-11---qc-thành-phẩm-và-batch-release)
- [UC-12 - Nhập kho thành phẩm và inventory ledger](#uc-12---nhập-kho-thành-phẩm-và-inventory-ledger)
- [UC-13 - Internal trace và public trace](#uc-13---internal-trace-và-public-trace)
- [UC-14 - Recall và recovery](#uc-14---recall-và-recovery)
- [UC-15 - MISA sync qua integration layer](#uc-15---misa-sync-qua-integration-layer)
- [UC-16 - Dashboard, alert và exception handling](#uc-16---dashboard-alert-và-exception-handling)
- [UC-17 - Admin UI, RBAC và PWA offline submit](#uc-17---admin-ui-rbac-và-pwa-offline-submit)
- [UC-18 - Correction, rollback, hold/halt/cancel/reject](#uc-18---correction-rollback-holdhaltcancelreject)

## UC-01 - Quản lý và xác minh Source Origin

| Field | Nội dung |
| --- | --- |
| Actor | `R-WH-RAW`, `R-QA-REL`, `R-OPS-MGR` |
| Module | M05 Source Origin |
| Precondition | Source zone tồn tại hoặc được tạo mới; evidence được chuẩn bị nếu cần verify. |
| Main flow | 1. Tạo source zone với `source_zone_name`, `province`, `ward`, `address_detail`. 2. Tạo source origin gắn source zone. 3. Upload/nhập evidence. 4. Submit verification. 5. `R-QA-REL` hoặc `R-OPS-MGR` approve thành `VERIFIED`. |
| Alternate/error flow | Evidence thiếu/sai -> `REJECTED`; source origin chưa `VERIFIED` không cho lot `SELF_GROWN` intake. |
| Postcondition | Source origin `VERIFIED` có thể dùng cho raw material lot `SELF_GROWN`. |
| API/UI | `/api/admin/source-zones/*`, `/api/admin/source-origins/*`; Source Zone, Source Origin Verification |
| Acceptance | AC-SRC-001, AC-SRC-002 |

## UC-02 - Nhập nguyên liệu tự trồng hoặc mua ngoài

| Field | Nội dung |
| --- | --- |
| Actor | `R-WH-RAW` |
| Module | M06 Raw Material |
| Precondition | Ingredient active; supplier active nếu `PURCHASED`; source origin `VERIFIED` nếu `SELF_GROWN`. |
| Main flow | 1. Mở Raw Material Intake. 2. Chọn `procurement_type`. 3. Nhập ingredient, quantity, UOM, date. 4. Nếu `SELF_GROWN`, chọn source zone/origin. 5. Nếu `PURCHASED`, chọn supplier. 6. Submit. |
| Alternate/error flow | `SELF_GROWN` thiếu/không verified source origin -> reject; `PURCHASED` thiếu supplier -> reject; quantity <= 0 -> reject. |
| Postcondition | Tạo receipt, receipt item, raw lot `PENDING_QC`, audit. |
| API/UI | `/api/admin/raw-material/intakes`; Raw Material Intake |
| Acceptance | AC-RM-001, AC-RM-002, AC-RM-003 |

## UC-03 - QC nguyên liệu đầu vào

| Field | Nội dung |
| --- | --- |
| Actor | `R-QC-RAW` |
| Module | M06 Raw Material, M09 QC Release |
| Precondition | Raw lot ở `PENDING_QC`. |
| Main flow | 1. Mở Incoming QC. 2. Nhập checklist/kết quả. 3. Ký `QC_PASS`, `QC_HOLD` hoặc `QC_REJECT`. 4. Hệ thống ghi audit và state transition. |
| Alternate/error flow | Hold/reject phải có reason; signed QC không sửa trực tiếp, correction là record mới. |
| Postcondition | Lot có QC result `QC_PASS` đủ điều kiện đi tiếp sang mark-ready; lot hold/reject bị block và không được cấp phát. |
| API/UI | `/api/admin/raw-material/qc/*`; Incoming QC |
| Acceptance | AC-QC-001, AC-QC-002 |

## UC-03A - Mark-ready raw lot cho sản xuất

| Field | Nội dung |
| --- | --- |
| Actor | `R-QA-REL`, `R-OPS-MGR` |
| Module | M06 Raw Material, M08 Material Issue Receipt |
| Precondition | Raw lot có QC result `QC_PASS`, source hợp lệ, balance available, không active hold/reject/quarantine. |
| Main flow | 1. Mở Raw Lot Detail. 2. Hệ thống hiển thị readiness blockers nếu có. 3. Actor chọn `RAW_LOT_MARK_READY` và nhập reason/evidence nếu cần. 4. Hệ thống chuyển lot sang `READY_FOR_PRODUCTION`. 5. Ghi state transition và audit. |
| Alternate/error flow | Lot chỉ `PENDING_QC`, `QC_HOLD`, `QC_REJECT`, `ON_HOLD`, thiếu balance hoặc thiếu quyền -> reject; material issue với lot `QC_PASS` nhưng chưa `READY_FOR_PRODUCTION` trả `LOT_NOT_READY_FOR_PRODUCTION`. |
| Postcondition | Raw lot `READY_FOR_PRODUCTION` mới được dùng cho material issue allocation. |
| API/UI | `GET /api/admin/raw-material/lots/{id}/readiness`, `POST /api/admin/raw-material/lots/{id}/mark-ready`; Raw Lot Detail |
| Acceptance | AC-RM-004, AC-MI-001 |

## UC-04 - Quản lý SKU, Ingredient và Recipe G1

| Field | Nội dung |
| --- | --- |
| Actor | `R-ADMIN`, data steward, `R-QA-REL`, `R-OPS-MGR` |
| Module | M04 SKU Ingredient Recipe |
| Precondition | Master data UOM và ingredient groups sẵn sàng. |
| Main flow | 1. Seed/create 20 SKU baseline. 2. Seed/create ingredient master có required ingredients. 3. Tạo recipe G1 cho SKU với 4 group. 4. Submit approval. 5. Approve và activate G1. |
| Alternate/error flow | Có research baseline token trong operational data -> reject; thiếu group/ingredient bắt buộc -> reject; active version overlap -> reject. |
| Postcondition | SKU có active approved recipe G1, sẵn sàng production snapshot. |
| API/UI | `/api/admin/skus/*`, `/ingredients/*`, `/recipes/*`; SKU, Ingredient, Recipe Version |
| Acceptance | AC-REC-001..AC-REC-005 |

## UC-05 - Mở Production Order và snapshot công thức

| Field | Nội dung |
| --- | --- |
| Actor | `R-PROD-MGR` |
| Module | M07 Production, M04 SKU Ingredient Recipe |
| Precondition | SKU active; active approved recipe G1; raw material readiness có thể kiểm sau. |
| Main flow | 1. Chọn SKU, batch count/date. 2. Hệ thống resolve active recipe. 3. Snapshot full recipe lines vào PO. 4. Approve/open PO. 5. In production order từ snapshot. |
| Alternate/error flow | Missing active formula, formula research baseline token, missing line/group -> reject. |
| Postcondition | PO có immutable snapshot và có thể tạo material request/work order. |
| API/UI | `/api/admin/production/orders`; Production Order Create/Print |
| Acceptance | AC-PO-001, AC-PO-002 |

## UC-06 - Duyệt material request

| Field | Nội dung |
| --- | --- |
| Actor | `R-PROD-OP`, `R-PROD-MGR` |
| Module | M08 Material Issue Receipt |
| Precondition | PO open/approved có snapshot. |
| Main flow | 1. Operator tạo material request từ snapshot. 2. Production manager review. 3. Approve hoặc reject. |
| Alternate/error flow | Line ngoài snapshot -> reject hoặc exception approval; reject phải có reason. |
| Postcondition | Approved request sẵn sàng material issue execution. |
| API/UI | `/api/admin/production/material-requests/*`; Material Request/Approval |
| Acceptance | AC-MI-002, AC-APP-001 |

## UC-07 - Thực hiện Material Issue

| Field | Nội dung |
| --- | --- |
| Actor | `R-WH-RAW` |
| Module | M08 Material Issue Receipt, M11 Warehouse Inventory |
| Precondition | Material request approved; raw lot `READY_FOR_PRODUCTION`, balance đủ, không hold/reject/quarantine. |
| Main flow | 1. Mở issue execution. 2. Scan/chọn raw lot cho từng snapshot line. 3. Allocate raw lots theo từng snapshot line. 4. Confirm issue. 5. Hệ thống tạo issue, issue lines, batch material usage, ledger decrement. |
| Alternate/error flow | Lot `QC_PASS` nhưng chưa `READY_FOR_PRODUCTION`, lot not ready, thiếu scan bắt buộc hoặc không đủ balance -> reject; duplicate submit -> idempotent result. |
| Postcondition | Raw inventory giảm đúng một lần; genealogy link raw lot -> batch được ghi. |
| API/UI | `/api/admin/production/material-issues/{id}/execute`; Material Issue Execution |
| Acceptance | AC-MI-001, AC-MI-003, AC-SCAN-001 |

## UC-08 - Xác nhận xưởng nhận nguyên liệu

| Field | Nội dung |
| --- | --- |
| Actor | `R-PROD-OP` |
| Module | M08 Material Issue Receipt |
| Precondition | Material issue executed. |
| Main flow | 1. Operator mở receipt confirmation. 2. Xác nhận received quantity. 3. Ghi variance nếu có. 4. Submit confirmation. |
| Alternate/error flow | Receipt > issued quantity hoặc variance lớn -> review/exception; không decrement inventory lần hai. |
| Postcondition | Workshop receipt record và variance audit được ghi. |
| API/UI | `/api/admin/production/material-receipts`; Material Receipt Confirmation |
| Acceptance | AC-MR-001, AC-MR-002 |

## UC-09 - Thực hiện chuỗi sản xuất

| Field | Nội dung |
| --- | --- |
| Actor | `R-PROD-OP`, `R-QC-PROD` |
| Module | M07 Production |
| Precondition | Work order/batch tồn tại; material issue đã execute và material receipt đã confirm nếu policy yêu cầu receipt trước khi start `PREPROCESSING`. |
| Main flow | 1. Start `PREPROCESSING`. 2. Complete `PREPROCESSING`. 3. Start/complete `FREEZING`. 4. Start/complete `FREEZE_DRYING`. 5. Hệ thống cập nhật batch/process state. |
| Alternate/error flow | Bỏ qua `FREEZING` -> reject; halt cần reason/audit; correction không sửa event gốc. |
| Postcondition | Batch đủ điều kiện mở packaging/QC sau sấy. |
| API/UI | `/api/admin/production/process-events`; Process Execution |
| Acceptance | AC-PROC-001, AC-EXC-002 |

## UC-10 - Đóng gói, in và QR lifecycle

| Field | Nội dung |
| --- | --- |
| Actor | `R-PACK-OP`, `R-PRINT-OP` |
| Module | M10 Packaging Printing |
| Precondition | Batch/process đủ điều kiện packaging; trade item/GTIN configured hoặc fixture dev được đánh dấu. |
| Main flow | 1. Tạo packaging job BOX/CARTON. 2. Validate trade item/GTIN unique theo package level. 3. Generate QR. 4. Queue print. 5. Print success -> QR `PRINTED`. 6. Nếu reprint, request reason và link original. |
| Alternate/error flow | Barcode/GTIN conflict -> `PRINT_TRADE_ITEM_BARCODE_CONFLICT`; print fail -> QR/print job `FAILED`; void -> public trace invalid; reprint thiếu reason -> reject. |
| Postcondition | Packaging unit và QR/print history đầy đủ. |
| API/UI | `/api/admin/packaging/*`, `/printing/*`, `/qr/*`, `/trade-items/*`; Packaging, Print Queue, QR Registry |
| Acceptance | AC-PKG-001, AC-QR-001, AC-QR-002, AC-PRINT-001, AC-GTIN-001 |

## UC-11 - QC thành phẩm và Batch Release

| Field | Nội dung |
| --- | --- |
| Actor | `R-QC-PROD`, `R-QA-REL` |
| Module | M09 QC Release |
| Precondition | Batch/packaging đủ điều kiện QC/release. |
| Main flow | 1. QC nhập inspection. 2. Ký `QC_PASS`/`QC_HOLD`/`QC_REJECT`. 3. Nếu pass, QA mở release. 4. Kiểm no active hold/prerequisite complete. 5. Approve release. |
| Alternate/error flow | QC pass chưa release -> không nhập kho; active hold -> release bị block. |
| Postcondition | Batch có release record `RELEASED`. |
| API/UI | `/api/admin/qc/inspections/*`, `/api/admin/qc/releases/*`; QC Inspection, Batch Release |
| Acceptance | AC-REL-001, AC-REL-002 |

## UC-12 - Nhập kho thành phẩm và inventory ledger

| Field | Nội dung |
| --- | --- |
| Actor | `R-WH-FG` |
| Module | M11 Warehouse Inventory |
| Precondition | Batch `RELEASED`. |
| Main flow | 1. Mở warehouse receipt. 2. Scan batch/packaging unit nếu policy yêu cầu. 3. Chọn released batch/packaging unit/quantity. 4. Confirm receipt. 5. Hệ thống tạo ledger credit và balance projection. |
| Alternate/error flow | Batch chỉ `QC_PASS`, thiếu scan bắt buộc hoặc active hold -> reject; correction dùng adjustment/reversal. |
| Postcondition | Finished goods inventory tăng qua ledger append-only. |
| API/UI | `/api/admin/warehouse/receipts`, `/api/admin/inventory/*`; Warehouse Receipt, Inventory Ledger |
| Acceptance | AC-WH-001, AC-INV-001, AC-SCAN-001 |

## UC-13 - Internal trace và public trace

| Field | Nội dung |
| --- | --- |
| Actor | `R-TRACE`, public user |
| Module | M12 Traceability |
| Precondition | Có trace links từ source/raw lot/material issue/batch/QR/warehouse. |
| Main flow | 1. Internal user search by QR/batch/lot. 2. Hệ thống trả genealogy chain. 3. Public user scan QR valid. 4. Public API trả whitelist fields. |
| Alternate/error flow | Missing link -> trace gap warning; QR `VOID`/`FAILED` -> public invalid; forbidden fields không được trả. |
| Postcondition | Internal trace đủ chain; public trace an toàn. |
| API/UI | `/api/admin/trace/*`, `/api/public/trace/{qrCode}`; Trace Search, Public Trace |
| Acceptance | AC-TRACE-001, AC-PTRACE-001, AC-PTRACE-002 |

## UC-14 - Recall và recovery

| Field | Nội dung |
| --- | --- |
| Actor | `R-RECALL-MGR`, `R-OPS-MGR` |
| Module | M13 Recall |
| Precondition | Incident hoặc risk report; trace search có thể xác định affected batch/lot. |
| Main flow | 1. Open incident/recall case. 2. Run impact analysis và lưu snapshot. 3. Apply hold/sale lock. 4. Ghi notification reference. 5. Theo dõi recovery. 6. Ghi disposition/CAPA. 7. Close thường khi đủ điều kiện hoặc close với residual risk khi có residual note/approval. |
| Alternate/error flow | Re-run impact tạo snapshot mới; close khi recovery open -> reject; close residual risk thiếu `residual_note` -> `RECALL_RESIDUAL_RISK_NOTE_REQUIRED`; cancel chỉ khi chưa có downstream action hoặc theo policy. |
| Postcondition | Recall có timeline/audit, exposure snapshot, recovery/disposition/CAPA và trạng thái `CLOSED` hoặc `CLOSED_WITH_RESIDUAL_RISK`. |
| API/UI | `/api/admin/incidents/*`, `/api/admin/recall/*`; Recall Case Management |
| Acceptance | AC-RECALL-001, AC-RECALL-002, AC-RECALL-003, AC-RECALL-004 |

## UC-15 - MISA sync qua integration layer

| Field | Nội dung |
| --- | --- |
| Actor | `R-ACC-INT`, system |
| Module | M14 MISA Integration |
| Precondition | Business event/outbox exists; accounting document generated/posted where required; mapping configured hoặc cần review. |
| Main flow | 1. Accounting document chuyển `GENERATED -> POSTED -> SYNC_PENDING` khi nghiệp vụ đủ điều kiện. 2. Integration layer nhận event. 3. Resolve mapping. 4. Sync MISA. 5. Ghi sync log/status. 6. Reconcile định kỳ/manual. |
| Alternate/error flow | Missing mapping -> failed/pending review; retry theo policy; manual retry sau khi sửa mapping. |
| Postcondition | MISA sync status có audit; nghiệp vụ không gọi MISA trực tiếp. |
| API/UI | `/api/admin/integrations/misa/*`; MISA Sync Monitor/Reconcile |
| Acceptance | AC-MISA-001, AC-MISA-002, AC-MISA-003 |

## UC-16 - Dashboard, alert và exception handling

| Field | Nội dung |
| --- | --- |
| Actor | `R-OPS-MGR`, `R-DEVOPS` |
| Module | M15 Reporting Dashboard, M01 Foundation Core |
| Precondition | Event/health/alert rules configured. |
| Main flow | 1. Dashboard hiển thị health raw QC, production, release, warehouse, trace, recall, MISA, printer. 2. Alert rule phát cảnh báo khi fail/threshold. 3. Operator review và xử lý. |
| Alternate/error flow | Alert không được mutate workflow trực tiếp. |
| Postcondition | Manager có visibility và audit/incident nếu xử lý. |
| API/UI | `/api/admin/dashboard/*`, `/api/admin/alerts/*`, `/health`; Operations Dashboard |
| Acceptance | AC-DASH-001, AC-ALERT-001 |

Note: observability/retention tooling chưa chốt là owner decision/NFR dependency, không phải alternate flow của UC này.

## UC-17 - Admin UI, RBAC và PWA offline submit

| Field | Nội dung |
| --- | --- |
| Actor | `R-ADMIN`, shopfloor operators |
| Module | M16 Admin UI, M02 Auth Permission |
| Precondition | User/role/permission seed; screen/action registry configured. |
| Main flow | 1. Admin config role/action/screen. 2. User sees menu/actions by permission. 3. Operator uses PWA submit scan/action with idempotency. 4. Duplicate/offline replay returns stable result. |
| Alternate/error flow | User missing permission -> backend `403`; offline duplicate không double-post; conflict replay shows resolution. |
| Postcondition | UI/PWA respects permission and idempotency. |
| API/UI | `/api/admin/ui/*`, `/api/mobile/*`; Menu/Sidebar, Shopfloor PWA |
| Acceptance | AC-RBAC-001, AC-PWA-001 |

## UC-18 - Correction, rollback, hold/halt/cancel/reject

| Field | Nội dung |
| --- | --- |
| Actor | Role owning object, `R-OPS-MGR` for override |
| Module | Cross-module |
| Precondition | Object exists; user has action permission. |
| Main flow | 1. User selects exception action. 2. Enters reason. 3. System validates side effects/state. 4. Applies hold/halt/cancel/reject/correction/rollback/override according to rules. 5. Writes audit and state transition. |
| Alternate/error flow | Object already posted/externalized -> rollback blocked, correction/reversal required; override cannot bypass append-only/public-private hard locks. |
| Postcondition | Exception handled without deleting history or breaking trace. |
| API/UI | Exception action endpoints per module; Detail screens/Override Queue |
| Acceptance | AC-EXC-001..AC-EXC-006 |



