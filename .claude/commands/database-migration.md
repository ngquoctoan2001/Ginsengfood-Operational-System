---
name: database-migration
description: Ginsengfood V2 database workflow for greenfield schema scaffold, migrations, seed, validation, clean reset, and production-readiness evidence.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /database-migration

Use this workflow for Ginsengfood V2 database, schema, migration, seed, or reset work.

## Current State

The repository is greenfield. EF/database infrastructure may not exist yet. If it does not exist, first plan or implement the backend/database scaffold phase from canonical database specs instead of running migration commands against nonexistent paths.

## Required Source

Read `AGENTS.md`, `CLAUDE.md`, and the relevant files from `docs/software-specs/` first. For broad schema, seed, workflow, form, traceability, recall, MISA, QR, production, or route work, read the relevant Markdown files in `docs/software-specs/`.

## Mandatory DB Rules

- G1 is the initial operational baseline for go-live, not a permanent version ceiling.
- Formula schema must support future G2/G3 versions with status, approval, effective dates, audit, immutable production snapshots, and retirement.
- G0 is research/baseline context only and must not be active in operational seed or production flows.
- Schema must support four go-live recipe line groups, canonical SKU/ingredient master, production order formula snapshot, material issue execution, material receipt confirmation, batch release, inventory ledger/balance, trade item/GTIN, QR lifecycle, public trace policy, and MISA mapping/retry/reconcile where in scope.
- Seed must be canonical, idempotent when intended, sorted by dependency, and validated by SQL or script.
- Historical seed SQL or extracted docs are not truth when they conflict with `docs/software-specs/`.

## Verification

When schema or seed changes and infrastructure exists, run and report:

- EF migration build.
- EF database update.
- Full sorted seed chain.
- Second seed pass if idempotent.
- Seed validation SQL/script.
- Backend build/tests.
- Frontend build/tests when API/UI contracts changed.
- Clean reset evidence only after explicit owner approval for destructive reset.
- Process cleanup: run `dotnet build-server shutdown` after agent-run .NET build/test/EF commands; stop only agent-owned long-lived PIDs with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`.

If infrastructure is absent, report `N/A - not scaffolded yet` and name the required scaffold phase.
