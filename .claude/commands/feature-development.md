---
name: feature-development
description: Ginsengfood V2 feature workflow for bounded greenfield scaffold or Operational Domain implementation phases.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /feature-development

Use this workflow for one bounded Ginsengfood V2 scaffold or implementation phase.

The repository is greenfield. Missing application layers are `NOT_SCAFFOLDED`, not stale code.

## Response Language

Tra loi bang tieng Viet cho plan, tien do, review, validation, handoff, blocker, risk va final response. Giu nguyen tieng Anh cho technical terms va exact identifiers nhu file paths, code symbols, route paths, API methods, DTO/table/column/enum names, commands, package names, JSON/YAML/TOML keys, HTTP status codes, framework/tool names va original log/error text.

For broad scaffold, schema, seed, workflow, form, traceability, recall, MISA, QR, production, or route work, read the relevant Markdown files in `docs/software-specs/` before planning changes.

## Required Reading

Read `AGENTS.md`, `CLAUDE.md`, `docs/software-specs/ai-agent/01_AI_AGENT_WORKFLOW.md`, and the relevant files in `docs/software-specs/` first.

## Role Sequence

1. BA: capture source requirement, heading, acceptance criteria, conflicts, and owner decisions.
2. PM: define phase scope, dependency, risk, validation gate, and handoff file.
3. Tech Lead: map target DB/backend/API/admin/worker/seed/test impact and route/contract surface.
4. DBA/Data: plan migration, constraints, seed order, idempotency, and validation SQL when data changes.
5. Developer: implement only the approved phase.
6. QA: add happy-path and negative tests from acceptance criteria.
7. DevOps: run available build/test/database/seed/smoke gates and document exact commands.
8. Reviewer/Security: check permissions, audit, public/private boundary, append-only records, and remaining risk.

## Formula Rule

G1 is the initial operational baseline for factory go-live and for the first correct schema, seed, production-order snapshot, material issue, trace, recall, and validation flows. The implementation must still support future accepted formula versions such as G2/G3 through version/status/effective-date governance and immutable production snapshots. G0 is research/baseline context only and must not be active in operational seed, production order, material issue, costing, trace, recall, or handoff.

## Non-Negotiable Operational Rules

Do not collapse recipe sections to two groups. Do not skip material issue/receipt, batch release, inventory ledger, public trace policy, QR lifecycle, permission, audit, or MISA integration boundaries. Initial API routes come from canonical API specs; after route code exists, do not create parallel route families without route impact analysis.

## Process Cleanup

Do not leave agent-started local processes running. Prefer finite foreground commands. If a live server is required, record the PID or start it with `tools/agent/Start-AgentOwnedProcess.ps1`, then stop it before final response with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`. After agent-run .NET build/test/EF commands, run `dotnet build-server shutdown`. Never kill broad process names; only stop PIDs started by the agent.
