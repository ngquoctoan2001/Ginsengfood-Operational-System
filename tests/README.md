# Tests

Test scaffold for the eight active validation groups.

Groups:

- `backend/`: .NET unit/component tests.
- `frontend/`: UI unit/component tests for admin, shopfloor and public trace apps.
- `api/`: API contract, endpoint behavior and error-shape tests.
- `integration/`: cross-layer backend/database/integration tests.
- `e2e/`: end-to-end workflow tests.
- `smoke/`: release smoke gates and happy-path checks.
- `seed-validation/`: seed idempotency, canonical data and fixture guard tests.
- `regression/`: bug/regression coverage retained across phases.

Current runnable commands:

- `dotnet test Ginsengfood.Operational.sln`
- `npm run test --workspaces --if-present`
