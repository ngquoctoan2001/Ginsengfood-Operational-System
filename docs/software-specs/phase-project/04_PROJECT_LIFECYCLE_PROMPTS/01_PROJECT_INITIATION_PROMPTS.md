# 01 - Project Initiation Prompts

> Dung truoc khi tao/scaffold code. Muc tieu la bien y tuong va docs thanh project charter co scope, done definition, quyết định owner, timeline va rui ro.

## Prompt 01.01 - Owner Brief And Success Criteria

```text
Role:
Bạn là Product Owner Analyst + Delivery Lead.

Mission:
Tạo project brief cho {project_name} từ docs/software-specs, đủ để cả owner, PM, dev, QA và AI agents hiểu mục tiêu, phạm vi, thành công là gì và cái gì không làm.

Source discipline:
- Requirement source-of-truth: docs/software-specs/.
- Nếu có mâu thuẫn giữa file docs, dùng precedence trong docs/software-specs/00_README.md và ghi conflict.
- Current code không phải requirement source.
- Không dùng legacy extract để override docs/software-specs.

Read first:
1. docs/software-specs/00_README.md
2. docs/software-specs/02_EXECUTIVE_SUMMARY.md
3. docs/software-specs/05_SCOPE_AND_BOUNDARY.md
4. docs/software-specs/06_MODULE_MAP.md
5. docs/software-specs/07_PHASE_PLAN.md
6. docs/software-specs/09_CONFLICT_AND_OWNER_DECISIONS.md
7. docs/software-specs/phase-project/03_PROGRESS_REPORT.md

Scope:
- Tạo project brief.
- Không sửa code.
- Có thể cập nhật docs/software-specs/phase-project/03_PROGRESS_REPORT.md.

Non-goals:
- Không chọn technology stack nếu chưa có dữ liệu.
- Không tạo repo hoặc scaffold.
- Không implement feature.

Workflow:
1. Tóm tắt business goal trong 5-8 dòng.
2. Xác định in-scope và out-of-scope.
3. Xác định P0/P1/P2 phases.
4. Xác định success criteria đo được.
5. Xác định open quyết định owner và blocker.
6. Xác định target users/roles.
7. Xác định release strategy sơ bộ: MVP, staging, UAT, production.
8. Cập nhật progress report với trạng thái inception.

Kiểm chứng:
- Kiểm tra mọi phase P0 trong CODE01-CODE08/CODE17 có mục tiêu và done gate.
- Kiểm tra owner decision blocker đã xuất hiện trong report.

Stop conditions:
- Nếu scope/phạm vi vận hành mâu thuẫn giữa docs, dừng và tạo conflict list.
- Nếu owner decision chặn việc bắt đầu project, ghi rõ blocker thay vì tự quyết.

Đầu ra bắt buộc:
- Project brief.
- In-scope / out-of-scope.
- Success criteria.
- Delivery phases.
- Quyết định owner.
- Initial risks.
- Next prompt to run.
- Confirmation that progress report was updated.
```

## Prompt 01.02 - Project Charter And Delivery Governance

```text
Role:
Bạn là PM/Delivery Governance Agent.

Mission:
Tạo project charter và governance rule cho việc triển khai bằng AI agents, bao gồm team roles, branching, approval, done gates, meeting cadence và reporting.

Read first:
1. docs/software-specs/phase-project/01_PHASE_PROJECT_TODO.md
2. docs/software-specs/phase-project/03_PROGRESS_REPORT.md
3. docs/software-specs/dev-handoff/07_MODULE_TASK_BREAKDOWN.md
4. docs/software-specs/dev-handoff/08_DONE_GATE_CHECKLIST.md
5. docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md

Scope:
- Planning/governance only.
- Có thể cập nhật progress report.

Workflow:
1. Đề xuất governance model: Owner, PM, Tech Lead, BA/SA, Backend, Frontend, QA, DevOps, Security.
2. Định nghĩa work item hierarchy: Project -> Phase -> Gap -> Task -> Test -> Handoff.
3. Định nghĩa rule giao việc cho AI agents.
4. Định nghĩa done gate bắt buộc cho mỗi loại task.
5. Định nghĩa reporting cadence: daily, weekly, release checkpoint.
6. Định nghĩa escalation path khi gặp owner decision hoặc validation fail.

Đầu ra bắt buộc:
- Project charter.
- RACI-lite table.
- AI agent operating model.
- Done gate policy.
- Reporting cadence.
- Escalation rules.
- Cập nhật báo cáo tiến độ.
```

## Prompt 01.03 - Owner Decision Closure Plan

```text
Role:
Bạn là Owner Decision Facilitator.

Mission:
Chuẩn bị danh sách quyết định owner cần chốt trước khi implementation/go-live, ưu tiên các quyết định đang chặn production.

Read first:
1. docs/software-specs/09_CONFLICT_AND_OWNER_DECISIONS.md
2. docs/software-specs/phase-project/03_PROGRESS_REPORT.md
3. docs/software-specs/07_PHASE_PLAN.md
4. docs/software-specs/non-functional/05_BACKUP_RETENTION_REQUIREMENTS.md
5. docs/software-specs/non-functional/07_SCALABILITY_AVAILABILITY_REQUIREMENTS.md

Workflow:
1. Liệt kê quyết định owner đang open.
2. Phân loại: blocks implementation, blocks UAT, blocks production, can defer.
3. Với mỗi OD, viết câu hỏi ngắn, options, recommendation, impact.
4. Đề xuất deadline cần chốt theo phase.
5. Cập nhật progress report owner tracker.

Đầu ra bắt buộc:
- Owner decision table.
- Recommended option per decision.
- Impact by DB/API/UI/workflow/test/release.
- Deadline/blocking phase.
- Cập nhật báo cáo tiến độ.
```

