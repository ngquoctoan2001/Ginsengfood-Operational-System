# OD-DEFAULTS-2026-05-03 — Default Resolution Cho OD Còn OPEN Và CONFLICT/OD Mới

> Mục đích: chốt production-freeze status cho 8 owner decision còn OPEN trong [09_CONFLICT_AND_OWNER_DECISIONS.md](../software-specs/09_CONFLICT_AND_OWNER_DECISIONS.md) §C.2 và nhóm CONFLICT/OD mới trong [software-specs-conflict-decision-audit-2026-05-03.md](../v2-audit/software-specs-conflict-decision-audit-2026-05-03.md) §5 để **không block scaffold greenfield**. PF-02 bổ sung production data/config closure: OD-17 và OD-20 dùng device/config/secret refs có owner thay vì accepted-risk mơ hồ.

## 0. Trạng Thái

- **Phiên bản**: 2026-05-03 (Batch 1)
- **Trạng thái**: PF-02_PRODUCTION_CONFIG_CLOSURE_2026-05-03
- **Trạng thái trước PF-01**: OWNER_PENDING
- **Phạm vi áp dụng**: scaffold greenfield + dev/staging environment + production cho tới khi owner override bằng directive mới.
- **Không thay thế**: tài liệu nguồn `docs/software-specs/`; chỉ bổ sung default cho gate vận hành.
- **Nguyên tắc**: mọi giá trị đều **configurable runtime**, không hard-code; swap giá trị production không cần đổi schema/code.
- **Effect**: 8 OD trong §C.2 + các CONFLICT/OD mới trong §3 chuyển sang trạng thái cuối. CODE00→CODE17 scaffold unblocked; production printer/MISA real mode dùng device/config/secret refs có owner và không commit secret thật.

## 1. Tổng Quan 8 OD

| OD    | Tóm tắt default                                               | Block CODE    | Đóng FINAL trước     |
| ----- | ------------------------------------------------------------- | ------------- | -------------------- |
| OD-11 | Trace SLA mặc định + middleware đo metric configurable        | CODE07        | CODE17               |
| OD-12 | RPO 15 phút / RTO 4 giờ DB; adapter backup/restore generic    | CODE16        | CODE17               |
| OD-13 | Retention 7 năm operational, 10 năm recall, 90 ngày outbox    | CODE16        | CODE17               |
| OD-14 | MVP single-language `vi`, schema i18n-ready từ ngày đầu       | CODE07        | CODE17               |
| OD-17 | HTTP/ZPL-compatible adapter + HMAC-SHA256 callback; physical device by config refs | CODE12        | CODE17 / pre-go-live |
| OD-20 | MISA AMIS `DryRun`/`Production` mode; tenant/endpoint/credential by secret refs | CODE13/CODE17 | CODE17               |
| OD-21 | 15 task type taxonomy default cho `/api/admin/tasks/my`       | CODE11        | CODE11 sprint review |
| OD-22 | 5 route family default theo REST + action sub-resource        | CODE09/10/11  | CODE10 sprint review |

## 2. Chi Tiết Từng OD

### 2.1 OD-11 — Trace Query SLA Technical

**Default cho dev/staging:**

| Metric                                                                     | Target dev | Target production (đề xuất) |
| -------------------------------------------------------------------------- | ---------- | --------------------------- |
| Public trace `/api/public/trace/{qr}` p95                                  | < 800ms    | < 500ms                     |
| Public trace p99                                                           | < 1500ms   | < 1000ms                    |
| Internal genealogy `/api/admin/trace/genealogy/{batch_id}` p95 (depth ≤ 5) | < 2s       | < 1.5s                      |
| Genealogy depth max                                                        | 10         | 10                          |
| Cache TTL public trace                                                     | 5 phút     | 15 phút                     |
| Concurrent QPS public                                                      | 50         | 200                         |

**Triển khai bắt buộc:**

1. Bảng cấu hình `op_trace_sla_config (key, value, updated_at, updated_by)` hoặc class `TraceSlaOptions` bind từ `appsettings`.
2. Materialized view `mv_trace_genealogy_summary` hai chiều (forward/backward), refresh trên event `TRACE_LINK_CREATED`.
3. Middleware `TracePerformanceMiddleware` ghi `trace_query_duration_ms`, `trace_query_depth`, `trace_cache_hit` vào `op_observability_metric` hoặc OpenTelemetry.
4. Postgres index bắt buộc:
   - `op_trace_link (parent_object_type, parent_object_id)`
   - `op_trace_link (child_object_type, child_object_id)`
   - `op_qr_registry (qr_code) INCLUDE (batch_id, sku_id)`
5. Smoke test CODE07 chạy fixture 50 batch + 5-level genealogy, ghi p95/p99 vào báo cáo.

**Đóng FINAL khi:** owner xem báo cáo metric thật + chốt bảng SLA production.

---

### 2.2 OD-12 — Backup/DR RPO + RTO

**Default cho dev/staging:**

| Loại                              | RPO       | RTO     | Cơ sở                               |
| --------------------------------- | --------- | ------- | ----------------------------------- |
| Database PostgreSQL 18            | ≤ 15 phút | ≤ 4 giờ | WAL streaming + nightly base backup |
| Evidence storage (CAPA, supplier) | ≤ 1 giờ   | ≤ 8 giờ | Object storage versioning           |
| Audit/event/outbox                | ≤ 5 phút  | ≤ 2 giờ | Append-only critical                |

**Triển khai bắt buộc:**

1. Tạo `docs/v2-handoff/backup-dr-runbook.md` với RPO/RTO + 4 kịch bản drill: `DB_CORRUPTION`, `FULL_DC_FAILURE`, `PARTIAL_TABLE_LOSS`, `EVIDENCE_STORAGE_LOSS`.
2. PostgreSQL config: `wal_level=replica`, `archive_mode=on`, `pg_basebackup` weekly, WAL ship interval 5 phút.
3. Adapter pattern `IBackupAdapter` + `IRestoreAdapter`. Default `LocalFileSystemBackupAdapter`; production swap `AzureBlobBackupAdapter` / `S3BackupAdapter` / `MinioBackupAdapter` qua DI.
4. Script `tools/db/Test-RestoreDrill.ps1` chạy drill định kỳ.
5. Mọi RPO/RTO phải nằm trong `appsettings.BackupDr` hoặc `op_backup_policy`, không hard-code.

**Đóng FINAL khi:** owner chốt RPO/RTO production + chọn storage provider + chạy 1 drill thành công.

---

### 2.3 OD-13 — Audit/Log/Retention Duration

**Default cho dev/staging (theo Nghị định 15/2018, ISO 22000, HACCP):**

| Bảng                                         | Retention | Hot vs Archive            |
| -------------------------------------------- | --------- | ------------------------- |
| `op_audit_log`                               | 7 năm     | 1 năm hot + 6 năm archive |
| `op_traceability_event`                      | 7 năm     | 2 năm hot + 5 năm archive |
| `op_recall_*` (recall, CAPA, evidence)       | 10 năm    | toàn bộ hot               |
| `op_inventory_ledger`                        | 7 năm     | 2 năm hot + 5 năm archive |
| `op_misa_sync_log`                           | 5 năm     | 1 năm hot + 4 năm archive |
| `op_outbox_event` (post-publish)             | 90 ngày   | hot only                  |
| `op_request_log` / `op_idempotency_registry` | 90 ngày   | hot only                  |

**Triển khai bắt buộc:**

1. Bảng `op_retention_policy (table_name, hot_days, archive_days, archive_target, updated_at, updated_by)`.
2. Worker `RetentionArchiveWorker` chạy hằng đêm: chuyển row `> hot_days` sang `archive_*` table hoặc cold storage (Parquet/S3).
3. View `vw_*_unified` JOIN hot + archive cho query đầy đủ; M16 admin search dùng view này.
4. Mọi retention period là config, không hard-code.
5. CODE16 prompt phải mention `RetentionArchiveWorker` + `op_retention_policy`.

**Đóng FINAL khi:** owner chốt từng dòng bảng retention.

---

### 2.4 OD-14 — Public Trace Multi-Language Policy

**Default:** ship MVP **chỉ tiếng Việt (`vi`)**, schema sẵn sàng i18n.

**Triển khai bắt buộc:**

1. Mọi cột text expose public trace (`source_zone_name`, `ingredient_display_name`, `process_step_label`, `recipe_group_label`...) đi kèm bảng phụ `op_*_i18n (object_id, locale, field_name, value)` từ migration đầu tiên.
2. Endpoint `/api/public/trace/{qr}` nhận query `?lang=vi` (default `vi`). Khi `lang ≠ vi` và không có bản dịch → fallback `vi` + header `Content-Language: vi`.
3. Frontend `apps/public-trace` (Next.js 16) dùng `next-intl`, locale duy nhất `vi` ở MVP.
4. Bảng `op_*_i18n` rỗng cho non-vi locale; thêm locale chỉ cần seed bảng, không sửa schema.

**Đóng FINAL khi:** owner trả lời 1 câu — "Có cần `en` / `zh` / `ko` không, ưu tiên locale nào, deadline?".

---

### 2.5 OD-17 — Production Printer Model + Driver

**Default abstraction:**

| Layer         | Default                                                          | Khi có printer thật                       |
| ------------- | ---------------------------------------------------------------- | ----------------------------------------- |
| Print payload | ZPL (Zebra Programming Language)                                 | Giữ ZPL, swap mapping driver              |
| Protocol      | HTTP REST callback `POST /api/admin/printing/jobs/{id}/callback` | Có thể giữ + thêm MQTT nếu printer hỗ trợ |
| Auth          | HMAC-SHA256 header `X-Printer-Signature` + `X-Device-Id`         | PF-02 baseline; mTLS/JWT chỉ thêm nếu owner ADR mới             |
| Heartbeat     | 60s, mark `OFFLINE` sau 3 lần miss                               | Configurable                              |

**Triển khai bắt buộc:**

1. `IPrinterAdapter` interface với 3 method: `Submit(PrintJob)`, `Cancel(jobId)`, `QueryStatus(jobId)`.
2. Implement `ZplOverHttpPrinterAdapter` làm default — đủ cho 90% Zebra/TSC/Godex industrial printer.
3. Print queue `op_print_job` + worker `PrintJobDispatcher` retry 3 lần exponential backoff (1m → 5m → 25m).
4. Label template ZPL ở `services/printer-device-adapter/templates/*.zpl` — versioned per packaging level (PACKET, BOX, CARTON).
5. Bảng `op_printer_device (device_id, model, ip_address, location, hmac_secret_ref, status, last_heartbeat_at)`.

**PF-02 final:** protocol/callback/label boundary đã chốt bằng device refs. Owner vẫn cần cung cấp model + IP/serial của ≥ 1 printer test thật để chạy factory smoke, nhưng không còn là schema/API blocker.

---

### 2.6 OD-20 — MISA AMIS Production Credential

**Default:** dev/staging **dry-run mode**, production dùng secret/runtime refs.

**Triển khai bắt buộc:**

1. Config class `MisaSyncOptions { Mode = DryRun | Production; BaseUrl; TenantId; ClientId; ClientSecretRef; WebhookSecretRef; }`.
2. Dev/staging `Mode=DryRun` → ghi `op_misa_sync_log` với `status=DRY_RUN_OK`, không gọi MISA thật.
3. Production secret từ platform secret manager/environment secret. KHÔNG commit secret vào repo, seed, docs hoặc log.
4. Bảng mapping `op_misa_account_mapping (operational_account_code, misa_object_code, misa_object_type)` seed fixture rỗng cho dev.
5. Worker reconcile so sánh `op_misa_sync_log` vs `op_misa_external_state`, log discrepancy vào `op_misa_reconcile_pending`.
6. Retry policy: 3 lần exponential backoff (1m → 5m → 25m), sau đó `RECONCILE_PENDING` chờ ops can thiệp.
7. Khi switch sang `Real` lần đầu phải chạy `dotnet run --project services/operational-api -- misa-sync --dry-run-validate` để smoke trước.

**PF-02 final:** tenant/endpoint/credential thật được bind bằng config/secret refs do Finance/Integration + DevOps sở hữu. Owner vẫn cần nạp giá trị thật trước go-live, nhưng không còn là schema/API blocker.

---

### 2.7 OD-21 — PWA Task Taxonomy + `/api/admin/tasks/my`

**Default task taxonomy (15 type, đủ cho 8 module operational):**

```
TASK_TYPE enum:
  RAW_RECEIPT_PENDING_QC
  RAW_QC_SIGN
  RAW_LOT_MARK_READY
  PRODUCTION_ORDER_PENDING_OPEN
  MATERIAL_ISSUE_PENDING_EXEC
  MATERIAL_RECEIPT_CONFIRM
  PROCESS_STEP_EXECUTE          -- PREPROCESSING / FREEZING / FREEZE_DRYING
  QC_FINISHED_INSPECT
  BATCH_RELEASE_APPROVE
  PACKAGING_PRINT_REQUEST
  WAREHOUSE_RECEIPT_CONFIRM
  RECALL_HOLD_EXECUTE
  RECALL_CAPA_EVIDENCE_UPLOAD
  SUPPLIER_INTAKE_RECEIVE
  SUPPLIER_EVIDENCE_REVIEW
```

**Triển khai bắt buộc:**

1. View `vw_user_pending_tasks` UNION ALL các bảng có pending state cho user role/scope.
2. Endpoint `GET /api/admin/tasks/my?type=&priority=&limit=50&cursor=` trả về `{ task_type, source_id, title, sla_due_at, priority, action_route }`.
3. PWA poll mỗi 60s (configurable) + push qua SignalR/SSE khi event mới xuất hiện trong `op_outbox_event`.
4. Action complete bằng command có `Idempotency-Key`.
5. `priority` enum: `LOW | NORMAL | HIGH | CRITICAL`; sort default `priority DESC, sla_due_at ASC`.

**Đóng FINAL khi:** owner xem demo PWA + chốt thêm/bớt task type + chốt sort/priority rule trong sprint review CODE11.

---

### 2.8 OD-22 — UI Mutation Route Taxonomy Phụ

**Default 5 route family theo REST + action sub-resource:**

| Domain                | Route                                                                                                           | Method       |
| --------------------- | --------------------------------------------------------------------------------------------------------------- | ------------ |
| UOM write             | `/api/admin/master-data/uoms`                                                                                   | POST create  |
|                       | `/api/admin/master-data/uoms/{code}`                                                                            | PATCH update |
|                       | `/api/admin/master-data/uoms/{code}/deactivate`                                                                 | POST action  |
| Raw lot hold          | `/api/admin/raw-material/lots/{id}/hold` body `{ reason, until_at? }`                                           | POST action  |
| Raw lot release       | `/api/admin/raw-material/lots/{id}/release` body `{ reason }`                                                   | POST action  |
| Process command       | `/api/admin/production/batches/{id}/process-steps` body `{ step_code, action: START / COMPLETE / FAIL, payload }` | POST action  |
| Screen registry write | `/api/admin/admin-ui/screens`                                                                                   | POST create  |
|                       | `/api/admin/admin-ui/screens/{code}`                                                                            | PATCH update |
|                       | `/api/admin/admin-ui/screens/{code}/permissions`                                                                | POST action  |

**Quy ước chung (ràng buộc theo [api/01_API_CONVENTION.md](../software-specs/api/01_API_CONVENTION.md)):**

- Mutation luôn POST/PATCH, không PUT thay thế toàn bộ.
- Action sub-resource `/{id}/{action}` cho transition state machine.
- Mọi mutation bắt buộc header `Idempotency-Key`.
- Mọi action ghi `op_audit_log` + `op_outbox_event`.

**Triển khai bắt buộc:**

1. Implement controller theo bảng trên trong CODE09/10.
2. OpenAPI generation phải reflect đầy đủ route family này.
3. Frontend API client (admin-web) generate từ OpenAPI, không tạo route song song.

**Đóng FINAL khi:** owner ký off route taxonomy trong sprint review CODE10. Có thể rename trước freeze CODE17.

## 3. Default Đề Xuất Cho CONFLICT/OD Mới

### 3.1 Critical — default trước schema/API

| ID                      | Default đề xuất để scaffold                                                                                                                                                                                     | Owner cần ký                                                                                                                                                                           | Guardrail khi dev                                                                                                   |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| CONFLICT-18             | Model coexistence là chính thức: G1 = `PILOT_PERCENT_BASED`, G2 = `FIXED_QUANTITY_BATCH`, unique active theo `(sku_id, formula_kind)`.                                                                          | Owner ký để patch wording cũ trong `04_BUSINESS_CONTEXT.md`, `business/02_BUSINESS_RULES.md` và các summary còn diễn đạt G1 như baseline duy nhất.                                     | Không tạo unique active per SKU đơn lẻ; PO snapshot luôn lưu `formula_version_snapshot` và `formula_kind_snapshot`. |
| OD-G2-001               | G2 fixed dùng `quantity_per_batch_400` làm standard basis cho 1 mẻ chuẩn 400; sản xuất lệch 400 được phép như variance có audit, không tự động là lỗi.                                                          | Chốt tolerance mặc định: đề xuất `±2%` theo quantity line hoặc cấu hình theo ingredient/risk class; vượt ngưỡng cần approval `R-OPS-MGR` hoặc QA tùy loại.                             | Không hard-code "must equal 400"; mọi tolerance nằm trong config/policy table.                                      |
| OD-FORMULA-PICK-001     | Create PO bắt buộc gửi `recipe_id` hoặc cặp `formula_version` + `formula_kind`; UI hiển thị dropdown khi có nhiều active.                                                                                       | Chốt có cho SKU default preselect hay không. Đề xuất: có preselect theo `ref_sku_operational_config`, nhưng user vẫn thấy và có thể đổi nếu có quyền.                                  | Backend không silent chọn FIXED; ambiguous request reject bằng error rõ như `ACTIVE_RECIPE_AMBIGUOUS`.              |
| OD-M03-OWNERSHIP-001    | M03A là canonical owner của `op_supplier`, `op_supplier_ingredient`, `op_supplier_user_link`, supplier portal scope và role `R-SUPPLIER`; M03 chỉ giữ master-data grouping/reference.                           | Owner ký để patch `modules/03_MASTER_DATA.md` giảm scope "Supplier management" thành reference/admin grouping.                                                                         | Chỉ có một supplier CRUD contract; M06 consume read-only supplier status/allowlist.                                 |
| OD-NOTIFY-OWNERSHIP-001 | Operational chỉ tạo `notification_job_id`/outbox event/reference và audit hand-off; notification delivery engine/channel/template là external service.                                                          | PF-01 FINAL: hệ thống bán hàng/external notification service chịu delivery, Operational SLA đo tới job/outbox hand-off. | Không build notification channel engine trong M13; chỉ có adapter/event boundary.                                   |
| OD-EVIDENCE-STORAGE-001 | Dev/test dùng `LOCAL_FS`; production dùng server công ty qua `COMPANY_SERVER` storage profile/adapter, cấu hình endpoint/path/credential/encryption/access-log/backup runtime.                                   | PF-01 FINAL: code cả local dev/test adapter và company-server configurable adapter; DB chỉ lưu metadata/object key/hash.                                                                 | Không lưu blob trong DB, không expose direct public URL.                                |
| OD-EVIDENCE-SCAN-001    | Default scanner: internal scan worker dùng ClamAV trong dev/staging; production scan provider configurable. `SCAN_FAILED` retry 3 lần exponential backoff; `INFECTED` quarantine và yêu cầu replacement upload. | Chốt provider production và scan SLA tối đa trước khi evidence được dùng để verify/close.                                                                                              | Gate chỉ count `scan_status = CLEAN`; failed/infected evidence append-only, không xóa dấu vết.                      |
| OD-INVENTORY-ALLOC-001  | FEFO mặc định cho mọi lot có `expiry_date`; tie-breaker FIFO theo received/created time; manual lot override cần reason và permission.                                                                          | Chốt có áp supplier priority hoặc preferred lot policy không. Đề xuất không áp supplier priority trong MVP vì dễ làm sai expiry control.                                               | Allocation deterministic; không auto-pick arbitrary lot; issue vẫn check ready/hold/expiry/available.               |
| OD-WAREHOUSE-3RD-001    | MVP không thêm `warehouse_type` thứ ba; dùng `op_warehouse_location`/zone/status cho `QUARANTINE_HOLD` và `RETURNS`, còn `warehouse_type` giữ `RAW_MATERIAL`, `FINISHED_GOODS`.                                 | Chốt nếu kế toán/report bắt buộc kho riêng thì thêm type trước migration freeze.                                                                                                       | Hold/sale-lock registry vẫn là gate chính; location không thay thế recall hold/sale-lock.                           |

### 3.2 High — default trước module closeout

| ID                         | Default đề xuất để scaffold                                                                                                                                                                | Owner cần ký                                                                                                             | Guardrail khi dev                                                                                  |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| OD-SUP-AUTH-001            | Supplier Portal MVP: MFA optional/off by default, session idle timeout 30 phút, absolute session 8 giờ, lockout 5 failed attempts trong 15 phút.                                           | Chốt có bắt buộc MFA production không và timeout chính thức.                                                             | Auth options configurable; supplier `SUSPENDED` block login và command trước mọi scope check.      |
| OD-SUP-EVIDENCE-RETRY-001  | Supplier được upload replacement khi `SCAN_FAILED` hoặc `INFECTED`; mỗi lần upload tạo evidence row mới append-only, row cũ giữ trạng thái và audit.                                       | Chốt có cho re-scan cùng object khi `SCAN_FAILED` không. Đề xuất cho re-scan tối đa 1 lần, sau đó replacement.           | Không delete failed/infected metadata; `INFECTED` object không cho download lại qua UI thường.     |
| OD-SUP-FEEDBACK-ENUM-001   | Final enum: `QUALITY_ISSUE`, `DELIVERY_LATE`, `DELIVERY_EARLY`, `QUANTITY_VARIANCE`, `DOCUMENTATION_INCOMPLETE`, `PACKAGING_DAMAGE`, `TEMPERATURE_BREACH`, `OTHER`.                         | Đã final trong Batch 2; mọi contract dùng enum này.                                                                        | `feedback_type` là enum/reference, body bắt buộc; `OTHER` cần mô tả.                               |
| OD-SUP-CONFIRM-TIMEOUT-001 | Company-created receipt chờ supplier confirm: nhắc sau 24 giờ, escalate sau 48 giờ, không auto-cancel mặc định.                                                                            | Chốt timeout theo thực tế mua hàng và có auto-cancel hay không.                                                          | Scheduler chỉ tạo alert/escalation trừ khi owner bật auto-cancel bằng config.                      |
| OD-PACKET-TRACE-001        | PF-01 FINAL: BOX/CARTON là public trace entry point; PACKET không in QR và không trace standalone vì luôn nằm trong BOX.                                               | PACKET inherit trace từ BOX/CARTON parent.                   | M12 chỉ trace mã thật được in; không giả lập trace PACKET khi label không có batch/QR/code.        |
| OD-PACKAGING-DEFAULT-001   | `units_per_box = 4` là seed/default editable per `op_trade_item`; `boxes_per_carton = NULL` cho tới khi owner bật `carton_enabled` và nhập số thùng.                                       | Owner ký default 4 gói/hộp và cung cấp `boxes_per_carton` theo SKU/kênh nếu cần carton.                                  | Packaging job snapshot quy cách lúc tạo; config đổi sau không rewrite lịch sử.                     |
| OD-CAPA-MODEL-001          | CAPA status default: `OPEN`, `IN_PROGRESS`, `EVIDENCE_PENDING`, `READY_TO_CLOSE`, `CLOSED`, `REJECTED`. Close gate: owner, due date, root cause/action text và ít nhất 1 evidence `CLEAN`. | Owner chốt enum/status wording và có cần `CLOSED_WITH_RESIDUAL_RISK` ở CAPA hay chỉ ở recall case.                       | Không tạo `op_recall_capa_item` baseline; evidence append-only; close API enforce gate.            |
| OD-MISA-DOC-OWNER-001      | M08 tạo operational facts và outbox event; M14 tạo accounting payload/document mapping và post lifecycle từ event.                                                                         | Owner ký boundary M08/M14 và document type mapping.                                                                      | Business module không gọi MISA trực tiếp; credential chỉ ở M14 adapter/runtime secret.             |
| OD-ADJUSTMENT-APPROVAL-001 | Default threshold: mọi inventory adjustment cần reason + audit; adjustment absolute value trên 2% lot balance hoặc high-risk ingredient cần `R-OPS-MGR` approval.                          | Owner chốt threshold theo quantity/value/ingredient risk.                                                                | Threshold trong `approval_policy.threshold_config`, không hard-code.                               |
| OD-WH-CORRECT-IDEMPO-001   | Mỗi warehouse receipt correction hợp lệ tạo record correction/reversal/adjustment mới; cùng line sửa lần 2 vẫn là record mới. `Idempotency-Key` chỉ chống duplicate cùng command.          | Owner ký append-only correction semantics.                                                                               | Không update correction đã approved/posted in-place; idempotency conflict phải trả rõ.             |
| OD-RATE-LIMIT-SCOPE-001    | Rate limit bắt buộc cho public trace, auth/login, supplier portal, MISA callback, printer/device callback; admin/PWA mutation dùng rate limit nhẹ + idempotency.                           | Owner chốt threshold. Default đề xuất: public trace 60 req/min/IP, login 5 failed/15 phút, callbacks 300 req/min/device. | Threshold configurable per route group; public trace release bị block nếu thiếu rate limit.        |
| OD-PRINTER-PROTO-001       | Default callback auth dùng HMAC-SHA256 signature + `X-Device-Id` over TLS; JWT device token là option; mTLS là production hardening nếu hạ tầng hỗ trợ.                                    | Owner chốt protocol production, rotation/revocation và printer model thật.                                               | Callback chỉ ghi heartbeat/print result qua service validation; không bypass QC/release/inventory. |

## 4. Quy Trình Đóng OD

| Trạng thái | Điều kiện | Ghi nhận |
| ---------- | --------- | -------- |
| `RESOLVED_FINAL` | Owner chốt chính sách đủ để scaffold và production freeze. | Cập nhật `09_CONFLICT...` §C.8, sign-off table §5. |
| `RESOLVED_FINAL_PF02_WITH_DEVICE_REFS` | Printer/device production freeze đủ bằng device registry/config refs; physical model/IP/driver là dữ liệu triển khai. | Không đổi schema/API; validate refs trước factory smoke. |
| `RESOLVED_FINAL_PF02_WITH_SECRET_REFS` | MISA production freeze đủ bằng config/secret refs có owner; literal secret không nằm trong repo. | Không đổi schema/API; validate refs trước production mode. |
| `DEFERRED_WITH_ACCEPTED_RISK` | Thiếu thông số hạ tầng/thông tin thật nhưng adapter/dry-run/config đủ để scaffold; production real mode bị khóa cho tới khi cấu hình thật. | Cập nhật impact/risk trong `09_CONFLICT...` §C.8 và không bật real integration khi chưa có secret/device. |

## 5. Owner Sign-Off

### 5.1 8 OD cũ

| OD    | PF-02 status | Ghi chú owner | Ngày |
| ----- | ------------ | ------------- | ---- |
| OD-11 | RESOLVED_FINAL | Trace SLA target production freeze accepted; đo metric khi có dữ liệu thật. | 2026-05-03 |
| OD-12 | RESOLVED_FINAL | RPO/RTO default accepted; backup adapter runtime configurable. | 2026-05-03 |
| OD-13 | RESOLVED_FINAL | Retention 7y operational, 10y recall, 90d outbox accepted. | 2026-05-03 |
| OD-14 | RESOLVED_FINAL | Public trace MVP `vi`; schema i18n-ready. | 2026-05-03 |
| OD-17 | RESOLVED_FINAL_PF02_WITH_DEVICE_REFS | Build HTTP/ZPL-compatible adapter + HMAC callback; model/IP/driver supplied through device registry/config refs. | 2026-05-03 |
| OD-20 | RESOLVED_FINAL_PF02_WITH_SECRET_REFS | Build MISA AMIS `DryRun`/`Production` mode; tenant/endpoint/credential supplied through `MisaSyncOptions.*` + secret refs. | 2026-05-03 |
| OD-21 | RESOLVED_FINAL | PWA task taxonomy accepted for scaffold; sprint can add non-breaking task types. | 2026-05-03 |
| OD-22 | RESOLVED_FINAL | UI mutation route families accepted as canonical baseline. | 2026-05-03 |

### 5.2 CONFLICT/OD mới

| OD                         | PF-01 status | Ghi chú owner | Ngày |
| -------------------------- | ------------ | ------------- | ---- |
| CONFLICT-18                | RESOLVED_FINAL | Formula coexistence G1 PILOT + G2 FIXED is canonical. | 2026-05-03 |
| OD-G2-001                  | RESOLVED_FINAL | Variance policy default accepted. | 2026-05-03 |
| OD-FORMULA-PICK-001        | RESOLVED_FINAL | Prefer FIXED when tie, with audited override. | 2026-05-03 |
| OD-M03-OWNERSHIP-001       | RESOLVED_FINAL | M03A owns supplier canonical CRUD; M03 keeps reference grouping. | 2026-05-03 |
| OD-NOTIFY-OWNERSHIP-001    | RESOLVED_FINAL | Operational outbox/job only; sales system owns delivery. | 2026-05-03 |
| OD-EVIDENCE-STORAGE-001    | RESOLVED_FINAL | Production evidence on company server via configurable adapter; dev/test local FS. | 2026-05-03 |
| OD-EVIDENCE-SCAN-001       | RESOLVED_FINAL | Scanner adapter default accepted. | 2026-05-03 |
| OD-INVENTORY-ALLOC-001     | RESOLVED_FINAL | FEFO default accepted. | 2026-05-03 |
| OD-WAREHOUSE-3RD-001       | RESOLVED_FINAL | Zone model accepted for hold/return/recall. | 2026-05-03 |
| OD-SUP-AUTH-001            | RESOLVED_FINAL | Supplier auth/session defaults accepted. | 2026-05-03 |
| OD-SUP-EVIDENCE-RETRY-001  | RESOLVED_FINAL | Replacement upload append-only accepted. | 2026-05-03 |
| OD-SUP-FEEDBACK-ENUM-001   | RESOLVED_FINAL | Feedback enum accepted. | 2026-05-03 |
| OD-SUP-CONFIRM-TIMEOUT-001 | RESOLVED_FINAL | 24h alert / 72h timeout accepted. | 2026-05-03 |
| OD-PACKET-TRACE-001        | RESOLVED_FINAL | PACKET has no QR and inherits BOX/CARTON trace. | 2026-05-03 |
| OD-PACKAGING-DEFAULT-001   | RESOLVED_FINAL | Packaging defaults accepted, override per SKU. | 2026-05-03 |
| OD-CAPA-MODEL-001          | RESOLVED_FINAL | CAPA schema/status/close gate accepted. | 2026-05-03 |
| OD-MISA-DOC-OWNER-001      | RESOLVED_FINAL | M14 owns MISA document lifecycle from M08 event. | 2026-05-03 |
| OD-ADJUSTMENT-APPROVAL-001 | RESOLVED_FINAL | Adjustment approval tiers accepted. | 2026-05-03 |
| OD-WH-CORRECT-IDEMPO-001   | RESOLVED_FINAL | Append-only correction semantics accepted. | 2026-05-03 |
| OD-RATE-LIMIT-SCOPE-001    | RESOLVED_FINAL | Rate-limit scopes accepted. | 2026-05-03 |
| OD-PRINTER-PROTO-001       | DEFERRED_WITH_ACCEPTED_RISK | HMAC callback baseline accepted; production hardening follows actual printer/infrastructure. | 2026-05-03 |

Owner ký: owner directive PF-01
Ngày ký: 2026-05-03

## 6. Lịch Sử

| Ngày       | Thay đổi                                                                         | Người |
| ---------- | -------------------------------------------------------------------------------- | ----- |
| 2026-05-03 | PF-01 finalization: sign-off table chuyển sang `RESOLVED_FINAL`/`DEFERRED_WITH_ACCEPTED_RISK`; Group A chốt theo owner directive. | owner/Codex |
| 2026-05-03 | Khởi tạo file default cho 8 OD còn OPEN.                                         | Codex |
| 2026-05-03 | Bổ sung default đề xuất cho CONFLICT/OD mới trước schema/API và module closeout. | Codex |
