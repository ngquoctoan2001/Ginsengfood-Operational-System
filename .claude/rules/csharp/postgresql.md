---
paths:
  - "**/*.cs"
  - "**/*.csx"
  - "**/appsettings*.json"
  - "**/*.csproj"
---

# PostgreSQL 18 + EF Core Guidelines

> This file covers PostgreSQL 18-specific conventions for the backend stack.
> Extends [common/coding-style.md](../common/coding-style.md) and [csharp/coding-style.md](./coding-style.md).

## Driver and Packages

- Use `Npgsql.EntityFrameworkCore.PostgreSQL` as the EF Core provider.
- Use `Npgsql` directly only for bulk operations or raw SQL paths where EF is insufficient.
- Do not mix Dapper and EF Core on the same `DbContext` transaction boundary.

## Connection String

- Read from environment / configuration only. Never hardcode.
- Local dev format (user secrets): `Host=localhost;Database=ginsengfood_dev;Username=app;Password=...`
- SSL in production: append `;SslMode=Require;Trust Server Certificate=false`
- User secrets: `dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=..."`
- CI/Production: environment variable `ConnectionStrings__DefaultConnection`

## Data Type Mapping — PostgreSQL 18

| Domain type        | PostgreSQL type | C# type                       | EF config note                                                        |
| ------------------ | --------------- | ----------------------------- | --------------------------------------------------------------------- |
| Primary key        | `uuid`          | `Guid`                        | `.ValueGeneratedNever()` — client-generated only                      |
| Audit timestamp    | `timestamptz`   | `DateTimeOffset`              | `.HasColumnType("timestamptz")` — never naked `timestamp`             |
| Long text          | `text`          | `string`                      | Prefer `text` over `varchar(n)` unless length is a hard business rule |
| Money / quantity   | `numeric(p,s)`  | `decimal`                     | Set `.HasColumnType("numeric(18,4)")` explicitly                      |
| JSON document      | `jsonb`         | `JsonDocument` / value object | Use `jsonb` for indexable JSON; `json` only for raw string round-trip |
| Enum discriminator | `text`          | `string` + value converter    | Store as `text` for readability; avoid raw `int` enum columns         |
| Boolean            | `boolean`       | `bool`                        | Maps directly                                                         |
| Large object       | `bytea`         | `byte[]`                      | For small blobs only; use object storage for files                    |

## EF Core Entity Configuration

```csharp
// In EntityTypeConfiguration<T>:
public void Configure(EntityTypeBuilder<Batch> builder)
{
    builder.HasKey(x => x.Id);
    builder.Property(x => x.Id).ValueGeneratedNever();    // client-side Guid

    builder.Property(x => x.CreatedAt)
           .HasColumnType("timestamptz")
           .HasDefaultValueSql("now()");

    builder.Property(x => x.UpdatedAt)
           .HasColumnType("timestamptz");

    builder.Property(x => x.Status)
           .HasConversion<string>()                        // enum → text
           .HasColumnType("text")
           .IsRequired();

    builder.Property(x => x.Notes)
           .HasColumnType("text");
}
```

## Migrations

- Always specify project and startup project flags explicitly:

  ```powershell
  dotnet ef migrations add <DescriptiveName> `
    --project src/Modules/<Module>/Infrastructure `
    --startup-project src/Api/Ginsengfood.Operational.Api

  dotnet ef database update `
    --project src/Modules/<Module>/Infrastructure `
    --startup-project src/Api/Ginsengfood.Operational.Api
  ```

- Review generated SQL (`Up()` and `Down()`) before applying — check for:
  - Unintended `DROP COLUMN` (data loss).
  - Missing `NOT NULL` default for existing rows.
  - Correct `timestamptz` / `uuid` types (not `timestamp` / `character varying`).
- Never use `dotnet ef database update` in production. Apply via:
  - Programmatic: `dbContext.Database.MigrateAsync()` at startup (acceptable for simple deployments).
  - Migration runner script for zero-downtime prod deployments.
- Always provide a reversible `Down()` unless it is the very first schema migration.

## Indexing

EF Core does **not** automatically create indexes on foreign keys — add them explicitly:

```csharp
// Required: every FK column needs an index
builder.HasIndex(x => x.BatchId);

// Composite index for common multi-column query patterns
builder.HasIndex(x => new { x.TenantId, x.Status });

// Partial index for filtered queries (use raw SQL in migration)
migrationBuilder.Sql(
    "CREATE INDEX idx_batch_active ON batches (status) WHERE status != 'ARCHIVED';"
);

// GIN index for JSONB columns (use raw SQL in migration)
migrationBuilder.Sql(
    "CREATE INDEX idx_batch_metadata ON batches USING GIN (metadata);"
);
```

**PostgreSQL 18 note:** The query planner now supports parallel index scans on B-tree indexes. Keep `work_mem` appropriately tuned for complex query plans.

## N+1 Prevention

```csharp
// CORRECT: projection to DTO, no entity graph exposed
var results = await ctx.Batches
    .Where(b => b.Status == BatchStatus.Released)
    .OrderByDescending(b => b.CreatedAt)
    .Select(b => new BatchSummaryDto(b.Id, b.BatchNo, b.CreatedAt))
    .ToListAsync(cancellationToken);

// WRONG: full entity + nav props loaded, then mapped in memory
var results = await ctx.Batches.Include(b => b.Lots).ToListAsync();
```

- Use `Include()` only for navigations that are always needed together.
- Use `AsSplitQuery()` when including multiple collection navigations to avoid cartesian explosion:
  ```csharp
  ctx.ProductionOrders
     .Include(o => o.RecipeLines)
     .Include(o => o.MaterialIssues)
     .AsSplitQuery()
  ```
- Use compiled queries for high-frequency hot paths:
  ```csharp
  private static readonly Func<AppDbContext, Guid, Task<Batch?>> GetBatchByIdQuery =
      EF.CompileAsyncQuery((AppDbContext ctx, Guid id) =>
          ctx.Batches.FirstOrDefault(b => b.Id == id));
  ```

## Connection Pooling

- Npgsql has built-in connection pooling — do not disable it.
- Production high-concurrency: use **PgBouncer** in transaction-pooling mode in front of the database.
- Set pool size in connection string when tuning: `;Maximum Pool Size=50;Minimum Pool Size=5`
- Use `await using` (or DI scoped `DbContext`) so connections are released promptly.
- Connection string per environment — never share dev/staging/prod strings.

## Query Patterns

```csharp
// CORRECT: async, CancellationToken, projection
public async Task<IReadOnlyList<BatchSummaryDto>> GetReleasedBatchesAsync(
    CancellationToken cancellationToken)
{
    return await _ctx.Batches
        .AsNoTracking()
        .Where(b => b.Status == BatchStatus.Released)
        .OrderByDescending(b => b.CreatedAt)
        .Select(b => new BatchSummaryDto(b.Id, b.BatchNo, b.CreatedAt))
        .ToListAsync(cancellationToken);
}

// WRONG: sync, no CT, tracker overhead, full entity
var batches = _ctx.Batches.ToList();
```

- Use `AsNoTracking()` for all read-only queries.
- Always pass `CancellationToken` through public async query methods.
- Never return domain entities directly from query methods — project to DTOs.

## PostgreSQL 18 Specific

- **`MERGE` statement**: natively supported — use for upsert operations in seed migrations.
- **Logical replication**: for read replicas and CDC. Use `pgoutput` plugin.
- **Partitioned tables**: consider range/list partitioning for large append-only tables (`audit_logs`, `inventory_transactions`).
- **`pg_stat_statements`**: enable in production to identify slow queries.
- **`VACUUM ANALYZE`**: run after bulk inserts/deletes (schedule as nightly maintenance job, not synchronously in code).
- **JSONB operators**: `@>`, `?`, `#>` — use through raw SQL or EF Core `EF.Functions.JsonContains()` (Npgsql extension methods).

## Security

- Create a dedicated application DB user with minimal required privileges — not a superuser.
- Use SSL in production: `SslMode=Require;Trust Server Certificate=false`
- Never log connection strings, passwords, or PII.
- Use row-level security (RLS) if multi-tenancy is enforced at the DB level.
- Enable `log_min_duration_statement` in staging to catch slow queries before production.
