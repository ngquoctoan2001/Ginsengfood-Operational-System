# 03 - Architecture Foundation Prompts

> Dung truoc khi implement business workflows. Muc tieu la khoa architecture, conventions, module skeleton, API/DB/UI boundary va ADR.

## Prompt 03.01 - Architecture Decision And ADR Baseline

```text
Role:
Bạn là Solution Architect Agent.

Mission:
Tạo architecture baseline và ADR plan cho Operational V2 trước khi code implementation.

Read first:
1. docs/software-specs/architecture/
2. docs/software-specs/06_MODULE_MAP.md
3. docs/software-specs/api/
4. docs/software-specs/database/
5. docs/software-specs/non-functional/

Scope:
- Architecture analysis and ADR docs.
- Do not implement code unless explicitly approved.

Workflow:
1. Summarize target architecture.
2. Identify containers/layers.
3. Map modules M01-M16 to layers.
4. Define cross-cutting decisions: auth, audit, idempotency, events/outbox, API envelope, DB migration, frontend client.
5. Create ADR backlog.
6. Identify decisions that need owner/tech lead approval.
7. Update progress report.

Required output:
- Architecture baseline.
- ADR table.
- Module/layer map.
- Risks and open decisions.
- Progress update.
```

## Prompt 03.02 - Coding Convention And Guardrail Prompt

```text
Role:
Bạn là Coding Standards Agent.

Mission:
Tạo coding convention và guardrails để mọi AI agents implement đồng nhất.

Read first:
1. docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md
2. docs/software-specs/dev-handoff/
3. docs/software-specs/api/01_API_CONVENTION.md
4. docs/software-specs/database/08_MIGRATION_STRATEGY.md

Workflow:
1. Define naming conventions by layer.
2. Define DTO/API envelope/error/pagination conventions.
3. Define DB table/column/index/constraint conventions.
4. Define frontend client/type/form state conventions.
5. Define test naming and REQ/TC mapping.
6. Define forbidden patterns.
7. Update progress report.

Required output:
- Coding convention checklist.
- Forbidden pattern list.
- Agent pre-edit checklist.
- Progress update.
```

## Prompt 03.03 - Module Skeleton And Boundary Audit

```text
Role:
Bạn là Module Boundary Agent.

Mission:
Audit or create module skeleton aligned to M01-M16 without duplicating business truth.

Read first:
1. docs/software-specs/06_MODULE_MAP.md
2. docs/software-specs/modules/
3. Current repository structure.

Scope:
- Audit first.
- Implement skeleton only if explicitly approved and write scope is clear.

Workflow:
1. Map existing code folders to M01-M16.
2. Detect missing/duplicated module boundaries.
3. Detect legacy naming that conflicts with canonical modules.
4. Propose module skeleton changes.
5. If approved, implement only skeleton/no business logic.
6. Update progress report.

Stop conditions:
- Stop if skeleton change would move large code without refactor approval.
- Stop if two modules would own the same business truth.

Required output:
- Module boundary map.
- Missing/duplicate boundary report.
- Skeleton plan or patch.
- Validation result.
- Progress update.
```

## Prompt 03.04 - Foundation Technical Spike

```text
Role:
Bạn là Foundation Spike Agent.

Mission:
Validate that the chosen stack can support auth/RBAC, audit, idempotency, EF/schema migration, frontend API client, background worker/outbox and test automation.

Read first:
1. docs/software-specs/modules/01_FOUNDATION_CORE.md
2. docs/software-specs/modules/02_AUTH_PERMISSION.md
3. docs/software-specs/api/
4. docs/software-specs/database/
5. docs/software-specs/testing/

Workflow:
1. Identify technical capabilities required.
2. Audit current repo capability.
3. Create spike checklist.
4. Implement minimal spike only if approved.
5. Validate with finite commands.
6. Record lessons and blockers.

Required output:
- Spike result.
- Capability matrix.
- Commands run.
- Risks.
- Progress update.
```

