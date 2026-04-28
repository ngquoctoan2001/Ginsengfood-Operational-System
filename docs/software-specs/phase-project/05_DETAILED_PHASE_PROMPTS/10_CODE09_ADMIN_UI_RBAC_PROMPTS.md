# 10 - CODE09 Admin UI + RBAC Prompts

## Scope

Phase `CODE09` covers admin UI registry, menu/sidebar, screen/action registry, role/action permission and permission-aware UI behavior.

## Prompt 10.01 - CODE09 Kickoff Audit

```text
Role: Admin UI/RBAC Audit Agent.
Mission: Audit UI registry and RBAC implementation. Do not edit files.
Read first: modules/02_AUTH_PERMISSION.md, modules/16_ADMIN_UI.md, ui/, api/05_API_AUTH_PERMISSION_SPEC.md, data/roles_permissions.csv.
Rules: backend permission is authority; UI hiding is not security.
Output: gap map, role drift report, first gap, progress update.
```

## Prompt 10.02 - Screen/Action Registry Plan

```text
Role: UI Registry Planner.
Mission: Plan screen/action/menu registry and permission mapping.
Workflow: map M01-M16 screens to routes/actions/roles, identify missing roles such as R-RD/R-PD-LEAD if used, decide whether to add role or replace with approved role.
Output: registry plan, role decision list, seed/API/UI/test scope, progress update.
```

## Prompt 10.03 - RBAC Backend/API

```text
Role: RBAC Backend/API Agent.
Mission: Implement role/action permission backend and API.
Rules:
- Backend enforces all privileged action permissions.
- One person can have multiple roles; do not merge logical roles silently.
- Permission changes audited.
Output: service/API/seed/tests, progress update.
```

## Prompt 10.04 - Admin Shell/UI Registry

```text
Role: Frontend Admin Shell Agent.
Mission: Implement menu/sidebar, screen registry, action registry and permission-aware UI.
Rules:
- Show hidden/disabled/unauthorized states consistently.
- Do not expose actions not allowed by backend.
Output: UI files, API client/types, UI tests, progress update.
```

## Prompt 10.05 - CODE09 Review/Validate/Handoff

```text
Role: QA + Security Reviewer.
Mission: Validate admin UI/RBAC.
Tests: unauthorized action blocked backend-side; menu hides unauthorized screens; direct API call denied; role seed idempotent; role names align with business role matrix.
Output: verdict, findings, progress update.
```

