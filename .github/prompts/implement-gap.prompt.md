---
description: "Implement a specific Ginsengfood V2 scaffold phase or bounded requirement from the accepted source specs."
mode: agent
---

# Implement Ginsengfood V2 Phase

## Response Language

Tra loi bang tieng Viet cho moi phan phan tich, tien do, review, validation, handoff va final report. Giu nguyen tieng Anh cho technical terms va exact identifiers nhu file paths, code symbols, route paths, API methods, DTO/table/column/enum names, commands, package names, JSON/YAML/TOML keys, HTTP status codes, framework/tool names va original log/error text.

## Input

Phase/requirement to implement: `$PHASE_ID - $PHASE_TITLE`

## Phase 0 - Pre-flight Reading

Read these documents before touching files:

1. `AGENTS.md`
2. `CLAUDE.md`
3. `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`
4. `docs/software-specs/01_SOURCE_INDEX.md`
5. Relevant files under `docs/software-specs/`

The repo is greenfield. Missing app code is `NOT_SCAFFOLDED`.

## Phase 1 - Role-Based Analysis

Produce short notes before implementation:

- BA: requirement source, heading, acceptance criteria, conflicts, owner decisions.
- PM: scope, exclusions, dependencies, phase risk, validation gates, handoff path.
- Tech Lead: target impact map for DB, backend, API/DTO/OpenAPI, frontend/admin, workers/events, seeds, tests, operations.
- DBA/Data: schema/migration/seed/validation SQL plan when data changes.
- QA: test matrix with happy path, negative path, migration/seed checks, smoke checks.
- Reviewer/Security: public/private exposure, permissions, audit, append-only, and contract drift risks.

## Phase 2 - Scaffold State

Map current state versus required state:

| Layer | Current State | Required State | Evidence |
| --- | --- | --- | --- |
| Repo/Solution Scaffold | | | |
| DB Schema | | | |
| Entity | | | |
| Service | | | |
| API/DTO/OpenAPI | | | |
| Frontend/Admin | | | |
| Worker/Event | | | |
| Seeds | | | |
| Tests | | | |

Use `NOT_SCAFFOLDED` when a layer does not exist yet.

## Phase 3 - Formula And Workflow Guardrails

Keep these rules active:

- G1 is the initial operational baseline for go-live, not the final version forever.
- Schema and flows must support future G2/G3 versions with approval, activation, immutable snapshots, audit, and retirement.
- G0 is research/baseline context only and must not be active in operational seed, production, material issue, costing, trace, recall, or handoff.
- Recipe display and material issue must use `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, and `SEASONING_FLAVOR`.
- Ingredient master must include `ING_MI_CHINH` and `HRB_SAM_SAVIGIN`.
- Production order snapshot must capture SKU, formula code, `formula_version = G1`, recipe line group, ingredient code/display name, quantity per batch 400, UOM, prep note, and usage role.
- Material Issue Execution decrements raw-material inventory.
- Material Receipt Confirmation is separate.
- QC_PASS is not RELEASED.
- Warehouse receipt requires RELEASED batch.
- Trade item/GTIN/GS1 identity is separate from SKU identity.
- QR registry must support GENERATED, QUEUED, PRINTED, FAILED, VOID, and REPRINTED.
- Public trace must not leak internal supplier/personnel/costing/QC-defect/loss/MISA fields.
- MISA sync uses one integration layer with mapping, retry, reconcile, and audit.

## Phase 4 - Implement

Work in dependency order when applicable:

1. Repository/solution scaffold.
2. Database migration/schema.
3. Domain/entity/configuration.
4. Application service/command/query.
5. API route/DTO/validator/OpenAPI.
6. Frontend/admin API client, types, forms, screens, state.
7. Worker/event/outbox/projection.
8. Seed SQL and seed validation.
9. Unit/API/E2E/smoke tests.
10. Phase handoff docs.

## Phase 5 - Completion Gates

Run and report relevant gates:

- Backend build and tests when backend exists and changed.
- Frontend type check/build/tests and API client generation when frontend exists and contracts changed.
- EF database update when migrations changed.
- Full sorted seed chain and seed validation when seed changed.
- Second seed pass when seed is intended to be idempotent.
- Smoke/e2e when user-facing workflow changed and infrastructure exists.
- Explicit `N/A - not scaffolded yet` for absent layers.

## Phase 6 - Handoff

Update `docs/v2-handoff/` or the active task document with source requirement, files changed, commands/results, DB migration/update result, seed validation result, residual risk, and next phase.

## Phase 7 - Process Cleanup

Stop only long-lived processes started by this agent before final response. Use `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants` for tracked PIDs. Run `dotnet build-server shutdown` after agent-run .NET build/test/EF commands.

## Format phan hoi cuoi

```markdown
## Tom tat
## Nguon yeu cau
## Evidence da tim thay
## File da sua
## Lenh da chay
## Ket qua test
## Ket qua backend build
## Ket qua frontend build
## Ket qua cleanup process
## Ket qua database migration/update
## Ket qua seed validation
## Ket qua smoke/e2e
## Handoff da cap nhat
## File bi chan boi quyen
## Rui ro con lai
## Prompt phase tiep theo
```
