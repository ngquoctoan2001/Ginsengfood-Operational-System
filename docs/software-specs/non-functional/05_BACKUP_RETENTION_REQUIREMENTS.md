# 05 - Backup Retention Requirements

## 1. Mục tiêu

Định nghĩa yêu cầu backup, restore, RPO/RTO, retention, archival và restore drill. Các số đo RPO/RTO và retention duration cần owner quyết định trước production readiness.

## 2. Backup Requirements

| backup_id | requirement | module | priority | validation | owner decision |
|---|---|---|---|---|---|
| BCK-001 | Database backup schedule must be defined before release readiness. | M01, M15 | P2 | Backup job evidence and restore drill log | OWNER DECISION NEEDED |
| BCK-002 | RPO/RTO must be approved by owner/DevOps. | M01, M15 | P2 | RPO/RTO documented and tested | OWNER DECISION NEEDED |
| BCK-003 | Backup must include operational transaction, ledger, audit, QR/print history, device registry/history, trace, recall, evidence metadata and MISA sync data. Binary evidence backup uses the configured storage server path, not DB blob backup. | M01, M05, M10, M11, M12, M13, M14, M15 | P0 | Restore drill validates trace/recall/ledger/QR-print/device/evidence continuity | OWNER DECISION NEEDED |
| BCK-004 | Backup secrets/credentials must not be exposed in logs/artifacts. | M14, M15 | P0 | Secret scan/review | OWNER DECISION NEEDED |
| BCK-005 | Restore drill must be executed before production readiness. | M01, M15 | P1 | Restore drill record with timestamp/result | OWNER DECISION NEEDED |

## 3. Retention Data Classes

| data_class | Examples | Retention policy | Owner decision |
|---|---|---|---|
| Master data | SKU, ingredient, UOM, warehouse, supplier, source zone | Keep while referenced; inactive instead of delete | Duration/version archive needed |
| Transaction data | PO, issue, receipt, QC, release, warehouse receipt | Retain for trace/recall/legal period; food-safety compliance defines the minimum floor, owner only decides retention beyond that floor | OWNER DECISION NEEDED |
| Ledger data | Inventory ledger, balance rebuild evidence | Append-only; no destructive deletion in active retention | OWNER DECISION NEEDED |
| Audit/history | Audit log, state transition, QR history | Append-only; archive after approved duration | OWNER DECISION NEEDED |
| Trace/recall | Trace link, public trace projection, recall snapshot, CAPA, CAPA evidence metadata and binary refs | Retain enough for recall/legal exposure; binary files backed up from storage adapter/company storage server | OWNER DECISION NEEDED |
| Integration logs | MISA sync event/log/reconcile | Retain enough for accounting/reconcile audit | OWNER DECISION NEEDED |
| Public data | Public trace response/projection | Retain by product/QR lifecycle policy | OWNER DECISION NEEDED |
| Sensitive/private data | Personnel, supplier, cost, QC defect/loss, internal notes | Restricted access, archive/search by permission | OWNER DECISION NEEDED |

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
3. Validate seed baseline with explicit counts: 20 SKU, 433 G1 recipe lines, 0 active G0 and SKU config points to G1.
4. Validate inventory ledger and balance projection for sample lot.
5. Validate QR/print history and device registry/history for sample packaging unit.
6. Validate internal trace chain for sample batch/QR.
7. Validate recall impact snapshot and CAPA evidence metadata can be read; validate referenced evidence file exists in configured storage backup/restore target.
8. Validate public trace denylist.
9. Validate MISA sync/reconcile log continuity.

## 6. Open Decisions

| decision_id | Decision |
|---|---|
| OD-BACKUP-RTO | RPO/RTO and backup frequency |
| OD-RETENTION | Retention duration by data class |
| OD-ARCHIVE-SEARCH | Which archived search fields must remain online |
| OD-BACKUP-ENCRYPTION | Backup encryption/key management owner |
