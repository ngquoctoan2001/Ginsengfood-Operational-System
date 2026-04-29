---
name: ginsengfood-v2-phase
description: Run one bounded Ginsengfood V2 scaffold, implementation, validation, or review phase from the accepted source specs.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /ginsengfood-v2-phase

Use this workflow for any Ginsengfood Operational Domain scaffold, schema, seed, API, admin UI, integration, test, review, or handoff phase.

The repo is greenfield. Missing application layers are `NOT_SCAFFOLDED`.

## Response Language

Tra loi bang tieng Viet cho tat ca project communication. Giu nguyen tieng Anh cho technical terms va exact identifiers nhu file paths, code symbols, route paths, API methods, DTO/table/column/enum names, commands, package names, JSON/YAML/TOML keys, HTTP status codes, framework/tool names va original log/error text.

## Required Reading

1. `AGENTS.md`
2. `CLAUDE.md`
3. `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`
4. Relevant files in `docs/software-specs/`

For broad scaffold, schema, seed, workflow, form, traceability, recall, MISA, QR, production, or route work, read the relevant Markdown files in `docs/software-specs/`.

## Role Sequence

1. BA: extract the exact requirement, source heading, acceptance criteria, and conflicts.
2. PM: define phase scope, exclusions, dependency, validation gate, and handoff output.
3. Tech Lead: map target DB, backend, API/DTO/OpenAPI, admin UI, workers/events, seeds, tests, and operations impact.
4. DBA/Data: plan migration, constraints, seed order, idempotency, and validation SQL when data changes.
5. Dev: implement only the bounded phase.
6. QA: add/adjust tests for happy path and negative cases.
7. DevOps: run available build, tests, EF update, seed chain, reset-safe checks, and smoke tests when applicable.
8. Reviewer/Security: verify correctness, permissions, audit, public/private data boundary, contract drift, and remaining risks.

## Formula Versioning Lock

G1 is the initial operational baseline for factory go-live. Do not hard-code a permanent single-version formula world. Schema and flows must support future approved versions such as G2/G3 with immutable production snapshots. G0 is research/baseline context only and must not be active in operational seed, production, material issue, costing, trace, recall, or handoff.

## Operational Locks

Four go-live recipe groups are required: `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`. `ING_MI_CHINH` and `HRB_SAM_SAVIGIN` are required. Material issue decrements inventory. QC_PASS is not RELEASED. Warehouse receipt requires RELEASED batch. Public trace must not leak internal fields. MISA sync goes through one integration layer.

## Done Gate

Bao cao bang tieng Viet: source evidence, file da sua, lenh da chay, backend build/tests, frontend build/tests, database migration/update, seed validation, smoke/e2e, cleanup process, cap nhat Markdown/handoff, file bi chan, reference cu con sot, rui ro con lai, va prompt phase tiep theo.

Use `N/A - not scaffolded yet` for absent layers. Before final response, stop only agent-owned long-lived PIDs with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`, run `dotnet build-server shutdown` after agent-run .NET build/test/EF commands, and never kill broad process names that may include owner-run terminals.
