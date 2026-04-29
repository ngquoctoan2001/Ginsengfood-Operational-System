# 01 - CODE01 Foundation + Source Origin Prompts

## Scope

Phase `CODE01` covers foundation core, RBAC baseline, idempotency/audit/event base, source zone, source origin, evidence and verification.

Read with:

- `docs/software-specs/modules/01_FOUNDATION_CORE.md`
- `docs/software-specs/modules/02_AUTH_PERMISSION.md`
- `docs/software-specs/modules/03_MASTER_DATA.md`
- `docs/software-specs/modules/05_SOURCE_ORIGIN.md`
- `docs/software-specs/modules/16_ADMIN_UI.md`
- `docs/software-specs/api/`
- `docs/software-specs/database/`
- `docs/software-specs/ui/`

## Prompt 01.01 - CODE01 Kickoff Audit

```text
Role: BA/SA + Tech Lead Audit Agent.
Mission: Audit CODE01 current implementation against docs/software-specs. Do not edit files.
Read first: 06_MODULE_MAP.md, 07_PHASE_PLAN.md, 08_REQUIREMENTS_TRACEABILITY_MATRIX.md, modules/01_FOUNDATION_CORE.md, 02_AUTH_PERMISSION.md, 03_MASTER_DATA.md, 05_SOURCE_ORIGIN.md, 16_ADMIN_UI.md, database/, api/, ui/, testing/.
Scope: CODE01 only.
Workflow:
1. Extract target requirements for audit, idempotency, event base, RBAC, source zone/origin/evidence/verification.
2. Inspect current DB/models/migrations, backend services/routes/DTOs, frontend screens, seed and tests.
3. Classify gaps as MISSING/PARTIAL/CONFLICT/WRONG_IMPLEMENTATION/MATCH.
4. Identify first safest bounded gap.
Đầu ra: gap table, recommended first gap, affected layers, source evidence, owner blockers, next prompt to run, cập nhật tiến độ.
```

## Prompt 01.02 - Foundation DB And Event Base Plan

```text
Role: DBA + Foundation Planner.
Mission: Plan the DB/support foundation for audit_log, idempotency_registry, event_schema_registry/outbox/state_transition_log for gap {gap_id}.
Scope: planning only.
Workflow:
1. Map target tables/enums/indexes/constraints from database specs.
2. Compare current schema/migrations.
3. Define migration steps and destructive risk.
4. Define validation queries.
5. Define backend/API/FE impact.
Stop if migration would mutate append-only history or duplicate existing foundation truth.
Đầu ra: migration plan, table contract, validation query plan, write scope, non-goals, cập nhật tiến độ.
```

## Prompt 01.03 - Foundation Backend Implementation

```text
Role: Backend Foundation Agent.
Mission: Implement approved foundation backend gap {gap_id}: audit, idempotency, state transition or event base.
Read first: approved plan, modules/01_FOUNDATION_CORE.md, api convention/idempotency docs, current code.
Rules:
- Side-effect commands must be idempotent where required.
- Sensitive actions must write audit/state transition.
- Outbox/event records must not call external systems directly.
Workflow: implement minimal service/middleware/DTO/routes, add tests, update docs/handoff/progress, run backend validation.
Đầu ra: file đã sửa, behavior implemented, tests, commands, API/FE impact, cleanup, cập nhật tiến độ.
```

## Prompt 01.04 - Auth/RBAC Baseline Implementation

```text
Role: Auth/RBAC Agent.
Mission: Implement or repair CODE01 local account + RBAC baseline for roles/actions/screens required by source origin workflows.
Read first: modules/02_AUTH_PERMISSION.md, business/04_ROLE_AND_PERMISSION_MODEL.md, ui specs, api auth/permission spec, data/roles_permissions.csv.
Rules:
- UI permission is not security; backend must enforce permission.
- If one user has multiple duties, assign multiple roles; do not merge role logic silently.
Workflow: audit current auth, implement role/action checks, seed/update permissions if needed, update API errors, update frontend visibility only after backend gate, add tests.
Đầu ra: RBAC changes, permission matrix evidence, tests, cập nhật tiến độ.
```

## Prompt 01.05 - Source Zone API/Backend Implementation

```text
Role: Source Zone Backend/API Agent.
Mission: Implement source zone CRUD/query and public-field-safe source data for gap {gap_id}.
Read first: modules/05_SOURCE_ORIGIN.md, api endpoint catalog, database source tables, public trace policy.
Rules:
- Source zone is required for SELF_GROWN path.
- Public fields must not expose internal supplier/personnel/costing/private notes.
Workflow: implement DB/backend/API/DTO/permission/idempotency, update OpenAPI/API docs if present, add tests.
Đầu ra: route/DTO/service changes, validation, FE impact, cập nhật tiến độ.
```

## Prompt 01.06 - Source Origin Evidence Verification Implementation

```text
Role: Source Origin Verification Agent.
Mission: Implement source origin evidence and verification lifecycle.
Rules:
- SELF_GROWN intake must be blocked unless source origin is VERIFIED.
- Verification actions must be permissioned and audited.
- Evidence records must not be silently mutated after verification.
Workflow:
1. Implement lifecycle states and validation.
2. Implement evidence attach/review/verify/reject commands.
3. Add idempotency/audit/state transition.
4. Add API tests for verified/unverified paths.
5. Update progress report.
Đầu ra: lifecycle implemented, negative tests, lệnh đã chạy, blockers.
```

## Prompt 01.07 - Source Origin Admin UI

```text
Role: Frontend/Admin UI Agent.
Mission: Implement source zone/source origin/evidence/verification UI for CODE01.
Read first: ui screen catalog, form/table/action specs, API contract for source zones/origins.
Rules:
- Show loading/empty/error/permission denied states.
- Verification action must require reason/evidence where API requires.
- UI must not show forbidden private fields in public preview.
Workflow: update API client/types/hooks, screens/forms/tables/actions, permission-aware buttons, tests.
Đầu ra: UI file đã sửa, API sync evidence, frontend validation, cập nhật tiến độ.
```

## Prompt 01.08 - CODE01 Test, Review, Validate, Handoff

```text
Role: QA + Reviewer + Handoff Agent.
Mission: Validate CODE01 gap/phase completion.
Check: migration, seed, backend tests, frontend tests, API/FE sync, RBAC, idempotency, audit, source verification negative cases.
Required negative cases: unverified SELF_GROWN blocked; unauthorized verify blocked; duplicate command idempotent; audit/state transition written.
Đầu ra: ACCEPT/NEEDS_FIX/REJECT, lệnh kiểm chứng, missing tests, rủi ro còn lại, cập nhật báo cáo tiến độ.
```

