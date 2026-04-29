---
description: "Use when implementing Ginsengfood V2 scaffold phases or bounded features from the accepted source specs."
---

# Ginsengfood V2 Greenfield Rules

## Response Language

All responses must be Vietnamese by default. Keep English for standard technical terms and exact identifiers such as file paths, code symbols, route paths, API methods, DTO/table/column/enum names, commands, package names, JSON/YAML/TOML keys, HTTP status codes, framework/tool names, and original log/error text.

## Required Reading Before Starting

1. `AGENTS.md`
2. `CLAUDE.md`
3. `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`
4. `docs/software-specs/01_SOURCE_INDEX.md`
5. Relevant files under `docs/software-specs/`

For broad scaffold, schema, seed, workflow, form, traceability, recall, MISA, QR, production, or route work, read every relevant Markdown file in `docs/software-specs/` before planning changes.

## Current Repo State

The project is greenfield. Do not require existing app code, migrations, routes, seed scripts, or tests before initial scaffold phases. Mark absent layers as `NOT_SCAFFOLDED`.

## Role-Based Implementation Sequence

1. BA: identify source file, heading, requirement, acceptance criteria, and conflicts.
2. PM: define phase scope, dependencies, risks, validation gates, and handoff artifact.
3. Tech Lead: map target DB, entities, services, API/DTO/OpenAPI, admin UI, workers/events, seeds, tests, and operations.
4. DBA/Data: plan first migrations, constraints, indexes, seed order, idempotency, validation SQL, and clean reset checks.
5. Developer: implement one bounded phase.
6. QA: add happy-path and negative tests from acceptance criteria.
7. DevOps: run available build/test/migration/seed/smoke gates and record exact commands.
8. Reviewer/Security: check correctness, permissions, public/private exposure, audit logs, append-only behavior, contract drift, and missing tests.
9. Handoff: update `docs/v2-handoff/` or the active task document.

## Documentation Precedence

| Priority | Document |
| --- | --- |
| P0 | `docs/software-specs/01_SOURCE_INDEX.md` |
| P0 | `docs/software-specs/02_EXECUTIVE_SUMMARY.md` |
| P0 | `docs/software-specs/architecture/` |
| P1 | `docs/software-specs/business/` |
| P1 | `docs/software-specs/functional/` |
| P1 | `docs/software-specs/database/` |
| P1 | `docs/software-specs/api/` |
| P1 | `docs/software-specs/ui/` |
| P1 | `docs/software-specs/workflows/` |
| P1 | `docs/software-specs/modules/` |
| P2 | `docs/software-specs/dev-handoff/` |
| P2 | `docs/software-specs/testing/` |
| P3 | Current repository implementation, once scaffolded, as evidence only |
| P4 | `.tmp-docx-extract/`, `specs/`, old DOCX/PDF extracts, historical migrations, old seed SQL as historical reference only |

When documents conflict, do not merge creatively. Use the priority above and record the conflict in `docs/v2-plan/` or `docs/v2-audit/`.

## Formula And Operational Locks

- G1 is the initial operational baseline formula version for factory go-live.
- Use G1 to build the first correct schema, seed chain, production-order snapshot, material issue, traceability, recall, and validation flows.
- Schema and flows must support future accepted versions such as G2/G3 with approval, activation, immutable production snapshots, audit, and retirement without rewriting historical production records.
- G0 is research/baseline context only and must not be active in seed, production order, material issue, costing, trace, recall, or dev handoff.
- Recipes and material issue must use `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, and `SEASONING_FLAVOR` for go-live G1.
- Ingredient master must include `ING_MI_CHINH` and `HRB_SAM_SAVIGIN`.
- Production order snapshot must capture SKU, formula code, `formula_version = G1`, recipe line group, ingredient code/display name, quantity per batch 400, UOM, prep note, and usage role.
- Material Issue Execution decrements raw-material inventory; Material Receipt Confirmation is separate.
- QC_PASS is not RELEASED; batch release is a separate action/record.
- Warehouse receipt requires RELEASED batch and creates inventory ledger/balance projection.
- Trade item/GTIN/GS1 identity is separate from SKU identity.
- QR lifecycle must include GENERATED, QUEUED, PRINTED, FAILED, VOID, and REPRINTED.
- Public trace field policy must block supplier/internal personnel/costing/QC-defect/loss/MISA data.
- MISA integration mapping/retry/reconcile/audit is required through one shared integration layer.
- Initial API routes come from canonical API specs. After route code exists, changes require route/consumer mapping first.

## Validation Gates

Run and report every applicable gate:

- backend build and backend tests when backend exists and changed;
- frontend type check, frontend tests, and frontend build when frontend exists and changed;
- EF database update when migrations change;
- full sorted seed chain and seed validation when seed changes, twice when idempotency is claimed;
- smoke/e2e when user-facing workflows change and smoke infrastructure exists;
- process cleanup after any local command sequence.

If a gate cannot run, report the exact command attempted, blocker, and residual risk. If a layer is absent, report `N/A - not scaffolded yet`.

## Response Format

```markdown
## Tom tat
## Nguon yeu cau
## File da sua
## Evidence da dung
## Lenh da chay
## Ket qua test
## Ket qua backend build
## Ket qua frontend build
## Ket qua cleanup process
## Ket qua database migration/update
## Ket qua seed validation
## Ket qua smoke/e2e
## Cap nhat Markdown/handoff
## File bi chan boi quyen
## Rui ro con lai
## Prompt phase tiep theo
```
