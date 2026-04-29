# 05 - Prompt kiểm chứng

## 1. Prompt lập kế hoạch kiểm chứng

```text
Create validation plan for gap {gap_id}.

Bao gồm:
- Lệnh backend build.
- Backend tests.
- Lệnh frontend build nếu chạm FE.
- Frontend tests nếu chạm FE.
- Lệnh migration apply/update nếu chạm DB.
- Lệnh seed và seed validation nếu chạm seed.
- API tests.
- UI tests.
- Integration/regression tests.
- E2E smoke subset.
- Bước cleanup process.
```

## 2. Prompt kiểm chứng migration

```text
Validate database migration for gap {gap_id}.

Kiểm tra:
- Applies to empty DB.
- Applies to existing QA/staging DB.
- FK/unique/check constraints work.
- `lot_status` enum/check constraint includes `READY_FOR_PRODUCTION` and does not use `QC_PASS` as lot readiness state.
- Append-only guard works.
- Validation query pass.
- Rollback/forward-fix note exists.
```

## 3. Prompt kiểm chứng seed

```text
Validate seed for gap {gap_id}.

Chạy/kiểm tra:
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

## 4. Prompt kiểm chứng API

```text
Validate API for gap {gap_id}.

Kiểm tra:
- Happy path.
- Negative validation.
- Permission negative.
- Idempotency replay/conflict if command.
- Error code.
- Audit/state/event/ledger side effects.
- Response body matches contract.
```

## 5. Prompt kiểm chứng UI

```text
Validate UI for gap {gap_id}.

Kiểm tra:
- Screen route renders.
- API client calls correct route family.
- Loading, empty, error, validation and stale state.
- Permission-aware action states.
- Form/table/filter/action behavior.
- Public trace whitelist if touched.
```

## 6. Prompt kiểm chứng smoke

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
