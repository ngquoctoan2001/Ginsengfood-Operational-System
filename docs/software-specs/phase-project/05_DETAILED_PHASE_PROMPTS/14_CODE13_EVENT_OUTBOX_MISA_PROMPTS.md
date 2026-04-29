# 14 - CODE13 Event + Outbox + MISA Prompts

## Scope

Phase `CODE13` covers event schema registry, outbox, event compatibility, MISA adapter, retry and reconcile.

## Prompt 14.01 - CODE13 Kickoff Audit

```text
Role: Event/MISA Audit Agent.
Mission: Audit event/outbox/MISA implementation. Do not edit files.
Read first: modules/01_FOUNDATION_CORE.md, modules/14_MISA_INTEGRATION.md, workflows/03_SEQUENCE_DIAGRAMS.md, data/event_schema_registry.csv.
Rules: business modules emit events; MISA integration layer syncs; no module syncs directly to MISA.
Đầu ra: producer/consumer gap map, direct sync violations, first gap, cập nhật tiến độ.
```

## Prompt 14.02 - Event Schema Registry Plan

```text
Role: Event Architect.
Mission: Plan event schema registry and compatibility rules.
Workflow: define event names, versions, producer, consumer, payload reference, compatibility gate, tests.
Đầu ra: schema registry plan, seed impact, cập nhật tiến độ.
```

## Prompt 14.03 - Outbox Implementation

```text
Role: Outbox Backend Agent.
Mission: Implement outbox creation, delivery states and retry base.
Rules: transactional with business action where needed; append-only event history; no direct external call inside business transaction.
Đầu ra: DB/service/worker/tests, cập nhật tiến độ.
```

## Prompt 14.04 - MISA Adapter Retry/Reconcile

```text
Role: MISA Integration Agent.
Mission: Implement MISA mapping, sync event/log, retry 3 times and reconcile flow.
Rules: MISA AMIS/SME mapping must be configurable; failures visible; reconcile audited.
Đầu ra: adapter/worker/API/UI/tests, cập nhật tiến độ.
```

## Prompt 14.05 - Event/MISA Monitor UI

```text
Role: Frontend Integration Agent.
Mission: Implement outbox/MISA monitor UI.
Đầu ra: sync queue, retry/reconcile action, failure detail, permission checks, tests, cập nhật tiến độ.
```

## Prompt 14.06 - CODE13 Review/Validate/Handoff

```text
Role: Reviewer Agent.
Mission: Validate event/outbox/MISA.
Tests: event produced once; retry/reconcile; mapping missing failure; no direct module-to-MISA sync; compatibility/version check.
Đầu ra: verdict, commands, cập nhật tiến độ.
```

