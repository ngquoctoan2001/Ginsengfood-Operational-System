# 04 - Audit Logging Requirements

## 1. Mục tiêu

Định nghĩa yêu cầu audit, state transition, event, ledger history và evidence chain cho hệ thống vận hành.

## 2. Audit Scope

| audit_id | Action                                                                                       | Module   | Required evidence                                                                                                                                                                                            | Test                          |
| -------- | -------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------- |
| AUD-001  | Login/logout and failed auth if implemented                                                  | M02      | actor/session/time/ip/device where available                                                                                                                                                                 | TC-M02-RBAC-001               |
| AUD-002  | Role/action permission change                                                                | M02      | actor, role, action, before/after                                                                                                                                                                            | TC-M02-PERM-002               |
| AUD-003  | Approval approve/reject                                                                      | M02      | submitter, approver/rejector, reason, timestamp, object                                                                                                                                                      | TC-M02-APP-003                |
| AUD-004  | Recipe create/submit/approve/activate/retire and forbidden G0 operational activation attempt | M04      | version, status change, `formula_kind`, anchor metadata (PILOT), effective date, approver, reason, affected formula version/token                                                                            | TC-M04-REC-006                |
| AUD-005  | Production order create/approve/cancel                                                       | M07      | PO id, actor, state transition, snapshot reference, `snapshot_formula_version`, `formula_kind_snapshot`, `snapshot_basis`, `anchor_quantity_input` (PILOT) hoặc `batch_size` (FIXED), `total_batch_quantity` | TC-M07-PO-001                 |
| AUD-006  | Material issue execute                                                                       | M08      | issue id, raw lot, qty, ledger id, idempotency key                                                                                                                                                           | TC-M08-MI-001                 |
| AUD-007  | Material receipt variance                                                                    | M08      | receipt id, variance qty/reason, actor                                                                                                                                                                       | TC-M08-MR-002                 |
| AUD-008  | QC sign/hold/reject/pass                                                                     | M09      | inspector, result, reason, checklist/result snapshot                                                                                                                                                         | TC-M09-QC-001                 |
| AUD-009  | Batch release approve/reject                                                                 | M09      | release id, QC reference, approver, reason, state                                                                                                                                                            | TC-M09-REL-002                |
| AUD-010  | QR void/reprint/print failure                                                                | M10      | QR id, print job, original link, reason, actor                                                                                                                                                               | TC-M10-PRINT-004              |
| AUD-011  | Warehouse receipt and inventory adjustment                                                   | M11      | receipt/adjustment id, ledger id, reason, actor                                                                                                                                                              | TC-M11-WH-001, TC-M11-INV-004 |
| AUD-012  | Public trace policy change                                                                   | M12      | changed field policy, actor, before/after                                                                                                                                                                    | TC-M12-PTRACE-002             |
| AUD-013  | Recall impact/hold/sale lock/CAPA/evidence/close                                             | M13      | recall id, affected batch, reason, snapshot id, CAPA id, evidence refs, scan status, actor; `CLOSED_WITH_RESIDUAL_RISK` requires residual note and approver evidence                                                                              | TC-M13-RECALL-001             |
| AUD-014  | MISA mapping/retry/reconcile                                                                 | M14      | mapping id, sync event, error, retry count, reconciler                                                                                                                                                       | TC-M14-MISA-002               |
| AUD-015  | Override/break-glass                                                                         | M01, M02 | actor, approver, reason, affected object, expiry/review                                                                                                                                                      | Override tests                |
| AUD-016  | Workforce check-in/check-out/confirm                                                         | M07      | work order, process step, operator, check-in/out timestamp, confirmer, correction reason if any                                                                                                              | TC-M07-WORKFORCE-001          |
| AUD-017  | Audit export/search of sensitive evidence                                                    | M01      | actor, export/query scope, reason, filters, timestamp, destination if exported                                                                                                                               | TC-M01-AUD-EXPORT             |

## 3. Audit Data Contract

| field                          | Required                                                                 |
| ------------------------------ | ------------------------------------------------------------------------ |
| `audit_id`                     | Yes                                                                      |
| `correlation_id`               | Yes for API command                                                      |
| `actor_user_id`                | Yes for authenticated action                                             |
| `actor_role_codes`             | Yes for sensitive actions; best-effort only for anonymous public trace   |
| `action_code`                  | Yes                                                                      |
| `object_type`                  | Yes                                                                      |
| `object_id`                    | Yes                                                                      |
| `before_state` / `after_state` | Required for state transition                                            |
| `reason`                       | Required for reject/hold/cancel/override/reprint/adjustment/audit export |
| `residual_note`                | Required for `CLOSED_WITH_RESIDUAL_RISK`                                 |
| `created_at`                   | Yes                                                                      |
| `source_ip` / `device_id`      | Required when available for public/admin/device                          |

## 4. Append-Only Rules

- Audit log is append-only.
- State transition log is append-only.
- Inventory ledger is append-only.
- QR state history is append-only.
- Recall exposure snapshot is immutable after creation.
- Corrections use new records/reversal/compensation, not in-place edits.

## 5. Audit Query And Retention

| requirement                                                                   | Status                |
| ----------------------------------------------------------------------------- | --------------------- |
| Audit viewer must support filter by actor/action/object/date/correlation id   | MANDATORY             |
| Audit export requires permission and reason if export contains sensitive data | MANDATORY             |
| Audit retention duration                                                      | OWNER DECISION NEEDED |
| Archive/restore behavior for audit                                            | OWNER DECISION NEEDED |

## 6. Validation

| validation_id | Expected                                                                                                    |
| ------------- | ----------------------------------------------------------------------------------------------------------- |
| AUD-VAL-001   | Sensitive command fails if audit write cannot be persisted.                                                 |
| AUD-VAL-002   | Direct update/delete of audit/state/ledger/history is blocked in all non-migration/non-archival code paths. |
| AUD-VAL-003   | Audit query returns expected command evidence by correlation id.                                            |
| AUD-VAL-004   | Public trace policy changes produce audit before public release.                                            |
