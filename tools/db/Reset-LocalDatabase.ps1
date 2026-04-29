[CmdletBinding()]
param(
    [switch]$ConfirmLocalReset,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "LocalDb.Common.ps1")

if (-not $ConfirmLocalReset) {
    throw "Refusing reset. Pass -ConfirmLocalReset for local-only reset."
}

$config = Import-LocalEnv -AllowExample:$DryRun
Assert-LocalDatabaseTarget $config

if ((Get-EnvValue $config "LOCAL_RESET_ALLOWED") -ne "true") {
    throw "Refusing reset because LOCAL_RESET_ALLOWED is not true."
}

$pg = Get-PostgresArgs $config

if ($DryRun) {
    Write-Host "DRY RUN: would drop and recreate local database '$($pg.Database)' on $($pg.Host):$($pg.Port)."
    exit 0
}

Get-RequiredTool "dropdb" | Out-Null
Get-RequiredTool "createdb" | Out-Null
Set-PostgresPassword $pg

& dropdb --host $pg.Host --port $pg.Port --username $pg.User --if-exists $pg.Database
& createdb --host $pg.Host --port $pg.Port --username $pg.User --encoding UTF8 $pg.Database
Write-Host "Reset local database '$($pg.Database)'."
