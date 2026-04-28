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

## 3. Thu Tu Su Dung

1. Doc `01_PHASE_PROJECT_TODO.md` de chon phase/gap tiep theo.
2. Copy prompt tu `02_AGENT_PROMPT_SEQUENCE.md` theo dung thu tu.
3. Sau khi agent hoan thanh, bat agent cap nhat `03_PROGRESS_REPORT.md`.
4. Neu phase phat sinh blocker, cap nhat `09_CONFLICT_AND_OWNER_DECISIONS.md` hoac phan `Owner Decision Tracker` trong `03_PROGRESS_REPORT.md`.
5. Chi chuyen phase khi done gate cua phase truoc da co evidence hoac duoc owner chap nhan defer.

Neu bat dau tu zero hoac can dua den production:

1. Doc `04_PROJECT_LIFECYCLE_PROMPTS/00_README.md`.
2. Chay prompt theo thu tu file `01_...` den `10_...`.
3. Khi vao phase implementation, doc `02_AGENT_PROMPT_SEQUENCE.md` de nam workflow chung.
4. Sau do dung `05_DETAILED_PHASE_PROMPTS/` de copy prompt chi tiet theo tung `CODE01-CODE17`.
5. Khi chuan bi release/go-live, dung `04_PROJECT_LIFECYCLE_PROMPTS/07_...`, `08_...`, `09_...`.

## 4. Source Discipline

Khi dung prompt trong thu muc nay:

- `docs/software-specs/` la source-of-truth cho requirement.
- Current code chi duoc dung lam implementation baseline/gap evidence.
- `AGENTS.md` la operating rule cua repo, khong phai requirement source.
- Khong dung `.tmp-docx-extract/` de override spec da repair trong `docs/software-specs/`.
- Khong tao route/table/enum/business truth song song neu chua co impact analysis.

## 5. Agent Done Rule

Moi agent run phai ket thuc bang:

- files changed;
- requirement source;
- evidence used;
- commands run;
- build/test/migration/seed/smoke result hoac blocker;
- process cleanup result;
- progress update vao `03_PROGRESS_REPORT.md`;
- remaining risks va next recommended action.
