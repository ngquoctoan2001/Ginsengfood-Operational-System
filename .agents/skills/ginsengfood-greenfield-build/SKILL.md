---
name: ginsengfood-greenfield-build
description: Use this skill when building ginsengfood-operational-system from scratch using docs/software-specs/, planning greenfield scaffold phases, implementing bounded Ginsengfood V2 Operational requirements, or later auditing implementation drift.
---

# Skill: Ginsengfood V2 Operational Greenfield Build

## 0. Response Language

Write plans, progress notes, handoff, validation reports, risks, owner decisions, and final responses in Vietnamese unless the user asks otherwise.

Keep these values in English:

- code identifiers
- file paths
- folder paths
- table names
- column names
- enum values
- route paths
- API methods
- class names
- function names
- command lines
- package names
- migration names
- branch names
- commit messages
- JSON/YAML/TOML keys
- status codes
- original log/error text

## 1. Purpose

Use this skill to build the Ginsengfood Operational system from the accepted Markdown specs.

The repository is currently greenfield: application code has not been scaffolded yet. Missing code is not automatically a "gap"; it is `NOT_SCAFFOLDED`.

The default workflow is:

```text
read source truth
-> map requirement to target architecture
-> plan one bounded scaffold or feature phase
-> implement
-> validate available gates
-> review
-> handoff
```

After application code exists, this skill also supports drift audits and bounded fixes against `docs/software-specs/`.

## 2. Operating Modes

Each turn must identify the active mode.

### 2.1 READ_ONLY_SOURCE_MAP

Use when:

- extracting requirements;
- finding conflicts;
- mapping intended architecture;
- preparing scaffold or phase boundaries;
- no code changes are requested.

Rules:

- Do not edit files.
- Do not create migrations.
- Do not run destructive commands.
- Output must cite source file, heading, and requirement evidence.
- Mark absent layers as `NOT_SCAFFOLDED`.

### 2.2 PLAN_ONLY

Use when:

- splitting phases;
- creating task queues;
- identifying dependencies;
- preparing owner decisions;
- making validation plans.

Rules:

- Do not edit code.
- Markdown plan/handoff files may be created or updated only when requested or when the phase contract requires it.
- Keep each phase bounded.
- Do not propose "do everything in one pass".

### 2.3 IMPLEMENT_ONE_PHASE

Use when:

- the user asked to implement;
- the phase or requirement slice is clear enough;
- source evidence and validation target are known.

Rules:

- Implement only the current bounded scaffold or feature phase.
- Do not broaden into unrelated modules.
- Do not refactor outside the phase.
- Do not alter source truth to justify code.
- When code does not exist, scaffold the minimum structure needed by the phase.

### 2.4 REVIEW_DIFF

Use after a diff exists.

Rules:

- Do not edit files.
- Compare the diff with canonical requirement sources.
- For scaffold work, verify structure, naming, contracts, and validation scripts are justified by docs.
- Return `ACCEPT`, `NEEDS_FIX`, or `REJECT`.

### 2.5 VALIDATE_AND_SMOKE

Use when:

- running build/test/migration/seed/smoke;
- confirming done gates.

Rules:

- Prefer finite commands.
- Do not run long-lived dev servers unless required.
- Report command, result, blocker, and residual risk.
- If a layer is absent, report `N/A - not scaffolded yet`.

## 3. Canonical Source

The single accepted source of truth is:

- `docs/software-specs/`

Use these workflow files for phase prompts and output contracts:

- `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`
- `docs/software-specs/ai-agent/02_CODEX_PROMPT_PACK.md`
- `docs/software-specs/ai-agent/03_GAP_IMPLEMENTATION_PROMPTS.md`
- `docs/software-specs/ai-agent/04_REVIEW_PROMPTS.md`
- `docs/software-specs/ai-agent/05_VALIDATION_PROMPTS.md`
- `docs/software-specs/ai-agent/06_HANDOFF_PROMPTS.md`

Use generated coordination folders only when they exist or a phase creates them:

- `docs/v2-plan/`
- `docs/v2-handoff/`
- `docs/v2-smoke/`
- `docs/v2-audit/`

Do not use `.tmp-docx-extract/`, `specs/`, old DOCX/PDF extracts, historical migrations, or old seed SQL as authoritative sources.

## 4. Required Reading Order

1. Root `AGENTS.md`.
2. `CLAUDE.md` if relevant to the active agent surface.
3. `docs/software-specs/01_SOURCE_INDEX.md`.
4. Relevant files in `docs/software-specs/`.
5. Active artifacts in `docs/v2-plan/`, `docs/v2-handoff/`, `docs/v2-smoke/`, or `docs/v2-audit/` if they exist.
6. Current repository implementation only after it exists.

For broad initial scaffold, schema, seed, workflow, forms, traceability, recall, MISA, QR, or production work, read all relevant Markdown files in `docs/software-specs/` before concluding.

## 5. Documentation Precedence

Unless the owner gives a newer instruction:

1. `docs/software-specs/01_SOURCE_INDEX.md`
2. `docs/software-specs/02_EXECUTIVE_SUMMARY.md`
3. `docs/software-specs/architecture/`
4. `docs/software-specs/business/`
5. `docs/software-specs/functional/`
6. `docs/software-specs/database/`
7. `docs/software-specs/api/`
8. `docs/software-specs/ui/`
9. `docs/software-specs/workflows/`
10. `docs/software-specs/modules/`
11. `docs/software-specs/dev-handoff/`
12. `docs/software-specs/testing/`
13. Current repository implementation, once scaffolded, as evidence only.
14. `.tmp-docx-extract/`, `specs/`, and older extracted documents as historical reference only.

If documents conflict:

- Do not merge creatively.
- Use the precedence above.
- Record conflict in `docs/v2-plan/` or `docs/v2-audit/`.
- Implement only the accepted canonical requirement.

## 6. Hard Locks

- G1 is the initial operational baseline recipe/formula version for factory go-live.
- Use G1 to build the first correct schema, seed, production-order snapshot, material issue, traceability, recall, and validation flows.
- Formula tables and flows must support future accepted versions such as G2, G3, and later versions.
- Future versions must be approved, activated, snapshotted, audited, and retired without rewriting historical production records.
- G0 is research/baseline context only; never seed active G0 or use it in operational production/material issue/costing/trace/recall.
- Recipe display and material issue must use exactly four G1 groups:
  - `SPECIAL_SKU_COMPONENT`
  - `NUTRITION_BASE`
  - `BROTH_EXTRACT`
  - `SEASONING_FLAVOR`
- SKU master has exactly 20 canonical SKUs unless a newer accepted owner document changes this.
- Ingredient master must include `ING_MI_CHINH` and `HRB_SAM_SAVIGIN`.
- Production order snapshot must capture SKU, formula code, `formula_version = G1`, recipe line group, ingredient code/display name, quantity per batch 400, UOM, prep note, and usage role.
- Material Issue Execution is the real raw-material inventory decrement point.
- Material Receipt Confirmation is separate and records workshop receipt/variance.
- QC_PASS is not RELEASED; batch release must be a distinct record/action.
- Warehouse finished-goods receipt must require batch RELEASED and create inventory ledger/balance projection.
- Packaging/printing must not create inventory, QC pass, or batch release.
- Trade item/GTIN/GS1 identity is separate from SKU identity.
- QR registry must include GENERATED, QUEUED, PRINTED, FAILED, VOID, and REPRINTED.
- QR VOID/FAILED must not public trace as valid QR.
- Public trace must follow field policy and must not expose supplier/internal personnel/costing/QC-defect/loss/MISA data.
- MISA sync must go through one common integration layer with mapping, retry, reconcile, and audit.
- Initial API routes come from canonical API specs. After route code exists, changes require route/consumer impact analysis.

## 7. Bounded Phase Rule

Every implementation must follow one bounded phase.

A valid phase has:

- `phase_id`
- requirement source
- current scaffold state
- affected layers
- files likely to create or change
- explicit non-goals
- validation gate
- owner decision needed, if any

Do not:

- implement unrelated phases in one pass;
- refactor broadly during a small phase;
- use old extracts to override source truth;
- require nonexistent code evidence in a greenfield phase.

If the user gives a broad task:

1. Create a Vietnamese plan.
2. Split into bounded phases.
3. Choose the smallest safe phase when implementation is allowed.

## 8. Greenfield Mapping Workflow

Use this for source-to-scaffold discovery:

1. Identify source file and heading.
2. Extract requirement and acceptance criteria.
3. Map requirement to target layers:
   - repository/solution scaffold
   - database/schema/migration
   - entities/models/configurations
   - DTOs/contracts/OpenAPI
   - controllers/routes
   - services/use cases/validators
   - frontend/admin screens/forms/states
   - workers/events/outbox
   - seeds/imports
   - tests/smoke
4. Classify status:
   - READY_FOR_SCAFFOLD
   - NOT_SCAFFOLDED
   - NEEDS_OWNER_DECISION
   - CONFLICT
   - MATCH
   - PARTIAL
   - WRONG_IMPLEMENTATION
   - UNKNOWN
5. Write or update the relevant plan/handoff artifact when required.

## 9. Implementation Workflow

Use this for approved changes:

1. Confirm approved phase or requirement slice.
2. Read canonical source section and active plan/handoff artifact.
3. Map current scaffold state before editing.
4. Modify only files needed for current phase.
5. Keep database/backend/API/frontend/seed/test changes together when the requirement crosses layers.
6. Run relevant validation:
   - backend build/test when backend exists and changed
   - frontend build/test/typecheck when frontend exists and changed
   - migration/update when schema changes
   - seed chain + seed validation when seed changes
   - smoke/e2e when workflow changes and smoke infra exists
7. Update handoff under `docs/v2-handoff/` or owner-referenced task doc.
8. Record newly discovered decisions or deferred gaps under `docs/v2-plan/` or `docs/v2-audit/`.

## 10. Schema / EF Migration Protocol

When a task touches schema or EF migrations:

1. If this is the first backend scaffold, create the first migration structure from canonical schema specs.
2. If migrations already exist, audit current EF model/configurations/migrations first.
3. Compare with canonical schema requirements.
4. Create a destructive migration risk list in Vietnamese.
5. Do not drop/rename table/column without explicit owner approval after data exists.
6. Do not use historical migrations as source truth.
7. If a migration is needed:
   - create a small migration for the phase;
   - use a clear migration name;
   - build migration;
   - run EF database update on local/dev/test DB when available;
   - report SQL/destructive risk if any.
8. If a command cannot run:
   - record exact command;
   - record blocker;
   - record residual risk.

Never run destructive production reset.

## 11. Seed Protocol

When a task touches seed:

1. Seed must follow canonical packs.
2. G1 is the active operational baseline.
3. Do not seed active G0.
4. Ingredient master must include `ING_MI_CHINH` and `HRB_SAM_SAVIGIN`.
5. Recipe seed must use exactly four G1 groups.
6. 20 canonical SKUs must match SKU master.
7. If seed changes:
   - run seed chain when available;
   - run seed validation when available;
   - run twice when idempotency is claimed;
   - report missing/failed rows.

## 12. API / Route Contract Protocol

When a task touches route/API:

1. For initial scaffold, derive routes from canonical API specs and document intended frontend/admin consumers.
2. After code exists, map current routes and consumers before changing or adding route families.
3. If docs conflict:
   - record conflict;
   - evaluate impact;
   - implement only the accepted canonical requirement.
4. If envelope/DTO changes:
   - update backend contract;
   - update OpenAPI when present;
   - update frontend client/types when frontend exists;
   - update tests.

## 13. Frontend / Admin UI Protocol

When a task touches frontend:

1. Confirm backend/API contract or planned contract first.
2. Do not make broad UI changes outside the phase.
3. Implement only related screens/forms/tables/state.
4. Run frontend typecheck/build/test when available.
5. Do not call APIs outside the planned or implemented contract.

## 14. Backend-Frontend Sync Rule

If a backend task changes anything that can affect frontend/admin-web, update or create the corresponding frontend API types, clients, UI flows, states, and tests in the same bounded phase when the frontend layer exists or is part of the phase.

Backend changes that require frontend review:

- route path or HTTP method;
- request DTO;
- response DTO;
- response envelope;
- pagination/meta shape;
- error response shape;
- enum/status values;
- action endpoint;
- auth/permission requirement;
- required/optional field;
- field casing;
- OpenAPI schema;
- validation rule shown in UI;
- query params/filter/sort/pagination convention.

If frontend is not scaffolded yet, report: `Frontend impact: N/A - not scaffolded yet`, and document the intended future consumer.

## 15. Process Hygiene Rules

AI agents must not leave background processes running.

Prefer finite validation commands:

- `dotnet build`
- `dotnet test`
- `npm run build`
- `npm run typecheck`
- `npm test` when the command terminates
- `pnpm build`
- `pnpm typecheck`

Do not run long-running commands unless explicitly required:

- `dotnet run`
- `dotnet watch`
- `npm run dev`
- `pnpm dev`
- `next dev`
- `vite dev`

Before final response, report:

- commands run;
- whether a long-running process was started;
- whether it was stopped;
- ports touched.

## 16. Validation Strategy

Validation must fit scope.

### Backend

- `dotnet build`
- focused `dotnet test`
- integration tests when workflow/schema changes
- `N/A - not scaffolded yet` if backend does not exist

### Frontend

- typecheck
- build
- relevant tests when available
- `N/A - not scaffolded yet` if frontend does not exist

### Database

- migration build
- EF database update on local/dev/test when schema changes
- no destructive reset without approval

### Seed

- seed chain
- seed validation
- duplicate/missing canonical data checks

### Smoke

- run only when workflow infrastructure exists
- report exact smoke path and result

## 17. Smoke Workflow Target

Target V2 smoke chain:

```text
Source Origin
-> Raw Material Intake
-> Raw Material QC / Lot Ready
-> SKU/Recipe G1 snapshot
-> Production Order
-> Material Issue by Lot
-> Material Receipt Confirmation
-> Execution / Batch Create
-> Packaging Level 1
-> Packaging Level 2 + GTIN/QR
-> QC Inspection
-> Batch Release
-> Warehouse Receipt Confirmed
-> Inventory Ledger / Lot Balance
-> Public/Internal Trace
-> Recall Hold / Sale Lock / Impact / Recovery
-> MISA sync points when configured
```

## 18. Review Protocol

When reviewing diff:

1. Compare diff with requirement source.
2. Check that it matches one bounded phase.
3. Check unrelated files.
4. Check tests/validation.
5. Check migration risk.
6. Check API/DTO/frontend sync.
7. Check security/permission/audit.
8. Check public trace field policy.
9. Check inventory ledger boundary.
10. Return verdict:
    - ACCEPT
    - NEEDS_FIX
    - REJECT

## 19. Do Not Do

- Do not treat the empty repo as a broken migration.
- Do not require current code route maps before initial route scaffold exists.
- Do not seed active G0.
- Do not use two-section operational recipes.
- Do not allow production/material issue to choose ingredients manually outside approved recipe/version flow.
- Do not treat QC_PASS as RELEASED.
- Do not let printing create inventory, QC pass, or release.
- Do not expose internal traceability fields in public trace.
- Do not let modules sync directly to MISA.
- Do not create duplicate business truth.
- Do not run destructive DB reset on production.
- Do not declare done without reporting commands run and validation results.
- Do not leave `dotnet`, `node`, `vite`, `next`, `testhost`, or dev server processes running.
- Do not implement from old DOCX/PDF extracts when canonical Markdown pack exists.
- Do not broaden a task because it is nearby.

## 20. Final Response Checklist

After implementation, report in Vietnamese:

- Summary
- Phase/requirement ID
- Requirement source
- Evidence used
- Files changed
- Commands run
- Test result
- Backend build result
- Frontend build result
- Migration/update result, if applicable
- Seed validation result, if applicable
- Smoke result, if applicable
- Markdown/handoff update
- Process cleanup result
- Remaining risks
- Next recommended action
