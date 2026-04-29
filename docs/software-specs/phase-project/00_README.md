# 00 - Phase Project README

## 1. Muc Dich

Thu muc `phase-project/` la lop dieu phoi trien khai tuan tu cho Owner/PM va AI coding agents.

No khong thay the `07_PHASE_PLAN.md`, `06_MODULE_MAP.md`, `dev-handoff/`, `testing/` hoac `ai-agent/`. Thay vao do, no gom cac artifact co the dung truc tiep de:

- copy/paste prompt theo dung thu tu cho AI agents;
- theo doi to-do list theo CODE01-CODE17;
- cap nhat ket qua agent da lam sau moi phase/gap;
- tao bao cao tien do ngan gon cho sep.

## 2. Active Files

| File | Muc dich |
| --- | --- |
| `01_PHASE_PROJECT_TODO.md` | Backlog/to-do list theo week, phase, module, dependency, done gate. |
| `02_AGENT_PROMPT_SEQUENCE.md` | Prompt copy-paste theo thu tu cho audit, plan, implement, validate, review va handoff. |
| `03_PROGRESS_REPORT.md` | File song de agent cap nhat ket qua, dung lam bao cao tien do. |
| `04_PROJECT_LIFECYCLE_PROMPTS/` | Bo prompt danh so tu tao du an den go-live va post-go-live operations. |
| `05_DETAILED_PHASE_PROMPTS/` | Prompt chi tiet theo CODE01-CODE17 de giao viec truc tiep cho DB/backend/API/FE/seed/QA/review agents. |

## 3. Thu Tu Prompt Tuan Tu Tu Zero

Neu bat dau tu repo rong/greenfield, chay prompt theo dung thu tu nay:

| Step | Prompt/file | Muc dich | Ket qua can co truoc khi sang buoc tiep |
| --- | --- | --- | --- |
| 00 | `00_README.md` | Hieu bo dieu phoi phase-project. | Nam duoc source discipline va done rule. |
| 01 | `04_PROJECT_LIFECYCLE_PROMPTS/00_README.md` | Hieu vong doi prompt tu project inception den go-live. | Biet dung bo lifecycle prompt. |
| 02 | `04_PROJECT_LIFECYCLE_PROMPTS/01_PROJECT_INITIATION_PROMPTS.md` | Chot scope, success criteria, quyết định owner, governance. | Project charter/decision tracker ro rang. |
| 03 | `04_PROJECT_LIFECYCLE_PROMPTS/02_REPO_AND_LOCAL_ENV_PROMPTS.md` | Scaffold repo/local env/secrets/branch strategy. | Repo scaffold va local env baseline san sang. |
| 04 | `04_PROJECT_LIFECYCLE_PROMPTS/03_ARCHITECTURE_FOUNDATION_PROMPTS.md` | Khoa architecture, coding conventions, module skeleton, ADR. | Architecture foundation duoc chap nhan. |
| 05 | `02_AGENT_PROMPT_SEQUENCE.md` - Prompt 00 | Bootstrap implementation queue. | First bounded gap duoc chon va progress report cap nhat. |
| 06 | `05_DETAILED_PHASE_PROMPTS/00_README.md` | Hieu cach dung prompt chi tiet. | San sang chay CODE/MX prompts. |
| 07 | `05_DETAILED_PHASE_PROMPTS/01_CODE01_FOUNDATION_SOURCE_ORIGIN_PROMPTS.md` | CODE01 Foundation + Source Origin. | CODE01 done gate hoac blocker ro rang. |
| 08 | `05_DETAILED_PHASE_PROMPTS/02_CODE02_RAW_MATERIAL_PROMPTS.md` | CODE02 Raw Material Intake + Lot + Incoming QC. | CODE02 done gate hoac blocker ro rang. |
| 09 | `05_DETAILED_PHASE_PROMPTS/03_MX_GATE_G1_MASTER_DATA_RECIPE_PROMPTS.md` | MX-GATE-G1 truoc CODE03. | G1/SKU/ingredient/recipe readiness pass. |
| 10 | `05_DETAILED_PHASE_PROMPTS/04_CODE03_PRODUCTION_MATERIAL_BATCH_PROMPTS.md` | CODE03 Manufacturing + Material + Batch. | CODE03 done gate hoac blocker ro rang. |
| 11 | `05_DETAILED_PHASE_PROMPTS/05_CODE04_PACKAGING_QR_PRINT_PROMPTS.md` | CODE04 Packaging + QR + Print. | CODE04 done gate hoac blocker ro rang. |
| 12 | `05_DETAILED_PHASE_PROMPTS/06_CODE05_QC_RELEASE_PROMPTS.md` | CODE05 QC + Batch Release. | CODE05 done gate hoac blocker ro rang. |
| 13 | `05_DETAILED_PHASE_PROMPTS/07_CODE06_WAREHOUSE_INVENTORY_PROMPTS.md` | CODE06 Warehouse + Inventory. | CODE06 done gate hoac blocker ro rang. |
| 14 | `05_DETAILED_PHASE_PROMPTS/08_CODE07_TRACEABILITY_PROMPTS.md` | CODE07 Traceability. | CODE07 done gate hoac OD defer ro rang. |
| 15 | `05_DETAILED_PHASE_PROMPTS/09_CODE08_RECALL_PROMPTS.md` | CODE08 Recall + Recovery. | CODE08 done gate hoac blocker ro rang. |
| 16 | `05_DETAILED_PHASE_PROMPTS/10_CODE09_ADMIN_UI_RBAC_PROMPTS.md` | CODE09 Admin UI/RBAC registry. | Permission-aware UI/backend gate evidence. |
| 17 | `05_DETAILED_PHASE_PROMPTS/11_CODE10_API_CONTRACT_PROMPTS.md` | CODE10 API contract/middleware. | API convention and FE sync gate pass. |
| 18 | `05_DETAILED_PHASE_PROMPTS/12_CODE11_PWA_OFFLINE_PROMPTS.md` | CODE11 PWA/offline contract. | Offline/idempotency gate pass. |
| 19 | `05_DETAILED_PHASE_PROMPTS/13_CODE12_DEVICE_PRINTER_PROMPTS.md` | CODE12 Device/printer boundary. | No direct DB/device bypass; OD-17 handled. |
| 20 | `05_DETAILED_PHASE_PROMPTS/14_CODE13_EVENT_OUTBOX_MISA_PROMPTS.md` | CODE13 Event/outbox/MISA adapter. | Retry/reconcile/no direct MISA sync pass. |
| 21 | `05_DETAILED_PHASE_PROMPTS/15_CODE14_MONITORING_DASHBOARD_PROMPTS.md` | CODE14 Monitoring/dashboard. | Critical alert/dashboard gate pass. |
| 22 | `05_DETAILED_PHASE_PROMPTS/16_CODE15_OVERRIDE_GOVERNANCE_PROMPTS.md` | CODE15 Override governance. | Override audit/security gate pass. |
| 23 | `05_DETAILED_PHASE_PROMPTS/17_CODE16_RETENTION_ARCHIVE_RESTORE_PROMPTS.md` | CODE16 Retention/archive/restore. | OD-12/OD-13 closed or formally deferred. |
| 24 | `05_DETAILED_PHASE_PROMPTS/18_CODE17_FINAL_CLOSEOUT_PROMPTS.md` | CODE17 final close-out. | Final smoke/release handoff ready. |
| 25 | `04_PROJECT_LIFECYCLE_PROMPTS/06_QA_UAT_ACCEPTANCE_PROMPTS.md` | UAT/acceptance/bug triage. | UAT verdict and fix queue. |
| 26 | `04_PROJECT_LIFECYCLE_PROMPTS/07_CICD_DEPLOYMENT_PROMPTS.md` | CI/CD, staging, release candidate. | Release candidate and rollback plan. |
| 27 | `04_PROJECT_LIFECYCLE_PROMPTS/08_PRODUCTION_READINESS_GO_LIVE_PROMPTS.md` | Production readiness/go-live. | Go/no-go evidence pack. |
| 28 | `04_PROJECT_LIFECYCLE_PROMPTS/09_POST_GO_LIVE_OPERATIONS_PROMPTS.md` | Hypercare/post-go-live. | Day-1/hypercare operating loop. |
| 29 | `04_PROJECT_LIFECYCLE_PROMPTS/10_MANAGEMENT_REPORTING_PROMPTS.md` | Management report. | Bao cao sep/owner. |

`04_PROJECT_LIFECYCLE_PROMPTS/04_IMPLEMENTATION_PHASE_PROMPTS.md` va `05_DATA_MIGRATION_SEED_PROMPTS.md` la prompt ho tro dung lap lai trong cac buoc CODE/MX khi can kickoff phase hoac lam DB/seed, khong phai buoc rieng tach khoi CODE sequence.

## 4. Thu Tu Su Dung Nhanh

1. Doc `01_PHASE_PROJECT_TODO.md` de chon phase/gap tiep theo.
2. Copy prompt tu `02_AGENT_PROMPT_SEQUENCE.md` theo dung thu tu.
3. Sau khi agent hoan thanh, bat agent cap nhat `03_PROGRESS_REPORT.md`.
4. Neu phase phat sinh blocker, cap nhat `09_CONFLICT_AND_OWNER_DECISIONS.md` hoac phan `Owner Decision Tracker` trong `03_PROGRESS_REPORT.md`.
5. Chi chuyen phase khi done gate cua phase truoc da co evidence hoac duoc owner chap nhan defer.

Neu bat dau tu zero hoac can dua den production:

1. Doc `04_PROJECT_LIFECYCLE_PROMPTS/00_README.md`.
2. Chay lifecycle prompt `01_...`, `02_...`, `03_...` truoc.
3. Chay `02_AGENT_PROMPT_SEQUENCE.md` Prompt 00 de bootstrap queue.
4. Dung `05_DETAILED_PHASE_PROMPTS/` theo thu tu `01_CODE01` -> `02_CODE02` -> `03_MX_GATE_G1` -> `04_CODE03` -> ... -> `18_CODE17`.
5. Trong tung CODE/MX phase, dung them lifecycle prompt `04_...` va `05_...` khi can kickoff implementation hoac DB/seed.
6. Sau CODE17, dung lifecycle prompt `06_...` den `10_...` cho UAT, CI/CD, go-live, post-go-live va management reporting.

## 5. Source Discipline

Khi dung prompt trong thu muc nay:

- `docs/software-specs/` la source-of-truth cho requirement.
- Neu repo/app chua scaffold, layer vang mat duoc ghi la `NOT_SCAFFOLDED` hoac `N/A - not scaffolded yet`.
- Current code, khi da ton tai, chi duoc dung lam implementation baseline/gap evidence.
- `AGENTS.md` la operating rule cua repo, khong phai requirement source.
- Khong dung `.tmp-docx-extract/` de override spec da repair trong `docs/software-specs/`.
- Khong tao route/table/enum/business truth song song neu chua co impact analysis.

## 6. Agent Done Rule

Moi agent run phai ket thuc bang:

- file đã sửa;
- requirement source;
- evidence used;
- lệnh đã chạy;
- build/test/migration/seed/smoke result hoac blocker;
- process cleanup result;
- cập nhật tiến độ vao `03_PROGRESS_REPORT.md`;
- rủi ro còn lại va next recommended action.
