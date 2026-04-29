# OD-M06-SUP-COLLAB - Supplier Collaboration Extension For Raw Material Receipt

## Status

Accepted - owner approved 2026-04-29.

Áp dụng cho M06 Raw Material và mở rộng phạm vi sang M02 Auth Permission, M03 Master Data, M16 Admin UI thông qua module mới `M03A Supplier Management` (sub-capability nhóm Master Data/Auth/Admin UI, không phá numbering M01-M16).

## Context

Owner mở rộng nghiệp vụ Raw Material Receipt để hỗ trợ supplier collaboration:

- công ty hoặc supplier đều có thể tạo `op_raw_material_receipt`;
- supplier có account riêng trên Supplier Portal, scope theo `supplier_id`;
- supplier upload evidence (ảnh/video/COA/lab/delivery doc) trước khi giao;
- raw material lot chỉ được tạo sau khi công ty xác nhận đã nhận hàng vật lý;
- không tạo bảng nghiệp vụ song song `op_supplier_delivery`; tái sử dụng `op_raw_material_receipt` + `op_raw_material_receipt_item` và bổ sung trường/trạng thái/bảng evidence.

Quyết định này giải quyết 9 owner decision còn mở từ phân tích đặc tả `DAC_TA_NGHIEP_VU_SUPPLIER_COLLAB_RAW_MATERIAL_RECEIPT.md` và đăng ký module `M03A Supplier Management`.

## Decisions

### OD-M06-SUP-CANCEL-001 - Pre-receipt cancel/decline policy

- Trước khi công ty xác nhận nhận hàng vật lý, **company được cancel pre-receipt** với reason và audit.
- Supplier **không cancel** phiếu của công ty; chỉ được **decline confirmation** với reason. Khi đó `supplier_collaboration_status = SUPPLIER_DECLINED`.
- Sau khi phiếu vào `RECEIVED_PENDING_QC` hoặc đã tạo `op_raw_material_lot`, **không được cancel** theo luồng thường. Chỉ xử lý qua reject, return, correction hoặc reversal theo policy.
- **Rule**: Company can cancel pre-receipt; supplier can decline confirmation. After physical receipt or lot creation, normal cancel is blocked.

### OD-M06-SUP-EDIT-001 - Supplier edit window after SUPPLIER_CONFIRMED

- Supplier sửa trực tiếp khi phiếu `DRAFT` hoặc trước `SUPPLIER_CONFIRMED`.
- Sau `SUPPLIER_CONFIRMED`, supplier **không** được sửa trực tiếp các trường quan trọng: `ingredient`, `proposed_quantity`, `proposed_uom_code`, `expected_delivery_date`, `supplier_lot_code`, `manufacture_date`, `expiry_date`.
- Thay đổi sau confirmed phải đi qua: (1) supplier change request để công ty duyệt; hoặc (2) công ty cancel phiếu cũ và tạo/cho supplier tạo phiếu mới.
- MVP chọn phương án đơn giản: cancel + tạo lại; supplier change request là enhancement sau MVP.
- Mọi thay đổi sau confirm phải có audit, revision hoặc change request record.
- **Rule**: After `SUPPLIER_CONFIRMED`, no direct supplier edit of quantity/UOM/date/ingredient. Changes require company approval or new receipt.

### OD-M03-SUP-ING-001 - Supplier ↔ ingredient mapping ownership

- Mapping **thuộc M03 Master Data** (cụ thể M03A Supplier Management), tham chiếu `op_supplier` master của M03 và `ref_ingredient` master của M04.
- M06 chỉ **read-only consume** mapping để validate supplier có quyền tạo `op_raw_material_receipt_item` cho ingredient hay không.
- Bảng đề xuất: `op_supplier_ingredient` với fields `supplier_id`, `ingredient_id`, `default_uom_code`, `status` (`ACTIVE`/`INACTIVE`), `effective_from`, `effective_to`, `created_by`, `created_at`, `approved_by`, `approved_at`, `audit`.
- MVP chưa cần full versioning; bắt buộc có effective date, active/inactive và audit.
- Approval: Supplier Manager hoặc Master Data Steward approve mapping thường; ingredient rủi ro cao có thể yêu cầu QA Manager approve thêm theo policy.
- **Rule**: Supplier-ingredient capability is M03A-owned master/config; references M04 ingredient; must be active/effective before supplier can create receipt item.

### OD-M06-SUP-LOT-SPLIT-001 - Receipt item to lot cardinality

- Một `op_raw_material_receipt_item` có thể tạo **một hoặc nhiều** `op_raw_material_lot` (1:N).
- Lý do: cùng dòng nguyên liệu có thể tách lot do khác supplier lot code, hạn dùng, bao bì, tình trạng QC, vị trí kho.
- Invariant cứng: `SUM(lot.initial_quantity WHERE receipt_item_id = X) <= received_quantity_of(X)`.
- Lot không đạt sau QC chuyển `QC_HOLD/QC_REJECT` hoặc `lot_status = REJECTED`, không được usable.
- MVP UI có thể default 1 receipt item = 1 lot, nhưng DB/API phải hỗ trợ 1:N từ đầu để tránh migration lớn.
- **Rule**: 1 receipt item creates N raw material lots; total lot quantity cannot exceed received quantity; only `READY_FOR_PRODUCTION` lots can be issued later.

### OD-M05-INTERNAL-GROWER-001 - Self-grown out of supplier portal scope

- Supplier Collaboration **chỉ áp dụng `procurement_type = PURCHASED`**.
- `SELF_GROWN`: công ty tự tạo Raw Material Receipt qua admin UI, chọn source zone/source origin, upload evidence nếu cần, đi theo flow M05/M06 hiện tại.
- Với `SELF_GROWN`: `supplier_id = NULL`, `supplier_collaboration_status = NOT_REQUIRED`.
- Future Source Origin Operator Portal cho vùng trồng nội bộ là **ADR riêng thuộc M05**, không reuse `R_SUPPLIER`.
- **Rule**: Supplier portal scope is `PURCHASED` only. `SELF_GROWN` uses Source Origin flow; future internal grower portal is separate ADR under M05.

### OD-M06-SUP-EVIDENCE-001 - Evidence required policy

- Evidence required **policy-driven** theo supplier/ingredient/risk, không hard-code toàn hệ thống.
- MVP default:
  - mọi phiếu `PURCHASED` cần ít nhất 1 ảnh hàng hóa trước khi giao;
  - video optional trừ khi policy yêu cầu;
  - COA/lab report/chứng nhận bắt buộc khi `op_supplier_ingredient` policy hoặc ingredient master yêu cầu.
- Policy fields đề xuất trên `op_supplier_ingredient` cho MVP: `requires_photo`, `requires_video`, `requires_coa`, `requires_lab_report`, `min_photo_count`, `min_video_count`.
- Future tách bảng riêng `op_supplier_evidence_policy` nếu cần.
- Phiếu công ty tạo trước **không được** chuyển `WAITING_DELIVERY` nếu supplier chưa upload đủ evidence bắt buộc.
- **Rule**: Evidence required is policy-driven by supplier/ingredient/risk. MVP requires at least one photo for `PURCHASED`; COA/lab required when configured.

### OD-M06-SUP-LOT-TIMING-001 - Lot creation timing

- Raw material lot được tạo **chỉ khi** công ty thực hiện action `receive` và phiếu chuyển sang `RECEIVED_PENDING_QC`.
- Không tạo lot ở: `DRAFT`, `PENDING_SUPPLIER_CONFIRMATION`, `EVIDENCE_REQUIRED`, `SUPPLIER_SUBMITTED`, `SUPPLIER_CONFIRMED`, `WAITING_DELIVERY`, `DELIVERED_PENDING_RECEIPT`.
- Lot khởi tạo ở trạng thái: `lot_status = CREATED`, `lot_qc_status = PENDING_QC`.
- Sau khi tạo, QC được thực hiện ở cấp lot bằng endpoint lot QC hiện có (`POST /api/admin/raw-material/lots/{lotId}/qc-inspections`).
- `QC_PASS` vẫn **chưa** usable; phải qua `RAW_LOT_MARK_READY` để chuyển `lot_status = READY_FOR_PRODUCTION`.
- `QC_HOLD/QC_REJECT` chặn issue.
- Partial accept/partial reject xử lý bằng lot state/QC result, không bypass lot QC.
- **Rule**: Lot is created only after company physical receive. Lot starts at `CREATED + PENDING_QC` and is not usable until `QC_PASS` + `RAW_LOT_MARK_READY` → `READY_FOR_PRODUCTION`.
- **Chuẩn enum chính thức** (xóa câu "tùy enum cuối cùng"): `lot_status = CREATED` khi vừa tạo; `lot_qc_status = PENDING_QC` khi chờ QC.

### OD-GLOSSARY-QTY-001 - Glossary và validation invariant

Bắt buộc cập nhật `03_GLOSSARY.md` và các file database/API/UI liên quan:

| Term                            | Định nghĩa                                                             |
| ------------------------------- | ---------------------------------------------------------------------- |
| `proposed_quantity`             | Số lượng dự kiến do supplier hoặc công ty khai báo trước khi hàng đến. |
| `proposed_uom_code`             | UOM của số lượng dự kiến.                                              |
| `received_quantity`             | Số lượng công ty xác nhận thực nhận khi hàng đến.                      |
| `accepted_quantity`             | Số lượng được chấp nhận sau kiểm tra/QC theo policy.                   |
| `rejected_quantity`             | Số lượng không đạt/chưa được chấp nhận.                                |
| `returned_quantity`             | Số lượng trả lại supplier.                                             |
| `raw_receipt_status`            | Trạng thái nghiệp vụ của phiếu nguyên liệu đầu vào.                    |
| `supplier_collaboration_status` | Trạng thái tương tác giữa công ty và supplier trên phiếu `PURCHASED`.  |
| `lot_status`                    | Trạng thái vòng đời của raw material lot.                              |
| `lot_qc_status`                 | Trạng thái QC của raw material lot.                                    |

Validation invariant (DB CHECK + VAL-\* rule):

```text
received_quantity   >= 0
accepted_quantity   >= 0
rejected_quantity   >= 0
returned_quantity   >= 0
accepted_quantity + rejected_quantity <= received_quantity
returned_quantity   <= rejected_quantity
SUM(lot.initial_quantity WHERE receipt_item_id = X) <= received_quantity_of(X)
issue eligibility = (lot_status = READY_FOR_PRODUCTION)
```

- **Rule**: All new quantity/status terms must be added to glossary and validated consistently in DB/API/UI.

### OD-M12-PTRACE-SUP-EVIDENCE-001 - Public trace exposure of supplier evidence

- Supplier evidence **tuyệt đối không** được expose qua `/api/public/trace/{qrCode}`.
- Các trường cấm xuất hiện: `evidence_uri`, `storage_path`, `original_filename`, supplier internal id, supplier document, COA/lab report file, damage photo, delivery document, company internal note, supplier note, scan result payload, QC internal note, cost/costing, MISA data.
- Nếu sau này muốn công bố một phần chứng nhận/nguồn gốc cho khách hàng, phải tạo field public riêng đã qua QA/Owner duyệt; không reuse `evidence_uri`/file gốc.
- Public trace giữ whitelist DTO/projection.
- **Rule**: Supplier evidence and receipt evidence are internal/controlled. Public trace is whitelist-only and must never expose evidence URI/file/path/internal notes.

### OD-MODULE-M03A-001 - Module M03A Supplier Management

- Tách Supplier Management thành **M03A Supplier Management** thuộc nhóm Master Data/Auth/Admin UI.
- Không tạo M17; giữ nguyên numbering M01-M16. M03A là sub-capability đăng ký kèm M03/M02/M16.
- M03A phối hợp:
  - **M03 Master Data**: supplier master (`op_supplier`), supplier ingredient capability (`op_supplier_ingredient`).
  - **M02 Auth Permission**: supplier user (`user_type = SUPPLIER_USER`), role `R_SUPPLIER`, password lifecycle (create temp, reset, lock/unlock), namespace permission `supplier.*`.
  - **M16 Admin UI**: Supplier Management screens (admin) và Supplier Portal screens.
  - **M06 Raw Material**: chỉ consume mapping/identity; không sở hữu account/password/master.
- M06 sở hữu duy nhất: `op_raw_material_receipt`, `op_raw_material_receipt_item`, `op_raw_material_receipt_evidence`, `op_raw_material_receipt_feedback`, `receive` action, `op_raw_material_lot` lifecycle, raw lot QC.
- **Rule**: Supplier account, password, supplier master và supplier-ingredient mapping không thuộc M06. M06 chỉ consume.

## Hard Locks Đăng Ký

| Hard lock    | Nội dung                                                                                                                                                                                              |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `HL-SUP-001` | Supplier user chỉ thấy `op_raw_material_receipt` thuộc `supplier_id` của mình.                                                                                                                        |
| `HL-SUP-002` | Supplier chỉ chọn ingredient được công ty gán qua `op_supplier_ingredient` `ACTIVE` và effective.                                                                                                     |
| `HL-SUP-003` | Supplier hoặc công ty tạo Raw Material Receipt trước **không** tạo raw material lot usable.                                                                                                           |
| `HL-SUP-004` | Raw material lot chỉ được tạo sau khi công ty xác nhận nhận hàng vật lý (action `receive`).                                                                                                           |
| `HL-SUP-005` | Company-created `PURCHASED` receipt phải được supplier xác nhận và upload evidence bắt buộc trước khi chuyển `WAITING_DELIVERY`.                                                                      |
| `HL-SUP-006` | Evidence không lưu blob trong PostgreSQL; chỉ lưu URI/hash/metadata. Storage adapter pluggable (LOCAL_FS dev, COMPANY_FILE_SERVER prod).                                                              |
| `HL-SUP-007` | Supplier không được thấy cost, inventory, formula, MISA, internal trace, supplier khác, batch sản xuất, customer/order/shipment.                                                                      |
| `HL-SUP-008` | Supplier password không lưu plaintext; chỉ hiển thị mật khẩu tạm một lần khi tạo/reset.                                                                                                               |
| `HL-SUP-009` | Supplier-created receipt luôn set cứng `procurement_type = PURCHASED` và `supplier_id` theo account; supplier không được tự đổi.                                                                      |
| `HL-SUP-010` | Phần nguyên liệu `rejected`/`returned` không được tạo lot usable cho sản xuất.                                                                                                                        |
| `HL-SUP-011` | Sau `RECEIVED_PENDING_QC` hoặc khi đã tạo `op_raw_material_lot`, normal cancel bị chặn; chỉ reject/return/correction/reversal theo policy.                                                            |
| `HL-SUP-012` | Sau `SUPPLIER_CONFIRMED`, supplier không được sửa trực tiếp `ingredient`, `proposed_quantity`, `proposed_uom_code`, `expected_delivery_date`, `supplier_lot_code`, `manufacture_date`, `expiry_date`. |
| `HL-SUP-013` | `op_supplier_ingredient` thuộc M03A; M06 read-only consume. Supplier chỉ tạo receipt item khi mapping `ACTIVE` và còn `effective_from/to`.                                                            |
| `HL-SUP-014` | `SUM(lot.initial_quantity WHERE receipt_item_id = X) <= received_quantity_of(X)`.                                                                                                                     |
| `HL-SUP-015` | Supplier portal scope = `PURCHASED` only. `SELF_GROWN` dùng flow M05/M06; future internal grower portal là ADR riêng thuộc M05.                                                                       |
| `HL-SUP-016` | Evidence required policy-driven theo `op_supplier_ingredient` (và future `op_supplier_evidence_policy`); MVP default ≥1 photo cho `PURCHASED`.                                                        |
| `HL-SUP-017` | Supplier evidence và receipt evidence không được expose qua public trace; public trace whitelist-only.                                                                                                |

## Enum Đăng Ký Chính Thức

### `raw_receipt_status`

```text
DRAFT
WAITING_DELIVERY
DELIVERED_PENDING_RECEIPT
RECEIVED_PENDING_QC
QC_IN_PROGRESS
ACCEPTED
PARTIALLY_ACCEPTED
REJECTED
RETURNED
CANCELLED
CLOSED
```

### `supplier_collaboration_status`

```text
NOT_REQUIRED
PENDING_SUPPLIER_CONFIRMATION
EVIDENCE_REQUIRED
SUPPLIER_SUBMITTED
SUPPLIER_CONFIRMED
SUPPLIER_DECLINED
SUPPLIER_CANCELLED
```

### `lot_qc_status` (chốt cứng)

```text
PENDING_QC
IN_QC
QC_PASS
QC_HOLD
QC_REJECT
```

`lot_status` giữ nguyên: `CREATED, IN_QC, ON_HOLD, REJECTED, READY_FOR_PRODUCTION, CONSUMED, EXPIRED, QUARANTINED`.

Lot khởi tạo bắt buộc: `lot_status = CREATED`, `lot_qc_status = PENDING_QC`.

## Tác động (Consequences)

### Database

- ALTER `op_raw_material_receipt` (header fields mới: `created_by_party`, `purchase_request_ref`, `expected_delivery_date`, `delivered_at`, `received_at`, `received_by`, `receipt_status`, `supplier_collaboration_status`, `evidence_required_flag`, `evidence_status`, `supplier_note`, `company_note`, `closed_at`, `cancel_reason`).
- ALTER `op_raw_material_receipt_item` (`proposed_quantity`, `proposed_uom_code`, `received_quantity`, `accepted_quantity`, `rejected_quantity`, `returned_quantity`, `supplier_lot_code`, `manufacture_date`, `expiry_date`, `line_status`, `rejection_reason`).
- CREATE `op_raw_material_receipt_evidence` (M06 owned).
- CREATE `op_raw_material_receipt_feedback` (M06 owned).
- CREATE `op_supplier_ingredient` (M03A owned, có evidence policy fields).
- CREATE `op_supplier_user` hoặc mở rộng `auth_user` với `user_type = SUPPLIER_USER` (M02 owned).
- Bổ sung enum `raw_receipt_status`, `supplier_collaboration_status`, `lot_qc_status`, `evidence_type`, `evidence_status`, `created_by_party`, `feedback_type`, `user_type`.
- DB CHECK constraint cho quantity invariant (xem OD-GLOSSARY-QTY-001).

### API

- Mở rộng route admin `/api/admin/raw-material/intakes/*`: `submit`, `request-supplier-evidence`, `supplier-confirmation`, `receive`, `start-qc`, `qc-result`, `return`, `cancel`, `evidence`.
- Tạo route family mới `/api/supplier/raw-material/intakes/*` cho Supplier Portal: `list`, `create`, `update`, `submit`, `confirm`, `decline-confirmation`, `evidence`, `cancel` (DRAFT only).
- Tạo route admin Supplier Management: `/api/admin/suppliers/*` (M03A): supplier CRUD, supplier user lifecycle (create/reset/lock/unlock), `op_supplier_ingredient` CRUD/approve.
- Tách DTO `SupplierIntakeResponse` riêng, không reuse Admin DTO.
- Bổ sung error codes: `SUPPLIER_INGREDIENT_NOT_ALLOWED`, `SUPPLIER_EVIDENCE_REQUIRED`, `SUPPLIER_DECLINED_BLOCKED`, `RECEIPT_LOCKED_AFTER_RECEIVE`, `LOT_QUANTITY_EXCEEDS_RECEIVED`, `RECEIPT_QUANTITY_INVARIANT_FAILED`, `SUPPLIER_EDIT_LOCKED_AFTER_CONFIRMED`.
- Idempotency-Key bắt buộc cho `submit/confirm/decline-confirmation/receive/start-qc/qc-result/return/cancel/evidence`.

### UI

- Admin: thêm screens `SCR-RAW-INTAKE-DETAIL`, `SCR-RAW-RECEIVE`, `SCR-RAW-LINE-QC`, `SCR-SUP-MGMT-LIST`, `SCR-SUP-MGMT-DETAIL`, `SCR-SUP-INGREDIENT-MAPPING`, `SCR-SUP-USER-LIFECYCLE`.
- Supplier Portal IA mới: `/supplier/raw-material/intakes`, `/supplier/raw-material/intakes/{id}`, `/supplier/raw-material/intakes/{id}/evidence`.
- `TBL-RAW-INTAKE` thêm filter: `procurement_type`, `supplier_collaboration_status`, `evidence_status`, `created_by_party`.
- UI-VAL-SUP-\* cho HL-SUP-001..017.

### Workflow

- Cập nhật `workflows/04_STATE_MACHINES.md` với 2 trục `raw_receipt_status` × `supplier_collaboration_status`.
- Insert pre-receipt block trước intake hiện tại trong `workflows/05_CANONICAL_OPERATIONAL_FLOW.md`.
- Bổ sung approval `AP-SUP-CONFIRM`, `AP-SUP-EVIDENCE-REVIEW` trong `workflows/06_APPROVAL_WORKFLOWS.md`.
- Bổ sung exception `EX-SUP-DECLINE`, `EX-RECEIPT-RETURN` trong `workflows/07_EXCEPTION_FLOWS.md`.
- Bổ sung smoke `SMK-SUP-001..006` trong `workflows/08_SMOKE_WORKFLOW.md`.

### Phase

- Tạo phase mới `CODE01A` (M03A): supplier master, supplier user, `op_supplier_ingredient`, admin UI, supplier portal foundation. Depend `CODE01`.
- Mở rộng `CODE02` (M06): pre-receipt company-create, supplier collaboration actions, evidence, receive sinh lot, partial accept, supplier portal raw-material screens. Depend `CODE01A`.
- `CODE03+` không đổi, vẫn consume `READY_FOR_PRODUCTION` lot.

### Testing

- Test plan các AC-SUP-001..015 + invariant lot quantity + supplier scope security + evidence required policy + public trace whitelist.

## Open Risks

1. **Storage provider thực tế** cho evidence cần ADR riêng (LOCAL_FS dev vs file server prod vs S3-compatible).
2. **Anti-malware/checksum SLA** cho `scan_status`/`evidence_hash`: cần policy thời gian quét trước khi cho phép `confirm`.
3. **Supplier change request workflow** (sau MVP): cần ADR mới và bảng `op_raw_material_receipt_change_request` nếu owner kích hoạt.
4. **Evidence policy**: MVP để fields trên `op_supplier_ingredient`; nếu phình to phải tách `op_supplier_evidence_policy`.
5. **Permission coupling M02 ↔ M03A**: namespace `supplier.*` phải tách hẳn để grant `R_SUPPLIER` không vô tình kế thừa `raw_intake.read` của staff role.

## Source Updates

Khi áp dụng decision này, các file sau phải được cập nhật:

- `docs/software-specs/00_README.md` - thêm hard locks `HL-SUP-001..017`.
- `docs/software-specs/06_MODULE_MAP.md` - đăng ký `M03A Supplier Management` và làm rõ M06 chỉ consume.
- `docs/software-specs/09_CONFLICT_AND_OWNER_DECISIONS.md` - đăng ký 9 OD và `CONFLICT-17 Supplier Collaboration`.
- `docs/software-specs/03_GLOSSARY.md` - thêm 10 thuật ngữ `OD-GLOSSARY-QTY-001`.
- `docs/software-specs/database/04_ENUM_REFERENCE.md` - thêm enum `raw_receipt_status`, `supplier_collaboration_status`, `lot_qc_status`, `evidence_type`, `evidence_status`, `created_by_party`, `feedback_type`, `user_type`.
- `docs/software-specs/database/08_MIGRATION_STRATEGY.md` - bổ sung migration nhóm M03A và mở rộng M06.
- `docs/software-specs/modules/06_RAW_MATERIAL.md` - mở rộng boundary, BR, table, API, screen, state machine, validation, test, phase.
- `docs/software-specs/modules/03A_SUPPLIER_MANAGEMENT.md` (mới) - full module spec M03A.
- `docs/software-specs/api/` - endpoint catalog, DTO, error codes mới.
- `docs/software-specs/ui/` - IA, screen catalog, table/filter, FE API client (admin + supplier).
- `docs/software-specs/workflows/04_STATE_MACHINES.md`, `05_CANONICAL_OPERATIONAL_FLOW.md`, `06_APPROVAL_WORKFLOWS.md`, `07_EXCEPTION_FLOWS.md`, `08_SMOKE_WORKFLOW.md`.
- `docs/software-specs/business/` - role/permission `R_SUPPLIER` + namespace `supplier.*`.
- `docs/software-specs/functional/01_MODULE_FUNCTION_MATRIX.md`, `02_USE_CASE_CATALOG.md`.
- `docs/software-specs/testing/` - test plan AC-SUP-\*.
- `docs/software-specs/phase-project/05_DETAILED_PHASE_PROMPTS/01A_CODE01A_M03A_SUPPLIER_MANAGEMENT_PROMPTS.md` (mới).
- `docs/software-specs/phase-project/05_DETAILED_PHASE_PROMPTS/02_CODE02_RAW_MATERIAL_PROMPTS.md` - thêm prompt 02.09..02.13 supplier collaboration.

## History

| Date       | Change                                                                                                                                                                                                                          | Owner |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| 2026-04-29 | Owner approved 9 OD (OD-M06-SUP-CANCEL-001 .. OD-M12-PTRACE-SUP-EVIDENCE-001) and OD-MODULE-M03A-001. Registered hard locks `HL-SUP-001..017` and enums `raw_receipt_status`, `supplier_collaboration_status`, `lot_qc_status`. | owner |
