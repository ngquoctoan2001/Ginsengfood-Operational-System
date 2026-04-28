# 04 - Review Prompts

## 1. General Code Review Prompt

```text
Review this patch for gap {gap_id}.

Prioritize:
- Requirement correctness vs REQ-* and BR-*.
- Behavioral regressions.
- Missing tests.
- API/DTO/frontend contract drift.
- Security and permission gaps.
- Database migration/seed risk.
- Audit/event/ledger append-only risk.

Output findings first, ordered by severity, with file/line evidence.
```

## 2. Security Review Prompt

```text
Review security for gap {gap_id}.

Check:
- Auth required on admin endpoints.
- Backend permission enforced for every sensitive command.
- Public endpoint exposes no admin/private fields.
- Secrets are not committed or seeded.
- Destructive operations require permission, reason and audit.
- Override/break-glass action is logged and reviewable.
```

## 3. Public Trace Review Prompt

```text
Review public trace changes.

Check:
- Public API uses /api/public/trace/{qrCode}.
- Response is whitelist-only.
- No supplier/personnel/cost/QC defect/loss/MISA/private fields.
- QR VOID/FAILED/not public returns safe invalid/not found response.
- Admin/internal trace DTO is not reused as public DTO.
- UI public page does not render debug/internal ids.
```

## 4. MISA Integration Review Prompt

```text
Review MISA integration changes.

Check:
- Business modules emit events/outbox only.
- No direct MISA call from business module.
- Mapping exists or missing mapping creates review/reconcile pending.
- Retry count/status/error log/audit are recorded.
- Manual retry and reconcile are permission-gated.
- Credentials are environment/secret references, not seed/code literals.
```

## 5. Inventory/Ledger Review Prompt

```text
Review inventory changes.

Check:
- Material Issue Execution is the only raw inventory decrement point.
- Material Issue Execution requires raw lot `lot_status = READY_FOR_PRODUCTION`; `QC_PASS` alone must be rejected with `RAW_MATERIAL_LOT_NOT_READY`.
- No stale QC-pass-only raw lot error code remains in backend/API/FE/tests/docs; canonical issue-readiness error is `RAW_MATERIAL_LOT_NOT_READY`.
- Material Receipt Confirmation does not decrement raw inventory.
- Warehouse receipt requires batch RELEASED.
- Inventory ledger is append-only.
- Balance projection derives from ledger.
- Correction uses reversal/adjustment, not direct ledger mutation.
```

## 6. Audit/Approval Review Prompt

```text
Review audit and approval behavior.

Check:
- Sensitive command writes audit.
- State transition writes from/to/actor/reason.
- Approval records submitter, approver/rejector, reason and timestamp.
- Reject requires reason.
- Approved/signed records are not edited in place.
- Audit/history records are append-only.
```

## 7. API/Frontend Sync Review Prompt

```text
Review API/Frontend sync for this patch.

Check:
- API catalog and DTO docs updated.
- Error code docs updated.
- FE client/types/hooks updated.
- Screen action/form/table state updated.
- Permission visibility updated.
- Tests updated.
- If no FE impact, evidence is explicit and credible.
```
