# 08 - Regression Test Plan

## 1. Mục tiêu

Regression test plan xác định các test phải chạy lại sau mỗi phase/gap để tránh phá hard lock vận hành, API/UI contract, seed baseline, inventory ledger, trace/public policy, recall và MISA boundary.

## 2. Regression Tiers

| tier | Khi nào chạy | Nội dung |
|---|---|---|
| `REG-P0` | Mỗi PR/phase liên quan domain hoặc trước merge | Hard lock, API command P0, seed validation P0, smoke negative P0 |
| `REG-P1` | Trước release candidate | UI P0/P1, integration boundary, E2E happy path, public trace security |
| `REG-P2` | Trước go-live hoặc khi owner chốt NFR | Performance/backup/retention/observability/SLA tests |

## 3. Regression Test Cases

| test_id | module | scenario | precondition | steps | expected result | data required | priority | trigger | requirement_id |
|---|---|---|---|---|---|---|---|---|---|
| TC-REG-001 | M04 | Forbidden operational formula token remains blocked | Any change to recipe/seed/PO | Run TC-M04-REC-004 and TC-SEED-004 | No active/approved operational recipe/order uses forbidden token | Recipe/seed data | P0 | recipe, seed, production | REQ-M04-004 |
| TC-REG-002 | M04/M07 | G1 snapshot remains immutable | Any change to recipe/PO | Run TC-M04-REC-007, TC-INT-REC-001 | Existing PO snapshots unchanged after recipe change | PO snapshot fixture | P0 | recipe, production | REQ-M04-007 |
| TC-REG-003 | M08/M11 | Material issue still sole decrement | Any change to material/inventory | Run TC-M08-MI-001, TC-M08-MR-002, TC-INT-INV-001 | One raw debit at issue from lot `READY_FOR_PRODUCTION`; no receipt debit; no double retry debit | Issue/receipt fixture | P0 | material, inventory | REQ-M08-001, REQ-M08-002 |
| TC-REG-003B | M06/M08 | Material issue rejects `QC_PASS` lot not `READY_FOR_PRODUCTION` | Any change to raw lot/material issue state machine | Run TC-M06-RM-005, TC-API-M06-LOT-READY, TC-INT-LOT-READY | `QC_PASS` not-ready lot rejected; mark-ready lot issuable; audit/state log exists | Raw lot fixtures | P0 | raw lot, material, inventory | REQ-M06-004 |
| TC-REG-004 | M09/M11 | QC_PASS not treated as RELEASED | Any change to QC/release/warehouse | Run TC-M09-REL-002, TC-M11-WH-001 | Warehouse receipt blocked until explicit release | QC_PASS batch | P0 | qc, release, warehouse | REQ-M09-002, REQ-M11-001 |
| TC-REG-005 | M11 | Warehouse receipt only for released batch | Warehouse/release changes | Try receipt for non-released and released batch | Non-released reject; released pass | Batch fixtures | P0 | warehouse | REQ-M11-001 |
| TC-REG-006 | M12 | Public trace denylist remains enforced | Trace/public/API/UI changes | Run public trace API/UI tests | No supplier/personnel/cost/QC defect/loss/MISA/private fields | QR trace fixture | P0 | trace, public, security | REQ-M12-002 |
| TC-REG-007 | M10/M12 | QR VOID/FAILED cannot resolve public trace | QR/print/trace changes | Resolve void/failed QR public | Safe invalid/not public response, no internal reason | QR invalid states | P0 | qr, trace | REQ-M12-003 |
| TC-REG-008 | M14 | MISA missing mapping remains reconcile pending | MISA/outbox changes | Dispatch event missing mapping | Event retained; log + review/reconcile pending | Missing mapping event | P0 | misa, integration | REQ-M14-002 |
| TC-REG-009 | M04/NFR | Seed baseline remains complete and idempotent | Seed/migration changes | Run TC-SEED-001..013 twice | 20 SKU, ingredients, 4 groups, G1, no forbidden operational formula, idempotent | Full seed | P0 | seed, migration | REQ-NFR-004 |
| TC-REG-010 | M12/M13 | Trace-to-recall snapshot remains stable | Trace/recall changes | Run recall impact twice | Snapshot versioning; no overwrite | Trace + recall fixture | P0 | trace, recall | REQ-M13-002 |
| TC-REG-011 | M01/M02 | Permission and audit gates remain active | Auth/API/UI changes | Run protected action and audit tests | 403 for unauthorized; sensitive command has audit/state log | User fixtures | P0 | auth, audit | REQ-M01-001, REQ-M02-002 |
| TC-REG-012 | M10 | Reprint history remains append-only | Print/QR changes | Reprint with reason | Original print/QR history preserved; new history linked | Printed QR | P1 | print, qr | REQ-M10-004 |
| TC-REG-013 | M13/M11 | Recall hold/sale lock blocks downstream | Recall/inventory changes | Apply hold; attempt downstream action | Block/warn per policy; audit reason | Recall hold | P1 | recall, inventory | REQ-M13-003 |
| TC-REG-014 | M16 | UI action visibility stays permission-aware | UI/menu/RBAC changes | Run role-based UI tests | Actions match role and backend enforcement | Role fixtures | P1 | ui, auth | REQ-M16-001 |
| TC-REG-015 | All | Full E2E smoke still passes | Before release | Run TC-E2E-SMK-001..015 including `TC-E2E-SMK-002B`, and negative smoke including `TC-E2E-NEG-003B` | Full chain and hard lock negative pass | Smoke dataset | P0 | release | REQ-NFR-005 |

## 4. Regression Trigger Matrix

| Change area | Required regression |
|---|---|
| Recipe/SKU/seed | TC-REG-001, TC-REG-002, TC-REG-009, TC-E2E-NEG-001 |
| Production/order/snapshot | TC-REG-002, TC-REG-015 |
| Material issue/receipt/inventory | TC-REG-003, TC-REG-003B, TC-REG-011, TC-REG-015 |
| QC/release/warehouse | TC-REG-004, TC-REG-005, TC-REG-015 |
| Packaging/QR/printing | TC-REG-007, TC-REG-012, TC-REG-015 |
| Trace/public trace | TC-REG-006, TC-REG-007, TC-REG-010, TC-REG-015 |
| Recall | TC-REG-010, TC-REG-013, TC-REG-015 |
| MISA/outbox/integration | TC-REG-008, TC-REG-011, TC-REG-015 |
| Auth/RBAC/UI | TC-REG-011, TC-REG-014 |
| Migration/seed | TC-REG-001, TC-REG-009, TC-REG-015 |

## 5. Regression Evidence

| evidence | Required for |
|---|---|
| Test report with test_id and requirement_id | All regression runs |
| API response and correlation id | API/integration failures |
| Ledger movement ids | Inventory decrement/warehouse tests |
| Snapshot before/after diff | Recipe/PO snapshot tests |
| Public trace response key list | Public trace security tests |
| MISA sync log and reconcile status | MISA tests |
| Screenshot/video/trace | UI/E2E failures |

## 6. Release Blocking Rules

| rule | Blocking condition |
|---|---|
| REG-BLOCK-001 | Any `REG-P0` failure blocks merge/release unless owner signs explicit accepted risk and the failure is not a hard lock. |
| REG-BLOCK-002 | Hard lock failures for forbidden operational formula, G1 snapshot, raw lot `READY_FOR_PRODUCTION` gate, material decrement, release gate, public trace leakage, QR public eligibility, MISA missing mapping, or seed baseline cannot be waived for go-live. |
| REG-BLOCK-003 | Regression test without RTM mapping is incomplete and must be fixed before release report. |

## 7. Done Gate

- Every regression case maps to `REQ-*`.
- Hard lock tests are present in both matrix and regression pack.
- Trigger matrix tells QA which tests to run after each module change.
