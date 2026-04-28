# Claude / Copilot Context - ginsengfood-operational-system

Read `AGENTS.md` first. It is the primary instruction file for project state, canonical Ginsengfood source-of-truth, greenfield workflow, required verification gates, and process cleanup.

## Model Posture

Use the strongest available Claude model for implementation planning and deep review. For GitHub Copilot Chat in VS Code, read `docs/software-specs/ai-agent/` before starting a phase.

For Codex in VS Code, use GPT-5.5 with xhigh reasoning as required by `AGENTS.md`.

## Repository State

This repo is currently a greenfield workspace. The application has not been scaffolded yet.

Do not assume these paths exist until they are created by a phase:

- `apps/api`
- `apps/admin-web`
- `apps/website`
- `src/`
- EF migrations
- OpenAPI output
- seed scripts
- smoke/e2e suites

When a layer does not exist, report validation as `N/A - not scaffolded yet` instead of treating the empty repo as a failed migration.

## Agent-Owned Process Lifecycle

Agents must not leave local processes running after the response or session handoff.

- Prefer finite foreground validation commands.
- Do not start `dotnet run`, `dotnet watch`, `npm run dev`, Vite/Next dev servers, Playwright web servers, Docker compose, `Start-Process`, `Start-Job`, or background jobs unless a live server is required.
- If a long-lived process is required, start it with `tools/agent/Start-AgentOwnedProcess.ps1` or record the exact PID immediately.
- Before final response, stop every agent-owned PID with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`.
- After any agent-run .NET build/test/EF sequence, run `dotnet build-server shutdown`.
- Never kill all `dotnet`, `node`, `npm`, `testhost`, or `VBCSCompiler` processes by name. User-owned terminals may be running the same commands; if ownership is unclear, report instead of killing.
- Include `Process cleanup result` in final reports.

## Current Source Of Truth

The accepted source-of-truth documents are exactly:

- `docs/software-specs/`
  - All architecture, business rules, module specs, API, database, UI, workflows, testing, forms, operational rules, master data, recipe/SKU/ingredient, seed spec, dev handoff, and agent workflow prompts.

Use these agent workflow files for phase prompts and output contracts:

- `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`
- `docs/software-specs/ai-agent/02_CODEX_PROMPT_PACK.md`
- `docs/software-specs/ai-agent/03_GAP_IMPLEMENTATION_PROMPTS.md`
- `docs/software-specs/ai-agent/04_REVIEW_PROMPTS.md`
- `docs/software-specs/ai-agent/05_VALIDATION_PROMPTS.md`
- `docs/software-specs/ai-agent/06_HANDOFF_PROMPTS.md`

Use phase output folders when they exist:

- `docs/v2-plan/`
- `docs/v2-handoff/`
- `docs/v2-smoke/`
- `docs/v2-audit/` for conflicts, deferred gaps, or later drift against implemented code.

Do not use `specs/`, `.tmp-docx-extract/`, old DOCX/PDF extracts, historical migrations, old seed SQL, or old prompts to override `docs/software-specs/`.

## Non-Negotiable V2 Rules

- G1 is the initial operational baseline recipe version for factory go-live and for building the first correct schema, seed, production, material issue, trace, recall, and validation flows.
- Formula design must support future approved versions such as G2, G3, and beyond through explicit version/status/effective-date governance, immutable production snapshots, and audit history.
- G0 is research/baseline context only and must not be active in seed, production order, material issue, costing, trace, recall, or dev handoff.
- Recipes and material issue must use the four G1 groups:
  - `SPECIAL_SKU_COMPONENT`
  - `NUTRITION_BASE`
  - `BROTH_EXTRACT`
  - `SEASONING_FLAVOR`
- Ingredient master must include `ING_MI_CHINH` and `HRB_SAM_SAVIGIN`.
- Production order snapshot must capture SKU, formula code, `formula_version = G1`, recipe line group, ingredient code/display name, quantity per batch 400, UOM, prep note, and usage role.
- Material Issue Execution decrements raw-material inventory; material approval does not.
- Material Receipt Confirmation is separate from issue execution.
- QC_PASS is not RELEASED; batch release is a separate action/record.
- Warehouse receipt requires RELEASED batch and creates inventory ledger/balance projection.
- Trade item/GTIN/GS1 identity is separate from SKU identity.
- QR registry must support GENERATED, QUEUED, PRINTED, FAILED, VOID, and REPRINTED.
- Public trace must follow field policy and must not expose supplier/internal personnel/costing/QC-defect/loss/MISA data.
- MISA sync must use one integration layer with mapping, retry, reconcile, and audit.
- Initial API routes must be derived from canonical API specs. After route code exists, later route changes require route/consumer mapping first.

## Agent Role Discipline

Use this file as a lightweight operating contract for Claude Sonnet/Opus in Copilot Chat:

- BA mode: extract `docs/software-specs/` requirements into IDs, source headings, acceptance criteria, conflicts, and open decisions.
- PM mode: create bounded greenfield phase plans with dependencies, risk, validation gate, and handoff output.
- Tech lead mode: map intended project structure and cross-layer impact across DB, backend, API, admin UI, workers, seeds, tests, and operations before coding.
- DBA mode: design first migrations, constraints, indexes, seed idempotency, clean reset, and G1-to-future-version readiness.
- Developer mode: implement narrow scaffold or feature patches and update related contracts/tests in the same phase.
- QA mode: convert acceptance criteria into unit, integration, API, migration, seed, and smoke tests.
- DevOps mode: validate build/test commands, database update/reset, seed order, environment assumptions, and runbook evidence.
- Reviewer mode: lead with defects, regressions, missing tests, contract drift, permission issues, public trace leaks, and audit gaps.

## Workflow

1. Read `AGENTS.md`.
2. Read the relevant files from `docs/software-specs/`. For broad Operational work, read every `.md` relevant to the domain.
3. Treat missing application code as `NOT_SCAFFOLDED`.
4. Build a greenfield phase map across intended DB, entities, services, API/DTO/OpenAPI, admin UI, workers/events, seeds, and tests.
5. Implement one bounded phase at a time.
6. Run backend build/tests, frontend build/tests, EF migration update, seed chain, and seed validation when the corresponding layer exists and is affected.
7. Update the current phase handoff under `docs/v2-handoff/` or the active task document before final handoff.

Use GitNexus after application code exists or when an indexed repo can reduce guesswork. Do not require GitNexus to prove absence in an empty repo.

## Validation Gates

Run and report the applicable gates for the files changed:

- backend build/tests for backend or contract changes when backend exists;
- frontend type check/build/tests for admin UI or generated-client changes when frontend exists;
- EF database update for migration changes;
- full sorted seed chain plus seed validation, twice when seed idempotency is claimed;
- smoke/e2e for user-facing workflow changes when smoke infrastructure exists;
- process cleanup for any local command sequence.

If a gate cannot run, report the exact command attempted, the blocker, and the residual risk. If a layer is not scaffolded yet, report `N/A - not scaffolded yet`.

## Local Tooling

GitNexus may be available through MCP and the local CLI:

```powershell
gitnexus status
gitnexus query --repo ginsengfood-operational-system "<topic>"
```

Use GitNexus before broad exploration only after code exists and the index is useful. Refresh the index only when needed.
