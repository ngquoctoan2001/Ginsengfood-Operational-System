# Dev Handoff README

## 1. Mục đích

Thư mục này chứa handoff active cho triển khai theo `docs/software-specs/`: phase, module, backend, frontend, database, seed, API contract, done gate và release/rollback.

## 2. Active Files

| File | Purpose |
|---|---|
| `01_DEVELOPMENT_GUIDE.md` | Quy trình triển khai theo phase/gap |
| `02_BACKEND_IMPLEMENTATION_GUIDE.md` | Backend/domain/API/service rules |
| `03_FRONTEND_IMPLEMENTATION_GUIDE.md` | Frontend/admin UI/API client handoff |
| `04_DATABASE_IMPLEMENTATION_GUIDE.md` | Migration/schema/constraint handoff |
| `05_SEED_IMPLEMENTATION_GUIDE.md` | Seed order and validation |
| `06_API_CONTRACT_HANDOFF.md` | Backend/frontend API sync |
| `07_MODULE_TASK_BREAKDOWN.md` | Task breakdown by CODE/M module |
| `08_DONE_GATE_CHECKLIST.md` | Build/test/migration/seed/smoke/handoff gates |
| `09_RELEASE_ROLLBACK_GUIDE.md` | Release, rollback, restore, hotfix |

## 3. Source Discipline

- Chỉ dùng prompt gốc, `docs-software/`, `.tmp-docx-extract/`, `docs/software-specs/`, kiến thức chuyên môn có đánh dấu và owner approval.
- Không dùng source code, current database, `AGENTS.md`, hoặc `docs/ginsengfood_*` làm source-of-truth cho handoff này.
- Thư mục `12. dev-handoff/` là legacy/generated path, không phải path chuẩn của prompt gốc.
- Khi API/database/UI spec thêm hard gate mới như raw lot readiness `RAW_LOT_MARK_READY` / `READY_FOR_PRODUCTION`, dev-handoff phải được đồng bộ trong backend, frontend, database, API contract, task breakdown và done gate trước khi giao phase cho dev.
