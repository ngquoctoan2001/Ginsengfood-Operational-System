# Component Diagram

> Mermaid component/context view for the target Operational Domain.

## 1. Component Diagram

```mermaid
flowchart LR
  subgraph UI[User Surfaces]
    Admin[Admin Web]
    PWA[Shopfloor PWA]
    PublicTrace[Public Trace Page]
  end

  subgraph API[API Boundary]
    Auth[Auth/RBAC Middleware]
    Idem[Idempotency Middleware]
    Validation[Validation/Error Contract]
    AdminApi[Admin API]
    PublicApi[Public Trace API]
  end

  subgraph APP[Application Services]
    SourceSvc[Source Origin Service]
    RawSvc[Raw Material Service]
    RecipeSvc[SKU/Recipe Service]
    ProdSvc[Production Service]
    IssueSvc[Material Issue/Receipt Service]
    QcSvc[QC/Release Service]
    PackSvc[Packaging/Printing/QR Service]
    WhSvc[Warehouse/Inventory Service]
    TraceSvc[Traceability Service]
    RecallSvc[Recall Service]
    ReportSvc[Dashboard/Alert Service]
  end

  subgraph INT[Integration Layer]
    MisaSvc[MISA Integration Service]
    EvidenceStorage[Evidence Storage Adapter]
    DeviceReg[Device Registry/Auth]
    PrinterAdapter[Printer/Scanner Adapter Service]
  end

  subgraph CORE[Foundation]
    Audit[Audit Log]
    StateLog[State Transition Log]
    Outbox[Outbox/Event Store]
    Approval[Approval Policy/Queue]
  end

  subgraph DB[(PostgreSQL Operational DB)]
    Master[(Master Tables)]
    Tx[(Transaction Tables)]
    Ledger[(Ledger/Balance)]
    Trace[(Trace/Recall)]
    Integration[(Integration/Audit)]
  end

  subgraph EXT[External Systems]
    MISA[MISA AMIS]
    EvidenceStore[Company Storage Server / Local Filesystem]
    Printer[Printer/Scanner Adapter]
    Commerce[Commerce/Order/Shipment]
    Notification[Notification/CRM]
  end

  Admin --> Auth --> Idem --> Validation --> AdminApi
  PWA --> Auth
  PublicTrace --> PublicApi

  AdminApi --> SourceSvc
  AdminApi --> RawSvc
  AdminApi --> RecipeSvc
  AdminApi --> ProdSvc
  AdminApi --> IssueSvc
  AdminApi --> QcSvc
  AdminApi --> PackSvc
  AdminApi --> WhSvc
  AdminApi --> TraceSvc
  AdminApi --> RecallSvc
  AdminApi --> MisaSvc
  AdminApi --> ReportSvc
  PublicApi --> TraceSvc

  SourceSvc --> DB
  SourceSvc --> EvidenceStorage
  RawSvc --> DB
  RecipeSvc --> DB
  ProdSvc --> DB
  IssueSvc --> DB
  QcSvc --> DB
  PackSvc --> DB
  WhSvc --> DB
  TraceSvc --> DB
  RecallSvc --> DB
  RecallSvc --> EvidenceStorage
  ReportSvc --> DB
  MisaSvc --> DB
  DeviceReg --> DB
  PrinterAdapter --> DB

  APP --> Audit
  APP --> StateLog
  APP --> Outbox
  APP --> Approval

  Outbox --> MisaSvc --> MISA
  EvidenceStorage -. file refs only .-> EvidenceStore
  AdminApi --> MisaSvc
  AdminApi --> DeviceReg
  PackSvc --> PrinterAdapter --> Printer
  Printer --> PrinterAdapter
  RecallSvc -. reference keys .-> Commerce
  RecallSvc -. notification_job_id .-> Notification
```

## 2. Component Contracts

| Component | Input | Output | Critical rule |
| --- | --- | --- | --- |
| API Boundary | HTTP request, auth context, idempotency key | Command/query response | Permission and idempotency before side effect. |
| Application Services | Validated command/query | Domain state changes | One use-case transaction boundary. |
| Domain Services | Current state + command | State transition/validation result | Enforce hard locks and business rules. |
| PostgreSQL | Transaction writes/queries | Durable state, constraints | Append-only tables guarded. |
| Outbox | Committed business event | Retryable integration event | No direct MISA sync from business module. |
| Lot Readiness | QC-signed raw lot + readiness command | Raw lot `READY_FOR_PRODUCTION` | Lot `QC_PASS` alone is not issuable. |
| MISA Integration Layer | Outbox event/accounting document | MISA sync status/reconcile evidence | Business modules never call MISA directly. |
| Printer/Device Integration | Print job, device heartbeat/callback | Print/QR technical state and device health | Device/printer cannot create inventory, QC pass or release. |
| Public Trace API | QR code | Whitelist public trace payload | No private/internal fields. |
| Evidence Storage Adapter | Source-origin/CAPA evidence file upload metadata | File URI/key, hash, size, MIME, scan status | Dev/test uses local filesystem; production uses company storage server config; DB stores metadata only. |
