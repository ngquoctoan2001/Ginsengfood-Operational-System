# Local Dev Environment Policy

## Purpose

This policy defines local-only setup for the Ginsengfood Operational V2 scaffold. It does not define production secrets, production reset behavior or production deployment.

## Prerequisites

| Tool | Required use | Check command |
|---|---|---|
| .NET SDK 10.x | Backend/API/worker build, tests and EF migration commands | `dotnet --version` |
| Node.js + npm | Next.js apps and workspace scripts | `node --version`, `npm --version` |
| PostgreSQL local instance | Local database, migrations, seed and seed validation | `psql --version` |
| PowerShell | Local wrapper scripts in `tools/` | `$PSVersionTable.PSVersion` |
| Git | Source control and dirty-worktree checks | `git status --short` |

## Local Setup Steps

1. Copy `.env.example` to `.env.local`.
2. Replace every `__set_in_user_env_or_secret_store__` value in `.env.local` with local-only values.
3. Keep `APP_ENV=local` and `POSTGRES_DB=ginsengfood_operational_local` for local scripts.
4. Run `npm run local:check`.
5. Run `npm install` if dependencies are missing.
6. Run `npm run db:init` after PostgreSQL is running.
7. Run `npm run db:update` after migrations exist.
8. Run `npm run db:seed` after seed scripts exist.
9. Run `npm run db:seed:validate` after validation SQL/scripts exist.

## Env Variable Matrix

| Variable | Scope | Example | Secret | Rule |
|---|---|---|---|---|
| `APP_ENV` | Backend/scripts | `local` | No | Must be `local` for local DB scripts. |
| `ASPNETCORE_ENVIRONMENT` | Backend | `Development` | No | Local development only. |
| `NODE_ENV` | Frontend | `development` | No | Local frontend mode. |
| `NEXT_PUBLIC_APP_ENV` | Frontend public | `local` | No | Public-safe value. |
| `ADMIN_WEB_URL` | Frontend/backend config | `http://localhost:3000` | No | Local URL only. |
| `SHOPFLOOR_PWA_URL` | Frontend/backend config | `http://localhost:3001` | No | Local URL only. |
| `PUBLIC_TRACE_BASE_URL` | Frontend/backend config | `http://localhost:3002` | No | Local URL only. |
| `OPERATIONAL_API_URL` | Frontend/server config | `http://localhost:5000` | No | Internal local API URL. |
| `NEXT_PUBLIC_OPERATIONAL_API_URL` | Browser public | `http://localhost:5000` | No | Must not contain secrets. |
| `DATABASE_PROVIDER` | Backend/scripts | `postgresql` | No | Approved local database provider. |
| `POSTGRES_HOST` | DB/scripts | `localhost` | No | Local scripts reject non-local hosts. |
| `POSTGRES_PORT` | DB/scripts | `5432` | No | Local PostgreSQL port. |
| `POSTGRES_DB` | DB/scripts | `ginsengfood_operational_local` | No | Must contain local marker for reset. |
| `POSTGRES_USER` | DB/scripts | `ginsengfood_local` | No | Local database user. |
| `POSTGRES_PASSWORD` | DB/scripts | placeholder | Yes | Never commit real value. |
| `DATABASE_URL` | Backend/scripts | local placeholder URL | Yes | Keep real value in `.env.local` only. |
| `LOCAL_RESET_ALLOWED` | DB/scripts | `true` | No | Required for local reset script. |
| `SEED_ENV` | Seed scripts | `local` | No | Seed scripts reject production context. |
| `SEED_INCLUDE_FIXTURES` | Seed scripts | `true` | No | Allows dev/test/smoke fixtures locally. |
| `SEED_FIXTURE_TAG` | Seed scripts | `DEV_TEST_SMOKE_ONLY` | No | Fixture visibility guard. |
| `JWT_SIGNING_KEY` | Backend auth | placeholder | Yes | Local secret only. |
| `COOKIE_SECRET` | Backend auth | placeholder | Yes | Local secret only. |
| `EVIDENCE_STORAGE_PROVIDER` | Backend/storage | `local-filesystem` | No | Local/dev/test evidence binary storage provider. Production will use company storage server config. |
| `EVIDENCE_STORAGE_LOCAL_ROOT` | Backend/storage | `./.local/evidence` | No | Local-only root for source-origin/CAPA evidence files; must not be committed. |
| `EVIDENCE_STORAGE_BASE_URI` | Backend/storage | `local://evidence` | No | Logical URI prefix stored in DB metadata for local/dev/test. |
| `EVIDENCE_SCAN_MODE` | Backend/storage | `dev-skip` or `mock-clean` | No | Local/dev/test only; production must use real AV/malware scanner. |
| `EVIDENCE_COMPANY_STORAGE_ENDPOINT` | Backend/storage | placeholder | Yes | Production company storage server endpoint/path, supplied by DevOps outside git. |
| `MISA_MODE` | Integration | `dry-run` | No | Local must not call real MISA. |
| `MISA_BASE_URL` | Integration | local placeholder | No | Dry-run endpoint only until approved. |
| `MISA_TENANT_ID` | Integration | fake local tenant | No | Fake local identifier only. |
| `MISA_CLIENT_ID` | Integration | placeholder | Yes | Never commit real value. |
| `MISA_CLIENT_SECRET` | Integration | placeholder | Yes | Never commit real value. |
| `PRINTER_ADAPTER_MODE` | Device adapter | `fake` | No | No real printer binding in local scaffold. |
| `PRINTER_DEVICE_TOKEN` | Device adapter | placeholder | Yes | Never commit real value. |

## Secret Policy

- Real secrets must not be committed, seeded, logged or placed in `.env.example`.
- `.env.local`, `.env`, `.env.*` and local secret files remain gitignored.
- `MISA_MODE=dry-run` is the only approved local MISA mode until production tenant/credential delivery is approved.
- Seed files may contain secret references, not literal secret values.
- Public/browser variables prefixed with `NEXT_PUBLIC_` must never contain secret values.
- Production evidence storage server endpoint/credentials must not be committed. `.env.example` keeps placeholders only.

## Local Evidence Storage Flow

1. Keep `EVIDENCE_STORAGE_PROVIDER=local-filesystem` for local/dev/test.
2. Store temporary source-origin/CAPA evidence under `EVIDENCE_STORAGE_LOCAL_ROOT`.
3. Keep uploaded binary files out of git; only DB metadata and tests may reference logical `local://...` refs.
4. Production switches provider/config to the company storage server without changing API/DTO/schema contracts.
5. Local/dev/test may use mock/dev-skip scanner mode to produce `scan_status = CLEAN`; production verify/close gates require a real scanner result with `scan_status = CLEAN`.

## Local Database Flow

1. Start local PostgreSQL.
2. Confirm `.env.local` has `APP_ENV=local`, `POSTGRES_HOST=localhost` or `127.0.0.1`, and a database name with a local marker.
3. Run `npm run db:init` to create the local DB if PostgreSQL CLI tools are available.
4. Run `npm run db:update` after EF migrations are introduced.
5. Migration commands are N/A until migration files exist.

## Seed And Validation Flow

1. Canonical seed SQL/scripts belong in `db/seeds/`.
2. Dev/test/smoke-only fixture data belongs in `db/fixtures/`.
3. Seed validation SQL/scripts belong in `db/validation/`.
4. Run `npm run db:seed` for local seed scripts.
5. Run `npm run db:seed:validate` after seed validation scripts exist.
6. Production seed must never include local fixture data unless an approved release process explicitly creates production-safe seed data.

## Safe Local Reset

Use `npm run db:reset:local` only for disposable local databases.

The reset script must reject:

- missing `-ConfirmLocalReset`;
- `APP_ENV` not equal to `local`;
- non-local database hosts;
- database names without a local marker;
- missing `LOCAL_RESET_ALLOWED=true`.

No production reset command is defined in this repository.
