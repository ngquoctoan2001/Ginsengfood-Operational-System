# 01A - CODE01A M03A Supplier Management Prompts

## Scope

Phase `CODE01A` covers M03A Supplier Management sub-module: supplier master CRUD, supplier suspend/reactivate, supplier ingredient allowlist, supplier user link, role `R-SUPPLIER` provisioning, password policy `HL-SUP-008`, và Supplier Portal authentication baseline.

Đây là tiền đề cho `CODE02-SUP` (Supplier Collaboration extension trong M06 Raw Material). Không bao gồm raw intake collaboration logic — phần đó nằm ở `CODE02` prompts 02.09-02.14.

Read with:

- `docs/v2-decisions/OD-M06-SUP-COLLAB.md` (HL-SUP-001..017, OD-MODULE-M03A-001)
- `docs/software-specs/modules/03A_SUPPLIER_MANAGEMENT.md`
- `docs/software-specs/business/04_ROLE_AND_PERMISSION_MODEL.md` (role `R-SUPPLIER`, PR-008..PR-012)
- `docs/software-specs/api/02_API_ENDPOINT_CATALOG.md` (Supplier Master M03A + Supplier Portal route families)
- `docs/software-specs/api/03_API_REQUEST_RESPONSE_SPEC.md` (Section 3A M03A DTOs)
- `docs/software-specs/database/` (`op_supplier`, `op_supplier_user_link`, `op_supplier_ingredient`)
- `docs/software-specs/ui/03_SCREEN_CATALOG.md` (SCR-SUPPLIER-LIST/DETAIL/INGREDIENT/USERS, SCR-SUP-LOGIN)
- `docs/software-specs/ui/06_TABLE_ACTION_FILTER_SPECIFICATION.md` (TBL-SUPPLIER-LIST, TBL-SUPPLIER-INGREDIENT, TBL-SUPPLIER-USERS)
- `docs/software-specs/ui/07_UI_STATE_AND_VALIDATION.md` (UI-VAL-SUP-001..006)
- `docs/software-specs/testing/02_TEST_CASE_MATRIX.md` (TC-M03A-SUP-001..AUTH-004 + TC-HL-SUP-SCOPE-001/ALLOW-001)

## Prompt 01A.01 - CODE01A Kickoff Audit

```text
Role: BA/SA + Tech Lead Audit Agent (M03A scope).
Mission: Audit M03A Supplier Management target vs current implementation. Do not edit files.
Read first: tất cả file trong "Read with" trên + docs/v2-decisions/OD-M06-SUP-COLLAB.md.
Workflow:
1. Extract requirements REQ-M03A-001..004 và HL-SUP-001/005/006/007.
2. Inspect current DB/models/migrations cho `op_supplier`, `op_supplier_user_link`, `op_supplier_ingredient`.
3. Inspect current backend services/routes/DTOs cho `/api/admin/suppliers/*` và `/api/supplier/auth/*`.
4. Inspect current admin UI screens SCR-SUPPLIER-* và supplier portal SCR-SUP-LOGIN.
5. Classify gaps MISSING/PARTIAL/CONFLICT/WRONG_IMPLEMENTATION/MATCH.
6. Identify first safest bounded gap.
Đầu ra: gap table, recommended first gap, affected layers, source evidence, owner blockers, next prompt to run, cập nhật tiến độ.
```

## Prompt 01A.02 - Supplier Master DB + Backend Plan

```text
Role: DBA + M03A Planner.
Mission: Plan DB + backend cho supplier master, suspend/reactivate, ingredient allowlist, user link cho gap {gap_id}.
Scope: planning only.
Workflow:
1. Map target tables: `op_supplier` (id, code, name, tax_code, contact, status enum ACTIVE/SUSPENDED/INACTIVE, audit cols), `op_supplier_user_link` (supplier_id, user_id UNIQUE), `op_supplier_ingredient` (supplier_id, ingredient_id, status, effective dates, UNIQUE (supplier_id, ingredient_id, status=ACTIVE)).
2. Compare current schema/migrations.
3. Define migration steps (forward + rollback consideration).
4. Define validation queries (counts, unique constraints, FK integrity).
5. Define backend service shape: SupplierService, SupplierUserService, SupplierIngredientAllowlistService.
6. Define API impact: routes trong api/02 catalog M03A row.
Stop if migration mutates append-only history hoặc duplicate existing supplier truth (M03 supplier).
Đầu ra: migration plan, table contract, validation query plan, service shape, write scope, non-goals, cập nhật tiến độ.
```

## Prompt 01A.03 - Supplier Master Backend + API Implementation

```text
Role: M03A Backend Agent.
Mission: Implement supplier master CRUD + suspend/reactivate + ingredient allowlist + user link cho gap {gap_id}.
Read first: approved plan, modules/03A_SUPPLIER_MANAGEMENT.md, api/03 Section 3A DTOs.
Rules:
- Suspend ngay lập tức block login + command (PR-012). Reactivate cần `R-OPS-MGR`.
- Allowlist `op_supplier_ingredient` phải approved + status `ACTIVE` mới được dùng (UI-VAL-SUP-006).
- Supplier user link unique (1 user ↔ 1 supplier_id).
- Mọi command ghi audit + idempotent theo Idempotency-Key.
- Không expose supplier internal fields qua public route.
Workflow:
1. Implement DTO + handler + service cho SupplierCreateRequest, SupplierUpdateRequest, SupplierSuspendRequest, SupplierReactivateRequest.
2. Implement SupplierIngredientCreateRequest + delete + list.
3. Implement SupplierUserCreateRequest + SupplierUserResetPasswordRequest.
4. Wire permission `supplier.*` namespace.
5. API tests TC-M03A-SUP-001 + TC-M03A-MAP-002 + TC-HL-SUP-ALLOW-001.
Đầu ra: file đã sửa, API contract evidence, validation, audit, cập nhật tiến độ.
```

## Prompt 01A.04 - Supplier Portal Auth + Scope Guard Backend

```text
Role: Supplier Portal Auth Agent.
Mission: Implement Supplier Portal authentication baseline + scope guard middleware cho gap {gap_id}.
Rules:
- `/api/supplier/auth/login` chỉ chấp nhận credential gắn `op_supplier_user_link`.
- JWT scope phải bao gồm `supplier_id` + audience claim `supplier-portal` (PR-009).
- Mọi route `/api/supplier/*` chạy qua scope guard middleware: resolve `supplier_id` từ token, reject `403 SUPPLIER_SCOPE_VIOLATION` nếu request muốn truy cập tài nguyên supplier khác (PR-008).
- Password hash bcrypt/argon2; complexity + lockout theo `HL-SUP-008` (PR-011).
- Suspended/Inactive supplier reject login (PR-012).
- Reset password ghi audit `supplier.user.reset_password`; không log plaintext.
Workflow:
1. Implement login + refresh handler.
2. Implement scope guard middleware + integration test.
3. Negative tests TC-M03A-AUTH-004 + TC-HL-SUP-SCOPE-001.
4. OpenAPI cập nhật Section 3A.
Đầu ra: routes, middleware, tests, audit evidence, cập nhật tiến độ.
```

## Prompt 01A.05 - Supplier Master Admin UI + Supplier Portal Login UI

```text
Role: Frontend/Admin UI Agent (M03A scope).
Mission: Implement SCR-SUPPLIER-LIST, SCR-SUPPLIER-DETAIL, SCR-SUPPLIER-INGREDIENT, SCR-SUPPLIER-USERS (admin) + SCR-SUP-LOGIN (supplier portal).
Rules:
- Admin UI dùng adminClient; supplier portal UI dùng supplierClient (sinh từ OpenAPI).
- TBL-SUPPLIER-LIST hiển thị status badge ACTIVE/SUSPENDED/INACTIVE; action suspend/reactivate role-gated.
- SCR-SUPPLIER-INGREDIENT hiển thị allowlist với search ingredient + check duplicate UNIQUE (UI-VAL-SUP-004).
- SCR-SUPPLIER-USERS hiển thị link tới user + reset password action.
- SCR-SUP-LOGIN: form login với password policy hint + lockout message; không leak password complexity rule chi tiết.
- Loading/empty/error/permission denied states đầy đủ.
Workflow:
1. Generate adminClient + supplierClient từ OpenAPI.
2. Implement screens + tables + forms + actions.
3. Wire role-gated actions (R-ADMIN/R-OPS-MGR cho admin; R-SUPPLIER cho portal).
4. FE tests typecheck + unit + smoke.
Đầu ra: UI files, API client generated, FE tests, cập nhật tiến độ.
```

## Prompt 01A.06 - CODE01A Seed + Validation

```text
Role: Seed/Data Agent (M03A scope).
Mission: Ensure CODE01A seed bao gồm role `R-SUPPLIER`, sample supplier `SUP_DEV_001` ACTIVE, supplier user link `sup_dev_001_user`, allowlist ingredient cho smoke E2E-SMOKE-007.
Read first: data/roles_permissions.csv, data/seed validation queries.
Workflow:
1. Add role R-SUPPLIER + permission namespace `supplier.*` vào seed roles/permissions.
2. Add SUP_DEV_001 với status ACTIVE.
3. Add sup_dev_001_user link tới SUP_DEV_001.
4. Add allowlist row (ingredient smoke) với status ACTIVE.
5. Validation queries: count R-SUPPLIER, count active supplier ≥ 1, count active allowlist ≥ 1, supplier user link unique.
6. Run seed chain 2 lần để confirm idempotency.
Đầu ra: seed file diffs, validation evidence, cập nhật tiến độ.
```

## Prompt 01A.07 - CODE01A Test, Review, Validate, Handoff

```text
Role: QA + Reviewer + DevOps Agent.
Mission: Validate CODE01A implementation và handoff cho CODE02-SUP.
Required tests:
- TC-M03A-SUP-001 supplier CRUD + suspend block login.
- TC-M03A-MAP-002 allowlist enforcement.
- TC-M03A-USER-003 supplier user scope.
- TC-M03A-AUTH-004 password policy + lockout.
- TC-HL-SUP-SCOPE-001 cross-supplier 403.
- TC-HL-SUP-ALLOW-001 ingredient allowlist negative.
Validation gates:
1. Backend build/test (Gate 2): dotnet build --no-incremental -warnaserror; dotnet test --no-build.
2. Frontend typecheck/build (Gate 3): npx tsc -b --noEmit; npm run build (admin-web + supplier portal).
3. EF migration apply (Gate 4) cho `op_supplier`, `op_supplier_user_link`, `op_supplier_ingredient`.
4. Seed validation (Gate 6) chạy 2 lần idempotent.
5. Process cleanup (Gate 8): tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants + dotnet build-server shutdown.
Đầu ra: kết quả từng gate, blockers, residual risks, cập nhật v2-handoff/CODE01A-handoff.md, gọi prompt 02.09 để bắt đầu CODE02-SUP.
```
