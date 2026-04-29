# Smoke Tools

Finite smoke-check helpers for local, staging, UAT and release verification.

Scripts here must exit on completion and must not start long-lived dev servers. Use `tools/agent/Start-AgentOwnedProcess.ps1` only when a live process is explicitly required by a later phase.
