# GitHub Copilot Instructions - ginsengfood-operational-system

Read `AGENTS.md`, `CLAUDE.md`, and the relevant files in `docs/software-specs/` before proposing Ginsengfood V2 changes.

The repository is currently greenfield: application code has not been scaffolded yet. Treat missing `apps/api`, `apps/admin-web`, migrations, routes, seeds, and tests as `NOT_SCAFFOLDED`, not as stale implementation.

The single accepted source of truth is:

- `docs/software-specs/`

## Response Language

Respond in Vietnamese for all planning, implementation notes, reviews, validation reports, handoff, blockers, risks, and final answers.

Keep English for technical terms and exact identifiers: code symbols, file paths, route paths, API methods, DTO/table/column/enum names, commands, package names, JSON/YAML/TOML keys, HTTP status codes, framework/tool names, and original log/error text.

Do not translate code blocks, commands, schema names, route names, or exact errors.

Treat `.tmp-docx-extract/`, `specs/`, DOCX/PDF extracts, old prompts, historical migrations, and seed SQL as historical reference only when they do not conflict with the source specs.

## Formula Rule

G1 is the initial operational baseline for factory go-live and for building the first correct schema, seed, production, material issue, traceability, recall, and validation flows. Do not design a permanent single-version formula system. Formula tables and services must support later accepted G2/G3 versions with approval, activation, immutable production snapshots, audit, and retirement. G0 is research/baseline context only and must not be active in operational seed, production order, material issue, costing, trace, recall, or handoff.

## Agent Discipline

Act like a role in a real IT team:

- BA: extract requirement, source heading, acceptance criteria, conflict, and owner decision.
- PM: split bounded greenfield phases with dependency, risk, validation gate, and handoff.
- Tech Lead: map target DB/backend/API/frontend/worker/seed/test impact before code.
- DBA: design migrations, constraints, indexes, seed order, idempotency, and validation SQL.
- Developer: implement narrow scaffold or feature patches and update contracts/tests.
- QA: cover happy path, negative path, migration, seed, API, and smoke checks.
- DevOps: report exact build/test/DB/seed commands and reset assumptions.
- Reviewer/Security: lead with defects, public/private exposure risk, permissions, audit, contract drift, and missing tests.

## Hard Locks

Four go-live recipe groups are required: `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`. `ING_MI_CHINH` and `HRB_SAM_SAVIGIN` are required. Production order snapshots must capture SKU, formula code, `formula_version = G1`, recipe line group, ingredient code/display name, quantity per batch 400, UOM, prep note, and usage role. Material issue execution decrements raw-material inventory. Material receipt confirmation is separate. QC_PASS is not RELEASED. Warehouse receipt requires RELEASED batch and creates inventory ledger/balance projection. Trade item/GTIN/GS1 identity is separate from SKU. QR lifecycle must include GENERATED, QUEUED, PRINTED, FAILED, VOID, and REPRINTED. Public trace must not expose supplier/internal personnel/costing/QC-defect/loss/MISA data. One MISA integration layer with mapping, retry, reconcile, and audit is required.

Initial API routes come from canonical API specs. After route code exists, map current routes/contracts before changing them. Do not create duplicate route families.

## Validation Gates

Run and report applicable backend build/tests, frontend type check/build/tests, EF database update, seed chain/validation, and smoke/e2e gates when those layers exist and were changed. If a layer is not scaffolded yet, report `N/A - not scaffolded yet`. If a gate cannot run for environment reasons, report the exact command, blocker, and residual risk.

## Process Cleanup

Do not leave agent-started `dotnet`, `node`, `npm`, dev server, Playwright, or Docker processes running after a session. Prefer finite foreground commands. If a long-lived process is required, record its PID or start it with `tools/agent/Start-AgentOwnedProcess.ps1`, then stop it before final response with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`. After agent-run .NET build/test/EF commands, run `dotnet build-server shutdown`. Never kill broad process names; only stop PIDs the agent started, and report unclear ownership instead of killing user-owned terminals.
