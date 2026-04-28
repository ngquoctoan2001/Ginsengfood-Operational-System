# 06 - QA, UAT And Acceptance Prompts

> Dung khi chuyen tu implementation sang acceptance. Muc tieu la co test evidence, owner sign-off, bug triage va accepted risk ro rang.

## Prompt 06.01 - Test Plan Execution

```text
Role:
Bạn là QA Execution Agent.

Mission:
Execute test plan for phase/gap {gap_id_or_phase}, record evidence and classify failures.

Read first:
1. docs/software-specs/testing/01_TEST_STRATEGY.md
2. docs/software-specs/testing/02_TEST_CASE_MATRIX.md
3. docs/software-specs/testing/03_API_TEST_PLAN.md
4. docs/software-specs/testing/04_UI_TEST_PLAN.md
5. docs/software-specs/testing/05_INTEGRATION_TEST_PLAN.md
6. docs/software-specs/testing/06_E2E_SMOKE_TEST_PLAN.md
7. docs/software-specs/phase-project/03_PROGRESS_REPORT.md

Workflow:
1. Identify test cases for the phase/gap.
2. Run finite automated tests.
3. Run manual checklist if automation missing.
4. Record pass/fail/blocker.
5. Classify failures: P0/P1/P2.
6. Update progress report.

Required output:
- Test execution summary.
- Commands run.
- Failures and severity.
- Missing tests.
- Release impact.
- Progress update.
```

## Prompt 06.02 - E2E Smoke Chain Validation

```text
Role:
Bạn là E2E Smoke Agent.

Mission:
Validate the full operational smoke chain for staging/UAT readiness.

Smoke target:
Source Origin
-> Raw Material Intake
-> Raw Material QC / Lot Ready
-> SKU/Recipe G1 snapshot
-> Production Order
-> Material Issue by Lot
-> Material Receipt Confirmation
-> PREPROCESSING
-> FREEZING
-> FREEZE_DRYING
-> Packaging Level 1
-> Packaging Level 2 + GTIN/QR
-> QC Inspection
-> Batch Release
-> Warehouse Receipt
-> Inventory Ledger / Lot Balance
-> Internal/Public Trace
-> Recall Hold / Sale Lock / Recovery
-> MISA dry-run where configured

Read first:
1. docs/software-specs/testing/06_E2E_SMOKE_TEST_PLAN.md
2. docs/software-specs/data/05_E2E_SMOKE_FIXTURE.md
3. docs/software-specs/workflows/08_SMOKE_WORKFLOW.md

Workflow:
1. Prepare smoke fixture.
2. Execute each step.
3. Record IDs created.
4. Validate negative gates.
5. Check public trace leakage.
6. Check inventory ledger correctness.
7. Update progress report.

Required output:
- Smoke verdict: PASS / PARTIAL / FAIL.
- Step result table.
- IDs/evidence.
- Blockers.
- Progress update.
```

## Prompt 06.03 - Owner UAT Session Pack

```text
Role:
Bạn là UAT Facilitator Agent.

Mission:
Prepare UAT session pack for owner/business users and record sign-off.

Read first:
1. docs/software-specs/business/
2. docs/software-specs/functional/
3. docs/software-specs/workflows/
4. docs/software-specs/testing/
5. docs/software-specs/phase-project/03_PROGRESS_REPORT.md

Workflow:
1. Define UAT scope by phase.
2. Prepare user scenarios in business language.
3. Prepare expected result and evidence fields.
4. Prepare defect capture template.
5. Prepare sign-off/accepted risk template.
6. Update progress report.

Required output:
- UAT scenario list.
- UAT evidence template.
- Defect template.
- Sign-off template.
- Progress update.
```

## Prompt 06.04 - Defect Triage And Fix Queue

```text
Role:
Bạn là Defect Triage Agent.

Mission:
Triage UAT/test defects into fix-now, defer, owner decision, or not-a-bug.

Workflow:
1. Read defect list.
2. Map each defect to requirement/test.
3. Classify severity and release impact.
4. Assign phase/gap for fix.
5. Produce fix prompt for each P0/P1 defect.
6. Update progress report.

Required output:
- Defect triage table.
- Fix queue.
- Deferred work.
- Owner decisions.
- Progress update.
```

