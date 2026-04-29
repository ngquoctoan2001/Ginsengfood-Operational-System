# API Auth Permission Spec

> Mục đích: chuẩn hóa auth/RBAC/action permission cho backend và UI.

## 1. Auth Model

| API family | Auth | Notes |
| --- | --- | --- |
| `/api/admin/*` | Bearer token required | Local account/RBAC phase 1. |
| `/api/mobile/*` | Bearer token + optional `X-Device-Id` | PWA/shopfloor. |
| `/api/public/trace/*` | Anonymous read-only | No admin DTO/private fields. |

## 2. Permission Enforcement

- Backend must check permission/action code for every protected command/query.
- UI permission state is derived from `GET /api/admin/ui/menu` and/or screen registry but is not security boundary.
- Sensitive commands must audit both success and rejected permission attempt if policy enables denial audit.

## 3. Action Permission Catalog

| action_code | Typical roles | Endpoint examples |
| --- | --- | --- |
| `AUDIT_VIEW` | `R-AUDITOR`, `R-OPS-MGR`, `R-ADMIN` | `GET /api/admin/audit/logs` |
| `ROLE_PERMISSION_UPDATE` | `R-ADMIN` | `POST /api/admin/roles/{roleCode}/actions` |
| `SOURCE_ORIGIN_EVIDENCE_ADD` | `R-WH-RAW`, `R-QA-REL`, `R-OPS-MGR` | `POST /api/admin/source-origins/{id}/evidence` |
| `SOURCE_ORIGIN_VERIFY` | `R-QA-REL`, `R-OPS-MGR` | `POST /api/admin/source-origins/{id}/verify` |
| `RAW_INTAKE_CREATE` | `R-WH-RAW` | `POST /api/admin/raw-material/intakes` |
| `RAW_QC_SIGN` | `R-QC-RAW` | `POST /api/admin/raw-material/lots/{id}/qc-inspections` |
| `RAW_LOT_MARK_READY` | `R-QA-REL`, `R-OPS-MGR` | `POST /api/admin/raw-material/lots/{id}/readiness` |
| `SKU_CREATE` | `R-ADMIN`, `R-OPS-MGR` | `POST /api/admin/skus` |
| `RECIPE_ACTIVATE` | `R-OPS-MGR`, `R-QA-REL` | `POST /api/admin/recipes/{id}/activate`; requires prior approved approval request unless owner policy explicitly permits direct activation |
| `PRODUCTION_ORDER_CREATE` | `R-PROD-MGR` | `POST /api/admin/production/orders` |
| `PRODUCTION_ORDER_APPROVE` | `R-PROD-MGR`, `R-OPS-MGR` | `POST /api/admin/production/orders/{id}/approve` |
| `MATERIAL_REQUEST_APPROVE` | `R-PROD-MGR` | `POST /api/admin/production/material-requests/{id}/approve` |
| `MATERIAL_ISSUE_EXECUTE` | `R-WH-RAW` | `POST /api/admin/production/material-issues/{id}/execute` |
| `MATERIAL_RECEIPT_CONFIRM` | `R-PROD-OP` | `POST /api/admin/production/material-receipts` |
| `WORKFORCE_CHECK_IN` | `R-PROD-OP` | `POST /api/admin/production/workforce/check-ins` |
| `WORKFORCE_CHECK_IN_CONFIRM` | `R-PROD-MGR` | `POST /api/admin/production/workforce/check-ins/{id}/confirm` |
| `PACKAGING_JOB_CREATE` | `R-PACK-OP` | `POST /api/admin/packaging/jobs` |
| `QR_GENERATE` | `R-PRINT-OP`, `R-PACK-OP` by policy | `POST /api/admin/qr/generate` |
| `QR_REPRINT` | `R-PRINT-OP`, approval by `R-OPS-MGR` if required | `POST /api/admin/printing/jobs/{id}/reprint` |
| `QC_INSPECTION_SIGN` | `R-QC-PROD`, `R-QC-RAW` | `POST /api/admin/qc/inspections` |
| `BATCH_RELEASE_APPROVE` | `R-QA-REL` | `POST /api/admin/qc/releases/{id}/approve` |
| `WAREHOUSE_RECEIPT_CONFIRM` | `R-WH-FG` | `POST /api/admin/warehouse/receipts` |
| `INVENTORY_ADJUSTMENT_CREATE` | `R-WH-RAW`, `R-WH-FG`, approval by `R-OPS-MGR` | `POST /api/admin/inventory/adjustments` |
| `TRACE_INTERNAL_VIEW` | `R-TRACE`, `R-RECALL-MGR`, `R-AUDITOR` | `GET /api/admin/trace/search` |
| `RECALL_CASE_CREATE` | `R-RECALL-MGR` | `POST /api/admin/recall/cases` |
| `RECALL_IMPACT_ANALYSIS` | `R-RECALL-MGR`, `R-QA-REL` | `POST /api/admin/recall/cases/{id}/impact-analysis` |
| `RECALL_HOLD_APPLY` | `R-RECALL-MGR`, `R-OPS-MGR` | `POST /api/admin/recall/cases/{id}/hold` |
| `RECALL_SALE_LOCK_APPLY` | `R-RECALL-MGR`, `R-OPS-MGR` | `POST /api/admin/recall/cases/{id}/sale-lock` |
| `RECALL_CAPA_EVIDENCE_ADD` | `R-RECALL-MGR`, `R-QA-REL` | `POST /api/admin/recall/capas/{capaId}/evidence` |
| `RECALL_CLOSE` | `R-RECALL-MGR`, approval by `R-QA-REL`/`R-OPS-MGR` if policy requires | `POST /api/admin/recall/cases/{id}/close` |
| `MISA_MANUAL_RETRY` | `R-ACC-INT` | `POST /api/admin/integrations/misa/sync-events/{id}/retry` |
| `ACCOUNTING_DOCUMENT_POST` | `R-ACC-INT` | `POST /api/admin/integrations/misa/material-issue-documents/{id}/post` |
| `OVERRIDE_REQUEST_SUBMIT` | Authorized operator for target action | `POST /api/admin/governance/overrides` |
| `OVERRIDE_REQUEST_APPROVE` | `R-OPS-MGR`, `R-ADMIN` by policy | `POST /api/admin/governance/overrides/{id}/approve` |
| `DASHBOARD_VIEW` | `R-OPS-MGR`, `R-DEVOPS`, role-based view | `GET /api/admin/dashboard/operations` |
| `UI_SCREEN_VIEW` | Internal authenticated users | `GET /api/admin/ui/screens` |

## 4. Permission Error Rules

| Case | HTTP | Error |
| --- | --- | --- |
| No token | `401` | `UNAUTHORIZED` |
| Token invalid/expired | `401` | `UNAUTHORIZED` |
| Valid token but missing action | `403` | `FORBIDDEN` |
| Approval actor violates policy | `403` or `422` | `APPROVAL_POLICY_VIOLATION` |
| Public trace invalid QR | `404`/`422` | `QR_INVALID` |

Route note: material issue/receipt permissions use the primary API route family `/api/admin/production/material-issues/*` and `/api/admin/production/material-receipts`. Work-order nested routes are adapters only if an implementation phase records route impact analysis.
