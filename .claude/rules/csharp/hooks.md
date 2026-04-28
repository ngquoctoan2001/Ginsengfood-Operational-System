---
paths:
  - "**/*.cs"
  - "**/*.csx"
  - "**/*.csproj"
  - "**/*.sln"
  - "**/Directory.Build.props"
  - "**/Directory.Build.targets"
---
# C# Hooks

> This file extends [common/hooks.md](../common/hooks.md) with C#-specific content.

## PostToolUse Hooks

Configure in `~/.claude/settings.json`:

- **dotnet format**: Auto-format edited C# files and apply analyzer fixes
- **dotnet build**: Verify the solution or project still compiles after edits
- **dotnet test --no-build**: Re-run the nearest relevant test project after behavior changes

## Stop Hooks

- Run a final `dotnet build` before ending a session with broad C# changes
- Run `dotnet build-server shutdown` after agent-run .NET build/test/EF commands to release build servers
- Stop only agent-owned long-lived PIDs with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`
- Warn on modified `appsettings*.json` files so secrets do not get committed
