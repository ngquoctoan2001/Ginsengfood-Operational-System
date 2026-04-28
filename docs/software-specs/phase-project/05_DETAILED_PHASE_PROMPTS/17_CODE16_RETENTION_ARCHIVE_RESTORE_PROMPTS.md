# 17 - CODE16 Retention + Archive + Restore Prompts

## Scope

Phase `CODE16` covers retention policy, archive/export, archive search boundary and restore drill.

## Prompt 17.01 - CODE16 Owner Decision Gate

```text
Role: Retention/DR Gate Agent.
Mission: Check whether CODE16 can start.
Read first: non-functional/05_BACKUP_RETENTION_REQUIREMENTS.md, non-functional/07_SCALABILITY_AVAILABILITY_REQUIREMENTS.md, business/06_COMPLIANCE_AND_DATA_POLICY.md, phase-project/03_PROGRESS_REPORT.md.
Owner blockers: OD-12 backup/DR RPO/RTO; OD-13 audit/ledger/trace/recall retention duration.
Rule: do not implement destructive retention/archive without owner-approved policy.
Output: GO / NEEDS_OWNER / DEFER, decision questions, progress update.
```

## Prompt 17.02 - Retention Policy Plan

```text
Role: Retention Planner.
Mission: Plan retention/archive only after OD-12/OD-13 are closed or formally deferred.
Workflow: classify data, retention duration, archive boundary, restore drill, audit requirements, tests.
Output: retention matrix, DB/API/UI/test plan, progress update.
```

## Prompt 17.03 - Archive/Restore Implementation

```text
Role: Archive/Restore Agent.
Mission: Implement approved archive/restore gap.
Rules: no silent delete; archive action audited; restore drill documented; archive search must respect privacy/security.
Output: implementation, validation, restore drill result, progress update.
```

## Prompt 17.04 - CODE16 Review/Validate/Handoff

```text
Role: Compliance/DR Reviewer.
Mission: Validate CODE16.
Tests: retention policy applied; archive/export audited; restore drill documented; no production-destructive behavior without approval.
Output: verdict, OD status, progress update.
```

