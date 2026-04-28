# 18 - CODE17 Final Closeout Prompts

## Scope

Phase `CODE17` is the final release gate: full smoke, release readiness, handoff, go/no-go and production transition.

## Prompt 18.01 - CODE17 Closeout Audit

```text
Role: Release Closeout Audit Agent.
Mission: Audit whether all required phases/gaps are ready for release.
Read first: phase-project/03_PROGRESS_REPORT.md, dev-handoff/08_DONE_GATE_CHECKLIST.md, dev-handoff/09_RELEASE_ROLLBACK_GUIDE.md, testing/06_E2E_SMOKE_TEST_PLAN.md.
Workflow: check P0/P1/P2 status, validation evidence, owner decisions, accepted risks, deferred work.
Output: release readiness gap list, go/no-go blockers, progress update.
```

## Prompt 18.02 - Full Operational Smoke

```text
Role: E2E Smoke Agent.
Mission: Run full smoke source -> raw -> production -> packaging -> QC -> release -> warehouse -> trace -> recall -> MISA dry-run where configured.
Read first: data/05_E2E_SMOKE_FIXTURE.md, workflows/08_SMOKE_WORKFLOW.md, testing/06_E2E_SMOKE_TEST_PLAN.md.
Output: step result table, IDs/evidence, failure classification, progress update.
```

## Prompt 18.03 - Release Candidate Handoff

```text
Role: Release Manager Agent.
Mission: Prepare release candidate handoff.
Include: scope, phases, migrations, seed version, build artifacts, test result, smoke result, rollback, known risks, accepted deferrals, monitoring checks.
Output: release handoff, owner sign-off items, progress update.
```

## Prompt 18.04 - Go/No-Go Decision Pack

```text
Role: Go-Live PM Agent.
Mission: Prepare go/no-go decision pack for owner/leadership.
Output: GO / GO_WITH_ACCEPTED_RISK / NO_GO recommendation, evidence table, blockers, decision text, progress update.
```

## Prompt 18.05 - Production Transition Handoff

```text
Role: Operations Handoff Agent.
Mission: Prepare production operations handoff for support/hypercare.
Include: support contacts, runbooks, monitoring, incident response, rollback, known risks, first-week watch list.
Output: operations handoff, progress update.
```

