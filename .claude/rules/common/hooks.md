# Hooks System

## Hook Types

- **PreToolUse**: Before tool execution (validation, parameter modification)
- **PostToolUse**: After tool execution (auto-format, checks)
- **Stop**: When session ends (final verification)

## Stop Hook Process Cleanup

- Stop hooks must clean up only processes started by the agent session.
- Prefer tracked PIDs. Use `tools/agent/Start-AgentOwnedProcess.ps1` for long-lived commands and `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants` at session end.
- After agent-run .NET build/test/EF commands, run `dotnet build-server shutdown`.
- Never kill broad process names such as all `dotnet`, `node`, `npm`, `testhost`, or `VBCSCompiler`; those may belong to the owner.
- If process ownership is unclear, list/report it instead of stopping it.

## Auto-Accept Permissions

Use with caution:
- Enable for trusted, well-defined plans
- Disable for exploratory work
- Never use dangerously-skip-permissions flag
- Configure `allowedTools` in `~/.claude.json` instead

## TodoWrite Best Practices

Use TodoWrite tool to:
- Track progress on multi-step tasks
- Verify understanding of instructions
- Enable real-time steering
- Show granular implementation steps

Todo list reveals:
- Out of order steps
- Missing items
- Extra unnecessary items
- Wrong granularity
- Misinterpreted requirements
