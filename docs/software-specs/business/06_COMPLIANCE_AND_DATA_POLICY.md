# Compliance And Data Policy

> Mục đích: xác định chính sách dữ liệu, public/internal boundary, retention/backup decision còn mở, và các nguyên tắc compliance để thiết kế DB/API/UI/test không lộ dữ liệu hoặc phá audit.

## 1. Data Classification

| data_class | Ví dụ | Visibility | Policy |
| --- | --- | --- | --- |
| `PUBLIC_TRACE` | SKU display name, batch public status, source zone public fields, production/release public summary | Public API | Whitelist-only, không suy ra từ internal view. |
| `INTERNAL_OPERATIONAL` | Raw lot, production order, material issue, QC result summary, warehouse receipt, trace graph | Internal users | Role-gated; audit sensitive actions. |
| `SENSITIVE_INTERNAL` | Supplier internal detail, personnel/user data, QC defect detail, loss/waste, costing, MISA/accounting data | Restricted internal | Không expose public; export cần permission riêng. |
| `AUDIT_HISTORY` | Audit log, state transition, approval log, override log | Restricted read-only | Append-only; retention owner chốt. |
| `LEDGER_HISTORY` | Inventory ledger, reversal, adjustment, lot balance projection | Restricted operational | Append-only ledger; balance derived/projection. |
| `INTEGRATION_DATA` | MISA mapping, sync log, retry/reconcile, external IDs | Restricted integration/accounting | Không để module nghiệp vụ sync trực tiếp. |
| `RECONCILE_DATA` | MISA reconcile record, manual retry reason, mismatch evidence, correction note | Restricted integration/accounting/audit | Append-only hoặc correction-linked; không xóa mismatch sau khi reconcile. |
| `DEVICE_INTEGRATION_DATA` | Device registry, printer token/reference, device auth attempt, print callback log, local agent id | Restricted operations/security | Device token/secret không public/log plaintext; callback không mutate business truth trực tiếp. |
| `EVIDENCE_FILE_METADATA` | Source origin evidence metadata, CAPA evidence metadata, file hash, MIME, size, scan status | Restricted internal | DB lưu metadata only; binary lưu qua storage adapter. Dev/test local filesystem; production company storage server. |
| `SNAPSHOT_DATA` | Production recipe snapshot, recall impact snapshot, print payload snapshot | Internal, immutable | Không mutate; correction tạo record mới. |
| `MASTER_DATA` | SKU, ingredient, UOM, supplier, warehouse, source zone | Internal admin; selected fields public | Inactive thay vì delete khi có transaction. |

## 2. Public Trace Field Policy

| field group | Public allowed? | Rule |
| --- | --- | --- |
| SKU/product display | Có | Chỉ field display được duyệt, không expose internal SKU config. |
| Batch/release public status | Có | Chỉ thông tin an toàn cho người dùng cuối. |
| Source zone public fields | Có | `source_zone_name`, `province`, `ward`, `address_detail` theo owner decision. |
| Supplier detail | Không | Supplier nội bộ/private không public. |
| Personnel/operator/approver | Không | Không expose tên nhân sự, user id, role nội bộ. |
| Costing/accounting/MISA | Không | Không expose giá vốn, bút toán, sync id private. |
| QC defect/loss/waste | Không | Không expose lỗi chi tiết hoặc loss; có thể expose "đã kiểm định/đạt" nếu policy cho phép. |
| Internal trace graph ids | Không | Public không trả raw lot ids, ledger ids, internal genealogy ids. |
| Recall public notice | Có nếu owner duyệt | Chỉ publish theo recall communication policy, không tự lộ internal root-cause. |

## 3. Data Ownership Boundary

| domain/object | Owner trong spec này | External reference only | Rule |
| --- | --- | --- | --- |
| Source zone/origin | Operational | N/A | Operational owner cho trace/source. |
| Raw material lot | Operational | N/A | Operational owner cho QC, issue, genealogy. |
| SKU identity | Transitional trong Operational | Catalog/Product owner dài hạn | Operational giữ `ref_sku` cho G1 baseline và transaction snapshot; không hard-code ownership dài hạn. |
| Recipe/version | Operational manufacturing | N/A | Operational owner vì phục vụ sản xuất/snapshot. |
| Batch/genealogy | Operational | N/A | Source of truth trace/recall. |
| Inventory ledger/lot balance | Operational | Commerce reads reference | Operational owner ledger/balance. |
| Shipment/customer exposure | External commerce/CRM | `shipment_id`, `customer_id`, `order_id`, `order_item_id` | Operational giữ reference để trace/recall, không copy customer master. |
| Notification | External notification/CRM | `notification_job_id` | Recall giữ reference, không owner notification delivery domain. |
| Accounting/MISA | MISA/integration layer | External IDs/status | Operational emits events; integration syncs. |
| Device/printer identity | Operational integration boundary | Driver/vendor/device details external | Operational lưu registry/callback evidence; token/secret quản lý như sensitive config. |
| Evidence binary storage | Storage adapter / company storage server | Object key/URI only | Operational DB owns evidence metadata and scan status; binary file server is infrastructure, not business truth. |

## 4. Retention And Backup Policy

| area | Policy status | Default documentation stance | Owner decision |
| --- | --- | --- | --- |
| Audit log retention | Chưa đủ thông tin | Không hard-code duration; design configurable. | OD-RETENTION |
| Inventory ledger retention | Chưa đủ thông tin | Treat as long-lived operational history; archive/search boundary cần chốt. | OD-RETENTION |
| Trace/recall history | Chưa đủ thông tin | Keep immutable snapshots; archive only with searchable index. | OD-RETENTION |
| MISA sync log | Chưa đủ thông tin | Retain enough for reconcile/audit; exact duration owner/devops chốt. | OD-RETENTION |
| Backup frequency | Chưa đủ thông tin | Require backup/restore runbook before release readiness. | OD-BACKUP-RTO |
| RPO/RTO | Chưa đủ thông tin | Mark as release blocker for CODE16/CODE17. | OD-BACKUP-RTO |

## 5. Compliance Rules

| policy_id | Policy | Affected module | Validation | Exception |
| --- | --- | --- | --- | --- |
| DP-001 | Public API dùng whitelist response, không serialize internal entity trực tiếp. | M12, M16 | Public trace test kiểm forbidden fields absent. | Không có exception. |
| DP-002 | Sensitive internal data export cần permission riêng và audit. | M01, M02, M12, M13 | Export action có permission + audit. | Owner có thể giới hạn export theo role. |
| DP-003 | Master data đã dùng trong transaction không hard delete. | M03, M04, M05 | Delete returns conflict; inactive allowed. | Approved archival sau retention policy. |
| DP-004 | Audit, ledger, snapshot, state history append-only. | M01, M07, M11, M12, M13 | Update/delete posted records blocked. | Correction/reversal only. |
| DP-005 | Integration credentials không lưu plaintext trong docs/API response. | M14 | Config references secret key, not value. | Dev fixture phải đánh dấu rõ. |
| DP-006 | MISA/private accounting data không public trace. | M12, M14 | Public trace leakage test. | Không có exception. |
| DP-007 | Recall communication public phải qua approved policy. | M13, M12 | Public recall banner/notice chỉ khi case policy cho phép. | Emergency owner approval. |
| DP-008 | PWA/offline submissions phải có idempotency và user/device/session metadata. | M16, M01 | Duplicate submit test. | Không có exception với issue/receipt. |
| DP-009 | Device token/secret và printer callback data là sensitive; không log plaintext và không trả qua public/admin list response nếu không cần. | M10, M14, M15 | Device security test kiểm token absent/masked; callback audit có correlation. | Debug tạm thời phải dùng secret reference và audit. |
| DP-010 | Reconcile data là evidence kế toán/tích hợp, không được hard delete sau khi resolved. | M14, M01 | Reconcile audit test kiểm original mismatch còn truy vết được. | Archive theo retention policy sau khi owner chốt. |
| DP-011 | Một trade item/package level chỉ có một active barcode/GTIN; barcode conflict không được in hoặc public trace. | M10, M12 | GTIN/barcode uniqueness test; print conflict test. | Fixture dev phải flag `TEST_ONLY_DEV_FIXTURE`. |
| DP-012 | Evidence binary không lưu trong DB; source verification và CAPA/recall close chỉ dùng evidence metadata có `scan_status = CLEAN`. | M05, M13 | Evidence upload/scan/close negative tests. | Local/dev/test có thể dùng mock/dev-skip scanner để tạo `CLEAN`; production phải dùng scanner thật. |

## 6. Testable Compliance Checks

| test_id | Scenario | Expected result |
| --- | --- | --- |
| TC-DP-001 | Gọi public trace với QR valid. | Response không có supplier, personnel, costing, QC defect, loss, MISA fields. |
| TC-DP-002 | Gọi public trace với QR `VOID`. | Không trả trace hợp lệ; không leak internal reason. |
| TC-DP-002B | Gọi public trace với QR `FAILED`. | Không trả trace hợp lệ; không leak internal reason. |
| TC-DP-003 | User thiếu permission export internal trace. | API trả `403`; audit permission denial nếu policy tracking bật. |
| TC-DP-004 | Thử xóa ingredient đã dùng trong recipe/lot. | Reject; cho inactive nếu business cho phép. |
| TC-DP-005 | Thử sửa posted inventory ledger. | Reject; hướng dùng adjustment/reversal. |
| TC-DP-006 | MISA mapping missing khi sync event phát sinh. | Event vào trạng thái failed/pending review; nghiệp vụ không gọi MISA trực tiếp. |
| TC-DP-007 | Backup/restore gate trước release. | Nếu OD-BACKUP-RTO chưa chốt thì CODE16/CODE17 không thể close hoàn toàn. |
| TC-DP-008 | Unregistered device hoặc device token failure gọi print callback. | Reject callback, audit security event, không đổi trạng thái print/QR thành công. |
| TC-DP-009 | Trade item có hai active barcode cùng package level. | Reject với `PRINT_TRADE_ITEM_BARCODE_CONFLICT`; không tạo print job. |
