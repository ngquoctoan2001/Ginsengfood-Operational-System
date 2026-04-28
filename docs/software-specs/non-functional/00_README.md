# Non-Functional Pack README

## 1. Mục đích

Thư mục này là NFR pack active theo cấu trúc prompt gốc. Nội dung bao phủ security, audit, performance, backup/retention, observability, scalability, availability, idempotency, concurrency, transaction consistency, public/internal field policy và migration safety.

## 2. Active Files

| File | Nội dung |
|---|---|
| `01_NON_FUNCTIONAL_REQUIREMENTS.md` | NFR tổng hợp và mapping về `REQ-*`/`TC-*` |
| `02_PERFORMANCE_REQUIREMENTS.md` | Performance, trace SLA, recall, QR/print, seed/smoke |
| `03_SECURITY_REQUIREMENTS.md` | Authentication, authorization, public/private boundary, secret, destructive action |
| `04_AUDIT_LOGGING_REQUIREMENTS.md` | Audit, state transition, append-only evidence |
| `05_BACKUP_RETENTION_REQUIREMENTS.md` | Backup, restore, RPO/RTO, retention, archive |
| `06_OBSERVABILITY_REQUIREMENTS.md` | Logs, metrics, health, alerts, correlation |
| `07_SCALABILITY_AVAILABILITY_REQUIREMENTS.md` | Scalability, availability, concurrency, graceful degradation |

## 3. Source Discipline

- Chỉ dùng prompt gốc, `docs-software/`, `.tmp-docx-extract/`, các file đã chuẩn hóa trong `docs/software-specs/`, kiến thức chuyên môn có đánh dấu và owner approval.
- Không dùng source code, current database, `AGENTS.md`, hoặc `docs/ginsengfood_*` làm source-of-truth cho NFR pack này.
- Thư mục `3. non-functional/` là legacy/generated path, không phải path chuẩn active theo prompt gốc.

## 4. Owner Decisions

| decision | Liên quan |
|---|---|
| OD-TRACE-SLA | Performance/trace SLA, volume, cache/index |
| OD-BACKUP-RTO | Backup frequency, RPO/RTO, restore drill |
| OD-RETENTION | Retention/archive theo data class |
| OD-OBSERVABILITY | Logging/metrics/tracing stack, retention, escalation channel |
| OD-ARCHIVE-SEARCH | Search keys that must remain available after archive |
| OD-BACKUP-ENCRYPTION | Backup encryption, key management and restore credential owner |
| OD-LOG-RETENTION | Application/background-worker log retention and searchable history |
| OD-METRIC-RETENTION | Metrics retention for dashboard, alert and incident analysis |
| OD-ESCALATION | Alert channel, severity routing and escalation owner |
| OD-RATE-LIMIT | Exact public trace/admin/login/MISA callback thresholds; rate limiting itself is mandatory |
| OD-PRINTER-PROTOCOL | Printer/device protocol, callback auth, heartbeat and failure threshold |
