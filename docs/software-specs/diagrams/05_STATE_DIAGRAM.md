# 05 State Diagram

## 1. Mục tiêu

File này gom các state diagram quan trọng nhất từ workflow contract. Chi tiết đầy đủ nằm ở `workflows/04_STATE_MACHINES.md`; file này dùng để review nhanh các gate state chính.

## 2. Production / Material / Release State Overview

```mermaid
stateDiagram-v2
    state "Production Order" as PO {
        [*] --> PO_DRAFT
        PO_DRAFT --> PO_OPEN: create snapshot
        PO_OPEN --> PO_APPROVED: approve
        PO_APPROVED --> PO_IN_PROGRESS: start
        PO_IN_PROGRESS --> PO_ON_HOLD: hold
        PO_ON_HOLD --> PO_IN_PROGRESS: resume
        PO_IN_PROGRESS --> PO_COMPLETED: complete work
        PO_COMPLETED --> PO_CLOSED: close
    }

    state "Material Issue" as MI {
        [*] --> MI_DRAFT
        MI_DRAFT --> MI_PENDING_APPROVAL: submit
        MI_PENDING_APPROVAL --> MI_APPROVED: approve
        MI_APPROVED --> MI_EXECUTED: issue and decrement ledger
        MI_EXECUTED --> MI_REVERSED: approved reversal
    }

    state "Material Receipt" as MR {
        [*] --> MR_PENDING_CONFIRMATION
        MR_PENDING_CONFIRMATION --> MR_CONFIRMED: confirm receipt
        MR_CONFIRMED --> MR_VARIANCE_REVIEW: variance detected
        MR_VARIANCE_REVIEW --> MR_CONFIRMED: accept variance
    }

    state "Batch Release" as REL {
        [*] --> REL_PENDING
        REL_PENDING --> REL_APPROVED_RELEASED: approve release
        REL_PENDING --> REL_REJECTED: reject
        REL_APPROVED_RELEASED --> REL_REVOKED: revoke
    }
```

## 3. Raw Lot / QR / Trace / Recall / MISA State Overview

```mermaid
stateDiagram-v2
    state "Raw Material Lot" as RML {
        [*] --> CREATED
        CREATED --> IN_QC: submit for QC
        IN_QC --> READY_FOR_PRODUCTION: QC_PASS + mark_ready
        IN_QC --> ON_HOLD: QC_HOLD
        IN_QC --> REJECTED: QC_REJECT
        ON_HOLD --> IN_QC: re-inspect
        ON_HOLD --> REJECTED: reject after investigation
        READY_FOR_PRODUCTION --> CONSUMED: issue executed
        READY_FOR_PRODUCTION --> ON_HOLD: operational hold
        READY_FOR_PRODUCTION --> EXPIRED: expiry check
        READY_FOR_PRODUCTION --> QUARANTINED: safety/legal quarantine
        QUARANTINED --> READY_FOR_PRODUCTION: quarantine release + readiness still valid
        QUARANTINED --> ON_HOLD: convert to investigation hold
    }

    state "QR Lifecycle" as QR {
        [*] --> GENERATED
        GENERATED --> QUEUED: queue print
        QUEUED --> PRINTED: print success
        QUEUED --> FAILED: print failure
        FAILED --> QUEUED: retry
        FAILED --> VOID: void failed QR
        PRINTED --> REPRINTED: reprint
        REPRINTED --> PRINTED: replacement confirmed
        PRINTED --> VOID: void
    }

    state "Trace" as TR {
        [*] --> NOT_BUILT
        NOT_BUILT --> BUILDING
        BUILDING --> COMPLETE
        BUILDING --> GAP_DETECTED
        COMPLETE --> PUBLISHED_PUBLIC
        GAP_DETECTED --> REVIEW_REQUIRED
        REVIEW_REQUIRED --> BUILDING: rebuild after correction
    }

    state "Recall" as RC {
        [*] --> OPEN
        OPEN --> IMPACT_ANALYSIS
        IMPACT_ANALYSIS --> HOLD_ACTIVE
        HOLD_ACTIVE --> SALE_LOCK_ACTIVE
        SALE_LOCK_ACTIVE --> RECOVERY
        RECOVERY --> DISPOSITION
        DISPOSITION --> CAPA
        CAPA --> CLOSED: clean CAPA evidence
        CAPA --> CLOSED_WITH_RESIDUAL_RISK: clean evidence + accepted residual risk
        CLOSED --> [*]
        CLOSED_WITH_RESIDUAL_RISK --> [*]
    }

    state "MISA Sync" as MS {
        [*] --> PENDING
        PENDING --> MAPPED
        PENDING --> FAILED_NEEDS_REVIEW: mapping missing
        MAPPED --> SYNCING
        SYNCING --> SYNCED
        SYNCING --> FAILED_RETRYABLE
        FAILED_RETRYABLE --> SYNCING: retry
        FAILED_NEEDS_REVIEW --> RECONCILED
    }
```

## 4. Liên kết triển khai

| State diagram | Module | Workflow | API | Tables |
|---|---|---|---|---|
| Production Order | M07 | WF-M07-PO | `/api/admin/production/orders`, `/api/admin/production/orders/{id}/approve` | `op_production_order`, `op_production_order_item` |
| Material Issue | M08/M11 | WF-M08-ISSUE | `/api/admin/production/material-issues/{id}/execute` | `op_material_issue`, `op_inventory_ledger` |
| Material Receipt | M08 | WF-M08-RECEIPT | `/api/admin/production/material-receipts` | `op_material_receipt`, `op_material_receipt_variance` |
| Batch Release | M09 | WF-M09-RELEASE | `/api/admin/qc/releases`, `/api/admin/qc/releases/{id}/approve` | `op_batch_release` |
| Raw Material Lot | M06/M09 | WF-M06-QC, WF-M06-READINESS | `/api/admin/raw-material/lots/{lotId}/qc-inspections`, `/api/admin/raw-material/lots/{lotId}/readiness` | `op_raw_material_lot`, `op_raw_material_qc_inspection`, `state_transition_log` |
| QR Lifecycle | M10/M12 | WF-M10-QR | `/api/admin/qr/generate`, `/api/admin/printing/jobs` | `op_qr_registry`, `op_qr_state_history` |
| Trace | M12 | WF-M12-INTERNAL, WF-M12-PUBLIC | `/api/admin/trace/search`, `/api/public/trace/{qrCode}` | `op_trace_link`, `vw_public_traceability` |
| Recall | M13 | WF-M13-RECALL | `/api/admin/recall/cases/*`, `/api/admin/recall/capas/{capaId}/evidence` | `op_recall_case`, `op_recall_exposure_snapshot`, `op_recall_capa`, `op_recall_capa_evidence` |
| MISA Sync | M14 | WF-M14-SYNC | `/api/admin/integrations/misa/*` | `misa_sync_event`, `misa_reconcile_record` |

## 5. Critical gates

| Gate | Rule |
|---|---|
| Material issue | Raw lot must be `READY_FOR_PRODUCTION`, available, not held. `QC_PASS` is prerequisite only. |
| Ledger | Issue posts decrement once; receipt does not decrement again. |
| Recall close | Recovery/CAPA must be closed and CAPA evidence must include at least 1 `CLEAN` scan metadata row. |
| Release | `QC_PASS` is prerequisite only; batch release approval is separate. |
| Warehouse | Warehouse receipt requires `APPROVED_RELEASED` batch. |
| Public trace | Only `PUBLISHED_PUBLIC` response uses whitelist fields. |
| MISA | Sync failure goes through retry/reconcile, never direct module sync. |
