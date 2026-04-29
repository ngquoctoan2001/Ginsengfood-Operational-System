# Data Retention Policy

> Mục đích: phân loại retention/archive/restore theo data class. Các thời hạn cụ thể còn `OWNER DECISION NEEDED` nếu source chưa chốt.

## 1. Retention Classes

| data_class | Tables | Retention stance | Owner decision |
| --- | --- | --- | --- |
| Master data | `ref_*`, `op_supplier`, `op_warehouse`, `op_source_zone`, `op_trade_item` | Không hard delete nếu đã dùng; inactive thay delete. | Không |
| Transaction data | PO, issue, receipt, QC, packaging, warehouse, recall | Long-lived operational history; archive sau khi owner chốt và không thấp hơn regulatory floor cho hồ sơ sản xuất thực phẩm. | OD-RETENTION |
| Ledger data | `op_inventory_ledger` | Append-only; retention dài hạn hoặc archive searchable. | OD-RETENTION |
| Audit/history | `audit_log`, `state_transition_log`, `op_qr_state_history`, `op_print_log`, `op_form_action_log`, `op_recall_timeline` | Append-only; duration cần owner/compliance chốt. | OD-RETENTION |
| PO snapshot data | `op_production_order_item` | Immutable operational recipe/ingredient snapshot; retain with production order/batch history. | OD-RETENTION |
| Print snapshot data | `op_print_job.print_payload_snapshot` | Immutable print payload evidence; retain through QR lifecycle and longer if tied to recall/incident. | OD-RETENTION |
| Recall snapshot data | `op_recall_exposure_snapshot` | Immutable recall impact evidence; retain until recall legally closed plus compliance period. `CLOSED_WITH_RESIDUAL_RISK` evidence should not be purged without owner/compliance approval. | OD-RETENTION |
| Evidence metadata/file refs | `op_source_origin_evidence`, `op_recall_capa_evidence` plus configured storage object/file refs | Metadata retained with source/recall history; binary retained in storage adapter/company storage server according to the same compliance class. Dev/test local evidence can be disposable only when marked fixture/non-production. | OD-RETENTION |
| Integration data | MISA sync/reconcile/outbox/event store | Giữ đủ cho reconcile/audit; duration owner chốt. | OD-RETENTION |
| Public projection | `vw_public_traceability`, trace policy/index | Derived; rebuildable nếu internal truth còn. | OD-TRACE-SLA, OD-RETENTION |
| Backup/restore logs | restore drill/logs | Required before release readiness. | OD-BACKUP-RTO |

## 2. Archive Rules

| rule_id | Rule |
| --- | --- |
| RET-001 | Không archive ledger/audit/trace nếu làm mất khả năng recall hoặc regulatory evidence. |
| RET-002 | Archive phải giữ searchable index tối thiểu theo batch, lot, QR, recall case, date. |
| RET-003 | Restore drill phải chứng minh trace/recall chain còn query được sau restore. |
| RET-004 | Public trace projection có thể rebuild từ internal truth nếu policy/version còn. |
| RET-005 | Deletion/anonymization chỉ áp dụng external personal data references nếu owner/compliance yêu cầu; Operational không owner customer master. |
| RET-006 | `CLOSED_WITH_RESIDUAL_RISK` recall evidence, residual note, approver, CAPA and exposure snapshot are retained at product-liability level; no routine archive/purge until explicit owner/compliance decision. |
| RET-007 | OD-RETENTION decides duration above the regulatory floor; it must not reduce required food production, QC, batch, issue, receipt, trace or recall evidence below applicable CGMP/ISO 22000/TCVN policy. |
| RET-008 | Evidence binary retention must keep DB metadata and storage object/file lifecycle aligned; a metadata row must not point to a purged production object unless an approved archive pointer replaces it. |

## 3. Backup / Restore Open Decisions

| decision | Needed for |
| --- | --- |
| RPO | Frequency and acceptable data loss. |
| RTO | Restore time objective and runbook. |
| Backup location/encryption | Production deployment. |
| Evidence storage backup | Company storage server backup/encryption/restore drill for production evidence files. |
| Restore drill cadence | CODE16/CODE17 release gate, meaning production readiness gate before factory go-live and final handover. |
| Archive storage | Retention and cost model. |
