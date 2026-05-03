# 01 - Non-Functional Requirements

## 1. Mục tiêu

Tài liệu này tổng hợp yêu cầu phi chức năng cho hệ thống Ginsengfood software specs: security, audit, performance, scalability, availability, backup, retention, observability, idempotency, concurrency, transaction consistency, migration safety và public/internal data policy.

Phạm vi nguồn tuân thủ [../01_SOURCE_INDEX.md](../01_SOURCE_INDEX.md): prompt gốc, `docs-software/`, `.tmp-docx-extract/`, các tài liệu đã chuẩn hóa trong `docs/software-specs/`, kiến thức chuyên môn có đánh dấu và owner approval. Không dùng source code, `AGENTS.md` hoặc `docs/ginsengfood_*` làm source-of-truth cho NFR pack này.

## 2. NFR Classification

| category | Description | Primary files |
|---|---|---|
| Performance | Latency, throughput, query, smoke runtime | `02_PERFORMANCE_REQUIREMENTS.md` |
| Security | AuthN/AuthZ, secret, public/private boundary, destructive action | `03_SECURITY_REQUIREMENTS.md` |
| Audit logging | Append-only audit, state transition, evidence chain | `04_AUDIT_LOGGING_REQUIREMENTS.md` |
| Backup/retention | RPO/RTO, restore drill, archive, data retention | `05_BACKUP_RETENTION_REQUIREMENTS.md` |
| Observability | Logging, metrics, health, alerts, incident visibility | `06_OBSERVABILITY_REQUIREMENTS.md` |
| Scalability/availability | Capacity, HA, graceful degradation, retry | `07_SCALABILITY_AVAILABILITY_REQUIREMENTS.md` |

## 3. NFR Matrix

| nfr_id | requirement | requirement_id | module | priority | acceptance criteria | validation/test | owner decision |
|---|---|---|---|---|---|---|---|
| NFR-SEC-001 | Admin/internal APIs require authentication and backend authorization. | REQ-NFR-003, REQ-M02-002 | M01, M02 | P0 | Unauthorized request rejected; user without permission gets `403`; no side effect. | TC-M02-PERM-002, TC-NFR-SEC-003 | No |
| NFR-SEC-002 | Public trace must enforce public/internal boundary. | REQ-M12-002, REQ-NFR-003 | M12 | P0 | Public response excludes supplier/personnel/cost/QC defect/loss/MISA/private fields. | TC-M12-PTRACE-002, TC-HL-PTRACE-001 | No |
| NFR-SEC-003 | Evidence upload must validate MIME/size and require clean malware scan before source verification, supplier receive policy, or CAPA/recall close. | REQ-M05-002, REQ-M13-001, REQ-NFR-003 | M05, M06, M13 | P0 | Invalid MIME/size rejected; pending/failed/malware scan cannot satisfy verify/receive/close; DB stores metadata only. | TC-NFR-SEC-EVIDENCE, TC-M13-CAPA-004 | No |
| NFR-AUD-001 | Sensitive commands across approval, recipe, production, issue, QC/release, QR/print, inventory, trace policy, recall and MISA must produce append-only audit/state evidence. | REQ-M01-001, REQ-M01-005 | M01, M02, M04, M07, M08, M09, M10, M11, M12, M13, M14 | P0 | Actor, role, action, object, before/after or from/to state, reason, correlation/idempotency when applicable and timestamp recorded. | TC-M01-AUD-001, TC-M01-STATE-005 | No |
| NFR-IDEM-001 | Side-effect commands must be idempotent where catalog requires. | REQ-M01-002 | M01, M16 | P0 | Same key/payload does not duplicate ledger/audit/event/QR/release side effects. | TC-M01-API-002, TC-M16-PWA-003 | No |
| NFR-PERF-001 | Trace query performance target must be defined and tested. | REQ-M12-004 | M12, M15 | P1 | Internal/public trace query has PF-01 SLA baseline and test method. | TC-M12-PERF-004 | RESOLVED_PF01 |
| NFR-BACKUP-001 | Backup/restore, RPO/RTO and restore drill must exist before release readiness. | REQ-NFR-001 | M01, M15 | P1 | Backup schedule, restore procedure, restore drill result and PF-02 RPO/RTO recorded. | TC-NFR-BACKUP-001 | RESOLVED_PF02 |
| NFR-RET-001 | Retention/archive policy must be defined by data class. | REQ-NFR-002 | M01, M11, M12, M13, M14 | P2 | Retention duration, archive trigger, restore/search boundary and deletion restriction documented per class. | TC-NFR-RET-002 | RESOLVED_PF02 |
| NFR-OBS-001 | Observability stack, log retention, metric retention and escalation channel must be defined. | REQ-M15-003 | M15 | P2 | Logs/metrics/traces/alerts available for P0 flows; tooling can be platform choice. | TC-M15-OBS-003 | DEFERRED_WITH_ACCEPTED_RISK |
| NFR-MIG-001 | Migration/seed must be idempotent and safe. | REQ-NFR-004 | M01, M04 | P0 | Seed can run twice; migration has validation and rollback/forward-fix note; validation proves 20 canonical SKU, 433 G1 recipe lines, 0 active G0 and SKU config points to active G1 `PILOT_PERCENT_BASED`. The `433` count is derived from `data/csv/g1_recipe_lines.csv` row count and `data/seed_manifest.json`, not inferred from 20 × fixed line count. | TC-NFR-SEED-004, TC-SEED-013 | No |
| NFR-SMOKE-001 | Full E2E smoke must cover the operational chain. | REQ-NFR-005 | All | P0 | Source -> intake -> QC -> lot mark-ready -> PO snapshot G1 -> issue -> receipt -> process -> packaging/QR -> batch release -> warehouse -> trace -> recall -> MISA dry-run pass. | TC-NFR-SMOKE-005 | No |
| NFR-CONC-001 | Concurrent commands must not create double inventory, duplicate release, duplicate QR or duplicate sync side effects. | REQ-M01-002, REQ-M08-001, REQ-M14-002 | M01, M08, M10, M14 | P0 | Unique/idempotency/locking prevents duplicate side effects; exact duplicate replay returns the original successful result. | TC-M01-API-002, TC-INT-INV-002, TC-INT-MISA-002 | No |
| NFR-TXN-001 | Cross-module business transactions must be atomic where required. | REQ-M08-001, REQ-M11-001, REQ-M13-002 | M08, M11, M13 | P0 | Lot readiness check + issue + ledger + trace, release-gated warehouse + ledger, recall impact snapshot are committed consistently or rolled back. | TC-INT-INV-001, TC-INT-RECALL-001 | No |
| NFR-DEVICE-001 | Printer/device integration must fail safe and never own business truth. | REQ-M10-003, REQ-M15-003 | M10, M15 | P0 | Device/printer failure creates error/retry state and log; QR/print history remains append-only; printer callback cannot create inventory, QC pass or release. PF-02 baseline: HTTP/ZPL-compatible adapter + HMAC callback auth. | TC-M10-PRINT-004, TC-M15-ALERT-002 | RESOLVED_PF02 |
| NFR-GATE-001 | Production and warehouse gates must be explicit NFR done gates. | REQ-M08-001, REQ-M11-001 | M08, M11 | P0 | Material issue rejects lot that is only `QC_PASS`; warehouse receipt rejects batch that is only `QC_PASS` and not `RELEASED`. | TC-M08-MI-001, TC-M11-WH-001 | No |

## 4. NFR Done Gate

| gate_id | Gate |
|---|---|
| NFR-DG-001 | Every P0 NFR maps to `REQ-*`, `BR-*` or test `TC-*`. |
| NFR-DG-002 | Public/internal data policy is tested before public trace release. |
| NFR-DG-003 | Audit/state/event/ledger append-only behavior is tested before go-live. |
| NFR-DG-004 | Migration/seed validation passes before E2E smoke. |
| NFR-DG-005 | Lot `READY_FOR_PRODUCTION` is the material issue gate; lot `QC_PASS` alone is rejected. |
| NFR-DG-006 | Batch `RELEASED` is the warehouse receipt gate; batch `QC_PASS` alone is rejected. |
| NFR-DG-007 | PF-02 closes backup, retention, rate-limit scope and device protocol baseline; remaining observability/tool choices must be closed or accepted as deferred risk. |

## 5. PF-02 NFR Decision Status

| decision_id | Canonical tracker ID | Related NFR | PF-02 status | Impact |
|---|---|---|---|---|
| OD-TRACE-SLA | OD-11 | NFR-PERF-001 | RESOLVED_PF01: generic metrics + performance validation target in CODE07/CODE17 | Performance test and DB/index design |
| OD-BACKUP-RTO | OD-12 | NFR-BACKUP-001 | RESOLVED_PF02: DB RPO 15m/RTO 4h; evidence RPO 1h/RTO 8h; audit/outbox RPO 5m/RTO 2h | Release readiness and DevOps runbook |
| OD-RETENTION | OD-13 | NFR-RET-001 | RESOLVED_PF02: 7y operational/audit/trace, 10y recall/CAPA, 5y MISA, 90d active outbox/request then archive | Archive schema, jobs, legal/compliance |
| OD-OBSERVABILITY | OD-OBSERVABILITY | NFR-OBS-001 | DEFERRED_WITH_ACCEPTED_RISK: exact tooling/channel can be platform choice; health/metrics/log hooks still mandatory | Monitoring and incident operations |
| OD-RATE-LIMIT | OD-RATE-LIMIT-SCOPE-001 | NFR-SEC-002 | RESOLVED_PF02: configurable thresholds for public/admin/login/supplier/PWA/MISA/device callback route families | Security and abuse protection |
| OD-PRINTER-PROTOCOL | OD-17 / OD-PRINTER-PROTO-001 | NFR-DEVICE-001 | RESOLVED_PF02: HTTP/ZPL-compatible adapter + HMAC-SHA256 callback auth; physical model in device registry/config | Print/QR safety and device operations |

Rule: `OD-11`, `OD-12`, ... are canonical IDs in `09_CONFLICT_AND_OWNER_DECISIONS.md`. Descriptive IDs in NFR docs are aliases only and must keep a 1-1 mapping in this table before scaffold.
