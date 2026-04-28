# 02 - Codex Prompt Pack

## 1. Base Implementation Prompt

```text
Bạn là AI coding agent triển khai một bounded gap trong docs/software-specs.

Source discipline:
- Chỉ dùng prompt gốc, .tmp-docx-extract/, docs/software-specs/, kiến thức chuyên môn có đánh dấu và owner approval.
- Không dùng source code, current database, AGENTS.md hoặc docs/ginsengfood_* làm source-of-truth cho requirement.
- Khi đọc code để implement, code chỉ là implementation baseline/gap evidence.

Task:
- Phase: {CODE}
- Module: {Mxx}
- Requirement: {REQ-*}
- Business rule: {BR-*}
- Test case: {TC-*}
- Scope: {backend/API/DB/FE/seed/test/docs}
- Non-goals: {list}

Workflow:
1. Đọc spec liên quan trong docs/software-specs.
2. Lập gap map theo DB/backend/API/FE/seed/test/docs.
3. Lập plan bounded, nêu write scope.
4. Implement minimal patch.
5. Validate build/test/migration/seed/smoke theo done gate.
6. Review security/public trace/MISA/inventory/audit/API-FE sync nếu chạm.
7. Handoff bằng summary, files, evidence, commands, risks.
```

## 2. Anti-Scope Prompt

```text
Trước khi sửa file, hãy kiểm tra scope:
- File nào được phép sửa?
- File nào không thuộc gap?
- Có route/table/enum/business truth song song nào đang định tạo không?
- Có API/DTO thay đổi nhưng chưa update FE client/types/screens/tests không?
- Có migration/seed tác động dữ liệu lịch sử không?
- Có public trace/private field/MISA/inventory/audit risk không?

Nếu câu trả lời không rõ, dừng và ghi OWNER DECISION NEEDED hoặc gap report.
Không refactor rộng, không format diện rộng, không đổi tên ngoài scope.
```

## 3. Backend/Frontend Sync Prompt

```text
Hãy audit backend/frontend sync cho gap {gap_id}.

Kiểm tra:
1. Endpoint/method/path trong api/02_API_ENDPOINT_CATALOG.md.
2. Request/response DTO và error code.
3. Permission/action code.
4. Idempotency requirement.
5. UI screen trong ui/03_SCREEN_CATALOG.md.
6. FE API client/type/hook/form/table/action state.
7. Tests trong testing/03_API_TEST_PLAN.md và testing/04_UI_TEST_PLAN.md.

Output:
- API changes.
- FE changes required.
- FE files likely affected.
- Test cases required.
- No-FE-impact evidence nếu không cần FE.
```

## 4. Phase Prompts

| phase  | Prompt focus                                                                      |
| ------ | --------------------------------------------------------------------------------- |
| CODE01 | Foundation, source origin, audit/idempotency/RBAC seed, source verification       |
| CODE02 | Raw intake, raw lot, incoming QC, `RAW_LOT_MARK_READY`, `lot_status = READY_FOR_PRODUCTION` readiness |
| CODE03 | 20 SKU/G1, recipe versioning, PO snapshot, material issue/receipt requiring `READY_FOR_PRODUCTION` raw lot, genealogy root |
| CODE04 | Packaging, GTIN fixture, QR lifecycle, print/reprint                              |
| CODE05 | QC inspection, batch release, QC pass vs release separation                       |
| CODE06 | Warehouse receipt, inventory ledger, lot balance                                  |
| CODE07 | Internal trace, public trace whitelist, QR public eligibility                     |
| CODE08 | Incident, recall, impact snapshot, hold/sale lock, recovery/CAPA                  |
| CODE09 | Admin UI registry, menu/sidebar, RBAC visibility                                  |
| CODE10 | API convention, error, auth, idempotency, pagination/filter/sort                  |
| CODE11 | PWA/mobile offline command, device/session/idempotency, offline-safe material issue/receipt and lot mark-ready review |
| CODE12 | Printer/device boundary, heartbeat, callback, incident bridge                     |
| CODE13 | Event schema, outbox, MISA integration adapter                                    |
| CODE14 | Dashboard, alert, health snapshot                                                 |
| CODE15 | Override governance, break-glass audit and scoped override review for lot mark-ready/release gates |
| CODE16 | Retention, archive, restore drill                                                 |
| CODE17 | Final smoke including raw lot mark-ready, release readiness, handoff              |

## 5. Module Prompt Template

```text
Implement module {Mxx} gap {gap_id}.

Read:
- docs/software-specs/modules/{module_file}
- docs/software-specs/08_REQUIREMENTS_TRACEABILITY_MATRIX.md
- docs/software-specs/business/02_BUSINESS_RULES.md
- docs/software-specs/api/02_API_ENDPOINT_CATALOG.md
- docs/software-specs/ui/03_SCREEN_CATALOG.md
- docs/software-specs/testing/02_TEST_CASE_MATRIX.md

Produce:
- Gap map.
- Implementation plan.
- Minimal patch.
- Validation evidence.
- Handoff update.

Protect:
- G1 snapshot, 4 recipe groups, raw lot mark-ready gate (`QC_PASS` -> `RAW_LOT_MARK_READY` -> `READY_FOR_PRODUCTION` -> material issue), material issue decrement, batch release gate (`QC_PASS` -> explicit release -> warehouse receipt), public trace policy, MISA boundary, audit append-only.
```
