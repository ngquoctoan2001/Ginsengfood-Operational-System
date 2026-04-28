---
description: "Run all applicable completion gates for the current scaffold state."
mode: agent
---

# Completion Gates Check

Run all applicable completion gates for the current task in order.

For Ginsengfood V2 tasks, the single accepted source of truth is:

- `docs/software-specs/`

The repo is greenfield. If a layer is not scaffolded, report `N/A - not scaffolded yet`.

## Context

Current task: `$TASK_DESCRIPTION`
Attached `.md` file, if any: `$MD_FILE`

## Step 1 - Update Attached .md File

If `$MD_FILE` is provided or a task-related `.md` file was referenced:

- Open the file.
- Update it with completed sections, status changes, evidence, and remaining gaps.
- Confirm the update was made.

## Step 2 - Backend Build + Test

If backend exists and changed:

```powershell
dotnet build --no-incremental -warnaserror
dotnet test --no-build
```

Otherwise report `N/A - not scaffolded yet` or `N/A - not touched`.

## Step 3 - Frontend Type Check + Build

If frontend exists and changed:

```powershell
npx tsc -b --noEmit
npm run build
```

Otherwise report `N/A - not scaffolded yet` or `N/A - not touched`.

## Step 4 - Database Migration Status

If EF migration infrastructure exists and migrations changed, run migration list/update commands and report exact results.

Otherwise report `N/A - not scaffolded yet` or `N/A - no migration changes`.

## Step 5 - API Contract Sync

If backend contracts changed and frontend exists, update/regenerate frontend API client and rerun frontend typecheck/build.

If frontend does not exist, report intended future consumer.

## Step 6 - Seed And Smoke Gates

If seed data changed and seed infrastructure exists, run seed chain and validation. Run twice when idempotency is claimed.

If a user-facing workflow changed and smoke infrastructure exists, run the relevant smoke/e2e command and report exact command and result.

## Step 7 - Agent Process Cleanup

Stop only long-lived PIDs started by this agent:

```powershell
.\tools\agent\Stop-AgentOwnedProcesses.ps1 -IncludeDescendants
```

After agent-run .NET build/test/EF commands, run:

```powershell
dotnet build-server shutdown
```

Never kill every `dotnet`, `node`, `npm`, `testhost`, or `VBCSCompiler` process by name.

## Final Report

| Gate | Status | Notes |
| --- | --- | --- |
| .md file updated |  |  |
| Backend build |  |  |
| Backend tests |  |  |
| Frontend type check |  |  |
| Frontend build |  |  |
| Migrations applied |  |  |
| API client synced |  |  |
| Seed validation |  |  |
| Smoke/e2e |  |  |
| Process cleanup |  |  |
