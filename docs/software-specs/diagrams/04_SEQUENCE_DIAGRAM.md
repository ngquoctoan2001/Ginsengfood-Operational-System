# 04 Sequence Diagram

## 1. Mục tiêu

Diagram này mô tả sequence E2E smoke cho chuỗi vận hành canonical, tập trung vào API/service boundaries và các điểm bắt buộc: snapshot G1, material issue decrement, release gate, public trace whitelist và MISA integration layer.

## 2. Mermaid Diagram

```mermaid
sequenceDiagram
    autonumber
    actor QA as QA/E2E Runner
    participant AdminUI as Admin/PWA UI
    participant SourceAPI as M05 Source Origin API
    participant RawAPI as M06 Raw Material API
    participant RecipeAPI as M04 Recipe API
    participant ProdAPI as M07 Production API
    participant MaterialAPI as M08 Material API
    participant InvAPI as M11 Inventory API
    participant QrAPI as M10 QR/Print API
    participant QcAPI as M09 QC/Release API
    participant TraceAPI as M12 Trace API
    participant RecallAPI as M13 Recall API
    participant MisaAPI as M14 MISA API

    QA->>AdminUI: Start smoke dataset
    AdminUI->>SourceAPI: POST /api/admin/source-origins
    SourceAPI-->>AdminUI: source origin SUBMITTED
    AdminUI->>SourceAPI: POST /api/admin/source-origins/{id}/verify
    SourceAPI-->>AdminUI: source origin VERIFIED

    AdminUI->>RawAPI: POST /api/admin/raw-material/intakes
    RawAPI-->>AdminUI: raw lot PENDING_QC
    AdminUI->>RawAPI: POST /api/admin/raw-material/lots/{lotId}/qc-inspections
    RawAPI-->>AdminUI: raw lot QC_PASS
    AdminUI->>RawAPI: POST /api/admin/raw-material/lots/{lotId}/readiness
    RawAPI-->>AdminUI: raw lot READY_FOR_PRODUCTION

    AdminUI->>RecipeAPI: GET /api/admin/recipes?sku=&status=ACTIVE_OPERATIONAL
    RecipeAPI-->>AdminUI: active G1 recipe with 4 groups
    AdminUI->>ProdAPI: POST /api/admin/production/orders
    ProdAPI-->>AdminUI: PO with immutable recipe snapshot
    AdminUI->>ProdAPI: POST /api/admin/production/orders/{id}/approve
    ProdAPI-->>AdminUI: PO APPROVED

    AdminUI->>MaterialAPI: POST /api/admin/production/material-requests
    MaterialAPI-->>AdminUI: material request PENDING_APPROVAL
    AdminUI->>MaterialAPI: POST /api/admin/production/material-requests/{id}/approve
    MaterialAPI-->>AdminUI: material request APPROVED
    AdminUI->>MaterialAPI: POST /api/admin/production/material-issues/{id}/execute with Idempotency-Key
    MaterialAPI->>InvAPI: post raw material decrement ledger
    InvAPI-->>MaterialAPI: ledger posted once
    MaterialAPI-->>AdminUI: material issue EXECUTED
    AdminUI->>MaterialAPI: POST /api/admin/production/material-receipts
    MaterialAPI-->>AdminUI: material receipt CONFIRMED

    AdminUI->>ProdAPI: POST /api/admin/production/process-events
    ProdAPI-->>AdminUI: batch/process complete
    AdminUI->>QrAPI: POST /api/admin/packaging/jobs
    QrAPI-->>AdminUI: packaging job ready
    AdminUI->>QrAPI: POST /api/admin/qr/generate
    QrAPI-->>AdminUI: QR GENERATED
    AdminUI->>QrAPI: POST /api/admin/printing/jobs
    QrAPI-->>AdminUI: QR PRINTED or FAILED

    AdminUI->>QcAPI: POST /api/admin/qc/inspections
    QcAPI-->>AdminUI: QC_PASS
    AdminUI->>QcAPI: POST /api/admin/qc/releases
    QcAPI-->>AdminUI: release request PENDING
    AdminUI->>QcAPI: POST /api/admin/qc/releases/{batchReleaseId}/approve
    QcAPI-->>AdminUI: batch APPROVED_RELEASED
    AdminUI->>InvAPI: POST /api/admin/warehouse/receipts
    InvAPI-->>AdminUI: FG ledger and balance posted

    AdminUI->>TraceAPI: GET /api/admin/trace/search
    TraceAPI-->>AdminUI: internal genealogy chain
    QA->>TraceAPI: GET /api/public/trace/{qrCode}
    TraceAPI-->>QA: PublicTraceResponse whitelist-only

    opt Recall extension
        AdminUI->>RecallAPI: POST /api/admin/incidents
        RecallAPI-->>AdminUI: incident opened
        AdminUI->>RecallAPI: POST /api/admin/recall/cases/{id}/impact-analysis
        RecallAPI->>TraceAPI: build exposure from genealogy
        TraceAPI-->>RecallAPI: exposure snapshot inputs
        RecallAPI-->>AdminUI: impact snapshot
        AdminUI->>RecallAPI: POST hold / sale-lock / close
        RecallAPI-->>AdminUI: recall lifecycle updated
    end

    AdminUI->>MisaAPI: GET /api/admin/integrations/misa/sync-events
    MisaAPI-->>AdminUI: SYNCED or FAILED_NEEDS_REVIEW or RECONCILED
```

## 3. Liên kết triển khai

| Sequence segment | Module | Workflow | API | Tables |
|---|---|---|---|---|
| Source verify | M05 | WF-M05-VERIFY | `/api/admin/source-origins`, `/api/admin/source-origins/{id}/verify` | `op_source_origin`, `op_source_origin_verification` |
| Raw intake/QC/readiness | M06/M09 | WF-M06-INTAKE, WF-M06-QC, WF-M06-READINESS | `/api/admin/raw-material/intakes`, `/api/admin/raw-material/lots/{lotId}/qc-inspections`, `/api/admin/raw-material/lots/{lotId}/readiness` | `op_raw_material_lot`, `op_raw_material_qc_inspection`, `state_transition_log` |
| Recipe snapshot | M04/M07 | WF-M04-SNAPSHOT, WF-M07-PO | `/api/admin/recipes`, `/api/admin/production/orders` | `op_production_recipe`, `op_production_order_item` |
| Material issue decrement | M08/M11 | WF-M08-ISSUE, WF-M11-LEDGER | `/api/admin/production/material-issues/{id}/execute` | `op_material_issue`, `op_inventory_ledger` |
| Receipt confirmation | M08 | WF-M08-RECEIPT | `/api/admin/production/material-receipts` | `op_material_receipt`, `op_material_receipt_variance` |
| Packaging/QR/print | M10 | WF-M10-PACK, WF-M10-QR | `/api/admin/packaging/jobs`, `/api/admin/qr/generate`, `/api/admin/printing/jobs` | `op_packaging_job`, `op_qr_registry`, `op_print_job` |
| QC/release/warehouse | M09/M11 | WF-M09-RELEASE, WF-M11-WH | `/api/admin/qc/releases`, `/api/admin/warehouse/receipts` | `op_batch_release`, `op_warehouse_receipt` |
| Trace/public trace | M12 | WF-M12-INTERNAL, WF-M12-PUBLIC | `/api/admin/trace/search`, `/api/public/trace/{qrCode}` | `op_trace_link`, `vw_public_traceability` |
| Recall extension | M13 | WF-M13-RECALL | `/api/admin/incidents`, `/api/admin/recall/cases/*` | `op_recall_case`, `op_recall_exposure_snapshot` |
| MISA status | M14 | WF-M14-SYNC | `/api/admin/integrations/misa/sync-events` | `misa_sync_event`, `misa_sync_log` |

## 4. Test mapping

| E2E test | Sequence coverage |
|---|---|
| E2E-SMOKE-001 | Full main sequence |
| E2E-SMOKE-002 | Material issue idempotency and one ledger decrement |
| E2E-SMOKE-003 | QC/release/warehouse gates |
| E2E-SMOKE-004 | Public trace whitelist response |
| E2E-SMOKE-005 | MISA sync/retry/reconcile visibility |
| E2E-SMOKE-006 | Recall extension |
