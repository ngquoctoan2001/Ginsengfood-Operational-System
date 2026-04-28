# User Stories

> Mục đích: diễn đạt requirement theo vai trò người dùng, có business value và acceptance anchor. Story không thay thế business rule; story phải được kiểm bằng acceptance criteria trong [04_ACCEPTANCE_CRITERIA.md](04_ACCEPTANCE_CRITERIA.md).

## 1. Story Catalog

| story_id | Role | Story | Module | Priority | Acceptance |
| --- | --- | --- | --- | --- | --- |
| US-SRC-001 | `R-WH-RAW` | Là nhân viên kho nguyên liệu, tôi muốn tạo source zone/source origin để raw lot tự trồng có nguồn gốc rõ ràng. | M05 | P0 | AC-SRC-001 |
| US-SRC-002 | `R-QA-REL` | Là QA/release authority, tôi muốn verify hoặc reject source origin với evidence để chỉ nguồn đạt chuẩn mới được dùng. | M05 | P0 | AC-SRC-002 |
| US-SUPPLIER-001 | `R-ADMIN`/`R-OPS-MGR` | Là người quản lý master data, tôi muốn quản lý supplier active/inactive để lot `PURCHASED` dùng đúng nhà cung cấp. | M03 | P0 | AC-MD-001 |
| US-RM-001 | `R-WH-RAW` | Là nhân viên kho nguyên liệu, tôi muốn nhập nguyên liệu theo `SELF_GROWN` hoặc `PURCHASED` để hệ thống tạo lot đúng nguồn. | M06 | P0 | AC-RM-001..003 |
| US-QC-RAW-001 | `R-QC-RAW` | Là QC nguyên liệu, tôi muốn ký kết quả QC lot để lot đạt có thể đi tiếp sang bước mark-ready. | M06, M09 | P0 | AC-QC-001 |
| US-LOT-READY-001 | `R-QA-REL`/`R-OPS-MGR` | Là QA/release authority, tôi muốn mark-ready raw lot sau QC pass để chỉ lot `READY_FOR_PRODUCTION` mới được material issue. | M06, M08 | P0 | AC-RM-004, AC-MI-001 |
| US-REC-001 | Data steward | Là người quản lý master, tôi muốn quản lý 20 SKU baseline và ingredient master để sản xuất G1 không thiếu dữ liệu. | M04 | P0 | AC-REC-001, AC-REC-002 |
| US-REC-002 | `R-QA-REL` | Là QA, tôi muốn approve/activate recipe G1 và version tương lai để công thức vận hành có kiểm soát. | M04, M02 | P0 | AC-REC-003..005 |
| US-PO-001 | `R-PROD-MGR` | Là trưởng sản xuất, tôi muốn mở production order từ active recipe để hệ thống snapshot công thức bất biến. | M07, M04 | P0 | AC-PO-001 |
| US-PO-002 | `R-PROD-MGR` | Là trưởng sản xuất, tôi muốn in phiếu lệnh từ snapshot để xưởng dùng đúng công thức đã khóa. | M07, M10 | P0 | AC-PO-002 |
| US-MAT-001 | `R-PROD-OP` | Là operator sản xuất, tôi muốn gửi material request từ snapshot để kho cấp đúng nguyên liệu. | M08 | P0 | AC-MI-002 |
| US-MAT-002 | `R-WH-RAW` | Là thủ kho nguyên liệu, tôi muốn execute material issue để tồn nguyên liệu giảm đúng tại điểm cấp phát. | M08, M11 | P0 | AC-MI-001 |
| US-MAT-003 | `R-PROD-OP` | Là operator sản xuất, tôi muốn xác nhận xưởng nhận nguyên liệu và ghi variance để đối soát với kho. | M08 | P0 | AC-MR-001 |
| US-PROC-001 | `R-PROD-OP` | Là operator sản xuất, tôi muốn ghi công đoạn sơ chế, cấp đông, sấy thăng hoa theo đúng thứ tự. | M07 | P0 | AC-PROC-001 |
| US-WORKFORCE-001 | `R-PROD-OP`/`R-PROD-MGR` | Là operator sản xuất, tôi muốn check-in/check-out ca/công đoạn và được quản lý xác nhận để có dữ liệu lao động vận hành. | M07 | P0 | AC-WORKFORCE-001 |
| US-PKG-001 | `R-PACK-OP` | Là nhân viên đóng gói, tôi muốn tạo packaging job theo BOX/CARTON để kiểm soát đơn vị đóng gói. | M10 | P0 | AC-PKG-001 |
| US-PRINT-001 | `R-PRINT-OP` | Là nhân viên in, tôi muốn generate/queue/print QR và request reprint có lý do để nhãn không bị in ngoài kiểm soát. | M10 | P0 | AC-QR-001, AC-PRINT-001 |
| US-QR-VOID-001 | `R-PRINT-OP`/`R-OPS-MGR` | Là người vận hành in/QR, tôi muốn void QR với reason để mã lỗi/hủy không còn public trace hợp lệ. | M10, M12 | P0 | AC-PTRACE-002, AC-QR-002 |
| US-QC-REL-001 | `R-QC-PROD` | Là QC thành phẩm, tôi muốn ký QC batch để QA có căn cứ release hoặc reject. | M09 | P0 | AC-REL-001 |
| US-QA-REL-001 | `R-QA-REL` | Là QA release, tôi muốn release batch bằng action riêng để `QC_PASS` không tự động nhập kho/bán. | M09 | P0 | AC-REL-001, AC-REL-002 |
| US-WH-001 | `R-WH-FG` | Là kho thành phẩm, tôi muốn chỉ nhập kho batch đã release để tồn thành phẩm hợp lệ. | M11 | P0 | AC-WH-001 |
| US-INV-001 | `R-WH-RAW`/`R-WH-FG` | Là nhân viên kho, tôi muốn xem ledger và balance theo lot để đối soát tồn kho. | M11 | P0 | AC-INV-001 |
| US-TRACE-001 | `R-TRACE` | Là trace analyst, tôi muốn truy ngược/truy xuôi từ QR/batch/lot để phân tích nguồn gốc và ảnh hưởng. | M12 | P0 | AC-TRACE-001 |
| US-PTRACE-001 | Public user | Là người tiêu dùng, tôi muốn scan QR để xem thông tin nguồn gốc an toàn và không thấy dữ liệu nội bộ. | M12 | P0 | AC-PTRACE-001 |
| US-RECALL-001 | `R-RECALL-MGR` | Là recall manager, tôi muốn mở recall và tạo impact snapshot để xác định batch/lot/customer exposure. | M13 | P0 | AC-RECALL-001, AC-RECALL-002 |
| US-RECALL-002 | `R-RECALL-MGR` | Là recall manager, tôi muốn apply hold/sale lock và theo dõi recovery/CAPA để thu hồi có kiểm soát. | M13 | P0 | AC-RECALL-003 |
| US-MISA-001 | `R-ACC-INT` | Là kế toán/integration operator, tôi muốn xem sync event, sửa mapping, retry và reconcile để MISA đồng bộ có kiểm soát. | M14 | P0 | AC-MISA-001, AC-MISA-002 |
| US-RBAC-001 | `R-ADMIN` | Là admin, tôi muốn quản lý role/action/screen để người dùng chỉ thấy và gọi được chức năng được phép. | M02, M16 | P0 | AC-RBAC-001 |
| US-AUD-001 | `R-AUDITOR` | Là auditor, tôi muốn xem audit/state transition để kiểm tra ai làm gì, lúc nào, vì sao. | M01 | P0 | AC-AUD-001 |
| US-PWA-001 | Shopfloor operator | Là operator xưởng, tôi muốn submit bằng PWA/offline idempotent để thao tác không bị double-post khi mạng yếu. | M16, M01 | P1 | AC-PWA-001 |
| US-DASH-001 | `R-OPS-MGR` | Là operations manager, tôi muốn dashboard/alert cho các flow trọng yếu để phát hiện lỗi vận hành sớm. | M15 | P1 | AC-DASH-001, AC-ALERT-001 |
| US-OVR-001 | Requesting role, `R-OPS-MGR` | Là người phụ trách vận hành khẩn cấp, tôi muốn dùng break-glass có scope, dual approval và tự hết hạn để xử lý sự cố mà không phá audit. | M01, M02, M15 | P0 | AC-OVR-001 |
| US-EXC-001 | Workflow owner | Là người phụ trách nghiệp vụ, tôi muốn hold/halt/cancel/reject/correction/rollback có reason/audit để xử lý ngoại lệ không mất lịch sử. | Cross-module | P0 | AC-EXC-001..006 |

## 2. Story Readiness Rules

| readiness_id | Rule |
| --- | --- |
| SR-001 | Story không ready nếu chưa map được module, API/UI surface và acceptance criteria. |
| SR-002 | Story liên quan state transition phải map state machine trong [../workflows/04_STATE_MACHINES.md](../workflows/04_STATE_MACHINES.md). |
| SR-003 | Story liên quan DB/API/UI phải được cập nhật tiếp ở nhóm `database/`, `api/`, `ui/`. |
| SR-004 | Story có owner decision mở vẫn viết được, nhưng acceptance phải ghi rõ phần blocked/deferred. |
| SR-005 | Story không được tạo business rule mới ngoài nguồn; nếu cần suy luận chuyên môn phải ghi `OWNER DECISION NEEDED`. |
