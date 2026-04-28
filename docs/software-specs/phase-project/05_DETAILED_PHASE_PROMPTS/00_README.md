# 00 - Detailed Phase Prompts README

## 1. Muc Dich

Thu muc `05_DETAILED_PHASE_PROMPTS/` la lop prompt chi tiet de giao viec truc tiep cho AI coding agents theo tung `CODE01-CODE17`.

Khac voi `../02_AGENT_PROMPT_SEQUENCE.md` chi la khung phase-level, moi file o day chia phase thanh cac bounded gap/action prompt:

- kickoff audit;
- implementation plan;
- database/schema;
- backend/service;
- API/DTO/permission/idempotency;
- frontend/UI;
- seed/data;
- tests/smoke;
- review;
- validation;
- handoff/progress.

## 2. Thu Tu Doc

Thu tu nay phu hop dependency trong `docs/software-specs/07_PHASE_PLAN.md`: `CODE01 -> CODE02 -> MX-GATE-G1 -> CODE03 -> ... -> CODE17`.

| Thu tu | File | Phase |
| --- | --- | --- |
| 00 | `00_README.md` | Huong dan dung detailed prompt pack |
| 01 | `01_CODE01_FOUNDATION_SOURCE_ORIGIN_PROMPTS.md` | CODE01 |
| 02 | `02_CODE02_RAW_MATERIAL_PROMPTS.md` | CODE02 |
| 03 | `03_MX_GATE_G1_MASTER_DATA_RECIPE_PROMPTS.md` | MX-GATE-G1 |
| 04 | `04_CODE03_PRODUCTION_MATERIAL_BATCH_PROMPTS.md` | CODE03 |
| 05 | `05_CODE04_PACKAGING_QR_PRINT_PROMPTS.md` | CODE04 |
| 06 | `06_CODE05_QC_RELEASE_PROMPTS.md` | CODE05 |
| 07 | `07_CODE06_WAREHOUSE_INVENTORY_PROMPTS.md` | CODE06 |
| 08 | `08_CODE07_TRACEABILITY_PROMPTS.md` | CODE07 |
| 09 | `09_CODE08_RECALL_PROMPTS.md` | CODE08 |
| 10 | `10_CODE09_ADMIN_UI_RBAC_PROMPTS.md` | CODE09 |
| 11 | `11_CODE10_API_CONTRACT_PROMPTS.md` | CODE10 |
| 12 | `12_CODE11_PWA_OFFLINE_PROMPTS.md` | CODE11 |
| 13 | `13_CODE12_DEVICE_PRINTER_PROMPTS.md` | CODE12 |
| 14 | `14_CODE13_EVENT_OUTBOX_MISA_PROMPTS.md` | CODE13 |
| 15 | `15_CODE14_MONITORING_DASHBOARD_PROMPTS.md` | CODE14 |
| 16 | `16_CODE15_OVERRIDE_GOVERNANCE_PROMPTS.md` | CODE15 |
| 17 | `17_CODE16_RETENTION_ARCHIVE_RESTORE_PROMPTS.md` | CODE16 |
| 18 | `18_CODE17_FINAL_CLOSEOUT_PROMPTS.md` | CODE17 |

## 3. Cach Dung

1. Neu bat dau tu zero, chay truoc:
   - `../04_PROJECT_LIFECYCLE_PROMPTS/01_PROJECT_INITIATION_PROMPTS.md`
   - `../04_PROJECT_LIFECYCLE_PROMPTS/02_REPO_AND_LOCAL_ENV_PROMPTS.md`
   - `../04_PROJECT_LIFECYCLE_PROMPTS/03_ARCHITECTURE_FOUNDATION_PROMPTS.md`
2. Chay `../02_AGENT_PROMPT_SEQUENCE.md` Prompt 00 de bootstrap implementation queue.
3. Khi vao implementation, chon file chi tiet theo thu tu trong bang muc 2.
4. Copy prompt dau tien cua phase de audit.
5. Chi copy prompt implement sau khi audit/plan da chon `gap_id` va write scope.
6. Sau moi run, bat agent cap nhat `../03_PROGRESS_REPORT.md`.
7. Khi CODE17 xong, quay lai lifecycle prompts `06_...` den `10_...` cho UAT/CI-CD/go-live/post-go-live/bao cao.

## 4. Prompt Contract Bat Buoc

Moi prompt implement/review/validate trong thu muc nay mac dinh ap dung:

- Requirement source-of-truth: `docs/software-specs/`.
- Neu repo/app chua scaffold, layer vang mat phai duoc ghi `NOT_SCAFFOLDED`.
- Current code, khi da ton tai, chi la implementation baseline/gap evidence.
- Khong tao route/table/enum/business truth song song.
- Khong sua lan ngoai bounded gap.
- Neu backend contract thay doi, phai update frontend client/types/screens/tests hoac co no-impact evidence.
- Neu schema/seed thay doi, phai co migration/seed validation.
- Khong bypass audit, idempotency, permission, QC, release, inventory ledger, trace, recall, MISA boundary.
- Khong de agent-owned long-running process chay sau final.

## 5. Output Contract Chung

Moi agent run phai tra ve:

- Summary.
- Phase/gap ID.
- Requirement source.
- Evidence used.
- Files changed.
- Commands run.
- Backend build/test result.
- Frontend build/test result.
- Migration/update result, if applicable.
- Seed validation result, if applicable.
- Smoke result, if applicable.
- Process cleanup result.
- Progress report update.
- Remaining risks.
- Next recommended prompt.
