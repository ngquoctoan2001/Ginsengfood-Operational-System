# 00 - Legacy File Mapping

> Mục đích: ghi lại cách chuyển nội dung từ thư mục đánh số legacy sang cây thư mục chuẩn theo prompt gốc. File này là historical mapping; trong cây hiện tại, các thư mục legacy đánh số không còn là active docs.

## Source Policy

- Tuân thủ `01_SOURCE_INDEX.md`.
- Không đọc source code, không dùng `AGENTS.md`, không dùng `docs/ginsengfood_*`.
- Nội dung legacy được copy để tránh mất dữ liệu; các file placeholder chỉ là scaffold cho các part sau.

## Folder Mapping

| Legacy folder | Canonical folder | Trạng thái |
| --- | --- | --- |
| `1. business/` | `business/` | Mapped; legacy folder not active in current tree |
| `2. functional/` | `functional/` | Mapped; legacy folder not active in current tree |
| `3. non-functional/` | `non-functional/` | Mapped; legacy folder not active in current tree |
| `4. architecture/` | `architecture/` | Mapped; legacy folder not active in current tree |
| `5. database/` | `database/` | Mapped; legacy folder not active in current tree |
| `6. api/` | `api/` | Mapped; legacy folder not active in current tree |
| `7. ui/` | `ui/` | Mapped; legacy folder not active in current tree |
| `8. workflows/` | `workflows/` | Mapped; legacy folder not active in current tree |
| `9. modules/` | `modules/` | Mapped; legacy folder not active in current tree |
| `10. diagrams/` | `diagrams/` | Mapped; legacy folder not active in current tree |
| `11. testing/` | `testing/` | Mapped; legacy folder not active in current tree |
| `12. dev-handoff/` | `dev-handoff/` | Mapped; legacy folder not active in current tree |
| `13. ai-agent/` | `ai-agent/` | Mapped; legacy folder not active in current tree |

## File Mapping Chính

| Legacy file | Canonical file | Ghi chú |
| --- | --- | --- |
| `1. business/01_BUSINESS_PROCESSES.md` | `business/01_BUSINESS_REQUIREMENTS.md` | Business processes dùng làm nền cho business requirements. |
| `1. business/02_BUSINESS_RULES.md` | `business/02_BUSINESS_RULES.md` | Giữ nguyên business rules. |
| `1. business/04_FORMS_AND_DOCUMENTS.md` | `business/03_OPERATIONAL_RULES.md` | Forms/documents dùng làm nền operational rules. |
| `1. business/03_ROLE_RESPONSIBILITY_MATRIX.md` | `business/04_ROLE_AND_PERMISSION_MODEL.md` | Role responsibility matrix dùng làm nền role/permission. |
| `1. business/04_FORMS_AND_DOCUMENTS.md` | `business/05_APPROVAL_AND_AUDIT_RULES.md` | Forms flow dùng làm nền approval/audit rules. |
| `2. functional/00_README.md` | `functional/00_FUNCTIONAL_OVERVIEW.md` | Functional README dùng làm overview. |
| `2. functional/01_FUNCTIONAL_REQUIREMENTS.md` | `functional/01_MODULE_FUNCTION_MATRIX.md` | Functional requirements dùng làm nền module/function matrix. |
| `2. functional/02_USE_CASES.md` | `functional/02_USE_CASE_CATALOG.md` | Use cases đổi tên theo prompt gốc. |
| `2. functional/03_USER_STORIES.md` | `functional/03_USER_STORIES.md` | Giữ nguyên user stories. |
| `2. functional/04_ACCEPTANCE_CRITERIA.md` | `functional/04_ACCEPTANCE_CRITERIA.md` | Giữ nguyên acceptance criteria. |
| `2. functional/05_FEATURE_MAP.md` | `functional/05_MODULE_DEPENDENCY_MATRIX.md` | Feature map dùng làm nền dependency matrix. |
| `3. non-functional/00_README.md` | `non-functional/01_NON_FUNCTIONAL_REQUIREMENTS.md` | NFR README dùng làm tổng quan NFR. |
| `3. non-functional/01_PERFORMANCE.md` | `non-functional/02_PERFORMANCE_REQUIREMENTS.md` | Performance đổi tên theo prompt gốc. |
| `3. non-functional/02_SECURITY.md` | `non-functional/03_SECURITY_REQUIREMENTS.md` | Security đổi tên theo prompt gốc. |
| `3. non-functional/05_OPERATIONS_AND_OBSERVABILITY.md` | `non-functional/06_OBSERVABILITY_REQUIREMENTS.md` | Operations/observability dùng làm observability requirements. |
| `3. non-functional/03_AVAILABILITY_AND_RELIABILITY.md` | `non-functional/07_SCALABILITY_AVAILABILITY_REQUIREMENTS.md` | Availability/reliability dùng làm scalability/availability. |
| `4. architecture/00_README.md` | `architecture/01_SYSTEM_ARCHITECTURE.md` | Architecture README dùng làm system architecture. |
| `4. architecture/03_COMPONENT_DIAGRAM.md` | `architecture/02_COMPONENT_DIAGRAM.md` | Component diagram đổi tên theo prompt gốc. |
| `4. architecture/05_INTEGRATION_DESIGN.md` | `architecture/04_INTEGRATION_ARCHITECTURE.md` | Integration design đổi tên theo prompt gốc. |
| `4. architecture/04_DEPLOYMENT_DIAGRAM.md` | `architecture/07_DEPLOYMENT_VIEW.md` | Deployment diagram dùng làm deployment view. |
| `4. architecture/06_ADR_INDEX.md` | `architecture/08_TECHNICAL_DECISIONS.md` | ADR index dùng làm technical decisions. |
| `5. database/01_ENTITIES_OVERVIEW.md` | `database/01_DATABASE_OVERVIEW.md` | Entities overview dùng làm database overview. |
| `5. database/02_SCHEMA_DETAILS.md` | `database/03_TABLE_SPECIFICATION.md` | Schema details đổi tên thành table specification. |
| `5. database/03_MIGRATION_POLICY.md` | `database/08_MIGRATION_STRATEGY.md` | Migration policy đổi tên theo prompt gốc. |
| `5. database/04_SEED_DATA.md` | `database/07_SEED_DATA_SPECIFICATION.md` | Seed data đổi tên theo prompt gốc. |
| `6. api/00_README.md` | `api/01_API_CONVENTION.md` | API README dùng làm API convention. |
| `6. api/01_ROUTE_MAP.md` | `api/02_API_ENDPOINT_CATALOG.md` | Route map đổi tên thành endpoint catalog. |
| `6. api/02_OPENAPI_CONVENTIONS.md` | `api/08_OPENAPI_GENERATION_GUIDE.md` | OpenAPI conventions đổi tên theo prompt gốc. |
| `6. api/03_ERROR_CONTRACT.md` | `api/04_API_ERROR_CODE_SPEC.md` | Error contract đổi tên theo prompt gốc. |
| `6. api/04_PUBLIC_VS_ADMIN.md` | `api/05_API_AUTH_PERMISSION_SPEC.md` | Public/admin boundary dùng làm auth/permission spec. |
| `6. api/05_IDEMPOTENCY_KEYS.md` | `api/06_API_IDEMPOTENCY_SPEC.md` | Idempotency keys đổi tên theo prompt gốc. |
| `7. ui/01_INFORMATION_ARCHITECTURE.md` | `ui/01_UI_INFORMATION_ARCHITECTURE.md` | UI information architecture đổi tên theo prompt gốc. |
| `7. ui/02_ADMIN_ROUTE_REGISTRY.md` | `ui/02_MENU_SIDEBAR_STRUCTURE.md` | Admin route registry dùng làm nền menu/sidebar. |
| `7. ui/03_PAGE_TEMPLATES.md` | `ui/04_SCREEN_SPECIFICATION_TEMPLATE.md` | Page templates đổi tên thành screen spec template. |
| `7. ui/04_FORM_PATTERNS.md` | `ui/05_FORM_FIELD_SPECIFICATION.md` | Form patterns dùng làm form field specification. |
| `8. workflows/00_README.md` | `workflows/01_WORKFLOW_OVERVIEW.md` | Workflow README dùng làm workflow overview. |
| `8. workflows/02_PRODUCTION_ORDER_LIFECYCLE.md` | `workflows/05_CANONICAL_OPERATIONAL_FLOW.md` | Production order lifecycle dùng làm nền operational flow. |
| `8. workflows/00_README.md` | `workflows/04_STATE_MACHINES.md` | Workflow README trỏ đến các lifecycle state machines. |
| `9. modules/00_README.md` | `modules/00_MODULE_TEMPLATE.md` | Module README dùng làm nền module template, cần chuẩn hóa ở Part 7. |
| `9. modules/08_MX_CROSS_CUTTING.md` | `modules/01_FOUNDATION_CORE.md` | Cross-cutting dùng làm nền foundation core. |
| `9. modules/08_MX_CROSS_CUTTING.md` | `modules/02_AUTH_PERMISSION.md` | Cross-cutting dùng làm nền auth/permission. |
| `9. modules/08_MX_CROSS_CUTTING.md` | `modules/03_MASTER_DATA.md` | Cross-cutting dùng làm nền master data. |
| `9. modules/08_MX_CROSS_CUTTING.md` | `modules/04_SKU_INGREDIENT_RECIPE.md` | Cross-cutting dùng làm nền SKU/recipe. |
| `9. modules/01_M1_SOURCE_ZONE.md` | `modules/05_SOURCE_ORIGIN.md` | M1 source zone đổi tên thành source origin. |
| `9. modules/02_M2_RAW_MATERIAL_LOT.md` | `modules/06_RAW_MATERIAL.md` | M2 raw material lot đổi tên thành raw material. |
| `9. modules/03_M3_PRODUCTION.md` | `modules/07_PRODUCTION.md` | M3 production đổi tên theo prompt gốc. |
| `9. modules/03_M3_PRODUCTION.md` | `modules/08_MATERIAL_ISSUE_RECEIPT.md` | M3 production chứa material issue/receipt, tạm tách sang file riêng. |
| `9. modules/05_M5_QC_RELEASE.md` | `modules/09_QC_RELEASE.md` | M5 QC release đổi tên theo prompt gốc. |
| `9. modules/04_M4_PACKAGING_QR_PRINT.md` | `modules/10_PACKAGING_PRINTING.md` | M4 packaging/QR/print đổi tên theo prompt gốc. |
| `9. modules/06_M6_WAREHOUSE_INVENTORY.md` | `modules/11_WAREHOUSE_INVENTORY.md` | M6 warehouse/inventory đổi tên theo prompt gốc. |
| `9. modules/07_M7_TRACE_RECALL.md` | `modules/12_TRACEABILITY.md` | M7 trace/recall dùng làm nền traceability. |
| `9. modules/07_M7_TRACE_RECALL.md` | `modules/13_RECALL.md` | M7 trace/recall dùng làm nền recall. |
| `9. modules/08_MX_CROSS_CUTTING.md` | `modules/14_MISA_INTEGRATION.md` | Cross-cutting dùng làm nền MISA integration. |
| `9. modules/08_MX_CROSS_CUTTING.md` | `modules/15_REPORTING_DASHBOARD.md` | Cross-cutting dùng làm nền reporting/dashboard. |
| `9. modules/08_MX_CROSS_CUTTING.md` | `modules/16_ADMIN_UI.md` | Cross-cutting dùng làm nền admin UI. |
| `10. diagrams/02_USE_CASE_DIAGRAM.md` | `diagrams/01_USE_CASE_DIAGRAM.md` | Use case diagram đổi tên theo prompt gốc. |
| `10. diagrams/03_COMPONENT_DIAGRAM.md` | `diagrams/02_COMPONENT_DIAGRAM.md` | Component diagram đổi tên theo prompt gốc. |
| `10. diagrams/01_CONTEXT_DIAGRAM.md` | `diagrams/09_CONTEXT_DIAGRAM.md` | Context diagram đổi tên theo prompt gốc. |

## File Được Tạo Mới Hoặc Chuẩn Hóa Trong Part 1

| File | Lý do |
| --- | --- |
| `business/06_COMPLIANCE_AND_DATA_POLICY.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `non-functional/04_AUDIT_LOGGING_REQUIREMENTS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `non-functional/05_BACKUP_RETENTION_REQUIREMENTS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `architecture/03_MODULE_BOUNDARY.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `architecture/05_EVENT_ARCHITECTURE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `architecture/06_DATA_FLOW_DIAGRAM.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `database/02_ERD.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `database/04_ENUM_REFERENCE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `database/05_INDEX_CONSTRAINT_REFERENCE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `database/06_DATA_RETENTION_POLICY.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `api/03_API_REQUEST_RESPONSE_SPEC.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `api/07_API_PAGINATION_FILTER_SORT_SPEC.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ui/03_SCREEN_CATALOG.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ui/06_TABLE_ACTION_FILTER_SPECIFICATION.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ui/07_UI_STATE_AND_VALIDATION.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ui/08_FRONTEND_API_CLIENT_CONTRACT.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `workflows/02_ACTIVITY_DIAGRAMS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `workflows/03_SEQUENCE_DIAGRAMS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `workflows/06_APPROVAL_WORKFLOWS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `workflows/07_EXCEPTION_FLOWS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `workflows/08_SMOKE_WORKFLOW.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `diagrams/03_ACTIVITY_DIAGRAM.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `diagrams/04_SEQUENCE_DIAGRAM.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `diagrams/05_STATE_DIAGRAM.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `diagrams/06_ERD_DIAGRAM.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `diagrams/07_DATA_FLOW_DIAGRAM.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `diagrams/08_DEPLOYMENT_DIAGRAM.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `testing/01_TEST_STRATEGY.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `testing/02_TEST_CASE_MATRIX.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `testing/03_API_TEST_PLAN.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `testing/04_UI_TEST_PLAN.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `testing/05_INTEGRATION_TEST_PLAN.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `testing/06_E2E_SMOKE_TEST_PLAN.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `testing/07_SEED_VALIDATION_TEST_PLAN.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `testing/08_REGRESSION_TEST_PLAN.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/01_DEVELOPMENT_GUIDE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/02_BACKEND_IMPLEMENTATION_GUIDE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/03_FRONTEND_IMPLEMENTATION_GUIDE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/04_DATABASE_IMPLEMENTATION_GUIDE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/05_SEED_IMPLEMENTATION_GUIDE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/06_API_CONTRACT_HANDOFF.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/07_MODULE_TASK_BREAKDOWN.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/08_DONE_GATE_CHECKLIST.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `dev-handoff/09_RELEASE_ROLLBACK_GUIDE.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ai-agent/01_AI_AGENT_WORKFLOW.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ai-agent/02_CODEX_PROMPT_PACK.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ai-agent/03_GAP_IMPLEMENTATION_PROMPTS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ai-agent/04_REVIEW_PROMPTS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ai-agent/05_VALIDATION_PROMPTS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |
| `ai-agent/06_HANDOFF_PROMPTS.md` | Tạo structural placeholder vì chưa có legacy file tương ứng trực tiếp. |

Ghi chú: các file trong `testing/`, `dev-handoff/` và `ai-agent/` sau đó đã được mirror/cập nhật theo các part chi tiết và prompt pack mới. Bảng trên là lịch sử tạo/cấu trúc ban đầu, không dùng để phủ quyết nội dung canonical hiện tại.

## Trạng Thái Legacy

Các thư mục `1. business/` đến `13. ai-agent/` là nguồn mapping lịch sử trong file này, không còn là active docs trong cây `docs/software-specs/` hiện tại. Không dùng file legacy path để sửa requirement mới; nếu cần truy xuất nguồn cũ, dùng canonical file tương ứng trong cột `Canonical file`.
