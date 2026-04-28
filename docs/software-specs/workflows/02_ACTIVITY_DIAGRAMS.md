# 02 Activity Diagrams

## 1. Mục tiêu

Tài liệu này mô tả activity diagram bằng Mermaid cho các luồng vận hành chính, phụ và lỗi. Diagram là contract nghiệp vụ/triển khai, không thay thế validation ở API/database.

## 2. Full Operational Activity

```mermaid
flowchart TD
    SO[Create source zone / source origin] --> SOV{Source origin verified?}
    SOV -- No --> SOR[Reject or request evidence]
    SOR --> SO
    SOV -- Yes --> RMI[Raw material intake]
    RMI --> LOT[Create raw material lot]
    LOT --> IQC[Incoming QC inspection]
    IQC --> QCR{QC result}
    QCR -- QC_HOLD --> LOTHOLD[Hold lot and investigate]
    QCR -- QC_REJECT --> LOTREJECT[Reject lot and block issue]
    QCR -- QC_PASS --> READY_REVIEW[Lot readiness transition / mark_ready]
    READY_REVIEW --> READY_DECISION{Readiness checks pass?}
    READY_DECISION -- No --> READY_BLOCK[Keep lot blocked / quarantined / not ready]
    READY_DECISION -- Yes --> READY[Raw lot READY_FOR_PRODUCTION]
    READY --> RECIPE[Recipe version active and approved]
    RECIPE --> PO[Create production order]
    PO --> SNAPSHOT[Snapshot recipe lines into PO]
    SNAPSHOT --> MREQ[Material request from snapshot]
    MREQ --> MREQ_APPROVAL{Material request approved?}
    MREQ_APPROVAL -- No --> MREQ_REJECT[Reject request with reason]
    MREQ_APPROVAL -- Yes --> ISSUE[Execute material issue from READY_FOR_PRODUCTION lot]
    ISSUE --> LEDGER[Post raw inventory decrement ledger]
    LEDGER --> RECEIPT[Confirm material receipt at workshop]
    RECEIPT --> VAR{Variance?}
    VAR -- Yes --> VAR_REASON[Record variance reason]
    VAR -- No --> EXEC[Start batch execution]
    VAR_REASON --> EXEC
    EXEC --> PROCESS[Process events in required order]
    PROCESS --> PACK[Packaging job]
    PACK --> QRGEN[Generate QR]
    QRGEN --> PRINTQ[Queue print job]
    PRINTQ --> PRINT_RESULT{Print result}
    PRINT_RESULT -- FAILED --> PRINT_FAIL[Retry or reprint with reason]
    PRINT_RESULT -- PRINTED --> BQC[QC inspection]
    BQC --> BQCR{QC result}
    BQCR -- QC_HOLD --> BHOLD[Hold batch]
    BQCR -- QC_REJECT --> BREJECT[Reject batch]
    BQCR -- QC_PASS --> RELEASE[Create/approve batch release]
    RELEASE --> WH[Warehouse finished goods receipt]
    WH --> FGLEDGER[Post FG inventory ledger and lot balance]
    FGLEDGER --> TRACE[Build internal trace genealogy]
    TRACE --> PUBLIC[Public trace projection]
    PUBLIC --> MISA[MISA sync event via integration layer]
    MISA --> MISASTATUS{Sync status}
    MISASTATUS -- SYNCED --> DONE[Done]
    MISASTATUS -- FAILED_RETRYABLE --> RETRY[Retry]
    MISASTATUS -- FAILED_NEEDS_REVIEW --> RECONCILE[Reconcile]
```

## 3. Source Origin And Raw Intake Activity

```mermaid
flowchart TD
    A[Source Manager creates source zone] --> B[Create source origin]
    B --> C[Attach evidence if required]
    C --> D[Submit for verification]
    D --> E{QA verifies?}
    E -- Reject --> F[Set REJECTED and store reason]
    E -- Verify --> G[Set VERIFIED]
    G --> H{Source still valid?}
    H -- Expired / inactive --> H1[Set EXPIRED or INACTIVE and block controlled intake]
    H -- Valid --> I[Warehouse creates raw intake]
    I --> J{Source origin required and verified?}
    J -- No --> K[Block intake: SOURCE_ORIGIN_NOT_VERIFIED]
    J -- Yes --> L[Confirm intake and create raw lot]
```

## 4. Material Issue / Receipt Activity

```mermaid
flowchart TD
    A[Production creates material request from PO snapshot] --> B{All lines inside snapshot?}
    B -- No --> B1[Reject OUTSIDE_SNAPSHOT_MATERIAL]
    B -- Yes --> C[Submit material request]
    C --> D{Approver approves?}
    D -- Reject --> D1[REJECTED with reason]
    D -- Approve --> E[Warehouse selects READY_FOR_PRODUCTION raw lot]
    E --> F{Lot available, not held, not expired?}
    F -- No --> F1[Block issue]
    F -- Yes --> G[Execute material issue]
    G --> H[Post inventory ledger CREDIT/consume raw lot]
    H --> I[Workshop confirms receipt]
    I --> J{Received qty differs?}
    J -- Yes --> K[Require variance reason]
    J -- No --> L[Confirm receipt]
    K --> L
    L --> M[Continue batch execution]
```

## 5. QC, Release, Warehouse Activity

```mermaid
flowchart TD
    A[Batch ready for QC] --> B[Create QC inspection]
    B --> C{QC result}
    C -- QC_REJECT --> D[Reject batch; block release and warehouse]
    C -- QC_HOLD --> E[Hold batch; investigate]
    C -- QC_PASS --> F[Batch eligible for release request]
    F --> G[QA Manager reviews release]
    G --> H{Release decision}
    H -- Reject release --> I[Release record REJECTED]
    H -- Approve release --> J[Release record APPROVED_RELEASED]
    J --> K[Warehouse receipt]
    K --> L[Post finished goods inventory ledger]
    L --> M[Update lot balance projection]
```

## 6. QR / Public Trace Activity

```mermaid
flowchart TD
    A[Packaging job completed] --> B[Generate QR]
    B --> C[QR GENERATED]
    C --> D[Queue print job]
    D --> E[QR QUEUED]
    E --> F{Print success?}
    F -- No --> G[Print FAILED]
    G --> H{Retry or void?}
    H -- Retry --> D
    H -- Void --> I[QR VOID with reason]
    F -- Yes --> J[QR PRINTED]
    J --> K[Build public trace projection]
    K --> L{Public field policy pass?}
    L -- No --> M[Block public preview and flag violation]
    L -- Yes --> N[Public trace visible]
    J --> O{Reprint needed?}
    O -- Yes --> P[Create reprint reason and state REPRINTED]
```

## 7. Recall Activity

```mermaid
flowchart TD
    A[Open incident] --> B{Escalate to recall?}
    B -- No --> C[Close incident with reason]
    B -- Yes --> D[Open recall case]
    D --> E[Run impact analysis from trace genealogy]
    E --> F{Trace gap?}
    F -- Yes --> F1[Flag gap and require review]
    F -- No --> G[Create exposure snapshot]
    F1 --> G
    G --> H[Apply hold and sale lock]
    H --> I[Notify affected parties if policy requires]
    I --> J[Recovery and disposition]
    J --> K[CAPA]
    K --> L{All actions closed?}
    L -- No --> J
    L -- Yes --> M[Close recall case]
```

## 8. MISA Integration Activity

```mermaid
flowchart TD
    A[Operational event posted] --> B[Create outbox event]
    B --> C[Integration layer maps event]
    C --> D{Mapping exists?}
    D -- No --> E[FAILED_NEEDS_REVIEW]
    E --> F[Integration Operator updates mapping]
    F --> C
    D -- Yes --> G[MAPPED]
    G --> H[SYNCING]
    H --> I{MISA accepted?}
    I -- Yes --> J[SYNCED]
    I -- Retryable error --> K[FAILED_RETRYABLE]
    K --> L[Auto/manual retry]
    L --> H
    I -- Mismatch --> M[FAILED_NEEDS_REVIEW]
    M --> N[Reconcile]
    N --> O[RECONCILED]
```
