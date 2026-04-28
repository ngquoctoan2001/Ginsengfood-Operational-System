# 07 - Seed Validation Test Plan

## 1. Mục tiêu

Seed validation đảm bảo baseline vận hành có đủ dữ liệu tối thiểu, chạy idempotent, không tạo dữ liệu vận hành trái hard lock và có thể làm nền cho API/UI/E2E smoke.

Nguồn seed tham chiếu: [database/07_SEED_DATA_SPECIFICATION.md](../database/07_SEED_DATA_SPECIFICATION.md), RTM REQ-NFR-004, các requirement M03/M04/M11/M12/M14/M16.

## 2. Seed Validation Principles

| principle_id | Principle |
|---|---|
| SVP-001 | Seed chạy lại không tạo duplicate row hoặc thay đổi key nghiệp vụ đã có. |
| SVP-002 | G1 là baseline vận hành ban đầu; token forbidden `G0` chỉ được dùng trong negative validation, không seed active/approved operational formula. |
| SVP-003 | Seed validation fail fast nếu thiếu hard lock data: 20 SKU, required ingredients, 4 recipe groups, active G1 recipe. |
| SVP-004 | Fixture dev như GTIN/MISA credential phải có flag rõ, không giả làm dữ liệu thật. |

## 3. Seed Validation Test Cases

| test_id | module | scenario | precondition | steps | expected result | data required | priority | requirement_id |
|---|---|---|---|---|---|---|---|---|
| TC-SEED-001 | M04 | Active baseline SKU count equals 20 | Seed chain đã chạy | Count active baseline SKU in `ref_sku` | Count = 20; SKU codes unique | SKU seed | P0 | REQ-M04-001 |
| TC-SEED-002 | M04 | Required ingredient codes active | Seed chain đã chạy | Query `ref_ingredient` for required codes | `HRB_SAM_SAVIGIN`, `ING_MI_CHINH`, `ING_THIT_HEO_NAC` exist and active | Ingredient seed | P0 | REQ-M04-003 |
| TC-SEED-003 | M04 | Recipe group seed has exactly 4 groups and stable sort order | Seed chain đã chạy | Query `ref_recipe_line_group` for code + sort_order | Exactly required 4 groups in canonical order with sort_order `10/20/30/40` | Recipe group seed | P0 | REQ-M04-005 |
| TC-SEED-004 | M04 | No active/approved operational formula uses forbidden token | Seed chain đã chạy | Query operational recipe table for `formula_version='G0'` and active/approved status | Zero rows; validation fails if any found | Recipe seed | P0 | REQ-M04-004, REQ-NFR-004 |
| TC-SEED-005 | M04 | Each baseline SKU has one active G1 recipe | Seed chain đã chạy | Join `ref_sku` to `op_production_recipe` | Each of 20 SKU has one `ACTIVE_OPERATIONAL` G1 recipe | SKU + recipe seed | P0 | REQ-M04-006 |
| TC-SEED-006 | M04 | Each G1 recipe has all 4 groups | TC-SEED-005 pass | Query recipe lines grouped by recipe | Every active G1 recipe has lines in all required group codes | Recipe line seed | P0 | REQ-M04-005 |
| TC-SEED-007 | M03/M11 | Warehouse baseline has raw and FG warehouse | Seed chain đã chạy | Query `op_warehouse` by type | At least one active `RAW_MATERIAL`, one active `FINISHED_GOODS` | Warehouse seed | P0 | REQ-M03-002 |
| TC-SEED-008 | M02/M16 | Role/action/UI seed supports protected workflows | Seed chain đã chạy | Query roles, actions, screen/menu registry | Required role/action/screen entries exist for M01-M16 P0 flows | RBAC/UI seed | P1 | REQ-M02-002, REQ-M16-001 |
| TC-SEED-009 | M12 | Public trace policy has explicit denylist | Seed chain đã chạy | Query public trace policy | Deny supplier/personnel/cost/QC defect/loss/MISA/private fields; allowlist exists | Public policy seed | P0 | REQ-M12-002 |
| TC-SEED-010 | M14 | MISA fixture mapping/secret refs are safe | Seed chain đã chạy | Query `misa_mapping` and secret refs | Dev fixture marked test/dev; no real credential in seed docs/data | MISA fixture | P1 | REQ-M14-003 |
| TC-SEED-011 | M10 | GTIN fixture marked test-only | Seed chain đã chạy | Query trade item/GTIN fixture | Fixture GTIN has `is_test_fixture=true` or equivalent flag | GTIN fixture | P1 | REQ-M10-002 |
| TC-SEED-012 | M01 | Event schema registry has required events | Seed chain đã chạy | Query event schema registry | Event types for issue, release, warehouse, trace, recall, MISA exist | Event seed | P1 | REQ-M01-003 |
| TC-SEED-013 | M01/M04 | Seed idempotency | Clean QA DB seeded once | Run seed chain second time; compare counts/keys/checksums | No duplicate rows; stable business keys; no destructive overwrite of approved/audit data | Full seed chain | P0 | REQ-NFR-004 |
| TC-SEED-014 | M04/M07 | Seed supports PO smoke | TC-SEED-001..006 pass | Create PO for one baseline SKU | PO can snapshot G1 without missing ingredient/group/UOM | Seeded SKU/recipe | P0 | REQ-NFR-005 |
| TC-SEED-015 | M06/M08 | Raw lot status supports production readiness gate | Seed/ref enum initialized | Query raw lot status enum/state machine config | `PENDING_QC`, `QC_PASS`, `QC_HOLD`, `QC_REJECT`, `READY_FOR_PRODUCTION` exist or implementation state machine supports them; no ambiguous `READY` alias | Raw lot status enum/config | P0 | REQ-M06-004 |

## 4. Suggested Validation Queries

> Các query dưới đây là pseudo-SQL contract. DBA/dev cần chuyển thành dialect thật theo database implementation.

```sql
-- SV-001: active baseline SKU count
SELECT COUNT(*) AS active_baseline_sku_count
FROM ref_sku
WHERE is_baseline = true AND active = true;
```

```sql
-- SV-002: no forbidden operational formula token
SELECT COUNT(*) AS forbidden_operational_formula_count
FROM op_production_recipe
WHERE formula_version = 'G0'
  AND status IN ('APPROVED', 'ACTIVE_OPERATIONAL');
```

```sql
-- SV-003: required recipe groups and canonical sort order
SELECT group_code, sort_order
FROM ref_recipe_line_group
WHERE group_code IN (
  'SPECIAL_SKU_COMPONENT',
  'NUTRITION_BASE',
  'BROTH_EXTRACT',
  'SEASONING_FLAVOR'
)
ORDER BY sort_order;
-- Expected rows:
-- SPECIAL_SKU_COMPONENT = 10
-- NUTRITION_BASE = 20
-- BROTH_EXTRACT = 30
-- SEASONING_FLAVOR = 40
```

```sql
-- SV-004: required ingredients
SELECT ingredient_code
FROM ref_ingredient
WHERE ingredient_code IN ('HRB_SAM_SAVIGIN', 'ING_MI_CHINH', 'ING_THIT_HEO_NAC')
  AND active = true;
```

```sql
-- SV-005: warehouse minimum
SELECT warehouse_type, COUNT(*) AS active_count
FROM op_warehouse
WHERE active = true
GROUP BY warehouse_type;
```

```sql
-- SV-006: public trace denylist configured
SELECT field_code, exposure_policy
FROM op_public_trace_policy
WHERE field_code IN ('supplier', 'personnel', 'cost', 'qc_defect', 'loss', 'misa', 'private_note');
```

```sql
-- SV-007: raw lot readiness statuses
SELECT status_code
FROM ref_lot_status
WHERE status_code IN (
  'PENDING_QC',
  'QC_PASS',
  'QC_HOLD',
  'QC_REJECT',
  'READY_FOR_PRODUCTION'
);
```

## 5. Seed Failure Handling

| failure | Expected handling |
|---|---|
| Missing 20 SKU | Block smoke and release; fix seed/source before continuing. |
| Any active/approved operational forbidden formula token | Block release immediately; remove/repair seed and audit impact. |
| Missing 4 recipe groups | Block recipe/PO tests. |
| Missing recipe group sort_order 10/20/30/40 | Block recipe display, snapshot ordering, and seed release gate. |
| Missing `READY_FOR_PRODUCTION` lot status/state | Block raw material issue, integration, and E2E smoke. |
| Missing required ingredient | Block G1 readiness and PO smoke. |
| Missing raw/FG warehouse | Block intake/issue/warehouse smoke. |
| Seed not idempotent | Block migration/seed release gate. |

## 6. Done Gate

- TC-SEED-001..007, TC-SEED-013, and TC-SEED-015 are P0 release-blocking.
- Seed validation output must be attached to E2E smoke evidence.
- Test matrix maps TC-SEED cases back to RTM via `requirement_id`.
