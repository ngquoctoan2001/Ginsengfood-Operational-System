# 03 - Frontend Implementation Guide

## 1. Mục tiêu

Hướng dẫn frontend/admin UI triển khai màn hình, form, table, action state và API client đồng bộ với backend contract.

## 2. Frontend Source Inputs

| Input | Cách dùng |
|---|---|
| `ui/01_UI_INFORMATION_ARCHITECTURE.md` | Navigation, screen groups |
| `ui/02_MENU_SIDEBAR_STRUCTURE.md` | Menu/sidebar and role visibility |
| `ui/03_SCREEN_CATALOG.md` | Screen route, API source, fields, columns, actions |
| `ui/05_FORM_FIELD_SPECIFICATION.md` | Form field, validation, enum, required rules |
| `ui/06_TABLE_ACTION_FILTER_SPECIFICATION.md` | Table columns, filters, actions |
| `ui/07_UI_STATE_AND_VALIDATION.md` | Loading/empty/error/stale/permission states |
| `ui/08_FRONTEND_API_CLIENT_CONTRACT.md` | API client contract |
| `api/02_API_ENDPOINT_CATALOG.md` | Backend route/method/error/idempotency |

## 3. UI Implementation Rules

| rule_id | Rule |
|---|---|
| FE-RULE-001 | Mỗi screen phải gọi đúng route family trong API catalog; không tạo parallel API client. |
| FE-RULE-002 | Command action phải gửi `Idempotency-Key` nếu endpoint yêu cầu. |
| FE-RULE-003 | UI ẩn/disable action theo permission nhưng backend vẫn là gate; test cả hai. |
| FE-RULE-004 | Mọi form có loading, empty, validation, error, stale state và retry nếu phù hợp. |
| FE-RULE-005 | Public trace page không render private fields và không dùng admin trace response. |
| FE-RULE-006 | Không hard-code 20 SKU như limit; chỉ dùng như seed baseline list. |
| FE-RULE-007 | Snapshot fields hiển thị read-only trong PO detail/print. |
| FE-RULE-008 | Raw lot UI phải hiển thị `qcStatus` và `lotStatus` riêng; Mark Ready chỉ hiện khi lot `QC_PASS`, chưa `READY_FOR_PRODUCTION`, không hold/reject/quarantine và user có action `RAW_LOT_MARK_READY`. |
| FE-RULE-009 | Material issue lot picker phải filter `lotStatus=READY_FOR_PRODUCTION`; không enable issue chỉ vì `qcStatus=QC_PASS`. |

## 4. Screen Groups By Module

| module | Screens | Must test |
|---|---|---|
| M04 | SKU, Ingredient, Recipe, Recipe Lines | 20 SKU baseline, required ingredients, 4 recipe groups, G1 active |
| M05/M06 | Source zones/origins, Raw intakes/lots, Incoming QC, Lot Readiness | Source evidence upload/scan state, source verification, procurement type, QC status, `lotStatus`, Mark Ready action |
| M07/M08 | PO, PO detail, Work order, Process, Material request/issue/receipt | Snapshot read-only, issue decrement, lot `READY_FOR_PRODUCTION` gate, receipt no double decrement |
| M09/M11 | QC inspection, Batch release, Warehouse receipt, Ledger, Balance | QC pass vs release, released-only receipt |
| M10/M12 | Packaging, QR registry, Print queue, Public trace preview/page | QR states, reprint reason, public whitelist |
| M13/M14 | Recall, Impact, Hold, CAPA, CAPA evidence, MISA sync/mapping/reconcile | Snapshot, hold/sale lock, clean evidence close gate, mapping missing |
| M15/M16 | Dashboard, Alerts, Screen registry, PWA | Permission, status, offline idempotency |

## 5. Backend/Frontend Sync Checklist

| backend change | Frontend action |
|---|---|
| New endpoint | Add/update API client, type, query/mutation hook, error handling, tests |
| Request body change | Update form schema, validation, request mapper, test data |
| Response body change | Update type, table columns/detail view, empty/error handling |
| Error code change | Update error mapper and screen-specific message handling |
| Permission/action change | Update menu/action visibility and negative tests |
| State enum change | Update badges, filters, action enablement, state machine UI |
| Readiness/action change | Update Raw Lot screen, Lot Readiness queue, Material Issue picker, permission gating and error mapper |
| Public DTO change | Re-run denylist/whitelist tests and preview |

## 6. Public Trace UI Policy

Public trace UI must:

- Call only `/api/public/trace/{qrCode}`.
- Render only whitelisted fields from public response.
- Show safe invalid/not found/void/recalled messages.
- Never render supplier, personnel, cost, QC defect detail, loss, MISA/internal sync, private note.
- Not include admin-only links, object ids, or debugging payload in public page.

## 7. PWA/Internal App Notes

| concern | Rule |
|---|---|
| Offline submit | Queue command with idempotency key and device/session metadata |
| Replay | Same key + same payload must not double execute |
| Conflict | Same key + different payload shows clear operator resolution state |
| Scan | Scan value must be validated by backend; UI cannot infer state as truth |
| Stale state | Reload entity state before command if API returns state conflict |
| Lot readiness | Offline Mark Ready and Material Issue commands must carry idempotency key; sync order must apply readiness before issue for the same lot |

## 8. Frontend Done Gate

- Screen matches `ui/03_SCREEN_CATALOG.md`.
- API client matches `api/02_API_ENDPOINT_CATALOG.md`.
- Permission states and backend 403 behavior tested.
- Public trace denylist tested if touched.
- All changed screens have loading/empty/error/validation/stale states.
- UI tests in `testing/04_UI_TEST_PLAN.md` updated/run.
- Material issue UI test proves a lot with `qcStatus=QC_PASS` but `lotStatus != READY_FOR_PRODUCTION` is not selectable/issuable.
