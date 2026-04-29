# 12 - CODE11 PWA + Offline Prompts

## Scope

Phase `CODE11` covers PWA-first internal app contract, offline commands, device/session headers and replay idempotency.

## Prompt 12.01 - CODE11 Kickoff Audit

```text
Role: PWA/Offline Audit Agent.
Mission: Audit PWA/offline readiness. Do not edit files.
Read first: ui/, api/, non-functional/, modules/16_ADMIN_UI.md, modules/01_FOUNDATION_CORE.md.
Rules: PWA-first is mandatory; offline replay must be idempotent.
Đầu ra: offline gap map, first gap, cập nhật tiến độ.
```

## Prompt 12.02 - Offline Command Contract Plan

```text
Role: Offline Contract Planner.
Mission: Plan offline command envelope, device/session headers, conflict behavior and replay rules.
Đầu ra: API/FE/storage/test plan, non-goals, cập nhật tiến độ.
```

## Prompt 12.03 - Offline API/Backend Support

```text
Role: Offline Backend Agent.
Mission: Implement backend support for offline command replay.
Rules: idempotency key required; stale/duplicate commands handled predictably; audit records device/session where specified.
Đầu ra: middleware/API/tests, cập nhật tiến độ.
```

## Prompt 12.04 - PWA Frontend Implementation

```text
Role: PWA Frontend Agent.
Mission: Implement PWA/offline UX for approved shopfloor workflows.
Rules: show pending/synced/failed states; no duplicate submit; recoverable errors visible.
Đầu ra: frontend files, tests, build result, cập nhật tiến độ.
```

## Prompt 12.05 - CODE11 Review/Validate/Handoff

```text
Role: QA Agent.
Mission: Validate offline/PWA.
Tests: duplicate replay idempotent; offline queue survives refresh if required; failed command retry; permission/auth handling.
Đầu ra: verdict, commands, cập nhật tiến độ.
```

