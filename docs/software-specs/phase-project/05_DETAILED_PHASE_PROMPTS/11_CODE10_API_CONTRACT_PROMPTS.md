# 11 - CODE10 API Contract Prompts

## Scope

Phase `CODE10` covers API convention, error contract, auth/permission middleware, idempotency, pagination/filter/sort and API/FE sync.

## Prompt 11.01 - CODE10 API Contract Audit

```text
Role: API Contract Audit Agent.
Mission: Audit API implementation against api specs. Do not edit files.
Read first: api/01_API_CONVENTION.md through api/08_OPENAPI_GENERATION_GUIDE.md, modules/01_FOUNDATION_CORE.md, frontend API client.
Rules: do not create parallel route families; map current route impact before changing routes.
Output: route/DTO/error/idempotency/pagination drift report, first gap, progress update.
```

## Prompt 11.02 - Error Envelope And Status Code Implementation

```text
Role: API Error Contract Agent.
Mission: Implement/repair API error envelope and status conventions.
Rules: consistent error code, message, details, trace/correlation id where specified; no internal leakage.
Workflow: update middleware/helpers/DTO/tests/frontend error handling if affected.
Output: API/FE sync evidence, tests, progress update.
```

## Prompt 11.03 - Idempotency Middleware

```text
Role: API Idempotency Agent.
Mission: Implement idempotency_registry and middleware for side-effect endpoints.
Rules: command replay returns safe response; duplicate side effects blocked; registry name aligns with specs.
Output: DB/backend/API tests, endpoint list, progress update.
```

## Prompt 11.04 - Pagination Filter Sort Contract

```text
Role: API Query Contract Agent.
Mission: Implement pagination/filter/sort contract.
Rules: consistent meta shape; validation errors follow error contract; frontend client updated.
Output: API helpers, route updates, frontend client/types, tests, progress update.
```

## Prompt 11.05 - OpenAPI And Frontend Sync

```text
Role: API/Frontend Sync Agent.
Mission: Ensure API docs/OpenAPI/client/types/screens are synchronized.
Workflow: map endpoints to callers, update types/hooks, run typecheck/build, record no-impact evidence where no caller exists.
Output: sync report, changed files, tests, progress update.
```

## Prompt 11.06 - CODE10 Review/Validate/Handoff

```text
Role: API Reviewer Agent.
Mission: Validate CODE10 API contract.
Check: routes, errors, auth, permission, idempotency, pagination, FE sync, OpenAPI.
Output: ACCEPT/NEEDS_FIX/REJECT, findings, commands, progress update.
```

