---
description: "Use when writing, editing, or reviewing C# / .NET backend code after the backend scaffold exists."
applyTo: "**/*.cs"
---

# Backend C# / .NET Guidelines

## Response Language

Respond in Vietnamese for explanations, plans, reviews, and validation notes. Keep C#/.NET terms, code symbols, file paths, commands, package names, migration names, table/column names, and exact errors in English.

## Greenfield Note

The backend may not exist yet. If backend code is absent, first follow the active scaffold phase and `docs/software-specs/` before assuming solution paths, module names, EF project paths, or test folders.

## Clean Architecture Layer Rules

```text
Api/Controllers      -> thin: validate, dispatch, return
Application          -> use cases, commands, queries, orchestration
Domain               -> entities, value objects, invariants, domain events
Infrastructure       -> EF Core, SQL, external I/O
```

- Controllers must not contain business logic.
- Domain entities own their invariants.
- Queries return read-optimized DTOs; never expose domain entities directly via API.

## Entity Conventions

```csharp
public sealed class Batch
{
    private Batch() { }

    public Guid Id { get; private set; }
    public string BatchNo { get; private set; } = null!;

    public static Batch Create(string batchNo)
    {
        Guard.Against.NullOrWhiteSpace(batchNo);
        return new Batch { Id = Guid.NewGuid(), BatchNo = batchNo };
    }
}
```

- Use `Guid` PKs generated in the domain unless canonical specs require otherwise.
- Avoid public setters on domain entity properties.
- Use guard clauses for input validation inside domain code.

## EF Core Migration Rules

When EF infrastructure exists:

1. Add migration with explicit project flags.
2. Review generated `Up()` and `Down()`.
3. Apply the migration to local/dev/test DB unless the environment blocks it.
4. Verify pending status.
5. Run `dotnet build-server shutdown` after agent-run .NET commands.

If EF infrastructure is not scaffolded yet, report `N/A - not scaffolded yet` and implement or request the backend/database scaffold phase.

## Repository Pattern

```csharp
public interface IBatchRepository
{
    Task<Batch?> GetByIdAsync(Guid id, CancellationToken ct);
    void Add(Batch batch);
}
```

- Repository interfaces live in `Domain` or `Application`.
- Concrete implementations live in `Infrastructure`.
- Do not call `SaveChangesAsync` inside repositories unless the chosen architecture explicitly uses that pattern.

## API / OpenAPI Annotations

Every controller action should document expected responses and enforce authorization on state-changing endpoints.

Use `ProblemDetails` for API errors and global exception middleware. Never return raw exception messages to clients.

## Testing Requirements

- Every new command/query handler needs focused tests.
- Every new controller action needs API/integration coverage when test infrastructure exists.
- Test files should mirror the backend source structure after scaffold.

## Coding Constraints

- Keep methods small and readable.
- Split large classes by responsibility.
- Prefer early returns over deep nesting.
- No hardcoded connection strings, secrets, or base URLs.
- Prefer immutable DTOs/records where practical.
