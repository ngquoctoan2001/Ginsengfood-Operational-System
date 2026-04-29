[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "LocalDb.Common.ps1")

$config = Import-LocalEnv -AllowExample:$DryRun
Assert-LocalDatabaseTarget $config

$migrationFiles = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "db/migrations") -File -ErrorAction SilentlyContinue
if (-not $migrationFiles) {
    Write-Host "N/A - no migration files exist yet. Run this after the CODE01 database baseline creates migrations."
    exit 0
}

$command = @(
    "ef", "database", "update",
    "--project", "services/operational-api/src/Ginsengfood.Operational.Infrastructure/Ginsengfood.Operational.Infrastructure.csproj",
    "--startup-project", "services/operational-api/src/Ginsengfood.Operational.Api/Ginsengfood.Operational.Api.csproj"
)

if ($DryRun) {
    Write-Host "DRY RUN: dotnet $($command -join ' ')"
    exit 0
}

& dotnet @command
