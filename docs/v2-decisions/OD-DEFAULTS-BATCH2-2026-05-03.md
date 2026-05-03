# OD-DEFAULTS-BATCH2-2026-05-03 — Default Resolution Cho Batch 2 (15 OD)

> Mục đích: chốt production-freeze status cho Batch 2 OD mới phát sinh khi rà soát toàn bộ `docs/software-specs/` ngày 2026-05-03. Sau PF-01, các OD trong file này có trạng thái cuối `RESOLVED_FINAL` hoặc `DEFERRED_WITH_ACCEPTED_RISK`; không còn nhóm owner-pending cho scaffold.

## 0. Trạng Thái

- **Phiên bản**: 2026-05-03 (Batch 2)
- **Trạng thái**: PF-02_PRODUCTION_CONFIG_CLOSURE_2026-05-03
- **Trạng thái trước PF-01**: OWNER_PENDING
- **Phạm vi áp dụng**: scaffold greenfield + dev/staging environment + production freeze baseline; production config thật dùng refs/owner theo PF-02.
- **Không thay thế**: tài liệu nguồn `docs/software-specs/`; chỉ bổ sung default cho gate vận hành.
- **Nguyên tắc**: mọi giá trị đều **configurable runtime** qua bảng `op_*_policy` hoặc `MisaSyncOptions`-style class, không hard-code.
- **PF-02 addendum**: evidence storage production dùng company storage server qua `EvidenceStorage.*`; scan provider là pluggable worker; inventory/warehouse/CAPA/MISA/notification decisions không chứa literal secret hoặc infrastructure credential trong repo.

## 1. Phân Loại

| Nhóm                                             | Số OD                                 | Cách xử lý                                                              |
| ------------------------------------------------ | ------------------------------------- | ----------------------------------------------------------------------- |
| Đã patch tài liệu, không cần ký mới              | 2 (CONFLICT-18, OD-M03-OWNERSHIP-001) | Patch trực tiếp ở `04_BUSINESS_CONTEXT.md`, `modules/03_MASTER_DATA.md` |
| RESOLVED_FINAL theo PF-01                        | 18                                    | 15 OD Batch 2 + 3 OD Group A đã có owner directive                      |
| DEFERRED_WITH_ACCEPTED_RISK                      | 0                                     | Batch 2 không còn accepted risk riêng; printer/MISA risk nằm ở Batch 1  |

## 2. Chi Tiết 15 OD RESOLVED_FINAL

### 2.1 OD-G2-001 — Variance Policy Mẻ FIXED 400

**Default:**

| Field                                   | Default                                                      | Cơ sở                          |
| --------------------------------------- | ------------------------------------------------------------ | ------------------------------ |
| `op_formula_g2_header.target_batch_qty` | 400                                                          | từ spec                        |
| `op_formula_g2_header.tolerance_pct`    | ±2% (392–408)                                                | tiêu chuẩn ngành thực phẩm rời |
| Variance trong tolerance                | log info, không block                                        |                                |
| Variance ngoài tolerance, ≤ 10%         | warning, không block, ghi `op_batch_variance_log`, QC review |                                |
| Variance > 10%                          | block release, force CAPA recall-style                       |                                |

**Schema bổ sung:**

- `op_formula_g2_header.tolerance_pct DECIMAL(5,2) NOT NULL DEFAULT 2.00`
- `op_batch_variance_log (variance_id, batch_id FK, expected_qty, actual_qty, variance_pct, variance_severity ENUM('IN_TOL','OUT_TOL_WARN','OUT_TOL_BLOCK'), reason, recorded_by, recorded_at)`

**API:**

- `POST /api/admin/production/batches/{id}/complete` body bắt buộc `actual_batch_qty`. Server tính variance, ghi log, trả về `variance_severity`.

**Đóng FINAL khi:** owner xác nhận tolerance ±2% / ±5% / ±10% gate.

---

### 2.2 OD-FORMULA-PICK-001 — Planner Pick PILOT vs FIXED

**Default rule ưu tiên:**

```
1. Nếu op_sku_operational_config.preferred_formula_kind != 'AUTO_LATEST' → dùng giá trị config.
2. Else nếu chỉ 1 formula_kind ACTIVE_OPERATIONAL → dùng cái đó.
3. Else (cả G1 PILOT + G2 FIXED active) → ưu tiên FIXED (chính xác hơn cho production scale).
4. Planner UI cho phép override với reason → ghi audit op_audit_log với formula_kind_override_reason.
```

**Schema:** `op_sku_operational_config.preferred_formula_kind ENUM('PILOT','FIXED','AUTO_LATEST') NOT NULL DEFAULT 'AUTO_LATEST'`.

**API:** `POST /api/admin/production/orders` body:

```json
{
  "sku_id": "...",
  "formula_selection": {
    "mode": "AUTO" | "OVERRIDE",
    "formula_kind": "PILOT" | "FIXED",
    "formula_version": "G1" | "G2",
    "override_reason": "..."
  }
}
```

**Đóng FINAL khi:** owner xác nhận rule ưu tiên FIXED khi tie + format API.

---

### 2.3 OD-EVIDENCE-SCAN-001 — Virus Scan Provider

**Default:**

| Field           | Giá trị                                                                           |
| --------------- | --------------------------------------------------------------------------------- |
| Provider        | ClamAV (open-source, on-premise)                                                  |
| Worker          | `services/evidence-scanner-worker` subscribe `EVIDENCE_UPLOADED` event            |
| Status enum     | `PENDING`, `SCANNING`, `CLEAN`, `INFECTED`, `SCAN_FAILED`                         |
| Retry policy    | 3 lần exponential 1m → 5m → 25m nếu `SCAN_FAILED`                                 |
| INFECTED action | move to quarantine bucket, alert ops, deny download, ghi `op_evidence_quarantine` |

**Abstraction:** `IEvidenceScanner { Task<ScanResult> ScanAsync(EvidenceRef) }`. Default `ClamAvScanner`. Swap được `WindowsDefenderScanner`, `AzureDefenderScanner`, `SophosScanner`.

**Đóng FINAL khi:** owner xác nhận ClamAV OK hoặc chỉ định enterprise scanner.

---

### 2.4 OD-INVENTORY-ALLOC-001 — FIFO vs FEFO

**Default: FEFO (First-Expiry-First-Out)** vì:

- Ngành thực phẩm: hạn dùng quan trọng hơn ngày nhập.
- Giảm waste, tuân thủ Nghị định 15/2018 ATTP.
- FIFO thuần chỉ phù hợp khi lot không có expiry.

**Algorithm:**

```sql
SELECT lot_id FROM op_raw_material_lot
WHERE sku_id = @sku AND status = 'READY' AND available_qty > 0
ORDER BY expiry_date ASC NULLS LAST, received_at ASC, lot_id ASC
```

**Configurable per SKU:** `op_sku_operational_config.allocation_strategy ENUM('FEFO','FIFO','LIFO','MANUAL') NOT NULL DEFAULT 'FEFO'`.

**Đóng FINAL khi:** owner xác nhận FEFO làm default + có cần override per-SKU không.

---

### 2.5 OD-WAREHOUSE-3RD-001 — Warehouse Type Thứ 3

**Default: KHÔNG thêm warehouse_type thứ 3.** Dùng **zone trong warehouse**.

**Schema:**

- `op_warehouse.warehouse_type ENUM('RAW_MATERIAL','FINISHED_GOODS')` — giữ nguyên 2 type.
- `op_warehouse_zone (zone_id, warehouse_id FK, zone_code, zone_purpose ENUM('STANDARD','QUARANTINE','RECALL_HOLD','RETURN','REJECT','BREAKAGE'), is_active)`.
- `op_inventory_balance.zone_id NOT NULL` — track theo zone.

**Lý do:** zone-level flexible hơn, không cần multiple warehouse vật lý cho recall hold/return ngắn hạn.

**Đóng FINAL khi:** owner xác nhận zone-level đủ, hoặc cần warehouse riêng vì kế toán/MISA.

---

### 2.6 OD-SUP-AUTH-001 — Supplier Portal Auth

**Default:**

| Field                | Default MVP                            | Default production                       |
| -------------------- | -------------------------------------- | ---------------------------------------- |
| MFA                  | Optional (TOTP qua app)                | Mandatory (owner xác nhận trước go-live) |
| Session timeout idle | 30 phút                                | 30 phút                                  |
| Session timeout max  | 8 giờ                                  | 8 giờ                                    |
| Password policy      | 12 ký tự, mixed case + số + special    | giữ nguyên                               |
| Lockout              | 5 fail → khóa 15 phút                  | giữ nguyên                               |
| Password reuse       | không cho dùng lại 5 password gần nhất | giữ nguyên                               |

**Schema bổ sung:** `op_supplier_user.mfa_enabled BOOLEAN DEFAULT FALSE`, `op_supplier_user.mfa_secret_ref` (encrypted).

**Đóng FINAL khi:** owner xác nhận có bật MFA mandatory pre-go-live không.

---

### 2.7 OD-SUP-EVIDENCE-RETRY-001 — Retry Upload INFECTED

**Default:** supplier **không được retry với cùng file**. Phải xóa record cũ → upload file mới.

**Flow:**

```
1. Supplier upload file → op_supplier_evidence (status=PENDING)
2. ClamAV scan → INFECTED
3. UI hiển thị: "File đã bị từ chối do nghi ngờ chứa mã độc.
   Vui lòng kiểm tra file gốc trước khi upload bản mới."
4. Supplier xóa record cũ (soft delete, status=REJECTED_INFECTED) → upload record mới.
5. Audit ghi đầy đủ INFECTED → REJECTED → NEW_UPLOAD chain.
```

**Lý do:** audit trail rõ ràng + tránh upload vòng lặp file độc.

**Đóng FINAL khi:** owner xác nhận policy này (không có quyền retry).

---

### 2.8 OD-SUP-FEEDBACK-ENUM-001 — Feedback Type Enum

**Default 8 type:**

```sql
CREATE TYPE feedback_type AS ENUM (
  'QUALITY_ISSUE',
  'DELIVERY_LATE',
  'DELIVERY_EARLY',
  'QUANTITY_VARIANCE',
  'DOCUMENTATION_INCOMPLETE',
  'PACKAGING_DAMAGE',
  'TEMPERATURE_BREACH',
  'OTHER'
);
```

**Schema:** `op_supplier_feedback.feedback_type feedback_type NOT NULL`, `op_supplier_feedback.note TEXT` cho free-text bổ sung.

**Đóng FINAL khi:** owner duyệt 8 enum value (thêm/bớt/đổi tên).

---

### 2.9 OD-SUP-CONFIRM-TIMEOUT-001 — Pre-Receipt Confirmation Timeout

**Default:**

| Trạng thái          | Hành động                                                                     | Time  |
| ------------------- | ----------------------------------------------------------------------------- | ----- |
| Pre-receipt created | Notify supplier                                                               | T+0   |
| Chưa confirm        | Auto-escalate notify supplier rep + factory contact                           | T+24h |
| Vẫn chưa confirm    | Auto-cancel pre-receipt, ghi `cancellation_reason='SUPPLIER_NO_RESPONSE_72H'` | T+72h |

**Configurable:** `op_supplier_collab_config (key, value)`:

- `preReceiptEscalateHours = 24`
- `preReceiptTimeoutHours = 72`

**Worker:** `SupplierConfirmTimeoutWorker` chạy mỗi 1h scan pending pre-receipt.

**Đóng FINAL khi:** owner xác nhận 24h/72h hoặc đổi giá trị.

---

### 2.10 OD-PACKAGING-DEFAULT-001 — Packaging Default

**Default:**

| Level  | units_per_parent | parent_level | Cấu hình             |
| ------ | ---------------- | ------------ | -------------------- |
| PACKET | (n/a)            | (n/a)        | unit nhỏ nhất        |
| BOX    | 4 PACKET         | PACKET       | configurable per SKU |
| CARTON | 12 BOX           | BOX          | configurable per SKU |

**Schema:**

- `op_trade_item_packaging (sku_id FK, packaging_level ENUM('PACKET','BOX','CARTON'), units_per_parent INT, parent_packaging_level)`
- `op_packaging_default_config (packaging_level, default_units_per_parent)` cho fallback khi tạo SKU mới.

**Đóng FINAL khi:** owner xác nhận default 4/12 hoặc đổi giá trị.

---

### 2.11 OD-CAPA-MODEL-001 — `op_recall_capa` Schema

**Default schema:**

```sql
CREATE TABLE op_recall_capa (
  capa_id          BIGINT PRIMARY KEY,
  recall_id        BIGINT NOT NULL REFERENCES op_recall_case(recall_id),
  capa_code        TEXT NOT NULL UNIQUE,           -- REC2026-001-CAPA-01
  title            TEXT NOT NULL,
  description      TEXT NOT NULL,
  owner_user_id    BIGINT NOT NULL REFERENCES op_user(user_id),
  due_date         DATE NOT NULL,
  status           capa_status NOT NULL DEFAULT 'OPEN',
  close_gate       capa_close_gate NOT NULL,
  evidence_count   INT NOT NULL DEFAULT 0,         -- computed via trigger
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by       BIGINT NOT NULL,
  closed_at        TIMESTAMPTZ,
  closed_by        BIGINT,
  closure_note     TEXT
);

CREATE TYPE capa_status AS ENUM (
  'OPEN','IN_PROGRESS','EVIDENCE_PENDING','REVIEW_PENDING','CLOSED','REJECTED'
);
CREATE TYPE capa_close_gate AS ENUM (
  'EVIDENCE_REVIEWED','QC_SIGNED','QA_MANAGER_APPROVED'
);

CREATE TABLE op_recall_capa_evidence (
  evidence_id    BIGINT PRIMARY KEY,
  capa_id        BIGINT NOT NULL REFERENCES op_recall_capa(capa_id),
  evidence_ref   TEXT NOT NULL,
  scan_status    evidence_scan_status NOT NULL DEFAULT 'PENDING',
  uploaded_by    BIGINT NOT NULL,
  uploaded_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Đóng FINAL khi:** owner duyệt schema + close_gate enum.

---

### 2.12 OD-MISA-DOC-OWNER-001 — MISA Document Ownership

**Default: M14 tạo document từ event, không phải M08.**

**Flow:**

```
1. M08 Material Issue Execution → ghi op_material_issue + op_outbox_event MATERIAL_ISSUED
2. M14 MisaSyncWorker subscribe MATERIAL_ISSUED qua outbox poll
3. M14 gọi MISA API tạo document
4. Ghi op_misa_sync_log (operational_ref, operational_type='MATERIAL_ISSUE', misa_doc_id, status, attempt_count)
```

**Lý do:**

- M08 không nên biết về MISA → loose coupling.
- MISA fail không block M08 commit.
- Single integration layer (M14) đúng hard lock.

**Đóng FINAL khi:** owner xác nhận event-driven flow + retry policy đã ghi ở `MisaSyncOptions`.

---

### 2.13 OD-ADJUSTMENT-APPROVAL-001 — Adjustment Threshold

**Default 3-tier:**

| Threshold                       | Approval level                | Số người duyệt           |
| ------------------------------- | ----------------------------- | ------------------------ |
| < 1% balance hoặc < 100 000 VND | warehouse_staff               | auto-approve, 1 ghi nhận |
| 1–5% balance hoặc 100k–1M VND   | warehouse_manager             | 1                        |
| > 5% balance hoặc > 1M VND      | qa_manager + factory_director | 2                        |

**Schema:**

```sql
CREATE TABLE op_adjustment_approval_policy (
  policy_id           BIGINT PRIMARY KEY,
  threshold_pct       DECIMAL(5,2),
  threshold_value_vnd DECIMAL(18,0),
  required_role       TEXT NOT NULL,
  required_count      INT NOT NULL DEFAULT 1,
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  effective_from      DATE NOT NULL
);
```

**Đóng FINAL khi:** owner xác nhận 3-tier + threshold value (1%/5% và 100k/1M VND).

---

### 2.14 OD-WH-CORRECT-IDEMPO-001 — Warehouse Receipt Correction

**Default: 2 record correction (append-only), không update.**

**Schema:**

```sql
CREATE TABLE op_warehouse_receipt_correction (
  correction_id        BIGINT PRIMARY KEY,
  receipt_line_id      BIGINT NOT NULL REFERENCES op_warehouse_receipt_line(line_id),
  correction_seq       INT NOT NULL,                -- 1, 2, 3...
  before_qty           DECIMAL(18,4) NOT NULL,
  after_qty            DECIMAL(18,4) NOT NULL,
  reason_code          TEXT NOT NULL REFERENCES ref_adjustment_reason(reason_code),
  reason_note          TEXT,
  prior_correction_id  BIGINT REFERENCES op_warehouse_receipt_correction(correction_id),
  corrected_by         BIGINT NOT NULL,
  corrected_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (receipt_line_id, correction_seq)
);
```

**Lý do:**

- Audit trail đầy đủ, không mất lịch sử.
- Đúng nguyên tắc append-only của ACR-007.
- `prior_correction_id` cho phép trace chain correction.

**Đóng FINAL khi:** owner xác nhận append-only + có giới hạn số lần correction không.

---

### 2.15 OD-RATE-LIMIT-SCOPE-001 — Rate Limit Mở Rộng

**Default:**

| Scope                        | Limit/phút        | Limit/giờ | Key strategy     |
| ---------------------------- | ----------------- | --------- | ---------------- |
| Public trace `/api/public/*` | 60/IP             | 600/IP    | IP               |
| Admin command (POST/PATCH)   | 120/user          | —         | USER             |
| PWA submit                   | 60/device         | —         | DEVICE           |
| MISA callback inbound        | 30/source-IP      | —         | IP (whitelisted) |
| Supplier portal              | 60/supplier_user  | —         | USER             |
| Auth login                   | 10/IP, 5/username | —         | IP+USER          |

**Schema:**

```sql
CREATE TABLE op_rate_limit_policy (
  policy_id          BIGINT PRIMARY KEY,
  scope_code         TEXT NOT NULL UNIQUE,    -- 'PUBLIC_TRACE', 'ADMIN_COMMAND'...
  limit_per_minute   INT,
  limit_per_hour     INT,
  key_strategy       TEXT NOT NULL,           -- 'IP','USER','DEVICE','APIKEY','IP+USER'
  is_active          BOOLEAN NOT NULL DEFAULT TRUE,
  burst_size         INT
);
```

**Implementation:** middleware `RateLimitMiddleware` đọc policy từ cache (refresh 5 phút), trả `429 Too Many Requests` với `Retry-After` header khi vượt.

**Đóng FINAL khi:** owner xác nhận limit value cho từng scope.

## 3. OD Business Critical Đã Owner FINAL (3 OD)

> **Cập nhật PF-01 2026-05-03**: Owner đã trả lời FINAL cho 3 OD bên dưới. Evidence production lưu trên server công ty với adapter/config runtime; dev/test dùng local filesystem. Operational chỉ tạo notification outbox/job, còn delivery do hệ thống bán hàng/external notification service. PACKET không in QR vì luôn nằm trong BOX và inherit trace từ BOX/CARTON.

### 3.1 OD-EVIDENCE-STORAGE-001 — Storage Server Evidence

**Owner answer PF-01:** Evidence production lưu trên server công ty qua `COMPANY_SERVER` storage profile/adapter. Dev/test lưu tạm trên máy local bằng `LocalFileSystemEvidenceAdapter`. Adapter vẫn giữ cấu hình endpoint/path/credential/encryption/access-log/backup để sau này chỉ cần thay thông số hạ tầng thật.

**Abstraction:**

```csharp
public interface IEvidenceStorageAdapter {
    Task<EvidenceRef> UploadAsync(Stream content, EvidenceMetadata meta);
    Task<Stream> DownloadAsync(EvidenceRef);
    Task<string> GenerateSignedUrlAsync(EvidenceRef, TimeSpan ttl);
}
```

**Trạng thái PF-01:** `RESOLVED_FINAL`. Production dùng `COMPANY_SERVER` evidence storage profile/adapter trỏ tới server công ty; dev/test dùng `LocalFileSystemEvidenceAdapter` trên máy local. Các thông số endpoint/path/credential/encryption/access-log/backup bind runtime, DB chỉ lưu metadata/object key/hash. CODE05+CODE13 không bị block.

---

### 3.2 OD-NOTIFY-OWNERSHIP-001 — Operational vs Notification Service Boundary

**Owner answer PF-01:**

```
Operational chỉ làm:
- tạo notification_job_id
- ghi op_notification_outbox (job_id, channel, recipient_ref, payload, status='PENDING')
- expose endpoint internal /api/admin/notifications/jobs/{id} cho external consume

Operational KHÔNG:
- gọi SMTP/SMS/Zalo/Push gateway trực tiếp
- giữ template content/render
- track delivery status final

Sales/Notification system (out-of-scope) consume outbox event qua:
- pull từ /api/admin/notifications/jobs?status=PENDING
- HOẶC subscribe op_outbox_event topic NOTIFICATION_REQUESTED
```

**Production boundary:** Operational không gọi gateway thật. Hệ thống bán hàng/external notification service chịu trách nhiệm delivery.

**Trạng thái PF-01:** `RESOLVED_FINAL`. Operational chỉ tạo notification job/outbox và `notification_job_id`; hệ thống bán hàng/external notification service chịu trách nhiệm delivery, channel gateway, template render và SLA kênh gửi. CODE13 không bị block.

---

### 3.3 OD-PACKET-TRACE-001 — PACKET Không QR

**Owner answer PF-01:**

```
Spec hiện tại: PACKET label không in batch_code/QR (BR-M10-PAYLOAD-001).
Consumer mua lẻ PACKET → trace như thế nào?

Đề xuất: PACKET inherit trace qua BOX/CARTON parent.
- Mua nguyên BOX → scan QR trên BOX
- Mua từ thùng đại lý → scan QR trên CARTON
- API /api/public/trace/{qr_box_or_carton} → trả lot/batch áp cho TOÀN BỘ PACKET trong BOX/CARTON.

Owner final:
- Giữ policy "PACKET không QR" vì PACKET luôn nằm trong BOX.
- Public trace dùng BOX/CARTON QR; PACKET inherit trace từ parent packaging.
```

**Production boundary:** Implement endpoint trace trả về kết quả áp cho parent packaging; không tạo trace standalone cho PACKET trong V2.

**Trạng thái PF-01:** `RESOLVED_FINAL`. Policy "PACKET không QR" là canonical cho V2 vì PACKET luôn nằm trong BOX; public trace entry point là BOX/CARTON QR và PACKET inherit batch/trace từ parent packaging. CODE07+CODE12 không bị block.

---

### 3.4 OD-PRINTER-PROTO-001 — Printer Callback Auth Method

**Default đã đề xuất ở [OD-DEFAULTS-2026-05-03.md §2.5](OD-DEFAULTS-2026-05-03.md): HMAC-SHA256.** Đây là phụ trợ của OD-17, không tách FINAL riêng.

**Headers:**

```
X-Printer-Signature: HMAC-SHA256(secret, body + timestamp)
X-Printer-Timestamp: 1714723200  (skew ≤ 5 phút)
X-Device-Id: PRINTER-001
```

**Trạng thái PF-02:** Không tách OD riêng trong Batch 2; thuộc `OD-17` và đi theo `RESOLVED_FINAL_PF02_WITH_DEVICE_REFS` trong [`OD-DEFAULTS-2026-05-03.md`](OD-DEFAULTS-2026-05-03.md). HMAC-SHA256 là callback baseline để scaffold; production hardening thêm nếu có ADR hạ tầng mới.

## 4. Quy Trình Đóng OD

| Trạng thái | Điều kiện | Ghi nhận |
| ---------- | --------- | -------- |
| `RESOLVED_FINAL` | Owner chốt chính sách đủ để scaffold và production freeze. | Cập nhật `09_CONFLICT...` §C.8, sign-off table §5. |
| `RESOLVED_FINAL_PF02_WITH_DEVICE_REFS` | Device/printer physical detail được bind qua registry/config refs. | OD-17 ở Batch 1 đã chuyển sang trạng thái này. |
| `RESOLVED_FINAL_PF02_WITH_SECRET_REFS` | Credential/tenant/endpoint thật được bind qua config/secret refs. | OD-20 ở Batch 1 đã chuyển sang trạng thái này. |

## 5. Owner Sign-Off

### 5.1 RESOLVED_FINAL (15 OD)

| OD                         | PF-01 status | Ghi chú owner | Ngày |
| -------------------------- | ------------ | ------------- | ---- |
| OD-G2-001                  | RESOLVED_FINAL | Variance policy default accepted. | 2026-05-03 |
| OD-FORMULA-PICK-001        | RESOLVED_FINAL | Prefer FIXED when tie, audited override accepted. | 2026-05-03 |
| OD-EVIDENCE-SCAN-001       | RESOLVED_FINAL | Scanner adapter default accepted. | 2026-05-03 |
| OD-INVENTORY-ALLOC-001     | RESOLVED_FINAL | FEFO allocation accepted. | 2026-05-03 |
| OD-WAREHOUSE-3RD-001       | RESOLVED_FINAL | Zone model accepted for hold/return/recall. | 2026-05-03 |
| OD-SUP-AUTH-001            | RESOLVED_FINAL | Supplier auth/session policy accepted. | 2026-05-03 |
| OD-SUP-EVIDENCE-RETRY-001  | RESOLVED_FINAL | Replacement upload append-only accepted. | 2026-05-03 |
| OD-SUP-FEEDBACK-ENUM-001   | RESOLVED_FINAL | Feedback enum accepted. | 2026-05-03 |
| OD-SUP-CONFIRM-TIMEOUT-001 | RESOLVED_FINAL | 24h alert / 72h timeout accepted. | 2026-05-03 |
| OD-PACKAGING-DEFAULT-001   | RESOLVED_FINAL | Packaging default accepted, SKU override allowed. | 2026-05-03 |
| OD-CAPA-MODEL-001          | RESOLVED_FINAL | CAPA schema/status/close gate accepted. | 2026-05-03 |
| OD-MISA-DOC-OWNER-001      | RESOLVED_FINAL | M14 owns MISA document lifecycle from M08 event. | 2026-05-03 |
| OD-ADJUSTMENT-APPROVAL-001 | RESOLVED_FINAL | Adjustment approval tiers accepted. | 2026-05-03 |
| OD-WH-CORRECT-IDEMPO-001   | RESOLVED_FINAL | Append-only correction accepted. | 2026-05-03 |
| OD-RATE-LIMIT-SCOPE-001    | RESOLVED_FINAL | Rate-limit scopes accepted. | 2026-05-03 |

### 5.2 Group A Owner FINAL (3 OD)

| OD                      | PF-01 status | Câu trả lời owner | Ngày |
| ----------------------- | ------------ | ----------------- | ---- |
| OD-EVIDENCE-STORAGE-001 | RESOLVED_FINAL | Production evidence lưu trên server công ty qua config adapter; dev/test lưu local trên máy hiện tại. | 2026-05-03 |
| OD-NOTIFY-OWNERSHIP-001 | RESOLVED_FINAL | Operational chỉ tạo notification job/outbox; hệ thống bán hàng chịu trách nhiệm delivery. | 2026-05-03 |
| OD-PACKET-TRACE-001     | RESOLVED_FINAL | PACKET không QR vì luôn nằm trong BOX; trace qua BOX/CARTON QR. | 2026-05-03 |

Owner ký: owner directive PF-01
Ngày ký: 2026-05-03

## 6. Lịch Sử

| Ngày       | Thay đổi                                                                                                           | Người |
| ---------- | ------------------------------------------------------------------------------------------------------------------ | ----- |
| 2026-05-03 | PF-01 finalization: 15 OD Batch 2 + 3 OD Group A chuyển sang `RESOLVED_FINAL`; sign-off table đầy đủ owner/date/impact. | owner/Codex |
| 2026-05-03 | Khởi tạo Batch 2: 15 OD provisional + 3 OD owner-pending trước PF-01 + 2 patch tài liệu (CONFLICT-18, OD-M03-OWNERSHIP-001). | Codex |
