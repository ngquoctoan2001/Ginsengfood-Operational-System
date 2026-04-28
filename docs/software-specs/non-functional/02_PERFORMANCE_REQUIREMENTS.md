# 02 - Performance Requirements

## 1. Mục tiêu

Định nghĩa yêu cầu hiệu năng cho API, trace, dashboard, printing/QR, seed/migration và E2E smoke. Vì tài liệu nguồn chưa chốt số đo vận hành cuối cùng, các target định lượng đều được đánh dấu `OWNER DECISION NEEDED` nếu chưa có owner approval.

## 2. Performance Requirement Matrix

| perf_id | scenario | module | target | measurement | priority | test case | owner decision |
|---|---|---|---|---|---|---|---|
| PERF-API-001 | Admin command API for production/material/QC/warehouse | M07, M08, M09, M11 | P95 latency target cần owner chốt; không được làm operator submit trùng do timeout mơ hồ. | API timing with realistic payload and DB transaction | P1 | TC-API-M08-001, TC-API-M11-001 | OWNER DECISION NEEDED |
| PERF-API-002 | Material issue execution retry/idempotency | M08, M11, M01 | Under retry/timeout, duplicate submit must return deterministic original result and never create a second ledger debit. | Timed retry test with same idempotency key/payload and concurrent submit | P0 | TC-M08-MI-001, TC-INT-INV-002 | No |
| PERF-PTRACE-001 | Public trace resolve by QR | M12 | P95 latency and cache policy cần owner chốt; query uses public-safe projection, not internal genealogy expansion. | `GET /api/public/trace/{qrCode}` load test against whitelist projection | P1 | TC-M12-PTRACE-002 | OWNER DECISION NEEDED |
| PERF-TRACE-001 | Internal trace search by QR/batch/raw lot | M12 | SLA/volume/index strategy cần owner chốt; query must support full chain depth lot -> issue -> batch -> QR -> warehouse. | Trace search benchmark by chain depth | P1 | TC-M12-PERF-004 | OWNER DECISION NEEDED |
| PERF-RECALL-001 | Recall impact analysis and CAPA/state updates | M13, M12 | Must complete within owner-approved recall SLA, including hold/sale lock, recovery/CAPA and `CLOSED_WITH_RESIDUAL_RISK` state updates. | Impact analysis and recall state benchmark using exposure set | P1 | TC-M13-RECALL-002 | OWNER DECISION NEEDED |
| PERF-PRINT-001 | QR generation and print queue | M10 | Throughput must support batch print volume after printer model is known; state transition latency for `GENERATED -> QUEUED -> PRINTED/FAILED` must be observable. | QR/print job enqueue, transition timing and callback throughput | P1 | TC-M10-QR-003, TC-M10-PRINT-004 | OWNER DECISION NEEDED |
| PERF-SEED-001 | Seed baseline and migration validation | M01, M04 | Seed can complete and rerun without timeout or duplicate. | Seed runtime, duplicate check, validation query | P0 | TC-NFR-SEED-004, TC-SEED-013 | No |
| PERF-DASH-001 | Operations dashboard | M15 | Dashboard must load without scanning transaction tables synchronously for every widget. | Dashboard query timing and projection freshness | P2 | TC-M15-DASH-001 | OWNER DECISION NEEDED |
| PERF-SMOKE-001 | E2E smoke workflow | All | Full smoke runtime target needs CI/QA environment decision; smoke must also assert formula version `G1` and no operational `G0`. | E2E test duration, step timing and correctness gate | P0 | TC-NFR-SMOKE-005 | OWNER DECISION NEEDED |

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
| Trace depth dataset | Validate source/raw lot -> issue -> batch -> QR -> warehouse/search chain | OWNER DECISION NEEDED: volume/depth |
| Recall exposure dataset | Validate impact analysis and snapshot generation | OWNER DECISION NEEDED: exposure size |
| QR print batch dataset | Validate generated/queued/printed/failed/reprinted states at print volume | OWNER DECISION NEEDED: printer/label volume |
| Dashboard 30/90-day dataset | Validate reporting projection and dashboard response | OWNER DECISION NEEDED: reporting volume |

## 5. Acceptance And Blockers

- P0 performance blocker: seed validation or E2E smoke cannot complete reliably in QA.
- P0 performance blocker: material issue retry/timeout cannot return deterministic idempotent result.
- P1 performance blocker: public/internal trace has no owner-approved SLA before trace release.
- P1 performance blocker: recall impact analysis cannot complete within owner-approved recall SLA.
- P2 blocker: dashboard/observability performance thresholds remain unapproved for go-live reporting scope.
