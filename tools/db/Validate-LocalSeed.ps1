[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "LocalDb.Common.ps1")

$config = Import-LocalEnv -AllowExample:$DryRun
Assert-LocalDatabaseTarget $config
$pg = Get-PostgresArgs $config

$validationFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot "db/validation") -Filter "*.sql" -File -ErrorAction SilentlyContinue | Sort-Object Name)
if (-not $validationFiles) {
    Write-Host "N/A - no seed validation SQL files exist yet."
    exit 0
}

if ($DryRun) {
    Write-Host "DRY RUN: would run validation files:"
    $validationFiles | ForEach-Object { Write-Host " - $($_.FullName)" }
    exit 0
}

Get-RequiredTool "psql" | Out-Null
Set-PostgresPassword $pg

foreach ($file in $validationFiles) {
    Write-Host "Validating seed: $($file.Name)"
    & psql --host $pg.Host --port $pg.Port --username $pg.User --dbname $pg.Database --set ON_ERROR_STOP=1 --file $file.FullName
}
