# 09 - CODE08 Recall Prompts

## Scope

Phase `CODE08` covers incident, recall case, impact snapshot, hold, sale lock, recovery, disposition, CAPA and close gate.

## Prompt 09.01 - CODE08 Kickoff Audit

```text
Role: Recall Audit Agent.
Mission: Audit recall implementation. Do not edit files.
Read first: modules/13_RECALL.md, workflows/07_EXCEPTION_FLOWS.md, api, database, ui, testing.
Hard locks: use recall_case/op_recall_case model, not recall_plan unless explicitly justified; recall uses trace snapshot, not duplicate trace truth; business SLA is 4h detection to batch lock + notification.
Output: gap map, model drift report, first gap, progress update.
```

## Prompt 09.02 - Recall Case Impact Snapshot Plan

```text
Role: Recall Planner.
Mission: Plan recall case and impact snapshot.
Workflow: define incident -> recall case -> affected batch -> exposure snapshot -> hold/sale lock -> recovery/disposition -> CAPA -> close.
Output: DB/API/UI/test plan, external notification reference handling, progress update.
```

## Prompt 09.03 - Recall Case Backend/API

```text
Role: Recall Backend/API Agent.
Mission: Implement recall case and impact snapshot.
Rules:
- Use trace/exposure snapshot at recall time.
- Notification jobs are external references only.
- All actions audited/timeline logged.
Output: service/API/model/tests, progress update.
```

## Prompt 09.04 - Hold And Sale Lock

```text
Role: Recall Hold Agent.
Mission: Implement batch hold and sale lock actions.
Rules:
- Hold/sale lock must be fast and auditable.
- Inventory and order/shipment external references must remain boundaries.
- Recall SLA target: within 4h from detection to batch lock + notification.
Output: commands/API/tests, SLA evidence note, progress update.
```

## Prompt 09.05 - Recovery, Disposition, CAPA, Close

```text
Role: Recall Recovery Agent.
Mission: Implement recovery/disposition/CAPA and close/close-with-residual-risk.
Rules:
- Close requires required recovery/disposition/CAPA evidence or accepted residual risk.
- Append timeline, do not rewrite history.
Output: workflow, API/UI/tests, progress update.
```

## Prompt 09.06 - Recall Admin UI

```text
Role: Frontend Recall Agent.
Mission: Implement incident/recall case management UI.
Rules: show impact snapshot, hold/sale lock, recovery, disposition, CAPA, timeline and close gate.
Output: UI/API client/tests, progress update.
```

## Prompt 09.07 - CODE08 Review/Validate/Handoff

```text
Role: QA + Reviewer Agent.
Mission: Validate recall workflow.
Required tests: trace impact snapshot; hold and sale lock; recovery/disposition; close blocked without evidence; close-with-residual-risk audited; no duplicate trace truth.
Output: verdict, smoke evidence, progress update.
```

