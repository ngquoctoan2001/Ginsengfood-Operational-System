# 07 UI State And Validation

## 1. Mục tiêu

Tài liệu này định nghĩa state UI, validation client-side, lỗi server-side và hành vi khi command thay đổi trạng thái nghiệp vụ. UI validation chỉ giúp UX; backend/database vẫn là nguồn enforce cuối cùng.

## 2. UI State Chuẩn

| state | Khi nào xảy ra | UI behavior | API/BE expectation |
|---|---|---|---|
| `idle` | Chưa fetch hoặc form chưa thay đổi | Hiển thị route shell hoặc form default | Không gọi command |
| `loading` | Đang fetch data | Skeleton/table loading; disable command | API GET đang xử lý |
| `loaded` | Data fetch thành công | Hiển thị data và action theo permission/state | Response có `data`, `meta` nếu list |
| `empty_first` | Chưa có data trong module | Hiển thị empty message và create action nếu có quyền | API trả list rỗng |
| `empty_filter` | Filter không có kết quả | Hiển thị clear filter | API trả list rỗng với filter |
| `dirty` | Form có thay đổi chưa lưu | Enable save/cancel; cảnh báo khi rời trang | Không tự submit |
| `validating` | Đang validate async | Disable submit field liên quan | Có thể gọi uniqueness/lookup API nếu được chấp nhận |
| `validation_error` | Client hoặc server trả lỗi field | Highlight field; show error summary | API trả `VALIDATION_ERROR` |
| `permission_denied` | User thiếu quyền view/action | Hide action hoặc show denied page | Backend trả `FORBIDDEN` nếu gọi API |
| `command_confirm` | Action cần xác nhận | Modal confirmation, reason nếu bắt buộc | Chưa gọi API |
| `command_pending` | Đang submit command | Disable submit; show spinner; giữ idempotency key | API xử lý command |
| `command_success` | Command thành công | Toast + reload record/list | API trả state mới |
| `command_failed` | Command lỗi | Show error code/message; giữ form input nếu an toàn | API trả error chuẩn |
| `stale_state` | Record state đổi giữa lúc user thao tác | Reload record; yêu cầu user thử lại | API trả `STALE_STATE` hoặc `INVALID_STATE_TRANSITION` |
| `offline_queued` | PWA offline command đã queue | Show pending sync badge | Command có `Idempotency-Key` |
| `sync_failed` | Offline/MISA/outbox sync lỗi | Show retry if allowed | API trả retryable status |
| `break_glass_active` | Override/break-glass đã được duyệt và còn TTL | Hiển thị scope, expiry countdown, audit warning; chỉ enable action trong scope | Backend enforce scope/TTL/permission |
| `break_glass_expired` | Override/break-glass hết TTL hoặc bị revoke | Disable privileged action; yêu cầu request mới | API trả `OVERRIDE_EXPIRED` nếu user vẫn gọi command |
| `partial_trace` | Trace/genealogy thiếu một phần | Warning banner; không suy diễn quan hệ | API trả partial flag/warning |

## 3. Validation Nguyên Tắc Chung

| Rule | Client validation | Server validation |
|---|---|---|
| Required field | Có | Có |
| Type/format | Có với code/date/number/email | Có |
| Unique code | Có thể pre-check nếu API hỗ trợ; không bắt buộc | Có |
| Permission | Hide/disable action | Có |
| State transition | Hide/disable action theo current state | Có |
| Inventory balance | Chỉ pre-check từ data hiện tại | Có, trong transaction |
| QC/release gate | Disable action nếu data hiện tại rõ ràng không đạt | Có |
| Public trace field policy | Không render forbidden fields | Có, whitelist response |
| Idempotency | Generate/reuse key per command attempt | Có |
| Concurrency | Reload before command nếu data cũ | Có qua version/updated_at/state check |

## 4. Validation Theo Nghiệp Vụ Trọng Yếu

| validation_id | module | rule | UI validation | API error expected | test case |
|---|---|---|---|---|---|
| UI-VAL-REC-001 | M04 Recipe | Công thức vận hành bắt đầu từ G1, không có non-operational baseline trong active flow | Không hiển thị lựa chọn version cũ không active | `NON_OPERATIONAL_RECIPE_VERSION`, `RECIPE_VERSION_INVALID` | TC-UI-REC-001 |
| UI-VAL-REC-002 | M04 Recipe | Recipe line chỉ thuộc 4 group chuẩn | Select chỉ có 4 group | `INVALID_RECIPE_GROUP` | TC-UI-REC-002 |
| UI-VAL-REC-003 | M04 Recipe | Active recipe cần approval và effective date | Disable activate khi thiếu approval/effective_date | `APPROVAL_REQUIRED`, `EFFECTIVE_DATE_REQUIRED` | TC-UI-REC-003 |
| UI-VAL-SRC-001 | M05 Source Origin | Source origin verify/reject cần role và reason khi reject | Show reject reason field | `FORBIDDEN`, `REJECT_REASON_REQUIRED` | TC-UI-SRC-002 |
| UI-VAL-RM-001 | M06 Raw Material | Raw intake quantity > 0 | Numeric min > 0 | `VALIDATION_ERROR` | TC-UI-RM-001 |
| UI-VAL-RM-002 | M06 Raw Material | Raw intake dùng source origin verified nếu policy yêu cầu | Combobox filter verified only | `SOURCE_ORIGIN_NOT_VERIFIED` | TC-UI-RM-002 |
| UI-VAL-RM-003 | M06 Raw Material | Raw lot mark-ready chỉ chuyển sang `READY_FOR_PRODUCTION` sau `QC_PASS` và không hold/reject/quarantine | Show Mark Ready only with `qcStatus=QC_PASS` and not ready/held/rejected | `RAW_MATERIAL_LOT_QC_NOT_PASSED`, `LOT_QUARANTINED`, `STATE_CONFLICT` | TC-UI-RM-READY-001 |
| UI-VAL-QC-001 | M09 QC | HOLD/REJECT bắt buộc note | Note required when result not PASS | `QC_NOTE_REQUIRED` | TC-UI-QC-001 |
| UI-VAL-PO-001 | M07 Production | Production order cần active recipe version | Disable create/start nếu lookup thiếu recipe | `RECIPE_ACTIVE_VERSION_MISSING` | TC-UI-PO-001 |
| UI-VAL-PO-002 | M07 Production | Snapshot immutable sau start | Fields readonly after start | `SNAPSHOT_IMMUTABLE` | TC-UI-PO-002 |
| UI-VAL-MI-001 | M08 Material Issue | Material issue line phải thuộc snapshot | UI line source từ snapshot only | `OUTSIDE_SNAPSHOT_MATERIAL` | TC-UI-MI-001 |
| UI-VAL-MI-002 | M08 Material Issue | Raw lot phải `READY_FOR_PRODUCTION`; `QC_PASS` alone is insufficient | Lot selector filter `lotStatus=READY_FOR_PRODUCTION` | `RAW_MATERIAL_LOT_NOT_READY` | TC-UI-MI-002 |
| UI-VAL-MI-003 | M08 Material Issue | Không issue vượt available balance | Show available_qty, prevent obvious over-issue | `INSUFFICIENT_INVENTORY` | TC-UI-MI-003 |
| UI-VAL-MR-001 | M08 Material Receipt | Variance cần reason | Reason required if received != issued | `VARIANCE_REASON_REQUIRED` | TC-UI-MRCP-001 |
| UI-VAL-REL-001 | M09 Release | `QC_PASS` không tự là `RELEASED` | Release button riêng cho QA Manager | `BATCH_NOT_QC_PASS`, `RELEASE_REQUIRED` | TC-UI-REL-001 |
| UI-VAL-WH-001 | M11 Warehouse | Warehouse receipt chỉ cho batch `RELEASED` | Batch selector filter `RELEASED` | `BATCH_NOT_RELEASED` | TC-UI-WH-001 |
| UI-VAL-QR-001 | M10 QR | QR lifecycle phải hợp lệ | Disable invalid lifecycle buttons | `INVALID_QR_STATE_TRANSITION` | TC-UI-QR-001 |
| UI-VAL-QR-002 | M10 QR | Void/reprint bắt buộc reason | Reason modal required | `REASON_REQUIRED` | TC-UI-QR-002 |
| UI-VAL-TRACE-001 | M12 Trace | Public trace không expose internal fields | Public DTO whitelist; ignore unknown forbidden fields | `PUBLIC_FIELD_POLICY_VIOLATION` | TC-UI-PTR-002 |
| UI-VAL-RECALL-001 | M13 Recall | Hold/sale lock cần target và reason | Require target/reason | `REASON_REQUIRED` | TC-UI-HOLD-001 |
| UI-VAL-MISA-001 | M14 MISA | Sync phải qua integration layer và mapping | UI chỉ có MISA console; không có module direct sync button | `MISA_MAPPING_MISSING`, `DIRECT_SYNC_FORBIDDEN` | TC-UI-MISA-001 |

## 5. State-Driven Action Matrix

| Entity | State | Allowed UI actions | Forbidden UI actions |
|---|---|---|---|
| Recipe | DRAFT | edit lines, submit | activate, production use |
| Recipe | PENDING_APPROVAL | approve, reject, view | edit lines, activate before approval |
| Recipe | APPROVED | activate, retire if active conflict resolved | edit lines |
| Recipe | ACTIVE | retire, view | edit lines, delete |
| Source Origin | DRAFT | edit, submit verify | use in controlled intake if verification required |
| Source Origin | PENDING_VERIFY | verify, reject | edit core fields without correction approval |
| Source Origin | VERIFIED | use in intake, view | delete |
| Raw Lot | QC_PENDING / IN_QC | create QC, hold | material issue, mark ready |
| Raw Lot | QC_PASS but not READY_FOR_PRODUCTION | mark ready, trace, hold | material issue |
| Raw Lot | READY_FOR_PRODUCTION | material issue, trace, hold | mark ready again, reject without controlled correction |
| Raw Lot | QC_HOLD / ON_HOLD / REJECTED / QUARANTINED | release hold or controlled correction if policy allows, trace | material issue, mark ready |
| Raw Lot | CONSUMED / EXPIRED | trace, view ledger | material issue, mark ready |
| Production Order | DRAFT/PLANNED | edit, start, cancel | issue material before approval if policy requires |
| Production Order | STARTED | create material request, view snapshot, close when complete | edit snapshot |
| Material Issue | OPEN/APPROVED | issue, cancel | confirm receipt |
| Material Issue | ISSUED | view, create/confirm receipt | issue again unless API supports partial issue |
| Material Receipt | PENDING | confirm, cancel | close batch |
| QC Inspection | OPEN | record result | release batch |
| Batch | QC_PASS | create release action | warehouse receipt before release |
| Batch | RELEASED | warehouse receipt, packaging | mutate release record |
| QR | GENERATED | queue print, void | mark printed |
| QR | QUEUED | mark printed, failed, void | reprint |
| QR | PRINTED | reprint, void, public trace preview | regenerate same QR |
| QR | FAILED | retry/queue, void | public trace as printed if not printed |
| QR | VOID | view audit | print/reprint |
| Recall Case | DRAFT | edit, submit/approve | hold if not approved [OWNER DECISION NEEDED] |
| Recall Case | ACTIVE | impact analysis, hold, sale lock, recovery | delete |
| Recall Case | CLOSED | view, export audit | mutate case, close with residual risk |
| Recall Case | CLOSED_WITH_RESIDUAL_RISK | view, export audit, show residual risk warning | mutate case, hide residual note |
| MISA Sync Job | FAILED/RETRYABLE | retry, view error | direct module sync |

## 6. Public Trace UI Rules

| Rule | UI behavior |
|---|---|
| Public client only | Public page imports only `publicTraceClient` and public DTO. |
| No admin token dependency | Public page must not require admin auth. |
| Whitelist render | Render only explicit allowed fields from `PublicTraceResponse`. |
| Forbidden field ignore | If response unexpectedly contains forbidden keys, UI must not render them. Admin preview may flag violation. |
| Safe errors | Not found/void/recalled messages must be public-safe and not reveal internal incident details. |
| No export/debug | Public page must not show raw JSON/debug panel. |

## 7. Idempotency UI Behavior

| Scenario | Required behavior |
|---|---|
| User double-clicks submit | Same `Idempotency-Key` reused; button disabled while pending. |
| Network timeout after command | UI retries status lookup before re-submitting; if re-submit needed, reuse same key for same attempt. |
| User changes form after failed validation | Generate new key only after command payload changes materially. |
| PWA offline queue | Store command payload + idempotency key + created_at + target endpoint; sync in order. |
| Command returns idempotency conflict | Show clear message; do not silently submit with new key unless user starts a new command. |

## 8. Error Display Mapping

| API error code | UI behavior |
|---|---|
| `VALIDATION_ERROR` | Show field-level errors and summary. |
| `FORBIDDEN` | Hide action after reload; show permission denied message. |
| `INVALID_STATE_TRANSITION` | Show stale/action no longer available; reload record. |
| `STALE_STATE` | Reload record and ask user to retry if still valid. |
| `RECIPE_ACTIVE_VERSION_MISSING` | Link to recipe screen if user has permission. |
| `RAW_MATERIAL_LOT_NOT_READY` | Show lot readiness status, link to Lot Readiness screen, and explain `QC_PASS` alone is insufficient. |
| `RAW_MATERIAL_LOT_QC_NOT_PASSED` | Show lot QC status and link to QC screen. |
| `LOT_QUARANTINED` | Show hold/quarantine detail and disable issue/mark-ready. |
| `INSUFFICIENT_BALANCE` | Show available balance and lot selector. |
| `BATCH_NOT_RELEASED` | Link to release queue if permitted. |
| `RECALL_RESIDUAL_RISK_NOTE_REQUIRED` | Focus residual note field in close-with-residual-risk modal. |
| `PUBLIC_FIELD_POLICY_VIOLATION` | In admin preview show blocking violation; public page suppresses forbidden data. |
| `MISA_MAPPING_MISSING` | Link to MISA mapping screen. |
| `MISA_SYNC_FAILED` | Show retry if permission and retryable. |

## 9. Done Gate

- Every mutate action has loading/success/error/stale state.
- Every reject/cancel/hold/reprint/override flow captures reason.
- UI does not rely on client-side validation as final source of truth.
- Public trace uses whitelist-only rendering and suppresses forbidden fields.
