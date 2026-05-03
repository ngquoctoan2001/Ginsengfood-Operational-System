# 01 - Phase Project To-Do List

> Muc tieu: bien `CODE01-CODE17` thanh danh sach viec co the giao tuan tu cho AI agents. File nay dung de chon viec tiep theo; prompt copy/paste nam trong `02_AGENT_PROMPT_SEQUENCE.md`; ket qua cap nhat vao `03_PROGRESS_REPORT.md`.

## 1. Status Legend

| Status        | Y nghia                                               |
| ------------- | ----------------------------------------------------- |
| `TODO`        | Chua giao cho agent.                                  |
| `IN_PROGRESS` | Agent dang lam, chua co handoff.                      |
| `NEEDS_OWNER` | Bi chan boi owner decision.                           |
| `NEEDS_FIX`   | Agent da lam nhung review/validation fail.            |
| `DONE`        | Da co patch, validation, handoff va cáº­p nháº­t tiáº¿n Ä‘á»™. |
| `DEFERRED`    | Owner chap nhan day sang phase sau.                   |

## 2. Open Owner Decisions Canh Bao

Cap nhat 2026-05-03 (turn 6 directive "giai quyet triet de"): TAT CA OD da chuyen sang `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03`. 23 OD provisional (8 Batch 1 + 15 Batch 2) duoc owner accept lam production-acceptable; 3 OD truoc day BLOCKING (EVIDENCE-STORAGE/NOTIFY-OWNERSHIP/PACKET-TRACE) cung duoc accept voi provisional adapter/boundary/policy lam production-acceptable. Default ghi tai `docs/v2-decisions/OD-DEFAULTS-2026-05-03.md` va `docs/v2-decisions/OD-DEFAULTS-BATCH2-2026-05-03.md`. Khong con OD nao block CODE00-CODE17. Owner co the swap gia tri runtime qua `op_*_config` table hoac DI binding ma khong can doi schema/contract.

| OD                      | Anh huong                                             | Trang thai                                                                                                                              |
| ----------------------- | ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| OD-11                   | CODE07 trace query technical SLA/latency target.      | `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03` (production-acceptable; runtime swap qua `op_trace_sla_config`)                                  |
| OD-12                   | CODE16 backup/DR RPO/RTO.                             | `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03` (production-acceptable; storage adapter swap qua DI `IBackupAdapter`)                            |
| OD-13                   | CODE16 audit/ledger/trace/recall retention.           | `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03` (production-acceptable; runtime swap qua `op_retention_policy`)                                  |
| OD-14                   | CODE07 public trace i18n policy.                      | `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03` (production-acceptable; schema i18n-ready, MVP `vi`)                                             |
| OD-17                   | CODE12 printer model/driver.                          | `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03` (production-acceptable; ZPL-over-HTTP + HMAC, swap printer adapter qua DI)                       |
| OD-EVIDENCE-STORAGE-001 | CODE05 (M05) + CODE13 (M13) evidence storage backend. | `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03` (production-acceptable; `LocalFileSystemEvidenceAdapter`, swap qua DI `IEvidenceStorageAdapter`) |
| OD-NOTIFY-OWNERSHIP-001 | CODE13 recall + notification boundary.                | `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03` (production-acceptable; outbox-only boundary, external Notification Service consume)             |
| OD-PACKET-TRACE-001     | CODE07 (M12) + CODE12 (M10) PACKET trace policy.      | `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03` (production-acceptable; PACKET inherit trace qua BOX/CARTON parent, schema `qr_code` nullable)   |

## 3. Prompt Execution Order

Day/Week labels are planning hints only. For copy/paste prompt execution, follow `Run order` from top to bottom.

| Run order | Suggested timing | Phase                   | Priority        | Goal                                                                                | Agent order                                                                   | Done gate                                                                                                                                                                              | Status |
| --------- | ---------------- | ----------------------- | --------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 00        | W0               | PROJECT-INITIATION      | P0              | Confirm scope, success criteria, quyáº¿t Ä‘á»‹nh owner, governance.                      | PM/BA Agent                                                                   | Charter/governance/decision tracker ready.                                                                                                                                             | TODO   |
| 01        | W0               | REPO-LOCAL-ENV          | P0              | Scaffold repo and local environment.                                                | DevOps/Tech Lead Agent                                                        | Repo/local env baseline ready; absent app layers marked `NOT_SCAFFOLDED`.                                                                                                              | TODO   |
| 02        | W0               | ARCHITECTURE-FOUNDATION | P0              | Lock architecture, conventions, module skeleton, ADR baseline.                      | Architect Agent -> Review                                                     | Architecture skeleton accepted.                                                                                                                                                        | TODO   |
| 03        | W0               | PROJECT-BOOTSTRAP       | P0              | Confirm source/docs, initialize progress, select first bounded gap.                 | Audit Agent -> Planner Agent                                                  | Progress report initialized; first bounded gap selected.                                                                                                                               | TODO   |
| 04        | W1               | CODE01                  | P0              | Foundation + Source Origin.                                                         | Audit -> Plan -> DB/Backend/API/FE/Seed/Test -> Review -> Validate -> Handoff | Source origin verification lifecycle works; audit/idempotency/event base mapped.                                                                                                       | TODO   |
| 04A       | W1-W2            | CODE01A                 | P0              | Supplier Management + Supplier Portal baseline (M03A + M03B).                       | Audit -> Plan -> DB/Backend/API/FE/Seed/Test -> Review -> Validate -> Handoff | Supplier CRUD + suspension/reactivation works; supplier portal receipt submission works; `auth_user` + `op_supplier_user_link` mapped; `supplier.*/dot-namespace` permission enforced. | TODO   |
| 05        | W2               | CODE02                  | P0              | Raw Material Intake + Lot + Incoming QC.                                            | Audit -> Plan -> Implement -> Review -> Validate -> Handoff                   | Raw lot ready only after procurement rule + QC gate.                                                                                                                                   | TODO   |
| 06        | W2               | MX-GATE-G1              | P0              | Master data/recipe readiness before manufacturing.                                  | Seed/DB/API audit -> Validation                                               | 20 SKU baseline, ingredient master, G1, 4 groups, future versioning ready.                                                                                                             | TODO   |
| 07        | W3-W4            | CODE03                  | P0              | Manufacturing execution, PO snapshot, material issue/receipt, batch genealogy root. | Audit -> Plan -> Implement slices -> Review -> Validate -> Handoff            | PO snapshot immutable; issue decrements once; process chain includes preprocessing/freezing/freeze-drying.                                                                             | TODO   |
| 08        | W4               | CODE04                  | P0              | Packaging, GTIN, QR, print/reprint.                                                 | Audit -> Plan -> Implement -> Review -> Validate -> Handoff                   | QR lifecycle pass; print/reprint audited; GTIN fixture not mistaken for production GTIN.                                                                                               | TODO   |
| 09        | W5               | CODE05                  | P0              | QC inspection and batch release.                                                    | Audit -> Plan -> Implement -> Review -> Validate -> Handoff                   | `QC_PASS` does not auto-release; release is separate action/record.                                                                                                                    | TODO   |
| 10        | W5               | CODE06                  | P0              | Warehouse receipt and inventory ledger.                                             | Audit -> Plan -> Implement -> Review -> Validate -> Handoff                   | Finished goods receipt requires `RELEASED`; ledger/balance projection correct.                                                                                                         | TODO   |
| 11        | W6               | CODE07                  | P0              | Internal/public trace and genealogy.                                                | Audit -> Plan -> Implement -> Review -> Validate -> Handoff                   | Backward/forward trace works; public trace denylist passes.                                                                                                                            | TODO   |
| 12        | W6-W7            | CODE08                  | P0              | Recall and product recovery.                                                        | Audit -> Plan -> Implement -> Review -> Validate -> Handoff                   | Recall impact snapshot, hold/sale lock/recovery/close gate pass.                                                                                                                       | TODO   |
| 13        | W7               | CODE09                  | P1              | Admin UI registry, menu, screen/action permission.                                  | UI/RBAC Agent -> Review -> Validate                                           | Permission-aware UI pass; no privileged action without backend gate.                                                                                                                   | TODO   |
| 14        | W7               | CODE10                  | P1              | API contract convention and middleware.                                             | API Agent -> FE Sync Agent -> Review -> Validate                              | Error/envelope/pagination/idempotency/auth contract pass.                                                                                                                              | TODO   |
| 15        | W8               | CODE11                  | P1              | PWA/internal app offline command contract.                                          | PWA Agent -> API Sync -> Review -> Validate                                   | Offline replay idempotent; device/session header standard works.                                                                                                                       | TODO   |
| 16        | W8               | CODE12                  | P1              | Printer/device boundary.                                                            | Device Agent -> Review -> Validate                                            | No direct DB/device bypass; printer blocker recorded if OD-17 still open.                                                                                                              | TODO   |
| 17        | W8-W9            | CODE13                  | P1              | Event schema, outbox, MISA adapter.                                                 | Event/MISA Agent -> Review -> Validate                                        | Retry/reconcile pass; modules do not sync directly to MISA.                                                                                                                            | TODO   |
| 18        | W9               | CODE14                  | P2              | Dashboard, alert, health.                                                           | Reporting Agent -> Review -> Validate                                         | Critical operational alerts visible.                                                                                                                                                   | TODO   |
| 19        | W9               | CODE15                  | P2              | Override governance and break-glass audit.                                          | Security Agent -> Review -> Validate                                          | Override audited, permissioned, reasoned.                                                                                                                                              | TODO   |
| 20        | W10              | CODE16                  | P2              | Retention, archive, restore.                                                        | Retention Agent -> Owner Decision -> Validate                                 | Blocked until OD-12/OD-13 closed or formally deferred.                                                                                                                                 | TODO   |
| 21        | W10              | CODE17                  | P0 release gate | Final smoke, release readiness, handoff.                                            | Release Agent -> QA Agent -> Owner Review                                     | Full smoke and report pack ready for management.                                                                                                                                       | TODO   |
| 22        | Release          | UAT-CICD-GOLIVE         | P0 release gate | UAT, CI/CD, production readiness, go-live, post-go-live reporting.                  | QA -> DevOps -> Owner Review -> PM                                            | Go/no-go evidence pack and management report ready.                                                                                                                                    | TODO   |

## 4. Bounded Gap Checklist

Moi phase phai tach thanh bounded gaps neu cham qua nhieu layer.

| Check            | Bat buoc                                                                                                                                 |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `gap_id`         | Co ma gap ro rang, vi du `GAP-C03-PO-SNAPSHOT`.                                                                                          |
| Nguá»“n yÃªu cáº§u    | Co `REQ-*`, `BR-*`, `TC-*`, file spec va heading.                                                                                        |
| Scope            | Ghi ro DB/backend/API/frontend/seed/test/docs nao duoc sua.                                                                              |
| Non-goals        | Ghi ro nhung viec khong lam trong gap nay.                                                                                               |
| Current evidence | Neu chua co app code, ghi `NOT_SCAFFOLDED`; neu da co code, doc code de audit sau khi da doc specs; khong dung code lam source-of-truth. |
| Done gate        | Build/test/migration/seed/smoke nao can pass.                                                                                            |
| Handoff          | Cap nhat `03_PROGRESS_REPORT.md` va file handoff lien quan.                                                                              |

## 5. Suggested Phase Slices

| Phase         | Suggested slices                                                                                                                                   |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| CODE01        | Foundation support tables; auth/RBAC baseline; source zone; source origin evidence/verification; UI source screens.                                |
| CODE02        | Intake command; procurement type validation; raw lot lifecycle; incoming QC; raw ledger receipt; UI raw screens.                                   |
| MX-GATE-G1    | SKU CRUD/versioning; ingredient CRUD/versioning; recipe G1 seed; recipe API; validation queries.                                                   |
| CODE03        | PO snapshot; work order; material request/approval; material issue execution; material receipt confirmation; process events; batch genealogy root. |
| CODE04        | Trade item/GTIN; packaging level 1; packaging level 2; QR registry; print job; reprint/void audit.                                                 |
| CODE05        | QC template; inspection; disposition; release queue; release action; release audit.                                                                |
| CODE06        | Warehouse receipt; inventory ledger; lot balance projection; adjustment; allocation reference.                                                     |
| CODE07        | Internal trace graph; public trace whitelist; QR resolve; trace query performance; trace tests.                                                    |
| CODE08        | Incident; recall case; impact snapshot; hold/sale lock; recovery/disposition; CAPA/evidence/close.                                                 |
| CODE09-CODE16 | Treat each as cross-cutting slice; never let cross-cutting work rewrite business workflow truth.                                                   |

## 6. Mandatory Management Reporting Fields

Sau moi agent run, cap nhat `03_PROGRESS_REPORT.md` voi:

- phase/gap;
- status;
- what changed;
- káº¿t quáº£ kiá»ƒm chá»©ng;
- blockers;
- risk;
- next action;
- owner decision needed;
- date/time;
- agent name/model neu co.
