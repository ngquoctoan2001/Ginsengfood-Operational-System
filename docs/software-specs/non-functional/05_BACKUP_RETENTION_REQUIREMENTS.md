# 05 - Backup Retention Requirements

## 1. Mục tiêu

Định nghĩa yêu cầu backup, restore, RPO/RTO, retention, archival và restore drill. PF-02 đã freeze baseline production cho RPO/RTO, retention duration, archive search boundary và restore drill owner.

## 2. Backup Requirements

| backup_id | requirement | module | priority | validation | owner decision |
|---|---|---|---|---|---|
| BCK-001 | Database backup schedule must be defined before release readiness. | M01, M15 | P2 | Backup job evidence and restore drill log | RESOLVED_PF02: DevOps/DBA owner |
| BCK-002 | RPO/RTO must be approved by owner/DevOps. | M01, M15 | P2 | RPO/RTO documented and tested | RESOLVED_PF02: DB RPO 15m/RTO 4h; evidence RPO 1h/RTO 8h; audit/outbox RPO 5m/RTO 2h |
| BCK-003 | Backup must include operational transaction, ledger, audit, QR/print history, device registry/history, trace, recall, evidence metadata and MISA sync data. Binary evidence backup uses the configured storage server path, not DB blob backup. | M01, M05, M10, M11, M12, M13, M14, M15 | P0 | Restore drill validates trace/recall/ledger/QR-print/device/evidence continuity | RESOLVED_PF02: company storage server backup included |
| BCK-004 | Backup secrets/credentials must not be exposed in logs/artifacts. | M14, M15 | P0 | Secret scan/review | RESOLVED_PF02: secret refs only; no literal secret in backup log/artifact |
| BCK-005 | Restore drill must be executed before production readiness. | M01, M15 | P1 | Restore drill record with timestamp/result | RESOLVED_PF02: quarterly drill, plus mandatory pre-go-live drill |

PF-02 operational defaults:

- PostgreSQL: PITR/WAL or equivalent continuous backup targeting RPO 15 minutes, daily full/snapshot backup, restore target RTO 4 hours.
- Evidence company storage server: hourly backup/snapshot or equivalent replication targeting RPO 1 hour, restore target RTO 8 hours.
- Audit/outbox critical integration state: backup/replication targeting RPO 5 minutes, restore target RTO 2 hours for operational dispatch visibility.
- Restore drill owner: DevOps/DBA executes; QA/Recall owner validates trace/recall/evidence continuity; Finance/Integration validates MISA continuity.

## 3. Retention Data Classes

| data_class | Examples | Retention policy | Owner decision |
|---|---|---|---|
| Master data | SKU, ingredient, UOM, warehouse, supplier, source zone | Keep while referenced; inactive instead of delete; archive versions after 7 years inactive if unreferenced | RESOLVED_PF02 |
| Transaction data | PO, issue, receipt, QC, release, warehouse receipt | Retain active/searchable 7 years minimum, then archive with trace keys | RESOLVED_PF02 |
| Ledger data | Inventory ledger, balance rebuild evidence | Append-only; retain active/searchable 7 years minimum; archive without destructive deletion | RESOLVED_PF02 |
| Audit/history | Audit log, state transition, QR history | Append-only; retain 7 years minimum; high-risk audit retained 10 years if tied to recall/CAPA | RESOLVED_PF02 |
| Trace/recall | Trace link, public trace projection, recall snapshot, CAPA, CAPA evidence metadata and binary refs | Recall/CAPA/evidence metadata retained 10 years; binary files backed up from storage adapter/company storage server | RESOLVED_PF02 |
| Integration logs | MISA sync event/log/reconcile | Retain 5 years active/archive for accounting/reconcile audit; payload remains redacted | RESOLVED_PF02 |
| Public data | Public trace response/projection | Retain while QR/product lifecycle is active plus 7 years archive, still following public field policy | RESOLVED_PF02 |
| Sensitive/private data | Personnel, supplier, cost, QC defect/loss, internal notes | Restricted access; archive/search by permission; no public trace exposure; minimum follows owning data class | RESOLVED_PF02 |

## 4. Archive Requirements

| archive_id | requirement | validation |
|---|---|---|
| ARC-001 | Archive must preserve ability to trace by approved minimum keys: `batch_code`, `lot_code`, `qr_code`/hash, `sku_code`, `recall_case_id`, `date_range`. | Archived trace search test |
| ARC-002 | Archive must not break audit evidence chain. | Audit query across active/archive |
| ARC-003 | Archive restore must be logged and permission-gated. | Restore audit test |
| ARC-004 | Public trace for archived product must follow public field policy. | Public trace archive test |

## 5. Restore Drill Scope

Minimum restore drill before release readiness:

1. Restore database to isolated environment.
2. Validate schema and migration version.
3. Validate seed baseline with explicit counts: 20 SKU, 433 G1 recipe lines, 0 active G0 and SKU config points to active G1 `PILOT_PERCENT_BASED`.
4. Validate inventory ledger and balance projection for sample lot.
5. Validate QR/print history and device registry/history for sample packaging unit.
6. Validate internal trace chain for sample batch/QR.
7. Validate recall impact snapshot and CAPA evidence metadata can be read; validate referenced evidence file exists in configured storage backup/restore target.
8. Validate public trace denylist.
9. Validate MISA sync/reconcile log continuity.

## 6. PF-02 Closed Decisions

| decision_id | Canonical tracker ID | PF-02 decision |
|---|---|---|
| OD-BACKUP-RTO | OD-12 | DevOps/DBA owner. DB RPO 15m/RTO 4h; evidence files RPO 1h/RTO 8h; audit/outbox RPO 5m/RTO 2h. |
| OD-RETENTION | OD-13 | Transaction/ledger/audit/trace 7 years minimum; recall/CAPA/evidence metadata 10 years; MISA sync/reconcile 5 years; request/outbox operational logs 90 days active then archive. |
| OD-ARCHIVE-SEARCH | OD-13-SUB-ARCHIVE-SEARCH | Archive search keys remain online/restore-queryable: `batch_code`, `lot_code`, `qr_code`/hash, `sku_code`, `recall_case_id`, `date_range`, `misa_sync_event_id`. |
| OD-BACKUP-ENCRYPTION | OD-12-SUB-BACKUP-ENCRYPTION | Backup encryption/key refs owned by DevOps/Security; keys/secrets stored outside repo and never logged. |

Rule: descriptive `OD-*` values in this NFR file are aliases. The canonical owner decision tracker uses `OD-12` for backup/DR and `OD-13` for retention; PF-02 closes these aliases for production freeze unless a later owner ADR supersedes them.
