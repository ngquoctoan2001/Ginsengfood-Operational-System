# 06 - Observability Requirements

## 1. Mục tiêu

Định nghĩa logging, metrics, tracing, health checks, alerts, incident visibility và operational dashboard requirements.

## 2. Observability Matrix

| obs_id         | signal                                       | module        | requirement                                                                                                                                                                            | priority | validation                   | owner decision     |
| -------------- | -------------------------------------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------- | ------------------ |
| OBS-LOG-001    | Structured application/background-worker log | All           | Log request id/correlation id, route/job name, status, latency, error code for admin APIs, outbox workers, MISA sync, QR print queue, recall notification and archive/restore workers. | P1       | API/worker error-log test    | Tooling/retention  |
| OBS-LOG-002    | Audit log                                    | M01           | Sensitive action audit append-only and queryable.                                                                                                                                      | P0       | TC-M01-AUD-001               | No                 |
| OBS-MET-001    | Inventory movement metrics                   | M08, M11      | Count issue/receipt/adjustment failures, duplicate issue attempts/idempotency collisions, negative balance risk, ledger posting errors.                                                | P1       | Alert/dashboard test         | Tooling            |
| OBS-MET-002    | QC/release metrics                           | M09           | Count QC hold/reject/pass, release pending, release blocked by hold.                                                                                                                   | P1       | Dashboard test               | Tooling            |
| OBS-MET-003    | Public trace metrics                         | M12           | Count public trace success, invalid QR, not public, latency, leakage violations.                                                                                                       | P1       | Public trace test            | Tooling            |
| OBS-MET-004    | MISA sync metrics                            | M14           | Count pending, synced, failed, missing mapping, retry, reconcile pending.                                                                                                              | P0       | TC-M14-MISA-002              | No                 |
| OBS-MET-005    | Recall metrics                               | M13           | Count open recall, impact pending, hold active, CAPA overdue, CAPA evidence pending/failed/malware scan.                                                                               | P1       | Recall dashboard test        | SLA decision       |
| OBS-MET-006    | Batch state metrics                          | M07, M09, M11 | Count batches by `QC_PENDING`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`, `RELEASED`, blocked warehouse receipt and active hold per time window.                                               | P1       | Production/QC dashboard test | Tooling            |
| OBS-HEALTH-001 | Health endpoint                              | M15           | Report app, DB, queue/outbox, MISA adapter, printer/device registry health, evidence storage adapter and scanner health where configured.                                              | P1       | Health check test            | Tooling            |
| OBS-ALERT-001  | Critical alerts                              | M15           | Alert on MISA fail, printer fail, inventory negative risk, public trace leakage, recall SLA risk.                                                                                      | P1       | TC-M15-ALERT-002             | Escalation channel |

## 3. Required Correlation IDs

| flow              | Required correlation                                                                    |
| ----------------- | --------------------------------------------------------------------------------------- |
| API command       | `correlation_id`, `idempotency_key` if command requires it                              |
| Material issue    | issue id, raw lot id, ledger id, batch id                                               |
| Warehouse receipt | receipt id, batch id, ledger id                                                         |
| Trace search      | search request id, entity id, chain id if implemented                                   |
| Public trace      | request id, QR code hash/reference only, public-safe result                             |
| Recall            | recall case id, impact snapshot id, hold/sale lock id, CAPA id, evidence id/scan status |
| MISA sync         | outbox event id, sync event id, retry/reconcile id                                      |

## 4. Logging Policy

- Logs must not contain secrets.
- Public trace logs must not include private supplier/personnel/cost/QC defect/loss/MISA fields.
- Error logs should include stable error code and correlation id.
- Background worker logs must include worker/job name, event id, retry count and correlation id when available.
- Debug payload logging must be disabled or redacted in production.
- Audit log is not a replacement for application logs; both have separate purposes.

## 5. Alert Rules

| alert_id           | Trigger                                                                                                                                           | Severity    | Owner/action              |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------------------------- |
| ALERT-MISA-001     | MISA sync failed beyond retry policy or missing mapping unresolved                                                                                | High        | Integration operator      |
| ALERT-INV-001      | Inventory ledger posting failure or negative balance risk                                                                                         | Critical    | Warehouse/Admin           |
| ALERT-TRACE-001    | Public trace response policy violation detected                                                                                                   | Critical    | Security/QA               |
| ALERT-RECALL-001   | Recall impact/hold/CAPA exceeds recall business SLA (OD-10 RESOLVED: < 4h từ phát hiện đến khóa batch + notification); SLA threshold configurable | High        | Recall manager            |
| ALERT-EVIDENCE-001 | Evidence scan failed, malware detected, or storage adapter unavailable for source-origin/CAPA evidence                                            | High        | QA/Security/DevOps        |
| ALERT-PRINT-001    | Print/QR job failure rate above threshold                                                                                                         | Medium/High | Packaging/Device operator |
| ALERT-SEED-001     | Seed validation fails in QA/staging                                                                                                               | High        | DBA/Backend               |

## 6. Owner Decisions

| decision_id         | Needed decision                                           |
| ------------------- | --------------------------------------------------------- |
| OD-OBSERVABILITY    | Logging/metrics/tracing tool stack                        |
| OD-LOG-RETENTION    | Log retention and searchable history                      |
| OD-METRIC-RETENTION | Metric retention                                          |
| OD-ESCALATION       | Alert channel, severity routing, on-call/escalation owner |
