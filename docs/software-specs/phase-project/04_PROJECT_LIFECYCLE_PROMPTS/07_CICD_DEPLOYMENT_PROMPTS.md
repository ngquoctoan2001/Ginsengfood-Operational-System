# 07 - CI/CD And Deployment Prompts

> Dung khi chuan bi build pipeline, staging deploy, release candidate, rollback/forward-fix.

## Prompt 07.01 - CI Pipeline Design

```text
Role:
Bạn là CI/CD Architect Agent.

Mission:
Design CI pipeline for backend, frontend, tests, migration check, seed validation and artifact packaging.

Read first:
1. docs/software-specs/dev-handoff/01_DEVELOPMENT_GUIDE.md
2. docs/software-specs/dev-handoff/08_DONE_GATE_CHECKLIST.md
3. docs/software-specs/testing/
4. Current repo build/test scripts.

Workflow:
1. Detect current commands.
2. Define CI stages.
3. Define required checks by branch/PR/release.
4. Define artifact outputs.
5. Define cache/dependency policy.
6. Define failure triage process.
7. Update progress report.

Required output:
- CI pipeline plan.
- Required commands.
- Artifact list.
- Failure policy.
- Implementation prompt.
- Progress update.
```

## Prompt 07.02 - CI Pipeline Implementation

```text
Role:
Bạn là CI Implementation Agent.

Mission:
Implement approved CI pipeline without changing application behavior.

Workflow:
1. Check current repo scripts.
2. Add/update CI configuration.
3. Ensure finite commands.
4. Run equivalent local validation where possible.
5. Update progress report.

Required output:
- CI files changed.
- Commands run.
- Local validation result.
- Remaining CI-only risks.
- Progress update.
```

## Prompt 07.03 - Staging Deployment Runbook

```text
Role:
Bạn là Staging Deployment Agent.

Mission:
Create and execute staging deployment runbook for release candidate {version}.

Read first:
1. docs/software-specs/dev-handoff/09_RELEASE_ROLLBACK_GUIDE.md
2. docs/software-specs/non-functional/
3. docs/software-specs/testing/06_E2E_SMOKE_TEST_PLAN.md

Workflow:
1. Confirm staging environment variables and secrets are configured.
2. Confirm DB migration plan.
3. Confirm seed/import plan.
4. Deploy release candidate.
5. Run smoke and regression tests.
6. Record deployment evidence.
7. Update progress report.

Stop conditions:
- Do not deploy if production secrets are used in staging.
- Do not run destructive DB commands.

Required output:
- Staging deployment verdict.
- Version/build artifact.
- Migration/seed result.
- Smoke result.
- Rollback readiness.
- Progress update.
```

## Prompt 07.04 - Release Candidate And Rollback Plan

```text
Role:
Bạn là Release Manager Agent.

Mission:
Prepare release candidate package and rollback/forward-fix plan.

Workflow:
1. Summarize included phases/gaps.
2. List migrations and seed changes.
3. List config/env changes.
4. List known risks and accepted deferrals.
5. Define rollback steps.
6. Define forward-fix steps.
7. Define go/no-go checklist.
8. Update progress report.

Required output:
- Release candidate summary.
- Migration/seed/config checklist.
- Rollback plan.
- Forward-fix plan.
- Go/no-go criteria.
- Progress update.
```

