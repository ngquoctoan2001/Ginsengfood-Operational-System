# 05 Canonical Operational Flow

## 1. Mục tiêu

Tài liệu này là chuỗi vận hành canonical từ nguồn nguyên liệu tới trace/recall/MISA. Đây là flow chuẩn để PM chia task, Dev map API/service/DB, QA tạo E2E smoke và AI coding agent triển khai theo module mà không suy đoán.

## 2. Full Chain Summary

| step | Workflow stage | Module | Actor | Main API | Main UI | Main DB | Output | Blocking rules |
|---:|---|---|---|---|---|---|---|---|
| 1 | Source zone/source origin setup | M05 | Source Manager | `POST /api/admin/source-zones`, `POST /api/admin/source-origins` | SCR-SOURCE-ZONES, SCR-SOURCE-ORIGINS | `op_source_zone`, `op_source_origin` | Source origin draft/submitted | Required fields/evidence |
| 2 | Source origin verification | M05 | QA Manager | `POST /api/admin/source-origins/{id}/verify` | SCR-SOURCE-ORIGINS | `op_source_origin_verification` | Source origin `VERIFIED` | Reject requires reason; only verified source can be used where required |
| 3 | Raw material intake | M06 | Warehouse Operator | `POST /api/admin/raw-material/intakes` | SCR-RAW-INTAKES | `op_raw_material_receipt`, `op_raw_material_lot` | Raw lot `PENDING_QC` | Quantity > 0; source/supplier rules |
| 4 | Raw material QC | M06/M09 | QA Inspector | `POST /api/admin/raw-material/lots/{lotId}/qc-inspections` | SCR-INCOMING-QC | `op_raw_material_qc_inspection` | Raw lot QC result `QC_PASS`, `QC_HOLD`, or `QC_REJECT` | QC result is append-only; `QC_PASS` only permits readiness review |
| 5 | Raw lot readiness transition | M06/M09 | QA Manager / Warehouse Manager | `POST /api/admin/raw-material/lots/{lotId}/mark-ready` | SCR-LOT-READINESS | `op_raw_material_lot`, `state_transition_log`, `audit_log` | Raw lot `READY_FOR_PRODUCTION` | `QC_PASS`, no active hold/reject/quarantine/expiry, source/readiness checks, `RAW_LOT_MARK_READY` permission |
| 6 | Recipe active baseline | M04 | R&D, QA Manager | `POST /api/admin/recipes`, `PUT /api/admin/recipes/{id}/lines`, `POST /api/admin/recipes/{id}/activate` | SCR-RECIPE, SCR-RECIPE-LINES | `op_production_recipe`, `op_recipe_ingredient` | Approved active G1 recipe version | 4 recipe groups; approved/effective active version |
| 7 | Production order snapshot | M07 | Production Planner | `POST /api/admin/production/orders` | SCR-PROD-ORDERS | `op_production_order`, `op_production_order_item` | PO with immutable recipe snapshot | Active recipe required; snapshot complete |
| 8 | Production order approval/start | M07 | Production Manager | `POST /api/admin/production/orders/{id}/approve` | SCR-PROD-ORDER-DETAIL | `approval_request`, `op_production_order` | PO `APPROVED`/`IN_PROGRESS` | Permission; no active hold |
| 9 | Material request | M08 | Production Operator | `POST /api/admin/production/material-requests` | SCR-MATERIAL-REQUESTS | `op_material_request` | Material request from snapshot | All lines inside snapshot |
| 10 | Material request approval | M08 | Production Manager | `POST /api/admin/production/material-requests/{id}/approve` | SCR-MATERIAL-REQUESTS | `approval_request`, `op_material_request` | Request `APPROVED` | Reject requires reason |
| 11 | Material issue execution | M08/M11 | Warehouse Operator | `POST /api/admin/production/material-issues/{id}/execute` | SCR-MATERIAL-ISSUES | `op_material_issue`, `op_inventory_ledger`, `op_inventory_lot_balance` | Issue `EXECUTED`, raw inventory decremented | Raw lot `READY_FOR_PRODUCTION`; enough balance; no active hold; idempotency |
| 12 | Material receipt confirmation | M08 | Production Operator | `POST /api/admin/production/material-receipts` | SCR-MATERIAL-RECEIPTS | `op_material_receipt`, `op_material_receipt_variance` | Workshop receipt confirmed | Variance reason if mismatch; no second decrement |
| 13 | Batch execution | M07 | Production Operator | `POST /api/admin/production/process-events` | SCR-PROCESS-EXEC | `op_batch`, `op_production_process_event` | Batch process complete | Required step order; halt/correction audited |
| 14 | Packaging | M10 | Packaging Operator | `POST /api/admin/packaging/jobs` | SCR-PACKAGING-JOBS | `op_packaging_job`, `op_trade_item_gtin` | Packaging job completed | Prerequisites complete; trade item/GTIN if required |
| 15 | QR generation | M10/M12 | Packaging Operator | `POST /api/admin/qr/generate` | SCR-QR-REGISTRY | `op_qr_registry`, `op_qr_state_history` | QR `GENERATED` | Packaging unit valid |
| 16 | Print queue and print result | M10 | Packaging Operator | `POST /api/admin/printing/jobs` | SCR-PRINT-QUEUE | `op_print_job` | QR `QUEUED`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED` | Valid lifecycle; reason for void/reprint |
| 17 | QC inspection | M09 | QA Inspector | `POST /api/admin/qc/inspections` | SCR-QC-INSPECTIONS | `op_qc_inspection` | Batch QC result | Hold/reject requires note |
| 18 | Batch release | M09 | QA Manager | `POST /api/admin/qc/releases`, `POST /api/admin/qc/releases/{id}/approve` | SCR-BATCH-RELEASE | `op_batch_release` | Batch release `APPROVED_RELEASED` | `QC_PASS` is not release; no active hold |
| 19 | Warehouse receipt | M11 | Warehouse Operator | `POST /api/admin/warehouse/receipts` | SCR-WAREHOUSE-RECEIPTS | `op_warehouse_receipt`, `op_inventory_ledger` | FG inventory ledger posted | Batch must be released |
| 20 | Lot balance projection | M11 | System/Warehouse Manager | `GET /api/admin/inventory/balances` | SCR-LOT-BALANCE | `op_inventory_lot_balance` | Balance updated | Projection derived from ledger |
| 21 | Internal trace | M12 | Trace Operator | `GET /api/admin/trace/search` | SCR-TRACE-SEARCH, SCR-GENEALOGY | `op_trace_link`, `vw_internal_traceability` | Genealogy chain | Trace gaps flagged |
| 22 | Public trace | M12 | Public user | `GET /api/public/trace/{qrCode}` | SCR-PUBLIC-TRACE | `vw_public_traceability`, `op_public_trace_policy` | Public-safe trace response | Whitelist-only; no internal fields |
| 23 | Recall if needed | M13 | QA/Recall Manager | `POST /api/admin/incidents`, `POST /api/admin/recall/cases/*` | SCR-RECALL-* | `op_incident_case`, `op_recall_case`, `op_recall_exposure_snapshot` | Hold/sale lock/recovery/CAPA | Cannot close while recovery/CAPA open |
| 24 | MISA sync | M14 | Integration Operator/System | `GET/POST /api/admin/integrations/misa/*` | SCR-MISA-* | `misa_sync_event`, `misa_mapping`, `misa_sync_log` | `SYNCED` or reconciled | Integration layer only; mapping required |

## 3. Detailed Flow

### 3.1 Source Origin

1. Source Manager tạo `source_zone`.
2. Source Manager tạo `source_origin` có thông tin vùng, supplier hoặc nguồn tự có, evidence nếu policy yêu cầu.
3. QA Manager verify hoặc reject.
4. Nếu reject, record giữ trạng thái `REJECTED` và reason; không xóa hồ sơ gốc.
5. Nếu verify, `source_origin` có thể dùng cho raw material intake theo policy.

### 3.2 Raw Material Intake

1. Warehouse Operator tạo raw intake với ingredient, quantity, UOM, supplier/source origin.
2. API validate quantity, UOM, source/supplier rule.
3. Khi confirm, hệ thống tạo raw material lot `PENDING_QC`.
4. Nếu source origin required nhưng chưa `VERIFIED`, API reject.

### 3.3 Raw Material QC

1. QA Inspector tạo/sign QC inspection cho raw lot.
2. Kết quả:
   - `QC_PASS`: lot eligible cho readiness transition, chưa được issue nếu chưa `READY_FOR_PRODUCTION`.
   - `QC_HOLD`: lot bị chặn issue, cần investigation/retest.
   - `QC_REJECT`: lot bị reject/disposition, không issue.
3. QC signed record append-only; correction tạo record mới.

### 3.4 Raw Lot Readiness

1. Sau khi QC result là `QC_PASS`, QA Manager hoặc Warehouse Manager có quyền phù hợp thực hiện `RAW_LOT_MARK_READY`.
2. Hệ thống kiểm tra source/readiness, không active hold, không reject/quarantine/expired, và lot còn available balance.
3. Nếu đạt, lot chuyển sang `READY_FOR_PRODUCTION`, ghi `state_transition_log`, audit và event `RAW_LOT_READY_FOR_PRODUCTION`.
4. Nếu không đạt, lot giữ trạng thái not-ready/blocked và material issue phải reject bằng `LOT_NOT_READY_FOR_PRODUCTION`.

### 3.5 Recipe Snapshot

1. Recipe active version phải được approve, có effective date và trạng thái active operational.
2. Recipe line phải thuộc đúng 4 nhóm:
   - `SPECIAL_SKU_COMPONENT`
   - `NUTRITION_BASE`
   - `BROTH_EXTRACT`
   - `SEASONING_FLAVOR`
3. Production order snapshot toàn bộ line cần cho sản xuất.
4. Recipe version tương lai như G2/G3 phải đi qua approval/activation và không sửa lịch sử production order cũ.

### 3.6 Production Order

1. Production Planner tạo PO cho SKU và planned quantity.
2. Production API resolve active recipe version.
3. Hệ thống snapshot SKU, formula code, formula version, group, ingredient, quantity, UOM, prep note, usage role vào PO.
4. Snapshot immutable sau khi PO mở/start.
5. Production Manager approve/start PO nếu đủ điều kiện.

### 3.7 Material Request / Issue / Receipt

1. Production Operator tạo material request từ PO snapshot.
2. Production Manager approve hoặc reject request.
3. Warehouse Operator execute issue:
   - raw lot phải `READY_FOR_PRODUCTION`;
   - available balance đủ;
   - không active hold/reject/quarantine/expiry;
   - line thuộc snapshot;
   - request có idempotency key.
4. Material issue post ledger decrement raw material.
5. Production Operator confirm receipt tại xưởng.
6. Receipt ghi variance nếu có, nhưng không trừ kho lần hai.

### 3.8 Batch Execution

1. Batch/work order bắt đầu sau khi material receipt đủ.
2. Process events phải ghi theo thứ tự được chấp nhận trong source docs/spec:
   - `PREPROCESSING`
   - `FREEZING`
   - `FREEZE_DRYING`
3. Halt/correction phải có reason và audit.
4. Batch chỉ sang downstream khi required process events hoàn tất.

### 3.9 Packaging / Printing / QR

1. Packaging job tạo từ batch đủ điều kiện.
2. Trade item/GTIN tách khỏi SKU identity.
3. QR được generate theo packaging unit/job.
4. Print job đưa QR vào queue và cập nhật lifecycle:
   - `GENERATED`
   - `QUEUED`
   - `PRINTED`
   - `FAILED`
   - `VOID`
   - `REPRINTED`
5. Void/reprint bắt buộc reason và audit.

### 3.10 QC / Release / Warehouse

1. QA Inspector sign QC inspection cho batch/scope tương ứng.
2. `QC_PASS` chỉ là điều kiện để request release, không tự tạo release.
3. QA Manager approve release để batch có release record `APPROVED_RELEASED`.
4. Warehouse receipt chỉ nhận batch đã release.
5. Confirm warehouse receipt post finished goods inventory ledger và lot balance projection.

### 3.11 Trace / Public Trace / Recall / MISA

1. Internal trace liên kết source origin, raw lot, issue, batch, packaging, QR, warehouse, shipment nếu có.
2. Public trace dùng projection whitelist-only, không expose supplier/personnel/cost/QC defect/loss/MISA.
3. Recall case mở từ incident hoặc trace finding.
4. Impact analysis tạo snapshot exposure; re-run tạo snapshot version mới.
5. Hold/sale lock/recovery/disposition/CAPA phải hoàn tất trước close.
6. MISA sync nhận event từ outbox/integration layer, mapping rồi sync/retry/reconcile.

## 4. Mandatory Blocking Rules

| rule_id | Rule | Blocking point | Error/response |
|---|---|---|---|
| FLOW-BLOCK-001 | Source origin required but not verified | Raw intake | `SOURCE_ORIGIN_NOT_VERIFIED` |
| FLOW-BLOCK-002 | Raw lot not `READY_FOR_PRODUCTION` | Material issue | `LOT_NOT_READY_FOR_PRODUCTION` |
| FLOW-BLOCK-003 | Material line outside PO snapshot | Material request/issue | `OUTSIDE_SNAPSHOT_MATERIAL` |
| FLOW-BLOCK-004 | Insufficient lot balance | Material issue | `INSUFFICIENT_BALANCE` |
| FLOW-BLOCK-005 | Missing active approved recipe | Production order | `ACTIVE_RECIPE_NOT_FOUND` |
| FLOW-BLOCK-006 | Snapshot incomplete | Production order/print | `SNAPSHOT_INCOMPLETE` |
| FLOW-BLOCK-007 | QC result not pass or active hold | Batch release | `QC_NOT_PASS`, `HOLD_ACTIVE` |
| FLOW-BLOCK-008 | Batch not released | Warehouse receipt | `BATCH_NOT_RELEASED` |
| FLOW-BLOCK-009 | Public trace field policy violation | Public trace preview/publish | `PUBLIC_FIELD_POLICY_VIOLATION` |
| FLOW-BLOCK-010 | MISA mapping missing | MISA sync | `MISA_MAPPING_MISSING` |

## 5. Events Emitted

| event | Emitted by | Consumer |
|---|---|---|
| `SOURCE_ORIGIN_VERIFIED` | Source origin verification | Raw intake readiness, audit |
| `RAW_LOT_CREATED` | Raw intake | QC queue, trace |
| `RAW_LOT_QC_SIGNED` | Raw QC | Lot readiness review, audit |
| `RAW_LOT_READY_FOR_PRODUCTION` | Lot readiness transition | Material issue, trace, dashboard/readiness queue |
| `RECIPE_ACTIVATED` | Recipe approval | Production planning |
| `PRODUCTION_ORDER_CREATED` | Production order | Material request, trace root |
| `MATERIAL_ISSUE_EXECUTED` | Material issue | Inventory ledger, trace, MISA outbox |
| `MATERIAL_RECEIPT_CONFIRMED` | Material receipt | Production execution |
| `BATCH_PROCESS_COMPLETED` | Batch execution | Packaging/QC queue |
| `QR_PRINTED` | Print/QR | Public trace projection |
| `BATCH_RELEASED` | Batch release | Warehouse receipt, trace, MISA outbox |
| `WAREHOUSE_RECEIPT_CONFIRMED` | Warehouse | Inventory ledger, MISA outbox |
| `TRACE_GAP_DETECTED` | Trace service | Alert/recall review |
| `RECALL_HOLD_APPLIED` | Recall | Inventory/sale lock, MISA/outbox if needed |
| `MISA_SYNC_FAILED` | Integration | Integration dashboard/retry |

## 6. Done Gate

- Một SKU baseline có active G1 recipe version và đủ 4 group.
- Một raw lot chỉ có thể issue vào PO snapshot sau khi đã `QC_PASS` và được mark `READY_FOR_PRODUCTION`.
- Material issue tạo ledger decrement đúng một lần.
- Material receipt không tạo decrement.
- Batch `QC_PASS` vẫn chưa vào warehouse nếu chưa release.
- Warehouse receipt tạo FG ledger và lot balance.
- Public trace trả response whitelist-only.
- MISA sync event đi qua mapping/retry/reconcile.
