# Approval And Audit Rules

> Mục đích: chuẩn hóa approval, reject, correction, override và audit cho các workflow vận hành. Mọi approval/audit ở đây là requirement đích, không phải xác nhận implementation hiện tại.

## 1. Approval Principles

| principle_id | Principle | Rule |
| --- | --- | --- |
| APP-P01 | Explicit action | Duyệt/từ chối là action riêng, không suy ra từ update field. |
| APP-P02 | Reason required | Reject, hold, cancel, correction, override phải có reason. |
| APP-P03 | Immutable history | Record đã signed/posted/released không sửa trực tiếp; correction/reversal là record mới. |
| APP-P04 | Least privilege | Chỉ role có permission/action code mới duyệt được. |
| APP-P05 | Separation ready | Thiết kế phải hỗ trợ tách submitter và approver nếu owner chốt threshold. |
| APP-P06 | Audit first-class | Approval sinh audit và state transition log. |
| APP-P07 | Time-bound emergency | Level 3 break-glass override phải có dual approval, scoped permission và auto-expire sau 15 phút. |

## 2. Approval Matrix

| approval_id | Object/action | Submitter | Approver | Approval condition | Reject condition | Audit event | Test case |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AP-SRC-001 | Source origin verification | `R-WH-RAW` hoặc data steward | `R-QA-REL` / `R-OPS-MGR` | Evidence đủ, address/source zone hợp lệ | Evidence thiếu/sai | `SOURCE_ORIGIN_VERIFIED` / `SOURCE_ORIGIN_REJECTED` | TC-APP-SRC-001 |
| AP-RM-READY-001 | Raw lot mark-ready | `R-QA-REL` / `R-OPS-MGR` | `R-QA-REL` / `R-OPS-MGR` | Raw lot có QC result `QC_PASS`, source hợp lệ, balance available, không hold/reject | Lot chưa QC pass, đang hold/reject, thiếu reason hoặc thiếu permission | `RAW_LOT_READY_FOR_PRODUCTION` / `RAW_LOT_MARK_READY_REJECTED` | TC-APP-RM-READY-001 |
| AP-REC-001 | Recipe approve | Data steward / admin | `R-QA-REL` / `R-OPS-MGR` | Recipe có đúng 4 group, ingredient active, chỉ dùng operational baseline hợp lệ | Thiếu line, group sai, version conflict | `RECIPE_APPROVED` / `RECIPE_REJECTED` | TC-APP-REC-001 |
| AP-REC-002 | Recipe activate | Data steward / admin | `R-OPS-MGR` | Version approved, effective date hợp lệ, chỉ một active version | Version chưa approve hoặc overlap policy sai | `RECIPE_ACTIVATED` | TC-APP-REC-002 |
| AP-PO-001 | Production order approve | `R-PROD-MGR` | `R-PROD-MGR` / `R-OPS-MGR` | Snapshot G1 đầy đủ, SKU active, batch quantity hợp lệ | Thiếu recipe/snapshot hoặc baseline nghiên cứu | `PRODUCTION_ORDER_APPROVED` | TC-APP-PO-001 |
| AP-MR-001 | Material request approve | `R-PROD-OP` | `R-PROD-MGR` | Request line thuộc snapshot, quantity hợp lệ | Ngoài snapshot hoặc thiếu material | `MATERIAL_REQUEST_APPROVED` / `REJECTED` | TC-APP-MR-001 |
| AP-MI-001 | Material issue exception | `R-WH-RAW` | `R-PROD-MGR` / `R-OPS-MGR` | Có lý do ngoài snapshot/variance và risk accepted | Không có reason hoặc phá recipe lock | `MATERIAL_ISSUE_EXCEPTION_APPROVED` | TC-APP-MI-001 |
| AP-QC-001 | QC correction | `R-QC-RAW` / `R-QC-PROD` | `R-QA-REL` | Có original inspection, correction reason, evidence | Muốn sửa trực tiếp record đã ký | `QC_CORRECTION_APPROVED` | TC-APP-QC-001 |
| AP-REL-001 | Batch release | `R-QA-REL` | `R-QA-REL` / `R-OPS-MGR` | QC pass, no active hold, prerequisites complete | QC hold/reject hoặc active hold | `BATCH_RELEASED` / `RELEASE_REJECTED` | TC-APP-REL-001 |
| AP-PRINT-001 | QR/label reprint | `R-PRINT-OP` | `R-OPS-MGR` nếu policy yêu cầu | Original job valid, reason exists | Không có original/reason | `QR_REPRINT_APPROVED` / `QR_REPRINTED` | TC-APP-PRINT-001 |
| AP-INV-001 | Inventory adjustment | `R-WH-RAW` / `R-WH-FG` | `R-OPS-MGR` | Reason, count evidence, adjustment type | Thiếu reason hoặc negative invalid | `INVENTORY_ADJUSTMENT_APPROVED` | TC-APP-INV-001 |
| AP-WH-CORR-001 | Warehouse receipt correction | `R-WH-FG` | `R-OPS-MGR` | Receipt đã confirmed, có reason, correction không sửa ledger cũ | Muốn update receipt/ledger in-place hoặc thiếu reason | `WAREHOUSE_RECEIPT_CORRECTION_APPROVED` | TC-APP-WH-CORR-001 |
| AP-RECALL-001 | Recall open/severity | `R-RECALL-MGR` | `R-OPS-MGR` | Incident đủ severity/evidence | Thiếu evidence | `RECALL_OPENED` | TC-APP-RECALL-001 |
| AP-RECALL-002 | Recall hold/sale lock | `R-RECALL-MGR` | `R-OPS-MGR` hoặc policy severity | Impact snapshot exists | Chưa có impact hoặc object không hợp lệ | `RECALL_HOLD_APPLIED`, `SALE_LOCK_APPLIED` | TC-APP-RECALL-002 |
| AP-MISA-001 | MISA manual retry/reconcile correction | `R-ACC-INT` | Optional `R-OPS-MGR` | Mapping fixed hoặc retry reason exists | Missing mapping vẫn chưa xử lý | `MISA_MANUAL_RETRY`, `MISA_RECONCILED` | TC-APP-MISA-001 |
| AP-OVR-001 | Break-glass override Level 3 | Requesting role | `R-OPS-MGR` + second approver bắt buộc | Emergency, reason, scoped permission, expiry <= 15 phút | Muốn bypass public/private/append-only hard lock hoặc gia hạn không duyệt | `BREAK_GLASS_OVERRIDE_USED` / `BREAK_GLASS_OVERRIDE_EXPIRED` | TC-APP-OVR-001 |

## 3. Audit Event Contract

| field | Required | Meaning |
| --- | --- | --- |
| `audit_id` | Có | Unique audit record. |
| `event_type` | Có | Business event/action code. |
| `actor_user_id` | Có | User thực hiện. |
| `actor_role_code` | Có | Role tại thời điểm action. |
| `object_type` | Có | Loại object: production order, lot, batch, recall, etc. |
| `object_id` | Có | ID object chính. |
| `parent_object_type` | Có khi có | PO/batch/recall parent nếu action thuộc child object. |
| `parent_object_id` | Có khi có | ID parent. |
| `from_state` | Có khi transition | State trước action. |
| `to_state` | Có khi transition | State sau action. |
| `reason_code` | Có khi reject/hold/cancel/correction/override | Lý do chuẩn hóa. |
| `reason_text` | Có khi reason_code chưa đủ | Ghi chú nghiệp vụ. |
| `before_snapshot` | Có khi update non-sensitive | Snapshot trước action nếu phù hợp. |
| `after_snapshot` | Có khi update non-sensitive | Snapshot sau action nếu phù hợp. |
| `correlation_id` | Có | Trace request/workflow. |
| `idempotency_key` | Có khi command idempotent | Chống submit trùng. |
| `created_at` | Có | Timestamp hệ thống. |
| `source_channel` | Có | `ADMIN_WEB`, `PWA`, `SYSTEM`, `INTEGRATION`, etc. |

## 4. Audit Coverage

| area | Must audit |
| --- | --- |
| Source origin | Create/update evidence, verify, reject, suspend. |
| Raw material | Intake submit, QC sign, hold/reject, correction. |
| Raw lot readiness | Mark-ready, reject mark-ready, release readiness hold, readiness correction. |
| Recipe | Create/update draft, submit, approve, activate, retire, reject. |
| Production | Create/approve/cancel PO, snapshot create, process event, halt/correction. |
| Material | Request, approve, issue execute, receipt confirm, variance/correction. |
| Packaging/printing | Packaging complete, QR generate/print/fail/void/reprint. |
| QC/release | Inspection sign, release approve/reject/revoke. |
| Warehouse/inventory | Receipt confirm, ledger post, adjustment/reversal. |
| Trace | Internal trace export, public policy change, trace gap flag. |
| Recall | Open, impact snapshot, hold, sale lock, recovery, disposition, CAPA, close. |
| MISA | Mapping change, sync success/fail, retry, reconcile. |
| Device/printer | Device registration, unregistered device attempt, device token failure, print callback accepted/rejected, printer status change. |
| Security | Login failure if tracked, permission denial for sensitive command, override. |

## 5. Correction And Rollback Rules

| rule_id | Rule | Applies to | QA expectation |
| --- | --- | --- | --- |
| ACR-001 | Posted ledger cannot be edited; use reversal/adjustment. | Inventory | Test direct edit is blocked; correction creates linked record. |
| ACR-002 | Signed QC cannot be edited; create correction inspection or correction item. | QC | Original remains visible and read-only. |
| ACR-003 | Production snapshot cannot be edited; create correction note/exception if needed. | Production | Snapshot hash/fields unchanged after recipe update. |
| ACR-004 | MISA synced event cannot be deleted; reconcile or compensation event required. | MISA | Sync log remains append-only. |
| ACR-005 | Public QR void does not delete QR history; state becomes `VOID`. | QR | Public trace invalid, admin history visible. |
| ACR-006 | Recall impact re-run creates new snapshot version. | Recall | Prior snapshot remains available. |
| ACR-007 | Warehouse receipt correction cannot mutate confirmed receipt or posted ledger in-place. | Warehouse/inventory | Correction creates linked correction/reversal/adjustment record and audit. |

## 6. Approval Open Decisions

| decision_id | Nội dung cần owner chốt | Default until decided |
| --- | --- | --- |
| OD-APP-THRESHOLD | Threshold nào cần dual approval cho inventory adjustment và reprint ngoài Level 3 break-glass? | Treat high-risk actions as requiring `R-OPS-MGR`; Level 3 break-glass luôn dual approval + 15 phút auto-expiry. |
| OD-APP-SEPARATION | Có bắt buộc submitter khác approver cho tất cả approval không? | Design must support separation; enforce where policy already explicit. |
| OD-APP-EXPORT | Audit/trace export có cần approval riêng không? | Read-only viewer allowed; export sensitive requires permission. |



