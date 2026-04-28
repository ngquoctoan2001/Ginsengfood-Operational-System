# Role And Permission Model

> Mục đích: xác định ai được tạo, duyệt, xác nhận, release và override từng nghiệp vụ. Permission phải được enforce ở backend, UI chỉ là lớp hỗ trợ.

## 1. Role Catalog

| role_code | Vai trò | Mô tả | Module chính |
| --- | --- | --- | --- |
| `R-ADMIN` | System Admin | Quản trị user/role/screen/config hệ thống. | M01, M02, M16 |
| `R-OPS-MGR` | Operations Manager | Chịu trách nhiệm điều phối vận hành end-to-end và override có kiểm soát. | All operational modules |
| `R-PROD-MGR` | Production Manager | Duyệt production order, material request, exception sản xuất. | M07, M08 |
| `R-PROD-OP` | Production Operator | Thực hiện công đoạn sản xuất và xác nhận receipt tại xưởng. | M07, M08 |
| `R-WH-RAW` | Raw Warehouse Operator | Nhập nguyên liệu, cấp phát nguyên liệu, quản lý raw inventory. | M06, M08, M11 |
| `R-WH-FG` | Finished Goods Warehouse Operator | Nhập kho thành phẩm, quản lý tồn thành phẩm, allocation/dispatch reference. | M11 |
| `R-QC-RAW` | Raw Material QC | Kiểm QC nguyên liệu đầu vào. | M06, M09 |
| `R-QC-PROD` | Production/Finished QC | Kiểm QC sau công đoạn/thành phẩm. | M09 |
| `R-QA-REL` | QA Release Authority | Duyệt release batch, reject release, giữ batch khi cần. | M09, M13 |
| `R-PACK-OP` | Packaging Operator | Tạo/thực hiện packaging job, đóng gói BOX/CARTON. | M10 |
| `R-PRINT-OP` | Print Operator | In QR/label, xử lý print queue, request reprint. | M10 |
| `R-TRACE` | Traceability Analyst | Tra cứu internal trace, kiểm public trace preview, phân tích genealogy. | M12 |
| `R-RECALL-MGR` | Recall Manager | Mở recall, impact analysis, hold/sale lock, recovery, disposition, CAPA. | M13 |
| `R-ACC-INT` | Accounting Integration Operator | Quản lý mapping/retry/reconcile MISA. | M14 |
| `R-DEVOPS` | DevOps/Release Operator | Backup/restore, retention, health, integration config. | M15, CODE16 |
| `R-AUDITOR` | Auditor/Read-only Reviewer | Xem audit, trace, release, recall, inventory ledger; không sửa dữ liệu. | M01, M12, M13 |

## 2. Action Permission Matrix

Legend: `C` create, `U` update draft, `S` submit, `A` approve, `Rj` reject, `X` execute/confirm, `Rel` release, `H` hold/halt, `Can` cancel, `Corr` correction, `Ovr` override, `View` read.

| action_area | R-ADMIN | R-OPS-MGR | R-PROD-MGR | R-PROD-OP | R-WH-RAW | R-WH-FG | R-QC-RAW | R-QC-PROD | R-QA-REL | R-PACK-OP | R-PRINT-OP | R-TRACE | R-RECALL-MGR | R-ACC-INT | R-DEVOPS | R-AUDITOR |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| User/role/screen config | C/U/A/View | View/Ovr | View | View | View | View | View | View | View | View | View | View | View | View | View | View |
| Source zone/origin | View | A/H/Ovr | View | View | View | View | View | View | View | View | View | View | View | View | View | View |
| Source origin verification | View | A/Rj/H | View | View | C/S | View | View | View | A/Rj | View | View | View | View | View | View | View |
| Raw material intake | View | H/Ovr | View | View | C/U/S/Can | View | View | View | View | View | View | View | View | View | View | View |
| Raw material QC | View | H/Ovr | View | View | View | View | C/X/Rj/Corr | View | View | View | View | View | View | View | View | View |
| Raw lot mark-ready | View | A/H/Ovr | View | View | View | View | View | View | A/Rj | View | View | View | View | View | View | View |
| SKU/ingredient/recipe | C/U/View | A/Ovr | View | View | View | View | View | View | A/Rj | View | View | View | View | View | View | View |
| Production order | View | H/Ovr | C/U/S/A/Rj/Can | View | View | View | View | View | View | View | View | View | View | View | View | View |
| Production process | View | H/Ovr | A/H/Can | C/X/H | View | View | View | C/X/Rj | View | View | View | View | View | View | View | View |
| Workforce check-in/out | View | H/Ovr | A/View | C/X | View | View | View | View | View | View | View | View | View | View | View | View |
| Material request | View | H/Ovr | A/Rj/Can | C/S | View | View | View | View | View | View | View | View | View | View | View | View |
| Material issue execution | View | H/Ovr | View | View | X/Can/Corr | View | View | View | View | View | View | View | View | View | View | View |
| Material receipt confirmation | View | H/Ovr | View | X/Corr | View | View | View | View | View | View | View | View | View | View | View | View |
| Packaging job | View | H/Ovr | View | View | View | View | View | View | View | C/U/X/H/Can | View | View | View | View | View | View |
| Print/QR/reprint | View | H/Ovr | View | View | View | View | View | View | View | View | C/X/S | View | View | View | View | View |
| QC inspection finished | View | H/Ovr | View | View | View | View | View | C/X/Rj/Corr | View | View | View | View | View | View | View | View |
| Batch release | View | H/Ovr | View | View | View | View | View | View | Rel/Rj/H/Corr | View | View | View | View | View | View | View |
| Warehouse receipt FG | View | H/Ovr | View | View | View | C/X/Can/Corr | View | View | View | View | View | View | View | View | View | View |
| Inventory adjustment | View | A/Ovr | View | View | C/S | C/S | View | View | View | View | View | View | View | View | View | View |
| Trace internal | View | View | View | View | View | View | View | View | View | View | View | View | View | View | View | View |
| Trace analysis | View | View | View | View | View | View | View | View | View | View | View | C/View | View | View | View | View |
| Recall case | View | A/H/Ovr | View | View | View | View | View | View | View | View | View | View | C/U/S/A/H/Can/Corr | View | View | View |
| MISA mapping/retry/reconcile | View | View/Ovr | View | View | View | View | View | View | View | View | View | View | View | C/U/X/Corr | View | View |
| Accounting document posting | View | View/Ovr | View | View | View | View | View | View | View | View | View | View | View | C/U/X/Corr | View | View |
| Dashboard/alerts | View | View/A | View | View | View | View | View | View | View | View | View | View | View | View | C/U/View | View |
| Backup/retention/archive | View | A | View | View | View | View | View | View | View | View | View | View | View | View | C/U/X | View |

## 3. Sensitive Action Ownership

| action_code | Ai tạo | Ai duyệt | Ai xác nhận/thực thi | Ai release | Ai override | Audit required |
| --- | --- | --- | --- | --- | --- | --- |
| `SOURCE_ORIGIN_VERIFY` | `R-WH-RAW` hoặc admin data steward | `R-QA-REL` hoặc `R-OPS-MGR` | N/A | N/A | `R-OPS-MGR` | Có |
| `RAW_INTAKE_CREATE` | `R-WH-RAW` | Optional theo policy | `R-WH-RAW` submit | N/A | `R-OPS-MGR` | Có |
| `RAW_QC_SIGN` | `R-QC-RAW` | Optional QA review | `R-QC-RAW` | N/A | `R-OPS-MGR` | Có |
| `RAW_LOT_MARK_READY` | `R-QA-REL` hoặc `R-OPS-MGR` | `R-QA-REL` / `R-OPS-MGR` | `R-QA-REL` | N/A | `R-OPS-MGR` | Có |
| `RECIPE_APPROVE` | `R-ADMIN`/data steward | `R-QA-REL` hoặc `R-OPS-MGR` | N/A | N/A | `R-OPS-MGR` | Có |
| `RECIPE_ACTIVATE` | `R-ADMIN`/data steward | `R-OPS-MGR` | N/A | N/A | `R-OPS-MGR` | Có |
| `PRODUCTION_ORDER_APPROVE` | `R-PROD-MGR` | `R-PROD-MGR` hoặc `R-OPS-MGR` | N/A | N/A | `R-OPS-MGR` | Có |
| `MATERIAL_REQUEST_APPROVE` | `R-PROD-OP` | `R-PROD-MGR` | N/A | N/A | `R-OPS-MGR` | Có |
| `MATERIAL_ISSUE_EXECUTE` | `R-WH-RAW` | Đã duyệt request | `R-WH-RAW` | N/A | `R-OPS-MGR` | Có |
| `MATERIAL_RECEIPT_CONFIRM` | `R-PROD-OP` | Optional variance review | `R-PROD-OP` | N/A | `R-OPS-MGR` | Có |
| `WORKFORCE_CHECK_IN_OUT` | `R-PROD-OP` | N/A | `R-PROD-OP` | N/A | `R-OPS-MGR` | Có |
| `WORKFORCE_ATTENDANCE_CONFIRM` | `R-PROD-OP` | `R-PROD-MGR` | `R-PROD-MGR` | N/A | `R-OPS-MGR` | Có |
| `BATCH_QC_SIGN` | `R-QC-PROD` | Optional QA review | `R-QC-PROD` | N/A | `R-OPS-MGR` | Có |
| `BATCH_RELEASE` | `R-QA-REL` | `R-QA-REL` hoặc `R-OPS-MGR` theo policy | N/A | `R-QA-REL` | `R-OPS-MGR` | Có |
| `WAREHOUSE_RECEIPT_CONFIRM` | `R-WH-FG` | Optional manager review | `R-WH-FG` | N/A | `R-OPS-MGR` | Có |
| `WAREHOUSE_RECEIPT_CORRECTION` | `R-WH-FG` | `R-OPS-MGR` | `R-WH-FG` sau approval | N/A | `R-OPS-MGR` | Có |
| `QR_REPRINT` | `R-PRINT-OP` | `R-OPS-MGR` nếu policy yêu cầu | `R-PRINT-OP` | N/A | `R-OPS-MGR` | Có |
| `RECALL_OPEN` | `R-RECALL-MGR` | `R-OPS-MGR` | N/A | N/A | `R-OPS-MGR` | Có |
| `RECALL_HOLD_SALE_LOCK` | `R-RECALL-MGR` | `R-OPS-MGR` hoặc `R-RECALL-MGR` theo severity | `R-RECALL-MGR` | N/A | `R-OPS-MGR` | Có |
| `MISA_MANUAL_RETRY` | `R-ACC-INT` | Optional | `R-ACC-INT` | N/A | `R-OPS-MGR` | Có |
| `ACCOUNTING_DOCUMENT_POST` | System/outbox hoặc `R-ACC-INT` | Optional `R-OPS-MGR` khi correction/reconcile | `R-ACC-INT` | N/A | `R-OPS-MGR` | Có |
| `BREAK_GLASS_OVERRIDE` | Requesting role | `R-OPS-MGR` + second approver bắt buộc cho Level 3 | `R-OPS-MGR` | N/A | `R-OPS-MGR` | Có, high severity, auto-expire 15 phút |

## 4. Permission Rules

| permission_rule_id | Rule | Validation | Exception |
| --- | --- | --- | --- |
| PR-001 | Không role nào được tự bypass backend permission bằng UI. | API luôn kiểm `permission/action`. | Không có exception. |
| PR-002 | Read-only role không gọi được command endpoint. | `R-AUDITOR` chỉ view/export nếu policy cho phép. | Export sensitive cần permission riêng. |
| PR-003 | Separation of duty áp dụng cho recipe activation, release, inventory adjustment lớn, override nếu owner chốt. | Submitter và approver khác user khi policy yêu cầu. | Owner có thể chốt threshold sau. |
| PR-004 | Override không được sửa ledger/audit/snapshot in-place. | Override chỉ tạo action log/correction/reversal. | Không có exception. |
| PR-005 | Public trace API không dùng admin permission context. | Public route chỉ dùng QR token/code và field policy. | Không trả private field dù user admin gọi public route. |
| PR-006 | QC correction do `R-QC-RAW`/`R-QC-PROD` đề xuất phải qua `R-QA-REL` hoặc policy approver trước khi có hiệu lực. | Matrix có thể cho role QC tạo correction request, nhưng backend phải enforce approval dependency. | Emergency correction vẫn đi qua override/audit, không sửa signed QC in-place. |
| PR-007 | `RAW_LOT_MARK_READY` là permission riêng với `RAW_QC_SIGN`. | User ký QC không tự động có quyền mark-ready nếu không được cấp action. | `R-OPS-MGR` có thể override có audit. |
