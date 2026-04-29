# Ginsengfood V2 Operational Rules

Use this rule file for Claude, GitHub Copilot Chat agents, and Codex GPT-5.5 xhigh when working in this repository.

## Repository State

This repository is currently greenfield. It contains source specifications and agent/tool configuration, but no application code has been scaffolded yet.

Treat missing app layers as `NOT_SCAFFOLDED`, not as stale implementation. Do not require current-code route maps, historical migration deltas, seed deltas, or GitNexus code graph evidence before the initial scaffold exists.

## Response Language

Respond in Vietnamese for all project communication: plans, progress notes, reviews, validation, handoff, risks, blockers, and final responses.

Keep English for standard technical terms and exact identifiers such as code symbols, file paths, route paths, API methods, DTO/table/column/enum names, commands, package names, JSON/YAML/TOML keys, HTTP status codes, framework/tool names, and original log/error text.

Do not translate code fences, command lines, exact schema names, route names, or error messages. Explain them in Vietnamese when needed.

## Source Packs

The current accepted source-truth documents are exactly:

- `docs/software-specs/`
  - Architecture, business rules, module specs, API, database, UI, workflows, testing, forms, operational rules, master data, recipe/SKU/ingredient, seed spec, dev handoff, and agent workflow prompts.

`.tmp-docx-extract/`, current assumptions, historical migrations, seed SQL, `specs/`, DOCX/PDF extracts, and old prompt packs are historical reference only. They are not allowed to override `docs/software-specs/`.

For broad scaffold, schema, seed, workflow, form, traceability, recall, MISA, QR, production, or route work, read the relevant Markdown files in `docs/software-specs/` before planning changes.

## Formula Versioning Rule

- G1 is the initial operational baseline formula version for factory go-live.
- Use G1 to build the first correct schema, seed chain, production-order snapshot, material issue, traceability, recall, and validation flows.
- Do not design the database as if G1 is the final version forever.
- Schema and services must support later accepted formula versions such as G2, G3, and beyond.
- Later formula versions must be approved, activated, snapshotted into production orders, audited, and retired without mutating historical production records.
- G0 is research/baseline context only. Do not seed G0 as an active operational formula and do not use it for production, material issue, costing, trace, recall, or handoff.

## Operational Hard Locks

- Recipe display and material issue use four G1 groups at go-live: `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`.
- Ingredient master must include `ING_MI_CHINH` and `HRB_SAM_SAVIGIN`.
- Production order snapshot must capture formula code, formula version, recipe line group, ingredient code/display name, quantity per batch 400, UOM, prep note, and usage role.
- Material Issue Execution is the raw-material inventory decrement point.
- Material Receipt Confirmation is separate and records workshop receipt/variance.
- `QC_PASS` is not `RELEASED`; batch release is a separate action/record.
- Warehouse finished-goods receipt requires a RELEASED batch and must create inventory ledger/balance projection.
- Trade item/GTIN/GS1 identity is separate from SKU identity.
- QR registry must support GENERATED, QUEUED, PRINTED, FAILED, VOID, and REPRINTED.
- Public trace must not expose supplier/internal personnel/costing/QC-defect/loss/MISA data.
- MISA sync goes through one integration layer with mapping, sync job/log, retry, reconcile, and audit.
- Initial API routes come from canonical API specs. After route code exists, map current routes before changing them.

## Agent Team Roles

Use these roles explicitly in planning and review:

- BA: extracts requirement IDs, source headings, acceptance criteria, conflicts, and owner decisions.
- PM: creates bounded greenfield phases, dependencies, risk, validation gates, and handoff paths.
- Tech Lead: maps target ownership, architecture, route contracts, versioning, public/private boundaries, and cross-layer impact.
- DBA/Data Engineer: owns first migrations, constraints, indexes, seed order, idempotency, validation SQL, and clean reset evidence.
- Backend Developer: implements domain, service, API, DTO, validation, OpenAPI, workers/events, and tests.
- Frontend/Admin Developer: creates API clients, types, routes, forms, states, permissions, and UI tests.
- QA/Tester: converts acceptance criteria into unit, integration, API, migration, seed, and smoke/e2e tests.
- DevOps/Release: verifies build/test commands, DB update/reset, seed chain, environment assumptions, backup, and rollback notes.
- Security/Reviewer: checks permissions, audit logs, public/private data exposure, append-only behavior, contract drift, and missing tests.

Use `docs/software-specs/ai-agent/` for phase prompts and output contracts.

## Validation Gates

Run and report applicable backend build/tests, frontend type check/build/tests, EF database update, seed chain/validation, and smoke/e2e gates when those layers exist and changed.

If a layer does not exist, report `N/A - not scaffolded yet`. If a gate cannot run because of environment or permission constraints, report the exact command, blocker, and residual risk.

## Agent-Owned Process Cleanup

Agents must not leave local processes running after final response or handoff.

- Prefer finite foreground commands.
- Avoid `dotnet run`, `dotnet watch`, `npm run dev`, Vite/Next dev servers, Playwright web servers, Docker compose, `Start-Process`, `Start-Job`, and background jobs unless required.
- If a live process is required, record the PID immediately or start it with `tools/agent/Start-AgentOwnedProcess.ps1`.
- Stop tracked PIDs before final response with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`.
- Run `dotnet build-server shutdown` after agent-run .NET build/test/EF commands.
- Never kill broad process names. User-owned terminals may be running the same binaries, so report unclear ownership instead of stopping it.
