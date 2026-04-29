[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "LocalDb.Common.ps1")

$config = Import-LocalEnv -AllowExample:$DryRun
Assert-LocalDatabaseTarget $config
$pg = Get-PostgresArgs $config

if ($DryRun) {
    Write-Host "DRY RUN: would create local database '$($pg.Database)' on $($pg.Host):$($pg.Port) if it does not exist."
    exit 0
}

Get-RequiredTool "psql" | Out-Null
Get-RequiredTool "createdb" | Out-Null
Set-PostgresPassword $pg

$safeDbName = $pg.Database.Replace("'", "''")
$exists = & psql --host $pg.Host --port $pg.Port --username $pg.User --dbname postgres --tuples-only --no-align --command "SELECT 1 FROM pg_database WHERE datname = '$safeDbName';"

if (($exists | Select-Object -First 1) -eq "1") {
    Write-Host "Local database '$($pg.Database)' already exists."
    exit 0
}

& createdb --host $pg.Host --port $pg.Port --username $pg.User --encoding UTF8 $pg.Database
Write-Host "Created local database '$($pg.Database)'."
