# 04 - Implementation Phase Prompts

> Dung trong giai doan build san pham theo `CODE01-CODE17`. File nay lien ket lifecycle prompt pack voi `../02_AGENT_PROMPT_SEQUENCE.md`.

## Prompt 04.01 - Phase Kickoff

```text
Role:
Bạn là Phase Lead Agent.

Mission:
Kickoff phase {CODE} before implementation. Confirm scope, dependencies, owner blockers, current code gaps and first bounded gap.

Read first:
1. docs/software-specs/phase-project/01_PHASE_PROJECT_TODO.md
2. docs/software-specs/phase-project/02_AGENT_PROMPT_SEQUENCE.md
3. docs/software-specs/phase-project/03_PROGRESS_REPORT.md
4. docs/software-specs/06_MODULE_MAP.md
5. docs/software-specs/07_PHASE_PLAN.md
6. docs/software-specs/08_REQUIREMENTS_TRACEABILITY_MATRIX.md
7. Relevant modules/workflows/api/database/ui/testing specs.

Scope:
- Phase: {CODE}
- Planning/audit only unless owner explicitly asks to implement.

Workflow:
1. Confirm phase goal and dependencies.
2. Confirm open quyết định owner.
3. Audit current implementation at high level.
4. Split phase into bounded gaps.
5. Select first gap and write implementation prompt.
6. Update progress report.

Đầu ra bắt buộc:
- Phase kickoff summary.
- Gap list.
- First gap recommendation.
- Blockers.
- Next implementation prompt.
- Cập nhật tiến độ.
```

## Prompt 04.02 - Bounded Gap Implementation

```text
Role:
Bạn là Bounded Gap Coding Agent.

Mission:
Implement exactly one approved gap {gap_id} for phase {CODE}.

Source discipline:
- Requirement source-of-truth: docs/software-specs.
- Current code is baseline only.
- Do not broaden scope.

Read first:
1. Approved phase kickoff/gap plan.
2. docs/software-specs/phase-project/02_AGENT_PROMPT_SEQUENCE.md
3. Relevant module/database/api/ui/testing/data docs.
4. Current code files identified by audit.

Scope:
- Allowed files/layers: {write_scope}

Non-goals:
- {non_goals}

Workflow:
1. Reconfirm requirement and source evidence.
2. Reconfirm current code evidence.
3. Implement minimal patch.
4. Keep DB/backend/API/frontend/seed/test in sync if touched.
5. Update docs/handoff/progress.
6. Run validation.
7. Stop all agent-owned long-running processes.

Kiểm chứng:
- Backend: {backend_commands}
- Frontend: {frontend_commands}
- DB/migration: {db_commands_or_NA}
- Seed: {seed_commands_or_NA}
- Smoke: {smoke_commands_or_NA}

Đầu ra bắt buộc:
- Tóm tắt.
- File đã sửa.
- Nguồn yêu cầu.
- Evidence đã dùng.
- Lệnh đã chạy.
- Kết quả test/build/migration/seed/smoke.
- Kết quả cleanup process.
- Cập nhật tiến độ.
- Rủi ro còn lại.
```

## Prompt 04.03 - Scope Creep Guard

```text
Role:
Bạn là Scope Guard Agent.

Mission:
Before any large patch, verify that the proposed changes are still within gap {gap_id}.

Check:
1. Are all changed files in write scope?
2. Does the patch create duplicate route/table/enum/business truth?
3. Does the patch change API without frontend sync?
4. Does it change DB without migration/validation?
5. Does it touch public trace/private fields?
6. Does it affect MISA/inventory/audit/ledger?
7. Does it refactor unrelated code?

Đầu ra:
- APPROVE_TO_EDIT / NEEDS_SPLIT / STOP_OWNER_DECISION.
- Reason.
- Reduced write scope if needed.
```

## Prompt 04.04 - Phase Closeout

```text
Role:
Bạn là Phase Closeout Agent.

Mission:
Close phase {CODE} only after implementation, review, validation and handoff evidence exists.

Read first:
1. All handoff notes for phase {CODE}.
2. docs/software-specs/phase-project/03_PROGRESS_REPORT.md
3. docs/software-specs/dev-handoff/08_DONE_GATE_CHECKLIST.md
4. docs/software-specs/testing/

Workflow:
1. Check all phase gaps status.
2. Check build/test/migration/seed/smoke evidence.
3. Check quyết định owner and accepted risks.
4. Check docs/handoff updated.
5. Produce phase closeout verdict.
6. Update progress report.

Đầu ra bắt buộc:
- Phase verdict: DONE / PARTIAL / FAILED.
- Evidence table.
- Deferred work.
- Accepted risks.
- Next phase recommendation.
- Cập nhật tiến độ.
```

