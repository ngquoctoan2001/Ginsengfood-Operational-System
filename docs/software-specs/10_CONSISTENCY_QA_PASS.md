# 10 - Consistency QA Pass

> Mục đích: ghi lại kết quả rà chéo cuối cho bộ `docs/software-specs/`. File này không thay thế các spec chi tiết; nó là checklist bằng chứng để owner/PM/BA/SA biết phần nào đã nhất quán, phần nào còn cần quyết định, và phần nào đã đủ điều kiện production freeze.

## 1. Phạm Vi Rà Soát

| Hạng mục | Phạm vi |
| --- | --- |
| Active docs | Top-level files và thư mục chuẩn: `business/`, `functional/`, `non-functional/`, `architecture/`, `database/`, `api/`, `ui/`, `workflows/`, `modules/`, `diagrams/`, `testing/`, `dev-handoff/`, `data/`, `ai-agent/`, `phase-project/` |
| Review artifacts | `problems/` chứa problem notes/readiness analysis; không phải requirement source chính. |
| Legacy docs | Mapping lịch sử từ thư mục đánh số `1. business/` đến `13. ai-agent/` được giữ trong `00_LEGACY_FILE_MAPPING.md`; các thư mục đánh số không còn là active docs trong cây hiện tại. |
| Source policy | Không dùng source code làm source-of-truth; không dùng `AGENTS.md`; không dùng `docs/ginsengfood_*`; tuân thủ `01_SOURCE_INDEX.md`. Implementation prompts có thể đọc code sau này chỉ để audit gap/baseline. |

## 2. Kết Quả Checklist

| Checklist | Kết quả | Evidence |
| --- | --- | --- |
| Cây thư mục chuẩn tồn tại đủ | PASS | 15 thư mục chuẩn đã có đủ file yêu cầu; `phase-project/` đã có lifecycle và detailed prompt packs. |
| Tất cả file active có tiêu đề rõ | PASS | `active_file_count=168`, `active_missing_title_count=0`; `phase_project_md_count=35`. |
| File dài có mục lục | PASS | `active_long_files_without_toc_count=0`; đã bổ sung TOC cho ERD, state machines, API request/response, UI client contract, use case catalog, sequence diagrams, conflict report. |
| Không còn forbidden research baseline token trong operational docs active | PASS | `active_operational_forbidden_baseline_match_count=0`. Các match literal còn lại chỉ nằm trong `testing/` negative validation và `03_GLOSSARY.md`/`09_CONFLICT...` historical/conflict context. |
| Recipe dùng đúng 4 group | PASS | `recipe_group_missing_in_enum_count=0`, `legacy_two_group_phrase_count=0`. |
| 20 SKU là baseline go-live, không hard-code vĩnh viễn | PASS | RTM, business rules, database spec, test matrix và dev handoff đều ghi 20 SKU là baseline và API/schema phải hỗ trợ mở rộng. |
| RTM map sang business rule, DB, API, UI, workflow, test | PASS | RTM có đủ 14 cột prompt; `rtm_requirement_row_ids=68`; test matrix reverse mapping phủ đủ 68 requirement. |
| API endpoint catalog và UI screen catalog khớp route family | PASS | `ui_routes_without_api_family_count=0`; đã bổ sung missing API rows cho genealogy, public preview, MISA mappings/reconcile, users và PWA task inbox. |
| Database table spec và ERD khớp nhau | PASS | `db_tables_missing_in_erd_count=0`, `db_tables_extra_in_erd_count=0`; ERD và table spec cùng 102 bảng/view/projection. |
| Workflow state machines khớp module/database anchors | PASS | Đủ 13 lifecycle prompt yêu cầu; `state_anchor_missing_count=0` sau khi bổ sung `Enum/Table Anchor Map`. |
| Test case matrix khớp RTM | PASS | `rtm_ids_not_in_test_matrix_count=0`; section `testing/02_TEST_CASE_MATRIX.md#4-rtm-reverse-mapping` sinh từ RTM. |
| Owner decisions mở gom rõ | PASS WITH PRODUCTION FREEZE | PF-01 2026-05-03: `09_CONFLICT_AND_OWNER_DECISIONS.md` C.8 đã chuyển toàn bộ OD còn lại sang `RESOLVED_FINAL` hoặc `DEFERRED_WITH_ACCEPTED_RISK`; 3 OD business critical (`OD-EVIDENCE-STORAGE-001`, `OD-NOTIFY-OWNERSHIP-001`, `OD-PACKET-TRACE-001`) đã owner FINAL. |
| PF-00 spec hygiene parser/readiness | PASS | 2026-05-03: Markdown table pipe-count validation pass trên `168` file `.md`; không còn mojibake token; không còn wording G1-only baseline, per-SKU active recipe cũ, hoặc tên DTO public trace cũ. |
| PF-02 production data/config closure | PASS | 2026-05-03: GTIN/GS1, MISA AMIS, printer/device, evidence storage, notification, backup/DR, retention/archive, production users/roles đã có production owner/config/secret refs; dev/test fixture vẫn giữ nhưng gắn `DEV_TEST_ONLY`; literal secret scan pass; `seed_manifest.json` JSON pass; Markdown table pipe-count validation pass trên `177` file `.md` trong `docs/software-specs/` và `docs/v2-decisions/`. |

## 3. Chỉnh Sửa Đã Thực Hiện Trong Part 11

| File/nhóm file | Nội dung chỉnh |
| --- | --- |
| `business/`, `functional/`, `non-functional/`, `architecture/`, `database/`, `api/`, `ui/`, `workflows/`, `modules/`, `diagrams/`, `testing/`, `dev-handoff/`, `data/`, `ai-agent/`, `phase-project/` | Tạo/mirror lại cây thư mục chuẩn từ legacy/generated folders; legacy path chỉ còn là historical mapping, không còn active docs. |
| `00_README.md`, `02_EXECUTIVE_SUMMARY.md` | Sửa bảng Markdown bị hỏng và diễn đạt hard lock theo formula-kind baseline (`G1` PILOT, `G2` FIXED coexist theo `(sku_id, formula_kind)`). |
| `business/*`, `functional/*`, `architecture/*`, `database/*` | Loại bỏ cách ghi trực tiếp forbidden research baseline token khỏi operational docs active; thay bằng `research/baseline token lịch sử`. |
| `database/02_ERD.md` | Bổ sung các view/projection thiếu để khớp `database/03_TABLE_SPECIFICATION.md`. |
| `api/02_API_ENDPOINT_CATALOG.md` | Bổ sung endpoint rows cho UI contract: `GET /api/admin/users`, trace genealogy/public preview, MISA mappings/reconcile, `GET /api/admin/tasks/my`. |
| `ui/03_SCREEN_CATALOG.md` | Chuẩn hóa `data source API` theo route family trong API catalog. |
| `workflows/04_STATE_MACHINES.md` | Bổ sung `Enum/Table Anchor Map` cho state machine vs module/database/test. |
| `testing/02_TEST_CASE_MATRIX.md` | Làm lại `RTM Reverse Mapping` từ RTM để phủ đủ requirement. |
| `09_CONFLICT_AND_OWNER_DECISIONS.md` | Bổ sung owner decisions mở về MISA production credential, PWA task taxonomy và endpoint mutation taxonomy. |
| `phase-project/` | Bổ sung lifecycle prompts, detailed phase prompts và progress report để điều phối từ project inception đến go-live/post-go-live. |
| `00_README.md`, `01_SOURCE_INDEX.md`, `05_SCOPE_AND_BOUNDARY.md` | Làm rõ source code không phải requirement source, nhưng implementation prompts có thể đọc code làm baseline/gap evidence. |
| `workflows/05_CANONICAL_OPERATIONAL_FLOW.md`, `ui/03_SCREEN_CATALOG.md`, `modules/04_SKU_INGREDIENT_RECIPE.md`, `functional/02_USE_CASE_CATALOG.md`, `functional/01_MODULE_FUNCTION_MATRIX.md`, `07_PHASE_PLAN.md`, `workflows/04_STATE_MACHINES.md` | PF-00 final hygiene: sửa bảng Markdown vỡ do route/action có ký tự pipe, sửa mojibake function matrix, đổi wording stale sang coexistence model `(sku_id, formula_kind)`. |
| `data/`, `database/`, `modules/05_SOURCE_ORIGIN.md`, `modules/06_RAW_MATERIAL.md`, `modules/10_PACKAGING_PRINTING.md`, `modules/13_RECALL.md`, `modules/14_MISA_INTEGRATION.md`, `architecture/04_INTEGRATION_ARCHITECTURE.md`, `architecture/05_EVENT_ARCHITECTURE.md`, `architecture/07_DEPLOYMENT_VIEW.md`, `non-functional/03_SECURITY_REQUIREMENTS.md`, `non-functional/05_BACKUP_RETENTION_REQUIREMENTS.md`, `dev-handoff/`, `.claude/rules/web/deployment.md` | PF-02 production data/config closure: tách fixture `DEV_TEST_ONLY`, thêm production config/secret/device refs, đóng boundary notification outbox, evidence storage, MISA dry-run/production, printer callback auth, backup/DR, retention/archive và production role assignment. |

## 4. Owner Decisions Đã Production Freeze

PF-02 đã chuyển OD-17/OD-20 từ accepted risk sang config/secret/device-ref closure: code adapter/dry-run vẫn được scaffold, production real mode bật bằng refs có owner và không commit secret/credential thật.

| ID | Trạng thái | Impact |
| --- | --- | --- |
| OD-11 | RESOLVED_FINAL | Trace SLA production target accepted. |
| OD-12 | RESOLVED_FINAL | Backup/DR RPO/RTO accepted. |
| OD-13 | RESOLVED_FINAL | Retention policy accepted. |
| OD-14 | RESOLVED_FINAL | Public trace `vi` MVP + i18n-ready accepted. |
| OD-17 | RESOLVED_FINAL_PF02_WITH_DEVICE_REFS | HTTP/ZPL-compatible adapter + HMAC callback; model/IP/driver in device registry/config refs. |
| OD-20 | RESOLVED_FINAL_PF02_WITH_SECRET_REFS | MISA `DryRun`/`Production` mode; tenant/endpoint/credential through config/secret refs. |
| OD-21 | RESOLVED_FINAL | PWA task taxonomy accepted. |
| OD-22 | RESOLVED_FINAL | UI mutation route taxonomy accepted. |

**Batch 2 (2026-05-03)** - `CONFLICT-18`, `OD-M03-OWNERSHIP-001`, 15 OD Batch 2 và 3 OD Group A đã có sign-off. Group A final: evidence production lưu server công ty + dev/test local FS; Operational notification outbox-only, delivery do hệ thống bán hàng; PACKET không QR, trace qua BOX/CARTON. Bảng chi tiết tại [`docs/v2-decisions/OD-DEFAULTS-2026-05-03.md`](../v2-decisions/OD-DEFAULTS-2026-05-03.md), [`docs/v2-decisions/OD-DEFAULTS-BATCH2-2026-05-03.md`](../v2-decisions/OD-DEFAULTS-BATCH2-2026-05-03.md) và [09_CONFLICT_AND_OWNER_DECISIONS.md §C.8](09_CONFLICT_AND_OWNER_DECISIONS.md).

## 5. PF-02 Production Freeze Areas

| Area | Trạng thái | Coding contract |
| --- | --- | --- |
| GTIN/GS1 | READY_FOR_PRODUCTION_FREEZE | Dev/test dùng fixture `DEV_TEST_ONLY`; production import GTIN thật với `is_test_fixture=false`; PACKET không có QR/trace standalone. |
| MISA AMIS | READY_FOR_PRODUCTION_FREEZE_WITH_SECRET_REFS | `DryRun` mặc định cho dev/test; production dùng `MisaSyncOptions` + secret refs, không commit tenant/credential thật. |
| Printer/device | READY_FOR_PRODUCTION_FREEZE_WITH_DEVICE_REFS | Adapter HTTP/ZPL-compatible; callback dùng HMAC-SHA256; model/IP/driver nằm trong device registry/config refs. |
| Evidence storage | READY_FOR_PRODUCTION_FREEZE_WITH_STORAGE_REFS | Dev/test local FS; production company storage server/object storage ref; object key format và scan flow đã đóng. |
| Notification | READY_FOR_PRODUCTION_FREEZE | Operational tạo outbox/job và đo SLA tại durable enqueue; delivery do hệ thống bán hàng. |
| Backup/DR | READY_FOR_PRODUCTION_FREEZE_WITH_RUNBOOK_REFS | PostgreSQL RPO 15m/RTO 4h; evidence RPO 1h/RTO 8h; audit/outbox RPO 5m/RTO 2h; restore drill trước go-live và hàng quý. |
| Retention/archive | READY_FOR_PRODUCTION_FREEZE | Operational/audit/trace 7 năm; recall/CAPA 10 năm; MISA sync 5 năm; outbox active 90 ngày rồi archive. |
| Production users/roles | READY_FOR_PRODUCTION_FREEZE | Action permission seed không đổi; user assignment thật là environment data có owner, không hard-code trong repo. |

## 6. Residual Risks

| Risk | Mức độ | Ghi chú |
| --- | --- | --- |
| Historical legacy mapping còn giữ | LOW | Không còn là active docs; giữ `00_LEGACY_FILE_MAPPING.md` để trace nguồn chuyển đổi. Owner có thể duyệt cleanup/deprecation note sau. |
| Một số endpoint bổ sung là target contract, chưa đối chiếu implementation | HIGH nếu đem implement ngay | Batch này đóng spec/config; implementation phase sau phải route impact analysis khi scaffold code. |
| Thông số thật của MISA/printer/storage chưa có trong repo | RESOLVED_BY_CONFIG_REFS | PF-02 đã đóng bằng config/secret/device/storage refs có owner; không commit secret/credential/IP thật. |

## 7. Done Gate Part 11

- PASS: tree chuẩn đủ file.
- PASS: title/TOC/formula-kind wording/API-UI/DB-ERD/workflow/test cross-map đã rà và sửa.
- PASS: PF-00 spec hygiene final pass - Markdown table validation pass trên 168 file, không còn mojibake token, không còn wording G1-only baseline, per-SKU active recipe cũ, hoặc tên DTO public trace cũ.
- PASS: open owner decisions được gom trong `09_CONFLICT_AND_OWNER_DECISIONS.md`.
- PASS: `phase-project/` đã được bổ sung vào scope consistency với 34 Markdown files và prompt pack chi tiết.
- PASS: PF-01 owner decision finalization hoàn tất; `09_CONFLICT_AND_OWNER_DECISIONS.md`, `OD-DEFAULTS-2026-05-03.md`, `OD-DEFAULTS-BATCH2-2026-05-03.md`, `02_EXECUTIVE_SUMMARY.md` đã bỏ trạng thái chờ owner cho các OD đã chốt.
- PASS: PF-02 production data/config closure hoàn tất; production-required values dùng owner refs, dev/test fixture gắn `DEV_TEST_ONLY`, literal secret scan pass, Markdown table validation pass trên 177 file.
- NEXT: khi bắt đầu CODE12/CODE13/CODE17, validate refs cho printer/MISA/evidence/backup trước khi bật production mode.
- NEXT: quyết định có giữ/ẩn `00_LEGACY_FILE_MAPPING.md` cùng `problems/` trong bản handoff cuối.
