# Data Retention Policy

> Mục đích: phân loại retention/archive/restore theo data class. PF-02 đã freeze baseline thời hạn retention, RPO/RTO và archive search boundary cho production.

## 1. Retention Classes

| data_class | Tables | Retention stance | Owner decision |
| --- | --- | --- | --- |
| Master data | `ref_*`, `op_supplier`, `op_warehouse`, `op_source_zone`, `op_trade_item` | Không hard delete nếu đã dùng; inactive thay delete. | Không |
| Transaction data | PO, issue, receipt, QC, packaging, warehouse, recall | Retain active/searchable 7 years minimum; archive with trace keys and no destructive delete during active retention. | RESOLVED_PF02 |
| Ledger data | `op_inventory_ledger` | Append-only; active/searchable 7 years minimum; archive remains searchable by lot/batch/date. | RESOLVED_PF02 |
| Audit/history | `audit_log`, `state_transition_log`, `op_qr_state_history`, `op_print_log`, `op_form_action_log`, `op_recall_timeline` | Append-only; retain 7 years minimum; recall/CAPA/high-risk audit 10 years. | RESOLVED_PF02 |
| PO snapshot data | `op_production_order_item` | Immutable operational recipe/ingredient snapshot; retain with production order/batch history for 7 years minimum. | RESOLVED_PF02 |
| Print snapshot data | `op_print_job.print_payload_snapshot` | Immutable print payload evidence; retain through QR lifecycle and 7 years minimum, 10 years if tied to recall/incident. | RESOLVED_PF02 |
| Recall snapshot data | `op_recall_exposure_snapshot` | Immutable recall impact evidence; retain 10 years; `CLOSED_WITH_RESIDUAL_RISK` evidence is not routine-purged. | RESOLVED_PF02 |
| Evidence metadata/file refs | `op_source_origin_evidence`, `op_raw_material_receipt_evidence`, `op_recall_capa_evidence` plus configured storage object/file refs | Metadata retained with source/receipt/recall history; recall/CAPA evidence 10 years. Binary retained in company storage server with aligned backup lifecycle. Dev/test local evidence can be disposable only when marked `DEV_TEST_ONLY`. | RESOLVED_PF02 |
| Integration data | MISA sync/reconcile/outbox/event store | MISA sync/reconcile retained 5 years; outbox operational request logs 90 days active then archive; payload redacted. | RESOLVED_PF02 |
| Public projection | `vw_public_traceability`, trace policy/index | Derived; rebuildable if internal truth remains; active QR/product lifecycle plus 7 years archive. | RESOLVED_PF02 |
| Backup/restore logs | restore drill/logs | Pre-go-live restore drill plus quarterly drill record retained 5 years. | RESOLVED_PF02 |

## 2. Archive Rules

| rule_id | Rule |
| --- | --- |
| RET-001 | Không archive ledger/audit/trace nếu làm mất khả năng recall hoặc regulatory evidence. |
| RET-002 | Archive phải giữ searchable index tối thiểu theo batch, lot, QR, recall case, date. |
| RET-003 | Restore drill phải chứng minh trace/recall chain còn query được sau restore. |
| RET-004 | Public trace projection có thể rebuild từ internal truth nếu policy/version còn. |
| RET-005 | Deletion/anonymization chỉ áp dụng external personal data references nếu owner/compliance yêu cầu; Operational không owner customer master. |
| RET-006 | `CLOSED_WITH_RESIDUAL_RISK` recall evidence, residual note, approver, CAPA and exposure snapshot are retained at product-liability level; no routine archive/purge until explicit owner/compliance decision. |
| RET-007 | PF-02 decides baseline duration above the regulatory floor; later owner ADR may extend, but must not reduce required food production, QC, batch, issue, receipt, trace or recall evidence below applicable CGMP/ISO 22000/TCVN policy. |
| RET-008 | Evidence binary retention must keep DB metadata and storage object/file lifecycle aligned; a metadata row must not point to a purged production object unless an approved archive pointer replaces it. |

## 3. PF-02 Backup / Restore Closed Decisions

| decision | PF-02 baseline |
| --- | --- |
| RPO | DB 15 minutes; evidence files 1 hour; audit/outbox critical state 5 minutes. |
| RTO | DB 4 hours; evidence files 8 hours; audit/outbox dispatch visibility 2 hours. |
| Backup location/encryption | Production deployment supplies backup target refs and encryption key refs through DevOps/Security; no key in repo. |
| Evidence storage backup | Company storage server backup/encryption/restore drill includes M05/M06/M13 evidence files. |
| Restore drill cadence | Mandatory pre-go-live drill and quarterly drill after go-live. |
| Archive storage | Archive must preserve search by `batch_code`, `lot_code`, `qr_code`/hash, `sku_code`, `recall_case_id`, `date_range`, `misa_sync_event_id`. |
