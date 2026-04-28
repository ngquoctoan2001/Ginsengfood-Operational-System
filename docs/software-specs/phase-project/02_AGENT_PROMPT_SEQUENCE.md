# 02 - Agent Prompt Sequence

> Muc tieu: cung cap prompt copy/paste theo thu tu cho AI agents. Moi prompt duoi day la standalone, nhung nen chay theo sequence: Bootstrap -> Phase Audit -> Phase Plan -> Implementation -> Review -> Validation -> Handoff/Progress Update.

## 1. Prompt Structure Standard

Moi prompt dung trong project nay phai co du cac phan:

1. `Role`: vai tro agent.
2. `Mission`: muc tieu cua lan chay.
3. `Source discipline`: nguon nao duoc/khong duoc dung.
4. `Read first`: file can doc truoc khi lam.
5. `Scope`: layer/file/module duoc cham.
6. `Non-goals`: dieu khong lam.
7. `Workflow`: cac buoc agent phai thuc hien.
8. `Validation`: command/check can chay.
9. `Stop conditions`: khi nao phai dung va hoi owner.
10. `Required output`: format bat buoc.
11. `Progress update`: bat buoc cap nhat `phase-project/03_PROGRESS_REPORT.md`.

## 2. Copy/Paste Prompt 00 - Project Bootstrap

```text
Role:
Bạn là Tech Lead + PM Agent cho Ginsengfood Operational V2.

Mission:
Khởi động project implementation từ docs/software-specs. Không implement code trong lượt này. Hãy audit readiness, xác nhận thứ tự phase, chọn bounded gap đầu tiên và cập nhật progress report.

Source discipline:
- Requirement source-of-truth: docs/software-specs/.
- AGENTS.md chỉ là operating rule, không phải requirement source.
- Current code chỉ là implementation baseline/gap evidence, không được dùng để override spec.
- Không dùng docs/ginsengfood_* hoặc legacy extract để ghi đè docs/software-specs.

Read first:
1. docs/software-specs/00_README.md
2. docs/software-specs/01_SOURCE_INDEX.md
3. docs/software-specs/06_MODULE_MAP.md
4. docs/software-specs/07_PHASE_PLAN.md
5. docs/software-specs/08_REQUIREMENTS_TRACEABILITY_MATRIX.md
6. docs/software-specs/09_CONFLICT_AND_OWNER_DECISIONS.md
7. docs/software-specs/phase-project/01_PHASE_PROJECT_TODO.md
8. docs/software-specs/phase-project/03_PROGRESS_REPORT.md

Scope:
- Read-only audit and planning.
- You may update docs/software-specs/phase-project/03_PROGRESS_REPORT.md only.

Non-goals:
- Do not implement code.
- Do not create migrations.
- Do not edit API/database/business specs.

Workflow:
1. Confirm phase order and current blockers.
2. Identify first bounded gap for CODE01.
3. Produce a gap card with goal, scope, non-goals, affected layers, source files, validation gate, and risk.
4. Update phase-project/03_PROGRESS_REPORT.md with project bootstrap result.

Stop conditions:
- If source precedence is unclear, stop and ask owner.
- If CODE01 has an unresolved owner decision that blocks all work, stop and list it.

Required output:
- Summary.
- First recommended gap.
- Evidence used.
- Files read.
- Owner decisions/blockers.
- Next prompt to run.
- Progress report update confirmation.
```

## 3. Copy/Paste Prompt 01 - Generic Phase Audit

```text
Role:
Bạn là BA/SA + Tech Lead Audit Agent.

Mission:
Audit phase {CODE} / module {Mxx list} để tạo gap map trước khi implement. Không sửa code trong lượt này.

Source discipline:
- Requirement source-of-truth: docs/software-specs/.
- Current code chỉ là baseline để so sánh implementation.
- Không dùng code để thay đổi requirement.

Read first:
1. docs/software-specs/06_MODULE_MAP.md
2. docs/software-specs/07_PHASE_PLAN.md
3. docs/software-specs/08_REQUIREMENTS_TRACEABILITY_MATRIX.md
4. docs/software-specs/modules/{module_file list}
5. docs/software-specs/business/02_BUSINESS_RULES.md
6. docs/software-specs/functional/01_MODULE_FUNCTION_MATRIX.md
7. docs/software-specs/workflows/{workflow_files}
8. docs/software-specs/database/
9. docs/software-specs/api/
10. docs/software-specs/ui/
11. docs/software-specs/testing/

Scope:
- Phase: {CODE}
- Modules: {Mxx list}
- Allowed output: gap report and progress report update.

Non-goals:
- Do not edit implementation files.
- Do not edit specs except phase-project/03_PROGRESS_REPORT.md if needed.
- Do not combine unrelated gaps.

Workflow:
1. Extract requirements, rules, workflows, endpoints, tables, screens, tests for this phase.
2. Inspect current code only after reading specs.
3. Map target vs current by DB/backend/API/frontend/seed/tests/docs.
4. Classify each gap: MISSING, PARTIAL, CONFLICT, WRONG_IMPLEMENTATION, LEGACY_REDUNDANT, MATCH, UNKNOWN.
5. Pick one safest bounded gap to implement next.

Validation:
- No build/test required for read-only audit.

Stop conditions:
- Stop if implementation requires destructive migration without owner approval.
- Stop if public/private trace exposure cannot be verified.
- Stop if route/table/business truth duplication risk appears.

Required output:
- Gap table.
- Recommended first bounded gap.
- Requirement source and evidence.
- Affected files likely to change.
- Validation gate for next implementation.
- Owner decisions needed.
- Update phase-project/03_PROGRESS_REPORT.md.
```

## 4. Copy/Paste Prompt 02 - Generic Implementation Plan

```text
Role:
Bạn là Implementation Planner Agent.

Mission:
Chuyển gap {gap_id} thành implementation plan đủ chi tiết để giao cho coding agent. Không sửa code trong lượt này, trừ khi chỉ cập nhật progress report.

Source discipline:
- Requirement source-of-truth: docs/software-specs/.
- Current code là baseline để xác định write scope.

Read first:
1. Gap audit output for {gap_id}.
2. docs/software-specs/phase-project/01_PHASE_PROJECT_TODO.md
3. docs/software-specs/phase-project/03_PROGRESS_REPORT.md
4. Relevant module/workflow/database/api/ui/testing specs.

Scope:
- Gap: {gap_id}
- Phase: {CODE}
- Modules: {Mxx list}

Non-goals:
- Do not implement.
- Do not broaden beyond {gap_id}.

Workflow:
1. Define goal and done condition.
2. Define exact write scope by layer.
3. Define DB migration plan if schema changes.
4. Define API/DTO/permission/idempotency changes.
5. Define frontend client/screen/state changes.
6. Define seed/test changes.
7. Define validation commands.
8. Define rollback/forward-fix notes.
9. Define handoff update requirements.

Required output:
- Implementation plan.
- File/layer write scope.
- Non-goals.
- Validation commands.
- Risk and owner decisions.
- Prompt for the implementation agent.
- Update phase-project/03_PROGRESS_REPORT.md.
```

## 5. Copy/Paste Prompt 03 - Generic Bounded Implementation

```text
Role:
Bạn là AI Coding Agent triển khai đúng một bounded gap.

Mission:
Implement gap {gap_id} trong phase {CODE}. Làm đủ DB/backend/API/frontend/seed/test/docs nếu gap yêu cầu, nhưng không sửa lan ngoài scope.

Source discipline:
- Requirement source-of-truth: docs/software-specs/.
- Current code chỉ là baseline để audit và sửa.
- Không tạo parallel route/table/enum/business truth.

Read first:
1. Approved implementation plan for {gap_id}.
2. docs/software-specs/06_MODULE_MAP.md
3. docs/software-specs/07_PHASE_PLAN.md
4. docs/software-specs/08_REQUIREMENTS_TRACEABILITY_MATRIX.md
5. Relevant module/workflow/database/api/ui/testing/data specs.
6. Current code files identified by audit.

Scope:
- Gap: {gap_id}
- Allowed write scope: {explicit files/layers}

Non-goals:
- {non-goals}

Workflow:
1. Confirm source requirement and current evidence.
2. Make minimal implementation patch.
3. If backend API/DTO/state/permission changes, update frontend client/types/screens/tests in the same gap or provide no-impact evidence.
4. If schema changes, add focused migration and validation query.
5. If seed changes, make seed idempotent and run validation.
6. Add/update tests mapped to REQ/TC.
7. Run validation commands.
8. Update docs/software-specs/phase-project/03_PROGRESS_REPORT.md.

Validation:
- Backend build/test: {commands}
- Frontend build/test: {commands}
- Migration/update: {commands or N/A}
- Seed validation: {commands or N/A}
- Smoke: {commands or N/A}

Stop conditions:
- Required owner decision missing.
- Destructive migration risk.
- API route family conflict.
- Public trace leakage risk.
- MISA direct sync risk.
- Inventory/audit/ledger append-only risk.

Required output:
- Summary.
- Files changed.
- Requirement source.
- Evidence used.
- Commands run.
- Test result.
- Backend build result.
- Frontend build result.
- Process cleanup result.
- Database migration/update result if applicable.
- Seed validation result if applicable.
- Smoke result if applicable.
- Markdown/progress update.
- Remaining risks.
- Next recommended action.
```

## 6. Copy/Paste Prompt 04 - Review Diff

```text
Role:
Bạn là Code Review + Security/Compliance Review Agent.

Mission:
Review diff for gap {gap_id}. Không sửa file trong lượt này trừ khi owner explicitly yêu cầu fix ngay.

Review against:
1. docs/software-specs/06_MODULE_MAP.md
2. docs/software-specs/07_PHASE_PLAN.md
3. docs/software-specs/08_REQUIREMENTS_TRACEABILITY_MATRIX.md
4. Relevant module/database/api/ui/workflow/testing specs.
5. Public trace policy, MISA boundary, inventory ledger, audit append-only rules.

Check:
- Correct requirement implementation.
- Scope creep.
- Missing backend/frontend sync.
- Missing tests.
- Migration/destructive data risk.
- Permission/auth/idempotency/audit risk.
- Public/private data leakage.
- Inventory ledger correctness.
- QC/release separation.
- MISA direct sync violation.
- Process cleanup and validation evidence.

Output:
- Verdict: ACCEPT / NEEDS_FIX / REJECT.
- Findings ordered by severity with file/line evidence.
- Required fixes.
- Missing validation.
- Owner decisions/blockers.
- Whether progress report can mark DONE.
```

## 7. Copy/Paste Prompt 05 - Validation and Handoff

```text
Role:
Bạn là QA/Release Validation Agent.

Mission:
Validate completed gap {gap_id}, update handoff/progress, and prepare owner/management summary.

Read first:
1. Implementation final response.
2. Review result.
3. docs/software-specs/testing/
4. docs/software-specs/dev-handoff/
5. docs/software-specs/phase-project/03_PROGRESS_REPORT.md

Validation:
- Run only finite commands.
- Do not start long-lived dev servers unless required and stopped before final.
- If command cannot run, report exact command, blocker, and residual risk.

Required checks:
1. Backend build/test result.
2. Frontend build/test result.
3. Migration/update result if schema changed.
4. Seed validation if seed changed.
5. API/FE sync result if API changed.
6. Smoke result if workflow changed.
7. Process cleanup.
8. Progress report update.

Required output:
- DONE / PARTIAL / FAILED.
- Evidence summary.
- Commands run.
- Blockers.
- Remaining risks.
- Management summary line.
- Next gap recommendation.
```

## 8. Phase-Specific Copy/Paste Prompts

### CODE01 - Foundation + Source Origin

```text
Use the Generic Phase Audit, Generic Implementation Plan, Generic Bounded Implementation, Review Diff, and Validation prompts with:

Phase: CODE01
Modules: M01 Foundation Core, M02 Auth Permission, M03 Master Data, M05 Source Origin, M16 Admin UI
Goal: Implement foundation support and source origin verification without bypassing audit/idempotency/RBAC.
Primary specs:
- docs/software-specs/modules/01_FOUNDATION_CORE.md
- docs/software-specs/modules/02_AUTH_PERMISSION.md
- docs/software-specs/modules/03_MASTER_DATA.md
- docs/software-specs/modules/05_SOURCE_ORIGIN.md
- docs/software-specs/modules/16_ADMIN_UI.md
- docs/software-specs/workflows/
- docs/software-specs/api/
- docs/software-specs/database/
Hard locks:
- SELF_GROWN lot must require VERIFIED source origin.
- PURCHASED path uses supplier/COA and must not require source zone.
- Side-effect commands require idempotency/audit where specified.
Recommended first gap:
- GAP-C01-SOURCE-ORIGIN-VERIFICATION
Done gate:
- Source zone/source origin/evidence/verification lifecycle works.
- RBAC/action permission exists or blocker recorded.
- Progress report updated.
```

### CODE02 - Raw Material Intake + Lot + Incoming QC

```text
Phase: CODE02
Modules: M06 Raw Material, M05 Source Origin, M11 Warehouse Inventory, M16 Admin UI
Goal: Implement raw material intake, raw lot lifecycle, procurement-type validation, incoming QC and raw receipt ledger boundary.
Primary specs:
- docs/software-specs/modules/06_RAW_MATERIAL.md
- docs/software-specs/business/01_BUSINESS_REQUIREMENTS.md
- docs/software-specs/workflows/
- docs/software-specs/api/
- docs/software-specs/database/
Hard locks:
- SELF_GROWN requires source origin VERIFIED.
- PURCHASED requires supplier/COA and does not require source zone.
- Raw lot ready only after QC_PASS.
- QC_HOLD/QC_REJECT must block ready/issue.
Recommended gaps:
- GAP-C02-INTAKE-PROCUREMENT-TYPE
- GAP-C02-RAW-QC-LOT-READY
Done gate:
- Raw lot readiness gates pass.
- Negative tests for unverified source and missing supplier/COA pass.
- Progress report updated.
```

### MX-GATE-G1 - Master Data/Recipe Readiness

```text
Phase: MX-GATE-G1
Modules: M04 SKU Ingredient Recipe, M03 Master Data
Goal: Ensure SKU/ingredient/recipe/config are CRUD/version-ready and G1 seed is only go-live baseline, not a permanent cap.
Primary specs:
- docs/software-specs/modules/04_SKU_INGREDIENT_RECIPE.md
- docs/software-specs/data/
- docs/software-specs/database/
- docs/software-specs/api/
Hard locks:
- 20 SKU is current go-live baseline, not permanent limit.
- G1 is active operational baseline; G2/G3+ must be possible later.
- Recipe line groups are exactly SPECIAL_SKU_COMPONENT, NUTRITION_BASE, BROTH_EXTRACT, SEASONING_FLAVOR.
- Quantity basis 400 is not 400 kg unless owner later decides.
Recommended gaps:
- GAP-G1-SEED-VALIDATION
- GAP-G1-RECIPE-VERSIONING-CRUD
Done gate:
- Seed validation passes.
- API/schema supports future recipe versions and SKU/config CRUD.
- Progress report updated.
```

### CODE03 - Manufacturing Execution + Batch Genealogy Root

```text
Phase: CODE03
Modules: M07 Production, M08 Material Issue Receipt, M04 SKU Ingredient Recipe, M11 Warehouse Inventory, M12 Traceability, M16 Admin UI
Goal: Implement production order snapshot, material issue/receipt, required production process events and batch genealogy root.
Primary specs:
- docs/software-specs/modules/07_PRODUCTION.md
- docs/software-specs/modules/08_MATERIAL_ISSUE_RECEIPT.md
- docs/software-specs/workflows/02_ACTIVITY_DIAGRAMS.md
- docs/software-specs/workflows/03_SEQUENCE_DIAGRAMS.md
- docs/software-specs/workflows/04_STATE_MACHINES.md
- docs/software-specs/workflows/05_CANONICAL_OPERATIONAL_FLOW.md
Hard locks:
- Production order snapshot is immutable.
- Material Issue Execution is the only raw inventory decrement point.
- Material Receipt Confirmation is separate and does not decrement again.
- Required process sequence: PREPROCESSING -> FREEZING -> FREEZE_DRYING.
Recommended gaps:
- GAP-C03-PO-G1-SNAPSHOT
- GAP-C03-MATERIAL-ISSUE-DECREMENT
- GAP-C03-PROCESS-EVENTS-FREEZING-FD
Done gate:
- Snapshot, issue/receipt and process order tests pass.
- Progress report updated.
```

### CODE04 - Packaging, Printing, QR

```text
Phase: CODE04
Modules: M10 Packaging Printing, M04 SKU Ingredient Recipe, M14 MISA Integration, M16 Admin UI
Goal: Implement packaging level 1/2, trade item/GTIN handoff, QR lifecycle and print/reprint audit.
Primary specs:
- docs/software-specs/modules/10_PACKAGING_PRINTING.md
- docs/software-specs/workflows/04_STATE_MACHINES.md
- docs/software-specs/workflows/05_CANONICAL_OPERATIONAL_FLOW.md
- docs/software-specs/api/
- docs/software-specs/data/
Hard locks:
- Packaging/printing does not create inventory, QC pass or release.
- QR states include GENERATED, QUEUED, PRINTED, FAILED, VOID, REPRINTED.
- VOID/FAILED QR must not resolve as valid public trace.
- GTIN fixture is test/dev only unless real owner data is provided.
Recommended gaps:
- GAP-C04-QR-REGISTRY-LIFECYCLE
- GAP-C04-PACKAGING-L1-L2
- GAP-C04-PRINT-REPRINT-AUDIT
Done gate:
- QR lifecycle/reprint tests pass.
- Progress report updated.
```

### CODE05 - QC Inspection and Batch Release

```text
Phase: CODE05
Modules: M09 QC Release, M10 Packaging Printing, M11 Warehouse Inventory, M16 Admin UI
Goal: Implement QC inspection, disposition and distinct batch release action.
Primary specs:
- docs/software-specs/modules/09_QC_RELEASE.md
- docs/software-specs/business/02_BUSINESS_RULES.md
- docs/software-specs/workflows/04_STATE_MACHINES.md
- docs/software-specs/workflows/05_CANONICAL_OPERATIONAL_FLOW.md
Hard locks:
- QC_PASS is not RELEASED.
- Batch release requires separate release record/action.
- QC_HOLD/QC_REJECT block release.
Recommended gaps:
- GAP-C05-QC-INSPECTION-DISPOSITION
- GAP-C05-BATCH-RELEASE-SEPARATION
Done gate:
- QC_PASS without release cannot enter warehouse.
- Release audit/state transition exists.
- Progress report updated.
```

### CODE06 - Warehouse Receipt and Inventory

```text
Phase: CODE06
Modules: M11 Warehouse Inventory, M09 QC Release, M12 Traceability, M14 MISA Integration, M16 Admin UI
Goal: Implement finished goods warehouse receipt, inventory ledger, lot balance and adjustment/allocation references.
Primary specs:
- docs/software-specs/modules/11_WAREHOUSE_INVENTORY.md
- docs/software-specs/database/
- docs/software-specs/api/
Hard locks:
- Warehouse finished-goods receipt requires batch RELEASED.
- Inventory ledger is append-only.
- Balance projection derives from ledger and must not rewrite history.
Recommended gaps:
- GAP-C06-FG-RECEIPT-RELEASED-GATE
- GAP-C06-INVENTORY-LEDGER-BALANCE
Done gate:
- Released-only receipt and ledger tests pass.
- Progress report updated.
```

### CODE07 - Traceability

```text
Phase: CODE07
Modules: M12 Traceability, M05 Source Origin, M06 Raw Material, M07 Production, M08 Material Issue Receipt, M10 Packaging Printing, M11 Warehouse Inventory, M16 Admin UI
Goal: Implement internal trace, public trace whitelist and genealogy search.
Primary specs:
- docs/software-specs/modules/12_TRACEABILITY.md
- docs/software-specs/api/
- docs/software-specs/data/public_trace_policy.csv
Hard locks:
- Public trace must not expose supplier/internal personnel/costing/QC defect/loss/MISA private data.
- QR VOID/FAILED must not resolve as valid public trace.
- Public-friendly batch code must preserve customer traceability.
Owner blockers:
- OD-11 trace query SLA.
- OD-14 public trace i18n.
Recommended gaps:
- GAP-C07-INTERNAL-GENEALOGY
- GAP-C07-PUBLIC-TRACE-WHITELIST
Done gate:
- Public leakage tests pass.
- If OD-11/OD-14 remain open, document deferred impact.
- Progress report updated.
```

### CODE08 - Recall and Recovery

```text
Phase: CODE08
Modules: M13 Recall, M12 Traceability, M11 Warehouse Inventory, M14 MISA Integration, M16 Admin UI
Goal: Implement recall case, impact snapshot, hold/sale lock, recovery, disposition, CAPA and close gate.
Primary specs:
- docs/software-specs/modules/13_RECALL.md
- docs/software-specs/workflows/04_STATE_MACHINES.md
- docs/software-specs/workflows/07_EXCEPTION_FLOWS.md
Hard locks:
- Recall uses trace/exposure snapshot, not duplicate trace truth.
- Recall SLA business target is 4h from detection to batch lock + notification.
- Notification external systems are referenced by ID, not owned by Operational Domain.
Recommended gaps:
- GAP-C08-RECALL-CASE-IMPACT-SNAPSHOT
- GAP-C08-HOLD-SALELOCK-RECOVERY
Done gate:
- Trace impact -> hold -> recovery -> close smoke passes.
- Progress report updated.
```

### CODE09 - Admin UI/RBAC Registry

```text
Phase: CODE09
Modules: M02 Auth Permission, M16 Admin UI
Goal: Implement screen/action/menu registry and permission-aware admin UI behavior.
Primary specs:
- docs/software-specs/modules/02_AUTH_PERMISSION.md
- docs/software-specs/modules/16_ADMIN_UI.md
- docs/software-specs/ui/
Hard locks:
- UI permission hiding is not security; backend must enforce permission.
- If one user has multiple duties, assign multiple roles; do not merge role logic silently.
Recommended gaps:
- GAP-C09-SCREEN-ACTION-REGISTRY
- GAP-C09-PERMISSION-AWARE-MENU
Done gate:
- Permission-aware UI and backend permission evidence exist.
- Progress report updated.
```

### CODE10 - API Contract Convention

```text
Phase: CODE10
Modules: M01 Foundation Core plus all API-owning modules
Goal: Implement API convention, error envelope, auth/permission middleware, idempotency and pagination/filter/sort contract.
Primary specs:
- docs/software-specs/api/
- docs/software-specs/modules/01_FOUNDATION_CORE.md
Hard locks:
- Do not create parallel route families.
- If backend contract changes, update frontend API client/types/screens/tests or provide no-impact evidence.
Recommended gaps:
- GAP-C10-API-ERROR-CONTRACT
- GAP-C10-IDEMPOTENCY-MIDDLEWARE
- GAP-C10-API-FE-SYNC
Done gate:
- Contract regression tests pass.
- Progress report updated.
```

### CODE11 - PWA/Internal App Contract

```text
Phase: CODE11
Modules: M16 Admin UI, M01 Foundation Core, M02 Auth Permission, M06 Raw Material, M08 Material Issue Receipt, M10 Packaging Printing
Goal: Implement PWA-first internal command contract, offline idempotency and device/session header standard.
Primary specs:
- docs/software-specs/ui/
- docs/software-specs/api/
- docs/software-specs/non-functional/
Hard locks:
- PWA-first is mandatory per owner decision.
- Offline replay must be idempotent.
Recommended gaps:
- GAP-C11-PWA-OFFLINE-COMMAND
- GAP-C11-DEVICE-SESSION-HEADER
Done gate:
- Duplicate offline submit does not duplicate side effects.
- Progress report updated.
```

### CODE12 - Device/Printer Boundary

```text
Phase: CODE12
Modules: M10 Packaging Printing, M14 MISA Integration, M15 Reporting Dashboard
Goal: Implement device/printer boundary, heartbeat, callback logs and incident bridge without direct DB/device bypass.
Primary specs:
- docs/software-specs/modules/10_PACKAGING_PRINTING.md
- docs/software-specs/non-functional/06_OBSERVABILITY_REQUIREMENTS.md
Hard locks:
- Devices/printers must call API/adapter boundary, not database directly.
- Print failure must be auditable.
Owner blocker:
- OD-17 printer model/driver.
Recommended gaps:
- GAP-C12-PRINTER-ADAPTER-BOUNDARY
- GAP-C12-DEVICE-HEARTBEAT
Done gate:
- No direct DB/device bypass.
- If OD-17 open, record blocked production-driver tasks.
- Progress report updated.
```

### CODE13 - Event Schema, Outbox, MISA Adapter

```text
Phase: CODE13
Modules: M01 Foundation Core, M14 MISA Integration
Goal: Implement event schema registry, outbox/event compatibility and MISA adapter with retry/reconcile.
Primary specs:
- docs/software-specs/modules/14_MISA_INTEGRATION.md
- docs/software-specs/workflows/03_SEQUENCE_DIAGRAMS.md
- docs/software-specs/workflows/07_EXCEPTION_FLOWS.md
- docs/software-specs/data/event_schema_registry.csv
Hard locks:
- Business modules emit events; MISA integration layer handles sync.
- No module syncs directly to MISA.
- Retry count and reconcile behavior must be audited.
Recommended gaps:
- GAP-C13-EVENT-SCHEMA-OUTBOX
- GAP-C13-MISA-ADAPTER-RETRY-RECONCILE
Done gate:
- Outbox retry/reconcile tests pass.
- Progress report updated.
```

### CODE14 - Monitoring, Alert, Dashboard

```text
Phase: CODE14
Modules: M15 Reporting Dashboard, M16 Admin UI, M14 MISA Integration
Goal: Implement dashboard health, alert rules and incident response hooks.
Primary specs:
- docs/software-specs/modules/15_REPORTING_DASHBOARD.md
- docs/software-specs/non-functional/06_OBSERVABILITY_REQUIREMENTS.md
Hard locks:
- Technical tooling such as Prometheus/Grafana/OpenTelemetry must remain implementation assumption unless explicitly chosen.
- Critical operational failures must be visible to operator/admin.
Recommended gaps:
- GAP-C14-ALERT-RULE-HEALTH
- GAP-C14-OPERATIONAL-DASHBOARD
Done gate:
- Critical alerts visible.
- Progress report updated.
```

### CODE15 - Override Governance

```text
Phase: CODE15
Modules: M01 Foundation Core, M02 Auth Permission, M09 QC Release, M11 Warehouse Inventory, M13 Recall, M16 Admin UI
Goal: Implement manual override/break-glass governance with reason, permission and audit.
Primary specs:
- docs/software-specs/modules/01_FOUNDATION_CORE.md
- docs/software-specs/non-functional/03_SECURITY_REQUIREMENTS.md
Hard locks:
- Override cannot silently mutate append-only records.
- Override must be permissioned, reasoned and auditable.
Recommended gaps:
- GAP-C15-OVERRIDE-REQUEST-ACTION
- GAP-C15-BREAKGLASS-AUDIT
Done gate:
- Override audit/security tests pass.
- Progress report updated.
```

### CODE16 - Retention, Archive, Restore

```text
Phase: CODE16
Modules: M01 Foundation Core, M11 Warehouse Inventory, M12 Traceability, M13 Recall, M14 MISA Integration, M15 Reporting Dashboard
Goal: Implement retention/archive/restore only after owner decisions for RPO/RTO and retention duration are closed or formally deferred.
Primary specs:
- docs/software-specs/non-functional/05_BACKUP_RETENTION_REQUIREMENTS.md
- docs/software-specs/non-functional/07_SCALABILITY_AVAILABILITY_REQUIREMENTS.md
- docs/software-specs/business/06_COMPLIANCE_AND_DATA_POLICY.md
Owner blockers:
- OD-12 backup/DR RPO/RTO.
- OD-13 audit/ledger/trace/recall retention.
Hard locks:
- Do not destructively archive or delete operational history without owner-approved retention policy.
Recommended gaps:
- GAP-C16-RETENTION-POLICY
- GAP-C16-ARCHIVE-RESTORE-DRILL
Done gate:
- If OD-12/OD-13 open, mark NEEDS_OWNER and do not implement destructive behavior.
- Progress report updated.
```

### CODE17 - Final Close-Out

```text
Phase: CODE17
Modules: All
Goal: Run full release readiness, final smoke and management handoff.
Primary specs:
- docs/software-specs/testing/06_E2E_SMOKE_TEST_PLAN.md
- docs/software-specs/dev-handoff/08_DONE_GATE_CHECKLIST.md
- docs/software-specs/dev-handoff/09_RELEASE_ROLLBACK_GUIDE.md
- docs/software-specs/phase-project/03_PROGRESS_REPORT.md
Hard locks:
- Do not mark release ready if P0 gates are failing without explicit owner-accepted risk.
- Full smoke must cover source -> raw -> production -> packaging -> QC -> release -> warehouse -> trace -> recall -> MISA dry-run where configured.
Recommended gaps:
- GAP-C17-FINAL-SMOKE
- GAP-C17-RELEASE-HANDOFF
Done gate:
- Management progress report complete.
- Release readiness verdict is DONE/PARTIAL/FAILED with evidence.
- Progress report updated.
```
