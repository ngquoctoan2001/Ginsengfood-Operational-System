---
description: "Use when adding, modifying, or removing EF Core database migrations. Greenfield-aware: scaffold EF first when migration infrastructure does not exist."
---

# EF Core Migration Rules

For Ginsengfood V2 schema/seed work, read `AGENTS.md`, `CLAUDE.md`, and the relevant Markdown files from `docs/software-specs/` first.

The repository is greenfield. If backend/EF infrastructure does not exist, do not run migration commands against imaginary paths. Plan or implement the backend/database scaffold phase first.

## Source Rules

- `docs/software-specs/` is the source of truth.
- `.tmp-docx-extract/`, `specs/`, old extracts, historical migrations, and old seed SQL are historical reference only.
- Preserve G1 as the go-live baseline while supporting future approved G2/G3 versions through immutable snapshots, approval, activation, audit, and retirement.

## Apply After Adding

After EF infrastructure exists, never add a migration without applying it to the local/dev/test database unless the environment blocks it and the blocker is reported.

```powershell
dotnet ef migrations add <DescriptiveName> --project <module-infrastructure-project> --startup-project <startup-project>
dotnet ef database update --project <module-infrastructure-project> --startup-project <startup-project>
dotnet ef migrations list --no-build --project <module-infrastructure-project> --startup-project <startup-project>
```

## Module Mapping

Do not assume module paths before scaffold. Add module path mappings when the backend solution is created.

## Migration Naming Convention

Use PascalCase descriptive names:

| Change type | Name pattern | Example |
| --- | --- | --- |
| Add table | `Add<Entity>` | `AddBatch` |
| Add column | `Add<Column>To<Table>` | `AddQcStatusToBatch` |
| Rename column | `Rename<Old>To<New>In<Table>` | `RenameBatchCodeToBatchNoInBatch` |
| Add index | `AddIndexOn<Column>In<Table>` | `AddIndexOnBatchNoInBatch` |
| Drop column | `Drop<Column>From<Table>` | `DropLegacyCodeFromBatch` |
| Seed data | `Seed<Resource>` | `SeedDefaultRoles` |

## Data Safety Checklist

Before applying:

- [ ] `Up()` method reviewed.
- [ ] `Down()` method present and correct.
- [ ] No accidental data loss.
- [ ] Nullable-to-not-null changes handle existing rows when data exists.
- [ ] Index additions account for duplicates when data exists.
- [ ] Foreign key delete behavior is intentional.
- [ ] No active operational G0 formula/seed path is introduced.
- [ ] Formula/version changes preserve immutable production snapshots.
- [ ] Route, DTO/OpenAPI, frontend, seed, and validation impacts are mapped when the schema change crosses layers.

## Anti-Patterns

- Dropping and recreating a column in one migration after data exists.
- Adding a `NOT NULL` column without default/backfill when rows exist.
- Empty `Down()` method.
- Committing a migration without applying it to dev/local DB unless blocked and reported.
- Running migrations with `--force` without knowing why.

## Process Cleanup

After agent-run `dotnet ef`, `dotnet build`, or `dotnet test` commands, run `dotnet build-server shutdown` before final response. Stop only tracked agent-owned PIDs.

## Response Requirements

```text
Migration added:
Command run:
Migration status:
Pending after:
Process cleanup result:
```
