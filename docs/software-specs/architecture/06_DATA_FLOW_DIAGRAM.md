# Data Flow Diagram

> Mục đích: mô tả luồng dữ liệu end-to-end từ nguyên liệu tới trace/recall/MISA.

## 1. Operational Data Flow

```mermaid
flowchart TD
  SZ[Source Zone / Source Origin] --> SEV[Source Evidence Metadata / Clean Scan]
  SEV --> RM[Raw Material Intake]
  SUP[Supplier] --> RM
  ING[Ingredient Master] --> RM
  RM --> RLOT[Raw Material Lot PENDING_QC]
  RLOT --> RQC[Incoming QC]
  RQC -->|QC_PASS| QCP[Raw Lot QC_PASS]
  QCP --> RTA[Lot Readiness Transition Action]
  RTA --> RFP[Raw Lot READY_FOR_PRODUCTION]
  RQC -->|QC_HOLD/QC_REJECT| BLOCK[Blocked Lot]

  SKU[SKU Master] --> REC[Recipe G1 Active]
  ING --> REC
  REC --> PO[Production Order Snapshot]
  SKU --> PO

  PO --> MRQ[Material Request]
  RFP --> MI[Material Issue Execution]
  MRQ --> MI
  MI --> LEDGER1[Raw Inventory Ledger Debit]
  MI --> USAGE[Batch Material Usage]
  MI --> MRC[Material Receipt Confirmation]

  PO --> WO[Work Order]
  WO --> PROC[PREPROCESSING -> FREEZING -> FREEZE_DRYING]
  PROC --> BATCH[Batch]
  USAGE --> BATCH

  BATCH --> PKG[Packaging Unit]
  PKG --> QR[QR Registry / Print Job]
  BATCH --> FQC[Finished QC]
  FQC -->|QC_PASS| RELCMD[Release Approval Command]
  RELCMD --> REL[Batch RELEASED]
  REL --> WHR[Warehouse Receipt]
  WHR --> LEDGER2[FG Inventory Ledger Credit]
  LEDGER2 --> BAL[Lot Balance Projection]

  SZ --> TRACE[Trace Links / Genealogy]
  RLOT --> TRACE
  USAGE --> TRACE
  BATCH --> TRACE
  QR --> TRACE
  WHR --> TRACE
  TRACE --> PUB[Public Trace View]
  TRACE --> RECALL[Recall Impact Snapshot]
  RECALL --> HOLD[Hold / Sale Lock / Recovery / CAPA / Clean Evidence]
  HOLD --> CAPAEV[CAPA Evidence Metadata / Clean Scan]
  SEV -. binary ref .-> ESTORE[Evidence Storage Adapter]
  CAPAEV -. binary ref .-> ESTORE

  LEDGER1 --> OUTBOX[Outbox]
  MI --> OUTBOX
  WHR --> OUTBOX
  REL --> OUTBOX
  OUTBOX --> MISA[MISA Integration]
  OUTBOX --> DASH[Dashboard / Alerts]
```

## 2. Snapshot Data Flow

| Snapshot | Source | Created at | Immutable because |
| --- | --- | --- | --- |
| Production recipe snapshot | Active recipe + SKU + ingredient lines | PO create/approve | Recipe G2/G3 must not rewrite old production. |
| Print payload snapshot | PO/batch/packaging/QR state + active GTIN/trade item mapping if commercial print | Print job create | Reprint must reproduce/compare original; missing GTIN mapping raises `GTIN_MAPPING_MISSING`, no fallback to SKU code. |
| Recall exposure snapshot | Trace query result | Impact analysis run | Recall evidence must not drift after new shipments/trace changes. |
| Public trace projection | Internal trace + public field policy | QR public-ready/update | Public response must stay whitelist-only. |

## 3. Data Flow Controls

| Control | Applies to | Rule |
| --- | --- | --- |
| Idempotency | Intake, issue, receipt, print, release, recall actions | Same command key cannot create duplicate side effects. |
| Append-only | Audit, state transition, ledger, QR history, recall snapshots, evidence metadata | Correction/reversal creates new record; evidence scan status can only move from `PENDING_SCAN` to a terminal scan result. |
| FK/reference | All transaction tables | No orphan transaction rows. |
| Check enum | State/status fields | Invalid state rejected at DB/app boundary. |
| Public whitelist | Public trace | Internal/private fields excluded by design. |

Note: process execution is simplified in this diagram as `PREPROCESSING -> FREEZING -> FREEZE_DRYING`; detailed per-step states belong in workflow/state-machine specs.
