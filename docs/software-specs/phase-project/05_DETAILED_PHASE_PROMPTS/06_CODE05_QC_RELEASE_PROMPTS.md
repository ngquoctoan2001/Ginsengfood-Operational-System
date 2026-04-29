# 06 - CODE05 QC + Batch Release Prompts

## Scope

Phase `CODE05` covers QC inspection, QC items, disposition, batch release, release audit and state transitions.

## Prompt 06.01 - CODE05 Kickoff Audit

```text
Role: QC/Release Audit Agent.
Mission: Audit QC and release implementation. Do not edit files.
Read first: modules/09_QC_RELEASE.md, business/02_BUSINESS_RULES.md, database/04_ENUM_REFERENCE.md, api, ui, testing.
Hard locks: QC_PASS is not RELEASED; QC statuses are QC_PASS, QC_HOLD, QC_REJECT.
Đầu ra: gap map, enum drift report, first gap, cập nhật tiến độ.
```

## Prompt 06.02 - QC Inspection Plan

```text
Role: QC Planner.
Mission: Plan QC inspection/disposition implementation.
Workflow: define inspection types, result enum, item checks, disposition, permission, audit, API/UI/tests.
Đầu ra: plan, write scope, gate kiểm chứng, cập nhật tiến độ.
```

## Prompt 06.03 - QC Backend/API Implementation

```text
Role: QC Backend/API Agent.
Mission: Implement QC inspection and result handling.
Rules:
- Use QC_PASS/QC_HOLD/QC_REJECT consistently.
- QC result must not auto-release batch.
- QC_HOLD/QC_REJECT block downstream release/warehouse receipt.
Đầu ra: schema/service/API/tests, cập nhật tiến độ.
```

## Prompt 06.04 - Batch Release Implementation

```text
Role: Batch Release Agent.
Mission: Implement distinct batch release action/record.
Rules:
- Release requires eligible QC result and required packaging/process evidence.
- Release is permissioned, audited and state-transition logged.
- Release cannot be faked by changing batch status directly.
Đầu ra: release service/API/UI/tests, audit evidence, cập nhật tiến độ.
```

## Prompt 06.05 - QC/Release Admin UI

```text
Role: Frontend QC Agent.
Mission: Implement QC inspection and release queue UI.
Rules:
- Show QC result separately from release status.
- Block release action when QC not eligible.
- Require reason/approval where API requires.
Đầu ra: UI/API sync/tests, cập nhật tiến độ.
```

## Prompt 06.06 - CODE05 Test/Review/Handoff

```text
Role: QA + Reviewer Agent.
Mission: Validate QC/release separation.
Required tests: QC_PASS not RELEASED; QC_REJECT blocks release; release creates op_batch_release/state log; unauthorized release blocked; warehouse receipt blocked before release.
Đầu ra: verdict, commands, findings, cập nhật tiến độ.
```

