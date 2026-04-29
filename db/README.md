# Database Scaffold

PostgreSQL implementation area for migrations, canonical seeds, validation queries and projections.

Current scope:

- No migration has been created in this scaffold patch.
- Canonical seed source remains `docs/software-specs/data/`.
- Historical `docs/seeds/` files are not moved or converted in this patch.

Folders:

- `migrations/`: EF Core migration files once CODE01/database baseline starts.
- `seeds/`: canonical idempotent seed chain created from accepted specs.
- `fixtures/`: dev/test/smoke-only data such as fake GTIN, fake MISA mapping, source samples and batch smoke fixtures.
- `validation/`: SQL/scripts used to verify migrations and seed state.
- `projections/`: database projection notes/scripts for traceability, inventory and public trace views.
