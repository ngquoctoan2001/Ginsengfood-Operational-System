# Agent Orchestration

## Available Agents

### GitHub Copilot Agents (`.github/agents/`)

Use in GitHub Copilot Chat with `@` mention:

| Agent               | Purpose                                                             | When to Use                           |
| ------------------- | ------------------------------------------------------------------- | ------------------------------------- |
| `Code Reviewer`     | Read-only code review, severity findings (CRITICAL/HIGH/MEDIUM/LOW) | After writing or modifying code       |
| `Codebase Explorer` | Read-only route/schema/seed/contract mapping                        | Before broad implementation changes   |
| `Task Implementer`  | Full-stack feature/gap implementation (.NET 10 + React + Next.js)   | Complex features, V2 Operational gaps |

### Codex Subagents (`.codex/agents/`)

Used by Codex 5.5 internally or by explicit mention:

| Agent                     | Purpose                                              | When to Use                        |
| ------------------------- | ---------------------------------------------------- | ---------------------------------- |
| `operational-implementer` | Implement one approved V2 gap/phase                  | V2 Operational implementation      |
| `operational-gap-auditor` | Audit current code vs. `docs/software-specs/`        | Gap discovery before planning      |
| `reviewer`                | OPERATIONAL v2 correctness, security, contract drift | After implementation, before merge |
| `explorer`                | Fast read-only codebase exploration                  | Before broad changes               |
| `implementation-planner`  | Phased implementation planning                       | Multi-layer complex work           |
| `contract-mapper`         | DB/API/frontend contract mapping                     | Before route or DTO changes        |
| `docs-researcher`         | Lookup in `docs/software-specs/`                     | Requirement clarification          |
| `test-planner`            | Test strategy and case design                        | Before writing tests               |

## Immediate Agent Usage

No prompt needed — invoke by context:

1. Complex V2 gap or new feature → use **Task Implementer**
2. Code just written or modified → use **Code Reviewer**
3. Need to map current code before changes → use **Codebase Explorer**
4. Need architectural/security review → use **reviewer** (Codex)
5. Build fails repeatedly → use **verification-loop** skill

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution

Launch 3 agents in parallel:

1. Agent 1: Security analysis of auth module
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utilities

# BAD: Sequential when unnecessary

First agent 1, then agent 2, then agent 3
```

## Agent Process Cleanup

- Subagents must not leave local processes running after their handoff.
- Any subagent that starts a live server, watcher, Docker compose stack, or background job must report the PID and stop it before returning.
- Parent agents must verify cleanup before final response.
- Use `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants` for tracked PIDs and `dotnet build-server shutdown` after agent-run .NET build/test/EF commands.
- Do not kill broad process names because owner-run terminals may use the same binaries.

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:

- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
