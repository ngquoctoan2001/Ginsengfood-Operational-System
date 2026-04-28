# 16 - CODE15 Override Governance Prompts

## Scope

Phase `CODE15` covers manual override, break-glass, reason, approval and audit governance.

## Prompt 16.01 - CODE15 Kickoff Audit

```text
Role: Override/Security Audit Agent.
Mission: Audit override/break-glass implementation. Do not edit files.
Read first: modules/01_FOUNDATION_CORE.md, modules/02_AUTH_PERMISSION.md, non-functional/03_SECURITY_REQUIREMENTS.md, business/05_APPROVAL_AND_AUDIT_RULES.md.
Rules: override cannot silently mutate append-only records; must be permissioned, reasoned and audited.
Output: override gap map, policy blockers, first gap, progress update.
```

## Prompt 16.02 - Override Policy Plan

```text
Role: Security Planner.
Mission: Plan override request/action model.
Workflow: define eligible actions, reason, approval, audit, expiry, emergency access, review queue.
Output: policy plan, DB/API/UI/test scope, owner decisions if needed, progress update.
```

## Prompt 16.03 - Override Backend/API

```text
Role: Override Backend Agent.
Mission: Implement override request/action/audit.
Rules: no direct mutation of append-only ledger/audit/history; override creates compensating/action record where applicable.
Output: service/API/tests, progress update.
```

## Prompt 16.04 - Override UI

```text
Role: Frontend Override Agent.
Mission: Implement override request/review queue UI.
Rules: show reason, risk, target record, approver, audit trail.
Output: UI/API client/tests, progress update.
```

## Prompt 16.05 - CODE15 Review/Validate/Handoff

```text
Role: Security Reviewer.
Mission: Validate override governance.
Tests: unauthorized blocked; reason required; audit written; append-only protected; break-glass report visible.
Output: verdict, progress update.
```

