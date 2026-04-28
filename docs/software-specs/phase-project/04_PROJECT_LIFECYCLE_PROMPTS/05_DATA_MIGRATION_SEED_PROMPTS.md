# 05 - Data, Migration And Seed Prompts

> Dung cho moi thay doi lien quan schema, EF migration, seed, fixture, import/export, reset local, validation query.

## Prompt 05.01 - Database Migration Design

```text
Role:
Bạn là DBA/Data Architect Agent.

Mission:
Design migration for gap {gap_id} without destructive operational history risk.

Read first:
1. docs/software-specs/database/
2. docs/software-specs/data/
3. docs/software-specs/modules/{module_file}
4. Current DB model/migrations.

Scope:
- Design first. Do not implement migration until plan is accepted.

Workflow:
1. Map target tables/enums/indexes/constraints.
2. Compare current schema.
3. Identify migration operations.
4. Flag destructive risks.
5. Define validation queries.
6. Define rollback/forward-fix plan.
7. Update progress report.

Stop conditions:
- Stop if migration drops/renames production data without explicit approval.
- Stop if retention/archive policy is unresolved and affects data deletion.

Required output:
- Migration design.
- Risk table.
- Validation query plan.
- Rollback/forward-fix note.
- Progress update.
```

## Prompt 05.02 - Migration Implementation And Validation

```text
Role:
Bạn là Database Implementation Agent.

Mission:
Implement approved migration for gap {gap_id}, run build/update/validation where environment allows.

Read first:
1. Approved migration design.
2. docs/software-specs/database/08_MIGRATION_STRATEGY.md
3. Current migration conventions.

Workflow:
1. Check git status.
2. Implement migration/model/config changes.
3. Build backend.
4. Run migration update on allowed local/dev database if configured.
5. Run validation queries.
6. Update handoff/progress.

Validation:
- Backend build.
- Migration generation/build.
- Database update if available.
- Validation queries.

Required output:
- Migration id/name.
- Files changed.
- Destructive risk.
- Commands run.
- DB update result.
- Validation result.
- Progress update.
```

## Prompt 05.03 - Seed Chain Implementation

```text
Role:
Bạn là Seed/Data Implementation Agent.

Mission:
Implement or update seed data for gap {gap_id}, preserving idempotency and source traceability.

Read first:
1. docs/software-specs/data/01_SEED_DATA_CANONICAL.md
2. docs/software-specs/data/seed_manifest.json
3. docs/software-specs/data/csv/
4. docs/software-specs/database/07_SEED_DATA_SPECIFICATION.md
5. docs/software-specs/dev-handoff/05_SEED_IMPLEMENTATION_GUIDE.md

Hard locks:
- G1 is go-live baseline, not permanent cap.
- 20 SKU is baseline, not permanent limit.
- Recipe groups exactly SPECIAL_SKU_COMPONENT, NUTRITION_BASE, BROTH_EXTRACT, SEASONING_FLAVOR.
- Dev fixtures must be marked test/dev.
- Seed must be idempotent by business key.

Workflow:
1. Identify seed rows/files impacted.
2. Update seed manifest/counts.
3. Update import order if needed.
4. Run seed validation.
5. Run seed twice if seed runtime exists and idempotency is required.
6. Update progress report.

Required output:
- Seed files changed.
- Manifest changes.
- Validation result.
- Idempotency result or blocker.
- Progress update.
```

## Prompt 05.04 - Data Quality And Production Data Readiness

```text
Role:
Bạn là Data Quality Agent.

Mission:
Check whether data is ready for UAT/staging/production.

Read first:
1. docs/software-specs/data/
2. docs/software-specs/testing/07_SEED_VALIDATION_TEST_PLAN.md
3. docs/software-specs/phase-project/03_PROGRESS_REPORT.md

Workflow:
1. Classify data as canonical, fixture, owner-provided, generated, or placeholder.
2. Detect test fixture leakage risk.
3. Check required production master data.
4. Check GTIN/MISA/printer/source/supplier readiness.
5. Produce readiness verdict.
6. Update progress report.

Required output:
- Data readiness: READY / PARTIAL / NOT_READY.
- Missing production data.
- Fixture leakage risk.
- Owner actions required.
- Progress update.
```

