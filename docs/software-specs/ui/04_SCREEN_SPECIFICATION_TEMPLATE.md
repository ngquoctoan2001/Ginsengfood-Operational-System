# 04 Screen Specification Template

## 1. Mục tiêu

Template này dùng khi BA/SA/FE cần viết đặc tả chi tiết cho một màn hình cụ thể từ `ui/03_SCREEN_CATALOG.md`. Mỗi màn hình triển khai thực tế phải có đủ route, API, permission, state, validation, audit, test và liên kết workflow.

## 2. Template chuẩn

```md
# [screen_id] [screen_name]

## 1. Metadata

| Thuộc tính | Giá trị |
|---|---|
| screen_id |  |
| screen_name |  |
| module |  |
| route |  |
| surface | Admin Web / Shopfloor PWA / Public Trace |
| owner role |  |
| related workflow |  |
| related API |  |
| related database table |  |
| related test case |  |
| source requirement |  |

## 2. Purpose

Mô tả ngắn màn hình phục vụ nghiệp vụ nào, record nào, state nào.

## 3. Roles And Permissions

| Role | Can view | Can create | Can edit | Can approve | Can execute command | Ghi chú |
|---|---|---|---|---|---|---|

## 4. Layout

### Header
- Title:
- Primary status badge:
- Identity fields:
- Primary action:
- Secondary actions:

### Summary Cards
| Card | Data source | Condition | Empty state |
|---|---|---|---|

### Main Table / Form
| Field/Column | Data key | Type | Required | Editable | Validation | API field |
|---|---|---|---|---|---|---|

### Related Records
| Section | API | Purpose |
|---|---|---|

### Timeline / Audit
| Event | API | Visible to |
|---|---|---|

## 5. Data Loading

| Data | API | Trigger | Cache policy | Error handling |
|---|---|---|---|---|

## 6. Commands

| Action | API | Method | Permission | State required | Idempotency-Key | Confirmation | Success result | Failure handling |
|---|---|---|---|---|---|---|---|---|

## 7. Validation

| Rule ID | Rule | Client validation | Server validation | Error code | Test case |
|---|---|---|---|---|---|

## 8. UI States

| State | UI behavior |
|---|---|
| loading |  |
| empty |  |
| loaded |  |
| permission_denied |  |
| validation_error |  |
| stale_state |  |
| command_in_progress |  |
| command_success |  |
| command_failed |  |

## 9. Offline / PWA Behavior

| Scenario | Required behavior |
|---|---|
| offline_read |  |
| offline_command_queue |  |
| sync_order |  |
| stale_after_sync |  |
| sensitive_payload_limit |  |

Ghi rõ `not applicable` nếu screen chỉ chạy trên Admin Web online. Với PWA/material issue/lot readiness/workforce check-in/out, section này phải nêu endpoint, idempotency key, queue order và stale-state handling.

## 10. Audit / Trace / Security

- Audit event:
- Public/private data policy:
- Sensitive fields:
- Forbidden fields:
- Export policy:

## 11. Test Cases

| test_id | scenario | precondition | steps | expected result | priority |
|---|---|---|---|---|---|
```

## 3. Ví dụ áp dụng: Raw Material Intake

```md
# SCR-RAW-INTAKES Raw Material Intakes

## 1. Metadata

| Thuộc tính | Giá trị |
|---|---|
| screen_id | SCR-RAW-INTAKES |
| screen_name | Raw Material Intakes |
| module | M06 Raw Material |
| route | /admin/raw-material/intakes |
| surface | Admin Web |
| owner role | Warehouse Operator |
| related workflow | W06 Raw intake |
| related API | GET/POST /api/admin/raw-material/intakes; POST /api/admin/raw-material/intakes/{id}/receive |
| related database table | raw_material_intake, raw_material_lot, source_origin |
| related test case | TC-UI-RM-001 |

## 2. Purpose

Màn hình ghi nhận tiếp nhận nguyên liệu, liên kết supplier, source origin, ingredient, số lượng và tạo basis cho raw material lot/QC đầu vào.

## 3. Roles And Permissions

| Role | Can view | Can create | Can edit | Can approve | Can execute command | Ghi chú |
|---|---|---|---|---|---|---|
| Warehouse Operator | Có | Có | Có khi DRAFT | Không | receive, cancel | Không được verify source origin. |
| QA Inspector | Có | Không | Không | Không | open QC | Chỉ xem và tạo QC nếu lot đã nhận. |
| QA Manager | Có | Không | Không | Có trong QC flow | Không | Dùng để giám sát. |

## 4. Layout

### Header
- Title: Raw Material Intakes
- Primary status badge: count theo DRAFT/RECEIVED/CANCELLED
- Primary action: Create Intake

### Main Table
| Field/Column | Data key | Type | Required | Editable | Validation | API field |
|---|---|---|---|---|---|---|
| Intake Code | intake_code | text | Có | Không sau create | Unique | intake_code |
| Ingredient | ingredient_id | select | Có | Có khi DRAFT | active ingredient | ingredient_id |
| Source Origin | source_origin_id | select | Có nếu source policy yêu cầu | Có khi DRAFT | phải verified nếu bắt buộc | source_origin_id |
| Quantity | quantity | decimal | Có | Có khi DRAFT | > 0 | quantity |
| UOM | uom_code | select | Có | Có khi DRAFT | match ingredient UOM policy | uom_code |
| Status | status | badge | Có | Không | enum | status |

## 5. Commands

| Action | API | Method | Permission | State required | Idempotency-Key | Confirmation | Success result | Failure handling |
|---|---|---|---|---|---|---|---|---|
| Create Intake | /api/admin/raw-material/intakes | POST | raw_intake.write | none | Có | Không | DRAFT/RECEIVED theo API policy | Show field errors |
| Receive | /api/admin/raw-material/intakes/{id}/receive | POST | raw_intake.receive | DRAFT | Có | Có | Creates raw_material_lot | Show SOURCE_ORIGIN_NOT_VERIFIED/VALIDATION_ERROR |
| Cancel | /api/admin/raw-material/intakes/{id}/cancel | POST | raw_intake.cancel | DRAFT | Có | Có | CANCELLED | Show stale state |

## 6. Validation

| Rule ID | Rule | Client validation | Server validation | Error code | Test case |
|---|---|---|---|---|---|
| UI-RM-VAL-001 | Quantity phải > 0 | Có | Có | VALIDATION_ERROR | TC-UI-RM-001 |
| UI-RM-VAL-002 | Source origin phải verified nếu policy yêu cầu | Chỉ pre-check | Có | SOURCE_ORIGIN_NOT_VERIFIED | TC-UI-RM-002 |
| UI-RM-VAL-003 | Không receive intake đã cancelled | Ẩn button | Có | INVALID_STATE_TRANSITION | TC-UI-RM-003 |
```

## 4. Checklist khi tạo screen spec

- Có `screen_id` đúng trong `ui/03_SCREEN_CATALOG.md`.
- Có route UI và API source rõ ràng.
- Có permission/action tương ứng trong `api/05_API_AUTH_PERMISSION_SPEC.md`.
- Có validation client/server và error code.
- Có lot status/readiness gate nếu screen liên quan raw lot hoặc material issue; material issue chỉ được phép với `lot_status = READY_FOR_PRODUCTION`.
- Có empty/error/loading/permission/stale state.
- Có idempotency cho command.
- Có Offline/PWA behavior nếu surface là Shopfloor PWA hoặc command có thể queue offline.
- Có test case tối thiểu cho success, validation error, permission denied, stale state.
- Không dùng DTO admin cho public trace.
