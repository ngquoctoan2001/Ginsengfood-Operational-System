# 07 Exception Flows

## 1. Mục tiêu

Tài liệu này chuẩn hóa các luồng lỗi và ngoại lệ bắt buộc: cancel, reject, hold, halt, void, reprint, retry, reconcile, override, rollback và correction. Các luồng này không được cập nhật âm thầm vào record gốc nếu record đã signed/posted/released/printed/synced.

## 2. Exception Flow Catalog

| exception_id | Flow | Khi dùng | Actor | State impact | Required data | Forbidden behavior | API/UI anchor | Test |
|---|---|---|---|---|---|---|---|---|
| EX-CANCEL-001 | Cancel | Hủy object chưa có downstream irreversible side effect | Creator/Manager by permission | `-> CANCELLED` | reason, actor, timestamp | Không cancel ledger posted/released/public QR without correction | All relevant command APIs; UI action per screen | TC-EXC-CANCEL-001 |
| EX-REJECT-001 | Reject | Từ chối approval, source verification, QC/release, material request | Approver/QA | `PENDING -> REJECTED` | reason required | Không xóa submission gốc | Approval APIs; SCR-APPROVAL-QUEUE | TC-EXC-REJECT-001 |
| EX-HOLD-001 | Hold | Tạm giữ lot/batch/inventory/recall target | QA/Warehouse/Recall roles | `-> ON_HOLD`, `QC_HOLD`, `HOLD_ACTIVE` | reason, target, scope, expected review | Không cho issue/release/ship khi hold active | Recall hold, raw lot hold, release gate | TC-EXC-HOLD-001 |
| EX-LOT-READY-REV-001 | Lot readiness reversal | Lot đã `READY_FOR_PRODUCTION` nhưng phát hiện contamination, expiry, source issue hoặc QC correction | QA Manager / Warehouse Manager | `READY_FOR_PRODUCTION -> ON_HOLD/QUARANTINED/EXPIRED` | reason, evidence, scope, related QC/source finding | Không sửa/xóa QC pass record; không cho issue sau reversal | `POST /api/admin/raw-material/lots/{id}/hold` or readiness reversal command [OWNER DECISION NEEDED exact route] | TC-EXC-LOT-READY-REV-001 |
| EX-HALT-001 | Halt | Dừng tạm production/packaging/print đang chạy | Production/Packaging Manager | `IN_PROGRESS -> ON_HOLD/HALTED` | reason, current step, safe resume point | Không rollback ledger/print đã posted | Production/process/packaging screens | TC-EXC-HALT-001 |
| EX-VOID-001 | Void QR/print | Vô hiệu QR/print trước hoặc sau in | Packaging Operator/QA | QR/print `-> VOID` | reason, QR/print id | Không xóa QR history | `POST /api/admin/printing/jobs/*`, QR commands [OWNER DECISION NEEDED exact path] | TC-EXC-VOID-001 |
| EX-REPRINT-001 | Reprint | In lại QR/label vì lỗi vật lý hoặc sai tem | Packaging Operator/QA | `PRINTED -> REPRINTED` then replacement `PRINTED` | reason, original print ref, new print job | Không reuse history như lần in đầu | `POST /api/admin/printing/jobs/{id}/reprint` | TC-EXC-REPRINT-001 |
| EX-RETRY-001 | Retry | Retry outbox/MISA/print/offline sync lỗi retryable | Integration/Packaging/System | `FAILED_RETRYABLE -> SYNCING/QUEUED` | reason for manual retry if required, retry count | Không retry vô hạn | MISA retry, outbox retry, print retry | TC-EXC-RETRY-001 |
| EX-RECON-001 | Reconcile | Đối soát mismatch MISA hoặc external result | Integration Operator | `FAILED_NEEDS_REVIEW -> RECONCILED` | mismatch type, resolution, reason | Không sửa nghiệp vụ gốc để khớp external nếu không có correction | `POST /api/admin/integrations/misa/sync-events/{id}/reconcile` | TC-EXC-RECON-001 |
| EX-OVERRIDE-001 | Override | Break-glass khi gate cần bypass có kiểm soát | Admin/dual approver [OWNER DECISION NEEDED] | controlled transition | reason, scope, expiry, approval | Không override public field policy, append-only ledger/audit, release gate without trace | Endpoint per module [OWNER DECISION NEEDED] | TC-EXC-OVR-001 |
| EX-ROLLBACK-001 | Rollback | Hoàn tác command chưa externalized | System/Admin | `-> CANCELLED` or rollback pending state | original command, reason | Không rollback silently sau ledger posted, QR public, MISA synced | Idempotency registry/correction flow | TC-EXC-ROLLBACK-001 |
| EX-CORR-001 | Correction | Sửa sai record signed/posted/confirmed | Authorized role | `-> CORRECTED` plus new correction/reversal | reason, original ref, new value, approval if needed | Không update in-place ledger/audit/snapshot | Adjustment/correction APIs | TC-EXC-CORR-001 |

## 3. Cancel Flow

```mermaid
flowchart TD
    A[User requests cancel] --> B[Load current state]
    B --> C{Irreversible side effect exists?}
    C -- No --> D[Require reason]
    D --> E[Set CANCELLED]
    E --> F[Append audit]
    C -- Yes --> G[Block cancel]
    G --> H[Suggest correction/reversal flow]
```

| Object | Cancellable before | Not cancellable after |
|---|---|---|
| Source origin | Before verification if no dependent intake | Verified and used by raw lot without correction |
| Raw intake | Before confirmed lot/QC | Lot QC signed or issued |
| Production order | Before material issue/irreversible batch execution | Material issue executed, ledger posted |
| Material request | Before issue executed | Issue executed |
| Material receipt | Before confirmation | Confirmed with downstream batch execution |
| Warehouse receipt | Before confirmation and before FG ledger posted | FG ledger posted; use correction/reversal |
| Print job | Before printed | Printed QR public unless void/reprint |

## 4. Reject Flow

```mermaid
flowchart TD
    A[Approver clicks reject] --> B{Reason entered?}
    B -- No --> C[Show REASON_REQUIRED]
    B -- Yes --> D[Validate pending state]
    D --> E{Pending?}
    E -- No --> F[STATE_CONFLICT and reload]
    E -- Yes --> G[Set REJECTED]
    G --> H[Append audit and notify submitter]
```

Reject applies to source verification, recipe approval, production order approval if enabled, material request, batch release, inventory adjustment, recall approval and MISA reconcile review.

## 5. Hold Flow

```mermaid
flowchart TD
    A[User applies hold] --> B[Select target: lot/batch/inventory/recall]
    B --> C[Enter reason and scope]
    C --> D[System blocks configured downstream actions]
    D --> E[Append hold registry and audit]
    E --> F{Investigation complete?}
    F -- No --> D
    F -- Yes --> G[Release hold with reason/approval]
```

| Hold target | Blocks |
|---|---|
| Raw material lot | Material issue |
| Batch | Release, warehouse receipt, public trace if policy requires |
| Inventory lot balance | Allocation/shipment/warehouse actions according scope |
| Recall exposure target | Sale/shipment and possibly public status |

## 6. Lot Readiness Reversal Flow

```mermaid
flowchart TD
    A[Issue found on READY_FOR_PRODUCTION lot] --> B[QA/Warehouse opens readiness reversal]
    B --> C[Capture reason, evidence, affected scope]
    C --> D{Already issued or consumed?}
    D -- Yes --> E[Block simple reversal; open correction/recall/hold workflow]
    D -- No --> F[Move lot to ON_HOLD or QUARANTINED]
    F --> G[Append state transition and audit]
    G --> H[Material issue selection no longer includes lot]
```

Reversal must not mutate the signed QC inspection. If the lot has already been issued, use correction/reversal, trace and recall impact workflows instead of silently changing history.

## 7. Halt Flow

```mermaid
flowchart TD
    A[Production/packaging in progress] --> B[Operator reports issue]
    B --> C[Manager halts process]
    C --> D[Record current step, reason, evidence]
    D --> E{Resume possible?}
    E -- Yes --> F[Resume from safe point]
    E -- No --> G[Cancel or correction flow]
```

Halt is temporary. It must not automatically reverse material issue, ledger, QR or release records.

## 8. Void And Reprint Flow

```mermaid
flowchart TD
    A[QR/print issue identified] --> B{Need void or reprint?}
    B -- Void --> C[Require void reason]
    C --> D[Set QR/print VOID]
    D --> E[Public trace returns safe invalid/void status]
    B -- Reprint --> F[Require reprint reason]
    F --> G[Create reprint job]
    G --> H{Print success?}
    H -- No --> I[FAILED; retry or void]
    H -- Yes --> J[State REPRINTED/PRINTED and append history]
```

Forbidden:

- Không xóa QR gốc.
- Không tái sử dụng print history như lần in đầu.
- Không expose lý do lỗi nội bộ ra public trace.

## 9. Retry Flow

```mermaid
flowchart TD
    A[Job/event failed] --> B{Retryable?}
    B -- No --> C[FAILED_NEEDS_REVIEW]
    B -- Yes --> D[FAILED_RETRYABLE]
    D --> E{Retry count within policy?}
    E -- No --> C
    E -- Yes --> F[Retry with same logical event/idempotency context]
    F --> G{Success?}
    G -- Yes --> H[SYNCED/PRINTED/DISPATCHED]
    G -- No --> D
```

Retry applies to MISA sync, outbox event, print job and PWA offline submissions. Retry must preserve idempotency/correlation metadata.

## 10. Reconcile Flow

```mermaid
flowchart TD
    A[MISA mismatch or missing mapping] --> B[Integration Operator opens reconcile]
    B --> C[Review local record and external status]
    C --> D{Resolution type}
    D -- Add mapping --> E[Upsert mapping]
    D -- Accept external ref --> F[Store external reference]
    D -- Mark resolved --> G[Record reason]
    E --> H[Retry sync]
    F --> I[Set RECONCILED]
    G --> I
```

Reconcile must not mutate operational truth just to match external system. If local operational data is wrong, use correction workflow first.

## 11. Override Flow

```mermaid
flowchart TD
    A[Blocked command] --> B[User requests override]
    B --> C[Capture reason, scope, expiry]
    C --> D{Override allowed for this rule?}
    D -- No --> E[Reject override]
    D -- Yes --> F[Approval / dual approval]
    F --> G{Approved?}
    G -- No --> E
    G -- Yes --> H[Execute controlled transition]
    H --> I[Append override audit]
```

Never override:

- Public/private field policy for public trace.
- Append-only ledger/audit/history behavior.
- Direct MISA sync from business modules.
- Recipe snapshot immutability for historical production orders.
- Raw lot readiness/issue gate after a lot is held, quarantined, expired or not `READY_FOR_PRODUCTION`.

## 12. Correction / Reversal Flow

```mermaid
flowchart TD
    A[Error found after signed/posted/confirmed] --> B[Open correction request]
    B --> C[Reference original record]
    C --> D[Enter reason and corrected data]
    D --> E{Requires approval?}
    E -- Yes --> F[Approval workflow]
    E -- No --> G[Create correction/reversal record]
    F --> G
    G --> H[Append audit and recompute projection if needed]
```

| Original record | Correction pattern |
|---|---|
| Inventory ledger | Reversal/adjustment ledger entry |
| Material issue | Reversal issue/correction linked to original |
| Material receipt | Correction receipt/variance review |
| QC inspection | Corrected inspection record; original stays signed |
| Batch release | Revoke/re-release record |
| Warehouse receipt | Correction/reversal entry |
| Recall impact | New impact snapshot version |
| MISA sync | Reconcile record and optional retry |

## 13. Done Gate

- `cancel`, `reject`, `hold`, `lot readiness reversal`, `halt`, `void`, `reprint`, `retry`, `reconcile`, `override`, `rollback`, `correction` all have rules and diagrams.
- Every exception requires reason when changing business state.
- No exception flow mutates append-only records in place.
- Public trace and MISA boundary remain protected.
