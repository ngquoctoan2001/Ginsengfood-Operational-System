# 09 - Release Rollback Guide

## 1. Mục tiêu

Hướng dẫn release, rollback, forward-fix, restore và hotfix cho các phase/gap trong `docs/software-specs/`.

## 2. Release Stages

| stage | Required checks |
|---|---|
| Pre-merge | Bounded gap done gate, unit/API/UI tests, no open hard lock failure |
| QA deploy | Migration applies, seed validates, API/UI smoke starts |
| Staging release candidate | Full regression P0/P1, E2E smoke, public trace security, MISA reconcile |
| Production readiness | Backup/restore check, rollback plan, owner decisions, monitoring/alert readiness |
| Post-release | Health checks, audit/event/outbox monitoring, smoke subset |

## 3. Rollback Principles

| scenario | Preferred strategy |
|---|---|
| Code-only failure before data write | Roll back deployment artifact |
| Migration failure before data write | Stop deploy; rollback migration if safe |
| Migration after data write | Prefer forward-fix migration; avoid destructive rollback |
| Bad seed | Idempotent seed fix; do not delete transaction data |
| Bad ledger/audit/history | Owner-approved repair migration or reversal/correction, not in-place mutation |
| Public trace leakage | Disable public route/projection if possible, hotfix DTO/policy, audit exposure |
| MISA sync issue | Pause dispatcher, keep events, fix mapping/retry/reconcile |
| QR/print issue | Void affected QR/print jobs through workflow; do not delete history |

## 4. Release Checklist

| item | Evidence |
|---|---|
| Build artifacts | Backend/frontend build result |
| Migration | Applied migration list and validation output |
| Seed | Seed validation and idempotency rerun |
| Smoke | E2E smoke report |
| Regression | P0/P1 regression report |
| Public trace | Denylist response evidence |
| MISA | Sync/retry/reconcile status evidence |
| Monitoring | Dashboard/alert/health endpoint evidence |
| Rollback | Exact rollback/forward-fix decision tree |

## 5. Hotfix Flow

| step | Action |
|---|---|
| 1 | Triage issue and affected module/phase/test case |
| 2 | Check whether issue touches hard lock or public/private boundary |
| 3 | Freeze related risky operations if needed: raw material readiness/material issue queue, public trace, MISA dispatcher, print queue, warehouse receipt |
| 4 | Patch smallest safe layer |
| 5 | Run targeted regression plus affected smoke subset |
| 6 | Record incident, evidence, owner decision if required |

## 6. Rollback/Handoff Template

```markdown
## Release/Rollback Handoff

- Release id:
- Phase/gap:
- Modules:
- Migration ids:
- Seed version:
- Build artifacts:
- Tests passed:
- Smoke evidence:
- Known risks:
- Rollback option:
- Forward-fix option:
- Data repair needed:
- Owner decisions:
- Monitoring checks:
```

## 7. Non-Rollbackable Data

Do not destructive rollback these without owner-approved repair plan:

- `audit_log`
- `state_transition_log`
- `op_inventory_ledger`
- `op_qr_state_history`
- `op_recall_exposure_snapshot`
- `op_source_origin_evidence`
- `op_recall_capa_evidence`
- referenced evidence files in local/dev storage or company storage server
- dispatched `outbox_event`/MISA sync logs
- raw lot readiness state transition/audit records once accepted

Use reversal, compensation, void/reprint, recall hold, reconcile or forward-fix migration instead.
