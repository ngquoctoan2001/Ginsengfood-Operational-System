# ADR-024 — `recall_applicable` ownership remains on `ref_sku_operational_config`

- Status: Accepted
- Date: 2026-04-29
- Decider: Owner + Tech Lead (Phase 5 packaging reconcile)
- Drives: M11 Recall, M01 SKU master data, seed file `12_op_sku_operational_config.sql`

## 1. Context

Phase 5 packaging redesign reverted drift on `ref_sku_operational_config` and explicitly listed `recall_applicable` as a per-SKU policy switch. Owner mandate ám chỉ "field/policy riêng cho recall" mà không quy định rõ có cần tách bảng `op_recall_policy` riêng hay không. Cần khoá quyết định để DB baseline + M11 implementation không phải chờ.

## 2. Decision

`recall_applicable boolean NOT NULL DEFAULT TRUE` ở lại trên `ref_sku_operational_config` cho V2 MVP. Không tạo bảng `op_recall_policy` riêng cho baseline.

Lý do giữ trên `ref_sku_operational_config`:

- Là cờ on/off đơn lẻ per SKU (không có thuộc tính phụ thuộc thời gian, không nhiều cột policy phụ).
- Đọc cùng lúc với `readiness_status`/`trace_public_enabled`/`qc_required` mỗi lần chuẩn bị production order, batch release, hoặc public trace decision; tách bảng làm tăng JOIN không cần thiết.
- Recall workflow dữ liệu giàu (decision, batch impact, customer notification, CAPA evidence) đã thuộc M11 tables (`op_recall_event`, `op_recall_capa`, `op_recall_capa_evidence`) — không cần "policy" riêng level SKU.
- Audit history per-SKU dùng audit log chuẩn (`op_audit_log`) cho thay đổi `recall_applicable`; không cần bảng versioned policy.

## 3. Khi nào cần tách `op_recall_policy`

Tách thành bảng riêng chỉ khi V3+ thêm bất kỳ scope nào sau đây:

- Recall policy có scope theo channel/region (ví dụ `recall_applicable_by_channel`, `recall_applicable_by_country`).
- Recall policy có effective window (`effective_from`, `effective_to`).
- Recall policy có nhiều cột phụ thuộc (notification template per SKU, CAPA SLA per SKU, escalation matrix per SKU).
- Recall workflow yêu cầu version history granularity nhỏ hơn audit log.

Khi xảy ra một trong các điều kiện trên, tạo migration `op_recall_policy` mới + ADR riêng + giữ `recall_applicable` cũ làm computed view tạm thời cho backward compatibility 1 release.

## 4. Hệ quả

- M11 Recall service đọc `recall_applicable` trực tiếp từ `ref_sku_operational_config` qua repository SKU operational config — không tự định nghĩa "recall policy" interface riêng.
- Seed file `12_op_sku_operational_config.sql` giữ field `recall_applicable` mặc định `TRUE` cho 20 SKU baseline.
- Public trace + recall API endpoints không expose field `recall_applicable` ra khách hàng (internal only); chỉ dùng làm guard ở backend.
- Audit log entry phải ghi rõ subject = `ref_sku_operational_config.recall_applicable` khi owner toggle.

## 5. Implementation gates

- Backend: SKU operational config repository expose `IsRecallApplicable(skuId)` boolean accessor; M11 service phải gọi accessor này trước khi cho phép tạo recall event đối với SKU.
- Frontend (admin UI): SCR-SKU-CONFIG checkbox `recall_applicable` (Vietnamese: "Áp dụng quy trình thu hồi") — owner sửa qua master data flow.
- Tests: unit test cho `recall_applicable = false` ⇒ M11 reject create recall event với error `RECALL_NOT_APPLICABLE_FOR_SKU` (thêm error code ở M11 spec khi scaffold service).

## 6. References

- `docs/software-specs/database/03_TABLE_SPECIFICATION.md` — `ref_sku_operational_config` schema
- `docs/software-specs/modules/13_RECALL.md` — M11 recall workflow
- `docs/seeds/12_op_sku_operational_config.sql` — canonical seed
