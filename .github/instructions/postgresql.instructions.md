---
description: "Use when writing EF Core migrations, entity configurations, repository queries, or PostgreSQL database code."
applyTo: "**/*.cs"
---

# PostgreSQL + EF Core Guidelines

## Greenfield Note

The backend/database layer may not exist yet. If EF infrastructure is absent, do not assume project paths. Use the active scaffold phase and `docs/software-specs/database/` to create the first database structure.

## Driver

- Prefer `Npgsql.EntityFrameworkCore.PostgreSQL` for EF Core.
- Do not mix raw ADO.NET or Dapper with EF Core on the same transaction without explicit coordination.

## Connection String

- Read from configuration only; never hardcode.
- Never log connection strings or credentials.
- Non-local environments must require SSL unless the deployment spec says otherwise.

## Data Type Rules

| Domain concept | PostgreSQL column | C# type | EF config |
| --- | --- | --- | --- |
| Primary key | `uuid` | `Guid` | client-generated unless specs say otherwise |
| Timestamps | `timestamptz` | `DateTimeOffset` | explicit column type |
| Status / enum | `text` | enum + converter | readable string values |
| Decimal / money | `numeric(18,4)` or spec-defined precision | `decimal` | explicit column type |
| Free text | `text` | `string` | use length only for real business constraints |
| JSON document | `jsonb` | JSON type | use for indexed JSON |

## Migration Rules

After EF infrastructure exists:

1. Add migration with explicit project/startup flags.
2. Apply it to local/dev/test DB unless blocked.
3. Verify pending status.
4. Review SQL for data loss and wrong data types.
5. Provide a reversible `Down()` method.

If EF infrastructure does not exist, report `N/A - not scaffolded yet`.

## Indexing Checklist

- EF Core does not automatically index all query patterns.
- Add indexes for foreign keys and common filter/sort combinations.
- Use partial or GIN indexes only when justified by access patterns.
- Keep append-only audit/event/inventory tables queryable.

## Query Rules

- Use `AsNoTracking()` for read-only queries.
- Prefer projection to DTOs over loading entire entities.
- Avoid N+1 navigation access.
- Use split queries for multiple collection includes where appropriate.
- Validate filter and sort inputs before building dynamic queries.

## Security

- DB users must have minimum required privileges.
- Never log PII, secrets, or sensitive trace/recall data.
- Public trace queries must enforce field policy at the API/service boundary.
