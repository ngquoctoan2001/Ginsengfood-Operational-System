# AGENTS.md - ginsengfood-operational-system

## Default Codex Mode

Use GPT-5.5 with `model_reasoning_effort = "xhigh"` for this repository.

Do not silently downgrade model or reasoning effort. If GPT-5.5 xhigh is unavailable in the active Codex IDE session, report that clearly before making changes.

## Repository State

This repository is currently a greenfield implementation workspace. It contains the accepted specification documents and agent/tool configuration, but no application codebase has been scaffolded yet.

Treat the current empty structure as intentional. Do not frame work as "migrating", "repairing", or "syncing stale implementation" unless an actual implementation is later added. The first engineering objective is to scaffold the project from the accepted source specifications, then implement bounded operational capabilities.

Current expected top-level roles:

- `docs/software-specs/`: accepted source of truth.
- `.agents/`, `.codex/`, `.claude/`, `.github/`, `.vscode/`: agent, IDE, and workflow rules.
- `tools/agent/`: process lifecycle helpers.
- `.tmp-docx-extract/`: historical extraction only; never authoritative.

## Agent Response Language

All AI agents working in this repository must respond in Vietnamese for planning, progress updates, reviews, validation reports, handoff notes, risks, blockers, and final responses.

Keep technical terms in English when they are standard engineering terms or exact identifiers, including:

- code identifiers, class names, function names, variable names;
- file paths, folder paths, route paths, API methods, DTO names, table names, column names, enum values;
- command lines, package names, migration names, branch names, commit messages;
- JSON/YAML/TOML keys, HTTP status codes, log/error text, tool names, framework/library names.

Do not translate code fences, commands, route names, schema names, or exact error messages. Explain them in Vietnamese around the original term when needed.

Final response section headings must also be Vietnamese. Do not use English headings such as `Progress Report Update`, `Commands Run`, `Validation`, `Summary`, `Files Changed`, or `Process Cleanup Result` as standalone final-response sections. Use the Vietnamese output contract in `Output Format` below.

## Agent-Owned Process Lifecycle

Do not leave agent-started local processes running after a response or chat session.

- Prefer finite foreground commands for validation: `dotnet build`, `dotnet test`, `dotnet ef ...`, `npx tsc`, `npm run build`, and similar commands must be allowed to finish before final response.
- Do not start long-lived commands such as `dotnet run`, `dotnet watch`, `npm run dev`, Vite/Next dev servers, Playwright web servers, Docker compose, `Start-Process`, `Start-Job`, or background shell jobs unless the task genuinely requires a live server.
- If a long-lived process is required, start it with `tools/agent/Start-AgentOwnedProcess.ps1` or record the exact PID immediately.
- Before final response or handoff, stop every process the agent started with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`.
- After any agent-run .NET build/test/EF sequence, run `dotnet build-server shutdown` before final response to release Roslyn/MSBuild build servers.
- Never stop processes by broad name matching such as killing every `dotnet`, `node`, `npm`, `testhost`, or `VBCSCompiler` process.
- Never stop user-owned terminal processes. If ownership is unclear, report suspicious processes instead of killing them.
- Every final implementation response must include a `Kết quả cleanup process` entry.

## Current Priority: Greenfield Ginsengfood Operational Build

The active workstream is to start the project from the accepted software specification documents.

Because the application code is not present yet:

- Do not require current-code route mapping before initial route families are scaffolded. Instead, map the route against `docs/software-specs/api/` and record the intended frontend/admin consumers.
- Do not require migration-delta analysis against historical migrations. Create the first schema/migration set from canonical database specs.
- Do not require seed-delta analysis against historical seed SQL. Create the first seed chain from canonical seed/master-data specs.
- Do not require GitNexus code-graph exploration before broad work while the codebase is empty. Use GitNexus later after code exists and indexing is useful.
- Do not create artificial gap reports just because code is missing. For greenfield work, produce a scaffold/implementation plan, requirement traceability, and handoff artifacts instead.

## Canonical Source

The single accepted source of truth is:

- `docs/software-specs/`
  - All architecture, business rules, module specs, API, database, UI, workflows, testing, forms, operational rules, master data, recipe/SKU/ingredient, seed spec, dev handoff, and agent workflow prompts.

Use these agent workflow files for phase prompts and output contracts:

- `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`
- `docs/software-specs/ai-agent/02_CODEX_PROMPT_PACK.md`
- `docs/software-specs/ai-agent/03_GAP_IMPLEMENTATION_PROMPTS.md`
- `docs/software-specs/ai-agent/04_REVIEW_PROMPTS.md`
- `docs/software-specs/ai-agent/05_VALIDATION_PROMPTS.md`
- `docs/software-specs/ai-agent/06_HANDOFF_PROMPTS.md`

Use these for tracking and coordination when phases create them:

- `docs/v2-plan/`
- `docs/v2-handoff/`
- `docs/v2-smoke/`
- `docs/v2-audit/` only for conflicts, deferred gaps, or later drift against an existing implementation.

When working on Operational modules:

1. Read this `AGENTS.md`.
2. Read `docs/software-specs/01_SOURCE_INDEX.md`.
3. Read relevant files from `docs/software-specs/`; for broad initial scaffold work, read every `.md` relevant to architecture, business, functional, database, API, UI, workflows, modules, dev handoff, and testing.
4. Read `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md` for the accepted phase workflow and output contracts.
5. For greenfield tasks, map spec requirements to intended project structure, modules, migrations, entities, DTOs, API routes, admin UI, workers, seeds, and tests before creating files.
6. After application code exists, use GitNexus before broad repository exploration when code graph context can reduce guesswork.
7. Record unresolved decisions explicitly instead of guessing.

## Documentation Precedence

Use this precedence unless the owner gives a newer instruction:

1. `docs/software-specs/01_SOURCE_INDEX.md` - source policy, what is and is not allowed.
2. `docs/software-specs/02_EXECUTIVE_SUMMARY.md` - system overview and owner priorities.
3. `docs/software-specs/architecture/` - system architecture, component design, integration architecture.
4. `docs/software-specs/business/` - business requirements, business rules, operational rules, role/permission, approval/audit.
5. `docs/software-specs/functional/` - module/function matrix, use cases, user stories, acceptance criteria.
6. `docs/software-specs/database/` - database overview, schema, seed specification, migration strategy.
7. `docs/software-specs/api/` - API conventions, endpoint catalog, DTOs, error codes, auth/permission, idempotency.
8. `docs/software-specs/ui/` - screen catalog, form specs, UI component specs.
9. `docs/software-specs/workflows/` - operational workflows, state machines, lifecycle diagrams.
10. `docs/software-specs/modules/` - per-module specs with requirements, business rules, test cases.
11. `docs/software-specs/dev-handoff/` - delivery gates, phase plan, code rules.
12. `docs/software-specs/testing/` - test plans, test cases, smoke gates.
13. Current repository implementation, once created, as implementation evidence only.
14. `.tmp-docx-extract/`, `specs/`, old PDFs/DOCX/text extracts, historical migrations, and old seed SQL only as historical reference.

If two canonical documents conflict, do not merge them creatively. Use the priority above, record the conflict in the current phase artifact under `docs/v2-plan/` or `docs/v2-audit/`, and implement only the accepted canonical requirement.

## Ginsengfood V2 Hard Locks

- G1 is the initial operational baseline recipe version for factory go-live. Use G1 to build the first correct schema, seed chain, production-order snapshot, material issue, traceability, recall, and validation flows.
- The system must be versioned so later accepted formula versions such as G2, G3, and beyond can be created, approved, activated, snapshotted, audited, and retired without rewriting history.
- G0 is research/baseline context only. Do not seed G0 as an active operational formula, and do not use G0 in production order, material issue, costing, trace, recall, or dev handoff.
- Operational recipe display and material issue must use exactly four G1 groups:
  - `SPECIAL_SKU_COMPONENT`
  - `NUTRITION_BASE`
  - `BROTH_EXTRACT`
  - `SEASONING_FLAVOR`
- SKU master has exactly 20 canonical SKU unless a newer accepted owner document changes this.
- Ingredient master must include canonical `ING_MI_CHINH` and `HRB_SAM_SAVIGIN`; do not add old-only ingredients merely to match stale descriptions.
- Production order snapshot must capture SKU, formula code, `formula_version = G1`, recipe line group, ingredient code/display name, quantity per batch 400, UOM, prep note, and usage role.
- Material Issue Execution is the real raw-material inventory decrement point.
- Material Receipt Confirmation is separate and records workshop receipt/variance.
- QC_PASS is not RELEASED. Batch release must be a distinct record/action.
- Warehouse finished-goods receipt must require batch RELEASED and must create inventory ledger/balance projection.
- Trade item/GTIN/GS1 identity is separate from SKU identity.
- QR registry must have lifecycle states including GENERATED, QUEUED, PRINTED, FAILED, VOID, and REPRINTED.
- Public trace must follow field policy and must not expose internal supplier/personnel/costing/QC-defect/loss data.
- MISA sync must go through a common integration layer with mapping, retry, and reconcile; modules must not sync directly.
- API routes must be derived from canonical API specs during initial scaffold. After routes exist, changes must include route/consumer impact analysis.

## AI Agent Operating Model

Use AI agents as a disciplined IT delivery team, not as free-form code generators. Every agent must stay inside the source packs, cite evidence, and produce artifacts that the next role can consume.

- BA / Product Analyst: extracts requirements from `docs/software-specs/`, writes requirement IDs, source file, heading, priority, acceptance criteria, conflicts, and unresolved decisions.
- PM / Delivery Lead: splits greenfield delivery into bounded phases with goal, scope, dependency, risk, validation gate, and handoff artifact.
- Tech Lead / Architect: maps requirement impact across target solution structure, database, backend, API/DTO/OpenAPI, frontend/admin UI, workers/events, seeds, tests, and operations.
- DBA / Data Engineer: designs first migrations, constraints, indexes, seed idempotency, reset flow, and acceptance queries from canonical specs.
- Backend Developer: implements domain/service/API behavior with simple, consistent patterns selected during scaffold; preserves audit/event append-only behavior and updates DTO/API contracts with tests.
- Frontend/Admin Developer: creates API clients, types, routes, form states, role-gated actions, loading/error states, and user workflows aligned to contracts.
- QA / Tester: writes unit, integration, API, seed, migration, and smoke/e2e coverage from acceptance criteria.
- DevOps / Release Engineer: verifies build, test, DB migration/update, clean reset, seed order, idempotency, environment variables, and runbook steps.
- Security / Compliance Reviewer: checks permissions, public/private data boundaries, traceability exposure, audit logs, and destructive operations.
- Code Reviewer: reviews correctness, regression risk, contract drift, missing tests, and `docs/software-specs/` traceability before marking a phase done.

## Operational Domain Hard Locks

Operational Domain is the source of truth for:

- batch;
- lot;
- genealogy;
- traceability;
- recall data;
- operational inventory ledger;
- inventory lot balance.

Operational Domain only stores reference keys for external domains, including:

- `sku_id`;
- `order_id`;
- `order_item_id`;
- `customer_id`;
- `shipment_id`;
- `notification_job_id`.

Operational Domain must not copy or become owner of external master data such as customer, order, membership, commission, CRM profile, pricing, campaign, ads attribution, or AI decision data.

CRM, Membership, Diamond / Commission, Analytics, and AI Operating Brain are not direct ownership scope for Operational Domain unless `docs/software-specs/` explicitly says otherwise.

## Greenfield Phased Execution

For Ginsengfood V2 implementation work, split delivery into explicit, reviewable phases:

1. Source intake and requirement traceability.
2. Architecture and repository scaffold.
3. Database baseline and seed framework.
4. Backend domain/API baseline.
5. Admin UI/API client baseline.
6. Operational workflow slices.
7. Integration, traceability, recall, public trace, and MISA layers.
8. Smoke/e2e, deployment, and handoff hardening.

Each phase must have an explicit goal, accepted requirement source, affected layers, files expected to be created or changed, validation target, and handoff update.

Related requirements may be grouped in the same phase only when required to complete the same workflow or scaffold boundary. Record deferred or newly discovered decisions in `docs/v2-plan/` or `docs/v2-handoff/`.

## Implementation Workflow

For Ginsengfood V2 work, Codex must follow this sequence:

1. Intake: identify the exact canonical source document, section, and requirement.
2. Greenfield map: compare the requirement against the current scaffold state. If no code exists, mark the layer as `NOT_SCAFFOLDED`, not as a stale implementation gap.
3. Plan: propose or update a bounded implementation phase.
4. Implement: modify only files needed for the current phase and task.
5. Validate: run the required backend tests/build, frontend tests/build, seed validation, and migration/database validation when the corresponding project or layer exists. If a command cannot run because the layer has not been scaffolded, report it as `N/A - not scaffolded yet`.
6. Review: check correctness, security, contract drift, traceability, inventory, QC, release, recall, public/private exposure, permissions, and audit behavior.
7. Handoff: update the current phase handoff under `docs/v2-handoff/` or the active task document referenced by the user.

## Completion Gates

Before marking any implementation task complete:

- If the user attached, referenced, or opened a task-related `.md` file, update that Markdown file with the completed work, status, evidence, or remaining gaps before the final response.
- If backend code exists and was affected, run backend tests and backend build successfully with zero errors.
- If frontend code exists and was affected, run frontend tests/typecheck/build successfully with zero errors.
- If a migration is added or changed, update the target database with that migration before the final response and report the exact migration/update command used.
- If seed data is added or changed, run the full sorted seed chain and a seed validation query/script; run it twice if the seed is intended to be idempotent.
- If a completion gate cannot run because the layer has not been scaffolded, report `N/A - not scaffolded yet`.
- If a completion gate cannot run because of environment, dependency, database, or permission constraints, report the blocker, the command attempted, and the remaining risk.

## Coding Rules

- Do not perform broad refactors while implementing a bounded phase.
- Do not change public API contracts without mapping frontend/admin/API/OpenAPI impact after those surfaces exist.
- If adding, modifying, or deleting backend behavior, API routes, DTOs/contracts, validation, enums, error shapes, permissions, or workflow state, create or update the corresponding frontend/admin API types, clients, UI flows, states, and tests in the same phase when that frontend layer exists or is part of the phase.
- Do not add production dependencies unless explicitly justified.
- Do not create duplicate business truth.
- Do not create direct database access for external industrial/device integrations unless approved by the accepted technical docs.
- Do not bypass QC gates, release gates, inventory ledger, traceability, recall, role permissions, or audit logs.
- Do not expose internal traceability fields in public trace APIs.
- Do not mutate append-only audit/event/history records except through approved migration or archival workflow.
- If the requirement affects database schema, check target migrations, entities/models, DTOs, API handlers, services, seeds, and tests together.

## Evidence Requirements

Before making code changes, cite concrete evidence from:

- canonical source-pack document sections;
- current scaffold files and folders;
- intended project/module paths;
- planned symbols/classes/functions/routes/DTOs/OpenAPI contracts;
- database migration and seed plans;
- tests to create or update.

After code exists, also cite concrete code paths, symbols, routes, migrations, seed files, and tests.

## Output Format

Every Codex response after implementation must include:

- Tóm tắt
- File đã sửa
- Nguồn yêu cầu
- Evidence đã dùng
- Lệnh đã chạy
- Kết quả test
- Kết quả backend build
- Kết quả frontend build
- Kết quả cleanup process
- Cập nhật Markdown
- Kết quả database migration/update, nếu áp dụng
- Kết quả seed validation, nếu áp dụng
- Rủi ro còn lại
- Cập nhật handoff
