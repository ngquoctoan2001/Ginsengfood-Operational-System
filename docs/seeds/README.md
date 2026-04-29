# Seed SQL Ginsengfood V2

Trạng thái: active seed chain đã được rebuild từ canonical source packs cho lane `GFV2-GAP-MASTER-G1-SKU-INGREDIENT-RECIPE-CANONICAL`. `G1` là initial go-live baseline, không phải version ceiling. `G0` chỉ còn là research/baseline context và không nằm trong active operational seed chain.

## Active Run Order

Chạy các file SQL sau khi đã chạy EF migrations trên database local/dev. Active execution là non-recursive; không chạy file trong `docs/seeds/archive/`.

| Thứ tự | File                                     | Vai trò                                                                                                                                               |
| -----: | ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
|      1 | `00_views.sql`                           | Tạo lại Operational SQL views sau EF migration/squash.                                                                                                |
|      2 | `01_roles.sql`                           | Seed roles.                                                                                                                                           |
|      3 | `02_permissions.sql`                     | Seed permissions và role-permission assignments.                                                                                                      |
|      4 | `03_admin_user.sql`                      | Bootstrap admin user và role assignments.                                                                                                             |
|      5 | `04_ref_uom.sql`                         | Seed UOM dùng cho master/operational data.                                                                                                            |
|      6 | `05_ref_category.sql`                    | Seed categories không thuộc canonical SKU/recipe pack.                                                                                                |
|      7 | `06_ref_sku.sql`                         | Seed đúng 20 canonical SKU và SKU metadata columns.                                                                                                   |
|      8 | `08_op_raw_material.sql`                 | Seed canonical ingredient/raw-material master bằng `HRB_*` / `ING_*` và alias `MAT-*`.                                                                |
|      9 | `09_ref_recipe_line_group.sql`           | Seed bốn canonical G1 recipe line groups.                                                                                                             |
|     10 | `10_op_production_recipe_g1_headers.sql` | Seed 20 active G1 production recipe headers và retire active G0.                                                                                      |
|     11 | `11_op_recipe_ingredients_g1.sql`        | Seed 433 canonical G1 recipe ingredient lines.                                                                                                        |
|     12 | `12_op_sku_operational_config.sql`       | Seed per-SKU operational config trỏ active formula version `G1`.                                                                                      |
|     13 | `13_trade_item_qr_public_trace_misa.sql` | Seed scaffold trade item owner-pending, một `TEST_ONLY_DEV_FIXTURE` GTIN/map cho local validation, QR lifecycle, public trace policy và MISA mapping. |
|     14 | `14_ref_operational_event_types.sql`     | Seed operational event types.                                                                                                                         |
|     15 | `15_seed_validation.sql`                 | Chạy post-seed assertions cho canonical G1 go-live data.                                                                                              |

`07_ref_sku_metadata.sql`, G0 seed files và old G1/MAT seed files đã bị loại khỏi active chain và lưu tại `docs/seeds/archive/` với suffix `.disabled`.

## Local Commands

Thiết lập password local qua environment variable; không commit credential thật vào docs.

```powershell
$env:PGPASSWORD = "<local password>"
```

Chạy active seed chain:

```powershell
Get-ChildItem docs/seeds -Filter "*.sql" |
  Sort-Object Name |
  ForEach-Object {
    & "C:\Program Files\PostgreSQL\18\bin\psql.exe" `
      -h localhost `
      -p 5432 `
      -U postgres `
      -d ginsengfood_operational `
      -v ON_ERROR_STOP=1 `
      -f $_.FullName
  }
```

Chạy lại chain lần hai khi kiểm tra idempotency.

Chạy validation riêng:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" `
  -h localhost `
  -p 5432 `
  -U postgres `
  -d ginsengfood_operational `
  -v ON_ERROR_STOP=1 `
  -f docs/seeds/15_seed_validation.sql
```

## Canonical Source Packs

| File nguồn                                                                                    | Dữ liệu canonical                                                          |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `docs/ginsengfood_sku_recipe_md_pack/01_SKU_CANONICAL_MASTER_GINSENGFOOD.md`                  | 20 canonical SKU master.                                                   |
| `docs/ginsengfood_sku_recipe_md_pack/02_INGREDIENT_CANONICAL_MASTER_GINSENGFOOD.md`           | Ingredient master, canonical `HRB_*` / `ING_*` identity.                   |
| `docs/ginsengfood_sku_recipe_md_pack/03_RECIPE_VERSIONING_AND_GOVERNANCE_GINSENGFOOD.md`      | Formula lifecycle, approval, activation, source-of-truth và snapshot rule. |
| `docs/ginsengfood_sku_recipe_md_pack/04_RECIPE_G1_OPERATIONAL_20SKU_GINSENGFOOD.md`           | G1 operational recipes, four canonical line groups và quantities.          |
| `docs/ginsengfood_sku_recipe_md_pack/05_RECIPE_G0_RESEARCH_BASELINE_20SKU_GINSENGFOOD.md`     | G0 historical/research context only.                                       |
| `docs/ginsengfood_sku_recipe_md_pack/07_SEED_DATA_SPEC_SKU_INGREDIENT_RECIPE_GINSENGFOOD.md`  | Seed data spec và expected validation counts.                              |
| `docs/ginsengfood_sku_recipe_md_pack/08_CONFLICT_REPORT_SKU_RECIPE_INGREDIENT_GINSENGFOOD.md` | Conflict decisions cho SKU/ingredient/recipe.                              |
| `docs/ginsengfood_final_pack_md/02_MASTER_DATA_RULE_PACK_FILE02.md`                           | Master-data rules và owner boundaries.                                     |
| `docs/ginsengfood_final_pack_md/11_SEED_MIGRATION_ROUTE_TEST_MATRIX.md`                       | Migration/seed/test matrix.                                                |
| `docs/ginsengfood_forms_operational_md_pack/06_PRINT_CODE_AND_TRACE_RULES_GINSENGFOOD.md`     | Print/QR/public trace rules.                                               |
| `docs/ginsengfood_forms_operational_md_pack/07_ACCOUNTING_MISA_BOUNDARY_GINSENGFOOD.md`       | MISA integration boundary.                                                 |

## Validation Counts

`15_seed_validation.sql` phải fail nếu bất kỳ assertion nào không đúng.

| Assertion                                                                   |   Expected |
| --------------------------------------------------------------------------- | ---------: |
| `ref_sku` active rows                                                       |         20 |
| Canonical ingredient master rows                                            |         46 |
| Active source-of-truth G1 recipe headers                                    |         20 |
| Active G1 recipe lines                                                      |        433 |
| Active operational G0 recipes/configs                                       |          0 |
| SKU operational config trỏ G1                                               |         20 |
| `SPECIAL_SKU_COMPONENT` lines                                               |        114 |
| `NUTRITION_BASE` lines                                                      |         99 |
| `BROTH_EXTRACT` lines                                                       |        100 |
| `SEASONING_FLAVOR` lines                                                    |        120 |
| `HRB_SAM_SAVIGIN` 9.00 kg trong G1                                          | 20 recipes |
| `ING_MI_CHINH` 1.90 kg trong G1                                             | 20 recipes |
| `FML-B4-G1` có `ING_THIT_HEO_NAC` 10.50 kg                                  |      1 row |
| Active bad legacy row `MAT-SAM-SAVIGIN` map tới Ky tu                       |          0 |
| G1 recipe ingredient không resolve tới ingredient master                    |          0 |
| QR registry canonical states                                                |          6 |
| Public trace allowed field policy groups                                    |          5 |
| Public trace blocked sensitive field policy groups                          |          5 |
| MISA document mapping scaffold rows                                         |          3 |
| Owner-pending INACTIVE `op_trade_item` PACKET rows (1 / SKU)                |         20 |
| Owner-pending INACTIVE `op_trade_item` BOX rows (1 / SKU)                   |         20 |
| `op_trade_item` CARTON rows seed (owner enable when GS1 ready)              |          0 |
| INACTIVE INTERNAL_BARCODE placeholder `op_trade_item_gtin` (1 / trade item) |         40 |
| ACTIVE `op_trade_item_gtin` identifiers từ seed                             |          0 |

## Owner Decisions

| Decision           | Trạng thái                                                                                                                                                                                                 |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ING_THIT_HEO_NAC` | Khóa là ingredient riêng vì `FML-B4-G1` issue theo lot với quantity 10.50 kg; ingredient master expected count là 46.                                                                                      |
| Legacy `MAT-*`     | Không dùng làm business truth; seed canonical `ingredient_code` bằng `HRB_*` / `ING_*`, giữ `MAT-*` trong `op_raw_material_alias` với `alias_type` như `LEGACY_CODE`, `DISPLAY_NAME`, `PROCUREMENT_ALIAS`. |
| G0 seed files      | Không nằm trong active run chain; giữ dưới `docs/seeds/archive/*.disabled` để audit historical context.                                                                                                    |
| Seed numbering     | Không renumber để giảm churn; `15_seed_validation.sql` là validation gate.                                                                                                                                 |
| GTIN/GS1           | Chưa có owner-approved production values; seed tạo 40 INACTIVE `op_trade_item` (20 PACKET + 20 BOX) và 40 INACTIVE INTERNAL_BARCODE placeholder `op_trade_item_gtin` (`identifier_value = 'PENDING-'       |     | trade_item_code`). Owner phê duyệt GTIN thật sẽ UPDATE `identifier_type='GTIN_13'/'GTIN_14'/'SSCC'`, `identifier_value`và set`status='ACTIVE'`. CARTON trade item phải được owner enable thủ công (set `carton_enabled=true`+`boxes_per_carton`); không seed CARTON. Tên bảng `op_trade_item_gtin`V2 locked theo ADR-025; rename V3 →`op_trade_item_identifier`. |

## Remaining Risks Fix Validation Status

| Gate                               | Kết quả gần nhất                                                                                              |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Backup/drop/create local DB        | Pass; backup file `.local/db-backups/ginsengfood_operational_before_remaining_risk_fix_20260425_210629.dump`. |
| EF database update                 | Pass với `dotnet ef database update ... --no-build` trên DB sạch `ginsengfood_operational`.                   |
| Seed chain                         | Pass hai lần theo sorted active order.                                                                        |
| Seed validation                    | Pass với `canonical seed validation passed`; `TEST_ONLY_DEV_FIXTURE` GTIN/map = 1/1.                          |
| Backend build                      | Pass, `0` warnings, `0` errors.                                                                               |
| Focused IntegrationTests GTIN/MISA | Pass `4/4`.                                                                                                   |
| Unit tests                         | Pass `337/337`.                                                                                               |
| API tests                          | Pass `262/262`.                                                                                               |
| Admin build                        | Pass; còn Vite large chunk warning.                                                                           |
| Admin smoke/e2e                    | Blocked ngay bởi `Error: spawn EPERM`; cần chạy lại khi môi trường cho phép spawn Playwright worker.          |

## Notes And Risks

- Destructive DB reset đã chạy cho local/dev `ginsengfood_operational` sau owner decision; không dùng flow này cho môi trường ngoài local/dev.
- `TEST_ONLY_DEV_FIXTURE` GTIN/map chỉ phục vụ validation; production vẫn cần owner-approved GTIN/GS1 và packaging trade item data.
- Active seed generator `docs/seeds/generate_canonical_seeds.js` phụ thuộc format hiện tại của source packs; nếu pack đổi table format, update generator trước khi chạy lại.
- Các row legacy `MAT-*` trong môi trường có dữ liệu thật cần rà raw material lots/receipts trước khi migrate lịch sử sang canonical material IDs.
