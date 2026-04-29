[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$IncludeFixtures
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "LocalDb.Common.ps1")

$config = Import-LocalEnv -AllowExample:$DryRun
Assert-LocalDatabaseTarget $config
$pg = Get-PostgresArgs $config

$seedFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot "db/seeds") -Filter "*.sql" -File -ErrorAction SilentlyContinue | Sort-Object Name)

if ($IncludeFixtures) {
    $fixtureFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot "db/fixtures") -Filter "*.sql" -File -ErrorAction SilentlyContinue | Sort-Object Name)
    $seedFiles += $fixtureFiles
}

if (-not $seedFiles) {
    Write-Host "N/A - no seed SQL files exist yet."
    exit 0
}

if ($DryRun) {
    Write-Host "DRY RUN: would apply seed files:"
    $seedFiles | ForEach-Object { Write-Host " - $($_.FullName)" }
    exit 0
}

Get-RequiredTool "psql" | Out-Null
Set-PostgresPassword $pg

foreach ($file in $seedFiles) {
    Write-Host "Applying seed: $($file.Name)"
    & psql --host $pg.Host --port $pg.Port --username $pg.User --dbname $pg.Database --set ON_ERROR_STOP=1 --file $file.FullName
}
