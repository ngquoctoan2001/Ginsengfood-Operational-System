# 04 - Seed Validation Queries

## Mục Lục

- [1. Mục đích](#1-mục-đích)
- [2. Cách dùng](#2-cách-dùng)
- [3. Validation SQL](#3-validation-sql)
- [4. CSV pre-import checks](#4-csv-pre-import-checks)
- [5. Done gate](#5-done-gate)

## 1. Mục Đích

Tài liệu này biến seed validation plan thành các query/check có thể đưa vào migration test hoặc seed test.

Các SQL dưới đây giả định PostgreSQL và tên bảng/cột theo `database/03_TABLE_SPECIFICATION.md`. Khi implementation khác tên cột vật lý, dev phải cập nhật query tương ứng nhưng giữ nguyên intent. CSV pre-import phải đọc file bằng `UTF-8`.

## 2. Cách Dùng

1. Chạy seed theo thứ tự trong `01_SEED_DATA_CANONICAL.md`.
2. Chạy validation query trong transaction read-only nếu môi trường hỗ trợ.
3. Nếu bất kỳ query trả về row lỗi hoặc `RAISE EXCEPTION`, seed gate fail.
4. Chạy seed lần hai rồi chạy lại validation để xác nhận idempotency.

## 3. Validation SQL

### SV-001 - Active baseline SKU count phải bằng 20

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(*) INTO v_count
  FROM ref_sku
  WHERE status = 'ACTIVE_BASELINE';

  IF v_count <> 20 THEN
    RAISE EXCEPTION 'SV-001 failed: expected 20 active baseline SKU, got %', v_count;
  END IF;
END $$;
```

### SV-002 - Không có operational formula ngoài G1 trong baseline seed

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(*) INTO v_count
  FROM op_production_recipe
  WHERE formula_status IN ('ACTIVE_OPERATIONAL', 'APPROVED_SEED_BASELINE')
    AND formula_version <> 'G1';

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'SV-002 failed: active operational baseline must be G1 only, got % invalid rows', v_count;
  END IF;
END $$;
```

### SV-003 - Mỗi baseline SKU có đúng một active G1

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(*) INTO v_count
  FROM (
    SELECT s.sku_code, count(r.recipe_id) AS active_g1_count
    FROM ref_sku s
    LEFT JOIN op_production_recipe r
      ON r.sku_id = s.sku_id
     AND r.formula_version = 'G1'
     AND r.formula_status = 'ACTIVE_OPERATIONAL'
    WHERE s.status = 'ACTIVE_BASELINE'
    GROUP BY s.sku_code
    HAVING count(r.recipe_id) <> 1
  ) x;

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'SV-003 failed: some baseline SKU do not have exactly one active G1 recipe';
  END IF;
END $$;
```

### SV-004 - Mỗi active G1 có đủ 4 recipe groups

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(*) INTO v_count
  FROM (
    SELECT r.recipe_id
    FROM op_production_recipe r
    JOIN op_recipe_ingredient ri ON ri.recipe_id = r.recipe_id
    WHERE r.formula_version = 'G1'
      AND r.formula_status = 'ACTIVE_OPERATIONAL'
    GROUP BY r.recipe_id
    HAVING count(DISTINCT ri.group_code) <> 4
  ) x;

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'SV-004 failed: some active G1 recipes do not have exactly four groups';
  END IF;
END $$;
```

### SV-005 - Required ingredients tồn tại và active

```sql
DO $$
DECLARE v_missing text;
BEGIN
  SELECT string_agg(code, ', ') INTO v_missing
  FROM (
    VALUES ('HRB_SAM_SAVIGIN'), ('ING_MI_CHINH'), ('ING_THIT_HEO_NAC')
  ) required(code)
  LEFT JOIN ref_ingredient i
    ON i.ingredient_code = required.code
   AND i.ingredient_status = 'ACTIVE'
  WHERE i.ingredient_id IS NULL;

  IF v_missing IS NOT NULL THEN
    RAISE EXCEPTION 'SV-005 failed: missing required active ingredients: %', v_missing;
  END IF;
END $$;
```

### SV-006 - Có tối thiểu một kho raw và một kho thành phẩm active

```sql
DO $$
DECLARE v_raw int;
DECLARE v_fg int;
BEGIN
  SELECT count(*) INTO v_raw FROM op_warehouse WHERE warehouse_type = 'RAW_MATERIAL' AND status = 'ACTIVE';
  SELECT count(*) INTO v_fg FROM op_warehouse WHERE warehouse_type = 'FINISHED_GOODS' AND status = 'ACTIVE';

  IF v_raw < 1 OR v_fg < 1 THEN
    RAISE EXCEPTION 'SV-006 failed: need at least one active RAW_MATERIAL and one active FINISHED_GOODS warehouse';
  END IF;
END $$;
```

### SV-007 - Public trace denylist bắt buộc

```sql
DO $$
DECLARE v_missing int;
BEGIN
  SELECT count(*) INTO v_missing
  FROM (
    VALUES
      ('supplier_id'),
      ('supplier_name'),
      ('operator_user_id'),
      ('qc_defect_detail'),
      ('loss_quantity'),
      ('cost_amount'),
      ('misa_external_id'),
      ('internal_batch_id'),
      ('raw_material_lot_internal_code')
  ) denied(field_code)
  LEFT JOIN op_public_trace_policy p
    ON p.field_code = denied.field_code
   AND p.is_public = false
   AND p.policy_status = 'ACTIVE'
  WHERE p.public_trace_policy_id IS NULL;

  IF v_missing <> 0 THEN
    RAISE EXCEPTION 'SV-007 failed: required public trace deny fields are missing';
  END IF;
END $$;
```

### SV-008 - Recipe line quantity hợp lệ

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(*) INTO v_count
  FROM op_recipe_ingredient
  WHERE quantity_per_batch_400 <= 0;

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'SV-008 failed: recipe line quantity must be > 0';
  END IF;
END $$;
```

### SV-009 - MISA fixture không chứa credential thật

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(*) INTO v_count
  FROM misa_mapping
  WHERE mapping_status LIKE '%DEV_FIXTURE%'
    AND coalesce(mapping_payload::text, '') ~* '(password|secret|token|client_secret)';

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'SV-009 failed: MISA fixture must not contain real credentials or secrets';
  END IF;
END $$;
```

### SV-010 - Idempotency duplicate key check

```sql
-- Các query này phải trả về 0 dòng.

SELECT sku_code, count(*)
FROM ref_sku
GROUP BY sku_code
HAVING count(*) > 1;

SELECT ingredient_code, count(*)
FROM ref_ingredient
GROUP BY ingredient_code
HAVING count(*) > 1;

SELECT sku_id, formula_version, count(*)
FROM op_production_recipe
GROUP BY sku_id, formula_version
HAVING count(*) > 1;

SELECT warehouse_code, count(*)
FROM op_warehouse
GROUP BY warehouse_code
HAVING count(*) > 1;

SELECT field_code, count(*)
FROM op_public_trace_policy
WHERE policy_status = 'ACTIVE'
GROUP BY field_code
HAVING count(*) > 1;

SELECT uom_code, count(*)
FROM ref_uom
GROUP BY uom_code
HAVING count(*) > 1;

SELECT event_type, event_version, count(*)
FROM event_schema_registry
GROUP BY event_type, event_version
HAVING count(*) > 1;

SELECT screen_id, count(*)
FROM ui_screen_registry
GROUP BY screen_id
HAVING count(*) > 1;

SELECT gtin, count(*)
FROM op_trade_item_gtin
GROUP BY gtin
HAVING count(*) > 1;

SELECT supplier_code, count(*)
FROM op_supplier
GROUP BY supplier_code
HAVING count(*) > 1;

SELECT source_zone_code, count(*)
FROM op_source_zone
GROUP BY source_zone_code
HAVING count(*) > 1;

SELECT origin_code, count(*)
FROM op_source_origin
GROUP BY origin_code
HAVING count(*) > 1;
```

### SV-011 - Required UOM list phải đầy đủ

```sql
DO $$
DECLARE v_missing text;
BEGIN
  SELECT string_agg(code, ', ') INTO v_missing
  FROM (
    VALUES ('kg'), ('g'), ('lít'), ('ml'), ('khay'), ('gói'), ('lọ'), ('hũ'), ('hộp'), ('thùng'), ('%')
  ) required(code)
  LEFT JOIN ref_uom u
    ON u.uom_code = required.code
   AND u.status = 'ACTIVE'
  WHERE u.uom_code IS NULL;

  IF v_missing IS NOT NULL THEN
    RAISE EXCEPTION 'SV-011 failed: missing required active UOM: %', v_missing;
  END IF;
END $$;
```

### SV-012 - GTIN fixture phải là test fixture

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(*) INTO v_count
  FROM op_trade_item_gtin
  WHERE status = 'ACTIVE_DEV_FIXTURE'
    AND is_test_fixture IS DISTINCT FROM true;

  IF v_count <> 0 THEN
    RAISE EXCEPTION 'SV-012 failed: every active dev GTIN fixture must have is_test_fixture=true';
  END IF;
END $$;
```

### SV-013 - Event schema registry có event baseline

```sql
DO $$
DECLARE v_missing text;
BEGIN
  SELECT string_agg(event_type, ', ') INTO v_missing
  FROM (
    VALUES
      ('SOURCE_ORIGIN_VERIFIED'),
      ('RAW_MATERIAL_RECEIVED'),
      ('RAW_QC_SIGNED'),
      ('RAW_LOT_READY_FOR_PRODUCTION'),
      ('PRODUCTION_ORDER_APPROVED'),
      ('MATERIAL_ISSUE_EXECUTED'),
      ('MATERIAL_RECEIPT_CONFIRMED'),
      ('PRODUCTION_PROCESS_EVENT_RECORDED'),
      ('BATCH_RELEASED'),
      ('FINISHED_GOODS_RECEIPT_CONFIRMED'),
      ('RECALL_CASE_OPENED'),
      ('MISA_SYNC_REQUESTED')
  ) required(event_type)
  LEFT JOIN event_schema_registry e
    ON e.event_type = required.event_type
   AND e.event_version = 'v1'
   AND e.is_active = true
  WHERE e.event_type IS NULL;

  IF v_missing IS NOT NULL THEN
    RAISE EXCEPTION 'SV-013 failed: missing required event schema: %', v_missing;
  END IF;
END $$;
```

### SV-014 - UI registry cover M01-M16

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(DISTINCT module_code) INTO v_count
  FROM ui_screen_registry
  WHERE status = 'ACTIVE'
    AND module_code BETWEEN 'M01' AND 'M16';

  IF v_count <> 16 THEN
    RAISE EXCEPTION 'SV-014 failed: expected active UI screens for M01-M16, got % modules', v_count;
  END IF;
END $$;
```

### SV-015 - Source/procurement fixture cover SELF_GROWN và PURCHASED

```sql
DO $$
DECLARE v_self_grown int;
DECLARE v_purchased int;
BEGIN
  SELECT count(*) INTO v_self_grown
  FROM op_source_origin
  WHERE origin_code = 'SRC_ORIGIN_SMOKE_001'
    AND verification_status = 'VERIFIED'
    AND status = 'ACTIVE';

  SELECT count(*) INTO v_purchased
  FROM op_supplier
  WHERE supplier_code = 'SUP_SMOKE_001'
    AND status = 'ACTIVE';

  IF v_self_grown <> 1 OR v_purchased <> 1 THEN
    RAISE EXCEPTION 'SV-015 failed: source/procurement fixture must cover one VERIFIED SELF_GROWN origin and one PURCHASED supplier';
  END IF;
END $$;
```

### SV-016 - Raw lot status supports READY_FOR_PRODUCTION

```sql
DO $$
DECLARE v_ready int;
DECLARE v_qc_as_lot int;
BEGIN
  IF to_regclass('ref_lot_status') IS NOT NULL THEN
    EXECUTE
      'SELECT count(*) FROM ref_lot_status WHERE lot_status_code = $1 AND is_active = true'
      INTO v_ready
      USING 'READY_FOR_PRODUCTION';

    EXECUTE
      'SELECT count(*) FROM ref_lot_status WHERE lot_status_code = $1 AND is_active = true'
      INTO v_qc_as_lot
      USING 'QC_PASS';
  ELSE
    SELECT count(*) INTO v_ready
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    WHERE t.relname = 'op_raw_material_lot'
      AND pg_get_constraintdef(c.oid) LIKE '%READY_FOR_PRODUCTION%';

    SELECT count(*) INTO v_qc_as_lot
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    WHERE t.relname = 'op_raw_material_lot'
      AND pg_get_constraintdef(c.oid) LIKE '%QC_PASS%'
      AND pg_get_constraintdef(c.oid) LIKE '%lot_status%';
  END IF;

  IF v_ready <> 1 OR v_qc_as_lot <> 0 THEN
    RAISE EXCEPTION 'SV-016 failed: lot_status must include READY_FOR_PRODUCTION and must not treat QC_PASS as lot_status';
  END IF;
END $$;
```

### SV-017 - Role permissions include RAW_LOT_MARK_READY

```sql
DO $$
DECLARE v_missing text;
BEGIN
  SELECT string_agg(role_code, ', ') INTO v_missing
  FROM (
    VALUES ('R-QA-REL'), ('R-OPS-MGR')
  ) required(role_code)
  LEFT JOIN auth_role r
    ON r.role_code = required.role_code
  LEFT JOIN role_action_permission rap
    ON rap.role_id = r.role_id
   AND rap.is_allowed = true
  LEFT JOIN auth_permission p
    ON p.permission_id = rap.permission_id
   AND p.action_code = 'RAW_LOT_MARK_READY'
  WHERE p.permission_id IS NULL;

  IF v_missing IS NOT NULL THEN
    RAISE EXCEPTION 'SV-017 failed: missing RAW_LOT_MARK_READY permission for roles: %', v_missing;
  END IF;
END $$;
```

### SV-018 - UI registry exposes M06 mark-ready action

```sql
DO $$
DECLARE v_count int;
BEGIN
  SELECT count(*) INTO v_count
  FROM ui_screen_registry
  WHERE module_code = 'M06'
    AND status = 'ACTIVE'
    AND required_permission LIKE '%RAW_LOT_MARK_READY%';

  IF v_count < 1 THEN
    RAISE EXCEPTION 'SV-018 failed: M06 UI registry must expose RAW_LOT_MARK_READY';
  END IF;
END $$;
```

## 4. CSV Pre-Import Checks

Nếu seed loader đọc CSV trước khi insert DB, phải check:

| check_id | file | expected |
|---|---|---|
| CSV-001 | `skus.csv` | 20 rows and column `is_advisory_enabled` present |
| CSV-002 | `g1_recipe_headers.csv` | 20 rows |
| CSV-003 | `g1_recipe_lines.csv` | 433 rows |
| CSV-004 | `ingredients.csv` | 52 rows |
| CSV-005 | `recipe_groups.csv` | 4 rows |
| CSV-006 | `g1_recipe_lines.csv.group_code` | chỉ 4 group chuẩn |
| CSV-007 | `g1_recipe_lines.csv.quantity_per_batch_400` | numeric và `> 0` |
| CSV-008 | `g1_recipe_lines.csv.ingredient_code` | tồn tại trong `ingredients.csv` |
| CSV-009 | `uom.csv` | 11 rows, required list present |
| CSV-010 | `source_origin_fixture.csv` | có `SELF_GROWN` verified và `PURCHASED` supplier path |
| CSV-011 | `gtin_fixture.csv` | 40 rows, toàn bộ `is_test_fixture = true` |
| CSV-012 | `event_schema_registry.csv` | required event baseline present, including `RAW_LOT_READY_FOR_PRODUCTION` |
| CSV-013 | `ui_registry_fixture.csv` | cover đủ module `M01` đến `M16`; M06 includes `RAW_LOT_MARK_READY` |
| CSV-014 | all CSV | đọc bằng `UTF-8`, không mojibake tên tiếng Việt |
| CSV-015 | `roles_permissions.csv` | `RAW_LOT_MARK_READY` allowed for `R-QA-REL` and `R-OPS-MGR` |

## 5. Done Gate

- Seed chạy lần 1 thành công.
- Seed chạy lần 2 không tạo duplicate.
- Tất cả SV-001 đến SV-018 pass.
- CSV pre-import checks pass.
- Seed validation output được lưu trong handoff khi bắt đầu coding phase seed/migration.
