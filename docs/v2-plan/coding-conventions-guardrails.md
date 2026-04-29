# Operational V2 Coding Conventions And Guardrails

> Status: Ready for AI-agent-assisted implementation.
> Mode: PLAN_ONLY / governance artifact. This document does not implement code.

## 1. Source Basis

| Source | Used for |
| --- | --- |
| `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md` | Agent workflow, required evidence, stop conditions, final handoff contract |
| `docs/software-specs/dev-handoff/01_DEVELOPMENT_GUIDE.md` | Source discipline, bounded gap template, anti-scope rules |
| `docs/software-specs/dev-handoff/02_BACKEND_IMPLEMENTATION_GUIDE.md` | Backend layers, transaction boundaries, invariants, done gate |
| `docs/software-specs/dev-handoff/03_FRONTEND_IMPLEMENTATION_GUIDE.md` | Frontend API client, UI state, public trace and PWA rules |
| `docs/software-specs/dev-handoff/04_DATABASE_IMPLEMENTATION_GUIDE.md` | Table classes, constraints, append-only guard and validation queries |
| `docs/software-specs/dev-handoff/05_SEED_IMPLEMENTATION_GUIDE.md` | Seed order, idempotency and seed validation |
| `docs/software-specs/dev-handoff/06_API_CONTRACT_HANDOFF.md` | API/backend/frontend/QA contract sync |
| `docs/software-specs/dev-handoff/07_MODULE_TASK_BREAKDOWN.md` | CODE01-CODE17 task IDs and phase/module mapping |
| `docs/software-specs/dev-handoff/08_DONE_GATE_CHECKLIST.md` | Universal and layer done gates |
| `docs/software-specs/api/01_API_CONVENTION.md` | Route, naming, envelope, status, header and command rules |
| `docs/software-specs/database/08_MIGRATION_STRATEGY.md` | Migration principles, order, validation and rollback/restore policy |

## 2. Coding Convention Checklist

Every implementation task must satisfy this checklist before editing and before handoff.

| Area | Convention | Evidence required |
| --- | --- | --- |
| Requirement anchor | Start from `REQ-*`, `BR-*`, module `M01..M16`, phase `CODE01..CODE17`, test case `TC-*`. | Gap/task header includes all anchors or states `OWNER DECISION NEEDED`. |
| Bounded scope | Change only the current gap write scope; no broad rename/format/refactor. | Files changed map to the gap layers. |
| Naming | Use descriptive names; no one-letter variables except local counters. | Review diff. |
| Simplicity | Prefer small services/functions, early returns, named constants and explicit validation. | Review diff and tests. |
| Immutability | Do not mutate audit/event/ledger/history/snapshot records in business flows. | Tests assert append-only behavior where applicable. |
| Error handling | Return stable API error codes from the spec; do not leak raw downstream/internal errors. | API negative tests and error mapper evidence. |
| Backend/frontend sync | Any API/DTO/state/permission change updates frontend client/types/screens/tests in the same phase when FE exists. | Handoff lists frontend impact or `N/A - not scaffolded yet`. |
| Public/private boundary | Public trace uses only `/api/public/trace/*` and whitelist DTO/projection. | Public denylist test evidence when touched. |
| Integration boundary | MISA/device work uses integration/outbox/adapter layer; modules do not sync directly. | Integration tests or adapter evidence. |
| Validation | Run finite build/test/migration/seed/smoke gates that apply to touched layers. | Exact commands and results in handoff. |

## 3. Naming Conventions By Layer

| Layer | Convention |
| --- | --- |
| API routes | Prefixes: `/api/admin/*`, `/api/mobile/*`, `/api/public/*`, `/health`. Resource names are plural lowercase kebab-case. Actions use `POST /{resource}/{id}/{action}`. |
| API path params | Use camelCase placeholders in docs, e.g. `{lotId}`, `{batchId}`, `{qrCode}`. |
| Query params | camelCase, explicit filters/sort/page fields. No ambiguous short keys such as `q` unless cataloged. |
| JSON keys / DTO properties | camelCase. |
| Enum values / status codes | UPPER_SNAKE_CASE, matching API/database enum references. |
| Backend classes | PascalCase for controllers, services, domain services, validators, repositories and options. Suffix by role: `Controller`, `Service`, `DomainService`, `Repository`, `Validator`, `Options`. |
| Backend methods | Verb-first camel/Pascal casing per language convention: `CreateProductionOrder`, `MarkRawLotReady`, `ExecuteMaterialIssue`, `ConfirmWarehouseReceipt`. |
| Database tables | Lower snake_case. Reference/master tables use `ref_*`; operational tables use `op_*`; auth uses `auth_*`; MISA uses `misa_*`; UI registry uses `ui_*`; views use `vw_*`. |
| Database columns | Lower snake_case. Use `*_id` for FK, `*_code` for business keys, `created_at`, `updated_at`, `created_by`, `updated_by`, `reason`, `correlation_id` where applicable. |
| Indexes | `ix_{table}_{column_or_purpose}` for non-unique index; `ux_{table}_{business_key}` for unique index. |
| Constraints | `pk_{table}`, `fk_{table}_{ref_table}_{column}`, `ck_{table}_{rule}`, `uq_{table}_{business_key}`. |
| Frontend components | PascalCase, module/screen scoped when business-specific, e.g. `RawLotReadinessPanel`. |
| Frontend hooks | `use{Thing}` for query/mutation/state hooks, e.g. `useRawLotReadiness`. |
| Frontend API client | One typed client per canonical route family/module; no duplicate client for adapter routes. |
| Tests | File/test names include behavior and module/TC reference where practical, e.g. `M08_material_issue_rejects_non_ready_lot_TC-M08-...`. |

## 4. DTO / API Envelope / Error / Pagination Conventions

| Topic | Required convention |
| --- | --- |
| Success single | `{ "data": { ... }, "meta": { "correlationId": "..." } }` |
| Success collection | `{ "data": [], "meta": { "page": 1, "pageSize": 50, "total": 0, "sort": "createdAt:desc", "correlationId": "..." } }` |
| Error | `{ "error": { "code": "VALIDATION_FAILED", "message": "...", "details": [], "correlationId": "..." } }` |
| HTTP status | Use `200`, `201`, `202`, `204`, `400`, `401`, `403`, `404`, `409`, `422`, `429`, `500`, `503` only according to `api/01_API_CONVENTION.md`. |
| Auth header | `/api/admin/*` and `/api/mobile/*` require `Authorization: Bearer <token>`. |
| Idempotency header | High-risk create/execute/confirm/release/print/retry/offline commands require `X-Idempotency-Key`. |
| Correlation header | Accept/generate `X-Correlation-Id`; always return `correlationId` in envelope. |
| Device header | PWA/device submit uses `X-Device-Id` when required by route policy. |
| Pagination | Lists use explicit `page`, `pageSize`, `sort` and cataloged filters; no unbounded operational scans. |
| Public trace | Public DTO must be separate from admin/internal DTO. Forbidden fields never appear in response, logs or debug payload. |
| Contract sync | Route is considered migrated only when endpoint catalog, permission spec, request/response spec, OpenAPI and UI/client use the same path. |

## 5. Database Table / Column / Index / Constraint Conventions

| Area | Rule |
| --- | --- |
| Migration order | Follow dependency order: foundation/auth/audit -> event/outbox -> master -> SKU/recipe -> source/raw -> production/material -> packaging/QR -> QC/release/warehouse/inventory -> trace/recall -> MISA -> dashboard/UI/forms -> views/projections -> seed -> validation. |
| Migration content | Each migration has forward change, validation check and rollback/restore note. |
| PK | UUID primary key unless a spec explicitly requires otherwise. |
| Business key | Use unique business code/key constraints for seed/master lookup and idempotent upsert. |
| Enum | Store as text with check constraints; enum values are UPPER_SNAKE_CASE. |
| FK | Use explicit FK constraints when dependency order allows. |
| Append-only | Guard `audit_log`, `state_transition_log`, `event_store`, `op_inventory_ledger`, `op_qr_state_history`, `op_recall_exposure_snapshot` against normal update/delete. |
| Snapshot | Snapshot tables are immutable after creation; changes create a new version/snapshot, not overwrite. |
| Ledger | `op_inventory_ledger` is source of truth; balance tables are projections/rebuildable. |
| Public projection | `vw_public_traceability` or equivalent projection excludes private fields by design. |
| Seed | Seed is idempotent by business key, not generated id. Dev fixtures are marked as dev/test fixtures. |
| Rollback | After production data write, prefer forward-fix migration; do not destructive rollback operational history. |

## 6. Frontend Client / Type / Form State Conventions

| Area | Rule |
| --- | --- |
| API client | Generate or maintain typed clients from the canonical API/OpenAPI contract. Do not call legacy/adapter route families as primary client routes. |
| Types | DTO types mirror API camelCase JSON shape. Public DTO types must not extend admin/internal DTOs. |
| Query/mutation hooks | One hook per use case/route action. Mutations requiring side effects must send idempotency key. |
| Form state | Forms implement loading, empty, validation, error, stale and permission-disabled states. |
| Error mapping | Map stable backend `error.code` to UI behavior. Do not parse message text for business logic. |
| Permissions | UI hides/disables actions by permission but backend remains the gate; tests cover both. |
| Raw lot readiness | UI shows `qcStatus` and `lotStatus` separately. Material issue picker filters only `lotStatus=READY_FOR_PRODUCTION`. |
| Public trace | Public page calls only `/api/public/trace/{qrCode}` and renders whitelist fields only. |
| Offline/PWA | Offline submit carries idempotency key and device/session metadata; replay cannot double execute. |

## 7. Test Naming And REQ/TC Mapping

| Test group | Convention |
| --- | --- |
| Unit | Name behavior first, include module or invariant: `MarkReady_rejects_lot_without_qc_pass`. |
| API | Include method/route/action and expected code: `POST_raw_lot_readiness_requires_idempotency_TC-M01-API-002`. |
| Integration | Cover transaction side effects: audit/state/event/ledger/projection rows. |
| UI | Include screen/action/state and permission behavior. |
| E2E smoke | Follow Source Origin -> Raw Material -> QC/Ready -> G1 PO -> Issue -> Receipt -> Batch -> Packaging/QR -> QC -> Release -> Warehouse -> Trace -> Recall -> MISA. |
| Seed validation | Use `SV-*` and `TC-SEED-*`; assert 20 SKU, required ingredients, 4 G1 groups, active G1, public denylist and idempotency. |
| Regression | Pin hard locks and previously fixed bugs; include REQ/TC in test name or metadata. |
| Handoff | Every test change lists `REQ-*`, `TC-*`, phase and module in final report. |

## 8. Forbidden Pattern List

| ID | Forbidden pattern |
| --- | --- |
| FP-001 | Using `.tmp-docx-extract/`, legacy extracts, current code or database as requirement source of truth. |
| FP-002 | Creating parallel route families, tables, enums or business truth without impact analysis and approval. |
| FP-003 | Changing API route/DTO/envelope/error/permission without frontend client/type/test sync or no-impact evidence. |
| FP-004 | Putting complex business rules in API controllers/handlers or UI state. |
| FP-005 | Letting UI permission hiding replace backend authorization. |
| FP-006 | Direct MISA sync from business modules instead of outbox/integration layer. |
| FP-007 | Mutating append-only audit/event/ledger/history/snapshot rows in normal business flow. |
| FP-008 | Treating `QC_PASS` as `RELEASED`. |
| FP-009 | Allowing material issue for a lot that is only `QC_PASS` but not `READY_FOR_PRODUCTION`. |
| FP-010 | Letting packaging/printing create inventory, QC pass or batch release. |
| FP-011 | Public trace reusing admin/internal DTOs or exposing supplier, personnel, cost, QC defect/loss, MISA/private fields. |
| FP-012 | Seeding active G0 or using G0 in operational PO/material issue/trace/recall. |
| FP-013 | Treating 20 SKU as a permanent application cap instead of G1 baseline seed. |
| FP-014 | Committing real secrets or seed credentials. |
| FP-015 | Destructive production reset, hard delete of operational history, or rollback that removes posted ledger/audit data. |
| FP-016 | Starting long-running dev servers or background jobs without tracking and cleanup. |
| FP-017 | Broad formatting, rename or refactor in the same patch as a bounded feature gap. |
| FP-018 | Tests named `works`, `test`, or vague names without behavior/REQ/TC context. |

## 9. Agent Pre-Edit Checklist

Before any AI agent edits code or scaffold files:

| Step | Required answer |
| --- | --- |
| 1 | What is the active mode: `PLAN_ONLY`, `IMPLEMENT_ONE_PHASE`, `REVIEW_DIFF` or `VALIDATE_AND_SMOKE`? |
| 2 | What `REQ-*`, `BR-*`, module, phase, task ID and `TC-*` anchor this work? |
| 3 | Which source sections from `docs/software-specs/` justify the change? |
| 4 | What is the bounded write scope? |
| 5 | Which layers are touched: DB, backend, API, frontend, seed, tests, docs, worker/integration? |
| 6 | What are the explicit non-goals? |
| 7 | Are there owner decisions, ADRs or route conflicts blocking the edit? |
| 8 | Does this change affect API/DTO/state/permission? If yes, what is the frontend sync plan? |
| 9 | Does this change affect schema or seed? If yes, what migration/seed validation command will run? |
| 10 | Does this touch public trace, MISA, inventory ledger, recall, QR/print or audit/history? If yes, what hard lock tests are required? |
| 11 | What finite validation commands will run, and what is `N/A - not scaffolded yet`? |
| 12 | What Markdown handoff/progress artifact must be updated before final response? |

## 10. Handoff Checklist

Every implementation handoff must include:

| Section | Minimum content |
| --- | --- |
| Summary | Behavior changed and bounded gap closed or blocked. |
| Requirement source | Source file, heading, `REQ-*`, `BR-*`, module, phase, `TC-*`. |
| Files changed | Paths grouped by DB/backend/API/frontend/seed/test/docs. |
| API impact | Endpoint/DTO/error/idempotency/permission changes or no-impact evidence. |
| Frontend impact | Client/type/screen/test changes or `N/A - not scaffolded yet`. |
| DB impact | Migration/table/index/constraint/seed impact or no-impact evidence. |
| Validation | Exact commands, result and blockers. |
| Hard lock review | Public trace, MISA, inventory, QC/release, audit/append-only checks if relevant. |
| Process cleanup | Agent-started processes stopped, or none started. |
| Remaining risks | Owner decisions, ADR approvals, validation blockers or deferred gaps. |

