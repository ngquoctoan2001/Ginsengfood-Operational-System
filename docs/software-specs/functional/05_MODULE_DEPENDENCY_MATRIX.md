# Module Dependency Matrix

> Mục đích: chỉ rõ dependency giữa các module/function để PM chia task, Dev tránh tạo business truth song song, QA xác định thứ tự smoke/integration test.

## 1. Dependency Matrix

| dependency_id | From module/function | Depends on | Dependency type | Reason | Blocking rule | Test anchor |
| --- | --- | --- | --- | --- | --- | --- |
| DEP-001 | M06 Raw Material Intake | M03 Master Data, M05 Source Origin, M04 Ingredient | Data | Intake cần ingredient/UOM/supplier/source. | Block intake nếu missing required reference. | AC-RM-001..003 |
| DEP-002 | M05 Source Origin | M02 Auth Permission, M01 Audit | Governance | Verification cần permission/audit. | Không verify nếu user thiếu quyền. | AC-SRC-002 |
| DEP-003 | M04 Recipe | M03 UOM, M02 Approval, M01 Audit | Data/governance | Recipe line cần UOM và approval/version audit. | Không activate recipe chưa approve. | AC-REC-005 |
| DEP-004 | M07 Production Order | M04 SKU/Recipe | Data/snapshot | PO snapshot active formula. | Missing active G1 blocks PO. | AC-PO-001 |
| DEP-005 | M08 Material Request | M07 Production Order | Workflow | Request line sinh từ PO snapshot. | Ngoài snapshot bị reject/exception. | AC-MI-002 |
| DEP-006 | M08 Material Issue | M06 Raw Lot Readiness, M11 Raw Inventory | Workflow/inventory | Issue cần lot `READY_FOR_PRODUCTION` và balance đủ. | Lot chỉ `QC_PASS` nhưng chưa mark-ready, lot not ready hoặc balance thiếu block issue. | AC-RM-004, AC-MI-001 |
| DEP-007 | M08 Material Receipt | M08 Material Issue | Workflow | Receipt xác nhận issue đã cấp. | Receipt không có issue reference bị reject. | AC-MR-001 |
| DEP-008 | M07 Process Execution | M08 Material Issue/Receipt | Workflow | Xưởng chỉ chạy khi material đã cấp/nhận theo policy. | Nếu policy yêu cầu receipt mà chưa confirm thì block process. | AC-PROC-001 |
| DEP-009 | M10 Packaging | M07 Process Execution | Workflow | Packaging sau full process completion. | Thiếu một trong ba bước `PREPROCESSING`, `FREEZING`, `FREEZE_DRYING` thì block packaging. | AC-PKG-001 |
| DEP-010 | M10 QR/Print | M10 Packaging, M10 Trade Item/GTIN | Data/workflow | QR gắn packaging unit và trade item. | Missing GTIN khi required block commercial print. | AC-QR-001 |
| DEP-011 | M09 Finished QC | M07/M10 Batch/Packaging | Workflow | QC thành phẩm sau process/packaging theo policy. | QC sai object/prereq bị reject. | AC-REL-001 |
| DEP-012 | M09 Batch Release | M09 QC, M13 Hold Registry | Governance/workflow | Release cần QC pass và no active hold. | QC pass không tự release; hold block release. | AC-REL-002 |
| DEP-013 | M11 Warehouse Receipt | M09 Batch Release | Workflow/inventory | Warehouse chỉ nhận released batch. | Batch chưa release block receipt. | AC-WH-001 |
| DEP-014 | M11 Inventory Balance | M08 Issue, M11 Receipt, M11 Adjustment | Ledger | Balance derived từ ledger. | Không update balance không ledger. | AC-INV-001 |
| DEP-015 | M12 Internal Trace | M05, M06, M08, M07, M10, M11 | Data lineage | Trace cần source/raw lot/material/batch/QR/warehouse links. | Missing link flag trace gap. | AC-TRACE-001 |
| DEP-016 | M12 Public Trace | M10 QR, M12 Public Policy | Public boundary | Public trace resolve từ QR và whitelist policy. | QR void/failed hoặc policy missing fail safe. | AC-PTRACE-001..002 |
| DEP-017 | M13 Recall Impact | M12 Traceability | Workflow | Recall impact dùng trace snapshot. | Không overwrite snapshot cũ. | AC-RECALL-002 |
| DEP-018A | M13 Hold Registry | M11 Inventory, M09 Release, M08 Issue | Control | Operational hold chặn release/issue/warehouse theo object affected. | Không dùng sale lock để thay operational hold. | AC-RECALL-003 |
| DEP-018B | M13 Sale Lock Registry | External order/shipment/customer refs | Control | Sale lock chặn commerce/allocation downstream theo reference. | Không dùng hold registry làm sale lock duy nhất. | AC-RECALL-003 |
| DEP-019 | M14 MISA Sync | M01 Event/Outbox, M14 Accounting Document, module business events | Integration | MISA xử lý accounting document/event downstream. | Module nghiệp vụ không direct sync; accounting document missing blocks sync handoff, not operational ledger. | AC-MISA-001, AC-MISA-003 |
| DEP-020 | M15 Dashboard/Alert | M01 Events, M14 Sync, M13 Recall, M10 Device/Print | Observability | Dashboard cần event/health/alert. | Unknown telemetry không được coi là OK. | AC-DASH-001 |
| DEP-021 | M16 Admin UI | M02 Permissions, all module APIs | UI/API | Screen/action theo permission và API contract. | UI action không bypass backend. | AC-RBAC-001 |
| DEP-022 | M16 PWA | M01 Idempotency, M02 Auth, selected module commands | Offline/workflow | PWA submit cần idempotent/device/session. | Duplicate replay không double-post. | AC-PWA-001 |
| DEP-023 | Exception flows | M01 Audit/State, M02 Permission | Governance | Hold/halt/cancel/reject/correction/rollback cần reason/audit/permission. | No silent history mutation. | AC-EXC-001..006 |
| DEP-024 | M10 Device/Printer Integration | M01 Event/Outbox, M02 Device/Auth policy, M10 Print Queue | Device/security | Printer/device callbacks đi qua integration boundary, không direct DB. | Device inactive/unregistered/token failure không đổi print/QR success state. | AC-QR-002, AC-ALERT-001 |

## 2. Critical Path

```text
M01 + M02 + M03
  → M05 Source Origin
  → M06 Raw Material + Incoming QC + Raw Lot Mark-Ready
  → M04 SKU/Ingredient/Recipe G1 readiness
  → M07 Production Order/Batch
  → M08 Material Issue/Receipt
  → M10 Packaging/QR
  → M09 QC/Release
  → M11 Warehouse/Inventory
  → M12 Traceability
  → M13 Recall
  → M14 MISA Sync
  → M15 Dashboard/Alert
  → M16 Admin/PWA updated throughout
```

## 3. Dependency Risk Register

| risk_id | Dependency risk | Impact | Mitigation |
| --- | --- | --- | --- |
| DR-001 | Recipe G1 readiness thiếu SKU/ingredient/4 groups hoặc required ingredients `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`, `ING_THIT_HEO_NAC` | CODE03 block | Seed validation + AC-REC-* before PO work. |
| DR-002 | Source origin chưa verified nhưng raw intake cho tự trồng vẫn qua | Trace/public trust bị sai | Enforce AC-RM-002 before issue. |
| DR-003 | Issue/receipt nhập chung một action | Sai tồn kho, khó trace | Keep M08 issue execution and receipt confirmation separate. |
| DR-004 | QC pass auto release | Nhập kho/bán batch chưa được release | AC-REL-001 and AC-WH-001 must be smoke tests. |
| DR-004B | Raw lot `QC_PASS` được issue khi chưa `READY_FOR_PRODUCTION` | Nguyên liệu chưa đủ readiness đi vào sản xuất | AC-RM-004 and AC-MI-001 negative test must run before CODE03. |
| DR-005 | Public trace dùng internal trace view trực tiếp | Lộ supplier/personnel/costing/QC defect | Public whitelist view/API and leakage tests. |
| DR-006 | MISA direct sync in business module | Coupling và retry/reconcile không kiểm soát | Outbox/integration layer only. |
| DR-007 | Exception flow sửa dữ liệu lịch sử | Mất audit/trace | Correction/reversal, no in-place updates. |
| DR-008 | Owner decisions về SLA/retention/printer chậm | CODE12/CODE16/CODE17 không close | Mark configurable/deferred and keep blockers visible. |

## 4. Integration Test Order

| order | Test group | Dependencies |
| --- | --- | --- |
| 1 | RBAC/audit/idempotency smoke | M01, M02 |
| 2 | Master/source/recipe readiness | M03, M04, M05 |
| 3 | Raw intake + incoming QC + mark-ready | M06, M09 |
| 4 | PO snapshot + material request/issue/receipt | M04, M07, M08, M11 |
| 5 | Production process + packaging/QR | M07, M10 |
| 6 | QC/release + warehouse receipt | M09, M11 |
| 7 | Trace/public trace leakage | M12 |
| 8 | Recall impact/hold/recovery | M13, M12, M11 |
| 9 | MISA dry-run/retry/reconcile | M14, M01 |
| 10 | Dashboard/alert + full smoke | M15, all modules |
