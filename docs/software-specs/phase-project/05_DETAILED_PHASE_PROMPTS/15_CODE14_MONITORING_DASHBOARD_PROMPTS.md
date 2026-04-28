# 15 - CODE14 Monitoring + Dashboard Prompts

## Scope

Phase `CODE14` covers health snapshot, alert rules, alert events, dashboard metrics and incident response visibility.

## Prompt 15.01 - CODE14 Kickoff Audit

```text
Role: Observability Audit Agent.
Mission: Audit monitoring/dashboard readiness. Do not edit files.
Read first: modules/15_REPORTING_DASHBOARD.md, non-functional/06_OBSERVABILITY_REQUIREMENTS.md, non-functional/01_NON_FUNCTIONAL_REQUIREMENTS.md.
Rules: tooling names such as Prometheus/Grafana/OpenTelemetry are assumptions unless approved; critical operational failures must be visible.
Output: observability gap map, tooling assumptions, first gap, progress update.
```

## Prompt 15.02 - Alert Rule And Health Plan

```text
Role: Monitoring Planner.
Mission: Plan alert rules and health snapshots.
Examples: MISA sync fail, printer fail, recall SLA risk, inventory ledger anomaly, failed outbox retry.
Output: metric/alert/API/UI/test plan, progress update.
```

## Prompt 15.03 - Monitoring Backend/API

```text
Role: Monitoring Backend Agent.
Mission: Implement alert events, health snapshots and dashboard metric API.
Output: DB/service/API/tests, progress update.
```

## Prompt 15.04 - Dashboard UI

```text
Role: Dashboard Frontend Agent.
Mission: Implement operational dashboard and alert views.
Rules: dashboard should be utilitarian, dense, scan-friendly, not marketing style.
Output: UI/API client/tests, progress update.
```

## Prompt 15.05 - CODE14 Review/Validate/Handoff

```text
Role: QA/Reviewer Agent.
Mission: Validate monitoring/dashboard.
Tests: alert created for critical failures; health endpoint accurate; dashboard shows critical items; assumptions labelled.
Output: verdict, progress update.
```

