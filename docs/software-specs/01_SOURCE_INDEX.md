# 01 - Source Index

> Mục đích: khóa lại danh mục nguồn được phép dùng khi biên soạn `docs/software-specs/`, tránh tiếp tục sửa tài liệu trên nền source precedence mâu thuẫn.

## 1. Phạm Vi Áp Dụng

File này chỉ áp dụng cho bộ tài liệu phân tích phần mềm tại `docs/software-specs/`.

Trong phạm vi bộ spec này:

- Không đọc source code.
- Không dùng source code hiện tại làm source of truth.
- Không dùng `AGENTS.md` làm source of truth.
- Không dùng ba thư mục Markdown pack `docs/ginsengfood_*` làm source of truth.
- Không dùng current database/migration/seed hiện hữu để phủ quyết tài liệu nguồn.
- Chỉ dùng `docs-software/`, `.tmp-docx-extract/`, prompt gốc, kiến thức phân tích hệ thống, và quyết định/phê duyệt của owner.

Phạm vi trên áp dụng cho việc biên soạn/sửa requirement và source truth của `docs/software-specs/`. Ở phase implementation sau này, AI agents có thể đọc current code theo prompt trong `phase-project/` để audit gap, route impact, schema impact và write scope, nhưng current code chỉ là implementation baseline/evidence, không được dùng để phủ quyết source truth đã khóa trong file này.

Quy tắc này được khóa theo chỉ đạo owner trong phiên 2026-04-27:

`OWNER-DIRECTIVE-2026-04-27-PART0`: "Chỉ dựa vào prompt gốc, `docs-software/`, `.tmp-docx-extract/`, toàn bộ kiến thức của bạn và sự phê duyệt của tôi."

## 2. Phân Loại Nguồn

| Loại nguồn                                              | Mã                                 | Được dùng?   | Vai trò                                                                                                                                                                        | Quy tắc sử dụng                                                                                                    |
| ------------------------------------------------------- | ---------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| Prompt gốc của owner                                    | `OWNER-PROMPT-INITIAL`             | Có           | Xác định mục tiêu, cấu trúc file đầu ra, nguyên tắc G1 và loại trừ baseline nghiên cứu khỏi vận hành, yêu cầu traceability, phase, module, API, UI, DB, testing, AI agent pack | Dùng làm yêu cầu đầu ra và nguyên tắc biên soạn chính                                                              |
| Chỉ đạo owner mới nhất                                  | `OWNER-DIRECTIVE-2026-04-27-PART0` | Có           | Chốt source policy cho `docs/software-specs/`                                                                                                                                  | Có hiệu lực cao nhất cho việc chọn nguồn trong bộ spec này                                                         |
| 16 tài liệu vận hành mới trong `docs-software/`         | `SRC-*`                            | Có           | Nguồn nghiệp vụ/kỹ thuật chính                                                                                                                                                 | Dùng làm requirement source chính                                                                                  |
| Bản text extract trong `.tmp-docx-extract/`             | `SRC-*` tương ứng                  | Có           | Bản đọc/cite của các `.docx`                                                                                                                                                   | Dùng để đọc, trích section, lập traceability                                                                       |
| `specs.docx` / `specs.txt`                              | `HIST-SPECS`                       | Có giới hạn  | Tài liệu hệ thống cũ                                                                                                                                                           | Chỉ dùng để lấp khoảng trống khi tài liệu mới thiếu và không mâu thuẫn                                             |
| Owner clarification/phê duyệt                           | `OWNER-*`                          | Có           | Đóng quyết định còn thiếu hoặc resolve conflict                                                                                                                                | Phải ghi vào `09_CONFLICT_AND_OWNER_DECISIONS.md`                                                                  |
| `docs/v2-decisions/` — accepted supplementary decisions | `V2-DECISION-*`                    | Có (bổ sung) | Ghi nhận quyết định owner được chấp nhận sau khi spec đã close; bổ sung và làm rõ conflict đã đóng; không phủ quyết `docs/software-specs/` trừ khi decision nói rõ là override | Tham khảo song song với spec chính; nếu mâu thuẫn thì spec thắng trừ khi decision ghi rõ override                  |
| Kiến thức chuyên môn BA/SA/Architecture/DB/API/UI/QA    | `PROFESSIONAL-KNOWLEDGE`           | Có giới hạn  | Chuẩn hóa cấu trúc đặc tả phần mềm, đề xuất option, nhận diện thiếu sót                                                                                                        | Không được tạo business rule mới nếu không có nguồn; nếu dùng phải gắn `[GIẢ ĐỊNH]` hoặc `[OWNER DECISION NEEDED]` |
| Source code/current implementation                      | `CURRENT-CODE`                     | Không        | Chỉ có thể là evidence hiện trạng ở phase khác nếu owner yêu cầu                                                                                                               | Không dùng trong batch tài liệu này                                                                                |
| `AGENTS.md`                                             | `AGENT-INSTRUCTION`                | Không        | Có thể chứa quy tắc vận hành agent                                                                                                                                             | Không dùng làm nguồn yêu cầu cho `docs/software-specs/` theo owner directive mới                                   |
| `docs/ginsengfood_final_pack_md/`                       | `MD-PACK-FINAL`                    | Không        | Markdown pack ngoài phạm vi batch này                                                                                                                                          | Không dùng trong batch tài liệu này                                                                                |
| `docs/ginsengfood_forms_operational_md_pack/`           | `MD-PACK-FORMS`                    | Không        | Markdown pack ngoài phạm vi batch này                                                                                                                                          | Không dùng trong batch tài liệu này                                                                                |
| `docs/ginsengfood_sku_recipe_md_pack/`                  | `MD-PACK-SKU-RECIPE`               | Không        | Markdown pack ngoài phạm vi batch này                                                                                                                                          | Không dùng trong batch tài liệu này                                                                                |

## 3. Nguồn Chính Được Phép Dùng

Các file `.docx` trong `docs-software/` là nguồn gốc. Các file `.txt` trong `.tmp-docx-extract/` là bản trích xuất được dùng để đọc/cite khi tạo Markdown.

| Mã nguồn              | File `.docx` trong `docs-software/`                                                                | File `.txt` trong `.tmp-docx-extract/`                                                            | Vai trò                                                                        |
| --------------------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `SRC-FILE01`          | `FILE 01 BẢN CHA SẠCH FINAL SẢN XUẤT NHẬP KHO TRUY VẾT THU HỒI CÓ LIÊN KẾT MISA GINSENGFOOD..docx` | `FILE 01 BẢN CHA SẠCH FINAL SẢN XUẤT NHẬP KHO TRUY VẾT THU HỒI CÓ LIÊN KẾT MISA GINSENGFOOD..txt` | Kiến trúc tổng thể, owner boundary, trace/recall, MISA boundary, route policy  |
| `SRC-FILE02`          | `FILE 02 MASTER DATA & RULE PACK — GINSENGFOOD..docx`                                              | `FILE 02 MASTER DATA & RULE PACK — GINSENGFOOD..txt`                                              | Master data, SKU, ingredient, recipe rules                                     |
| `SRC-FILE03`          | `FILE 03 — BỘ PHIẾU & LUỒNG VẬN HÀNH CHUẨN — GINSENGFOOD.docx`                                     | `FILE 03 — BỘ PHIẾU & LUỒNG VẬN HÀNH CHUẨN — GINSENGFOOD.txt`                                     | Operational forms, workflow, role/action/state                                 |
| `SRC-FILE04`          | `FILE 04 — DEV HANDOFF & TRIỂN KHAI DEV FINAL — GINSENGFOOD.docx`                                  | `FILE 04 — DEV HANDOFF & TRIỂN KHAI DEV FINAL — GINSENGFOOD.txt`                                  | Dev handoff, route family, delivery gate                                       |
| `SRC-FILE04-1`        | `FILE 04.1 PHASE CODE TRIỂN KHAI BẮT BUỘC.docx`                                                    | `FILE 04.1 PHASE CODE TRIỂN KHAI BẮT BUỘC.txt`                                                    | Phase CODE01-CODE17, delivery order, operational hardening                     |
| `SRC-FILE05`          | `FILE 05 BẢN QUY TẮC CODE KỸ THUẬT HỆ SẢN XUẤT.docx`                                               | `FILE 05 BẢN QUY TẮC CODE KỸ THUẬT HỆ SẢN XUẤT.txt`                                               | Technical rules, API style, audit, route, append-only behavior                 |
| `SRC-LOCK5`           | `BỘ KHÓA 5 BƯỚC.docx`                                                                              | `BỘ KHÓA 5 BƯỚC.txt`                                                                              | Go-live locks: SKU, ingredient, G1 recipe, forms, snapshot                     |
| `SRC-CHECKLIST`       | `CHECKLIST TRIỂN KHAI THỰC CHIẾN.docx`                                                             | `CHECKLIST TRIỂN KHAI THỰC CHIẾN.txt`                                                             | Practical implementation checklist                                             |
| `SRC-RECIPE-NEW`      | `CÔNG THỨC 20 SKU MỚI.docx`                                                                        | `CÔNG THỨC 20 SKU MỚI.txt`                                                                        | G1 recipe baseline for 20 SKU                                                  |
| `SRC-PRINT-CMD`       | `mẫu phiếu lệnh sản xuất.docx`                                                                     | `mẫu phiếu lệnh sản xuất.txt`                                                                     | Production order print form                                                    |
| `SRC-FORM-AUTO`       | `PHIẾU TỰ SINH ,IN, KẾ TOÁN HẠCH TOÁN.docx`                                                        | `PHIẾU TỰ SINH ,IN, KẾ TOÁN HẠCH TOÁN.txt`                                                        | Auto-generated forms, print, accounting posting boundary, approval/audit chain |
| `SRC-RECIPE-APPENDIX` | `PHỤ LỤC CÔNG THỨC PHIẾU LỆNH.docx`                                                                | `PHỤ LỤC CÔNG THỨC PHIẾU LỆNH.txt`                                                                | Recipe appendix/history, used only when not conflicting with newer G1 source   |
| `SRC-REPO-CODE01-A`   | `1. GÓI REPO-READY — CODE 01.docx`                                                                 | `1. GÓI REPO-READY — CODE 01.txt`                                                                 | Repo-ready CODE01 package, backend/database/bootstrap guidance                 |
| `SRC-REPO-CODE01-B`   | `GÓI TRIỂN KHAI REPO-READY — CODE 01.docx`                                                         | `GÓI TRIỂN KHAI REPO-READY — CODE 01.txt`                                                         | Alternate CODE01 package, likely overlapping with `SRC-REPO-CODE01-A`          |
| `SRC-DEV-ORDER`       | `LỆNH GIAO DEV CODE 01 → 08.docx`                                                                  | `LỆNH GIAO DEV CODE 01 → 08.txt`                                                                  | Dev task order CODE01-CODE08, validation gates                                 |
| `SRC-CLEAN-04`        | `01 -04 BỘ SẠCH HOÀN CHỈNH — WORD-READY.docx`                                                      | `01 -04 BỘ SẠCH HOÀN CHỈNH — WORD-READY.txt`                                                      | Consolidated FILE01-FILE04 cross-check pack                                    |

## 4. Nguồn Lịch Sử Fallback

| Mã nguồn     | File `.docx` | File `.txt` | Vai trò                    | Quy tắc bắt buộc                                                                                                     |
| ------------ | ------------ | ----------- | -------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `HIST-SPECS` | `specs.docx` | `specs.txt` | Tài liệu mô tả hệ thống cũ | Chỉ dùng khi nguồn chính thiếu nội dung cần thiết cho đặc tả phần mềm và nội dung đó không mâu thuẫn với nguồn chính |

Mọi nội dung lấy từ `HIST-SPECS` phải gắn nhãn:

`[BỔ SUNG TỪ specs.docx — cần owner xác nhận nếu ảnh hưởng thiết kế/triển khai]`

Nếu `HIST-SPECS` mâu thuẫn với nguồn chính, ưu tiên nguồn chính và ghi conflict vào `09_CONFLICT_AND_OWNER_DECISIONS.md`.

## 5. Nguồn Không Được Dùng Trong Batch Này

Các nguồn sau không được dùng để tạo, sửa, phủ quyết hoặc suy luận requirement trong `docs/software-specs/`:

| Nguồn                                                                     | Lý do loại trừ                                                                                                |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `apps/`, `src/`, source code hiện tại, migration, EF model, seed hiện hữu | Owner yêu cầu không đọc source code; current implementation không phải source of truth cho batch tài liệu này |
| `AGENTS.md`                                                               | Có thể chứa quy tắc vận hành agent nhưng owner đã chốt không dựa vào `AGENTS.md` cho batch này                |
| `docs/ginsengfood_final_pack_md/`                                         | Không dùng theo owner directive mới                                                                           |
| `docs/ginsengfood_forms_operational_md_pack/`                             | Không dùng theo owner directive mới                                                                           |
| `docs/ginsengfood_sku_recipe_md_pack/`                                    | Không dùng theo owner directive mới                                                                           |
| `docs/v2-audit/`, `docs/v2-plan/`, `docs/v2-handoff/`, `docs/v2-smoke/`   | Artifact downstream/implementation, không phải nguồn chính cho bộ spec từ prompt gốc                          |
| `docs/seeds/`, seed SQL cũ, migration cleanup notes                       | Chỉ là evidence/implementation artifact, không dùng để tạo business rule trong batch này                      |

Nếu các nguồn bị loại trừ có nội dung khác với `docs-software/` hoặc `.tmp-docx-extract/`, không dùng để sửa spec. Nếu cần ghi nhận, chỉ ghi là conflict nguồn ở `09_CONFLICT_AND_OWNER_DECISIONS.md` theo thông tin owner cung cấp.

## 6. Thứ Tự Ưu Tiên Khi Xung Đột

Thứ tự ưu tiên chỉ áp dụng giữa các nguồn được phép dùng ở mục 2-4.

1. `OWNER-DIRECTIVE-2026-04-27-PART0` thắng về source policy cho batch này.
2. Quyết định owner/phê duyệt owner (`OWNER-*`) được dùng để đóng điểm còn thiếu hoặc conflict, nhưng nếu thay đổi hard lock nghiệp vụ thì phải ghi rõ impact trong `09_CONFLICT_AND_OWNER_DECISIONS.md`.
3. `OWNER-PROMPT-INITIAL` thắng về mục tiêu đầu ra, cấu trúc file, nguyên tắc G1 và loại trừ baseline nghiên cứu khỏi vận hành, yêu cầu module/API/UI/DB/workflow/testing/dev-handoff/AI-agent.
4. Hard locks trong `SRC-LOCK5`, `SRC-CHECKLIST`, `SRC-DEV-ORDER` thắng về go-live scope: G1, 20 SKU baseline, 4 recipe groups, ingredient master, snapshot, MISA boundary, public trace policy.
5. `SRC-FILE01` thắng về architecture, owner boundary, trace/recall, MISA boundary, route policy.
6. `SRC-FILE02` thắng về master data, SKU, ingredient, recipe governance nếu không mâu thuẫn với hard locks.
7. `SRC-RECIPE-NEW` thắng về G1 recipe, 20 SKU, quantities, 4 recipe sections/groups.
8. `SRC-FILE03` và `SRC-FORM-AUTO` thắng về operational forms, action/state, approval, print, audit chain.
9. `SRC-FILE04`, `SRC-FILE04-1`, `SRC-FILE05`, `SRC-REPO-CODE01-*`, `SRC-DEV-ORDER` dùng cho dev handoff, phase, route/API/code rules. Nếu lệch nhau, ghi conflict và ưu tiên tài liệu cụ thể hơn cho phạm vi đó.
10. `SRC-CLEAN-04` dùng để cross-check FILE01-FILE04; nếu khác bản file riêng, ghi conflict.
11. `SRC-RECIPE-APPENDIX` chỉ dùng làm lịch sử/cross-check, không được phủ quyết `SRC-RECIPE-NEW`.
12. `HIST-SPECS` chỉ dùng fallback khi nguồn chính thiếu và không mâu thuẫn.
13. Nếu vẫn chưa đủ thông tin, ghi `[CHƯA ĐỦ THÔNG TIN]` và `[OWNER DECISION NEEDED]`.

## 7. Hard Locks Không Được Phá Trong Bộ Spec

Các rule sau được khóa từ prompt gốc và các nguồn chính:

| Lock                            | Quy tắc                                                                                                                                                                                                                                                                             |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `LOCK-FORMULA-KIND-COEXISTENCE` | G1 PILOT_PERCENT_BASED là pilot operational baseline; G2 FIXED_QUANTITY_BATCH là production baseline; cả hai có thể coexist `ACTIVE_OPERATIONAL` cho cùng SKU; planner pick `formula_version` + `formula_kind` khi tạo PO. Active operational unique theo `(sku_id, formula_kind)`. |
| `LOCK-NO-RESEARCH-BASELINE-OPS` | G0 và mọi research/baseline token lịch sử khác không dùng trong seed, production order, material issue, costing, trace, recall, dev handoff hoặc workflow triển khai.                                                                                                               |
| `LOCK-FUTURE-VERSIONING`        | Thiết kế recipe phải hỗ trợ G2/G3/G4... với trạng thái, phê duyệt, ngày hiệu lực, audit, active version, snapshot, không rewrite lịch sử.                                                                                                                                           |
| `LOCK-20-SKU-BASELINE`          | 20 SKU là baseline go-live; không hard-code thành giới hạn vĩnh viễn nếu owner đã yêu cầu hệ thống mở rộng về sau.                                                                                                                                                                  |
| `LOCK-4-RECIPE-GROUPS`          | Recipe phải dùng 4 group: `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`.                                                                                                                                                                           |
| `LOCK-MISA-LAYER`               | MISA sync phải đi qua integration layer chung với mapping, retry, reconcile, audit; module nghiệp vụ không sync trực tiếp.                                                                                                                                                          |
| `LOCK-PUBLIC-TRACE-POLICY`      | Public trace không expose supplier nội bộ, nhân sự, costing, QC defect, loss, MISA/private data.                                                                                                                                                                                    |
| `LOCK-QC-RELEASE`               | `QC_PASS` không đồng nghĩa `RELEASED`; batch release là record/action riêng.                                                                                                                                                                                                        |
| `LOCK-INVENTORY-DECREMENT`      | Material Issue Execution là điểm decrement raw-material inventory thật sự.                                                                                                                                                                                                          |
| `LOCK-WAREHOUSE-RELEASED`       | Warehouse finished-goods receipt phải yêu cầu batch `RELEASED`.                                                                                                                                                                                                                     |

## 8. Quy Ước Citation

Mỗi requirement/rule trong các file khác nên cite theo mẫu:

```text
Source: SRC-FILE01 §<heading hoặc đoạn>
Source: SRC-RECIPE-NEW §<SKU/section>
Source: SRC-LOCK5 §<heading>
Source: HIST-SPECS §<heading> [BỔ SUNG TỪ specs.docx — cần owner xác nhận nếu ảnh hưởng thiết kế/triển khai]
Source: OWNER-DIRECTIVE-2026-04-27-PART0
```

Nếu không có source rõ:

- Dùng `[GIẢ ĐỊNH]` cho giả định phân tích.
- Dùng `[CHƯA ĐỦ THÔNG TIN]` khi thiếu dữ liệu.
- Dùng `[OWNER DECISION NEEDED]` khi cần owner chốt trước triển khai.

## 9. Nhãn Trạng Thái

| Nhãn                      | Ý nghĩa                                                                                       |
| ------------------------- | --------------------------------------------------------------------------------------------- |
| `[CANONICAL]`             | Nội dung lấy từ nguồn chính được phép dùng trong mục 3                                        |
| `[BỔ SUNG TỪ specs.docx]` | Nội dung lấy từ `HIST-SPECS`, cần owner xác nhận nếu ảnh hưởng thiết kế/triển khai            |
| `[CONFLICT]`              | Có mâu thuẫn giữa hai hoặc nhiều nguồn được phép dùng, hoặc mâu thuẫn nguồn đã được owner nêu |
| `[GIẢ ĐỊNH]`              | Suy luận chuyên môn để chuẩn hóa tài liệu, chưa phải business rule đã chốt                    |
| `[CHƯA ĐỦ THÔNG TIN]`     | Nguồn chưa cung cấp đủ chi tiết                                                               |
| `[OWNER DECISION NEEDED]` | Cần owner quyết định trước khi triển khai                                                     |
| `[EXCLUDED_SOURCE]`       | Nguồn bị loại trừ khỏi batch này theo mục 5                                                   |

## 10. Conflict Nguồn Hiện Tại Đã Được Ghi Nhận

Conflict source precedence đã được ghi vào `09_CONFLICT_AND_OWNER_DECISIONS.md`:

- `CONFLICT-SRC-00`: mâu thuẫn giữa chỉ đạo vận hành agent/canonical packs và owner directive mới cho batch `docs/software-specs/`.

Quyết định hiện hành cho batch này:

- Không dùng `AGENTS.md`.
- Không dùng `docs/ginsengfood_*`.
- Không đọc source code.
- Dùng `docs-software/`, `.tmp-docx-extract/`, prompt gốc, kiến thức chuyên môn, và owner approval.

## 11. Phạm Vi Ngoài Batch

Các việc sau nằm ngoài batch source-index này:

- Đối chiếu current code với spec.
- Route impact analysis dựa trên implementation.
- Migration/seed implementation.
- Build/test source code.
- Cleanup thư mục legacy generated.
- Hợp nhất với các Markdown pack ngoài phạm vi owner directive hiện tại.
