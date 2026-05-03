# Spec Cleanup Scaffold Readiness - 2026-04-30

## Scope

Small cleanup pass before scaffold/code generation, limited to:

- `formula_kind` + CSV seed readiness.
- M03A supplier naming + supplier seed fixtures.
- M06 2-axis enum/routes.
- M04/supplier canonical route families.

## Decisions Applied

- M04 API family is canonical as `/api/admin/skus/*`, `/api/admin/ingredients/*`, `/api/admin/recipes/*`.
- Supplier admin family is canonical as `/api/admin/suppliers/*`.
- Supplier portal raw intake family is canonical as `/api/supplier/raw-material/intakes/*`.
- Supplier allowlist table name is canonical as `op_supplier_ingredient`.
- Supplier role code is canonical as `R-SUPPLIER`.
- M06 2-axis values follow `database/04_ENUM_REFERENCE.md`:
  - `supplier_collaboration_status`: `NOT_REQUIRED`, `PENDING_SUPPLIER_CONFIRMATION`, `EVIDENCE_REQUIRED`, `SUPPLIER_SUBMITTED`, `SUPPLIER_CONFIRMED`, `SUPPLIER_DECLINED`, `SUPPLIER_CANCELLED`.
  - `raw_receipt_status`: `DRAFT`, `WAITING_DELIVERY`, `DELIVERED_PENDING_RECEIPT`, `RECEIVED_PENDING_QC`, `QC_IN_PROGRESS`, `ACCEPTED`, `PARTIALLY_ACCEPTED`, `REJECTED`, `RETURNED`, `CANCELLED`, `CLOSED`.

## Seed Pack Changes

- `g1_recipe_headers.csv` now includes `formula_kind`, `anchor_ingredient_code`, `anchor_baseline_quantity`, `anchor_uom_code`, `anchor_ratio_percent`.
- `g1_recipe_lines.csv` now includes `formula_kind`, `is_anchor`; `ratio_percent` is normalized per recipe to SUM approximately 100.
- Anchor values are mechanically derived from the largest source quantity line per recipe and remain `owner_review_required=true`.
- Added M03A supplier seed files:
  - `suppliers.csv`
  - `supplier_users.csv`
  - `op_supplier_ingredient.csv`
- Updated `roles_permissions.csv`, `ui_registry_fixture.csv`, `event_schema_registry.csv`, `source_origin_fixture.csv`, and `seed_manifest.json`.

## Validation To Reuse

- Static CSV checks:
  - required recipe columns exist;
  - 20 headers, 433 lines;
  - exactly 1 anchor line per recipe;
  - `SUM(ratio_percent)` in `[99.95, 100.05]`;
  - manifest counts match CSV row counts.
- Static grep checks:
  - no `op_supplier_ingredient_allowed`;
  - no `/api/supplier/intakes`;
  - no old M06 enum values `NOT_APPLICABLE`, `PENDING_RECEIVE`, `COMPANY_ACKNOWLEDGED`, `COLLABORATION_CLOSED`.

## Remaining Risk

- G1 anchor choice is scaffold-ready but still owner-review data, not production formula approval.
- DB seed chain/database validation was not run in this pass; use the static checks until the local DB/toolchain blockers are cleared.
