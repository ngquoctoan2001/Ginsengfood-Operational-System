# 03 - MX-GATE-G1 Master Data + Recipe Prompts

## Scope

`MX-GATE-G1` is a mandatory readiness gate before CODE03. It covers SKU, ingredient, UOM, recipe versioning, G1 seed, 4 recipe groups and future G2/G3+ readiness.

## Prompt 03.01 - MX-GATE-G1 Audit

```text
Role: Data/Domain Audit Agent.
Mission: Audit SKU/ingredient/recipe/config readiness before manufacturing. Do not edit files.
Read first: modules/04_SKU_INGREDIENT_RECIPE.md, modules/03_MASTER_DATA.md, data/, database/, api/, ui/, testing/07_SEED_VALIDATION_TEST_PLAN.md.
Rules:
- 20 SKU is go-live baseline, not permanent cap.
- G1 is active operational baseline, not only seed forever.
- Future G2/G3+ must be supported by CRUD/versioning.
- Recipe groups exactly SPECIAL_SKU_COMPONENT, NUTRITION_BASE, BROTH_EXTRACT, SEASONING_FLAVOR.
Đầu ra: readiness report, missing CRUD/versioning gaps, seed validation gaps, first gap recommendation, cập nhật tiến độ.
```

## Prompt 03.02 - SKU/Ingredient CRUD And Versioning Plan

```text
Role: Master Data Planner.
Mission: Plan long-term CRUD/versioning for SKU, ingredient, operational config and recipe source data.
Workflow:
1. Define ownership boundary: catalog/product owns SKU identity; operational owns recipe/version/config/snapshot tied to sku_id unless docs say otherwise.
2. Define DB/API/UI needs.
3. Define validation and tests.
4. Identify seed vs production master data separation.
Đầu ra: bounded implementation plan, write scope, non-goals, cập nhật tiến độ.
```

## Prompt 03.03 - Recipe Schema/Backend Implementation

```text
Role: Recipe Backend/DB Agent.
Mission: Implement approved recipe/version/schema gap {gap_id}.
Rules:
- Do not hard-code 20 SKU as permanent cap.
- Do not hard-code G1 as only version forever.
- Production snapshot must capture formula/version/group/ingredient/quantity/UOM/prep/usage role.
- Quantity basis 400 is not 400 kg unless owner later decides.
Workflow: implement schema/model/service/API, constraints, version lifecycle, tests.
Đầu ra: file đã sửa, migration, API impact, validation, cập nhật tiến độ.
```

## Prompt 03.04 - G1 Seed And Validation

```text
Role: Seed/Data Agent.
Mission: Implement/validate G1 seed chain and CSV fixtures.
Read first: data/01_SEED_DATA_CANONICAL.md, data/02_G1_RECIPE_LINE_MATRIX.md, data/03_INGREDIENT_MASTER_MATRIX.md, data/seed_manifest.json.
Rules:
- Seed idempotent by business key.
- Derived counts such as 433 lines must be marked derived validation, not canonical text if source did not state it.
- Required ingredients ING_MI_CHINH and HRB_SAM_SAVIGIN must exist.
Đầu ra: seed changes, manifest count check, lệnh kiểm chứng, idempotency evidence, cập nhật tiến độ.
```

## Prompt 03.05 - SKU/Recipe API Contract

```text
Role: API Contract Agent.
Mission: Implement/repair SKU, ingredient, recipe and config API contracts for CRUD and future versions.
Rules:
- Use API catalog route family; do not create parallel routes.
- Include create/update/approve/activate/retire/clone where spec requires.
- Backend and frontend DTOs must stay in sync.
Đầu ra: route/DTO changes, error/idempotency behavior, API tests, FE impact, cập nhật tiến độ.
```

## Prompt 03.06 - Master Data Admin UI

```text
Role: Frontend Agent.
Mission: Implement SKU, ingredient, recipe version and recipe line UI.
Rules:
- UI must support future SKU/recipe changes, not read-only seed forever.
- Show recipe groups clearly.
- Prevent editing active historical snapshot directly; use version workflow.
Đầu ra: API client/types/screens/forms/tables, UI tests, cập nhật tiến độ.
```

## Prompt 03.07 - MX-GATE-G1 Review And Close

```text
Role: QA/Reviewer Agent.
Mission: Decide if manufacturing can start.
Check: 20 SKU baseline, ingredients, UOM, G1 active formulas, 4 groups, future versioning, snapshot fields, seed validation, API/UI CRUD path.
Đầu ra: MX-GATE-G1 verdict PASS/PARTIAL/FAIL, blockers, accepted deferrals, next CODE03 prompt, cập nhật tiến độ.
```

