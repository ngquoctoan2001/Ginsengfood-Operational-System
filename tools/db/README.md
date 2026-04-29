# DB Tools

Local-only database, migration, seed and validation wrappers live here.

Current commands:

- `npm run db:init`: create the guarded local PostgreSQL database if needed.
- `npm run db:update`: apply EF migrations after migration files exist.
- `npm run db:seed`: apply local seed SQL from `db/seeds/`.
- `npm run db:seed:fixtures`: apply local seed SQL plus dev/test/smoke fixtures.
- `npm run db:seed:validate`: run seed validation SQL from `db/validation/`.
- `npm run db:reset:local`: guarded local-only drop/recreate.

Safety rules:

- All DB scripts require `APP_ENV=local`.
- Reset requires `LOCAL_RESET_ALLOWED=true`, a local host and a database name with a local marker.
- No production reset command exists.
