# 01 Workflow Overview

## 1. Mục tiêu

Tài liệu này chuẩn hóa nhóm workflow của `docs/software-specs/` theo prompt gốc và các contract đã được sửa ở Part 2-5. Bộ workflow này thay cho cách mô tả lifecycle rời rạc trước đó, để PM/BA/SA/Dev/QA có thể triển khai và kiểm thử smoke end-to-end mà không phải suy đoán.

Phạm vi nguồn: prompt gốc, `docs-software/`, `.tmp-docx-extract/`, kiến thức chuyên môn và phê duyệt owner. Không dùng source code, `AGENTS.md` hoặc các pack `docs/ginsengfood_*` làm nguồn cho batch tài liệu này.

## 2. Workflow Documents

| File                               | Vai trò                                     | Output chính                                                                                                                                          |
| ---------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `01_WORKFLOW_OVERVIEW.md`          | Tổng quan workflow và dependency            | Danh mục flow, actor, module, gate                                                                                                                    |
| `02_ACTIVITY_DIAGRAMS.md`          | Activity diagram theo flow                  | Mermaid flowchart/activity cho flow chính và phụ                                                                                                      |
| `03_SEQUENCE_DIAGRAMS.md`          | Sequence diagram theo tương tác API/service | Mermaid sequence cho E2E smoke, issue/receipt, release, MISA                                                                                          |
| `04_STATE_MACHINES.md`             | State machine chuẩn                         | Production order, material issue, material receipt, raw material lot/readiness, batch, QC, release, warehouse, ledger, print, QR, trace, recall, MISA |
| `05_CANONICAL_OPERATIONAL_FLOW.md` | Chuỗi vận hành canonical                    | Full chain từ source origin tới MISA sync                                                                                                             |
| `06_APPROVAL_WORKFLOWS.md`         | Duyệt/reject/dual-control                   | Recipe, source origin, PO, material request, release, adjustment, recall, MISA                                                                        |
| `07_EXCEPTION_FLOWS.md`            | Flow lỗi và ngoại lệ                        | cancel/reject/hold/halt/void/reprint/retry/reconcile/override/correction                                                                              |
| `08_SMOKE_WORKFLOW.md`             | Kịch bản smoke E2E                          | Bộ bước chạy được cho QA/E2E                                                                                                                          |

## 3. Canonical Operational Chain

```text
Source Origin
-> Raw Material Intake
-> Raw Material QC
-> Raw Lot Ready
-> G1 Recipe Snapshot
-> Production Order
-> Material Request / Approval
-> Material Issue Execution
-> Material Receipt Confirmation
-> Batch Execution
-> Packaging
-> Printing / QR
-> QC Inspection
-> Batch Release
-> Warehouse Receipt
-> Inventory Ledger / Lot Balance
-> Internal Trace / Public Trace
-> Recall if needed
-> MISA Sync via Integration Layer
```

## 4. Workflow Map

| workflow_id | Workflow                               | Module   | Primary actor                           | Input                                                                                                                                                                                | Output                                                                            | Blocking gate                                                                                                          | API/UI/Test anchors                                                          |
| ----------- | -------------------------------------- | -------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| WF-01       | Source origin setup and verification   | M05      | Source Manager, QA Manager              | Source zone, supplier/source data, evidence                                                                                                                                          | `op_source_origin` = `VERIFIED`                                                   | Source origin must be verified before controlled intake when policy requires                                           | API M05; UI SCR-SOURCE-ZONES, SCR-SOURCE-ORIGINS; TC-UI-SRC-002              |
| WF-02       | Raw material intake                    | M06      | Warehouse Operator                      | Supplier/source origin, ingredient, quantity, UOM                                                                                                                                    | Raw material intake and raw lot                                                   | Quantity > 0; verified source origin where required                                                                    | API M06; UI SCR-RAW-INTAKES; TC-UI-RM-001                                    |
| WF-03       | Raw material QC                        | M06, M09 | QA Inspector                            | Raw material lot                                                                                                                                                                     | Raw lot QC result `QC_PASS`, `QC_HOLD`, or `QC_REJECT`                            | `QC_PASS` only unlocks lot readiness review; it is not issue-ready by itself                                           | API M06/M09; UI SCR-INCOMING-QC; TC-UI-QC-001                                |
| WF-03A      | Raw lot readiness transition           | M06, M09 | QA Manager, Warehouse Manager           | Raw lot with QC result `QC_PASS`                                                                                                                                                     | Raw lot `READY_FOR_PRODUCTION`                                                    | `RAW_LOT_MARK_READY` permission, no active hold/reject/quarantine/expiry, source/readiness checks pass                 | API M06/M09; UI SCR-LOT-READINESS; TC-M06-RM-005                             |
| WF-04       | Recipe governance                      | M04      | R&D, QA Manager, Production Manager     | SKU, ingredient, 4 recipe groups, `formula_kind` (`PILOT_PERCENT_BASED` → anchor metadata + 1 `is_anchor` line; `FIXED_QUANTITY_BATCH` → quantity_per_batch_400 > 0), effective date | Approved active recipe version                                                    | Must be approved, effective, active; snapshot must be immutable; per-PO planner picks `formula_version + formula_kind` | API M04; UI SCR-RECIPE, SCR-RECIPE-LINES; TC-UI-REC-001                      |
| WF-05       | Production order and snapshot          | M07      | Production Planner/Manager              | SKU, planned qty, active recipe                                                                                                                                                      | Production order with immutable snapshot                                          | Active recipe required; snapshot complete                                                                              | API M07; UI SCR-PROD-ORDERS; TC-UI-PO-001                                    |
| WF-06       | Material request and approval          | M08      | Production Operator, Production Manager | PO snapshot lines                                                                                                                                                                    | Approved material request                                                         | Requested lines must be inside snapshot                                                                                | API M08; UI SCR-MATERIAL-REQUESTS; TC-UI-MR-001                              |
| WF-07       | Material issue execution               | M08, M11 | Warehouse Operator                      | Approved material request, raw lot                                                                                                                                                   | `EXECUTED` material issue and raw inventory decrement ledger                      | Raw lot `READY_FOR_PRODUCTION`, available balance, no active hold, idempotency                                         | API M08; UI SCR-MATERIAL-ISSUES; TC-UI-MI-001                                |
| WF-08       | Material receipt confirmation          | M08      | Production Operator                     | Executed issue                                                                                                                                                                       | Confirmed workshop receipt, variance if any                                       | Variance reason required; no second decrement                                                                          | API M08; UI SCR-MATERIAL-RECEIPTS; TC-UI-MRCP-001                            |
| WF-09       | Batch execution                        | M07      | Production Operator                     | Confirmed material receipt                                                                                                                                                           | Completed process events and batch ready for QC/packaging                         | Process order must be respected; halt/correction audited                                                               | API M07; UI SCR-PROCESS-EXEC; TC-UI-BATCH-001                                |
| WF-10       | Packaging and trade item               | M10      | Packaging Operator                      | Batch ready, trade item/GTIN                                                                                                                                                         | Packaging job completed                                                           | Packaging prerequisite complete                                                                                        | API M10; UI SCR-PACKAGING-JOBS, SCR-TRADE-ITEMS; TC-UI-PKG-001               |
| WF-11       | Printing and QR lifecycle              | M10, M12 | Packaging Operator                      | Packaging job, QR quantity                                                                                                                                                           | QR generated/queued/printed or failed/void/reprinted                              | Lifecycle transition valid; reason for void/reprint                                                                    | API M10; UI SCR-QR-REGISTRY, SCR-PRINT-QUEUE; TC-UI-QR-001                   |
| WF-12       | QC inspection and release              | M09      | QA Inspector, QA Manager                | Batch/QC scope                                                                                                                                                                       | QC result and distinct batch release                                              | `QC_PASS` is not `RELEASED`; release action required                                                                   | API M09; UI SCR-QC-INSPECTIONS, SCR-BATCH-RELEASE; TC-UI-REL-001             |
| WF-13       | Warehouse receipt and inventory ledger | M11      | Warehouse Operator                      | Released batch                                                                                                                                                                       | Finished-goods warehouse receipt, ledger, lot balance                             | Batch must be released; ledger append-only                                                                             | API M11; UI SCR-WAREHOUSE-RECEIPTS, SCR-INVENTORY-LEDGER; TC-UI-WH-001       |
| WF-14       | Traceability and public trace          | M12      | Trace Operator, public user             | QR/batch/lot/shipment                                                                                                                                                                | Internal genealogy and public trace response                                      | Public trace whitelist only                                                                                            | API M12; UI SCR-TRACE-SEARCH, SCR-GENEALOGY, SCR-PUBLIC-TRACE; TC-UI-PTR-002 |
| WF-15       | Recall                                 | M13      | QA Manager, Recall Manager              | Incident or affected entity                                                                                                                                                          | Recall case, impact snapshot, hold/sale lock, recovery, CAPA, clean CAPA evidence | Cannot close with open recovery/CAPA, missing clean evidence or unresolved trace gaps                                  | API M13; UI SCR-RECALL-\*; TC-UI-RCL-001                                     |
| WF-16       | MISA sync                              | M14      | Integration Operator                    | Posted operational event                                                                                                                                                             | Sync event mapped/synced/reconciled                                               | Integration layer only; mapping required; retry/reconcile audited                                                      | API M14; UI SCR-MISA-\*; TC-UI-MISA-001                                      |

## 5. Actors

| Actor                | Trách nhiệm workflow                                                       |
| -------------------- | -------------------------------------------------------------------------- |
| Admin                | User/role, screen registry, audit, emergency support.                      |
| Master Data Steward  | UOM, supplier, warehouse, SKU/ingredient baseline.                         |
| Source Manager       | Source zone/source origin data and evidence.                               |
| R&D                  | Recipe draft and recipe lines.                                             |
| QA Inspector         | Incoming QC, process/batch QC, incident capture.                           |
| QA Manager           | Source verification, recipe approval, release approval, recall governance. |
| Production Planner   | Production order planning.                                                 |
| Production Manager   | PO approval/start/close, material request approval.                        |
| Production Operator  | Work execution, material receipt confirmation, process event entry.        |
| Warehouse Operator   | Raw intake, material issue, warehouse receipt.                             |
| Warehouse Manager    | Inventory hold/adjustment approval, lot balance review.                    |
| Packaging Operator   | Packaging job, QR generation, print queue.                                 |
| Recall Manager       | Impact analysis, hold/sale lock, recovery, CAPA, CAPA evidence.            |
| Integration Operator | MISA mapping, retry, reconcile.                                            |
| Public User          | Public trace lookup only.                                                  |

## 6. Cross-Workflow Invariants

| invariant_id | Invariant                                                                                                          | Enforcement point                                            | Test anchor                  |
| ------------ | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------- |
| WF-INV-001   | Production order uses only approved active operational recipe version and snapshots it immutably.                  | Production order create/start; database snapshot constraints | TC-UI-PO-001                 |
| WF-INV-002   | Recipe lines use exactly 4 groups: `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`. | Recipe line save, approval, seed validation                  | TC-UI-REC-002                |
| WF-INV-003   | Material issue is the real raw inventory decrement point.                                                          | Material issue execute transaction                           | TC-UI-MI-001                 |
| WF-INV-004   | Material receipt confirms workshop receipt and variance; it does not decrement raw inventory again.                | Material receipt confirm service                             | TC-UI-MRCP-001               |
| WF-INV-005   | `QC_PASS` does not equal `RELEASED`; release is a distinct action/record.                                          | Batch release workflow and warehouse receipt gate            | TC-UI-REL-001                |
| WF-INV-006   | Warehouse receipt for finished goods requires released batch and posts append-only ledger.                         | Warehouse receipt confirm                                    | TC-UI-WH-001                 |
| WF-INV-007   | QR public trace uses whitelist-only field policy.                                                                  | Public trace projection and UI                               | TC-UI-PTR-002                |
| WF-INV-008   | MISA sync goes through integration layer, never direct module sync.                                                | Outbox/MISA sync event                                       | TC-UI-MISA-001               |
| WF-INV-009   | Ledger, audit, state history and trace history are append-only; correction uses reversal/correction records.       | DB constraints and service commands                          | TC-UI-LED-001                |
| WF-INV-010   | `QC_PASS` does not equal `READY_FOR_PRODUCTION`; raw lot issue requires a separate lot readiness transition.       | Lot mark-ready command and material issue execute guard      | TC-M06-RM-005, TC-M08-MI-001 |

## 7. Done Gate

- `04_STATE_MACHINES.md` has state machine for every object listed in Part 6, including raw lot readiness and batch lifecycle.
- `05_CANONICAL_OPERATIONAL_FLOW.md` covers the full chain from source origin to MISA sync.
- `07_EXCEPTION_FLOWS.md` covers cancel, reject, hold, halt, void, reprint, retry, reconcile, override and correction.
- `08_SMOKE_WORKFLOW.md` can be converted directly into E2E test steps with API/UI anchors.
