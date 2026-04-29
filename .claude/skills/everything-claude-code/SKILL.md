---
name: ginsengfood-greenfield-conventions
description: Repository conventions for the greenfield Ginsengfood Operational system workspace.
---

# Ginsengfood Greenfield Conventions

## Overview

This skill records the local repository posture for agent work. The repository is currently a greenfield implementation workspace for Ginsengfood Operational V2.

Use `AGENTS.md` as the primary instruction file and `docs/software-specs/` as the single accepted source of truth.

## Response Language

Tra loi bang tieng Viet cho planning, progress, review, validation, handoff, blockers, risks va final response. Giu nguyen tieng Anh cho technical terms va exact identifiers: file paths, code symbols, route paths, API methods, DTO/table/column/enum names, command lines, package names, JSON/YAML/TOML keys, HTTP status codes, framework/tool names va original log/error text.

## Repository Process Lifecycle

- Prefer finite foreground validation commands.
- Do not leave agent-started `dotnet`, `node`, `npm`, dev server, Playwright, Docker, `Start-Process`, `Start-Job`, or background-shell processes running after final response.
- If a live server is required, record the PID immediately and stop it before handoff.
- Use `tools/agent/Start-AgentOwnedProcess.ps1` and `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants` for tracked long-lived commands in this repo.
- Run `dotnet build-server shutdown` after agent-run .NET build/test/EF sequences.
- Never kill broad process names; only stop PIDs started by the agent.

## Current State

- Application code is not scaffolded yet.
- Missing backend/frontend/database/seed/smoke layers are `NOT_SCAFFOLDED`.
- Do not treat the empty repo as a failed migration.
- Do not require current route maps, migration history, seed deltas, or GitNexus graph evidence before code exists.

## Source Rules

- Source truth: `docs/software-specs/`.
- Historical reference only: `.tmp-docx-extract/`, `specs/`, old DOCX/PDF extracts, historical migrations, old seed SQL, and old prompts.
- If sources conflict, use the precedence in `AGENTS.md` and record the decision in a phase artifact.

## Greenfield Workflow

1. Read `AGENTS.md`.
2. Read `docs/software-specs/01_SOURCE_INDEX.md`.
3. Read relevant canonical specs.
4. Map requirements to intended project structure and validation gates.
5. Implement one bounded phase.
6. Run available gates; mark absent layers as `N/A - not scaffolded yet`.
7. Update handoff or active Markdown task document.

## Ginsengfood Hard Locks

- G1 is the initial operational baseline.
- Future G2/G3 formula versions must remain possible.
- G0 is research/baseline context only.
- Use exactly four G1 recipe groups: `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`.
- Ingredient master must include `ING_MI_CHINH` and `HRB_SAM_SAVIGIN`.
- QC_PASS is not RELEASED.
- Material issue decrements raw-material inventory.
- Warehouse receipt requires RELEASED batch and creates inventory ledger/balance projection.
- Public trace must not expose internal supplier/personnel/costing/QC-defect/loss/MISA data.
- MISA sync must go through a common integration layer.

## Commit Guidance

Use clear conventional commits when commits are requested:

- `feat: scaffold backend baseline`
- `feat: add G1 recipe seed baseline`
- `fix: align public trace field policy`
- `docs: update phase handoff`

Do not commit unless the user asks for it.
