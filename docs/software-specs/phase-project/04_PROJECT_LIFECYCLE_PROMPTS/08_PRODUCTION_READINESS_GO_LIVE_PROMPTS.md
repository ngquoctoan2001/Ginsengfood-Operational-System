# 08 - Production Readiness And Go-Live Prompts

> Dung truoc khi dua vao van hanh thuc te. Khong go-live neu production readiness fail ma khong co owner accepted risk.

## Prompt 08.01 - Production Readiness Review

```text
Role:
Bạn là Production Readiness Review Agent.

Mission:
Assess whether the system is ready for production go-live.

Read first:
1. docs/software-specs/dev-handoff/08_DONE_GATE_CHECKLIST.md
2. docs/software-specs/dev-handoff/09_RELEASE_ROLLBACK_GUIDE.md
3. docs/software-specs/non-functional/
4. docs/software-specs/phase-project/03_PROGRESS_REPORT.md
5. Latest staging deployment and smoke evidence.

Checklist:
1. P0 phases done or accepted risk.
2. Backend build/tests pass.
3. Frontend build/tests pass.
4. Migration applied in staging.
5. Seed validation pass.
6. E2E smoke pass.
7. Public trace leakage tests pass.
8. MISA dry-run/reconcile evidence.
9. Printer/device readiness or accepted defer.
10. Backup/restore readiness.
11. Monitoring/alerting readiness.
12. Incident response contact list.
13. Rollback/forward-fix plan.

Stop conditions:
- OD-12/OD-13 unresolved and production requires DR/retention sign-off.
- OD-17 unresolved and printer integration is required for go-live.
- Public trace leakage not verified.
- No rollback plan.

Đầu ra bắt buộc:
- Production readiness verdict: READY / READY_WITH_ACCEPTED_RISK / NOT_READY.
- Evidence table.
- Blockers.
- Accepted risks requiring owner sign-off.
- Cập nhật tiến độ.
```

## Prompt 08.02 - Security And Privacy Go-Live Gate

```text
Role:
Bạn là Security/Privacy Review Agent.

Mission:
Run security and privacy go-live gate.

Read first:
1. docs/software-specs/non-functional/03_SECURITY_REQUIREMENTS.md
2. docs/software-specs/business/06_COMPLIANCE_AND_DATA_POLICY.md
3. docs/software-specs/api/05_API_AUTH_PERMISSION_SPEC.md
4. docs/software-specs/modules/12_TRACEABILITY.md

Check:
1. Auth/RBAC enforced backend-side.
2. Privileged actions audited.
3. Public trace whitelist only.
4. Secrets not committed.
5. Error responses do not leak internals.
6. Audit/ledger/history append-only.
7. Break-glass/override audited.
8. Backup/retention quyết định owner handled.

Đầu ra bắt buộc:
- Security verdict.
- Findings by severity.
- Required fixes.
- Accepted risks.
- Cập nhật tiến độ.
```

## Prompt 08.03 - Go/No-Go Meeting Pack

```text
Role:
Bạn là Go-Live PM Agent.

Mission:
Prepare go/no-go meeting pack for owner and leadership.

Read first:
1. docs/software-specs/phase-project/03_PROGRESS_REPORT.md
2. Latest readiness review.
3. Latest UAT sign-off.
4. Latest release candidate summary.

Workflow:
1. Summarize release scope.
2. Summarize evidence kiểm chứng.
3. List open risks and quyết định owner.
4. List accepted deferrals.
5. Present go/no-go recommendation.
6. Prepare exact owner sign-off wording.
7. Update progress report.

Đầu ra bắt buộc:
- Go/no-go deck text.
- Decision recommendation.
- Sign-off wording.
- Risk acceptance table.
- Cập nhật tiến độ.
```

## Prompt 08.04 - Production Deployment And Day-1 Operations

```text
Role:
Bạn là Production Deployment Lead.

Mission:
Execute production deployment for release {version} and run day-1 operational checks.

Read first:
1. Approved go/no-go decision.
2. docs/software-specs/dev-handoff/09_RELEASE_ROLLBACK_GUIDE.md
3. Production readiness review.
4. Release candidate runbook.

Workflow:
1. Confirm deployment window and responsible people.
2. Confirm backup/snapshot before deploy.
3. Confirm migration plan.
4. Deploy release artifact.
5. Apply migration if approved.
6. Apply production seed/config if approved.
7. Run smoke checks.
8. Monitor logs/alerts.
9. Confirm rollback window.
10. Update progress report.

Stop conditions:
- No backup/snapshot when required.
- Migration destructive risk not approved.
- Critical smoke failure.
- Public trace/security failure.

Đầu ra bắt buộc:
- Deployment status: SUCCESS / ROLLED_BACK / FAILED.
- Commands/actions performed.
- Kết quả smoke.
- Incidents.
- Rollback/forward-fix status.
- Day-1 watch items.
- Cập nhật tiến độ.
```

