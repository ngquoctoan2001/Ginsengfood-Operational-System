# 05 - E2E Smoke Fixture

## Mục Lục

- [1. Mục đích](#1-mục-đích)
- [2. Fixture chính](#2-fixture-chính)
- [3. Smoke workflow](#3-smoke-workflow)
- [4. Expected state chain](#4-expected-state-chain)
- [5. Data required](#5-data-required)
- [6. Negative smoke cases](#6-negative-smoke-cases)

## 1. Mục Đích

Fixture này tạo một đường chạy E2E tối thiểu từ source origin đến public trace, recall dry-run và MISA pending/retry.

SKU smoke được chọn là `A1/CS/DM/HS` vì đây là SKU vegan, công thức có đủ 4 group và 23 recipe lines.

## 2. Fixture Chính

| fixture_key                | value                                            |
| -------------------------- | ------------------------------------------------ |
| `sku_code`                 | `A1/CS/DM/HS`                                    |
| `formula_code`             | `FML-A1-G1`                                      |
| `formula_version`          | `G1`                                             |
| `formula_kind`             | `PILOT_PERCENT_BASED`                            |
| `anchor_ingredient_code`   | `HRB_SAM_SAVIGIN`                                |
| `anchor_baseline_quantity` | theo seed canonical                              |
| `anchor_uom_code`          | `kg`                                             |
| `anchor_ratio_percent`     | theo seed canonical                              |
| `batch_size_standard`      | `400`                                            |
| Recipe line count          | 23                                               |
| Special component lines    | 7                                                |
| Nutrition base lines       | 5                                                |
| Broth extract lines        | 5                                                |
| Seasoning flavor lines     | 6                                                |
| Raw warehouse              | `WH_RAW_MAIN`                                    |
| Finished goods warehouse   | `WH_FG_MAIN`                                     |
| Source zone                | `SRC_ZONE_SMOKE_001`                             |
| Source origin              | `SRC_ORIGIN_SMOKE_001`                           |
| Purchased supplier         | `SUP_SMOKE_001`                                  |
| Production order           | `PO-SMOKE-G1-A1-001`                             |
| Batch                      | `BATCH-SMOKE-G1-A1-001`                          |
| Material request           | `MR-SMOKE-G1-A1-001`                             |
| Material issue             | `MI-SMOKE-G1-A1-001`                             |
| Material receipt           | `MRC-SMOKE-G1-A1-001`                            |
| QC inspection              | `QC-SMOKE-G1-A1-001`                             |
| Batch release              | `REL-SMOKE-G1-A1-001`                            |
| Packaging job              | `PKG-SMOKE-G1-A1-001`                            |
| Print job                  | `PRINT-SMOKE-G1-A1-001`                          |
| QR code                    | `QR-SMOKE-G1-A1-001`                             |
| Warehouse receipt          | `WR-SMOKE-G1-A1-001`                             |
| Recall dry-run             | `RCL-SMOKE-G1-A1-001`                            |
| Required process steps     | `PREPROCESSING` -> `FREEZING` -> `FREEZE_DRYING` |

## 3. Smoke Workflow

Route examples in this workflow follow `docs/software-specs/api/02_API_ENDPOINT_CATALOG.md`. Nếu API catalog đổi route family, file này phải đổi cùng lúc để tránh sinh route song song.

| step | action                                                                                                                                  | API/UI                                                                                     | expected                                                                                                                                                                   |
| ---: | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   01 | Seed UOM, role/action, warehouse, source fixture, SKU, ingredient, G1 recipe, GTIN, public trace policy, event schema, MISA, UI fixture | Seed script                                                                                | SV-001 đến SV-018 pass                                                                                                                                                     |
|   02 | Create source zone                                                                                                                      | `POST /api/admin/source-zones`                                                             | `SRC_ZONE_SMOKE_001` active                                                                                                                                                |
|   03 | Create and verify source origin                                                                                                         | `POST /api/admin/source-origins`, `POST /api/admin/source-origins/{sourceOriginId}/verify` | `SRC_ORIGIN_SMOKE_001` = `VERIFIED`                                                                                                                                        |
|   04 | Raw material intake for A1 recipe ingredients                                                                                           | `POST /api/admin/raw-material/intakes`                                                     | `SELF_GROWN` uses verified source origin; alternate `PURCHASED` path uses `SUP_SMOKE_001` + COA and no source zone                                                         |
|   05 | Raw material QC pass                                                                                                                    | `POST /api/admin/raw-material/lots/{lotId}/qc-inspections`                                 | QC result `QC_PASS`; lot is not issue-ready until mark-ready                                                                                                               |
|   06 | Mark raw lot ready for production                                                                                                       | `POST /api/admin/raw-material/lots/{lotId}/readiness`                                      | lot status `READY_FOR_PRODUCTION`; event `RAW_LOT_READY_FOR_PRODUCTION`                                                                                                    |
|   07 | Create production order                                                                                                                 | `POST /api/admin/production/orders`                                                        | PO created with immutable G1 PILOT snapshot (`formula_kind_snapshot=PILOT_PERCENT_BASED`, anchor metadata, `total_batch_quantity`, `snapshot_basis=PILOT_RATIO_OF_ANCHOR`) |
|   08 | Approve production order                                                                                                                | `POST /api/admin/production/orders/{id}/approve`                                           | PO approved                                                                                                                                                                |
|   09 | Create material request from snapshot                                                                                                   | `POST /api/admin/production/material-requests`                                             | request lines match snapshot                                                                                                                                               |
|   10 | Approve material request                                                                                                                | approve endpoint                                                                           | material request approved                                                                                                                                                  |
|   11 | Execute material issue                                                                                                                  | `POST /api/admin/production/material-issues/{id}/execute`                                  | raw inventory decremented; ledger created                                                                                                                                  |
|   12 | Confirm material receipt at workshop                                                                                                    | `POST /api/admin/production/material-receipts`                                             | receipt confirmed; variance handled                                                                                                                                        |
|   13 | Execute batch/process events                                                                                                            | `POST /api/admin/production/process-events`                                                | `PREPROCESSING` -> `FREEZING` -> `FREEZE_DRYING` complete; post-dry QC/F-07 blocked until `FREEZE_DRYING` complete                                                         |
|   14 | Create packaging job                                                                                                                    | `POST /api/admin/packaging/jobs`                                                           | packaging job created                                                                                                                                                      |
|   15 | Generate QR                                                                                                                             | `POST /api/admin/qr/generate`                                                              | QR state `GENERATED`                                                                                                                                                       |
|   16 | Queue/complete print job                                                                                                                | `POST /api/admin/printing/jobs`                                                            | QR state `PRINTED`                                                                                                                                                         |
|   17 | Finished QC pass                                                                                                                        | `POST /api/admin/qc/inspections`                                                           | QC inspection result `QC_PASS`                                                                                                                                             |
|   18 | Batch release                                                                                                                           | `POST /api/admin/qc/releases` then approve                                                 | batch status `RELEASED`                                                                                                                                                    |
|   19 | Warehouse finished goods receipt                                                                                                        | `POST /api/admin/warehouse/receipts`                                                       | FG ledger created and balance updated                                                                                                                                      |
|   20 | Internal trace search                                                                                                                   | `GET /api/admin/trace/search`                                                              | material-to-batch-to-QR chain visible                                                                                                                                      |
|   21 | Public trace                                                                                                                            | `GET /api/public/trace/{qrCode}`                                                           | only public whitelist fields returned                                                                                                                                      |
|   22 | Recall dry-run impact analysis                                                                                                          | `POST /api/admin/recall/cases`, impact endpoint                                            | affected batch/QR identified                                                                                                                                               |
|   23 | MISA sync pending/retry fixture                                                                                                         | MISA sync event/retry endpoints                                                            | missing mapping case goes reconcile pending                                                                                                                                |

## 4. Expected State Chain

| entity            | expected states                                                                                                  |
| ----------------- | ---------------------------------------------------------------------------------------------------------------- |
| Source origin     | `DRAFT` -> `SUBMITTED` -> `VERIFIED`                                                                             |
| Raw material lot  | `RECEIVED` -> `QC_PENDING` -> `QC_PASS_RECORDED` -> `READY_FOR_PRODUCTION` -> `RESERVED/ALLOCATED` -> `CONSUMED` |
| Production order  | `DRAFT` -> `SUBMITTED` -> `APPROVED` -> `IN_PROGRESS` -> `COMPLETED`                                             |
| Material request  | `DRAFT` -> `SUBMITTED` -> `APPROVED`                                                                             |
| Material issue    | `DRAFT` -> `APPROVED` -> `EXECUTED`                                                                              |
| Material receipt  | `PENDING` -> `CONFIRMED`                                                                                         |
| QC inspection     | `DRAFT` -> `SIGNED` with result `QC_PASS`                                                                        |
| Batch release     | `PENDING` -> `RELEASED`                                                                                          |
| QR lifecycle      | `GENERATED` -> `QUEUED` -> `PRINTED`                                                                             |
| Warehouse receipt | `DRAFT` -> `CONFIRMED`                                                                                           |
| MISA sync         | `PENDING` -> `FAILED_RETRYABLE` hoặc `RECONCILE_PENDING` theo fixture                                            |

`RESERVED/ALLOCATED` có thể được implementation lưu bằng lot state hoặc bằng allocation/reservation record riêng, nhưng không được thay thế gate `READY_FOR_PRODUCTION` trước material issue.

## 5. Data Required

| data group                 | source                                                    |
| -------------------------- | --------------------------------------------------------- |
| UOM                        | `csv/uom.csv`                                             |
| A1 recipe lines            | `csv/g1_recipe_lines.csv` filter `sku_code = A1/CS/DM/HS` |
| A1 ingredients             | `csv/ingredients.csv` joined by A1 recipe lines           |
| Warehouse/location         | `csv/warehouses_locations.csv`                            |
| Source/procurement fixture | `csv/source_origin_fixture.csv`                           |
| GTIN/trade item fixture    | `csv/gtin_fixture.csv`                                    |
| Public trace policy        | `csv/public_trace_policy.csv`                             |
| Event schema               | `csv/event_schema_registry.csv`                           |
| MISA fixture               | `csv/misa_mapping_fixture.csv`                            |
| Role/action                | `csv/roles_permissions.csv`                               |
| UI registry                | `csv/ui_registry_fixture.csv`                             |

## 6. Negative Smoke Cases

| test_id       | scenario                                                                               | expected                                                                         |
| ------------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| SMOKE-NEG-001 | Create PO without active G1 recipe                                                     | reject `ACTIVE_RECIPE_NOT_FOUND`                                                 |
| SMOKE-NEG-002 | Execute material issue using raw lot not `READY_FOR_PRODUCTION`                        | reject `RAW_MATERIAL_LOT_NOT_READY`                                              |
| SMOKE-NEG-003 | Warehouse receipt before batch `RELEASED`                                              | reject `BATCH_NOT_RELEASED`                                                      |
| SMOKE-NEG-004 | Public trace on `VOID` QR                                                              | reject or return public-safe non-traceable message                               |
| SMOKE-NEG-005 | Public trace attempts to expose supplier/cost/QC defect/MISA                           | response must omit fields; test fails on leakage                                 |
| SMOKE-NEG-006 | MISA mapping missing                                                                   | sync event becomes `RECONCILE_PENDING` or failed retryable with audit log        |
| SMOKE-NEG-007 | `SELF_GROWN` intake with source origin not `VERIFIED`                                  | reject `SOURCE_ORIGIN_NOT_VERIFIED`; no lot created                              |
| SMOKE-NEG-008 | `PURCHASED` intake without supplier/COA                                                | reject `SUPPLIER_REQUIRED` or validation error; source zone must not be required |
| SMOKE-NEG-009 | Start F-07/post-dry QC before `FREEZE_DRYING` completed                                | reject `PROCESS_STEP_ORDER_INVALID`                                              |
| SMOKE-NEG-010 | Finished QC result `QC_REJECT` then release attempt                                    | release rejected; no `op_batch_release`                                          |
| SMOKE-NEG-011 | Execute material issue using lot with QC result `QC_PASS` but no mark-ready transition | reject `RAW_MATERIAL_LOT_NOT_READY`; no ledger                                   |
