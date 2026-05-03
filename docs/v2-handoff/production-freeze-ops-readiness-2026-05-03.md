# PF-04 Production Freeze Ops Readiness Handoff - 2026-05-03

## 1. Scope

PF-04 completes release and operations readiness documentation for the production freeze source pack. This handoff covers deployment topology, environment/config refs, secret management, storage/device boundaries, runbooks, monitoring and production freeze smoke.

## 2. Updated Source Documents

| document | PF-04 update |
|---|---|
| `docs/software-specs/dev-handoff/08_DONE_GATE_CHECKLIST.md` | Added PF-04 production freeze ops gate for deployment, runbook, monitoring and smoke evidence. |
| `docs/software-specs/dev-handoff/09_RELEASE_ROLLBACK_GUIDE.md` | Added PF-04 deployment readiness runbook, clean DB rehearsal, migration decision tree, restore drill, worker/incident operations and alert matrix. |
| `docs/software-specs/testing/06_E2E_SMOKE_TEST_PLAN.md` | Added production freeze smoke tests and mandatory negative tests for supplier scope isolation, QR void and production fixture block. |

## 3. Coding Handoff

- Scaffold deployment docs and runtime config using the topology in `architecture/07_DEPLOYMENT_VIEW.md`: `apps/admin-web`, `apps/public-trace`, `apps/shopfloor-pwa`, Operational API/backend, workers, PostgreSQL, evidence storage adapter and printer/device adapter.
- Use config/secret refs for MISA, printer/device, evidence storage, backup/DR, notification outbox binding and frontend API base URLs. Do not commit literal production secrets.
- Treat local filesystem evidence storage and fixture GTIN/MISA/device data as `DEV_TEST_ONLY`.
- Implement workers with observable health and retry state for outbox, MISA sync, printer/QR, evidence scan, projections, archive/retention and alerts.
- Public trace smoke must use `PublicTracePublicResponse` and include leakage/invalid QR checks.
- Release rehearsal must apply migrations from clean DB, run seed validation, run seed twice for idempotency and execute the PF-04 smoke subset.

## 4. Remaining Risk

The repo still has no production runtime scaffold in this phase, so PF-04 is a documentation and contract freeze only. Build/test commands become mandatory when the corresponding apps/workers exist.
