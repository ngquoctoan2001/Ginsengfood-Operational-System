# Operational Rules

> Mục đích: khóa cách vận hành thực tế của nhà máy trong các luồng chính, luồng phụ và luồng lỗi. File này bổ sung rõ các rule còn thiếu về `hold`, `halt`, `cancel`, `reject`, `rollback`, `correction`.

## 1. Canonical Operational Flow

```text
Source Origin Verification
→ Raw Material Intake
→ Incoming QC
→ Raw Lot Mark Ready
→ Raw Lot Ready For Production
→ G1 Production Order Snapshot
→ Material Request / Approval
→ Material Issue Execution
→ Material Receipt Confirmation
→ Production Process: PREPROCESSING → FREEZING → FREEZE_DRYING
→ Packaging / Printing / QR
→ QC Inspection
→ Batch Release
→ Warehouse Receipt
→ Inventory Ledger / Lot Balance
→ Trace / Public Trace
→ Recall / Recovery
→ MISA Sync via Integration Layer
```

## 2. Operational State Rules

| object | Required states | Rule | Blocked transition | Test case |
| --- | --- | --- | --- | --- |
| `op_source_origin` | `DRAFT`, `SUBMITTED`, `VERIFIED`, `REJECTED`, `SUSPENDED` | `SELF_GROWN` lot chỉ nhận source origin `VERIFIED`. | `DRAFT/SUBMITTED/REJECTED/SUSPENDED -> intake SELF_GROWN` | TC-OP-SRC-001 |
| `op_raw_material_lot` | `CREATED`, `IN_QC`, `QC_PASSED_WAITING_READY`, `READY_FOR_PRODUCTION`, `RESERVED`, `CONSUMED`, `ON_HOLD`, `REJECTED`, `EXPIRED`, `QUARANTINED` | QC result `QC_PASS` chỉ đưa lot vào trạng thái chờ mark-ready; chỉ `READY_FOR_PRODUCTION` mới được material issue. | `QC_PASSED_WAITING_READY/ON_HOLD/REJECTED/QUARANTINED -> material issue` | TC-OP-RM-001, TC-OP-RM-READY-001 |
| `op_production_recipe` | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `ACTIVE`, `RETIRED`, `REJECTED` | Production order chỉ dùng active approved G1 hoặc version active tương lai. | `DRAFT/PENDING/REJECTED/RETIRED -> production order` | TC-OP-REC-001 |
| `op_production_order` | `DRAFT`, `OPEN`, `APPROVED`, `IN_PROGRESS`, `ON_HOLD`, `CANCELLED`, `COMPLETED`, `CLOSED` | Snapshot tạo khi mở/approve; không mutate sau khi bắt đầu issue. | `IN_PROGRESS -> edit snapshot` | TC-OP-PO-001 |
| `op_batch` | `CREATED`, `IN_PROCESS`, `PACKAGED`, `QC_PENDING`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`, `RELEASED`, `BLOCKED`, `CLOSED` | Batch là genealogy root; `QC_PASS` không tự release, `RELEASED` chỉ sau release action. | `QC_PASS -> warehouse receipt` khi chưa release record; `BLOCKED -> release/warehouse` | TC-OP-BATCH-001 |
| `op_material_issue` | `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `EXECUTED`, `ON_HOLD`, `CANCELLED`, `REVERSED` | `EXECUTED` tạo ledger decrement. | `EXECUTED -> delete/update line` | TC-OP-MI-001 |
| `op_material_receipt` | `DRAFT`, `CONFIRMED`, `VARIANCE_REVIEW`, `CANCELLED` | Receipt xác nhận xưởng nhận và variance, không decrement. | `CONFIRMED -> edit quantity without correction` | TC-OP-MR-001 |
| `op_production_process_event` | `NOT_STARTED`, `IN_PROGRESS`, `DONE`, `HALTED`, `REJECTED`, `CORRECTED` | Bắt buộc thứ tự `PREPROCESSING -> FREEZING -> FREEZE_DRYING`. | `FREEZE_DRYING DONE` khi thiếu `FREEZING DONE` | TC-OP-PROC-001 |
| `op_qc_inspection` | `DRAFT`, `IN_REVIEW`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`, `CORRECTED` | QC signed record append-only; correction là record mới. | `QC_PASS -> edit checklist` | TC-OP-QC-001 |
| `op_batch_release` | `PENDING`, `APPROVED_RELEASED`, `REJECTED`, `REVOKED` | `QC_PASS` không tự release. | Warehouse receipt khi chưa `APPROVED_RELEASED` | TC-OP-REL-001 |
| `op_packaging_job` | `DRAFT`, `READY`, `IN_PROGRESS`, `PRINTING`, `COMPLETED`, `PRINT_ERROR`, `ON_HOLD`, `CANCELLED` | Packaging chỉ mở khi process và prerequisite đã đủ; print state/error không tự tạo QC pass, release hoặc inventory. | Packaging khi production process chưa xong; `PRINT_ERROR -> completed` không có correction/reprint | TC-OP-PKG-001 |
| `op_qr_registry` | `GENERATED`, `QUEUED`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED` | `VOID`/`FAILED` không public trace hợp lệ. | Public resolve QR void/failed | TC-OP-QR-001 |
| `op_warehouse_receipt` | `DRAFT`, `CONFIRMED`, `CANCELLED`, `CORRECTED` | Confirm receipt tạo finished-goods ledger credit. | Confirm receipt batch chưa release | TC-OP-WH-001 |
| `op_inventory_ledger` | `POSTED`, `REVERSAL_POSTED`, `ADJUSTMENT_POSTED` | Ledger append-only, không update/delete. | Direct update posted ledger | TC-OP-INV-001 |
| `op_recall_case` | `OPEN`, `IMPACT_ANALYSIS`, `HOLD_ACTIVATED`, `SALE_LOCK_ACTIVATED`, `NOTIFICATION_SENT`, `RECOVERY`, `DISPOSITION`, `CAPA`, `CLOSED`, `CLOSED_WITH_RESIDUAL_RISK`, `CANCELLED` | Close chỉ khi impact/hold/recovery/disposition/CAPA đạt policy; close residual risk cần explicit residual note và approver. | Close recall còn recovery open; close residual risk thiếu note | TC-OP-RECALL-001, TC-OP-RECALL-RESIDUAL-001 |
| `misa_sync_event` | `PENDING`, `MAPPED`, `SYNCING`, `SYNCED`, `FAILED_RETRYABLE`, `FAILED_NEEDS_REVIEW`, `RECONCILED` | Module nghiệp vụ không sync trực tiếp; event đi qua layer. | Drop event khi mapping missing | TC-OP-MISA-001 |

## 3. Exception Flow Rules

| flow | Khi dùng | Quy tắc bắt buộc | Không được làm | Output | Test case |
| --- | --- | --- | --- | --- | --- |
| `HOLD` | Tạm giữ lot/batch/inventory/recall item để điều tra. | Có reason, actor, start time, affected object, audit; object bị block theo policy. | Không xóa hoặc sửa object gốc. | Hold registry/state transition. | TC-EXC-HOLD-001 |
| `HALT` | Dừng tạm production/packaging/print job đang chạy. | Có reason, current step, resume/cancel policy. | Không tự rollback ledger/QR đã posted. | Halt event + audit. | TC-EXC-HALT-001 |
| `CANCEL` | Hủy object chưa tạo side effect downstream. | Kiểm downstream side effect trước cancel; reason bắt buộc. | Không cancel object đã posted ledger/release/public QR mà không correction. | State `CANCELLED`. | TC-EXC-CANCEL-001 |
| `REJECT` | Từ chối approval/QC/source verification/release. | Reason bắt buộc; submission gốc read-only. | Không xóa submission gốc. | State `REJECTED` + audit. | TC-EXC-REJECT-001 |
| `ROLLBACK` | Hoàn tác transaction chưa externalized. | Chỉ áp dụng khi chưa posted ledger, chưa public QR, chưa MISA synced, chưa warehouse confirmed. | Không rollback silently sau khi đã externalized. | Rollback state hoặc compensation plan. | TC-EXC-ROLLBACK-001 |
| `CORRECTION` | Sửa sai sau khi đã confirmed/posted/signed. | Tạo record correction hoặc reversal link original, reason, approval nếu cần. | Không update trực tiếp audit/ledger/snapshot. | Correction/reversal record. | TC-EXC-CORR-001 |
| `OVERRIDE` | Bypass gate trong tình huống có thẩm quyền. | Break-glass permission, reason, audit, có thể yêu cầu dual approval. | Không override public/private data policy hoặc append-only rules. | Override action log. | TC-EXC-OVR-001 |

## 4. Operational Invariants

| invariant_id | Invariant | Applies to | Violation behavior |
| --- | --- | --- | --- |
| INV-001 | Research/baseline token lịch sử không là operational formula. | Recipe, PO, issue, trace, recall, seed | Reject command hoặc seed validation fail. |
| INV-002 | Production snapshot immutable. | Production order, print, trace | Không cho update in-place; correction phải tạo record riêng. |
| INV-003 | Ledger append-only. | Raw issue, warehouse receipt, adjustment, recall recovery | Không update/delete ledger posted; dùng reversal/adjustment. |
| INV-004 | `QC_PASS` khác `RELEASED`. | QC, release, warehouse | Warehouse receipt block nếu chưa release. |
| INV-005 | Public trace whitelist-only. | Public API, public UI | Fail closed hoặc minimal safe response nếu policy thiếu. |
| INV-006 | MISA chỉ là downstream integration. | MISA sync | Missing mapping không chặn nghiệp vụ đã posted, nhưng tạo sync error/reconcile. |
| INV-007 | Material issue decrement một lần. | Issue/receipt/inventory | Receipt confirmation không ghi decrement. |
| INV-008 | Recall snapshot không bị overwrite. | Recall impact | Re-run tạo snapshot version mới. |
| INV-009 | `READY_FOR_PRODUCTION` khác `QC_PASS`. | Raw lot, material issue | Lot `QC_PASS` nhưng chưa mark-ready bị reject với `LOT_NOT_READY_FOR_PRODUCTION`. |
| INV-010 | Inventory available không âm trong luồng thường. | Issue/allocation/balance | Reject với `INSUFFICIENT_BALANCE`, không post ledger debit. |
| INV-011 | Hold khác sale lock. | Recall, warehouse, commerce reference | Không dùng một flag chung thay thế hai registry. |
| INV-012 | Scan bắt buộc cho operation có rủi ro nhầm batch/lot. | Issue, receipt, warehouse, recall | Thiếu scan trả `BATCH_SCAN_REQUIRED`. |

## 5. Operational Validation Points

| checkpoint | Validation | Blocking? | Owner decision |
| --- | --- | --- | --- |
| Source origin verification | `SELF_GROWN` source origin = `VERIFIED` | Có | Đã chốt |
| Raw lot QC | QC result `QC_PASS` là prerequisite để mark-ready, không phải điều kiện issue cuối cùng | Có | Đã chốt |
| Raw lot readiness | Lot `READY_FOR_PRODUCTION` trước material issue | Có | Đã chốt |
| Recipe readiness | 20 SKU, G1 active, 4 groups, required ingredients | Có | Đã chốt |
| PO snapshot | Snapshot đủ fields và chỉ dùng operational baseline hợp lệ | Có | Đã chốt |
| Material issue | Lot `READY_FOR_PRODUCTION`, balance đủ, line thuộc snapshot, scan nếu operation yêu cầu | Có | Đã chốt |
| Process chain | Đúng thứ tự sơ chế/cấp đông/sấy thăng hoa | Có | Đã chốt |
| Release | QC pass + no hold + release approver | Có | Đã chốt |
| Warehouse receipt | Batch released | Có | Đã chốt |
| Trace | Chain đủ hoặc flag gap | Không luôn block, nhưng phải alert/audit | OD-TRACE-SLA còn mở |
| Recall | Impact snapshot + hold/sale lock | Có cho close | OD-RECALL-SLA cần chốt chi tiết |
| MISA sync | Mapping exists hoặc pending review | Không block operational truth | Credential thật còn mở |



