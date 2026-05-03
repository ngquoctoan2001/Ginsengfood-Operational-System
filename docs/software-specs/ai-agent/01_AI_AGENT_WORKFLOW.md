# 01 - AI Agent Workflow

## 1. Mục tiêu

Workflow này hướng dẫn AI coding agent nhận một phase/module/gap và triển khai có kiểm soát, dựa trên `docs/software-specs/`, không suy đoán nghiệp vụ.

## 2. Quy tắc vận hành

| rule_id | Quy tắc |
|---|---|
| AG-WF-001 | Luôn bắt đầu bằng `REQ-*`, module `M01..M16`, phase `CODE01..CODE17` và test case `TC-*`. |
| AG-WF-002 | Không đọc hoặc dùng source bị cấm làm source-of-truth cho spec batch này. |
| AG-WF-003 | Current code nếu được đọc ở phase triển khai sau chỉ là implementation baseline để tìm gap. |
| AG-WF-004 | Không sửa lan ngoài bounded gap; không refactor rộng. |
| AG-WF-005 | Nếu đổi backend API/DTO/state/permission, phải cập nhật frontend client/types/screens/tests cùng phase hoặc nêu evidence không có FE impact. |
| AG-WF-006 | Không tạo parallel route family/table/enum/business truth nếu chưa có impact analysis. |
| AG-WF-007 | Không bypass audit, idempotency, permission, raw lot `READY_FOR_PRODUCTION` gate trước material issue (`QC_PASS` không đủ điều kiện issue), batch release gate trước warehouse receipt, inventory ledger, trace, recall, MISA boundary. |
| AG-WF-008 | Nếu thiếu thông tin, ghi `OWNER DECISION NEEDED`; không tự tạo nghiệp vụ mới. |

## 3. Delivery Sequence

| step | Đầu ra của agent |
|---|---|
| 1. Intake | Requirement, module, phase, business rule, test, source file/section |
| 2. Gap map | Current vs target gap by DB/backend/API/FE/seed/test/docs |
| 3. Plan | Bounded work items, write scope, dependencies, non-goals |
| 4. Implement | Minimal patch, no unrelated cleanup |
| 5. Validate | Lệnh và kết quả build/test/migration/seed/smoke |
| 6. Review | Security, public trace, MISA, inventory, audit, API/FE sync |
| 7. Handoff | Tóm tắt, file đã sửa, evidence, cập nhật Markdown/handoff, rủi ro còn lại, gap tiếp theo |

## 4. Evidence bắt buộc

| evidence | Bắt buộc khi |
|---|---|
| `REQ-*` and `BR-*` | Every gap |
| API endpoint and DTO | API/backend/FE gap |
| Table/index/constraint | DB/backend/seed gap |
| Screen/action/API client | FE gap |
| State machine/workflow | Lifecycle gap |
| Test case IDs | Every implementation gap |
| Command output | Kiểm chứng/build/test/seed/smoke |
| Owner decision | Any open ambiguity or deferred behavior |

## 5. Điều kiện dừng

Agent phải dừng và tạo gap/decision report thay vì implement khi:

- Source precedence is unclear.
- Required owner decision blocks behavior.
- Implementing would require broad unrelated refactor.
- Current code would need duplicate route/table/business truth.
- Public/private data exposure cannot be verified.
- Migration/seed path would mutate append-only historical data destructively.

## 6. Contract phản hồi cuối

Mỗi implementation handoff phải dùng heading tiếng Việt và gồm:

- Tóm tắt.
- File đã sửa.
- Nguồn yêu cầu.
- Evidence đã dùng.
- Lệnh đã chạy.
- Kết quả test.
- Kết quả backend build.
- Kết quả frontend build.
- Kết quả cleanup process.
- Cập nhật Markdown.
- Kết quả database migration/update khi áp dụng.
- Kết quả seed validation khi áp dụng.
- Rủi ro còn lại.
- Cập nhật handoff.

Không dùng heading phản hồi cuối bằng tiếng Anh như `Progress Report Update`, `Commands Run`, `Validation`, `Summary`, `Files Changed`, hoặc `Process Cleanup Result`.
