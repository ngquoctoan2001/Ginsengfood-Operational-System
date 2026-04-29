---
description: "Use when completing any implementation task. Enforces applicable completion gates for the current scaffold state."
applyTo: "**"
---

# Completion Gates

Never mark a task done without reporting every applicable gate.

For Ginsengfood V2 work, the accepted source truth is exactly `docs/software-specs/`. The repo is currently greenfield, so gates for non-scaffolded layers are reported as `N/A - not scaffolded yet`.

## Response Language

Write gate results, blockers, residual risks, and final reports in Vietnamese. Keep command lines, file paths, package/script names, status codes, and original build/test/error output in English.

## Gate 1 - Update Attached .md File

If the user referenced, attached, or opened a `.md` file related to this task:

- Update that file with completed sections, status changes, evidence of completion, and remaining gaps.
- Do this before the final response.

## Gate 2 - Backend Build + Test

Trigger: backend code exists and a backend file, project file, migration, or build config changed.

Preferred commands after scaffold:

```powershell
dotnet build --no-incremental -warnaserror
dotnet test --no-build
```

If backend is not scaffolded, report `N/A - not scaffolded yet`.

## Gate 3 - Frontend Build + Type Check

Trigger: frontend code exists and `.ts`, `.tsx`, routes, API clients, form schemas, or package config changed.

Preferred commands after scaffold:

```powershell
npx tsc -b --noEmit
npm run build
```

If frontend is not scaffolded, report `N/A - not scaffolded yet`.

## Gate 4 - Database Migration Sync

Trigger: EF Core migration files are added, modified, or removed.

After backend scaffold exists, apply migrations to the target local/dev/test database and report the exact command. Verify pending status after applying.

If migration infrastructure is not scaffolded, report `N/A - not scaffolded yet`.

## Gate 5 - Backend/Frontend Contract Sync

Trigger: backend API routes, controller actions, DTOs, enums, error shapes, validation rules, or OpenAPI spec changed.

If frontend exists, regenerate/update the frontend API client and run frontend typecheck/build. If frontend is not scaffolded, report `Frontend impact: N/A - not scaffolded yet` and document the intended future consumer.

## Gate 6 - Seed Chain And Validation

Trigger: seed SQL/scripts, canonical SKU/ingredient/recipe data, recipe groups, QR statuses, trace policy, MISA mappings, or bootstrap behavior changed.

Run the seed chain and validation when seed infrastructure exists. Run twice when idempotency is claimed. If seed infrastructure is not scaffolded, report `N/A - not scaffolded yet`.

## Gate 7 - Smoke/E2E

Trigger: user-facing workflow changes, form state/action changes, trace/recall changes, QR/print changes, material issue/receipt changes, batch release changes, warehouse receipt changes, or public trace exposure changes.

Run relevant smoke/e2e when infrastructure exists. Otherwise report `N/A - not scaffolded yet`.

## Gate 8 - Agent Process Cleanup

Trigger: any local command execution, especially .NET, frontend, Playwright, Docker, or dev-server commands.

- Prefer finite foreground commands.
- Stop tracked long-lived PIDs with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`.
- After agent-run .NET build/test/EF commands, run `dotnet build-server shutdown`.
- Never kill every `dotnet`, `node`, `npm`, `testhost`, or `VBCSCompiler` process by name.

## Format phan hoi cuoi

```markdown
## Tom tat
## File da sua
## Lenh da chay
## Ket qua test
## Ket qua backend build
## Ket qua frontend build
## Ket qua cleanup process
## Ket qua database migration/update
## Ket qua seed validation
## Ket qua smoke/e2e
## File .md da cap nhat
## File bi chan boi quyen
## Rui ro con lai
```
