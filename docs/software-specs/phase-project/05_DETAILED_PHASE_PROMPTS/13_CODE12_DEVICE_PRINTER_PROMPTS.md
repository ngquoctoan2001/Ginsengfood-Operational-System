# 13 - CODE12 Device + Printer Prompts

## Scope

Phase `CODE12` covers printer/device adapter boundary, heartbeat, callback logs and incident bridge.

## Prompt 13.01 - CODE12 Kickoff Audit

```text
Role: Device/Printer Audit Agent.
Mission: Audit printer/device implementation. Do not edit files.
Read first: modules/10_PACKAGING_PRINTING.md, modules/14_MISA_INTEGRATION.md, modules/15_REPORTING_DASHBOARD.md, non-functional/06_OBSERVABILITY_REQUIREMENTS.md.
Owner blocker: OD-17 printer model/driver.
Output: device boundary gap map, direct DB bypass risk, blocker list, progress update.
```

## Prompt 13.02 - Printer Adapter Boundary Plan

```text
Role: Printer Boundary Planner.
Mission: Plan printer adapter boundary without locking unapproved driver details.
Rules: API/adapter only; no direct DB/device bypass; driver-specific work blocked by OD-17 if open.
Output: adapter contract, callback/log model, tests, progress update.
```

## Prompt 13.03 - Print Callback And Heartbeat Implementation

```text
Role: Device Backend Agent.
Mission: Implement device heartbeat/callback logs and incident bridge.
Rules: callback authenticated where possible; failures audited; no direct release/QC/inventory side effects.
Output: API/service/tests, progress update.
```

## Prompt 13.04 - Device Console UI

```text
Role: Frontend Device Agent.
Mission: Implement device/printer console and failure visibility.
Output: device list, heartbeat status, print failure logs, retry/reprint links, tests, progress update.
```

## Prompt 13.05 - CODE12 Review/Validate/Handoff

```text
Role: Reviewer Agent.
Mission: Validate device/printer boundary.
Tests: no direct DB bypass; callback logged; heartbeat stale alert; OD-17 production driver blocker recorded if unresolved.
Output: verdict, blockers, progress update.
```

