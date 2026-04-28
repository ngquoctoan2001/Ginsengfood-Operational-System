# 10 - Consistency QA Pass

> Mục đích: ghi lại kết quả rà chéo cuối cho bộ `docs/software-specs/` sau khi bổ sung Part 0-10. File này không thay thế các spec chi tiết; nó là checklist bằng chứng để owner/PM/BA/SA biết phần nào đã nhất quán và phần nào còn cần quyết định.

## 1. Phạm Vi Rà Soát

| Hạng mục | Phạm vi |
|---|---|
| Active docs | Top-level files và thư mục chuẩn: `business/`, `functional/`, `non-functional/`, `architecture/`, `database/`, `api/`, `ui/`, `workflows/`, `modules/`, `diagrams/`, `testing/`, `dev-handoff/`, `data/`, `ai-agent/`, `phase-project/` |
| Review artifacts | `problems/` chứa problem notes/readiness analysis; không phải requirement source chính. |
| Legacy docs | Mapping lịch sử từ thư mục đánh số `1. business/` đến `13. ai-agent/` được giữ trong `00_LEGACY_FILE_MAPPING.md`; các thư mục đánh số không còn là active docs trong cây hiện tại. |
| Source policy | Không dùng source code làm source-of-truth; không dùng `AGENTS.md`; không dùng `docs/ginsengfood_*`; tuân thủ `01_SOURCE_INDEX.md`. Implementation prompts có thể đọc code sau này chỉ để audit gap/baseline. |

## 2. Kết Quả Checklist

| Checklist | Kết quả | Evidence |
|---|---|---|
| Cây thư mục chuẩn tồn tại đủ | PASS | 15 thư mục chuẩn đã có đủ file yêu cầu; `phase-project/` đã có lifecycle và detailed prompt packs. |
| Tất cả file active có tiêu đề rõ | PASS | `active_file_count=166`, `active_missing_title_count=0`; `phase_project_md_count=34`. |
| File dài có mục lục | PASS | `active_long_files_without_toc_count=0`; đã bổ sung TOC cho ERD, state machines, API request/response, UI client contract, use case catalog, sequence diagrams, conflict report. |
| Không còn forbidden research baseline token trong operational docs active | PASS | `active_operational_forbidden_baseline_match_count=0`. Các match literal còn lại chỉ nằm trong `testing/` negative validation và `03_GLOSSARY.md`/`09_CONFLICT...` historical/conflict context. |
| Recipe dùng đúng 4 group | PASS | `recipe_group_missing_in_enum_count=0`, `legacy_two_group_phrase_count=0`. |
| 20 SKU là baseline go-live, không hard-code vĩnh viễn | PASS | RTM, business rules, database spec, test matrix và dev handoff đều ghi 20 SKU là baseline và API/schema phải hỗ trợ mở rộng. |
| RTM map sang business rule, DB, API, UI, workflow, test | PASS | RTM có đủ 14 cột prompt; `rtm_requirement_row_ids=68`; test matrix reverse mapping phủ đủ 68 requirement. |
| API endpoint catalog và UI screen catalog khớp route family | PASS | `ui_routes_without_api_family_count=0`; đã bổ sung missing API rows cho genealogy, public preview, MISA mappings/reconcile, users và PWA task inbox. |
| Database table spec và ERD khớp nhau | PASS | `db_tables_missing_in_erd_count=0`, `db_tables_extra_in_erd_count=0`; ERD và table spec cùng 102 bảng/view/projection. |
| Workflow state machines khớp module/database anchors | PASS | Đủ 13 lifecycle prompt yêu cầu; `state_anchor_missing_count=0` sau khi bổ sung `Enum/Table Anchor Map`. |
| Test case matrix khớp RTM | PASS | `rtm_ids_not_in_test_matrix_count=0`; section `testing/02_TEST_CASE_MATRIX.md#4-rtm-reverse-mapping` sinh từ RTM. |
| Owner decisions mở gom rõ | PASS WITH OPEN ITEMS | `09_CONFLICT_AND_OWNER_DECISIONS.md` C.2 đã bổ sung OD-20, OD-21, OD-22 và giữ OD-11/12/13/14/17. |

## 3. Chỉnh Sửa Đã Thực Hiện Trong Part 11

| File/nhóm file | Nội dung chỉnh |
|---|---|
| `business/`, `functional/`, `non-functional/`, `architecture/`, `database/`, `api/`, `ui/`, `workflows/`, `modules/`, `diagrams/`, `testing/`, `dev-handoff/`, `data/`, `ai-agent/`, `phase-project/` | Tạo/mirror lại cây thư mục chuẩn từ legacy/generated folders; legacy path chỉ còn là historical mapping, không còn active docs. |
| `00_README.md`, `02_EXECUTIVE_SUMMARY.md` | Sửa lại bảng Markdown bị hỏng và diễn đạt hard lock theo `G1-only operational baseline`. |
| `business/*`, `functional/*`, `architecture/*`, `database/*` | Loại bỏ cách ghi trực tiếp forbidden research baseline token khỏi operational docs active; thay bằng `research/baseline token lịch sử`. |
| `database/02_ERD.md` | Bổ sung các view/projection thiếu để khớp `database/03_TABLE_SPECIFICATION.md`. |
| `api/02_API_ENDPOINT_CATALOG.md` | Bổ sung endpoint rows cho UI contract: `GET /api/admin/users`, trace genealogy/public preview, MISA mappings/reconcile, `GET /api/admin/tasks/my`. |
| `ui/03_SCREEN_CATALOG.md` | Chuẩn hóa `data source API` theo route family trong API catalog. |
| `workflows/04_STATE_MACHINES.md` | Bổ sung `Enum/Table Anchor Map` cho state machine vs module/database/test. |
| `testing/02_TEST_CASE_MATRIX.md` | Làm lại `RTM Reverse Mapping` từ RTM để phủ đủ requirement. |
| `09_CONFLICT_AND_OWNER_DECISIONS.md` | Bổ sung owner decisions mở về MISA production credential, PWA task taxonomy và endpoint mutation taxonomy. |
| `phase-project/` | Bổ sung lifecycle prompts, detailed phase prompts và progress report để điều phối từ project inception đến go-live/post-go-live. |
| `00_README.md`, `01_SOURCE_INDEX.md`, `05_SCOPE_AND_BOUNDARY.md` | Làm rõ source code không phải requirement source, nhưng implementation prompts có thể đọc code làm baseline/gap evidence. |

## 4. Owner Decisions Còn Mở

| ID | Nội dung | Impact |
|---|---|---|
| OD-11 | Trace query SLA technical: latency/volume/depth/cache target. | Trace index/cache/materialized view/performance test. |
| OD-12 | Backup/DR RPO/RTO. | CODE16 backup/restore/runbook/release readiness. |
| OD-13 | Audit/log/ledger/trace/recall retention duration. | Retention/archive/storage sizing. |
| OD-14 | Public trace multi-language policy. | Public trace API/UI/i18n schema. |
| OD-17 | Production printer model + driver. | CODE12 printer adapter/callback/label format. |
| OD-20 | MISA AMIS tenant/credential/endpoint thật cho production. | Real sync enablement; dev giữ dry-run/fake credential. |
| OD-21 | PWA task taxonomy và endpoint inbox `/api/admin/tasks/my`. | CODE11 shopfloor PWA task routing. |
| OD-22 | UI mutation route taxonomy phụ. | UOM write, raw lot hold/release, process command, screen registry write. |

## 5. Residual Risks

| Risk | Mức độ | Ghi chú |
|---|---|---|
| Historical legacy mapping còn giữ | LOW | Không còn là active docs; giữ `00_LEGACY_FILE_MAPPING.md` để trace nguồn chuyển đổi. Owner có thể duyệt cleanup/deprecation note sau. |
| Một số endpoint bổ sung là target contract, chưa đối chiếu implementation | HIGH nếu đem implement ngay | Batch này không đọc source code theo owner directive; implementation phase sau phải route impact analysis. |
| Owner decisions NFR còn mở | HIGH | RPO/RTO, retention, trace SLA ảnh hưởng production readiness. |
| MISA/printer thông số thật chưa có | MEDIUM/HIGH | Dev có thể làm adapter/dry-run, chưa bật production sync/print thật. |

## 6. Done Gate Part 11

- PASS: tree chuẩn đủ file.
- PASS: title/TOC/G1-only wording/API-UI/DB-ERD/workflow/test cross-map đã rà và sửa.
- PASS: open owner decisions được gom trong `09_CONFLICT_AND_OWNER_DECISIONS.md`.
- PASS: `phase-project/` đã được bổ sung vào scope consistency với 34 Markdown files và prompt pack chi tiết.
- NEXT: owner duyệt OD-11/12/13/14/17/20/21/22 và quyết định có giữ/ẩn `00_LEGACY_FILE_MAPPING.md` cùng `problems/` trong bản handoff cuối.
