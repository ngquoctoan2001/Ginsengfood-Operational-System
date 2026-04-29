---
description: "Add a new EF Core migration and apply it when backend/database scaffold exists."
mode: agent
---

# Add Migration And Update Database

For Ginsengfood V2 schema work, read `AGENTS.md`, `CLAUDE.md`, and the relevant files from `docs/software-specs/` before creating the migration.

The repository is greenfield. If EF infrastructure is not scaffolded yet, first create or request the backend/database scaffold phase instead of pretending a migration project exists.

## Response Language

Tra loi bang tieng Viet cho migration plan, risk, validation, blocker va report. Giu nguyen tieng Anh cho migration names, EF Core commands, SQL/table/column names, file paths va exact errors.

## Input

- Migration name: `$MIGRATION_NAME`
- Module: `$MODULE_NAME`

## Step 1 - Resolve Module Path

If backend scaffold exists, map `$MODULE_NAME` to the correct Infrastructure project path.

If backend scaffold does not exist, report:

```text
Migration status: N/A - backend/EF scaffold not created yet
Required next step: scaffold backend/database baseline from docs/software-specs/database/
```

## Step 2 - Add Migration

After scaffold exists:

```powershell
dotnet ef migrations add $MIGRATION_NAME --project <resolved-path> --startup-project <startup-project>
```

## Step 3 - Review Generated Migration

Verify:

- `Up()` makes the intended change.
- `Down()` correctly reverts the change.
- No unintended table drops or data loss.
- G0 is not introduced as an active operational formula.
- Formula/version tables support approval, activation, audit, retirement, and immutable snapshots where formula behavior is in scope.
- Recipe groups, seed constraints, public trace fields, QR lifecycle, MISA mapping, release gates, inventory ledger, and route-contract impacts are mapped when relevant.

## Step 4 - Apply To Database

```powershell
dotnet ef database update --project <resolved-path> --startup-project <startup-project>
```

## Step 5 - Verify

```powershell
dotnet ef migrations list --no-build --project <resolved-path> --startup-project <startup-project>
```

## Step 6 - Backend Build Check

```powershell
dotnet build --no-incremental -warnaserror
```

## Step 7 - Process Cleanup

Run `dotnet build-server shutdown` after agent-run .NET build/test/EF commands. Stop only tracked agent-owned PIDs.

## Report

```markdown
Migration da them:
Module:
Lenh apply:
Trang thai migration:
Pending sau khi apply:
Ket qua build:
Ket qua cleanup process:
```
