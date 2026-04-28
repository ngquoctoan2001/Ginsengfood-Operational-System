# 01 - Development Guide

## 1. Mục tiêu

Tài liệu này hướng dẫn dev team triển khai `docs/software-specs/` theo phase/gap có kiểm soát. Mỗi task phải có scope rõ, requirement anchor, module, layer bị ảnh hưởng, test và handoff.

## 2. Source Discipline

- Chỉ dùng prompt gốc, `docs-software/`, `.tmp-docx-extract/`, các file đã chuẩn hóa trong `docs/software-specs/`, kiến thức chuyên môn có đánh dấu và phê duyệt owner.
- Không dùng source code, current database, `AGENTS.md`, hoặc `docs/ginsengfood_*` làm source-of-truth cho handoff này.
- Current implementation nếu được audit ở phase triển khai sau chỉ là baseline để tìm gap, không được ghi đè requirement đã chốt.
- Nếu thiếu dữ liệu hoặc có mâu thuẫn, ghi `OWNER DECISION NEEDED`; không tự tạo nghiệp vụ mới.

## 3. Read Order

| order | File/folder | Mục đích |
|---|---|---|
| 1 | `01_SOURCE_INDEX.md` | Source được phép dùng và fallback |
| 2 | `08_REQUIREMENTS_TRACEABILITY_MATRIX.md` | `REQ-*`, module, DB, API, UI, workflow, test |
| 3 | `09_CONFLICT_AND_OWNER_DECISIONS.md` | Conflict và owner decision |
| 4 | `06_MODULE_MAP.md` | Module M01-M16 và dependency |
| 5 | `07_PHASE_PLAN.md` | Phase CODE01-CODE17, dependency, done gate |
| 6 | `modules/{module}.md` | Boundary, rules, events, state, tests |
| 7 | `database/`, `api/`, `ui/`, `workflows/`, `testing/` | Chi tiết layer cần triển khai |
| 8 | `dev-handoff/`, `ai-agent/` | Hướng dẫn triển khai, review, validation, handoff |

## 4. Execution Model

| step | Output bắt buộc |
|---|---|
| Intake | `REQ-*`, module, phase, source section, owner decisions liên quan |
| Gap audit | Gap list theo DB/backend/API/FE/seed/test/docs |
| Impact map | File/layer dự kiến chạm; API/UI/DB/test impact; rollback risk |
| Plan | Bounded task list, non-goals, dependency, validation commands |
| Implement | Patch nhỏ, không sửa lan, không refactor không liên quan |
| Validate | Build/test/migration/seed/smoke theo `08_DONE_GATE_CHECKLIST.md` |
| Review | Security/public trace/MISA/inventory/audit/API-FE sync review |
| Handoff | Summary, files changed, evidence, commands, risks, owner decisions |

## 5. Phase Summary

| phase | Goal | Primary modules | Priority |
|---|---|---|---|
| CODE01 | Foundation + Source Origin | M01, M02, M03, M05, M16 | P0 |
| CODE02 | Raw Material Intake + Lot + Incoming QC + Mark Lot `READY_FOR_PRODUCTION` | M06, M05, M09, M11, M16 | P0 |
| CODE03 | Manufacturing Execution + Batch + Genealogy Foundation | M04, M07, M08, M11, M12, M16 | P0 |
| CODE04 | Packaging & Printing Control | M10, M04, M16 | P0 |
| CODE05 | QC & Batch Release | M09, M10, M11, M16 | P0 |
| CODE06 | Warehouse Receipt & Inventory Control | M11, M14, M16 | P0 |
| CODE07 | Traceability & Batch Genealogy Engine | M12, M05, M06, M07, M08, M10, M11, M16 | P0 |
| CODE08 | Recall & Product Recovery Engine | M13, M12, M11, M14, M16 | P0 |
| CODE09 | Admin UI/RBAC/Screen Registry | M02, M16 | P1 |
| CODE10 | API Contract/Error/Auth/Idempotency Boundary | M01, all API modules | P1 |
| CODE11 | Mobile/Internal App Contract | M16, M01, M02, M06, M08, M10 | P1 |
| CODE12 | Device/Printer Boundary | M10, M14, M15 | P1 |
| CODE13 | Event/Outbox/MISA Adapter | M01, M14 | P1 |
| CODE14 | Monitoring/Alert/Dashboard | M15, M16, M14 | P2 |
| CODE15 | Override Governance | M01, M02, M09, M11, M13, M16 | P2 |
| CODE16 | Retention/Archive/Restore | M01, M11, M12, M13, M14, M15 | P2 |
| CODE17 | Final Close-Out Gate | All | P0 release gate |

## 6. Bounded Gap Template

```markdown
## GAP-{phase}-{module}-{slug}

- Requirement: REQ-...
- Business rule: BR-...
- Module: M..
- Phase: CODE..
- Scope: backend/API/DB/FE/seed/test/docs
- Non-goals:
- DB impact:
- API impact:
- UI impact:
- Seed impact:
- Tests:
- Done gate:
- Rollback/forward fix:
```

## 7. Anti-Scope Rules

- Không đổi route family nếu chưa cập nhật API catalog, FE client, UI screen, test và impact analysis.
- Không tạo table/enum mới song song với table/enum đã có trong database spec nếu chỉ vì code hiện tại khác spec.
- Không sửa module khác ngoài dependency trực tiếp của gap.
- Không refactor style, rename hoặc format diện rộng trong cùng patch nghiệp vụ.
- Không thay đổi public API response mà không cập nhật frontend contract và tests.
- Không mutate audit/event/ledger/history records trong business flow.
- Không cho material issue chạy chỉ dựa trên `QC_PASS`; raw lot phải qua readiness transition `RAW_LOT_MARK_READY` và có `lot_status = READY_FOR_PRODUCTION`.

## 8. Required Handoff Per Gap

| section | Nội dung |
|---|---|
| Summary | Gap đã xử lý và behavior thay đổi |
| Requirement source | `REQ-*`, business rule, workflow, test case |
| Files changed | File paths theo layer |
| API impact | Endpoint/DTO/error/idempotency thay đổi hoặc `No API impact` có evidence |
| Frontend impact | Screen/client/type/test thay đổi hoặc `No FE impact` có evidence |
| DB impact | Migration/table/index/constraint/seed impact |
| Validation | Commands run, result, blockers |
| Risks | Residual risk, owner decision, deferred work |
| Rollback | Rollback/forward-fix path |
