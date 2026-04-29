# 00 - README

> Bộ tài liệu `docs/software-specs/` là bộ đặc tả phát triển phần mềm cho Operational Domain của Ginsengfood. Tài liệu này dùng cho Owner, BA/SA, PM, Backend, Frontend, QA/QC, DevOps và AI coding agent.

## 1. Mục Đích

Bộ tài liệu này chuẩn hóa các tài liệu nghiệp vụ ban đầu thành một package đủ để:

- Owner đọc hiểu phạm vi và quyết định còn mở.
- BA/SA nắm nghiệp vụ, dữ liệu, workflow, boundary và rule.
- PM chia phase/task và quản lý done gate.
- Backend thiết kế database, API, service, event, workflow.
- Frontend thiết kế screen, form, table, state, validation.
- QA/QC viết test case, smoke test, integration test.
- DevOps chuẩn bị migration, seed, deployment, rollback.
- AI coding agent triển khai từng bounded module/gap mà không suy đoán.

## 2. Source Policy

Tuân thủ [01_SOURCE_INDEX.md](01_SOURCE_INDEX.md):

- Khi biên soạn/sửa requirement trong `docs/software-specs/`, chỉ dùng prompt gốc, `docs-software/`, `.tmp-docx-extract/`, kiến thức chuyên môn và phê duyệt owner.
- `specs.docx` chỉ là `HIST-SPECS`, dùng fallback khi tài liệu mới thiếu và không mâu thuẫn.
- Không đọc source code để làm source-of-truth cho requirement/spec.
- Không dùng `AGENTS.md`.
- Không dùng `docs/ginsengfood_*`.

Riêng các prompt triển khai trong `phase-project/` được phép yêu cầu AI agents đọc current code ở phase implementation sau khi đã đọc specs, nhưng chỉ để audit gap/implementation baseline. Current code không được dùng để sửa ngược requirement đã owner duyệt.

Mọi nội dung lấy từ `specs.docx` phải gắn nhãn:

`[BỔ SUNG TỪ specs.docx — cần owner xác nhận nếu ảnh hưởng thiết kế/triển khai]`

## 3. Cấu Trúc Thư Mục Chuẩn

```text
docs/software-specs/
├── 00_README.md
├── 01_SOURCE_INDEX.md
├── 02_EXECUTIVE_SUMMARY.md
├── 03_GLOSSARY.md
├── 04_BUSINESS_CONTEXT.md
├── 05_SCOPE_AND_BOUNDARY.md
├── 06_MODULE_MAP.md
├── 07_PHASE_PLAN.md
├── 08_REQUIREMENTS_TRACEABILITY_MATRIX.md
├── 09_CONFLICT_AND_OWNER_DECISIONS.md
├── business/
├── functional/
├── non-functional/
├── architecture/
├── database/
├── api/
├── ui/
├── workflows/
├── modules/
├── diagrams/
├── testing/
├── dev-handoff/
├── data/
├── phase-project/
├── problems/
└── ai-agent/
```

Mapping lịch sử từ thư mục legacy dạng `1. business/`, `2. functional/`, ... nằm tại [00_LEGACY_FILE_MAPPING.md](00_LEGACY_FILE_MAPPING.md). Trong cây hiện tại, các thư mục legacy đánh số không còn là active docs.

## 4. Thứ Tự Đọc Khuyến Nghị

| Vai trò           | Thứ tự đọc                                                                                                                                                                                                                                                                                                     |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Owner / Executive | `02_EXECUTIVE_SUMMARY.md` → `05_SCOPE_AND_BOUNDARY.md` → `07_PHASE_PLAN.md` → `09_CONFLICT_AND_OWNER_DECISIONS.md`                                                                                                                                                                                             |
| BA / SA           | `01_SOURCE_INDEX.md` → `03_GLOSSARY.md` → `04_BUSINESS_CONTEXT.md` → `06_MODULE_MAP.md` → `08_REQUIREMENTS_TRACEABILITY_MATRIX.md`                                                                                                                                                                             |
| PM                | `06_MODULE_MAP.md` → `07_PHASE_PLAN.md` → `08_REQUIREMENTS_TRACEABILITY_MATRIX.md` → `phase-project/01_PHASE_PROJECT_TODO.md` → `phase-project/03_PROGRESS_REPORT.md` → `dev-handoff/07_MODULE_TASK_BREAKDOWN.md`                                                                                              |
| Backend           | `05_SCOPE_AND_BOUNDARY.md` → `06_MODULE_MAP.md` → `database/` → `data/` → `api/` → `workflows/`                                                                                                                                                                                                                |
| Frontend          | `06_MODULE_MAP.md` → `ui/` → `api/` → `workflows/`                                                                                                                                                                                                                                                             |
| QA/QC             | `08_REQUIREMENTS_TRACEABILITY_MATRIX.md` → `workflows/` → `data/` → `testing/` → `09_CONFLICT_AND_OWNER_DECISIONS.md`                                                                                                                                                                                          |
| DevOps            | `07_PHASE_PLAN.md` → `database/08_MIGRATION_STRATEGY.md` → `database/07_SEED_DATA_SPECIFICATION.md` → `data/01_SEED_DATA_CANONICAL.md` → `dev-handoff/09_RELEASE_ROLLBACK_GUIDE.md`                                                                                                                            |
| AI coding agent   | `01_SOURCE_INDEX.md` → `06_MODULE_MAP.md` → `07_PHASE_PLAN.md` → `08_REQUIREMENTS_TRACEABILITY_MATRIX.md` → `phase-project/04_PROJECT_LIFECYCLE_PROMPTS/00_README.md` nếu bắt đầu từ zero → `phase-project/02_AGENT_PROMPT_SEQUENCE.md` → `phase-project/05_DETAILED_PHASE_PROMPTS/00_README.md` → `ai-agent/` |

## 5. Hard Locks

Các rule sau dùng xuyên suốt toàn bộ spec:

| Lock                             | Nội dung                                                                                                                                                                                                                                  |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `LOCK-FORMULA-KIND-COEXISTENCE`  | G1 PILOT_PERCENT_BASED là pilot baseline cho go-live; G2 FIXED_QUANTITY_BATCH là production baseline cố định mẻ 400; cả hai có thể coexist `ACTIVE_OPERATIONAL` cho cùng SKU; planner pick `formula_version` + `formula_kind` khi tạo PO. |
| `LOCK-NO-RESEARCH-BASELINE-OPS`  | G0 và mọi research/baseline token lịch sử khác không được dùng trong seed, production order, material issue, costing, trace, recall, dev handoff.                                                                                         |
| `LOCK-RECIPE-VERSIONING`         | Recipe phải hỗ trợ G2/G3/G4... với approval, effective date, audit, active/retire và immutable snapshot.                                                                                                                                  |
| `LOCK-4-RECIPE-GROUPS`           | Recipe dùng đúng `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`.                                                                                                                                          |
| `LOCK-20-SKU-BASELINE`           | 20 SKU là baseline go-live, không phải giới hạn vĩnh viễn nếu owner đã yêu cầu CRUD/versioning dài hạn.                                                                                                                                   |
| `LOCK-MATERIAL-ISSUE-DECREMENT`  | Material Issue Execution là điểm decrement raw-material inventory thật sự.                                                                                                                                                                |
| `LOCK-MATERIAL-RECEIPT-SEPARATE` | Material Receipt Confirmation là record riêng, không decrement lần hai.                                                                                                                                                                   |
| `LOCK-QC-PASS-NOT-RELEASED`      | `QC_PASS` không phải `RELEASED`; release là record/action riêng.                                                                                                                                                                          |
| `LOCK-WAREHOUSE-RELEASED`        | Warehouse finished-goods receipt chỉ nhận batch `RELEASED` và tạo inventory ledger/balance.                                                                                                                                               |
| `LOCK-TRADEITEM-SKU-SEPARATE`    | Trade item/GTIN/GS1 tách khỏi SKU identity.                                                                                                                                                                                               |
| `LOCK-QR-LIFECYCLE`              | QR registry hỗ trợ `GENERATED`, `QUEUED`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED`.                                                                                                                                                       |
| `LOCK-PUBLIC-TRACE-POLICY`       | Public trace không expose supplier nội bộ, nhân sự, costing, QC defect, loss, MISA/private data.                                                                                                                                          |
| `LOCK-MISA-LAYER`                | MISA sync chỉ đi qua integration layer chung với mapping, retry, reconcile, audit.                                                                                                                                                        |
| `HL-SUP-001`                     | Supplier user chỉ thấy `op_raw_material_receipt` thuộc `supplier_id` của mình.                                                                                                                                                            |
| `HL-SUP-002`                     | Supplier chỉ chọn ingredient được công ty gán qua `op_supplier_ingredient` `ACTIVE` và còn `effective_from/to`.                                                                                                                           |
| `HL-SUP-003`                     | Supplier hoặc công ty tạo Raw Material Receipt trước không tạo raw material lot usable.                                                                                                                                                   |
| `HL-SUP-004`                     | Raw material lot chỉ được tạo sau khi công ty xác nhận nhận hàng vật lý (action `receive`); lot khởi tạo `lot_status = CREATED` + `lot_qc_status = PENDING_QC`.                                                                           |
| `HL-SUP-005`                     | Company-created `PURCHASED` receipt phải được supplier xác nhận và upload evidence bắt buộc trước khi chuyển `WAITING_DELIVERY`.                                                                                                          |
| `HL-SUP-006`                     | Evidence không lưu blob trong PostgreSQL; chỉ lưu URI/hash/metadata. Storage adapter pluggable (LOCAL_FS dev, COMPANY_FILE_SERVER prod).                                                                                                  |
| `HL-SUP-007`                     | Supplier không được thấy cost, inventory, formula, MISA, internal trace, supplier khác, batch sản xuất, customer/order/shipment.                                                                                                          |
| `HL-SUP-008`                     | Supplier password không lưu plaintext; chỉ hiển thị mật khẩu tạm một lần khi tạo/reset.                                                                                                                                                   |
| `HL-SUP-009`                     | Supplier-created receipt luôn set cứng `procurement_type = PURCHASED` và `supplier_id` theo account; supplier không được tự đổi.                                                                                                          |
| `HL-SUP-010`                     | Phần nguyên liệu `rejected`/`returned` không được tạo lot usable cho sản xuất.                                                                                                                                                            |
| `HL-SUP-011`                     | Sau `RECEIVED_PENDING_QC` hoặc khi đã tạo `op_raw_material_lot`, normal cancel bị chặn; chỉ reject/return/correction/reversal theo policy.                                                                                                |
| `HL-SUP-012`                     | Sau `SUPPLIER_CONFIRMED`, supplier không được sửa trực tiếp `ingredient`, `proposed_quantity`, `proposed_uom_code`, `expected_delivery_date`, `supplier_lot_code`, `manufacture_date`, `expiry_date`.                                     |
| `HL-SUP-013`                     | `op_supplier_ingredient` thuộc M03A; M06 read-only consume. Supplier chỉ tạo receipt item khi mapping `ACTIVE` và còn `effective_from/to`.                                                                                                |
| `HL-SUP-014`                     | `SUM(lot.initial_quantity WHERE receipt_item_id = X) <= received_quantity_of(X)`.                                                                                                                                                         |
| `HL-SUP-015`                     | Supplier portal scope = `PURCHASED` only. `SELF_GROWN` dùng flow M05/M06; future internal grower portal là ADR riêng thuộc M05.                                                                                                           |
| `HL-SUP-016`                     | Evidence required policy-driven theo `op_supplier_ingredient` (và future `op_supplier_evidence_policy`); MVP default ≥1 photo cho `PURCHASED`, COA/lab khi policy yêu cầu.                                                                |
| `HL-SUP-017`                     | Supplier evidence và receipt evidence không được expose qua public trace; public trace whitelist-only.                                                                                                                                    |

Chi tiết và 9 owner decision liên quan: [`docs/v2-decisions/OD-M06-SUP-COLLAB.md`](../v2-decisions/OD-M06-SUP-COLLAB.md), [09_CONFLICT_AND_OWNER_DECISIONS.md](09_CONFLICT_AND_OWNER_DECISIONS.md) mục C.7.

## 6. Module Chuẩn

Bộ spec dùng 16 module file chuẩn:

1. `01_FOUNDATION_CORE`
2. `02_AUTH_PERMISSION`
3. `03_MASTER_DATA`
4. `04_SKU_INGREDIENT_RECIPE`
5. `05_SOURCE_ORIGIN`
6. `06_RAW_MATERIAL`
7. `07_PRODUCTION`
8. `08_MATERIAL_ISSUE_RECEIPT`
9. `09_QC_RELEASE`
10. `10_PACKAGING_PRINTING`
11. `11_WAREHOUSE_INVENTORY`
12. `12_TRACEABILITY`
13. `13_RECALL`
14. `14_MISA_INTEGRATION`
15. `15_REPORTING_DASHBOARD`
16. `16_ADMIN_UI`

Ngoài 16 module chuẩn, đăng ký sub-capability `M03A Supplier Management` thuộc nhóm Master Data/Auth/Admin UI (không tạo M17, giữ nguyên numbering M01-M16). Xem `OD-MODULE-M03A-001` tại [09_CONFLICT_AND_OWNER_DECISIONS.md](09_CONFLICT_AND_OWNER_DECISIONS.md) và [`docs/v2-decisions/OD-M06-SUP-COLLAB.md`](../v2-decisions/OD-M06-SUP-COLLAB.md).

Chi tiết: [06_MODULE_MAP.md](06_MODULE_MAP.md).

## 7. Quy Tắc Cập Nhật Tài Liệu

- Mọi thay đổi requirement phải cập nhật `08_REQUIREMENTS_TRACEABILITY_MATRIX.md`.
- Mọi conflict hoặc owner decision phải cập nhật `09_CONFLICT_AND_OWNER_DECISIONS.md`.
- Nếu thêm/sửa module, cập nhật `06_MODULE_MAP.md`.
- Nếu thay phase/done gate, cập nhật `07_PHASE_PLAN.md`.
- Nếu dùng `HIST-SPECS`, ghi rõ nhãn fallback và owner decision cần có.
- Không xóa legacy folder trước khi owner duyệt cleanup.

## 8. Implementation Data Pack

Thư mục `data/` là artifact Part 12, dùng để triển khai seed/migration/test trực tiếp:

- `data/01_SEED_DATA_CANONICAL.md`
- `data/02_G1_RECIPE_LINE_MATRIX.md`
- `data/03_INGREDIENT_MASTER_MATRIX.md`
- `data/04_SEED_VALIDATION_QUERIES.md`
- `data/05_E2E_SMOKE_FIXTURE.md`
- `data/06_API_EXAMPLE_FIXTURES.md`
- `data/07_OWNER_DECISION_CLOSURE_FOR_CODING.md`
- `data/csv/*.csv`
- `data/seed_manifest.json`

Data pack hiện có 20 SKU, 20 G1 recipe headers, 433 G1 recipe lines, 52 ingredients, 4 recipe groups, starter RBAC, warehouse fixture, MISA fixture và public trace policy.

## 9. Trạng Thái Part 2

Part 2 làm lại nhóm top-level docs để PM/BA/SA có nền nhất quán trước khi viết chi tiết các nhóm `business/`, `functional/`, `database/`, `api/`, `ui/`, `workflows/`, `modules/`, `testing/`, `dev-handoff/`, `ai-agent/`.

## 10. Phase Project Pack

Thư mục `phase-project/` là artifact điều phối triển khai:

- `phase-project/01_PHASE_PROJECT_TODO.md` dùng làm to-do list theo tuần/phase.
- `phase-project/02_AGENT_PROMPT_SEQUENCE.md` chứa prompt copy-paste cho AI agents.
- `phase-project/03_PROGRESS_REPORT.md` là file sống để cập nhật kết quả agent và báo cáo tiến độ.
- `phase-project/04_PROJECT_LIFECYCLE_PROMPTS/` chứa prompt đánh số từ project inception/scaffold đến CI/CD, UAT, production readiness, go-live và post-go-live operations.
- `phase-project/05_DETAILED_PHASE_PROMPTS/` chứa prompt chi tiết theo MX-GATE-G1 và `CODE01-CODE17` để giao trực tiếp cho DB/backend/API/frontend/seed/QA/review agents.

## 11. Problems / Review Notes

Thư mục `problems/` chứa các báo cáo đánh giá, problem notes và phân tích readiness sinh trong quá trình rà soát. Đây là evidence hỗ trợ PM/owner, không phải nguồn yêu cầu chính. Nếu nội dung trong `problems/` khác với top-level spec hoặc source index, ưu tiên `01_SOURCE_INDEX.md` và các file spec canonical trong cây chuẩn.
