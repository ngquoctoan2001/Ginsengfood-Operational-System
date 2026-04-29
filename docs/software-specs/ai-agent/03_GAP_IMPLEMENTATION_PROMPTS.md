# 03 - Gap Implementation Prompts

## 1. BA Gap Extraction Prompt

```text
Extract implementation gaps for {phase}/{module}.

Use only docs/software-specs and allowed source policy.
For each gap provide:
- gap_id
- requirement_id
- source file/section
- business rule
- affected DB tables
- affected API endpoints
- affected UI screens
- affected workflows/state machines
- test cases
- owner decision needed
- priority

Do not propose code changes yet.
```

## 2. Implementation Planner Prompt

```text
Turn gap {gap_id} into a bounded implementation plan.

Đầu ra:
- Goal
- Scope and non-goals
- Files/layers likely affected
- DB migration plan
- API/DTO contract changes
- Frontend client/screen changes
- Seed changes
- Tests to add/update
- Lệnh kiểm chứng
- Rollback/forward-fix notes
- Risks and quyết định owner
```

## 3. Backend Implementation Prompt

```text
Implement backend for gap {gap_id}.

Rules:
- Enforce permission backend-side.
- Use idempotency for side-effect commands.
- Write audit/state transition for sensitive actions.
- Keep ledger/audit/history append-only.
- Emit outbox events instead of direct external sync.
- For material issue, enforce `lot_status = READY_FOR_PRODUCTION`; `QC_PASS` alone must return `RAW_MATERIAL_LOT_NOT_READY`.
- For warehouse receipt, enforce approved batch release; `QC_PASS` alone is not released.
- Do not change API contract without updating API docs and FE impact.

Đầu ra bắt buộc:
- Services/routes/DTOs changed.
- DB impact.
- Tests.
- Lệnh đã chạy.
```

## 4. Database Implementation Prompt

```text
Implement database migration for gap {gap_id}.

Rules:
- Follow migration order in dev-handoff/04_DATABASE_IMPLEMENTATION_GUIDE.md.
- Add FK/unique/check constraints where spec requires.
- Add append-only guard for audit/ledger/history.
- Include validation query.
- Include rollback/restore/forward-fix note.
- Do not destructive-update historical operational data.
```

## 5. Frontend Implementation Prompt

```text
Implement frontend for gap {gap_id}.

Rules:
- Use route/API client from API catalog.
- Update types and hooks if DTO changes.
- Implement loading, empty, error, validation, stale state.
- Enforce permission-aware UI but rely on backend for true permission gate.
- Public trace must use public API only and render whitelist fields only.
- Add/update UI tests from testing/04_UI_TEST_PLAN.md.
```

## 6. Seed Implementation Prompt

```text
Implement seed for gap {gap_id}.

Rules:
- Seed idempotent by business key.
- Preserve G1 operational baseline.
- Do not seed G0 as active/approved operational formula; G0 is research/baseline context only.
- 20 SKU baseline is required but not a permanent cap.
- Recipe groups must be exactly SPECIAL_SKU_COMPONENT, NUTRITION_BASE, BROTH_EXTRACT, SEASONING_FLAVOR.
- Required ingredients must exist.
- Dev fixtures must be flagged test/dev.
- Run seed validation and rerun seed to prove idempotency.
```

## 7. Test Implementation Prompt

```text
Implement tests for gap {gap_id}.

Use:
- testing/00_README.md
- testing/02_TEST_CASE_MATRIX.md
- testing/03_API_TEST_PLAN.md
- testing/04_UI_TEST_PLAN.md
- testing/05_INTEGRATION_TEST_PLAN.md
- testing/06_E2E_SMOKE_TEST_PLAN.md
- testing/07_SEED_VALIDATION_TEST_PLAN.md
- testing/08_REGRESSION_TEST_PLAN.md

Each test must map to REQ-* and TC-*.
Include happy path, negative path, permission, idempotency, audit/event/ledger assertion when relevant.
For material issue, include a negative test where the raw lot has `QC_PASS` but is not `READY_FOR_PRODUCTION`; expected error is `RAW_MATERIAL_LOT_NOT_READY`.
```
