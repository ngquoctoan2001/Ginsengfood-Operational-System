# 06 - Handoff Prompts

## 1. Implementation Handoff Prompt

```text
Write final handoff for gap {gap_id}.

Use this format:
- Summary
- Files changed
- Requirement source
- Evidence used
- Commands run
- Test result
- Backend build result
- Frontend build result
- Process cleanup result
- Markdown update
- Database migration/update result, if applicable
- Seed validation result, if applicable
- API/Frontend sync result, if applicable
- Remaining risks
- Owner decisions
- Next recommended gap
```

## 2. Gap Register Prompt

```text
Update gap register after implementation.

For each remaining gap:
- gap_id
- requirement_id
- module
- phase
- affected layers
- priority
- blocker
- owner decision needed
- suggested next action
```

## 3. Owner Decision Prompt

```text
Prepare owner decision request.

Include:
- Decision id
- Requirement/module/phase
- What is unknown
- Option A
- Option B
- Pros/cons
- Recommendation
- Impact on DB/API/UI/workflow/test/release
- Deadline or blocking phase
```

## 4. Release Handoff Prompt

```text
Prepare release handoff.

Include:
- Release scope
- Phases included
- Migration ids
- Seed version/check result
- Build artifacts
- Test/regression/smoke result
- Public trace leakage evidence
- Lot mark-ready permission and `READY_FOR_PRODUCTION` smoke evidence
- MISA sync/reconcile evidence
- Rollback/forward-fix plan
- Known accepted risks
- Monitoring checks after deploy
```

## 5. No-Impact Evidence Prompt

```text
When claiming no impact, provide evidence:
- No DB impact because...
- No API impact because...
- No FE impact because...
- No seed impact because...
- No migration impact because...
- No public trace/security impact because...
- No MISA/inventory/audit impact because...

Do not write "no impact" without concrete reasoning.
```

## 6. Deferred Work Prompt

```text
Record deferred work only if it is outside current bounded gap or blocked by owner decision.

For each deferred item:
- deferred_id
- reason
- owner decision needed
- risk if deferred
- phase/module to revisit
- validation that remains blocked
```
