# 09 — Conflict and Owner Decisions

Tài liệu này tổng hợp các xung đột giữa các tài liệu nguồn và các điểm cần owner ra quyết định trước khi triển khai.

> Cập nhật source policy 2026-04-27: trong batch sửa `docs/software-specs/` hiện tại, owner yêu cầu không đọc source code, không dựa vào `AGENTS.md`, và không dùng ba thư mục `docs/ginsengfood_*`. Nguồn được phép dùng là prompt gốc, `docs-software/`, `.tmp-docx-extract/`, kiến thức chuyên môn, và sự phê duyệt của owner.

Ghi chú 2026-04-28: source policy trên áp dụng cho việc biên soạn/sửa requirement và source truth. Các prompt implementation trong `phase-project/` có thể yêu cầu đọc current code để audit gap/route/schema/write scope, nhưng code chỉ là implementation baseline/evidence, không được dùng để phủ quyết source truth.

## Mục lục

- [A0. Source Precedence Decision Cho Batch `docs/software-specs/`](#a0-source-precedence-decision-cho-batch-docssoftware-specs)
- [A1. Quyết Định Chuẩn Hóa Top-Level Docs Part 2](#a1-quyết-định-chuẩn-hóa-top-level-docs-part-2)
- [A. Quy ước](#a-quy-ước)
- [B. Xung đột giữa tài liệu nguồn](#b-xung-đột-giữa-tài-liệu-nguồn)
- [C. Điểm cần owner xác nhận](#c-điểm-cần-owner-xác-nhận)
- [D. `[BỔ SUNG TỪ specs.docx]` cần owner xác nhận](#d-bổ-sung-từ-specsdocx-cần-owner-xác-nhận)
- [E. Risks nếu không quyết kịp](#e-risks-nếu-không-quyết-kịp)
- [F. Quy trình resolve](#f-quy-trình-resolve)
- [G. Lịch sử update](#g-lịch-sử-update)

## A0. Source Precedence Decision Cho Batch `docs/software-specs/`

### CONFLICT-SRC-00 — `AGENTS.md`/canonical Markdown packs vs owner directive mới

- **Severity**: CRITICAL
- **Status**: RESOLVED 2026-04-27 theo owner directive mới cho batch tài liệu này
- **Nội dung mâu thuẫn**:
  - Một chỉ đạo vận hành trước đó yêu cầu dùng `AGENTS.md` và ba thư mục canonical Markdown packs trong `docs/ginsengfood_*` cho Operational V2.
  - Owner directive mới trong task hiện tại yêu cầu: `KHÔNG ĐỌC SOURCE CODE`, `KHÔNG DỰA VÀO AGENT.MD VÀ 3 THƯ MỤC canonical Markdown packs trong docs/ginsengfood_*`, và chỉ dựa vào prompt gốc, `docs-software/`, `.tmp-docx-extract/`, kiến thức chuyên môn, và phê duyệt owner.
- **Tài liệu A**: chỉ đạo vận hành agent/canonical packs được owner nhắc lại như một conflict cần ghi nhận; trong batch này không đọc lại/không dùng làm source.
- **Tài liệu B**: `OWNER-DIRECTIVE-2026-04-27-PART0` trong phiên hiện tại.
- **Tác động**:
  - `01_SOURCE_INDEX.md` phải phân loại `AGENTS.md` và `docs/ginsengfood_*` là `[EXCLUDED_SOURCE]` cho batch `docs/software-specs/`.
  - Không dùng current code, migration, seed, hoặc canonical Markdown packs để phủ quyết `docs-software/` và `.tmp-docx-extract/`.
  - Các hard lock như G1 initial operational baseline, 20 SKU baseline, 4 recipe groups, MISA integration layer, public trace field policy vẫn được giữ vì chúng có trong prompt gốc và/hoặc nguồn `.docx` được phép dùng.
- **Khuyến nghị chuẩn hóa**:
  - Dùng `docs-software/*.docx` là source file gốc.
  - Dùng `.tmp-docx-extract/*.txt` là bản đọc/cite của source file gốc.
  - Dùng `specs.docx`/`specs.txt` là `HISTORICAL_FALLBACK_SOURCE`, chỉ lấp khoảng trống khi không mâu thuẫn với nguồn mới.
  - Dùng kiến thức chuyên môn chỉ để chuẩn hóa format, option, thiếu sót, và phải gắn `[GIẢ ĐỊNH]` hoặc `[OWNER DECISION NEEDED]` khi không có căn cứ nguồn.
- **Owner decision cần có**: Không còn cho batch này; owner đã chốt phạm vi nguồn trong task hiện tại.
- **Trạng thái**: RESOLVED.

## A1. Quyết Định Chuẩn Hóa Top-Level Docs Part 2

### CONFLICT-DOC-17 — Module map legacy/generated vs 16 module file theo prompt gốc

- **Severity**: HIGH
- **Status**: RESOLVED 2026-04-27 theo Part 2
- **Nội dung mâu thuẫn**:
  - Một số file generated trước đó dùng mapping kiểu `MX1`, `MX2`, `M1`, `M2`, hoặc gắn chặt với CODE01-CODE17 như thể đó là module map.
  - Prompt gốc yêu cầu cây `modules/` gồm 16 file cố định từ `01_FOUNDATION_CORE.md` đến `16_ADMIN_UI.md`.
  - `SRC-FILE04-1` mô tả CODE01-CODE17 là phase/delivery order, không phải danh sách module thay thế cho prompt.
- **Tài liệu A**: bản generated cũ trong `docs/software-specs/` trước Part 2, đặc biệt `06_MODULE_MAP.md`, `07_PHASE_PLAN.md`, `08_REQUIREMENTS_TRACEABILITY_MATRIX.md`.
- **Tài liệu B**: `OWNER-PROMPT-INITIAL` yêu cầu 16 module file; `SRC-FILE04-1` yêu cầu CODE01-CODE17 cho phase triển khai.
- **Quyết định**:
  - Module map chính thức cho `docs/software-specs/` là 16 module:
    `M01 Foundation Core`,
    `M02 Auth Permission`,
    `M03 Master Data`,
    `M04 SKU Ingredient Recipe`,
    `M05 Source Origin`,
    `M06 Raw Material`,
    `M07 Production`,
    `M08 Material Issue Receipt`,
    `M09 QC Release`,
    `M10 Packaging Printing`,
    `M11 Warehouse Inventory`,
    `M12 Traceability`,
    `M13 Recall`,
    `M14 MISA Integration`,
    `M15 Reporting Dashboard`,
    `M16 Admin UI`.
  - CODE01-CODE17 là phase plan/delivery gates, được map tới các module trên trong [07_PHASE_PLAN.md](07_PHASE_PLAN.md), không được dùng thay thế module map.
  - Các nhãn legacy như `MX1`, `MX2`, `M1` cũ chỉ được xem là legacy/generated mapping hoặc readiness grouping, không dùng làm tên module cuối cùng.
- **Tác động**:
  - [06_MODULE_MAP.md](06_MODULE_MAP.md) đã được chuẩn hóa theo 16 module.
  - [07_PHASE_PLAN.md](07_PHASE_PLAN.md) giữ CODE01-CODE17 nhưng mỗi CODE map tới module liên quan.
  - [08_REQUIREMENTS_TRACEABILITY_MATRIX.md](08_REQUIREMENTS_TRACEABILITY_MATRIX.md) đã làm lại theo module M01-M16 và phase mapping riêng.
- **Owner decision cần có**: Không. Đây là chuẩn hóa theo prompt gốc và source phase được phép dùng.
- **Trạng thái**: RESOLVED.

### CONFLICT-DOC-18 — RTM cũ sai cột prompt và thiếu mapping module/API/UI/workflow/test

- **Severity**: HIGH
- **Status**: RESOLVED 2026-04-27 theo Part 2
- **Nội dung mâu thuẫn**:
  - Prompt gốc yêu cầu `08_REQUIREMENTS_TRACEABILITY_MATRIX.md` có các cột: `requirement_id`, `requirement`, `source document`, `source section`, `module`, `business rule`, `database table`, `API endpoint`, `UI screen`, `workflow`, `test case`, `priority`, `status`, `owner decision needed`.
  - Bản RTM generated cũ dùng cột `REQ ID`, `Tên`, `Status`, `Source`, `Ghi chú`, nên không đủ để PM/BA/SA/Dev/QA trace requirement sang DB/API/UI/workflow/test.
- **Tài liệu A**: `08_REQUIREMENTS_TRACEABILITY_MATRIX.md` bản generated cũ.
- **Tài liệu B**: `OWNER-PROMPT-INITIAL` mục `08_REQUIREMENTS_TRACEABILITY_MATRIX.md`.
- **Quyết định**:
  - Làm lại RTM theo đúng 14 cột prompt.
  - Mỗi requirement cấp nền phải gắn module M01-M16, business rule, database table, API endpoint, UI screen, workflow và test case.
  - Các endpoint/table trong RTM là contract/schema đích để viết spec chi tiết, không phải kết luận implementation vì batch này không đọc source code.
- **Tác động**:
  - RTM trở thành nền để viết tiếp nhóm `business/`, `functional/`, `database/`, `api/`, `ui/`, `workflows/`, `testing/`, `dev-handoff/`.
- **Owner decision cần có**: Không cho cấu trúc RTM. Các owner decision nghiệp vụ còn mở vẫn giữ ở mục C/D.
- **Trạng thái**: RESOLVED.

### DECISION-DOC-01 — Source rule áp dụng cho Part 2 và các phần viết tiếp

- **Status**: ACTIVE
- **Quy tắc**:
  - `docs-software/` và `.tmp-docx-extract/` là source chính theo prompt gốc.
  - `specs.docx`/`specs.txt` là `HISTORICAL_FALLBACK_SOURCE`, chỉ dùng khi nguồn mới thiếu và không mâu thuẫn; mọi nội dung fallback phải ghi nhãn.
  - `AGENTS.md`, source code, current migrations/seeds/database và `docs/ginsengfood_*` không dùng làm source trong batch `docs/software-specs/` theo owner directive.
  - Hard locks như G1, không dùng G0 vận hành, 20 SKU baseline, 4 recipe groups, MISA integration layer, public trace policy, QC release gate và material issue decrement vẫn giữ vì có trong prompt gốc và nguồn được phép dùng.
- **Tác động**:
  - Các file tiếp theo phải cite theo `01_SOURCE_INDEX.md`.
  - Khi thiếu thông tin, ghi `CHƯA ĐỦ THÔNG TIN` hoặc `OWNER DECISION NEEDED`, không tự bịa nghiệp vụ.

## A. Quy ước

- **Severity**: `CRITICAL` (block triển khai), `HIGH` (cần quyết trước phase liên quan), `MEDIUM` (có thể defer), `LOW` (cosmetic).
- **Status**: `OPEN` / `RESOLVED` / `DEFERRED`.

## B. Xung đột giữa tài liệu nguồn

### CONFLICT-01 — Recipe section: 2 nhóm cũ vs 4 nhóm mới

- **Severity**: CRITICAL
- **Status**: RESOLVED theo nguồn → 4 nhóm thắng
- **Source A** (cũ): `SRC-RECIPE-APPENDIX`, `HIST-SPECS` mô tả công thức theo 2 section "Dược liệu" + "Nguyên liệu".
- **Source B** (mới): `SRC-RECIPE-NEW` (`CÔNG THỨC 20 SKU MỚI`) quy định 4 phần tiếng Việt: "Thành phần đặc thù SKU", "Nguyên liệu nền dinh dưỡng", "Rau củ chiết dịch tạo nước hầm", "Nguyên liệu nêm & tạo hương vị".
- **Quyết định**: Dùng 4 group (`SRC-RECIPE-NEW` thắng `SRC-RECIPE-APPENDIX` theo precedence E.3 trong [01_SOURCE_INDEX.md](01_SOURCE_INDEX.md)). English enum `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR` là mapping spec chính thức, không phải exact string trong `.tmp-docx-extract`.
- **Tác động spec**: mọi UI/seed/snapshot trong bộ tài liệu này dùng 4 group và phải hiển thị/ghi mapping Việt ↔ enum rõ ràng.

### CONFLICT-02 — Recipe version baseline: G0 vs G1

- **Severity**: CRITICAL
- **Status**: RESOLVED theo nguồn → G1 thắng
- **Source A**: `SRC-RECIPE-APPENDIX` và một số phụ lục cũ liệt kê công thức gắn nhãn `G0` cho mọi SKU.
- **Source B**: `SRC-RECIPE-NEW`, `SRC-LOCK5`, `SRC-DEV-ORDER`, `SRC-CHECKLIST` quy định G1 là initial operational baseline cho go-live; G0 là research baseline only.
- **Quyết định**: theo nguồn, G0 không active trong operational seed/production/material issue/trace/recall. G1 là active baseline. Hệ thống phải hỗ trợ G2/G3/... tương lai. => Đúng
- **Tác động spec**: bộ tài liệu này mô tả seed/snapshot/config trỏ G1.

### CONFLICT-03 — Ingredient code: legacy `MAT-*` vs `HRB_*`/`ING_*`

- **Severity**: HIGH
- **Status**: RESOLVED theo nguồn → `HRB_*`/`ING_*` thắng, legacy thành alias
- **Source A**: `SRC-RECIPE-APPENDIX`, `HIST-SPECS` dùng `MAT-SAM-SAVIGIN`, `MAT-MI-CHINH`.
- **Source B**: `SRC-RECIPE-NEW`, `SRC-FILE02`, `SRC-LOCK5` chuẩn hoá `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`.
- **Quyết định**: theo nguồn, dùng `HRB_*`/`ING_*` làm operational business key. Giữ `MAT-*` như alias qua bảng `op_raw_material_alias` để compat. => Đúng
- **Tác động spec**: bộ tài liệu này mô tả ingredient master + alias theo cấu trúc trên.

### CONFLICT-04 — `Thịt heo nạc`: stock ingredient riêng hay là chế phẩm?

- **Severity**: MEDIUM
- **Status**: RESOLVED 2026-04-27 (owner)
- **Source A**: `SRC-RECIPE-NEW` cho B4 dùng "Thịt heo nạc 10.50 kg" như một recipe line riêng.
- **Source B**: `SRC-RECIPE-APPENDIX` và `HIST-SPECS` xem thịt heo nạc như chế phẩm trộn sẵn, không tách lot.
- **Quyết định owner**: `Thịt heo nạc` được xem như nguyên liệu thường, đăng ký thành `ING_THIT_HEO_NAC` trong ingredient master, có QC riêng và quản lý theo lot như các ingredient khác.

### CONFLICT-05 — Warehouse model: 1 kho hay multi-warehouse?

- **Severity**: HIGH
- **Status**: RESOLVED 2026-04-27 (owner) → multi-warehouse theo `warehouse_type`
- **Source A**: `SRC-FILE01`, `SRC-FILE04`, `SRC-DEV-ORDER` không nêu rõ số warehouse phase 1.
- **Source B**: `HIST-SPECS` mô tả warehouse master + location master với multi-warehouse.
- **Quyết định owner**: bắt buộc tách 2 loại kho ngay từ Phase 1:
  - `RAW_MATERIAL` — kho dự trữ tất cả nguyên liệu đầu vào, dùng để biết còn lại bao nhiêu phục vụ sản xuất; là nguồn cấp cho material issue khi mở production order.
  - `FINISHED_GOODS` — kho chứa sản phẩm sau sản xuất (thùng/hộp/đơn vị bán); hệ thống bán hàng đọc tồn kho từ đây và bán.
  - Mỗi loại kho có thể có nhiều warehouse instance (ví dụ nhiều kho FINISHED_GOODS theo khu vực) — schema phải hỗ trợ N warehouse, nhưng tối thiểu 1 RAW_MATERIAL + 1 FINISHED_GOODS cho go-live.
- **Tác động spec**: master data section phải có bảng `op_warehouse` với cột `warehouse_type ∈ {RAW_MATERIAL, FINISHED_GOODS}` và tồn kho tách theo type.

### CONFLICT-06 — GTIN/GS1 production data

- **Severity**: HIGH (block real commercial print)
- **Status**: RESOLVED 2026-04-27 (owner) → cấu hình fake fixture, có cả GTIN hộp và GTIN thùng
- **Source**: `SRC-FILE01`, `SRC-FORM-AUTO`, `HIST-SPECS` quy định trade item / GTIN / GS1 là identity riêng tách khỏi SKU; nhưng không file nguồn nào cung cấp GTIN cụ thể cho 20 SKU.
- **Quyết định owner**: công ty đã có GTIN thật nhưng chưa cấp cho dev, dev cấu hình fake fixture cho cả 2 cấp đóng gói:
  - `box_gtin` — GTIN cho hộp sản phẩm bán lẻ.
  - `carton_gtin` — GTIN cho thùng sản phẩm.
  - Đánh dấu fixture `TEST_ONLY_DEV_FIXTURE` để khi có GTIN thật thì swap không gây drift.
- **Tác động spec**: bảng `trade_item_gtin` phải hỗ trợ ít nhất 2 packaging level (BOX, CARTON) và cờ `is_test_fixture`.

### CONFLICT-07 — MISA endpoint/credential cho production

- **Severity**: HIGH
- **Status**: RESOLVED 2026-04-27 (owner) → MISA AMIS, retry 3x backoff, credential giả định
- **Source**: `SRC-FORM-AUTO` và `SRC-FILE01` quy định MISA integration layer chung với mapping/sync log/reconcile/audit; nhưng không file nguồn nào nêu rõ MISA SME hay AMIS, tenant ID, credential, retry policy production.
- **Quyết định owner**:
  - Edition: **MISA AMIS** (công ty đang dùng AMIS cho chấm công + kế toán).
  - Tenant ID + credential: cấu hình giả định trong dev, owner cung cấp giá trị thật sau.
  - Retry policy: 3 lần với exponential backoff (đơn giản); chính sách chi tiết owner update sau.
- **Tác động spec**: integration spec phải mặc định AMIS endpoints + 3-retry-backoff.

### CONFLICT-08 — Phase mapping canonical CODE01→CODE17

- **Severity**: MEDIUM
- **Status**: RESOLVED theo source + `OWNER-2026-04-27` → dùng CODE01→CODE17
- **Source A**: `SRC-FILE04-1` liệt kê phase code bắt buộc CODE01→CODE17, trong đó CODE09→CODE17 là admin UI, API contract, mobile/internal app, device integration, event schema/outbox, monitoring, override, retention/archive/restore, final close-out.
- **Source B**: bản re-plan generated trước đó đã gộp sai CODE13→17 thành analytics/AI/public-trace mở rộng và tách Master Data thành phase số riêng.
- **Quyết định**: [07_PHASE_PLAN.md](07_PHASE_PLAN.md) dùng canonical CODE01→CODE17. Master Data SKU/Recipe G1 là readiness gate trước CODE03, không phải phase số riêng. Không map CODE13→17 sang analytics/AI; Analytics/AI vẫn out-of-scope Operational nếu không có owner source mới.

### CONFLICT-09 — Click-vs-auto-display boundary

- **Severity**: LOW (đã có rule rõ)
- **Status**: RESOLVED 2026-04-27 (owner)
- **Quyết định**: `SRC-LOCK5` + `SRC-FORM-AUTO` thắng → raw material intake = click select (operator chọn linh hoạt vì có thể nhiều nguyên liệu khác nhau); production order/issue = auto-display từ formula snapshot (đã khoá công thức, tiết kiệm thời gian, tránh nhầm lẫn).

### CONFLICT-10 — Đơn vị batch chuẩn = 400

- **Severity**: MEDIUM
- **Status**: RESOLVED tạm 2026-04-27 (owner) → giữ giả định 400, owner update sau
- **Source**: `SRC-RECIPE-NEW` mọi công thức ghi "kg/batch 400".
- **Quyết định owner**: cứ cấu hình giả định 1 batch = 400 đơn vị (sachet/hũ). Khi owner có thông tin chính xác về đơn vị + packaging level thì cập nhật sau.

### CONFLICT-11 — Public trace expose source zone level chi tiết bao nhiêu?

- **Severity**: MEDIUM
- **Status**: RESOLVED 2026-04-27 (owner) → expose chi tiết tên vùng trồng + Tỉnh + Xã + địa chỉ chi tiết
- **Source A**: `SRC-FILE01` field policy nói KHÔNG expose supplier nội bộ, personnel, costing, QC defect, loss, MISA data.
- **Source B**: `HIST-SPECS` có gợi ý expose source zone level chi tiết hơn cho mục đích branding nhưng không khoá mức cụ thể.
- **Quyết định owner**: public trace expose source zone ở mức chi tiết nhất để làm thương hiệu và kể câu chuyện nguồn gốc:
  - `source_zone_name` — tên vùng trồng cụ thể (ví dụ "Vùng trồng Sâm Savigin Lâm Đồng").
  - `province` — Tỉnh.
  - `ward` — Xã. Đơn vị hành chính mới tại Việt Nam **không còn cấp Huyện**, không thêm field huyện.
  - `address_detail` — 1 trường input chung free-form cho địa chỉ cụ thể (số, đường, ấp, khu phố, …).
  - Vẫn giữ rule không expose supplier nội bộ, personnel, costing, QC defect, loss, MISA data.
- **Tác động spec**: bảng `op_source_zone` phải có 4 trường trên; public trace API phải expose 4 trường này; private internal field vẫn ẩn.

### CONFLICT-12 — Mobile: PWA hay native app?

- **Severity**: MEDIUM
- **Status**: RESOLVED 2026-04-27 (owner) → PWA-first
- **Source**: `SRC-FILE01` chỉ nói "mobile / internal app".
- **Quyết định owner**: làm **PWA trước** để phát triển/triển khai/bảo trì nhanh, hoạt động offline ở mức độ nhất định nếu thiết kế đúng, scan barcode dùng thư viện PWA hiện đại. Native app cân nhắc sau khi phát hiện nhu cầu thực tế (ví dụ scan/offline mạnh hơn).
- **Tác động spec**: mobile spec mặc định PWA; field PWA & printer-agent là 2 surface độc lập.

## C. Điểm cần owner xác nhận

### C.1 — Đã RESOLVED 2026-04-27

| ID    | Điểm cần quyết                                        | Quyết định owner                                                                                                                    |
| ----- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| OD-01 | `ING_THIT_HEO_NAC` có phải ingredient riêng theo lot? | RESOLVED → ingredient riêng, có QC, theo lot.                                                                                       |
| OD-02 | Warehouse model phase 1                               | RESOLVED → multi-warehouse theo `warehouse_type` (RAW_MATERIAL + FINISHED_GOODS), tối thiểu 1 instance mỗi loại go-live.            |
| OD-03 | Production GTIN/GS1 cho 20 SKU + packaging level      | RESOLVED → fake fixture, cấu hình cả `box_gtin` + `carton_gtin`, đánh dấu `TEST_ONLY_DEV_FIXTURE`. Owner update GTIN thật sau.      |
| OD-04 | MISA endpoint/credential production                   | RESOLVED → MISA AMIS, retry 3x exponential backoff, credential giả định, owner cung cấp thật sau.                                   |
| OD-05 | CODE09→CODE17 có cần giữ trong phase plan không?       | RESOLVED → giữ canonical CODE01→CODE17 theo `SRC-FILE04-1`; CODE09→17 là delivery/governance/ops gates, không phải analytics/AI.     |
| OD-06 | Đơn vị batch chuẩn = 400 (sachet/hũ?)                 | RESOLVED tạm → giữ giả định 400, owner update sau.                                                                                  |
| OD-07 | Mức expose source zone trong public trace             | RESOLVED → expose `source_zone_name` + `province` (Tỉnh) + `ward` (Xã, không có Huyện) + `address_detail` (free-form).              |
| OD-08 | Mobile PWA vs native                                  | RESOLVED → PWA-first.                                                                                                               |
| OD-09 | Source origin verification policy                     | RESOLVED → block intake/lot nếu source origin bắt buộc mà chưa `VERIFIED`.                                                          |
| OD-10 | Recall SLA business                                  | RESOLVED → phát hiện đến khóa batch + gửi notification phải < 4h.                                                                    |
| OD-15 | Operator authentication phase 1                       | RESOLVED → local account + RBAC; SSO identity map vào local user/role.                                                              |
| OD-16 | Ingredient procurement_type (tự trồng vs mua ngoài)   | RESOLVED → 2 type: `SELF_GROWN` (có source_zone + source_origin) vs `PURCHASED` (chỉ supplier, không source_zone). Xem CONFLICT-13. |
| OD-18 | Chuỗi công đoạn sản xuất bắt buộc                      | RESOLVED → mọi sản phẩm phải đi qua `Sơ chế → Cấp đông → Sấy thăng hoa`; không được bỏ qua cấp đông. Xem CONFLICT-15.               |
| OD-19 | 20 SKU/công thức là baseline hay giới hạn vĩnh viễn?   | RESOLVED → 20 SKU/G1 là baseline go-live; hệ thống phải có CRUD/API + approval/versioning cho SKU, công thức và config tương lai.   |

### C.2 — Còn OPEN

| ID    | Điểm cần quyết                                                     | Severity | CODE chặn |
| ----- | ------------------------------------------------------------------ | -------- | --------- |
| OD-11 | Trace query SLA technical: target latency?                         | MEDIUM   | CODE07    |
| OD-12 | Backup/DR target: RPO, RTO?                                        | HIGH     | CODE16    |
| OD-13 | Audit log retention: bao lâu?                                      | HIGH     | CODE16    |
| OD-14 | Public trace có cần multi-language không?                          | LOW      | CODE07    |
| OD-17 | Production printer model + driver chính thức                       | MEDIUM   | CODE12    |
| OD-20 | MISA AMIS tenant/credential/endpoint thật cho production            | HIGH     | CODE13/CODE17 |
| OD-21 | PWA task taxonomy và endpoint inbox `/api/admin/tasks/my`           | MEDIUM   | CODE11    |
| OD-22 | Các mutation endpoint UI phụ: UOM write, raw lot hold/release, process command, screen registry write | MEDIUM | CODE09/CODE10/CODE11 |

Các OD trên là implementation blocker list chính thức:

| OD | Không được freeze trước khi chốt | Có thể làm trước |
| -- | -------------------------------- | ---------------- |
| OD-11 | Trace index/cache sizing và SLO final cho CODE07. | Ghi metric trace query và thiết kế query path có thể cấu hình. |
| OD-12 | RPO/RTO, backup topology, restore drill gate cho CODE16. | Viết runbook/adapter restore generic. |
| OD-13 | Retention/archive/search boundary và storage sizing cho CODE16. | Thiết kế retention configurable, không hard-code thời hạn. |
| OD-14 | Public trace i18n contract final. | Ship single-language với field i18n-ready nếu cần. |
| OD-17 | Production printer driver/model final cho CODE12. | Adapter/queue/callback generic, không bind driver cụ thể. |
| OD-20 | Real MISA sync enablement cho production. | Giữ dry-run/fake credential dev; không hard-code secret trong spec/code. |
| OD-21 | PWA task inbox contract final. | Giữ endpoint placeholder có đánh dấu `[OWNER DECISION NEEDED]`; command vẫn dùng idempotency. |
| OD-22 | UI mutation route taxonomy final. | Chỉ dùng canonical route family hiện có; endpoint chưa chốt phải ghi owner decision, không tạo route song song. |

### C.3 — CONFLICT-13: Ingredient procurement_type (mới, owner đã chốt cùng đợt 2026-04-27)

- **Severity**: HIGH (ảnh hưởng schema + form raw material intake + public trace)
- **Status**: RESOLVED 2026-04-27 (owner)
- **Source**: `OWNER-2026-04-27` (chưa có trong file nguồn `.tmp-docx-extract/`).
- **Quyết định owner**: nguyên liệu chia thành **2 loại theo nguồn gốc procurement**:
  - `SELF_GROWN` — nguyên liệu công ty tự trồng. Khi nhập (raw material intake) **bắt buộc** có `source_zone_id` + `source_origin` (vùng trồng + tỉnh + xã + địa chỉ chi tiết). Không cần supplier (vì là nội bộ).
  - `PURCHASED` — nguyên liệu mua ngoài từ nhà cung cấp. Khi nhập **bắt buộc** có `supplier_id`, **không** có `source_zone`, **không** có `source_origin`.
  - Cùng một `ingredient_master_code` có thể vừa được intake dạng SELF_GROWN vừa dạng PURCHASED ở các lot khác nhau (bind type ở mức lot, không ở mức ingredient master).
- **Tác động spec**:
  - Bảng `op_raw_material_lot` phải có cột `procurement_type ∈ {SELF_GROWN, PURCHASED}`, `source_zone_id NULL khi PURCHASED`, `supplier_id NULL khi SELF_GROWN`, ràng buộc check.
  - Form raw material intake phải hiển thị field theo `procurement_type` (chọn type trước → enable/disable field tương ứng).
  - Public trace chỉ resolve source zone khi lot có `procurement_type = SELF_GROWN`; lot PURCHASED hiển thị nguồn gốc theo policy ẩn supplier (theo CONFLICT-11).

### C.4 — CONFLICT-14: SKU ownership transitional

- **Severity**: HIGH (ảnh hưởng boundary Catalog/Product vs Operational, seed, production order snapshot)
- **Status**: RESOLVED 2026-04-27 (`OWNER-2026-04-27`)
- **Source A**: `SRC-FILE01` owner boundary quy định Operational chỉ giữ reference key như `sku_id` cho external domains.
- **Source B**: `SRC-FILE02`, `SRC-LOCK5`, `SRC-RECIPE-NEW` cần 20 SKU canonical + G1 recipe/config để production order CODE03 snapshot đúng.
- **Quyết định**: Catalog/Product là owner cuối cùng của SKU identity. Vì hiện chưa có Catalog domain riêng, Operational tạm giữ `ref_sku` và recipe/config link để phục vụ G1 go-live. Khi Catalog domain ra đời, `ref_sku` chuyển thành read-only proxy/snapshot reference; Operational chỉ giữ `sku_id` trong transaction và snapshot.
- **Tác động spec**:
  - Không mô tả Operational như owner dài hạn của SKU master.
  - MX2 Master Data là readiness gate trước CODE03, không phá boundary ownership.
  - Production order snapshot vẫn capture SKU/formula tại thời điểm mở để không rewrite history.

### C.5 — CONFLICT-15: Manufacturing process thiếu công đoạn cấp đông

- **Severity**: HIGH (ảnh hưởng workflow sản xuất, QC, genealogy, acceptance criteria)
- **Status**: RESOLVED 2026-04-27 (`OWNER-2026-04-27`)
- **Source A**: `SRC-FILE03` khóa các form/lệnh lõi có F-06 sơ chế và F-07 QC sau sấy, nhưng không tách rõ record lệnh cấp đông trong danh sách 12 phiếu/lệnh.
- **Source B**: owner xác nhận quy trình sản xuất thực tế cho mọi sản phẩm là **Sơ chế → Cấp đông → Sấy thăng hoa**.
- **Quyết định**:
  - Giữ F-06 là phiếu sơ chế và F-07 là phiếu QC sau sấy thăng hoa theo FILE03.
  - Bổ sung `R-FREEZE` như lệnh/record công đoạn cấp đông bắt buộc sau F-06.
  - Bổ sung `R-FD` như lệnh/record công đoạn sấy thăng hoa bắt buộc sau `R-FREEZE`.
  - Packaging cấp 1/cấp 2 và QC thành phẩm không được mở nếu chuỗi trên chưa hoàn tất đúng thứ tự.
- **Tác động spec**: business process, form/document map, functional requirements, use cases, user stories, acceptance criteria và feature map phải thể hiện đủ chuỗi `PREPROCESSING → FREEZING → FREEZE_DRYING`.

### C.6 — CONFLICT-16: 20 SKU/G1 baseline vs long-term SKU/recipe CRUD

- **Severity**: HIGH (ảnh hưởng API, database, seed strategy, ownership boundary)
- **Status**: RESOLVED 2026-04-27 (`OWNER-2026-04-27`)
- **Source A**: `SRC-FILE02`, `SRC-LOCK5`, `SRC-RECIPE-NEW` khóa 20 SKU + G1 recipe làm baseline operational go-live.
- **Source B**: owner xác nhận 20 SKU không phải giới hạn vĩnh viễn; công thức cũng sẽ thay đổi theo đời sản phẩm.
- **Quyết định**:
  - 20 SKU/G1 là **initial operational baseline**, không được hard-code thành giới hạn vĩnh viễn.
  - Seed G1 chỉ là dữ liệu khởi tạo; hệ thống phải có CRUD/API cho SKU, ingredient, recipe formula header, recipe lines, SKU operational config, packaging config, trade item/GTIN config.
  - Thay đổi công thức phải đi qua versioning/approval/activate/retire; không mutate snapshot production order cũ.
  - Boundary vẫn giữ như CONFLICT-14: Catalog/Product là owner dài hạn của SKU identity; Operational tạm giữ `ref_sku` cho go-live và lưu snapshot transaction.
- **Tác động spec**: MX2 là readiness gate trước CODE03, không phải “seed xong là đóng”; database/API docs phải có quản trị master/config dài hạn.

## D. `[BỔ SUNG TỪ specs.docx]` cần owner xác nhận

Các nội dung sau lấy từ `HIST-SPECS` (specs.docx) và CHƯA có canonical doc xác nhận. Owner cần duyệt từng item.

| ID    | Nội dung                                                                                        | Đánh giá                                                                                     |
| ----- | ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| HS-01 | 17 screen `UI-OM-01` → `UI-OM-17` đầy đủ tên + role gate                                        | Cần đối chiếu với screen list trong `SRC-LOCK5` và `SRC-FILE04`.                             |
| HS-02 | Phần I (Governance): role-based access control, manual override governance, incident management | Cần đối chiếu với role/approval trong `SRC-FILE03` và `SRC-FORM-AUTO`.                       |
| HS-03 | Phần H (Device): Industrial device boundary, PrinterIntegrationService design                   | Có hiện diện trong `SRC-FILE01` và `SRC-FILE05` nhưng implementation detail cần owner duyệt. |
| HS-04 | Trace query latency target                                                                      | Là NFR — cần owner chốt SLA qua OD-11.                                                       |
| HS-05 | Audit log retention rule                                                                        | Là compliance — cần owner chốt theo OD-13 và quy định ngành.                                 |

## E. Risks nếu không quyết kịp

| Risk                                                                             | CODE chặn       | Mitigation                                                         |
| -------------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------ |
| Không có GTIN production → không in mã thương mại thật được                      | CODE04          | Owner mua GS1 prefix + assign GTIN trước commercial print.          |
| Không có MISA credential → không sync kế toán thật                               | CODE13/CODE17   | Build dry-run mode, defer real sync sau credential ready.           |
| Không quyết trace query technical SLA → khó sizing index/cache đúng              | CODE07          | Thiết kế đo metric trước; chốt SLA trước performance freeze.        |
| Không quyết backup/DR + retention → khó đóng CODE16                              | CODE16          | Thiết kế retention/archive configurable; chốt RPO/RTO trước release. |
| Không quyết production printer model → CODE12 chỉ dừng ở adapter/queue generic   | CODE12          | Dùng adapter abstraction; cần driver thật trước factory smoke.      |

## F. Quy trình resolve

1. Owner review file này.
2. Owner ghi quyết định vào cột "Quyết định" cho từng dòng (hoặc tạo issue tracker).
3. Update lại spec liên quan (`02_EXECUTIVE_SUMMARY.md`, các module spec, requirements traceability).
4. Đóng entry tại đây với status `RESOLVED` + ngày + người duyệt.

## G. Lịch sử update

| Ngày       | Thay đổi                                                                                                                                                                                                                               | Người            |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| 2026-04-25 | Khởi tạo Batch 1 với 12 conflict + 15 owner decision                                                                                                                                                                                   | (auto-generated) |
| 2026-04-27 | Owner duyệt batch resolve: CONFLICT-04/05/06/07/08/09/10/11/12 RESOLVED; OD-01→OD-10, OD-15, OD-16 RESOLVED; thêm CONFLICT-13 (ingredient procurement_type SELF_GROWN/PURCHASED) và CONFLICT-14 (SKU ownership transitional). Sửa phase plan về CODE01→CODE17 theo `SRC-FILE04-1`. | owner            |
| 2026-04-27 | Owner bổ sung OD-18/CONFLICT-15: mọi sản phẩm phải qua `Sơ chế → Cấp đông → Sấy thăng hoa`; OD-19/CONFLICT-16: 20 SKU/G1 là baseline, hệ thống phải có CRUD/API + versioning/config cho SKU/công thức dài hạn. | owner |
| 2026-04-27 | Thêm `CONFLICT-SRC-00` và khóa source policy cho batch `docs/software-specs/`: không đọc source code, không dùng `AGENTS.md`, không dùng `docs/ginsengfood_*`; chỉ dùng prompt gốc, `docs-software/`, `.tmp-docx-extract/`, kiến thức chuyên môn, và phê duyệt owner. | owner |
| 2026-04-27 | Part 2 chuẩn hóa 10 top-level docs: `06_MODULE_MAP.md` dùng 16 module theo prompt, `07_PHASE_PLAN.md` giữ CODE01-CODE17 như phase/delivery gates, `08_REQUIREMENTS_TRACEABILITY_MATRIX.md` làm lại đúng 14 cột prompt và map requirement sang module/API/UI/DB/workflow/test. | Codex |
| 2026-04-28 | Rà lại top-level docs sau khi thêm `phase-project/`: đồng bộ OD-20/21/22 vào executive/phase/RTM, sửa số liệu consistency, làm rõ code chỉ được đọc ở implementation phase như baseline, và cập nhật legacy mapping thành historical mapping. | Codex |
