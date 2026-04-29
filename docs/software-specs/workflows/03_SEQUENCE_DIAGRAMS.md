# 03 Sequence Diagrams

## Mục lục

- [1. Mục tiêu](#1-mục-tiêu)
- [2. Smoke E2E Sequence](#2-smoke-e2e-sequence)
- [3. Production Order Snapshot Sequence](#3-production-order-snapshot-sequence)
- [4. Material Issue And Receipt Sequence](#4-material-issue-and-receipt-sequence)
- [5. QC Release And Warehouse Sequence](#5-qc-release-and-warehouse-sequence)
- [6. QR And Public Trace Sequence](#6-qr-and-public-trace-sequence)
- [7. Recall Sequence](#7-recall-sequence)
- [8. MISA Sync Sequence](#8-misa-sync-sequence)

## 1. Mục tiêu

Tài liệu này mô tả sequence diagram cho các tương tác API/service chính. Các tên service là target architecture trong docs, không phải bằng chứng source code.

## 2. Smoke E2E Sequence

```mermaid
sequenceDiagram
    autonumber
    actor QA as QA/E2E Runner
    participant AdminUI as Admin/PWA UI
    participant SourceAPI as Source Origin API
    participant RawAPI as Raw Material API
    participant RecipeAPI as Recipe API
    participant ProdAPI as Production API
    participant MaterialAPI as Material API
    participant QcAPI as QC/Release API
    participant WhAPI as Warehouse API
    participant TraceAPI as Trace API
    participant MisaAPI as MISA Integration API

    QA->>AdminUI: Start smoke data set
    AdminUI->>SourceAPI: Create source origin + verify
    SourceAPI-->>AdminUI: Source origin VERIFIED
    AdminUI->>RawAPI: Create raw intake
    RawAPI-->>AdminUI: Raw lot created
    AdminUI->>QcAPI: Sign raw lot QC_PASS
    QcAPI-->>AdminUI: Raw lot QC_PASS
    AdminUI->>RawAPI: Mark raw lot READY_FOR_PRODUCTION
    RawAPI-->>AdminUI: Raw lot READY_FOR_PRODUCTION
    AdminUI->>RecipeAPI: Ensure active G1 recipe for SKU
    RecipeAPI-->>AdminUI: Active recipe version returned
    AdminUI->>ProdAPI: Create production order with recipe snapshot
    ProdAPI-->>AdminUI: PO with immutable snapshot
    AdminUI->>MaterialAPI: Create and approve material request
    MaterialAPI-->>AdminUI: Material request APPROVED
    AdminUI->>MaterialAPI: Execute material issue with Idempotency-Key
    MaterialAPI-->>AdminUI: Issue EXECUTED + inventory ledger posted
    AdminUI->>MaterialAPI: Confirm material receipt
    MaterialAPI-->>AdminUI: Receipt CONFIRMED
    AdminUI->>ProdAPI: Record batch/process events
    ProdAPI-->>AdminUI: Batch ready for QC/release flow
    AdminUI->>QcAPI: Sign batch QC_PASS
    QcAPI-->>AdminUI: Batch QC_PASS, release still pending
    AdminUI->>QcAPI: Approve batch release
    QcAPI-->>AdminUI: Batch RELEASED
    AdminUI->>WhAPI: Confirm warehouse receipt
    WhAPI-->>AdminUI: Finished goods ledger posted
    AdminUI->>TraceAPI: Resolve internal trace and public trace
    TraceAPI-->>AdminUI: Genealogy + public-safe response
    AdminUI->>MisaAPI: Verify sync event mapped/synced or retry/reconcile
    MisaAPI-->>AdminUI: Sync terminal status
```

## 3. Production Order Snapshot Sequence

```mermaid
sequenceDiagram
    autonumber
    actor Planner as Production Planner
    participant UI as Production Order UI
    participant ProdAPI as Production API
    participant RecipeSvc as Recipe Service
    participant Db as Database
    participant Audit as Audit/Event

    Planner->>UI: Submit PO create form
    UI->>ProdAPI: POST /api/admin/production/orders
    ProdAPI->>RecipeSvc: Resolve active approved recipe by SKU
    RecipeSvc-->>ProdAPI: Recipe header + lines
    ProdAPI->>ProdAPI: Validate active operational version and required 4 groups
    ProdAPI->>Db: Insert PO header and snapshot lines
    Db-->>ProdAPI: PO created
    ProdAPI->>Audit: Append PRODUCTION_ORDER_CREATED
    ProdAPI-->>UI: ProductionOrderResponse
    UI-->>Planner: Show PO detail and snapshot
```

## 4. Material Issue And Receipt Sequence

```mermaid
sequenceDiagram
    autonumber
    actor Prod as Production Operator
    actor Wh as Warehouse Operator
    participant UI as Material UI/PWA
    participant MaterialAPI as Material API
    participant InvSvc as Inventory Service
    participant TraceSvc as Trace Service
    participant Db as Database

    Prod->>UI: Create material request from PO snapshot
    UI->>MaterialAPI: POST /api/admin/production/material-requests
    MaterialAPI->>Db: Validate lines inside PO snapshot
    MaterialAPI-->>UI: Material request created
    Wh->>UI: Execute approved issue
    UI->>MaterialAPI: POST /api/admin/production/material-issues/{id}/execute with Idempotency-Key
    MaterialAPI->>InvSvc: Check raw lot READY_FOR_PRODUCTION, no active hold, and available balance
    InvSvc-->>MaterialAPI: Lot eligible
    MaterialAPI->>Db: Mark issue EXECUTED
    MaterialAPI->>InvSvc: Post raw inventory decrement ledger
    MaterialAPI->>TraceSvc: Append RAW_LOT_TO_ISSUE and ISSUE_TO_BATCH links
    MaterialAPI-->>UI: MaterialIssueResponse
    Prod->>UI: Confirm workshop receipt
    UI->>MaterialAPI: POST /api/admin/production/material-receipts
    MaterialAPI->>Db: Store receipt and variance if any
    MaterialAPI-->>UI: MaterialReceiptResponse
```

## 5. QC Release And Warehouse Sequence

```mermaid
sequenceDiagram
    autonumber
    actor Inspector as QA Inspector
    actor Manager as QA Manager
    actor Warehouse as Warehouse Operator
    participant UI as QC/Warehouse UI
    participant QcAPI as QC API
    participant ReleaseSvc as Release Service
    participant WhAPI as Warehouse API
    participant InvSvc as Inventory Service
    participant TraceSvc as Trace Service

    Inspector->>UI: Sign batch QC inspection
    UI->>QcAPI: POST /api/admin/qc/inspections
    QcAPI-->>UI: QC inspection result QC_PASS
    Manager->>UI: Approve release
    UI->>QcAPI: POST /api/admin/qc/releases/{id}/approve
    QcAPI->>ReleaseSvc: Validate QC_PASS and no active hold
    ReleaseSvc-->>QcAPI: Batch release APPROVED_RELEASED
    QcAPI-->>UI: BatchReleaseResponse
    Warehouse->>UI: Confirm FG warehouse receipt
    UI->>WhAPI: POST /api/admin/warehouse/receipts
    WhAPI->>ReleaseSvc: Validate batch released
    WhAPI->>InvSvc: Post FG inventory ledger
    WhAPI->>TraceSvc: Append BATCH_TO_WAREHOUSE link
    WhAPI-->>UI: WarehouseReceiptResponse
```

## 6. QR And Public Trace Sequence

```mermaid
sequenceDiagram
    autonumber
    actor Pack as Packaging Operator
    actor Public as Public User
    participant UI as Packaging/Printing UI
    participant QrAPI as QR API
    participant PrintAPI as Print API
    participant TraceProjection as Public Trace Projection
    participant PublicAPI as Public Trace API

    Pack->>UI: Generate QR for packaging job
    UI->>QrAPI: POST /api/admin/qr/generate
    QrAPI-->>UI: QR GENERATED
    UI->>PrintAPI: POST /api/admin/printing/jobs
    PrintAPI-->>UI: Print job QUEUED
    PrintAPI->>QrAPI: Mark QR PRINTED or FAILED
    QrAPI->>TraceProjection: Build public-safe projection for printed QR
    Public->>PublicAPI: GET /api/public/trace/{qrCode}
    PublicAPI->>TraceProjection: Resolve whitelisted public data
    TraceProjection-->>PublicAPI: PublicTraceResponse
    PublicAPI-->>Public: Public-safe trace response
```

## 7. Recall Sequence

```mermaid
sequenceDiagram
    autonumber
    actor QA as QA Manager
    actor Recall as Recall Manager
    participant UI as Recall UI
    participant RecallAPI as Recall API
    participant TraceSvc as Trace Service
    participant InvSvc as Inventory/Hold Service
    participant Audit as Audit/Event

    QA->>UI: Open incident
    UI->>RecallAPI: POST /api/admin/incidents
    RecallAPI-->>UI: Incident opened
    Recall->>UI: Open recall case
    UI->>RecallAPI: POST /api/admin/recall/cases
    RecallAPI-->>UI: Recall case OPEN
    UI->>RecallAPI: POST /api/admin/recall/cases/{id}/impact-analysis
    RecallAPI->>TraceSvc: Build genealogy and exposure snapshot
    TraceSvc-->>RecallAPI: Impact data or trace gap
    RecallAPI-->>UI: Impact snapshot
    UI->>RecallAPI: POST /api/admin/recall/cases/{id}/hold
    RecallAPI->>InvSvc: Apply hold/sale lock
    RecallAPI->>Audit: Append recall hold event
    RecallAPI-->>UI: Recall HOLD_ACTIVE
    Recall->>UI: Complete recovery/CAPA and attach evidence
    UI->>RecallAPI: POST /api/admin/recall/capas/{capaId}/evidence
    RecallAPI->>Audit: Append CAPA evidence metadata + scan status
    RecallAPI-->>UI: CAPA evidence CLEAN or blocking scan error
    Recall->>UI: Close recall
    UI->>RecallAPI: POST /api/admin/recall/cases/{id}/close
    RecallAPI-->>UI: Recall CLOSED or blocking errors
```

## 8. MISA Sync Sequence

```mermaid
sequenceDiagram
    autonumber
    participant Domain as Domain Service
    participant Outbox as Outbox/Event Service
    participant Misa as MISA Integration Service
    actor Operator as Integration Operator
    participant UI as MISA UI

    Domain->>Outbox: Append operational event
    Outbox->>Misa: Dispatch sync event
    Misa->>Misa: Resolve mapping
    alt Mapping exists
        Misa->>Misa: Send to MISA adapter
        Misa-->>Outbox: SYNCED or FAILED_RETRYABLE
    else Mapping missing
        Misa-->>Outbox: FAILED_NEEDS_REVIEW
    end
    Operator->>UI: Review failed sync
    UI->>Misa: POST /api/admin/integrations/misa/sync-events/{id}/retry or reconcile
    Misa-->>UI: Updated sync status
```
