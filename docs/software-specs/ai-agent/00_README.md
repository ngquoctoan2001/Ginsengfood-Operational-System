# AI Agent Pack README

## 1. Mục đích

Thư mục này chứa prompt pack active cho AI coding agent triển khai từng phase/module/gap mà không suy đoán nghiệp vụ.

## 2. Active Files

| File                               | Purpose                                                                   |
| ---------------------------------- | ------------------------------------------------------------------------- |
| `01_AI_AGENT_WORKFLOW.md`          | Workflow, evidence, stop conditions                                       |
| `02_CODEX_PROMPT_PACK.md`          | Base prompt, anti-scope prompt, phase/module prompts                      |
| `03_GAP_IMPLEMENTATION_PROMPTS.md` | Gap audit, planning, backend, DB, FE, seed, test prompts                  |
| `04_REVIEW_PROMPTS.md`             | Review prompts cho security/public trace/MISA/inventory/audit/API-FE sync |
| `05_VALIDATION_PROMPTS.md`         | Validation prompts cho build/test/migration/seed/smoke                    |
| `06_HANDOFF_PROMPTS.md`            | Handoff, release, owner decision, deferred work prompts                   |

## 2.1. Phase Project Pack

Nếu cần giao việc tuần tự cho nhiều AI agents, dùng thêm:

| File | Purpose |
| --- | --- |
| `../phase-project/01_PHASE_PROJECT_TODO.md` | Backlog/to-do list theo week, phase, module và done gate |
| `../phase-project/02_AGENT_PROMPT_SEQUENCE.md` | Prompt copy-paste theo thu tu audit → plan → implement → review → validate → handoff |
| `../phase-project/03_PROGRESS_REPORT.md` | File sống để agent cập nhật kết quả và owner/PM báo cáo tiến độ |
| `../phase-project/04_PROJECT_LIFECYCLE_PROMPTS/` | Prompt đánh số từ tạo dự án đến go-live và post-go-live operations |
| `../phase-project/05_DETAILED_PHASE_PROMPTS/` | Prompt chi tiết theo phase/gap cho DB/backend/API/frontend/seed/QA/review agents |

## 3. Legacy Files

Các file dạng `* copy.md`, `04_REVIEW_VALIDATION_PROMPTS.md`, `05_HANDOFF_PROMPTS.md` là legacy-generated/deprecated. Không dùng chúng làm prompt pack chính thức và không dùng để ghi đè 6 file active ở trên.

## 4. Source Discipline

- Chỉ dùng prompt gốc, `docs-software/`, `.tmp-docx-extract/`, `docs/software-specs/`, kiến thức chuyên môn có đánh dấu và owner approval.
- Không dùng source code, current database, `AGENTS.md`, hoặc `docs/ginsengfood_*` làm source-of-truth cho prompt pack này.
- Khi implement code ở phase sau, current implementation chỉ là baseline để audit/gap, không phải nguồn yêu cầu nghiệp vụ nếu mâu thuẫn với spec.

## 5. Agent Hard Locks

- Không sửa lan ngoài bounded gap.
- Không tạo parallel route family, enum, table hoặc business truth nếu chưa có impact analysis.
- Nếu backend contract đổi, frontend API client/types/screens/tests phải cập nhật cùng phase hoặc có no-impact evidence.
- Không expose private trace fields ra public trace.
- Không bypass idempotency, permission, audit, approval, raw lot readiness, batch release, inventory ledger, trace, recall, MISA boundary.
- Không bypass raw lot `READY_FOR_PRODUCTION` gate trước material issue; `QC_PASS` chỉ là tiền điều kiện cho action `RAW_LOT_MARK_READY`, không đủ để issue.
- Không bypass batch release gate trước warehouse receipt; `QC_PASS` không phải `APPROVED_RELEASED`.
- Không mutate append-only audit/event/ledger/history.
- Done gate bắt buộc: build/test/migration/seed/smoke/handoff hoặc ghi rõ blocker, command attempted và residual risk.
