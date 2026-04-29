# 05 - CODE04 Packaging + QR + Print Prompts

## Scope

Phase `CODE04` covers packaging level 1/2, trade item/GTIN, QR registry, print job, print log, reprint and void lifecycle.

## Prompt 05.01 - CODE04 Kickoff Audit

```text
Role: Packaging/QR Audit Agent.
Mission: Audit packaging, trade item/GTIN, QR and print implementation. Do not edit files.
Read first: modules/10_PACKAGING_PRINTING.md, workflows/04_STATE_MACHINES.md, data/gtin_fixture.csv, api, database, ui, testing.
Hard locks: packaging/printing does not create inventory, QC pass or release; QR states include GENERATED, QUEUED, PRINTED, FAILED, VOID, REPRINTED.
Đầu ra: gap map, first gap, GTIN/printer blockers, cập nhật tiến độ.
```

## Prompt 05.02 - Trade Item And GTIN Plan

```text
Role: Trade Item Planner.
Mission: Plan trade item and GTIN implementation.
Rules:
- Trade item/GTIN/GS1 identity is separate from SKU identity.
- Fake GTIN fixture is test/dev only.
- Missing production GTIN should block commercial print if policy requires it.
Đầu ra: DB/API/UI/seed/test plan, owner data needed, cập nhật tiến độ.
```

## Prompt 05.03 - Packaging Level 1 Implementation

```text
Role: Packaging L1 Agent.
Mission: Implement packaging level 1 workflow.
Rules:
- L1 label prints NSX/HSD according to spec.
- L1 does not release batch or create inventory.
- Actions must be audited.
Đầu ra: backend/API/UI/tests, cập nhật tiến độ.
```

## Prompt 05.04 - Packaging Level 2 Implementation

```text
Role: Packaging L2 Agent.
Mission: Implement packaging level 2 workflow with batch/NSX/HSD/barcode/QR/GTIN where required.
Rules:
- L2 links packaging units to batch and trade item.
- L2 cannot public trace invalid QR.
Đầu ra: DB/backend/API/UI/tests, cập nhật tiến độ.
```

## Prompt 05.05 - QR Registry Lifecycle

```text
Role: QR Lifecycle Agent.
Mission: Implement QR registry lifecycle.
Rules:
- States: GENERATED, QUEUED, PRINTED, FAILED, VOID, REPRINTED.
- Reprint links to original QR/print job and requires reason/audit.
- VOID/FAILED cannot resolve as valid public trace.
Đầu ra: lifecycle service/API/tests, state history evidence, cập nhật tiến độ.
```

## Prompt 05.06 - Print Job And Printer Boundary

```text
Role: Print Boundary Agent.
Mission: Implement print job/log boundary without direct printer DB coupling.
Rules:
- Print request goes through API/adapter boundary.
- Print failure creates auditable log and retry/reprint path.
- Printer model/driver specifics defer to OD-17 if open.
Đầu ra: print job/log changes, device assumptions, tests, cập nhật tiến độ.
```

## Prompt 05.07 - Packaging/QR Admin UI

```text
Role: Frontend Packaging Agent.
Mission: Implement packaging, print queue, QR lifecycle and reprint/void UI.
Rules:
- Show QR state clearly.
- Reprint/void requires reason.
- Hide/disable invalid actions by permission/state.
Đầu ra: UI/API client/tests, cập nhật tiến độ.
```

## Prompt 05.08 - CODE04 Review/Validate/Handoff

```text
Role: QA + Reviewer Agent.
Mission: Validate CODE04.
Required tests: packaging cannot create inventory/release; QR lifecycle transitions valid; reprint audited; VOID/FAILED QR public trace blocked; fake GTIN marked fixture.
Đầu ra: verdict, validation, blockers, cập nhật tiến độ.
```

