# 07 - Module Task Breakdown

## 1. Mục tiêu

Task breakdown chia CODE01-CODE17 thành bounded implementation units cho PM, dev, QA và AI coding agent.

## 2. Task Breakdown Theo Phase

| phase | task_id | module | scope | DB | API | UI | tests | done gate |
|---|---|---|---|---|---|---|---|---|
| CODE01 | T-C01-M01-FOUNDATION | M01 | Audit, idempotency, state log, event base | `audit_log`, `idempotency_registry`, `state_transition_log`, `outbox_event` | audit/events/system | Audit/outbox monitor | TC-M01-* | Command audit/idempotency pass |
| CODE01 | T-C01-M05-SOURCE | M05 | Source zone/origin/evidence/verification | `op_source_zone`, `op_source_origin*` | source-zones/source-origins | Source screens | TC-M05-* | Verified source lifecycle pass |
| CODE01A | T-C01A-M03A-SUPPLIER | M03A/M02/M03 | Supplier master, supplier user link, supplier ingredient allowlist, role `R-SUPPLIER`, Supplier Portal auth/scope baseline | `op_supplier`, `op_supplier_ingredient`, `op_supplier_user_link`, auth role/permission seed | `/api/admin/suppliers/*`, `/api/supplier/me` | Supplier admin + Supplier Portal login/scope | TC-M03A-*, TC-HL-SUP-* | Supplier scope/allowlist/auth pass; handoff to CODE02-SUP |
| CODE02 | T-C02-M06-RAW | M06 | Raw intake, raw lot, incoming QC, `RAW_LOT_MARK_READY` -> `READY_FOR_PRODUCTION` | raw receipt/lot/QC, `lot_status`, state transition/audit | raw-material intakes/lots/QC/readiness | Raw intake/QC/lot/readiness | TC-M06-*, TC-UI-RM-READY-* | Lot readiness = `READY_FOR_PRODUCTION`; mark-ready API/permission/state log pass |
| CODE03 | T-C03-M04-G1 | M04 | 20 SKU, ingredients, G1 recipe, 4 groups | SKU/ingredient/recipe | skus/ingredients/recipes | Catalog screens | TC-M04-*, TC-SEED-* | G1 seed and versioning pass |
| CODE03 | T-C03-M07-PROD | M07 | PO snapshot, work order, batch, process chain | PO/work/batch/process | production orders/work/process | PO/work/process | TC-M07-* | Snapshot immutable and process order pass |
| CODE03 | T-C03-M08-MAT | M08/M11 | Material request/issue/receipt and raw decrement | material + ledger | material-* | Material screens | TC-M08-* | One decrement only; issue rejects lot not `READY_FOR_PRODUCTION` |
| CODE04 | T-C04-M10-PACK | M10 | Packaging, GTIN, QR, print/reprint | packaging/QR/print | packaging/qr/printing | Packaging/QR/print | TC-M10-* | QR lifecycle/reprint pass |
| CODE05 | T-C05-M09-QC | M09 | QC inspection and batch release | QC/release | qc inspections/releases | QC/release screens | TC-M09-* | QC pass separate from release |
| CODE06 | T-C06-M11-WH | M11 | Warehouse receipt, ledger, balance, adjustment | warehouse/inventory | warehouse/inventory | Warehouse/ledger/balance | TC-M11-* | Released-only receipt and ledger pass |
| CODE07 | T-C07-M12-TRACE | M12 | Internal/public trace and genealogy | trace links/views/policy | trace/public trace | Trace/public preview | TC-M12-* | Public denylist pass |
| CODE08 | T-C08-M13-RECALL | M13 | Incident, recall, impact, hold, CAPA, CAPA evidence | recall/hold/sale lock/CAPA evidence | incidents/recall | Recall screens | TC-M13-*, TC-UI-CAPA-* | Impact snapshot and clean-evidence close gate pass |
| CODE09 | T-C09-M16-UIREG | M16/M02 | Screen/action/menu registry and permissions | ui registry/RBAC | ui/menu/roles | Admin shell | TC-M16-* | Permission-aware UI pass |
| CODE10 | T-C10-M01-APICON | M01/all | API convention, error, pagination, auth middleware | support tables | all APIs | API client | API regression | Contract sync pass |
| CODE11 | T-C11-M16-PWA | M16/M01 | Offline/PWA command contract | offline/idempotency | mobile/offline | PWA tasks | TC-M16-PWA-* | Replay idempotent |
| CODE12 | T-C12-M10-DEVICE | M10/M14/M15 | Printer/device boundary with PF-02 HTTP/ZPL adapter + HMAC callback refs | device/print logs | printers/devices | Device console | device tests | No direct DB/device bypass; device refs configured |
| CODE13 | T-C13-M14-OUTBOX | M01/M14 | Event schema/outbox/MISA adapter with PF-02 DryRun/Production mode + secret refs | event/misa tables | events/misa | MISA monitor | TC-M14-* | Retry/reconcile pass; no literal MISA secrets |
| CODE14 | T-C14-M15-DASH | M15 | Dashboard/alerts/health | dashboard/alert/health | dashboard/alerts | Dashboard | TC-M15-* | Critical alerts visible |
| CODE15 | T-C15-M01-OVERRIDE | M01/M02 | Override governance | override/audit | overrides | Override queue | override tests | Break-glass audited |
| CODE16 | T-C16-M01-RETENTION | M01/M11/M12/M13/M14 | Retention/archive/restore using PF-02 RPO/RTO and retention classes | retention/archive | retention/archive | Archive admin | retention tests | Restore drill documented; archive search keys preserved |
| CODE17 | T-C17-ALL-CLOSEOUT | All | Final smoke/release handoff | all | all | all | TC-NFR-SMOKE-005 | All P0 gates pass |

## 3. Task Sizing Rules

| size | Definition |
|---|---|
| S | Single layer or docs-only; no contract change |
| M | 2-3 layers, one route family, focused tests |
| L | DB + backend + API + FE + tests for one bounded workflow |
| XL | Split required; cannot be implemented safely in one patch |

Readiness-specific sizing note: `RAW_LOT_MARK_READY` is part of CODE02, not optional polish. It includes API endpoint, permission/action seed, state transition/audit/event evidence, UI action/filter, and negative tests.

## 4. Sequencing Rule

```text
CODE01 -> CODE01A -> CODE02 -> MX-GATE-G1 -> CODE03 -> CODE04 -> CODE05 -> CODE06 -> CODE07 -> CODE08 -> CODE17
```

CODE09-CODE16 may run in parallel only if their touched route/table/UI scopes do not conflict with the active operational phase.
