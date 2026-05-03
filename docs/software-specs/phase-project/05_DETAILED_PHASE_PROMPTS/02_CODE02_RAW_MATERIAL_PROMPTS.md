# 02 - CODE02 Raw Material Prompts

## Scope

Phase `CODE02` covers raw material intake, procurement type, raw material lot, incoming QC, lot readiness and raw receipt ledger boundary.

## Prompt 02.01 - CODE02 Kickoff Audit

```text
Role: BA/SA + Tech Lead Audit Agent.
Mission: Audit CODE02 target vs current implementation. Do not edit files.
Read first: modules/06_RAW_MATERIAL.md, modules/05_SOURCE_ORIGIN.md, modules/11_WAREHOUSE_INVENTORY.md, business rules, api, database, ui, testing, data/source_origin_fixture.csv.
Workflow:
1. Extract rules for SELF_GROWN and PURCHASED intake.
2. Map intake, lot, incoming QC, raw ledger receipt, UI and tests.
3. Verify QC vocabulary uses QC_PASS/QC_HOLD/QC_REJECT.
4. Pick first bounded gap.
Output: gap table, recommended gap, blocker list, progress update.
```

## Prompt 02.02 - Intake Procurement Type Plan

```text
Role: Planner Agent.
Mission: Plan gap {gap_id} for procurement_type validation and intake creation.
Rules:
- SELF_GROWN requires VERIFIED source origin.
- PURCHASED requires supplier/COA and must not require source zone.
- Source/supplier semantics must not be mixed in UI labels, DTOs or DB constraints.
Output: DB/API/FE/seed/test plan, write scope, non-goals, validation gate, progress update.
```

## Prompt 02.03 - Raw Intake DB/Backend/API

```text
Role: Raw Intake Backend/API Agent.
Mission: Implement raw material intake for approved gap {gap_id}.
Workflow:
1. Update schema/model/constraints if needed.
2. Implement create/update/submit/approve commands where specified.
3. Enforce procurement type validation backend-side.
4. Add idempotency for side-effect commands.
5. Emit audit/state transition.
6. Add API tests for SELF_GROWN and PURCHASED paths.
Output: files changed, API contract, validation, progress update.
```

## Prompt 02.04 - Raw Lot Lifecycle And Incoming QC

```text
Role: Raw Lot/QC Agent.
Mission: Implement raw lot lifecycle and incoming QC readiness.
Rules:
- Raw lot cannot become READY until incoming QC_PASS.
- QC_HOLD and QC_REJECT block issue/ready.
- QC_PASS must be recorded as QC result, not as downstream production approval.
Workflow: implement lot state, QC inspection/result commands, transition log/audit, API tests, UI impact.
Output: lifecycle evidence, negative tests, progress update.
```

## Prompt 02.05 - Raw Receipt Ledger Boundary

```text
Role: Inventory Boundary Agent.
Mission: Implement raw material receipt ledger boundary without confusing it with material issue decrement.
Rules:
- Raw intake/receipt can add raw inventory according to spec.
- Material Issue Execution later is the production decrement point.
- Ledger append-only.
Workflow: audit ledger model, implement receipt transaction type, balance projection, tests.
Output: ledger entries, balance validation, no double-decrement evidence, progress update.
```

## Prompt 02.06 - Raw Material Admin UI

```text
Role: Frontend/Admin UI Agent.
Mission: Implement raw intake, raw lot and incoming QC screens.
Rules:
- UI copy must say supplier if PURCHASED, source origin if SELF_GROWN.
- UI must block/disable invalid actions but backend remains authoritative.
- Show QC_HOLD/QC_REJECT reasons and lot not-ready state.
Output: UI/API client changes, tests, frontend validation, progress update.
```

## Prompt 02.07 - CODE02 Seed And Fixture Validation

```text
Role: Seed/Data Agent.
Mission: Ensure CODE02 seed/fixtures support SELF_GROWN and PURCHASED smoke tests.
Read first: data/source_origin_fixture.csv, data/uom.csv, data/04_SEED_VALIDATION_QUERIES.md.
Workflow: validate supplier/source fixture, UOM, COA placeholder policy, seed idempotency.
Output: seed changes or no-change evidence, validation commands, progress update.
```

## Prompt 02.08 - CODE02 Test, Review, Validate, Handoff

```text
Role: QA + Reviewer Agent.
Mission: Validate CODE02 implementation.
Required tests: SELF_GROWN verified pass, SELF_GROWN unverified fail, PURCHASED with supplier/COA pass, PURCHASED missing supplier/COA fail, QC_HOLD/QC_REJECT block ready/issue, duplicate command idempotent.
Output: verdict, findings, commands, handoff, progress update.
```

## Prompt 02.09 - CODE02-SUP Supplier Collaboration Audit

```text
Role: BA/SA + Tech Lead Audit Agent (Supplier Collaboration scope).
Mission: Audit supplier collaboration extension target vs current implementation. Do not edit files.
Read first: docs/v2-decisions/OD-M06-SUP-COLLAB.md (HL-SUP-001..017), modules/06_RAW_MATERIAL.md mục 11 (2-axis state machine), modules/03A_SUPPLIER_MANAGEMENT.md, database schema (op_raw_material_receipt mở rộng axis A + created_by_party, op_supplier_user_link, op_supplier_ingredient, op_supplier_collab_feedback), api/03_API_REQUEST_RESPONSE_SPEC.md (Sections 3.1, 3.2, 3A), ui/03_SCREEN_CATALOG.md (SCR-SUPPLIER-*, SCR-SUP-*, SCR-RAW-INTAKE-DETAIL/RECEIVE/LINE-QC), workflows/04 mục 4A, workflows/05 step 2A/3A, workflows/06 AP-SUP-*, workflows/07 EX-SUP-*, workflows/08 SMK-SUP-001..006 + SMK-N012..N015, testing/02 TC-M06-SUP-* + TC-M03A-* + TC-HL-SUP-*.
Workflow:
1. Confirm single-source-of-truth: chỉ op_raw_material_receipt; KHÔNG tạo op_supplier_delivery song song (TC-HL-SUP-NO-PARALLEL-001).
2. Map 2-axis status (axis A supplier_collaboration_status × axis B raw_receipt_status) qua DB/backend/API/UI/workflow/test.
3. Verify scope guard backend (PR-008, PR-009) cho /api/supplier/* và allowlist (PR-010), password (PR-011), suspend block (PR-012).
4. Pick first bounded gap.
Đầu ra: gap table, recommended gap, blocker list, cập nhật tiến độ.
```

## Prompt 02.10 - Receipt 2-Axis Backend + DB Migration

```text
Role: DBA + Receipt Backend Agent.
Mission: Implement axis A supplier_collaboration_status + axis B raw_receipt_status trong op_raw_material_receipt cho gap {gap_id}.
Rules:
- KHÔNG tạo bảng op_supplier_delivery song song. Mọi pre-receipt + post-receipt dùng cùng op_raw_material_receipt.
- Migration thêm cột axis A enum, cột created_by_party (USER/SUPPLIER), check constraint procurement_type=PURCHASED khi created_by_party=SUPPLIER.
- Transition chỉ chấp nhận theo bảng combined valid trong modules/06_RAW_MATERIAL.md mục 11.2.
- SUPPLIER_DECLINED chặn axis B sang RECEIVED_PENDING_QC.
- Audit + state_transition_log cho mỗi axis.
Workflow:
1. Migration EF Core: thêm cột + index + check constraint + enum.
2. Backend: state machine transition guard, idempotency cho acknowledge/receive/accept/reject/return/close.
3. API tests 2-axis happy path + negative TC-HL-SUP-DECLINE-001 + TC-HL-SUP-NO-PARALLEL-001.
Đầu ra: migration, service, API tests, ledger evidence, cập nhật tiến độ.
```

## Prompt 02.11 - Supplier Portal API + Scope Guard

```text
Role: Supplier Portal Backend Agent.
Mission: Implement /api/supplier/* routes (auth/login, intakes CRUD, evidence upload, confirm, decline) cho gap {gap_id}.
Rules:
- Route /api/supplier/* chỉ chấp nhận role R-SUPPLIER + audience claim supplier-portal (PR-009).
- Backend resolve supplier_id từ op_supplier_user_link; mọi query/command scope theo supplier_id (PR-008).
- Submit/confirm intake validate ingredient nằm trong op_supplier_ingredient (PR-010).
- Password theo HL-SUP-008 (bcrypt/argon2, lockout, complexity); reset password ghi audit supplier.user.reset_password.
- Edit lock sau axis A SUPPLIER_CONFIRMED (UI-VAL-SUP-007).
- Supplier SUSPENDED/INACTIVE block toàn bộ login + command (PR-012).
Workflow:
1. Implement auth/login + JWT scope.
2. Implement intake submit/confirm/decline + evidence upload + scan_status gate.
3. Negative tests: scope violation 403 (TC-HL-SUP-SCOPE-001), allowlist violation (TC-HL-SUP-ALLOW-001), password yếu, suspended supplier block.
4. OpenAPI cập nhật Section 3.2 + Section 3A.
Đầu ra: routes, DTOs, scope guard middleware, tests TC-M06-SUP-001..004 + TC-M03A-AUTH-004, cập nhật tiến độ.
```

## Prompt 02.12 - Admin Acknowledge/Receive/Line QC Backend

```text
Role: Admin Receipt Backend Agent.
Mission: Implement /api/admin/raw-material/intakes/{id}/acknowledge|receive|lines/{lineId}/accept|reject|return|close|feedback cho gap {gap_id}.
Rules:
- Acknowledge yêu cầu axis A SUPPLIER_CONFIRMED.
- Receive yêu cầu axis A SUPPLIER_CONFIRMED và sinh raw lot từ op_raw_material_receipt (single source).
- Line accept/reject/return phải giữ sum invariant accepted+rejected+returned=received (UI-VAL-SUP-009).
- Return + reject yêu cầu evidence (UI-VAL-SUP-010).
- Close yêu cầu tất cả line đã quyết định và chuyển axis A sang SUPPLIER_CONFIRMED.
Workflow:
1. Implement command handlers + transition guard + idempotency.
2. Tests TC-M06-SUP-005..008 + EX-RECEIPT-RETURN coverage.
Đầu ra: routes, services, ledger evidence, audit, cập nhật tiến độ.
```

## Prompt 02.13 - Supplier Portal UI + Admin 2-Axis Extensions

```text
Role: Frontend/Admin UI Agent (Supplier scope).
Mission: Implement Supplier Portal screens + admin SCR-RAW-INTAKE-DETAIL/SCR-RAW-RECEIVE/SCR-RAW-LINE-QC mở rộng cho 2-axis collaboration.
Rules:
- Supplier Portal route /supplier/* dùng supplierClient (sinh từ OpenAPI).
- Hiển thị 2-axis status badge (axis A + axis B) ở SCR-RAW-INTAKE-DETAIL.
- Allowlist dropdown ingredient ở SCR-SUP-PORTAL-INTAKES form (UI-VAL-SUP-006).
- Edit lock sau SUPPLIER_CONFIRMED (UI-VAL-SUP-007); receive lock sau RECEIVED_PENDING_QC (UI-VAL-SUP-008).
- Sum invariant validate phía FE (UI-VAL-SUP-009) trước submit; backend luôn enforce.
- Evidence required cho return/reject (UI-VAL-SUP-010).
Workflow:
1. Generate supplierClient từ OpenAPI.
2. Implement SCR-SUP-LOGIN, SCR-SUP-PORTAL-INTAKES, SCR-SUP-PORTAL-EVIDENCE.
3. Mở rộng SCR-RAW-INTAKE-DETAIL với 2-axis + acknowledge/receive button.
4. Implement SCR-RAW-RECEIVE form, SCR-RAW-LINE-QC form, TBL-SUP-PORTAL-INTAKES + TBL-SUP-PORTAL-EVIDENCE.
5. Frontend tests typecheck + smoke E2E-SMOKE-007.
Đầu ra: UI files, supplierClient generated, FE tests, cập nhật tiến độ.
```

## Prompt 02.14 - CODE02-SUP Test/Validate/Handoff

```text
Role: QA + DevOps Agent.
Mission: Run validation gates + handoff cho supplier collaboration extension.
Workflow:
1. Backend build/test (Gate 2): dotnet build --no-incremental -warnaserror; dotnet test --no-build.
2. Frontend typecheck/build (Gate 3): npx tsc -b --noEmit; npm run build (admin-web + supplier-portal nếu tách).
3. EF migration apply (Gate 4): dotnet ef database update cho axis A + supplier tables.
4. Seed validation (Gate 6): chạy seed chain bao gồm role R-SUPPLIER, sample supplier user, allowlist; chạy 2 lần để confirm idempotency.
5. Smoke E2E-SMOKE-007 (Gate 7) supplier collab pre-receipt: SMK-PRE-008, SMK-SUP-001..006, SMK-N012..N015.
6. Process cleanup (Gate 8): tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants + dotnet build-server shutdown.
Đầu ra: kết quả từng gate, blockers, residual risks, cập nhật v2-handoff/CODE02-SUP-handoff.md.
```
