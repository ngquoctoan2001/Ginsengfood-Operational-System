# 07 - Owner Decision Closure For Coding

## 1. Mục Đích

File này gom các quyết định còn ảnh hưởng trực tiếp đến coding, seed, migration, API test và E2E smoke.

Dev có thể bắt đầu foundation/dev seed khi các quyết định production chưa khóa không ảnh hưởng trực tiếp. Production seed, MISA production, public trace production, printer production và CODE16 không được coi là go-live ready nếu owner decision còn mở.

## 2. Mapping Về OD Chuẩn

| data decision | maps to OD | nội dung | block area | trạng thái coding |
|---|---|---|---|---|
| DATA-OD-ING-CODE | DATA local | Có dùng generated `ingredient_code` hay map sang mã nguyên liệu/kho/ERP chính thức? | Production seed, recipe editor, material issue, trace | Dev/QA dùng generated code; production cần owner/master-data review |
| DATA-OD-G1-EFFECTIVE-DATE | DATA local | Ngày hiệu lực production thật của G1 baseline là ngày nào? | Recipe activation, production order snapshot, audit | Dev/QA dùng technical date trong CSV |
| DATA-OD-GTIN-REAL | Owner commercial/GS1 | GTIN thật cho 20 SKU ở level BOX/CARTON | Packaging, QR, public trace, commercial print | Dev dùng `gtin_fixture.csv` với `is_test_fixture=true`; production phải thay bằng GTIN thật |
| DATA-OD-MISA-PROD | OD-04 implementation detail | MISA AMIS tenant, endpoint, credential, object code mapping thật | MISA sync, reconcile, accounting handoff | Dev dùng fixture; không commit secret |
| DATA-OD-TRACE-SLA | OD-11 | Trace query technical SLA | Trace index/query, performance test | Không block seed; block performance freeze |
| DATA-OD-DR | OD-12 | RPO/RTO backup/DR | CODE16, release rollback | Không block dev seed; block hardening/go-live |
| DATA-OD-AUDIT-RETENTION | OD-13 | Audit retention/archive | CODE16, compliance | Không block dev seed; block retention/archive design |
| DATA-OD-PUBLIC-I18N | OD-14 | Public trace multi-language | Public DTO/UI/copy | Defer sau MVP tiếng Việt nếu owner chưa chốt |
| DATA-OD-PRINTER | OD-17 | Printer model/driver chính thức | Print job, label rendering, QR lifecycle | Code abstraction trước; production cần driver thật |
| DATA-OD-QC-STAFFING | OD-R-03 | QC raw/finished staffing có thể một người kiêm nhiệm | RBAC seed/user assignment | Seed role riêng; assign nhiều role cho cùng user nếu cần |
| DATA-OD-LOT-MARK-READY-PERMISSION | DATA local / OD-R-03 | Ai có quyền `RAW_LOT_MARK_READY` sau khi raw QC pass? | CODE02 readiness, RBAC seed, smoke test | ACCEPTED_FOR_DEV: `R-QA-REL` và `R-OPS-MGR` có quyền mark-ready; production có thể review user assignment |

## 3. Quyết Định Có Thể Defer

| decision_id | nội dung | defer được đến | điều kiện an toàn |
|---|---|---|---|
| DATA-DEF-001 | Public trace multi-language | Sau MVP public trace tiếng Việt | Public trace policy vẫn allowlist-only |
| DATA-DEF-002 | PWA offline taxonomy chi tiết | Sau khi admin workflow API ổn định | PWA-first command/idempotency contract vẫn có |
| DATA-DEF-003 | Exact dashboard metric catalogue | Sau khi operational events/ledger ổn định | Event baseline đã seed |
| DATA-DEF-004 | MISA reconcile UI nâng cao | Sau sync event/retry baseline | Missing mapping vẫn thành reconcile pending |
| DATA-DEF-005 | Production GTIN thật | Trước commercial print/go-live | Dev/test chỉ dùng fixture flagged `is_test_fixture=true` |

## 4. Coding Readiness

| area | readiness | điều kiện |
|---|---|---|
| Foundation/Core | READY | Không phụ thuộc owner data mới |
| Auth/RBAC | READY_FOR_BASELINE | Dùng `roles_permissions.csv`; role logic vẫn tách riêng theo OD-R-03; `RAW_LOT_MARK_READY` được seed riêng cho `R-QA-REL` và `R-OPS-MGR` |
| UOM/reference | READY | `uom.csv` có 11 UOM required |
| Master Data/SKU/Ingredient | READY_FOR_DEV | Cần DATA-OD-ING-CODE trước production |
| Recipe G1 seed | READY_FOR_DEV | 20 headers + 433 lines là derived validation; production cần review checksum/source |
| Source/procurement fixture | READY_FOR_DEV | Có `SELF_GROWN` verified và `PURCHASED` supplier path |
| Production order snapshot | READY | Dùng `g1_recipe_lines.csv` làm seed và snapshot contract |
| Material issue/receipt | READY | Dựa vào snapshot + ingredient + warehouse seed; issue chỉ chọn raw lot `READY_FOR_PRODUCTION` |
| Process events | READY | Smoke/API fixture yêu cầu `PREPROCESSING -> FREEZING -> FREEZE_DRYING` |
| QC/Release | READY | `QC_PASS != RELEASED`; release tạo `op_batch_release` |
| Warehouse/Inventory | READY | Có raw/FG warehouse fixture |
| Trace/Public Trace | READY_FOR_DEV | Có field policy; OD-11/OD-14 vẫn ảnh hưởng freeze |
| Recall | READY_FOR_DEV | Smoke fixture có recall dry-run |
| MISA | READY_FOR_DEV_FIXTURE | Production blocked bởi DATA-OD-MISA-PROD |
| Printing/QR | READY_FOR_DEV_FIXTURE | Production blocked bởi DATA-OD-GTIN-REAL và DATA-OD-PRINTER |
| CODE16 retention/DR | NOT_READY_FOR_FREEZE | Blocked by OD-12/OD-13 |

## 5. Khuyến Nghị Phase Tiếp Theo

| next_step | mô tả | done gate |
|---|---|---|
| CODE-READY-01 | Viết seed loader đọc CSV theo business key và `UTF-8` | Import được toàn bộ CSV trong data pack, chạy lại không duplicate |
| CODE-READY-02 | Viết seed validation test từ `04_SEED_VALIDATION_QUERIES.md` | SV-001 đến SV-018 pass |
| CODE-READY-03 | Viết API fixture tests từ `06_API_EXAMPLE_FIXTURES.md` | Command payload và error payload ổn định |
| CODE-READY-04 | Viết E2E smoke test theo `05_E2E_SMOKE_FIXTURE.md` | Chạy được full chain source -> raw -> PO -> issue -> process -> QC -> release -> warehouse -> trace |
| CODE-READY-05 | Owner review `ingredients.csv` và generated ingredient codes | DATA-OD-ING-CODE resolved trước production seed |
| CODE-READY-06 | Owner review GTIN/MISA/printer production config | DATA-OD-GTIN-REAL, DATA-OD-MISA-PROD, DATA-OD-PRINTER resolved trước production go-live |
| CODE-READY-07 | Owner review final user assignment cho `RAW_LOT_MARK_READY` | Không đổi coding baseline nếu chỉ thay user-role mapping; vẫn giữ permission riêng khỏi `RAW_QC_SIGN` |
