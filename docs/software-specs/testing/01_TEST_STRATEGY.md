# 01 - Test Strategy

## 1. Mục tiêu

Testing pack này định nghĩa chiến lược kiểm thử cho bộ đặc tả `docs/software-specs/`, đủ để QA lập test case, backend/frontend viết automation, PM theo dõi release gate và AI coding agent kiểm tra từng bounded module.

Phạm vi nguồn tuân thủ [01_SOURCE_INDEX.md](../01_SOURCE_INDEX.md): prompt gốc, `docs-software/`, `.tmp-docx-extract/`, các tài liệu đã chuẩn hóa trong `docs/software-specs/`, kiến thức chuyên môn có đánh dấu và phê duyệt owner. Không dùng source code, `AGENTS.md` hoặc `docs/ginsengfood_*` cho testing pack này.

## 2. Test Scope

| scope_id | Phạm vi | Module | Requirement anchor | Test pack liên quan |
|---|---|---|---|---|
| TS-SCOPE-01 | Foundation, audit, idempotency, state log, error contract | M01 | REQ-M01-001..005 | API, integration, regression |
| TS-SCOPE-02 | Auth, RBAC, approval, permission gate | M02 | REQ-M02-001..003 | API, UI, integration |
| TS-SCOPE-03 | Master data, warehouse, supplier/source separation | M03 | REQ-M03-001..003 | API, UI, seed |
| TS-SCOPE-04 | 20 SKU, ingredient, G1 baseline, 4 recipe groups, immutable snapshot | M04 | REQ-M04-001..007 | seed, API, E2E, regression |
| TS-SCOPE-05 | Source origin, raw material intake, raw lot QC và `READY_FOR_PRODUCTION` readiness | M05, M06 | REQ-M05-001..003, REQ-M06-001..004 | API, UI, integration, E2E |
| TS-SCOPE-06 | Production order, work order, batch, process chain | M07 | REQ-M07-001..004 | API, UI, E2E |
| TS-SCOPE-07 | Material issue/receipt, inventory decrement and variance | M08, M11 | REQ-M08-001..004 | API, integration, E2E |
| TS-SCOPE-08 | QC inspection, batch release, release gate | M09 | REQ-M09-001..003 | API, UI, E2E |
| TS-SCOPE-09 | Packaging, GTIN, QR, print/reprint | M10 | REQ-M10-001..005 | API, UI, E2E |
| TS-SCOPE-10 | Warehouse receipt, ledger append-only, lot balance | M11 | REQ-M11-001..004 | integration, E2E, regression |
| TS-SCOPE-11 | Internal trace, public trace field policy, QR public eligibility | M12 | REQ-M12-001..005 | API, UI, security regression |
| TS-SCOPE-12 | Recall lifecycle, impact snapshot, hold/sale lock | M13 | REQ-M13-001..004 | integration, E2E |
| TS-SCOPE-13 | MISA integration layer, mapping, retry, reconcile | M14 | REQ-M14-001..003 | integration, API |
| TS-SCOPE-14 | Dashboard, alert, observability, admin UI/PWA | M15, M16 | REQ-M15-001..003, REQ-M16-001..003 | UI, regression |

## 3. Test Levels

| level | Mục tiêu | Chủ sở hữu | Tối thiểu phải có |
|---|---|---|---|
| Unit test | Kiểm tra rule, validator, state transition, mapper, serializer | Dev | Rule hard lock P0, enum, field whitelist, idempotency decision |
| API test | Kiểm tra endpoint contract, auth, permission, validation, error code, idempotency | QA + Backend | Mỗi endpoint P0 trong `api/02_API_ENDPOINT_CATALOG.md` có happy/negative/idempotency nếu là command |
| UI test | Kiểm tra màn hình, form, table, action state, empty/error state, permission-aware UI | QA + Frontend | Mỗi màn hình P0/P1 trong `ui/03_SCREEN_CATALOG.md` có render, validation, action gate |
| Integration test | Kiểm tra dữ liệu xuyên module: snapshot, ledger, trace, recall, MISA outbox | QA + Backend | Không double decrement, không bypass release, public trace whitelist |
| E2E smoke | Kiểm tra chuỗi vận hành từ source origin đến warehouse/trace/recall/MISA | QA Lead | Flow trong [06_E2E_SMOKE_TEST_PLAN.md](06_E2E_SMOKE_TEST_PLAN.md) pass |
| Seed validation | Kiểm tra seed baseline, hard lock, idempotency seed | DBA + QA | 20 SKU, required ingredients, 4 groups, G1 active, no operational forbidden baseline |
| Regression | Chạy lại các gate rủi ro cao sau mỗi phase/release | QA Lead | Matrix P0 + P1 theo [08_REGRESSION_TEST_PLAN.md](08_REGRESSION_TEST_PLAN.md) |

## 4. Test Case Format Bắt Buộc

Mọi test case trong testing pack phải có các cột:

| field | Ý nghĩa |
|---|---|
| `test_id` | ID duy nhất, ưu tiên reuse anchor từ RTM như `TC-M04-REC-004`; test mở rộng dùng suffix rõ ràng như `TC-M04-REC-004-N01`. |
| `module` | Module M01-M16 hoặc `NFR`. |
| `scenario` | Tình huống kiểm thử cụ thể. |
| `precondition` | Dữ liệu/trạng thái/quyền cần có trước khi chạy. |
| `steps` | Các bước chính, có thể ghi endpoint/UI action. |
| `expected result` | Kết quả quan sát được, gồm dữ liệu, state, error, audit nếu cần. |
| `data required` | Seed/test fixture/input cần dùng. |
| `priority` | `P0`, `P1`, `P2`. |

Các file có thể bổ sung cột `requirement_id`, `business_rule`, `api`, `ui`, `table`, `workflow`, `automation_type`, nhưng không được bỏ 8 cột trên.

## 5. Hard Lock Coverage

| hard_lock_id | Requirement | Test bắt buộc | File kiểm thử |
|---|---|---|---|
| HL-TEST-01 | Forbidden research/baseline version token không được dùng vận hành | Reject seed/recipe/PO/material issue/trace/recall nếu payload hoặc dữ liệu operational dùng `G0` | 02, 03, 07, 08 |
| HL-TEST-02 | G1 snapshot bất biến | Tạo PO với G1, sửa recipe future version, PO cũ không đổi | 02, 03, 05, 06, 08 |
| HL-TEST-03 | Material Issue Execution là điểm decrement duy nhất | Issue tạo đúng một ledger debit; receipt không debit lần hai; retry không double debit | 02, 03, 05, 06, 08 |
| HL-TEST-04 | Raw lot `QC_PASS` chưa đủ cấp cho sản xuất | Raw lot chỉ được allocate/issue khi đã qua `mark_ready` và có trạng thái `READY_FOR_PRODUCTION`; `QC_PASS` chưa mark-ready phải bị reject | 02, 03, 04, 05, 06, 08 |
| HL-TEST-05 | `QC_PASS` không phải `RELEASED` | QC pass xong vẫn bị chặn warehouse receipt cho tới khi có release record | 02, 03, 05, 06, 08 |
| HL-TEST-06 | Warehouse receipt chỉ nhận batch `RELEASED` | Receipt batch chưa release bị reject; batch release thành công mới receipt được | 02, 03, 05, 06, 08 |
| HL-TEST-07 | Public trace không lộ field nội bộ | Public API/UI không trả supplier/personnel/cost/QC defect/loss/MISA/private fields | 02, 03, 04, 05, 06, 08 |
| HL-TEST-08 | QR `VOID`/`FAILED` không trace public | Public resolve QR invalid trả public-safe error, không leak reason nội bộ | 02, 03, 04, 06, 08 |
| HL-TEST-09 | MISA missing mapping phải log/reconcile pending | Event thiếu mapping không drop, có status review/reconcile và retry/manual action | 02, 03, 05, 06, 08 |
| HL-TEST-10 | Seed 20 SKU + ingredient + 4 group recipe | Seed validation fail nếu thiếu SKU, ingredient bắt buộc, recipe group hoặc G1 active | 02, 07, 08 |

## 6. Test Environment Strategy

| environment | Mục tiêu | Data policy | Điều kiện pass |
|---|---|---|---|
| `local-dev` | Dev chạy nhanh unit/API contract hẹp | Seed tối thiểu, fixture dev đánh dấu rõ | Không cần MISA thật; missing mapping flow phải test được |
| `qa-integrated` | QA chạy API/UI/integration/E2E | Seed đầy đủ 20 SKU + G1 + warehouse + public trace policy | E2E smoke P0 pass, audit/log có evidence |
| `staging-release` | Release rehearsal | Data gần production, secret thật nếu owner cung cấp | Migration/seed idempotent, regression P0/P1 pass |
| `production-readiness` | Dry-run trước go-live | Không dùng dữ liệu giả ngoài fixture được phê duyệt | Backup/restore, rollback, observability và owner decision đã chốt |

## 7. Automation Strategy

| automation_area | Khuyến nghị | Notes |
|---|---|---|
| API | Collection hoặc API test runner có data seeding/reset, assert status/error/body/audit | Mỗi command P0 phải assert `Idempotency-Key` nếu contract yêu cầu |
| UI | Page Object Model theo screen route, dùng `data-testid` ổn định | UI test không thay thế API permission test |
| E2E | Smoke chạy tuần tự theo dependency, mỗi bước lưu entity id vào context | Không hard-code QR nếu hệ thống generate |
| Seed | Validation query/script độc lập, chạy được sau migration/seed | Chạy seed hai lần để chứng minh idempotency |
| Regression | Suite theo risk tags: `recipe`, `inventory`, `release`, `trace`, `misa`, `security` | P0 chạy mỗi PR/phase; P1 trước release |

## 8. Entry / Exit Criteria

| gate | Entry criteria | Exit criteria |
|---|---|---|
| Module QA | Requirement trong RTM có API/UI/table/workflow rõ | Test case P0/P1 viết xong, negative path rõ |
| Integration QA | Seed baseline pass, dependent module có API contract | Ledger/trace/release/public policy/MISA assertions pass |
| E2E smoke | Full seed + user permission + environment config sẵn sàng | Smoke happy path và negative hard lock P0 pass |
| Release regression | E2E smoke pass, owner decisions blocking đã xử lý hoặc accepted risk | P0/P1 regression pass, residual risks được ghi |

## 9. Open Items

| item_id | Nội dung | Impact | Trạng thái |
|---|---|---|---|
| TS-OI-001 | Exact command/test runner sẽ được chốt khi scaffold có package/project scripts. | DevOps bổ sung lệnh cụ thể trong implementation handoff; không block contract freeze. | DEFERRED_WITH_ACCEPTED_RISK |
| TS-OI-002 | MISA sandbox/credential thật được bind bằng PF-02 config/secret refs. | Integration test dùng `DryRun` hoặc sandbox refs; missing mapping/reconcile pending vẫn là negative test hợp lệ. | RESOLVED_PF02 |
| TS-OI-003 | SLA performance trace/recall/backup đã có baseline PF-01/PF-02. | Performance/backup tests dùng baseline đã freeze, threshold vẫn configurable theo môi trường. | RESOLVED_PF02 |
