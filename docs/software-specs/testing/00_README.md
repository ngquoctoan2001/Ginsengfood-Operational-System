# Testing Pack README

## 1. Mục đích

Thư mục này chứa test strategy, test matrix và test plan cho bộ đặc tả `docs/software-specs/`. QA dùng các file này để viết manual test, API test, UI test, integration test, E2E smoke, seed validation và regression suite.

## 2. Source Discipline

- Chỉ dùng prompt gốc, `docs-software/`, `.tmp-docx-extract/`, các file đã chuẩn hóa trong `docs/software-specs/`, kiến thức chuyên môn có đánh dấu và phê duyệt owner.
- Không dùng source code, current database, `AGENTS.md`, hoặc `docs/ginsengfood_*` làm source-of-truth cho testing pack này.
- Mọi test case quan trọng phải map được về `REQ-*` trong [../08_REQUIREMENTS_TRACEABILITY_MATRIX.md](../08_REQUIREMENTS_TRACEABILITY_MATRIX.md).
- Nếu thiếu thông tin môi trường, command runner, MISA sandbox, printer, backup/SLA hoặc retention, ghi `OWNER DECISION NEEDED`.

## 3. File Index Chính Thức

| File                                                               | Nội dung                                                                 | Trạng thái |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------ | ---------- |
| [01_TEST_STRATEGY.md](01_TEST_STRATEGY.md)                         | Chiến lược test, layer, environment, entry/exit gate, hard lock coverage | Active     |
| [02_TEST_CASE_MATRIX.md](02_TEST_CASE_MATRIX.md)                   | Ma trận test case map ngược RTM                                          | Active     |
| [03_API_TEST_PLAN.md](03_API_TEST_PLAN.md)                         | API test plan theo endpoint contract                                     | Active     |
| [04_UI_TEST_PLAN.md](04_UI_TEST_PLAN.md)                           | UI test plan theo screen catalog                                         | Active     |
| [05_INTEGRATION_TEST_PLAN.md](05_INTEGRATION_TEST_PLAN.md)         | Integration test cho snapshot, ledger, trace, recall, MISA               | Active     |
| [06_E2E_SMOKE_TEST_PLAN.md](06_E2E_SMOKE_TEST_PLAN.md)             | E2E smoke happy path và negative smoke                                   | Active     |
| [07_SEED_VALIDATION_TEST_PLAN.md](07_SEED_VALIDATION_TEST_PLAN.md) | Seed validation cho 20 SKU, ingredient, 4 groups, G1 và idempotency      | Active     |
| [08_REGRESSION_TEST_PLAN.md](08_REGRESSION_TEST_PLAN.md)           | Regression triggers, tiers và release blockers                           | Active     |

## 4. Legacy Files

Các file dạng `* copy.md` trong thư mục này là legacy-generated/deprecated từ vòng tạo tài liệu trước. Không dùng các file đó làm test pack chính thức và không dùng để ghi đè 8 file active ở trên. Chỉ giữ lại để owner so sánh trước khi quyết định cleanup.

## 5. Hard Lock Test Coverage

| hard lock                                                                                 | Test coverage chính                                                                                                                                             |
| ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Forbidden operational formula token không được dùng vận hành                              | `TC-M04-REC-004`, `TC-HL-G0-001`, `TC-SEED-004`, `TC-REG-001`                                                                                                   |
| G1 snapshot bất biến                                                                      | `TC-M04-REC-007`, `TC-HL-G1-SNAPSHOT-001`, `TC-INT-REC-001`, `TC-REG-002`, `TC-M04-PILOT-001`, `TC-M04-COEX-001`, `TC-API-M04-PILOT-001`, `TC-UI-REC-PILOT-001` |
| Raw lot `QC_PASS` phải qua `mark_ready` thành `READY_FOR_PRODUCTION` trước material issue | `TC-M06-RM-005`, `TC-HL-LOT-READY-001`, `TC-API-M06-LOT-READY`, `TC-INT-LOT-READY`, `TC-E2E-SMK-002B`, `TC-REG-003B`                                            |
| Material issue là điểm decrement duy nhất                                                 | `TC-M08-MI-001`, `TC-M08-MR-002`, `TC-HL-DECREMENT-001`, `TC-INT-INV-001`, `TC-REG-003`                                                                         |
| `QC_PASS` không phải `RELEASED`                                                           | `TC-M09-REL-002`, `TC-HL-QC-RELEASE-001`, `TC-REG-004`                                                                                                          |
| Warehouse receipt chỉ nhận batch `RELEASED`                                               | `TC-M11-WH-001`, `TC-API-M11-001`, `TC-REG-005`                                                                                                                 |
| Public trace không lộ field nội bộ                                                        | `TC-M12-PTRACE-002`, `TC-HL-PTRACE-001`, `TC-REG-006`                                                                                                           |
| QR `VOID`/`FAILED` không trace public                                                     | `TC-M12-PTRACE-003`, `TC-HL-QR-VOID-001`, `TC-REG-007`                                                                                                          |
| MISA missing mapping tạo log/reconcile pending                                            | `TC-M14-MISA-002`, `TC-HL-MISA-MAP-001`, `TC-REG-008`                                                                                                           |
| Seed 20 SKU + ingredient + 4 group recipe                                                 | `TC-SEED-001..006`, `TC-NFR-SEED-004`, `TC-REG-009`                                                                                                             |

## 6. Done Gate

- 8 file active tồn tại và có bảng test case với cột `test_id`, `module`, `scenario`, `precondition`, `steps`, `expected result`, `data required`, `priority`.
- Test case P0 map được về `REQ-*`.
- Hard lock bắt buộc có test ở matrix, API/integration/E2E hoặc seed/regression tương ứng.
- Các file `* copy.md` không được xem là active pack.
