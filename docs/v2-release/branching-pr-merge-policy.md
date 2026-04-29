# Branching, PR And Merge Policy

## Purpose

This policy defines how AI-agent-assisted implementation is branched, reviewed, validated and merged for Ginsengfood Operational V2.

## Source Basis

- `docs/software-specs/phase-project/01_PHASE_PROJECT_TODO.md`
- `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`
- `docs/software-specs/dev-handoff/08_DONE_GATE_CHECKLIST.md`

## Branching Policy

Use one branch per bounded phase/gap. A branch must not mix unrelated gaps.

| Work type | Branch pattern | Example |
|---|---|---|
| Project/init policy | `project/{topic}` | `project/release-process-policy` |
| Repo/local env | `repo/{gap-id}-{slug}` | `repo/repo-local-env-policy-001-local-db` |
| Architecture foundation | `arch/{gap-id}-{slug}` | `arch/architecture-foundation-adr-baseline` |
| CODE phase implementation | `code{nn}/{gap-id}-{slug}` | `code01/gap-c01-audit-base` |
| DB migration/seed gap | `db/{phase}-{gap-id}-{slug}` | `db/code01-foundation-schema` |
| Frontend/admin UI gap | `ui/{phase}-{gap-id}-{slug}` | `ui/code09-screen-registry` |
| QA/test-only gap | `test/{phase}-{gap-id}-{slug}` | `test/code07-public-trace-denylist` |
| Release/handoff policy | `release/{topic}` | `release/branching-pr-merge-policy` |
| Hotfix after release | `hotfix/{incident-or-gap}-{slug}` | `hotfix/recall-export-null-state` |

Branch rules:

- Include the phase or gap identifier in every implementation branch.
- Keep branch names lowercase, ASCII, hyphen-separated.
- Do not reuse a branch for a second unrelated gap.
- If a gap expands across DB/backend/API/frontend/seed/test, keep it in one branch only when the workflow requires all layers for the same done gate.
- If an owner decision blocks the branch, stop implementation and record the blocker before adding speculative behavior.

## Commit Convention

Use small commits that match the bounded gap.

Pattern:

```text
{type}({phase-or-gap}): {short imperative summary}
```

Allowed `type` values:

- `docs`
- `scaffold`
- `db`
- `seed`
- `api`
- `backend`
- `frontend`
- `test`
- `security`
- `release`
- `fix`

Examples:

```text
scaffold(REPO-LOCAL-ENV): add local DB guard scripts
db(CODE01): add foundation audit schema migration
test(CODE07): add public trace denylist regression
release(CODE17): add go-live evidence checklist
```

## PR Title Template

```text
[{phase}] {gap-id}: {outcome}
```

Examples:

```text
[REPO-LOCAL-ENV] REPO-LOCAL-ENV-POLICY-001: local environment guard scripts
[CODE02] GAP-C02-RAW-LOT-READY: readiness transition and validation
```

## PR Body Template

```markdown
## Summary

- {What changed}
- {What is intentionally not included}

## Requirement Source

- Phase: `{CODE or project phase}`
- Gap: `{gap-id}`
- Sources:
  - `docs/software-specs/...`
- Requirement IDs / rules / tests:
  - `REQ-*`
  - `BR-*`
  - `TC-*`

## Scope

- DB:
- Backend:
- API/DTO:
- Frontend/UI:
- Seed/fixtures:
- Tests:
- Docs/handoff:

## Validation

| Gate | Command/evidence | Result |
|---|---|---|
| Backend build | `{command or N/A}` | `{PASS/FAIL/BLOCKED/N/A}` |
| Backend tests | `{command or N/A}` | `{PASS/FAIL/BLOCKED/N/A}` |
| Frontend build | `{command or N/A}` | `{PASS/FAIL/BLOCKED/N/A}` |
| Frontend tests | `{command or N/A}` | `{PASS/FAIL/BLOCKED/N/A}` |
| Migration/update | `{command or N/A}` | `{PASS/FAIL/BLOCKED/N/A}` |
| Seed validation | `{command or N/A}` | `{PASS/FAIL/BLOCKED/N/A}` |
| Smoke/regression | `{command or N/A}` | `{PASS/FAIL/BLOCKED/N/A}` |
| Process cleanup | `{evidence}` | `{PASS/FAIL}` |

## Review Checklist

- [ ] Source discipline is satisfied.
- [ ] Scope matches one bounded gap.
- [ ] No unrelated refactor or formatting churn.
- [ ] API/FE sync is complete or no-impact evidence is present.
- [ ] DB/seed changes have validation and rollback/forward-fix notes.
- [ ] Security/public-private boundary is reviewed.
- [ ] Audit/idempotency/permission/state gates are preserved.
- [ ] Owner decisions are closed or explicitly deferred.
- [ ] Progress report and handoff are updated.

## Deferred Work

| Deferred item | Reason | Owner decision / risk | Target phase |
|---|---|---|---|
| `{item}` | `{why deferred}` | `{OD/RISK}` | `{phase}` |

## Rollback / Forward Fix

- Rollback:
- Forward fix:
```

## Required Review Gates

| Gate | Required reviewer | Required evidence |
|---|---|---|
| Product/BA source gate | BA or PM | Requirement IDs, source files, conflicts and owner decisions mapped. |
| Tech lead scope gate | Tech Lead | Bounded gap, affected layers, non-goals and dependency impact are clear. |
| DB/seed gate | DBA/Data Engineer when DB/seed touched | Migration order, constraints, seed idempotency and validation plan. |
| API/FE contract gate | Backend + Frontend when API/DTO/UI touched | API catalog/client/types/screens/tests synced or no-impact evidence. |
| QA gate | QA/Test Agent | Relevant unit, integration, API, seed, smoke or regression evidence. |
| Security gate | Security/Compliance when auth, secrets, public trace, device, MISA or destructive action touched | Secret handling, permission, public/private denylist, audit and destructive action checks. |
| Release gate | PM/Release Agent for phase close or CODE17 | Handoff, known risks, deferred work and go/no-go evidence. |

## Validation Required Before Merge

Use the done gates from `08_DONE_GATE_CHECKLIST.md`.

Minimum merge evidence for every PR:

- `DG-001` requirement mapped.
- `DG-002` source discipline satisfied.
- `DG-003` scope controlled.
- `DG-010` handoff/progress updated.
- Process cleanup evidence included.

Conditional evidence:

- Backend touched: backend build and relevant tests must pass, or blocker must be accepted by Tech Lead/PM.
- Frontend touched: frontend build/typecheck/tests must pass, or blocker must be accepted by Tech Lead/PM.
- API/DTO touched: API/FE sync or no-impact evidence is mandatory.
- DB touched: migration apply/update command, validation and rollback/forward-fix note are mandatory.
- Seed touched: seed run, seed validation and idempotency rerun are mandatory.
- Security/public trace/MISA/device/destructive actions touched: security gate is mandatory.
- Release gate touched: smoke/regression and open owner decision review are mandatory.

## Merge Rules

- Merge only through PR review. Direct pushes to protected release branches are not allowed.
- Squash merge is preferred for bounded gaps so branch history remains concise.
- A PR cannot merge with unresolved `NEEDS_OWNER`, `NEEDS_FIX`, failed validation or unreviewed security risk.
- A PR with `BLOCKED` validation can merge only for docs/scaffold/policy work when the blocker is external, recorded in the progress report and accepted by PM/Tech Lead.
- CODE phase completion requires all mandatory done gates for the touched layers; docs-only support work must state `N/A` gates explicitly.
- Do not merge speculative implementation for open owner decisions.
- Do not merge production reset, real secrets, or seed files containing real credentials.

## Deferred Work Recording

Deferred work must be recorded in all applicable locations:

- PR `Deferred Work` table.
- `docs/software-specs/phase-project/03_PROGRESS_REPORT.md` risk or blocker row.
- `docs/v2-handoff/` handoff note if the deferred item affects another role.
- `docs/v2-decisions/` when the deferral depends on owner approval.
- `docs/v2-release/` when the deferral affects release readiness.

Deferred work must include:

- short description;
- reason for deferral;
- target phase or deadline;
- owner decision or risk ID;
- validation impact;
- explicit acceptance owner.
