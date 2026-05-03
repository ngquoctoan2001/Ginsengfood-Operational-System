# 07 - Phase Plan

> Mục tiêu: chia phase triển khai theo `SRC-FILE04-1` CODE01-CODE17, nhưng map rõ sang 16 module chuẩn, database, API, UI, seed, test, dependency, done gate, risk và priority.

## 1. Nguyên Tắc Phase

| Nguyên tắc | Mô tả |
| --- | --- |
| Bounded | Mỗi phase có scope rõ và không ôm toàn bộ hệ thống. |
| Dependency-first | Foundation/master/config trước transaction; transaction trước trace/recall/reporting. |
| No hidden owner decision | Nếu thiếu dữ liệu, phase ghi `[OWNER DECISION NEEDED]`. |
| Traceable | Mọi phase map được về source, module, DB, API, UI, test. |
| Done gate thật | Không coi phase done nếu thiếu migration/seed/test/handoff tương ứng ở phase triển khai sau. |
| Source policy | Phase plan không dựa vào code hiện tại. |

## 2. Phase Summary CODE01-CODE17

| CODE | Priority | Goal | Module liên quan | Dependency |
| --- | --- | --- | --- | --- |
| CODE01 | P0 | Foundation + Source Origin | M01, M02, M03, M05, M16 | Source policy/owner decisions |
| CODE01A | P0 | M03A Supplier Management + Supplier Portal Auth Baseline | M03A, M02, M03, M16 | CODE01 |
| CODE02 | P0 | Raw Material Intake + Lot + Incoming QC | M06, M05, M11, M16 | CODE01A |
| CODE03 | P0 | Manufacturing Execution + Batch + Genealogy Foundation | M04, M07, M08, M11, M12, M16 | CODE01, CODE01A, CODE02, MX-GATE-G1 |
| CODE04 | P0 | Packaging & Printing Control | M10, M04, M16 | CODE03 |
| CODE05 | P0 | QC & Batch Release | M09, M10, M11, M16 | CODE04 |
| CODE06 | P0 | Warehouse Receipt & Inventory Control | M11, M14, M16 | CODE05 |
| CODE07 | P0 | Traceability & Batch Genealogy Engine | M12, M05, M06, M07, M08, M10, M11, M16 | CODE06 |
| CODE08 | P0 | Recall & Product Recovery Engine | M13, M12, M11, M14, M16 | CODE07 |
| CODE09 | P1 | Role-Based Admin UI Engine + Screen Registry + Permission | M02, M16 | CODE01; evolves with CODE02-CODE08 |
| CODE10 | P1 | API Contract + Query/Command Boundary + Error/Permission/Audit Middleware | M01, M02, all API modules | CODE01; evolves with all modules |
| CODE11 | P1 | Mobile/Internal App Contract + Offline/Idempotency + Device Header Standard | M16, M01, M02, M06, M08, M10 | CODE10 |
| CODE12 | P1 | Device/Printer/IoT Integration + Heartbeat + Error/Incident Bridge | M10, M14, M15 | CODE04, CODE10 |
| CODE13 | P1 | Event Schema Registry + Outbox/Event Bus Adapter + Compatibility Lock | M01, M14 | CODE03-CODE08 |
| CODE14 | P2 | Monitoring/Alert Rule Engine + Incident Response + Dashboard Health | M15, M16, M14 | CODE13 |
| CODE15 | P2 | Manual Override + Break-Glass + Human-in-the-Loop Governance | M01, M02, M09, M11, M13, M16 | CODE10, CODE14 |
| CODE16 | P2 | Data Retention + Archival + Restore / Archive Search Boundary | M01, M11, M12, M13, M14, M15 | PF-02 backup/retention baseline |
| CODE17 | P0 release gate | Final Close-Out Gate + Integration Smoke + Release Readiness + Handover Checklist | All | CODE01-CODE16 |

## 3. Master Data G1 Readiness Gate

`MX-GATE-G1` là gate bắt buộc trước CODE03, không phải phase riêng:

| Gate item | Done condition | Source |
| --- | --- | --- |
| 20 SKU baseline | Có đủ 20 SKU baseline go-live, không hard-code giới hạn vĩnh viễn | `SRC-FILE02`, `SRC-LOCK5`, owner OD-19 |
| Ingredient master | Có `ING_MI_CHINH`, `HRB_SAM_SAVIGIN`, `ING_THIT_HEO_NAC` | `SRC-RECIPE-NEW`, owner OD-01 |
| G1 active formula | Mỗi SKU go-live có formula G1 active operational | `SRC-RECIPE-NEW`, `SRC-LOCK5` |
| 4 recipe groups | Chỉ dùng `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR` | `SRC-RECIPE-NEW` |
| Future versioning | Thiết kế hỗ trợ G2/G3/G4... approve/activate/retire/snapshot | `SRC-FILE02`, prompt gốc |
| Snapshot fields | Production order snapshot capture đủ formula/SKU/group/ingredient/quantity/UOM/prep/usage | `SRC-LOCK5`, `SRC-RECIPE-NEW` |
| No research/baseline token in operational flow; G1 PILOT and G2 FIXED coexist model | Không seed/use baseline nghiên cứu trong operational flow; G1 `PILOT_PERCENT_BASED` và G2 `FIXED_QUANTITY_BATCH` có thể coexist active theo `(sku_id, formula_kind)` | prompt gốc, `SRC-LOCK5`, `CONFLICT-18` |

## 4. Phase Detail

| CODE | Mục tiêu | Scope | DB/schema | API | UI | Seed | Test | Done gate | Risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CODE01 | Khóa nền hệ thống và source origin | Audit/idempotency/event base; source zone/origin/evidence/verification; basic RBAC hooks | `audit_log`, `idempotency_registry`, `event_schema_registry`, `op_source_zone`, `op_source_origin`, evidence/verification tables | `/api/admin/source-zones/*`, `/api/admin/source-origins/*`, `/api/admin/audit/*` | Source zone registry, source origin verification, audit viewer sơ bộ | Source zone sample, role seed tối thiểu, event types | Unit + API + seed validation cho source origin verification | Source origin có lifecycle và lot `SELF_GROWN` có thể kiểm gate `VERIFIED` | Source address public fields chưa được owner duyệt lại nếu thay đổi hành chính |
| CODE01A | Khóa M03A supplier baseline | Supplier master, supplier user link, supplier ingredient allowlist, role `R-SUPPLIER`, supplier auth/scope middleware baseline | `op_supplier`, `op_supplier_ingredient`, `op_supplier_user_link`, `auth_role`, `auth_permission`, `role_action_permission` | `/api/admin/suppliers/*`, `/api/supplier/me` | Supplier admin screens, Supplier Portal login/scope | Supplier dev fixture, `R-SUPPLIER`, supplier admin permissions | TC-M03A-*, TC-HL-SUP-SCOPE-*, TC-HL-SUP-ALLOW-* | Supplier scope/allowlist/auth pass; CODE02-SUP có owner data boundary rõ | Production supplier list/credential thật chờ owner data |
| CODE02 | Khóa đầu vào nguyên liệu | Intake, supplier/source binding, raw lot, incoming QC, raw material ledger receipt | Raw receipt/item, raw lot, raw QC, raw ledger receipt | `/api/admin/raw-material/intakes/*`, `/lots/*`, `/qc/*` | Raw material intake, QC, lot detail | Ingredient reference tối thiểu, supplier/source sample, QC status | API + workflow test: `SELF_GROWN`, `PURCHASED`, QC pass/hold/reject | Raw lot chỉ ready khi QC pass; field theo procurement type đúng | Thiếu owner data supplier/source thực tế |
| CODE03 | Khóa sản xuất và batch genealogy root | Production order, G1 snapshot, work order, process events, batch, material issue/receipt | Production order/item snapshot, work order, process event, batch, issue/receipt, batch material usage | `/api/admin/production/orders/*`, `/work-orders/*`, `/material-issues/*`, `/material-receipts/*`, `/batches/*` | Production order, material issue/receipt, process execution, batch detail | 20 SKU + G1 + ingredient + recipe line groups | Snapshot test, forbidden-baseline test, material issue decrement test, process order test | PO snapshot bất biến, issue theo lot, receipt không decrement, batch genealogy tạo được | Recipe seed chưa đủ sẽ block CODE03 |
| CODE04 | Khóa đóng gói/in/QR | Packaging job/unit, print job/log, QR registry, trade item/GTIN | Packaging, print, QR, trade item/GTIN | `/api/admin/packaging/*`, `/printing/*`, `/qr/*`, `/trade-items/*` | Packaging job, print queue, QR lifecycle, GTIN config | GTIN fixture `DEV_TEST_ONLY`, print templates | QR lifecycle API test, reprint audit test, missing GTIN block test | QR đủ 6 state; reprint link original; commercial print cần GTIN thật hoặc production import `is_test_fixture=false` | GTIN thật import sát go-live; fixture bị block production |
| CODE05 | Khóa QC và release | QC inspection, disposition, batch release, state transition | QC inspection/item, batch disposition, batch release, transition log | `/api/admin/qc/inspections/*`, `/api/admin/qc/releases/*` | QC inspection, release queue, batch release | QC checklist template | API + workflow test: `QC_PASS` không auto release | Batch chỉ `RELEASED` sau release action/record | Role approval chưa chi tiết nếu owner thay policy |
| CODE06 | Khóa nhập kho và tồn kho | Warehouse receipt, ledger, balance, adjustment/allocation references | Warehouse receipt, inventory ledger, lot balance, allocation, adjustment | `/api/admin/warehouse/*`, `/api/admin/inventory/*` | Warehouse receipt, ledger viewer, lot balance | 1 `RAW_MATERIAL`, 1 `FINISHED_GOODS`, locations | Ledger append-only, receipt requires `RELEASED`, balance projection test | Finished goods inventory chỉ tăng qua confirmed receipt | Multi-warehouse thực tế cần owner data |
| CODE07 | Khóa traceability | Internal trace, public trace, genealogy search, QR resolve, exposure reference | Trace link, genealogy link, trace index/views, public trace policy | `/api/admin/trace/*`, `/api/public/trace/*` | Trace search, genealogy tree, public trace preview | Public field policy seed | Public leakage tests, QR invalid state tests, internal trace graph tests | Trace backward/forward đủ chain; public không lộ private field; SLA metric đo được | PF-01: OD-11/OD-14 đã freeze baseline |
| CODE08 | Khóa recall/recovery | Incident, recall case, hold, sale lock, exposure snapshot, recovery, disposition, CAPA, CAPA evidence | Incident, recall case/batch, hold, sale lock, recovery, disposition, CAPA, CAPA evidence, timeline | `/api/admin/incidents/*`, `/api/admin/recall/*`, `/api/admin/recall/capas/{capaId}/evidence` | Incident dashboard, recall case management, recovery/CAPA evidence | Recall reason/severity seed, evidence scan fixture | Recall smoke: trace impact → hold → notification ref → recovery/CAPA → clean evidence → close | Recall dùng trace snapshot, có audit timeline, close cần clean CAPA evidence | Notification system external chỉ giữ reference; production storage server config do DevOps cung cấp |
| CODE09 | Khóa Admin UI/RBAC | Screen registry, role/action matrix, menu/sidebar, permission gate | UI registry, action registry, role-action mapping | `/api/admin/ui/*`, `/api/admin/roles/*` | Menu/sidebar, screen/action registry, permission-aware UI | Role/action/screen seed | UI permission test, hidden/disabled action tests | Không có privileged action không audit | Screen detail còn cần Part UI spec |
| CODE10 | Khóa API contract | API convention, error, pagination/filter/sort, auth middleware, audit middleware | Idempotency/audit support if needed | All module route contracts | API client contract handoff | Error code/reference seed nếu có | API contract tests, error shape tests, permission tests | API catalog đủ request/response/error/idempotency | Không đối chiếu current code trong batch này |
| CODE11 | Khóa mobile/internal contract | PWA/internal app contract, scan, offline submit, idempotency/device headers | Offline submit/idempotency records | `/api/mobile/*` hoặc internal endpoints theo contract | PWA shopfloor screens | Device/header seed nếu có | Duplicate offline submit idempotency test | PWA-first contract có scan/material issue/receipt basics | Native app ngoài scope phase này |
| CODE12 | Khóa device/printer boundary | Printer/scanner adapter, heartbeat, callback, incident bridge | Device, heartbeat, callback log | `/api/admin/devices/*`, `/api/admin/printers/*`, callbacks | Device/printer console | Device fixture `DEV_TEST_ONLY` | Callback/heartbeat/failure tests | Device không access DB và không bypass QC/release; HMAC callback auth | PF-02: physical model/config refs, HTTP/ZPL-compatible adapter baseline |
| CODE13 | Khóa event/outbox | Event schema, outbox, compatibility, MISA consumer events | Event schema/outbox/event log | `/api/admin/events/*` | Event/outbox monitor | Event type seed | Outbox delivery/retry/compatibility tests | Breaking event change bị chặn hoặc versioned | Event taxonomy cần đồng bộ all modules |
| CODE14 | Khóa monitoring/dashboard | Health, alerts, operational dashboard, incident response hooks | Alert rule/event, health snapshot, dashboard metric | `/api/admin/dashboard/*`, `/api/admin/alerts/*`, `/health/*` | Dashboard, alerts, health | Alert rule seed | Alert tests: MISA fail, printer fail, recall SLA risk | Dashboard phản ánh health critical flows | Tooling cụ thể chưa chốt |
| CODE15 | Khóa override governance | Manual override, break-glass, reason, dual approval where needed | Override request/action/audit | `/api/admin/overrides/*` | Override queue/review | Override reason seed | Override audit/security tests | Override không mutate append-only silently | Need owner policy chi tiết cho dual approval |
| CODE16 | Khóa retention/archive/restore | Retention policy, archive/export, restore drill, archive search boundary | Retention policy, archive index/log | `/api/admin/retention/*`, `/api/admin/archive/*` | Retention/archive admin | PF-02 retention policy seed/config | Restore drill, archive search, retention tests | PF-02 RPO/RTO + retention baseline implemented and tested | Restore drill evidence required before production readiness |
| CODE17 | Close-out | Full smoke, release readiness, handoff checklist | No new schema unless gap found | Full API smoke | Full admin smoke | Full seed chain | E2E smoke intake→recall + MISA dry-run | Toàn bộ P0/P1 gates pass hoặc deferred rõ | Open OD phải có owner acceptance/defer |

## 5. Dependency Model

```text
CODE01
  → CODE01A
  → CODE02
  → MX-GATE-G1
  → CODE03
  → CODE04
  → CODE05
  → CODE06
  → CODE07
  → CODE08

CODE09 + CODE10 start after CODE01 and are updated with every module.
CODE11 depends on CODE10 + shopfloor flows.
CODE12 depends on CODE04 + CODE10.
CODE13 depends on event producers from CODE03-CODE08.
CODE14 depends on CODE13.
CODE15 depends on CODE10/CODE14 and high-risk actions.
CODE16 depends on OD-12/OD-13.
CODE17 depends on all prior phases.
```

## 6. Owner Decisions Còn Chặn

| OD | Phase bị ảnh hưởng | Quyết định cần có |
| --- | --- | --- |
| OD-11 | CODE07 | Trace query technical SLA/latency target. |
| OD-12 | CODE16 | Backup/DR RPO/RTO. |
| OD-13 | CODE16 | Audit/ledger/trace/recall retention duration. |
| OD-14 | CODE07 | Public trace multi-language policy. |
| OD-17 | CODE12 | Printer model/driver chính thức. |
| OD-20 | CODE13, CODE17 | MISA AMIS tenant/credential/endpoint thật cho production. |
| OD-21 | CODE11 | PWA task taxonomy và endpoint inbox `/api/admin/tasks/my`. |
| OD-22 | CODE09, CODE10, CODE11 | UI mutation route taxonomy phụ: UOM write, raw lot hold/release, process command, screen registry write. |

## 7. Done Gate Chung Cho Mọi Phase

- Requirement traceability cập nhật.
- Database spec/migration strategy cập nhật nếu phase có schema.
- API catalog/request-response/error/idempotency cập nhật nếu phase có endpoint.
- UI screen/form/action/permission cập nhật nếu phase có UI.
- Seed spec cập nhật nếu phase có seed.
- Test case matrix cập nhật.
- Conflict/owner decision cập nhật nếu phát sinh.
- Dev handoff cập nhật với scope, non-goals, validation, risks.


