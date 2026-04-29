# 00 - Project Lifecycle Prompts README

## 1. Muc Dich

Thu muc `04_PROJECT_LIFECYCLE_PROMPTS/` bo sung bo prompt di tu luc bat dau tao du an den khi dua vao van hanh thuc te.

Neu `02_AGENT_PROMPT_SEQUENCE.md` tap trung vao trien khai tung `CODE01-CODE17`, bo nay mo rong ra toan bo vong doi:

```text
project inception
-> repository bootstrap
-> architecture foundation
-> phase implementation
-> data/migration/seed
-> QA/UAT
-> CI/CD and release candidate
-> production readiness
-> go-live
-> post go-live operations
-> management reporting
```

## 2. Thu Tu Doc Bat Buoc

| Thu tu | File | Dung khi nao |
| --- | --- | --- |
| 00 | `00_README.md` | Hieu scope va cach dung bo prompt. |
| 01 | `01_PROJECT_INITIATION_PROMPTS.md` | Khi bat dau du an, chot scope, success criteria, quyết định owner, team/process. |
| 02 | `02_REPO_AND_LOCAL_ENV_PROMPTS.md` | Khi tao/scaffold repo, local dev, env/secrets, branch strategy. |
| 03 | `03_ARCHITECTURE_FOUNDATION_PROMPTS.md` | Khi khoa architecture, coding conventions, skeleton module, ADR. |
| 04 | `04_IMPLEMENTATION_PHASE_PROMPTS.md` | Khi bat dau implement tung phase/gap theo CODE01-CODE17; sau kickoff, dung tiep `../05_DETAILED_PHASE_PROMPTS/`. |
| 05 | `05_DATA_MIGRATION_SEED_PROMPTS.md` | Khi lam database, migration, seed, data validation. |
| 06 | `06_QA_UAT_ACCEPTANCE_PROMPTS.md` | Khi test, UAT, acceptance, bug triage. |
| 07 | `07_CICD_DEPLOYMENT_PROMPTS.md` | Khi tao CI/CD, staging, release candidate, rollback. |
| 08 | `08_PRODUCTION_READINESS_GO_LIVE_PROMPTS.md` | Khi chuan bi production, go/no-go, go-live, day-1 operations. |
| 09 | `09_POST_GO_LIVE_OPERATIONS_PROMPTS.md` | Khi vao hypercare, incident, monitoring, change management. |
| 10 | `10_MANAGEMENT_REPORTING_PROMPTS.md` | Khi can bao cao tien do, blocker, owner decision, release status cho sep. |

## 3. Cach Copy/Paste Cho AI Agents

Moi prompt trong bo nay duoc viet theo cau truc:

- `Role`
- `Mission`
- `Source discipline`
- `Read first`
- `Scope`
- `Non-goals`
- `Workflow`
- `Validation`
- `Stop conditions`
- `Required output`
- `Cập nhật tiến độ`

Khi copy prompt, thay cac placeholder nhu `{project_name}`, `{phase}`, `{gap_id}`, `{environment}` bang gia tri thuc te.

## 4. Rule Bat Buoc

- Khong mark done neu chua cap nhat `../03_PROGRESS_REPORT.md`.
- Khong implement code khi prompt dang o audit/planning/review mode.
- Khong deploy production neu OD-12/OD-13/OD-17 hoac production readiness gate lien quan con open ma chua co owner accepted risk.
- Khong chay lenh destructive tren database production neu khong co approval ro rang.
- Moi agent phai bao cao command da chay, ket qua validation va process cleanup.
