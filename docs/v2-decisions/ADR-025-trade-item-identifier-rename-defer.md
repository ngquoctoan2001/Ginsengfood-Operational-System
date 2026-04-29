# ADR-025 — `op_trade_item_gtin` table name locked for V2; rename to `op_trade_item_identifier` deferred to V3

- Status: Accepted
- Date: 2026-04-29
- Decider: Owner + Tech Lead (Phase 5 packaging reconcile)
- Drives: M10 Packaging/Printing, API contracts, OpenAPI generation, frontend types

## 1. Context

Phase 5 mandate giữ tên bảng `op_trade_item_gtin` nhưng thêm discriminator `identifier_type IN ('GTIN_13','GTIN_14','SSCC','INTERNAL_BARCODE','TEST_FIXTURE')`. Kỹ thuật, bảng giờ chứa nhiều loại định danh (không chỉ GTIN). Owner accept "khuyến nghị dài hạn rename `op_trade_item_gtin` → `op_trade_item_identifier`" nhưng không thực hiện trong V2 MVP.

Cần khoá quyết định để: (a) DB baseline migration không rename, (b) API/OpenAPI contract dùng tên `tradeItemGtin*`/`/trade-items/*/gtins` không bị sửa giữa chừng làm vỡ frontend/admin types, (c) V3 có plan rename rõ ràng.

## 2. Decision

### V2 MVP (now → release 1.0)

- Tên bảng vật lý: `op_trade_item_gtin` (giữ nguyên).
- Schema mới Phase 5: `identifier_type`, `identifier_value`, `is_test_fixture`, `effective_from`, `effective_to`, `status`. Không còn cột `gtin`.
- Constraint: `UNIQUE (identifier_type, identifier_value) WHERE status = 'ACTIVE'`.
- API route family: `/api/admin/trade-items/{tradeItemId}/identifiers` (NEW route family đặt theo nghĩa, không theo tên bảng) + alias `/api/admin/trade-items/{tradeItemId}/gtins` deprecated nếu route GTIN cũ đã tồn tại; nếu API chưa scaffold, dùng `identifiers` ngay từ baseline.
- DTO/OpenAPI tên: `TradeItemIdentifierResponse`, `TradeItemIdentifierCreateRequest` (đặt theo nghĩa, độc lập với tên bảng vật lý).
- Repository class: `TradeItemIdentifierRepository` (đặt theo nghĩa).
- Lý do tách tên route/DTO/repo khỏi tên bảng: cho phép rename bảng V3 mà không vỡ public API/OpenAPI/frontend types.

### V3 rename plan (deferred)

Khi mở V3 milestone, tạo migration:

1. `RENAME TABLE op_trade_item_gtin TO op_trade_item_identifier`.
2. `RENAME CONSTRAINT`/index theo cùng pattern (`pk_op_trade_item_gtin` → `pk_op_trade_item_identifier`, ...).
3. Giữ view `op_trade_item_gtin` (read-only) cho backward compatibility 1 release nếu có integration ngoài đọc trực tiếp DB.
4. Cập nhật ADR-025 thành `Superseded by ADR-XXX (V3 rename executed)`.

API/DTO/route đã đặt sẵn theo nghĩa từ V2 nên KHÔNG bị ảnh hưởng — chỉ EF entity + migration thay tên.

## 3. Hệ quả

- M10 module spec phải dùng tên route `/api/admin/trade-items/{id}/identifiers` ngay từ baseline (cập nhật catalog API endpoint trước khi sinh OpenAPI lần đầu).
- Frontend admin tạo TypeScript type `TradeItemIdentifier` (không phải `TradeItemGtin`) ngay từ phase đầu khi admin UI scaffold.
- Backend EF entity tạm thời `TradeItemGtin` map vào bảng `op_trade_item_gtin` qua `[Table("op_trade_item_gtin")]`; class name `TradeItemGtin` chỉ dùng nội bộ — service/controller/DTO dùng `TradeItemIdentifier`.
- Seed file dùng tên bảng vật lý hiện tại `op_trade_item_gtin` (xem `docs/seeds/16_op_trade_item_packaging.sql`).
- Bất kỳ DOC/spec nào sau này nhắc tên bảng phải dùng `op_trade_item_gtin` cho V2 và note "rename → `op_trade_item_identifier` planned V3 (ADR-025)".

## 4. Implementation gates

- API spec freeze: route `/api/admin/trade-items/{tradeItemId}/identifiers` + DTO `TradeItemIdentifier*` phải xuất hiện trong `api/02_API_ENDPOINT_CATALOG.md` + `api/03_API_REQUEST_RESPONSE_SPEC.md` trước khi backend scaffold endpoint.
- OpenAPI generator phải sinh client method tên `listTradeItemIdentifiers`/`createTradeItemIdentifier` (không phải `*Gtin`).
- Migration test: V3 rename migration phải có integration test verify view `op_trade_item_gtin` vẫn SELECTable trong 1 release sau rename (nếu chọn keep view).

## 5. References

- `docs/software-specs/database/03_TABLE_SPECIFICATION.md` — `op_trade_item_gtin` schema row + comment "Khuyến nghị dài hạn rename thành `op_trade_item_identifier`"
- `docs/software-specs/modules/10_PACKAGING_PRINTING.md` — M10 module spec
- `docs/seeds/16_op_trade_item_packaging.sql` — canonical seed dùng tên bảng vật lý hiện tại
