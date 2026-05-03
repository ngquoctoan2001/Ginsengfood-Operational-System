# 02 - Performance Requirements

## 1. Mục tiêu

Định nghĩa yêu cầu hiệu năng cho API, trace, dashboard, printing/QR, seed/migration và E2E smoke. PF-01/PF-02 đã freeze baseline cho trace/recall/printer-related release gates; các target còn lại có thể cấu hình theo môi trường nhưng không được bỏ measurement.

## 2. Performance Requirement Matrix

| perf_id | scenario | module | target | measurement | priority | test case | owner decision |
|---|---|---|---|---|---|---|---|
| PERF-API-001 | Admin command API for production/material/QC/warehouse | M07, M08, M09, M11 | PF-03 baseline: P95 command API < 2s for normal payload; idempotency must prevent duplicate submit under timeout. | API timing with realistic payload and DB transaction | P1 | TC-API-M08-001, TC-API-M11-001 | RESOLVED_PF03 |
| PERF-API-002 | Material issue execution retry/idempotency | M08, M11, M01 | Under retry/timeout, duplicate submit must return deterministic original result and never create a second ledger debit. | Timed retry test with same idempotency key/payload and concurrent submit | P0 | TC-M08-MI-001, TC-INT-INV-002 | No |
| PERF-PTRACE-001 | Public trace resolve by QR | M12 | PF-01 baseline: P95 public trace < 500ms using public-safe projection/cache policy; not internal genealogy expansion. | `GET /api/public/trace/{qrCode}` load test against whitelist projection | P1 | TC-M12-PTRACE-002 | RESOLVED_PF01 |
| PERF-TRACE-001 | Internal trace search by QR/batch/raw lot | M12 | PF-01 baseline: genealogy depth <= 5 P95 < 1.5s; query must support full chain depth lot -> issue -> batch -> QR -> warehouse. | Trace search benchmark by chain depth | P1 | TC-M12-PERF-004 | RESOLVED_PF01 |
| PERF-RECALL-001 | Recall impact analysis and CAPA/state updates | M13, M12 | Recall Operational SLA: detection to hold + notification job/outbox < 4h; impact analysis benchmark must be measured against exposure set. | Impact analysis and recall state benchmark using exposure set | P1 | TC-M13-RECALL-002 | RESOLVED_FINAL |
| PERF-PRINT-001 | QR generation and print queue | M10 | PF-02 baseline: HTTP/ZPL-compatible adapter and HMAC callback; state transition latency for `GENERATED -> QUEUED -> PRINTED/FAILED` must be observable and configurable. | QR/print job enqueue, transition timing and callback throughput | P1 | TC-M10-QR-003, TC-M10-PRINT-004 | RESOLVED_PF02 |
| PERF-SEED-001 | Seed baseline and migration validation | M01, M04 | Seed can complete and rerun without timeout or duplicate. | Seed runtime, duplicate check, validation query | P0 | TC-NFR-SEED-004, TC-SEED-013 | No |
| PERF-DASH-001 | Operations dashboard | M15 | Dashboard must load from projection/metric tables; exact 30/90-day volume is environment config and does not block scaffold. | Dashboard query timing and projection freshness | P2 | TC-M15-DASH-001 | DEFERRED_WITH_ACCEPTED_RISK |
| PERF-SMOKE-001 | E2E smoke workflow | All | Full smoke runtime target is CI/QA profile-bound; smoke must assert formula version `G1`, no operational `G0`, and P0 hard locks. | E2E test duration, step timing and correctness gate | P0 | TC-NFR-SMOKE-005 | RESOLVED_PF03 |

## 3. Performance Design Rules

| rule_id | Rule | Affected module |
|---|---|---|
| PERF-RULE-001 | Trace search must use indexed/projection-friendly data structures; do not rely on unbounded recursive runtime joins for production trace. | M12 |
| PERF-RULE-002 | Public trace may be cacheable by QR/state/projection version, but must invalidate or fail safe for QR state changes. | M10, M12 |
| PERF-RULE-003 | Dashboard metrics should be derived from metric/projection tables, not expensive live scans of audit/ledger/trace for every request. | M15 |
| PERF-RULE-004 | Idempotency must protect against user retry caused by latency or network timeout. | M01, M08, M16 |
| PERF-RULE-005 | Seed and migration validation must be runnable in CI/QA without manual DB edits. | M01, M04 |

## 4. Performance Test Data

| dataset | Purpose | Owner decision |
|---|---|---|
| Minimal smoke dataset | Validate P0 operational flow with at least 20 SKU, 433 G1 recipe lines, 0 active G0, one `READY_FOR_PRODUCTION` lot and one `RELEASED` batch fixture | No |
| Trace depth dataset | Validate source/raw lot -> issue -> batch -> QR -> warehouse/search chain | RESOLVED_PF01: depth <= 5 baseline; larger volume can be tuned by config/test profile |
| Recall exposure dataset | Validate impact analysis and snapshot generation | RESOLVED_FINAL: use smoke exposure set plus configurable larger benchmark set |
| QR print batch dataset | Validate generated/queued/printed/failed/reprinted states at print volume | RESOLVED_PF02: adapter/callback throughput measured; physical printer volume is device config/test profile |
| Dashboard 30/90-day dataset | Validate reporting projection and dashboard response | DEFERRED_WITH_ACCEPTED_RISK: reporting volume binds by environment profile |

## 5. Acceptance And Blockers

- P0 performance blocker: seed validation or E2E smoke cannot complete reliably in QA.
- P0 performance blocker: material issue retry/timeout cannot return deterministic idempotent result.
- P1 performance blocker: public/internal trace fails PF-01 SLA baseline or has no measurement evidence before trace release.
- P1 performance blocker: recall impact/outbox path cannot support the < 4h Operational SLA measurement.
- P2 blocker: dashboard/observability performance thresholds remain unapproved for go-live reporting scope.
