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
| NFR-SEC-003 | Evidence upload must validate MIME/size and require clean malware scan before source verification or CAPA/recall close. | REQ-M05-002, REQ-M13-001, REQ-NFR-003 | M05, M13 | P0 | Invalid MIME/size rejected; pending/failed/malware scan cannot satisfy verify/close; DB stores metadata only. | TC-NFR-SEC-EVIDENCE, TC-M13-CAPA-004 | No |
| NFR-AUD-001 | Sensitive commands across approval, recipe, production, issue, QC/release, QR/print, inventory, trace policy, recall and MISA must produce append-only audit/state evidence. | REQ-M01-001, REQ-M01-005 | M01, M02, M04, M07, M08, M09, M10, M11, M12, M13, M14 | P0 | Actor, role, action, object, before/after or from/to state, reason, correlation/idempotency when applicable and timestamp recorded. | TC-M01-AUD-001, TC-M01-STATE-005 | No |
| NFR-IDEM-001 | Side-effect commands must be idempotent where catalog requires. | REQ-M01-002 | M01, M16 | P0 | Same key/payload does not duplicate ledger/audit/event/QR/release side effects. | TC-M01-API-002, TC-M16-PWA-003 | No |
| NFR-PERF-001 | Trace query performance target must be defined and tested. | REQ-M12-004 | M12, M15 | P1 | Internal/public trace query has approved SLA and test method. | TC-M12-PERF-004 | OWNER DECISION NEEDED: SLA/volume |
| NFR-BACKUP-001 | Backup/restore, RPO/RTO and restore drill must exist before release readiness. | REQ-NFR-001 | M01, M15 | P1 | Backup schedule, restore procedure, restore drill result and owner-approved RPO/RTO recorded. | TC-NFR-BACKUP-001 | OWNER DECISION NEEDED: RPO/RTO |
| NFR-RET-001 | Retention/archive policy must be defined by data class. | REQ-NFR-002 | M01, M11, M12, M13, M14 | P2 | Retention duration, archive trigger, restore/search boundary and deletion restriction documented per class. | TC-NFR-RET-002 | OWNER DECISION NEEDED: retention duration |
| NFR-OBS-001 | Observability stack, log retention, metric retention and escalation channel must be defined. | REQ-M15-003 | M15 | P2 | Logs/metrics/traces/alerts available for P0 flows; owner-approved tooling. | TC-M15-OBS-003 | OWNER DECISION NEEDED: tooling/channel |
| NFR-MIG-001 | Migration/seed must be idempotent and safe. | REQ-NFR-004 | M01, M04 | P0 | Seed can run twice; migration has validation and rollback/forward-fix note; validation proves 20 canonical SKU, 433 G1 recipe lines, 0 active G0 and SKU config points to G1. | TC-NFR-SEED-004, TC-SEED-013 | No |
| NFR-SMOKE-001 | Full E2E smoke must cover the operational chain. | REQ-NFR-005 | All | P0 | Source -> intake -> QC -> lot mark-ready -> PO snapshot G1 -> issue -> receipt -> process -> packaging/QR -> batch release -> warehouse -> trace -> recall -> MISA dry-run pass. | TC-NFR-SMOKE-005 | No |
| NFR-CONC-001 | Concurrent commands must not create double inventory, duplicate release, duplicate QR or duplicate sync side effects. | REQ-M01-002, REQ-M08-001, REQ-M14-002 | M01, M08, M10, M14 | P0 | Unique/idempotency/locking prevents duplicate side effects; exact duplicate replay returns the original successful result. | TC-M01-API-002, TC-INT-INV-002, TC-INT-MISA-002 | No |
| NFR-TXN-001 | Cross-module business transactions must be atomic where required. | REQ-M08-001, REQ-M11-001, REQ-M13-002 | M08, M11, M13 | P0 | Lot readiness check + issue + ledger + trace, release-gated warehouse + ledger, recall impact snapshot are committed consistently or rolled back. | TC-INT-INV-001, TC-INT-RECALL-001 | No |
| NFR-DEVICE-001 | Printer/device integration must fail safe and never own business truth. | REQ-M10-003, REQ-M15-003 | M10, M15 | P0 | Device/printer failure creates error/retry state and log; QR/print history remains append-only; printer callback cannot create inventory, QC pass or release. | TC-M10-PRINT-004, TC-M15-ALERT-002 | OWNER DECISION NEEDED: protocol/threshold |
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
| NFR-DG-007 | Open owner decisions for SLA, backup, retention, observability, rate-limit and device protocol are either closed or accepted as deferred risk. |

## 5. Open Owner Decisions

| decision_id | Related NFR | Decision needed | Impact |
|---|---|---|---|
| OD-TRACE-SLA | NFR-PERF-001 | Trace latency, volume, indexing/caching target | Performance test and DB/index design |
| OD-BACKUP-RTO | NFR-BACKUP-001 | RPO/RTO, backup frequency, restore drill scope | Release readiness and DevOps runbook |
| OD-RETENTION | NFR-RET-001 | Retention duration per data class | Archive schema, jobs, legal/compliance |
| OD-OBSERVABILITY | NFR-OBS-001 | Tooling, log/metric retention, escalation channel | Monitoring and incident operations |
| OD-RATE-LIMIT | NFR-SEC-002 | Exact thresholds for public/admin/login/MISA callback endpoints | Security and abuse protection |
| OD-PRINTER-PROTOCOL | NFR-DEVICE-001 | Printer/device protocol, callback auth and failure threshold | Print/QR safety and device operations |
