# 05 - Seed Implementation Guide

## 1. Mục tiêu

Seed guide định nghĩa thứ tự và validation cho baseline vận hành: role/action, warehouse, 20 SKU, ingredient, G1 recipe, 4 recipe groups, public trace policy, event schema và MISA fixture an toàn.

## 2. Seed Order

| order | Seed group | Tables |
|---|---|---|
| 01 | UOM/reference | `ref_uom`, `ref_adjustment_reason`, base config |
| 02 | Auth/RBAC/action | `auth_role`, `auth_permission`, `role_action_permission`, action seed including `RAW_LOT_MARK_READY` |
| 03 | Warehouse/location | `op_warehouse`, `op_warehouse_location` |
| 04 | Recipe groups | `ref_recipe_line_group` |
| 05 | Ingredient master | `ref_ingredient`, `ref_ingredient_alias` |
| 06 | SKU baseline | `ref_sku`, `ref_sku_operational_config` |
| 07 | G1 recipe baseline | `op_production_recipe`, `op_recipe_ingredient` |
| 08 | Source/sample | `op_source_zone`, `op_source_origin` for dev/QA only |
| 09 | GTIN/packaging fixture | `op_trade_item`, `op_trade_item_gtin` with test fixture flag |
| 10 | Public trace policy | `op_public_trace_policy` |
| 11 | Event schema | `event_schema_registry` |
| 12 | MISA fixture | `misa_mapping`, secret references, no real credentials |
| 13 | UI registry | `ui_screen_registry`, `ui_action_registry`, `ui_menu_item` |
| 14 | Enum/reference status if catalog-backed | `lot_status` includes `READY_FOR_PRODUCTION`; no seed should equate `QC_PASS` with ready |

## 3. Seed Rules

| rule_id | Rule |
|---|---|
| SEED-RULE-001 | Seed must be idempotent by business key, not by generated id. |
| SEED-RULE-002 | 20 SKU is go-live baseline, not a permanent application cap. |
| SEED-RULE-003 | G1 is the active operational baseline for go-live. |
| SEED-RULE-004 | Future G2/G3/G4 must be created through versioning/approval workflow, not seed overwrite. |
| SEED-RULE-005 | Recipe lines must use exactly the 4 required group codes. |
| SEED-RULE-006 | Dev fixtures for GTIN/MISA/source must be marked test/dev and not presented as production truth. |
| SEED-RULE-007 | Seed validation must fail if any hard lock data is missing. |
| SEED-RULE-008 | If action/permission seed is used, `RAW_LOT_MARK_READY` must be seeded separately from raw QC sign and material issue execute. |

## 4. Required Seed Checks

| validation_id | Test case | Check |
|---|---|---|
| SV-001 | TC-SEED-001 | Active baseline SKU count = 20 |
| SV-002 | TC-SEED-002 | Required ingredients active |
| SV-003 | TC-SEED-003 | Recipe group seed has exactly 4 required groups |
| SV-004 | TC-SEED-004 | No active/approved operational formula uses forbidden baseline token |
| SV-005 | TC-SEED-005 | Each baseline SKU has one active G1 recipe |
| SV-006 | TC-SEED-006 | Each active G1 recipe has all 4 groups |
| SV-007 | TC-SEED-007 | At least one raw and one finished-goods warehouse active |
| SV-008 | TC-SEED-009 | Public trace denylist configured |
| SV-009 | TC-SEED-010 | MISA fixture safe and no real credential in seed |
| SV-010 | TC-SEED-013 | Running seed twice creates no duplicate rows |
| SV-011 | TC-SEED-014 | `RAW_LOT_MARK_READY` action/permission exists if RBAC is seed-backed |
| SV-012 | TC-SEED-015 | `lot_status` reference includes `READY_FOR_PRODUCTION` if enum/status values are seed-backed |

## 5. Seed Failure Policy

| failure | Action |
|---|---|
| Missing SKU baseline | Block CODE03 and smoke; fix seed before continuing |
| Missing required ingredient | Block G1 readiness and PO creation tests |
| Missing recipe group | Block recipe line/PO snapshot |
| Missing active G1 recipe | Block production order creation |
| Missing raw/FG warehouse | Block raw/warehouse smoke |
| Public trace policy missing | Fail closed; block public trace release |
| Missing `RAW_LOT_MARK_READY` action | Block CODE02/CODE03 because lot readiness and material issue permission gates cannot be validated |
| Missing `READY_FOR_PRODUCTION` lot status reference | Block CODE02/CODE03 if status enum/reference is seed-backed |
| MISA mapping missing | Allowed only for negative/reconcile test; event must become review/pending |
| Seed not idempotent | Block release/migration gate |

## 6. Seed Done Gate

- Seed script order documented.
- Seed can run twice without duplicate business keys.
- Seed validation output stored in handoff.
- Dev-only fixture flags visible.
- No secret value committed in seed.
- E2E smoke can create PO/material/warehouse/trace from seeded baseline.
