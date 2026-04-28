# 05 - Validation Prompts

## 1. Validation Planner Prompt

```text
Create validation plan for gap {gap_id}.

Include:
- Backend build command.
- Backend tests.
- Frontend build command if FE touched.
- Frontend tests if FE touched.
- Migration apply/update command if DB touched.
- Seed command and validation if seed touched.
- API tests.
- UI tests.
- Integration/regression tests.
- E2E smoke subset.
- Process cleanup steps.
```

## 2. Migration Validation Prompt

```text
Validate database migration for gap {gap_id}.

Check:
- Applies to empty DB.
- Applies to existing QA/staging DB.
- FK/unique/check constraints work.
- `lot_status` enum/check constraint includes `READY_FOR_PRODUCTION` and does not use `QC_PASS` as lot readiness state.
- Append-only guard works.
- Validation query passes.
- Rollback/forward-fix note exists.
```

## 3. Seed Validation Prompt

```text
Validate seed for gap {gap_id}.

Run/check:
- Active baseline SKU count = 20.
- Required ingredients active.
- 4 recipe groups exist.
- Each baseline SKU has active G1 recipe.
- No active/approved operational formula uses the G0 formula version marker; G0 is not active operational seed data.
- `lot_status` seed/reference includes `READY_FOR_PRODUCTION`.
- Raw and finished-goods warehouses exist.
- Public trace denylist exists.
- Seed runs twice without duplicate.
```

## 4. API Validation Prompt

```text
Validate API for gap {gap_id}.

Check:
- Happy path.
- Validation negative.
- Permission negative.
- Idempotency replay/conflict if command.
- Error code.
- Audit/state/event/ledger side effects.
- Response body matches contract.
```

## 5. UI Validation Prompt

```text
Validate UI for gap {gap_id}.

Check:
- Screen route renders.
- API client calls correct route family.
- Loading, empty, error, validation and stale state.
- Permission-aware action states.
- Form/table/filter/action behavior.
- Public trace whitelist if touched.
```

## 6. Smoke Validation Prompt

```text
Run smoke subset for affected phase.

For CODE17/full smoke include:
- Source origin verified.
- Raw intake and incoming QC pass as prerequisite for mark-ready.
- Raw lot mark-ready action executed with `RAW_LOT_MARK_READY`, producing `lot_status = READY_FOR_PRODUCTION`.
- Negative check: material issue with `QC_PASS` but not `READY_FOR_PRODUCTION` returns `RAW_MATERIAL_LOT_NOT_READY`.
- Active G1 recipe with 4 groups.
- PO snapshot immutable.
- Material issue executes once with a `READY_FOR_PRODUCTION` lot and decrements raw inventory once.
- Material receipt does not decrement.
- Process events complete.
- QR printed.
- QC pass then explicit release.
- Warehouse receipt after release.
- Internal/public trace.
- Recall impact/hold/CAPA/close.
- MISA synced or reconcile pending.
```
