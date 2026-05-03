# 07 - Owner Decision Closure For Coding

## 1. Mục Đích

File này gom các quyết định còn ảnh hưởng trực tiếp đến coding, seed, migration, API test, E2E smoke và production freeze.

PF-02 đã đóng nhóm dữ liệu/cấu hình production bằng cơ chế config/secret references có owner rõ ràng. Repo không chứa secret thật. Dev/test fixture vẫn được phép tồn tại, nhưng phải gắn `DEV_TEST_ONLY` và không được dùng làm production truth.

## 2. PF-02 Production Freeze Status

Ngày freeze: 2026-05-03

| area | production freeze status | owner vận hành | production config/secret refs | dev/test fixture policy |
|---|---|---|---|---|
| GTIN/GS1 | READY_FOR_PRODUCTION_FREEZE | Packaging/Commercial Ops | GTIN thật import qua data/config production; `op_trade_item_gtin.is_test_fixture=false`; PACKET không có QR/GTIN bắt buộc theo PF-01, BOX/CARTON dùng GTIN/SSCC nếu có | `gtin_fixture.csv` là `DEV_TEST_ONLY`; tất cả row `is_test_fixture=true`; production print phải block |
| MISA AMIS | READY_FOR_PRODUCTION_FREEZE_WITH_SECRET_REFS | Finance/Accounting Integration + DevOps | `MisaSyncOptions.Mode`, `BaseUrl`, `TenantId`, `ClientId`, `ClientSecretRef`, `WebhookSecretRef`; object mapping qua `misa_mapping` | `misa_mapping_fixture.csv` là `DEV_TEST_ONLY`; dry-run/fake mapping không chứa endpoint/credential thật |
| Printer/device | READY_FOR_PRODUCTION_FREEZE_WITH_DEVICE_REFS | Packaging Ops + DevOps | `PrinterOptions.Protocol=HTTP_ZPL`, `CallbackAuth=HMAC_SHA256`, `DeviceSecretRef`, device registry (`device_code`, `model`, `endpoint`) | Local/emulator adapter là `DEV_TEST_ONLY`; callback phải qua API, không direct DB |
| Evidence storage | READY_FOR_PRODUCTION_FREEZE | DevOps + Security | `EvidenceStorage.Provider=COMPANY_SERVER`, `BasePathOrBucket`, `EncryptionKeyRef`, `AccessLogSinkRef`, backup policy ref | Local filesystem là `DEV_TEST_ONLY`; object key/metadata vẫn giống production |
| Notification | READY_FOR_PRODUCTION_FREEZE | Recall Owner + Sales/Notification system owner | Operational chỉ tạo `notification_job_id`/outbox event `NOTIFICATION_REQUESTED`; delivery do hệ thống bán hàng/notification xử lý | Smoke có thể dùng fake consumer; SLA Operational đo tại thời điểm outbox/job created |
| Backup/DR | READY_FOR_PRODUCTION_FREEZE | DevOps + DBA | DB RPO 15 phút/RTO 4 giờ; evidence files RPO 1 giờ/RTO 8 giờ; audit/outbox RPO 5 phút/RTO 2 giờ; restore drill trước production | Local backup scripts chỉ phục vụ dev/test, không thay thế restore drill production |
| Retention/archive | READY_FOR_PRODUCTION_FREEZE | Compliance + DevOps | Transaction/ledger/audit/trace giữ tối thiểu 7 năm; recall/CAPA/evidence metadata 10 năm; MISA sync/reconcile 5 năm; request/outbox operational logs 90 ngày active rồi archive | Archive test dùng fixture nhưng phải giữ search keys giống production |
| Production users/roles | READY_FOR_PRODUCTION_FREEZE | Admin/HR/Ops owner | Action permission baseline từ `roles_permissions.csv` không đổi theo môi trường; user-role assignment thật import/config riêng | User fixture/supplier fixture là `DEV_TEST_ONLY`; không commit account/secret thật |

## 3. Mapping Về OD Chuẩn

| data decision | maps to OD | nội dung | block area | trạng thái coding/freeze |
|---|---|---|---|---|
| DATA-OD-ING-CODE | DATA local | Có dùng generated `ingredient_code` hay map sang mã nguyên liệu/kho/ERP chính thức? | Production seed, recipe editor, material issue, trace | READY_FOR_PRODUCTION_FREEZE_WITH_DATA_STEWARDSHIP_REVIEW; production master-data review là data stewardship và không block scaffold |
| DATA-OD-G1-EFFECTIVE-DATE | DATA local | Ngày hiệu lực production thật của G1 baseline là ngày nào? | Recipe activation, production order snapshot, audit | READY_FOR_PRODUCTION_FREEZE; dev/test dùng technical date, production có thể override effective date bằng approved seed import |
| DATA-OD-GTIN-REAL | Owner commercial/GS1 | GTIN thật cho level BOX/CARTON; PACKET không in QR và không cần standalone trace | Packaging, QR, public trace, commercial print | RESOLVED_FINAL_PF02; production rows phải `is_test_fixture=false`; fixture `DEV_TEST_ONLY` |
| DATA-OD-MISA-PROD | OD-20 implementation detail | MISA AMIS tenant, endpoint, credential, object code mapping thật | MISA sync, reconcile, accounting handoff | RESOLVED_FINAL_PF02_WITH_SECRET_REFS; không commit secret thật |
| DATA-OD-TRACE-SLA | OD-11 | Trace query technical SLA | Trace index/query, performance test | RESOLVED_FINAL_PF01; metric đo trong CODE07/CODE17 |
| DATA-OD-DR | OD-12 | RPO/RTO backup/DR | CODE16, release rollback | RESOLVED_FINAL_PF02; xem `non-functional/05_BACKUP_RETENTION_REQUIREMENTS.md` |
| DATA-OD-AUDIT-RETENTION | OD-13 | Audit retention/archive | CODE16, compliance | RESOLVED_FINAL_PF02; xem retention table |
| DATA-OD-PUBLIC-I18N | OD-14 | Public trace multi-language | Public DTO/UI/copy | RESOLVED_FINAL_PF01; MVP tiếng Việt, schema i18n-ready |
| DATA-OD-PRINTER | OD-17 | Printer model/driver/callback protocol | Print job, label rendering, QR lifecycle | RESOLVED_FINAL_PF02_WITH_DEVICE_REFS; adapter HTTP_ZPL + HMAC callback baseline |
| DATA-OD-QC-STAFFING | OD-R-03 | QC raw/finished staffing có thể một người kiêm nhiệm | RBAC seed/user assignment | READY_FOR_PRODUCTION_FREEZE; action permission cố định, assignment user thật cấu hình riêng |
| DATA-OD-LOT-MARK-READY-PERMISSION | DATA local / OD-R-03 | Ai có quyền `RAW_LOT_MARK_READY` sau khi raw QC pass? | CODE02 readiness, RBAC seed, smoke test | RESOLVED_FINAL; `R-QA-REL` và `R-OPS-MGR` có quyền; production đổi user assignment, không đổi action |

## 4. Quyết Định Có Thể Defer

| decision_id | nội dung | defer được đến | điều kiện an toàn |
|---|---|---|---|
| DATA-DEF-001 | Public trace multi-language ngoài tiếng Việt | Sau MVP public trace tiếng Việt | Public trace policy vẫn allowlist-only và DTO i18n-ready |
| DATA-DEF-002 | PWA offline taxonomy chi tiết | Sau khi admin workflow API ổn định | PWA-first command/idempotency contract vẫn có |
| DATA-DEF-003 | Exact dashboard metric catalogue | Sau khi operational events/ledger ổn định | Event baseline đã seed |
| DATA-DEF-004 | MISA reconcile UI nâng cao | Sau sync event/retry baseline | Missing mapping vẫn thành reconcile pending |
| DATA-DEF-005 | GTIN thật từng SKU | Có thể import sát go-live | Không cho production print nếu mapping còn `is_test_fixture=true` |

## 5. Coding Readiness

| area | readiness | điều kiện |
|---|---|---|
| Foundation/Core | READY_FOR_PRODUCTION_FREEZE | Không phụ thuộc owner data mới |
| Auth/RBAC | READY_FOR_PRODUCTION_FREEZE | Dùng `roles_permissions.csv` làm action baseline; user-role assignment production import riêng |
| UOM/reference | READY_FOR_PRODUCTION_FREEZE | `uom.csv` có 11 UOM required |
| Master Data/SKU/Ingredient | READY_FOR_PRODUCTION_FREEZE_WITH_DATA_STEWARDSHIP_REVIEW | Cần DATA-OD-ING-CODE review trước production master-data cutover, không block schema/API scaffold |
| Recipe G1/G2 seed model | READY_FOR_PRODUCTION_FREEZE | 20 headers + 433 G1 lines là derived validation; G1/G2 coexist model đã freeze ở PF-01 |
| Source/procurement fixture | READY_FOR_PRODUCTION_FREEZE_WITH_DEV_TEST_FIXTURE | `SELF_GROWN` verified và `PURCHASED` supplier path có fixture; production supplier/source import riêng |
| Production order snapshot | READY_FOR_PRODUCTION_FREEZE | Dùng recipe snapshot contract; không dùng fixture làm snapshot truth |
| Material issue/receipt | READY_FOR_PRODUCTION_FREEZE | Dựa vào snapshot + ingredient + warehouse seed; issue chỉ chọn raw lot `READY_FOR_PRODUCTION` |
| Process events | READY_FOR_PRODUCTION_FREEZE | Smoke/API fixture yêu cầu `PREPROCESSING -> FREEZING -> FREEZE_DRYING` |
| QC/Release | READY_FOR_PRODUCTION_FREEZE | `QC_PASS != RELEASED`; release tạo `op_batch_release` |
| Warehouse/Inventory | READY_FOR_PRODUCTION_FREEZE | Warehouse/zone model đã freeze; fixture chỉ là baseline |
| GTIN/GS1 | READY_FOR_PRODUCTION_FREEZE_WITH_DATA_IMPORT | Production rows owner-provided và `is_test_fixture=false`; fixture `DEV_TEST_ONLY` |
| Trace/Public Trace | READY_FOR_PRODUCTION_FREEZE | Field policy + SLA + i18n MVP đã freeze; no private leakage |
| Recall | READY_FOR_PRODUCTION_FREEZE | Notification boundary là outbox/job only; CAPA evidence dùng storage adapter/scan gate |
| MISA | READY_FOR_PRODUCTION_FREEZE_WITH_SECRET_REFS | Dry-run/dev fixture cho test; production mode chỉ bật khi secret refs và mapping thật có owner |
| Printing/QR | READY_FOR_PRODUCTION_FREEZE_WITH_DEVICE_REFS | PACKET không QR; BOX/CARTON print block fixture GTIN; device callback HMAC |
| Evidence storage | READY_FOR_PRODUCTION_FREEZE_WITH_STORAGE_REFS | Dev/test local FS; production company storage server qua config |
| Backup/DR | READY_FOR_PRODUCTION_FREEZE | RPO/RTO/restore drill baseline đã freeze |
| Retention/archive | READY_FOR_PRODUCTION_FREEZE | Retention class và archive search boundary đã freeze |

## 6. Khuyến Nghị Phase Tiếp Theo

| next_step | mô tả | done gate |
|---|---|---|
| CODE-READY-01 | Viết seed loader đọc CSV theo business key và `UTF-8` | Import được toàn bộ CSV trong data pack, chạy lại không duplicate |
| CODE-READY-02 | Viết seed validation test từ `04_SEED_VALIDATION_QUERIES.md` | SV-001 đến SV-018 pass |
| CODE-READY-03 | Viết API fixture tests từ `06_API_EXAMPLE_FIXTURES.md` | Command payload và error payload ổn định |
| CODE-READY-04 | Viết E2E smoke test theo `05_E2E_SMOKE_FIXTURE.md` | Chạy được full chain source -> raw -> PO -> issue -> process -> QC -> release -> warehouse -> trace |
| CODE-READY-05 | Owner review `ingredients.csv` và generated ingredient codes | DATA-OD-ING-CODE resolved trước production seed cutover |
| CODE-READY-06 | Implement production config binding | GTIN import, MISA secret refs, printer device refs, storage refs, backup refs đều có validation, không có literal secret |
| CODE-READY-07 | Owner review final user assignment cho `RAW_LOT_MARK_READY` | Không đổi coding baseline nếu chỉ thay user-role mapping; vẫn giữ permission riêng khỏi `RAW_QC_SIGN` |

## 7. PF-02 Done Gate

- Dev/test fixture còn trong repo phải có `DEV_TEST_ONLY` trong status/notes hoặc cột tương đương (`is_test_fixture=true`, `is_dev_fixture=true`) và không được promote tự động lên production.
- Production-required values dùng data import, config ref hoặc secret ref có owner: GTIN/GS1, MISA, printer/device, evidence storage, notification outbox consumer, backup/DR, retention/archive, production user assignment.
- Không commit secret thật, token thật, private key, password hoặc endpoint credential thật vào repo.
- Production readiness không yêu cầu chỉnh code nếu chỉ thay giá trị tenant/endpoint/credential/device/storage/user assignment qua config hợp lệ.
