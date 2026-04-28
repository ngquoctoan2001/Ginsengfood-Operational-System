---
description: "Use when creating or changing backend API routes, controllers, DTOs, enums, error shapes, validation rules, or OpenAPI spec."
---

# Backend / Frontend API Contract Sync

For initial Ginsengfood V2 scaffold, derive API routes and DTOs from `docs/software-specs/api/` and document intended frontend/admin consumers.

After route code exists, map current routes/controllers/handlers and consumers before changing or adding route families. Do not create duplicate route families from documents.

## When This Applies

This instruction activates whenever you:

- add, rename, or remove a controller action or route;
- add, rename, or remove DTO properties;
- add or modify enums used in API responses/requests;
- change validation rules;
- change error response shapes or status codes;
- add, remove, or modify query parameters or route parameters;
- change OpenAPI operation IDs.

For Operational V2 endpoints, also check formula versioning, production snapshot fields, material issue/receipt state, QC vs release state, warehouse ledger effects, QR lifecycle, public trace exposure, MISA mapping, role permissions, and audit/event behavior where relevant.

## Sync Workflow

### Step 1 - Backend Contract

Ensure the backend compiles when backend exists:

```powershell
dotnet build --no-incremental -warnaserror
```

If backend is not scaffolded, report `N/A - not scaffolded yet`.

### Step 2 - Frontend API Client

If frontend exists, regenerate or update the API client:

```powershell
npm run gen:api
npx tsc -b --noEmit
```

If frontend is not scaffolded, report `Frontend impact: N/A - not scaffolded yet` and document the intended future consumer.

### Step 3 - Update Affected Areas

| Change | Frontend areas to update |
| --- | --- |
| New endpoint | Add query hook in the relevant feature API folder |
| Renamed DTO field | Update table columns, form defaults, display components |
| New required field | Update form schema and default values |
| Removed field | Remove from tables, forms, display components |
| New enum value | Update switch/case, select options, badge colors |
| Changed error shape | Update mutation error handling |
| Changed status code | Update API/e2e expectations |

### Step 4 - Run Frontend Build

```powershell
npm run build
```

Run only when frontend exists and changed.

### Step 5 - Process Cleanup

If OpenAPI generation or e2e required a running backend/frontend server, stop only PIDs started by this agent before final response. Run `dotnet build-server shutdown` after agent-run .NET commands.

## Explicit No Frontend Impact Evidence

If frontend exists and you claim no frontend impact, provide evidence:

- endpoint is not included in OpenAPI;
- DTO is only used internally;
- enum is backend-only and not in response DTOs;
- no existing frontend feature references this endpoint.

If frontend does not exist, say `Frontend impact: N/A - not scaffolded yet`.
