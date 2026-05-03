# 07 - Scalability Availability Requirements

## 1. Mục tiêu

Định nghĩa yêu cầu scalability, availability, reliability, retry, concurrency, graceful degradation và release readiness cho hệ thống vận hành.

## 2. Availability Matrix

| avail_id | requirement | module | priority | validation | owner decision |
|---|---|---|---|---|---|
| AVL-001 | Admin operational workflows must fail safely and not create partial side effects, including atomic rollback when lot readiness check fails during material issue. | M01, M07, M08, M09, M11 | P0 | Transaction/integration tests | No |
| AVL-002 | Public trace must fail safe if QR invalid, void, failed or policy missing. | M10, M12 | P0 | TC-M12-PTRACE-003 | No |
| AVL-003 | MISA outage must not block local operational transaction if event can be retained for retry/reconcile. | M14, M01 | P0 | TC-M14-MISA-002 | No |
| AVL-004 | Printer/device failure must not delete QR/print history; failure creates retry/error state. | M10 | P1 | TC-M10-PRINT-004 | Printer model/protocol |
| AVL-005 | Restore/backup readiness must be approved before production. | M01, M15 | P1 | Restore drill | RPO/RTO |
| AVL-006 | Health checks must cover app, DB and background queue/outbox/integration components. | M15, M14 | P1 | Health endpoint/monitoring test | Tooling |

## 3. Scalability Matrix

| scale_id | area | requirement | design rule | owner decision |
|---|---|---|---|---|
| SCL-001 | SKU/recipe | 20 SKU is go-live baseline but not permanent application cap. | Data model supports future SKU and future recipe versions. | No |
| SCL-002 | Recipe versioning | Future formula versions must be approved/activated/snapshotted without rewriting history. | Immutable PO snapshot and versioned recipe tables. | No |
| SCL-003 | Inventory ledger | Ledger grows append-only and balance projection must remain queryable after adjustment/correction. | Index by item/lot/warehouse/reference/time; define projection rebuild trigger and manual rebuild boundary. | Retention/archive |
| SCL-004 | Trace | Trace chain can grow by batch/lot/QR/shipment references. | Use trace links/search index/projection; avoid unbounded query path. | Trace SLA/volume |
| SCL-005 | Public trace | Public trace can have traffic spikes. | Cache safe public projection; rate limit; invalidate by QR/policy state. | SLA/rate limit |
| SCL-006 | MISA sync | Sync events can backlog during outage without exhausting storage. | Persistent queue, retry, reconcile, manual retry, maximum queue depth and circuit breaker. | Retry policy |
| SCL-007 | E2E smoke/regression | Test suite grows by module/phase. | P0 regression runs on every docs/code contract change; P1/P2 run targeted by trigger. | CI runtime |

## 4. Concurrency Requirements

| concurrency_id | Scenario | Required behavior | Test |
|---|---|---|---|
| CONC-001 | Duplicate material issue execution | One ledger debit only; exact duplicate idempotency replay returns original successful result, not a new debit or ambiguous failure. | TC-INT-INV-002 |
| CONC-002 | Concurrent warehouse receipt for same batch | Prevent duplicate receipt/ledger credit unless split receipt is explicitly designed. | TC-M11-WH-001 variant |
| CONC-003 | Concurrent recipe activation | Only one active operational recipe per `(sku_id, formula_kind)`/effective window; G1 PILOT and G2 FIXED may coexist for the same SKU. | TC-M04-REC-006 |
| CONC-004 | Concurrent QR generated/queued/reprint/void | State machine serializes `GENERATED -> QUEUED` claim and prevents invalid reprint/void transition; history append-only. | TC-M10-QR-003 |
| CONC-005 | Concurrent MISA retry/reconcile | Lock sync event or use version check; no duplicate external sync side effects. | TC-M14-MISA-002 |

## 5. Graceful Degradation

| failure | Expected degradation |
|---|---|
| MISA unavailable | Local transaction completes if event retained; sync event pending/retry/reconcile. |
| Printer unavailable | Print job failed/pending; QR history retained; reprint/void through workflow. |
| Public trace policy unavailable | Fail closed or return minimal safe error, not internal data. |
| Dashboard projection stale | Show stale indicator and last updated time; do not block core transactions. |
| Trace search partial gap | Show trace gap warning internally; public response remains safe. |
| Backup/restore not verified | Block production readiness gate. |

## 6. Availability Done Gate

- P0 workflows have atomic transaction and idempotency tests.
- Lot readiness and batch release gates are included in atomic transaction tests.
- External dependency failures are retained/retryable or fail safe.
- No public/private leakage under failure.
- Backup/restore and observability owner decisions are closed before production readiness.
- Regression triggers in `testing/08_REGRESSION_TEST_PLAN.md` cover scale/availability hard locks.
