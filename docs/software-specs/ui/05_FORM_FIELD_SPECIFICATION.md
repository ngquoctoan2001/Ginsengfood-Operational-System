# 05 Form Field Specification

## 1. Mục tiêu

Tài liệu này chuẩn hóa field, kiểu nhập liệu, validation, source option và rule enabled/visible cho các form nghiệp vụ chính. FE dùng tài liệu này để build form; BE/QA dùng để đối chiếu request validation.

## 2. Quy tắc field chung

| Field type | Component gợi ý | Validation chung | Ghi chú |
|---|---|---|---|
| `code` | text input uppercase | required, unique nếu là master code, trim, không khoảng trắng đầu/cuối | Backend quyết định regex cuối cùng. |
| `text` | text input/textarea | max length theo schema, trim | Không dùng để chứa JSON. |
| `decimal` | numeric input | decimal precision, `> 0` hoặc `>= 0` theo field | Không dùng float trong API. |
| `quantity` | decimal input + UOM | quantity rule theo transaction | Phải hiển thị UOM gần field. |
| `date` | date picker | valid ISO date | Effective date không được mơ hồ timezone. |
| `datetime` | date time picker | ISO-8601 | Backend lưu timezone chuẩn. |
| `select` | combobox | option phải active nếu tạo mới | Data source API rõ ràng. |
| `status` | badge/select nếu filter | enum từ `database/04_ENUM_REFERENCE.md` | Không hardcode label trái enum. |
| `reason` | textarea | required cho reject/cancel/hold/release hold/override | Audit phải lưu reason. |
| `attachment` | upload/list | file type/size [OWNER DECISION NEEDED] | Không upload nếu chưa có storage policy. |
| `scan` | scanner input | checksum/pattern nếu có | PWA/offline phải giữ raw scan value. |

## 3. Field Matrix Theo Form

| form_id | field_key | label | type | required_when | source/options API | validation | visibility/enabled rules | error |
|---|---|---|---|---|---|---|---|---|
| FORM-UOM | code | UOM Code | code | create | none | unique; required | disabled after create | `DUPLICATE_CODE`, `VALIDATION_ERROR` |
| FORM-UOM | display_name | Display Name | text | always | none | required; max length [CHƯA XÁC MINH] | enabled if `uom.write` | `VALIDATION_ERROR` |
| FORM-SUPPLIER | supplier_code | Supplier Code | code | create | none | unique | disabled after create | `DUPLICATE_CODE` |
| FORM-SUPPLIER | name | Supplier Name | text | always | none | required | enabled if `supplier.write` | `VALIDATION_ERROR` |
| FORM-SUPPLIER | tax_code | Tax Code | text | optional | none | format [OWNER DECISION NEEDED] | enabled if `supplier.write` | `VALIDATION_ERROR` |
| FORM-WAREHOUSE | warehouse_code | Warehouse Code | code | create | none | unique | disabled after create | `DUPLICATE_CODE` |
| FORM-WAREHOUSE | warehouse_type | Warehouse Type | select | always | enum `WAREHOUSE_TYPE` | required | enabled if `warehouse.write` | `VALIDATION_ERROR` |
| FORM-SKU | sku_code | SKU Code | code | create | none | unique; baseline seed code must not duplicate | disabled after create | `DUPLICATE_SKU_CODE` |
| FORM-SKU | display_name | Display Name | text | always | none | required | enabled if `sku.write` | `VALIDATION_ERROR` |
| FORM-SKU | public_name | Public Name | text | when public trace enabled | none | required if exposed public | enabled if `sku.write` | `PUBLIC_FIELD_POLICY_VIOLATION` |
| FORM-INGREDIENT | ingredient_code | Ingredient Code | code | create | none | unique | disabled after create | `DUPLICATE_INGREDIENT_CODE` |
| FORM-INGREDIENT | uom_code | UOM | select | always | `GET /api/admin/uom?active=true` | required | enabled if draft/active edit allowed | `VALIDATION_ERROR` |
| FORM-INGREDIENT | ingredient_type | Ingredient Type | select | always | enum `INGREDIENT_TYPE` | required | enabled if `ingredient.write` | `VALIDATION_ERROR` |
| FORM-RECIPE | sku_id | SKU | select | create draft | `GET /api/admin/skus?active=true` | required; active SKU | disabled after recipe submit | `VALIDATION_ERROR` |
| FORM-RECIPE | formula_version | Formula Version | text/select | create draft | generated or manual [OWNER DECISION NEEDED] | G1 baseline initially; future G2/G3 supported; no non-operational baseline in active flows | disabled after submit | `NON_OPERATIONAL_RECIPE_VERSION`, `VALIDATION_ERROR` |
| FORM-RECIPE | effective_date | Effective Date | date | submit/approve | none | required before activation | enabled until approved | `VALIDATION_ERROR` |
| FORM-RECIPE | approval_note | Approval Note | textarea | approve/reject | none | required on reject; optional on approve | visible to approver | `APPROVAL_REASON_REQUIRED` |
| FORM-RECIPE-LINE | group_code | Recipe Group | select | always | enum recipe groups | exactly one of 4 groups | enabled only DRAFT | `INVALID_RECIPE_GROUP` |
| FORM-RECIPE-LINE | ingredient_code | Ingredient | select | always | `GET /api/admin/ingredients?active=true` | required; active ingredient | enabled only DRAFT | `INGREDIENT_NOT_FOUND` |
| FORM-RECIPE-LINE | quantity_per_batch | Quantity Per Batch | decimal | always | none | > 0 | enabled only DRAFT | `VALIDATION_ERROR` |
| FORM-SOURCE-ZONE | zone_code | Zone Code | code | create | none | unique | disabled after create | `DUPLICATE_CODE` |
| FORM-SOURCE-ZONE | name | Zone Name | text | always | none | required | enabled if `source_zone.write` | `VALIDATION_ERROR` |
| FORM-SOURCE-ORIGIN | origin_code | Origin Code | code | create | none | unique | disabled after create | `DUPLICATE_CODE` |
| FORM-SOURCE-ORIGIN | zone_id | Source Zone | select | always | `GET /api/admin/source-zones?active=true` | required | enabled until verified unless correction approved | `VALIDATION_ERROR` |
| FORM-SOURCE-ORIGIN | supplier_id | Supplier | select | always | `GET /api/admin/suppliers?active=true` | required if supplier-linked | enabled until verified | `VALIDATION_ERROR` |
| FORM-SOURCE-ORIGIN | public_summary | Public Summary | textarea | when public origin exposed | none | no internal supplier/personnel/cost | enabled if `public_trace.preview`/approved role | `PUBLIC_FIELD_POLICY_VIOLATION` |
| FORM-SOURCE-VERIFY | decision | Verification Decision | select | always | `VERIFIED`, `REJECTED` | required | visible to QA Manager/authorized verifier | `VALIDATION_ERROR` |
| FORM-SOURCE-VERIFY | reason | Reason | textarea | reject | none | required on reject | visible when reject | `REJECT_REASON_REQUIRED` |
| FORM-RAW-INTAKE | supplier_id | Supplier | select | always | `GET /api/admin/suppliers?active=true` | required if supplier flow | enabled in DRAFT | `VALIDATION_ERROR` |
| FORM-RAW-INTAKE | source_origin_id | Source Origin | select | when origin required | `GET /api/admin/source-origins?verification_status=VERIFIED` | must be verified | enabled in DRAFT | `SOURCE_ORIGIN_NOT_VERIFIED` |
| FORM-RAW-INTAKE | ingredient_id | Ingredient | select | always | `GET /api/admin/ingredients?active=true` | required | enabled in DRAFT | `VALIDATION_ERROR` |
| FORM-RAW-INTAKE | quantity | Quantity | decimal | always | none | > 0 | enabled in DRAFT | `VALIDATION_ERROR` |
| FORM-RAW-INTAKE | received_at | Received At | datetime | receive | none | not future beyond tolerance [OWNER DECISION NEEDED] | set on receive | `VALIDATION_ERROR` |
| FORM-RAW-QC | lot_id | Raw Lot | select/scan | always | `GET /api/admin/raw-material/lots` | required | disabled after result submit | `RAW_LOT_NOT_FOUND` |
| FORM-RAW-QC | result | QC Result | select | submit result | enum `QC_PASS`, `QC_HOLD`, `QC_REJECT` | required | enabled if inspection open | `INVALID_QC_RESULT` |
| FORM-RAW-QC | note | QC Note | textarea | hold/reject | none | required for HOLD/REJECT | enabled if inspection open | `QC_NOTE_REQUIRED` |
| FORM-LOT-MARK-READY | lot_id | Raw Lot | select/scan | mark ready | `GET /api/admin/raw-material/lots?qcStatus=QC_PASS` + readiness check | required; lot not hold/reject/quarantine | enabled if user has `raw_lot.mark_ready` and lot not `READY_FOR_PRODUCTION` | `RAW_MATERIAL_LOT_QC_NOT_PASSED`, `LOT_QUARANTINED`, `STATE_CONFLICT` |
| FORM-LOT-MARK-READY | targetLotStatus | Target Lot Status | status | mark ready | fixed `READY_FOR_PRODUCTION` | required; cannot choose another status | readonly | `VALIDATION_FAILED` |
| FORM-LOT-MARK-READY | reasonText | Readiness Reason | reason | mark ready | none | required if policy requires reason/audit | enabled before submit | `REASON_REQUIRED` |
| FORM-PROD-ORDER | sku_id | SKU | select | create | `GET /api/admin/skus?active=true` | required | disabled after start | `SKU_NOT_FOUND` |
| FORM-PROD-ORDER | planned_qty | Planned Quantity | decimal | create | none | > 0 | editable before start | `VALIDATION_ERROR` |
| FORM-PROD-ORDER | batch_size | Batch Size | decimal | create | none | > 0; default 400 if owner accepted | editable before start | `VALIDATION_ERROR` |
| FORM-PROD-ORDER | formula_version | Formula Version | select/readonly | create | `GET /api/admin/recipes?sku_id=&active=true` | active version required | readonly after create | `RECIPE_ACTIVE_VERSION_MISSING` |
| FORM-MATERIAL-REQUEST | production_order_id | Production Order | select | create | `GET /api/admin/production-orders?status=STARTED` | required | disabled after submit | `PRODUCTION_ORDER_NOT_FOUND` |
| FORM-MATERIAL-REQUEST | lines | Requested Lines | line grid | create | production order snapshot | each ingredient must be in snapshot | editable before submit | `OUTSIDE_SNAPSHOT_MATERIAL` |
| FORM-MATERIAL-REQUEST | due_at | Due At | datetime | optional | none | valid datetime | editable before approval | `VALIDATION_ERROR` |
| FORM-MATERIAL-ISSUE | raw_lot_id | Raw Lot | scan/select | issue | `GET /api/admin/raw-material/lots?lotStatus=READY_FOR_PRODUCTION` | `READY_FOR_PRODUCTION`; balance enough; not held/quarantined | enabled before issue | `RAW_MATERIAL_LOT_NOT_READY`, `INSUFFICIENT_BALANCE`, `LOT_QUARANTINED` |
| FORM-MATERIAL-ISSUE | issue_qty | Issue Quantity | decimal | issue | none | > 0; <= available | enabled before issue | `INSUFFICIENT_INVENTORY` |
| FORM-MATERIAL-ISSUE | warehouse_id | Warehouse | select | issue | `GET /api/admin/warehouses?active=true` | required | enabled before issue | `VALIDATION_ERROR` |
| FORM-MATERIAL-RECEIPT | received_qty | Received Quantity | decimal | confirm | none | >= 0 | enabled before confirm | `VALIDATION_ERROR` |
| FORM-MATERIAL-RECEIPT | variance_reason | Variance Reason | textarea | when received_qty != issued_qty | none | required if variance | visible when variance exists | `VARIANCE_REASON_REQUIRED` |
| FORM-QC-INSPECTION | scope | Scope | select | create | enum inspection scope | required | disabled after create | `VALIDATION_ERROR` |
| FORM-QC-INSPECTION | entity_id | Entity | select/scan | create | depends on scope | required | disabled after create | `VALIDATION_ERROR` |
| FORM-QC-INSPECTION | result | Result | select | result submit | `QC_PASS`, `QC_HOLD`, `QC_REJECT` | required | enabled if open | `INVALID_QC_RESULT` |
| FORM-BATCH-RELEASE | batch_id | Batch | select | release | `GET /api/admin/batches?qcStatus=QC_PASS&releaseStatus!=RELEASED` | QC_PASS required | enabled before release | `BATCH_NOT_QC_PASS` |
| FORM-BATCH-RELEASE | release_note | Release Note | textarea | release/reject | none | required on reject; optional release | enabled for QA Manager | `VALIDATION_ERROR` |
| FORM-WH-RECEIPT | batch_id | Batch | select/scan | create | `GET /api/admin/batches?release_status=RELEASED` | RELEASED required | disabled after create | `BATCH_NOT_RELEASED` |
| FORM-WH-RECEIPT | quantity | Quantity | decimal | confirm | none | > 0 | enabled before confirm | `VALIDATION_ERROR` |
| FORM-WH-RECEIPT | warehouse_id | Warehouse | select | create | `GET /api/admin/warehouses?active=true` | required | enabled before confirm | `VALIDATION_ERROR` |
| FORM-PACKAGING-JOB | batch_id | Batch | select | create | `GET /api/admin/batches?release_status=RELEASED` | RELEASED if packaging gate enabled | disabled after start | `BATCH_NOT_RELEASED` |
| FORM-PACKAGING-JOB | trade_item_id | Trade Item | select | create | `GET /api/admin/trade-items?active=true` | required | disabled after start | `VALIDATION_ERROR` |
| FORM-QR-GENERATE | packaging_job_id | Packaging Job | select | generate | `GET /api/admin/packaging-jobs?status=READY` | required | enabled before generate | `VALIDATION_ERROR` |
| FORM-QR-GENERATE | quantity | QR Quantity | decimal | generate | none | integer > 0 | enabled before generate | `VALIDATION_ERROR` |
| FORM-QR-VOID | reason | Void Reason | textarea | void | none | required | visible only when void action | `REASON_REQUIRED` |
| FORM-QR-REPRINT | reason | Reprint Reason | textarea | reprint | none | required | visible only when reprint action | `REASON_REQUIRED` |
| FORM-RECALL-CASE | reason | Recall Reason | textarea | create | none | required | enabled in draft/open | `VALIDATION_ERROR` |
| FORM-RECALL-CASE | severity | Severity | select | create/classify | enum `RECALL_SEVERITY` | required | enabled until approved | `VALIDATION_ERROR` |
| FORM-RECALL-CASE | scope | Scope | select | create | batch/lot/shipment/customer exposure | required | enabled until started | `VALIDATION_ERROR` |
| FORM-RECALL-CASE | close_type | Close Type | select | close | `CLOSED`, `CLOSED_WITH_RESIDUAL_RISK` | required on close | visible in close modal | `VALIDATION_ERROR` |
| FORM-RECALL-CASE | residual_note | Residual Risk Note | textarea | close_type = `CLOSED_WITH_RESIDUAL_RISK` | none | required for residual close | visible when close_type = `CLOSED_WITH_RESIDUAL_RISK` | `RECALL_RESIDUAL_RISK_NOTE_REQUIRED` |
| FORM-RECALL-HOLD | target_type | Target Type | select | create hold | enum target types | required | enabled before submit | `VALIDATION_ERROR` |
| FORM-RECALL-HOLD | target_id | Target ID | select/search | create hold | trace/impact result API | required | enabled before submit | `VALIDATION_ERROR` |
| FORM-RECALL-HOLD | hold_reason | Hold Reason | textarea | create/release | none | required | enabled for authorized role | `REASON_REQUIRED` |
| FORM-CAPA | action_type | Action Type | select | create | enum CAPA action | required | enabled if recall open | `VALIDATION_ERROR` |
| FORM-CAPA | owner | Owner | select | create | `GET /api/admin/users?role=...` [CHƯA XÁC MINH] | required | enabled if CAPA write | `VALIDATION_ERROR` |
| FORM-CAPA | evidence | Evidence | attachment/text | close | storage policy [OWNER DECISION NEEDED] | required before close | visible for close action | `EVIDENCE_REQUIRED` |
| FORM-MISA-MAPPING | internal_type | Internal Type | select | create | enum mapping type | required | disabled after create | `VALIDATION_ERROR` |
| FORM-MISA-MAPPING | internal_code | Internal Code | select/text | create | lookup by internal_type | required; unique pair | disabled after create | `MISA_MAPPING_DUPLICATE` |
| FORM-MISA-MAPPING | misa_code | MISA Code | text | create/edit | none | required | enabled if mapping write | `MISA_MAPPING_MISSING` |
| FORM-MISA-RETRY | reason | Retry Reason | textarea | manual retry | none | required if configured by owner | visible for retry | `REASON_REQUIRED` |

## 4. Command Form Rules

| Command group | Required UI behavior |
|---|---|
| Approve/Reject | Luôn có confirmation; reject bắt buộc reason; refresh record sau command. |
| Hold/Release Hold | Bắt buộc reason; hiển thị tác động inventory/sale lock nếu API trả về. |
| Cancel | Confirmation rõ ràng; chỉ hiển thị khi state cho phép. |
| Lot Mark Ready | Chỉ hiện với lot `QC_PASS` nhưng chưa `READY_FOR_PRODUCTION`; gửi `targetLotStatus=READY_FOR_PRODUCTION`, reason/audit nếu policy yêu cầu, và idempotency key. |
| Material Issue | Bắt buộc scan/select lot `READY_FOR_PRODUCTION`; hiển thị available balance; gửi idempotency key; disable submit trong khi pending. |
| Batch Release | Hiển thị QC summary; nhắc QC_PASS không đồng nghĩa RELEASED. |
| Warehouse Receipt | Chặn tại UI nếu batch chưa RELEASED nhưng vẫn cần backend enforce. |
| QR Void/Reprint | Bắt buộc reason; hiển thị lifecycle hiện tại; gửi idempotency key. |
| MISA Retry | Không cho user chọn module sync trực tiếp; chỉ retry job qua integration layer. |

## 5. Public Trace Form/Field Policy

Public trace page không có form mutate dữ liệu. Input duy nhất là `qrCode` từ route hoặc scan.

| Field | Rule |
|---|---|
| `qrCode` | Required; trim; không log raw sensitive token nếu owner xác định QR chứa token nhạy cảm. |
| Public fields | Chỉ render keys có trong `PublicTraceResponse`. |
| Forbidden fields | Không render supplier/personnel/cost/QC defect/loss/MISA kể cả API lỗi trả thừa. FE phải ignore unknown forbidden-looking fields và báo policy violation trong admin preview nếu phát hiện. |
