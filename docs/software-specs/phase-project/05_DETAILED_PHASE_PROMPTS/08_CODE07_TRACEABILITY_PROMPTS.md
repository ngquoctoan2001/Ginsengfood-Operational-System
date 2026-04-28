# 08 - CODE07 Traceability Prompts

## Scope

Phase `CODE07` covers internal trace, public trace, genealogy search, QR resolve and public/private field policy.

## Prompt 08.01 - CODE07 Kickoff Audit

```text
Role: Traceability Audit Agent.
Mission: Audit traceability implementation. Do not edit files.
Read first: modules/12_TRACEABILITY.md, data/public_trace_policy.csv, workflows/08_SMOKE_WORKFLOW.md, api, database, ui, testing.
Owner blockers: OD-11 trace query SLA, OD-14 public trace i18n.
Hard locks: public trace must not expose supplier/internal personnel/costing/QC defect/loss/MISA data.
Output: gap map, public leakage risk, SLA/i18n blockers, first gap, progress update.
```

## Prompt 08.02 - Internal Genealogy Plan

```text
Role: Trace Planner.
Mission: Plan internal genealogy and trace search.
Workflow: map source/raw lot -> material issue -> production/batch -> packaging/QR -> warehouse -> recall exposure.
Output: DB/view/index/API/UI/test plan, SLA owner blockers, progress update.
```

## Prompt 08.03 - Internal Trace Backend/API

```text
Role: Trace Backend/API Agent.
Mission: Implement internal trace/genealogy.
Rules:
- Trace must reuse operational truth; do not create duplicate trace truth.
- Backward and forward trace must include source/raw/material/batch/packaging/warehouse links.
Output: service/API/views/tests, performance note, progress update.
```

## Prompt 08.04 - Public Trace Whitelist

```text
Role: Public Trace Agent.
Mission: Implement public trace whitelist and QR resolve.
Rules:
- Use public_trace_policy.csv.
- Public-friendly batch code must preserve customer traceability; do not mask beyond usability.
- VOID/FAILED QR invalid for public trace.
Output: public API, whitelist enforcement tests, leakage tests, progress update.
```

## Prompt 08.05 - Trace Admin/Public UI

```text
Role: Frontend Trace Agent.
Mission: Implement internal trace search, genealogy view and public trace preview.
Rules:
- Internal view may show allowed operational evidence by permission.
- Public preview must use public API/whitelist only.
Output: UI/API client/tests, progress update.
```

## Prompt 08.06 - Trace Performance/SLA Decision

```text
Role: Performance/Owner Decision Agent.
Mission: Prepare OD-11 trace query SLA decision and implementation impact.
Output: options, recommendation, DB/API/index/test impact, blocking phase, progress update.
```

## Prompt 08.07 - CODE07 Review/Validate/Handoff

```text
Role: QA + Security Reviewer.
Mission: Validate traceability.
Required tests: backward/forward genealogy; public denylist; invalid QR; no supplier/personnel/costing/QC defect/loss/MISA leakage; performance test if OD-11 closed.
Output: verdict, findings, owner blockers, progress update.
```

