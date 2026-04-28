# 01 - AI Agent Workflow

## 1. Mục tiêu

Workflow này hướng dẫn AI coding agent nhận một phase/module/gap và triển khai có kiểm soát, dựa trên `docs/software-specs/`, không suy đoán nghiệp vụ.

## 2. Operating Rules

| rule_id | Rule |
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

| step | Agent output |
|---|---|
| 1. Intake | Requirement, module, phase, business rule, test, source file/section |
| 2. Gap map | Current vs target gap by DB/backend/API/FE/seed/test/docs |
| 3. Plan | Bounded work items, write scope, dependencies, non-goals |
| 4. Implement | Minimal patch, no unrelated cleanup |
| 5. Validate | Build/test/migration/seed/smoke commands and results |
| 6. Review | Security, public trace, MISA, inventory, audit, API/FE sync |
| 7. Handoff | Summary, files changed, evidence, residual risks, next gaps |

## 4. Evidence Required

| evidence | Required when |
|---|---|
| `REQ-*` and `BR-*` | Every gap |
| API endpoint and DTO | API/backend/FE gap |
| Table/index/constraint | DB/backend/seed gap |
| Screen/action/API client | FE gap |
| State machine/workflow | Lifecycle gap |
| Test case IDs | Every implementation gap |
| Command output | Validation/build/test/seed/smoke |
| Owner decision | Any open ambiguity or deferred behavior |

## 5. Stop Conditions

Agent must stop and produce a gap/decision report instead of implementing when:

- Source precedence is unclear.
- Required owner decision blocks behavior.
- Implementing would require broad unrelated refactor.
- Current code would need duplicate route/table/business truth.
- Public/private data exposure cannot be verified.
- Migration/seed path would mutate append-only historical data destructively.

## 6. Final Response Contract

Every implementation handoff must include:

- Summary.
- Files changed.
- Requirement source.
- Evidence used.
- Commands run.
- Test result.
- Backend build result.
- Frontend build result.
- Process cleanup result.
- Database migration/update result when applicable.
- Seed validation result when applicable.
- Remaining risks.
- Handoff update.
