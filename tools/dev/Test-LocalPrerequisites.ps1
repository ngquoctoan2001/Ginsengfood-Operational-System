[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../..")

function Add-Check {
    param(
        [string]$Name,
        [string]$Status,
        [string]$Detail
    )

    [PSCustomObject]@{
        Name = $Name
        Status = $Status
        Detail = $Detail
    }
}

function Get-CommandVersion {
    param([string]$Command, [string[]]$Arguments)

    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $cmd) {
        return $null
    }

    try {
        return (& $Command @Arguments 2>$null | Select-Object -First 1)
    }
    catch {
        return "installed; version check failed: $($_.Exception.Message)"
    }
}

$checks = New-Object System.Collections.Generic.List[object]

$dotnet = Get-CommandVersion "dotnet" @("--version")
if ($dotnet) { $checks.Add((Add-Check ".NET SDK" "OK" $dotnet)) } else { $checks.Add((Add-Check ".NET SDK" "FAIL" "dotnet not found")) }

$node = Get-CommandVersion "node" @("--version")
if ($node) { $checks.Add((Add-Check "Node.js" "OK" $node)) } else { $checks.Add((Add-Check "Node.js" "FAIL" "node not found")) }

$npm = Get-CommandVersion "npm" @("--version")
if ($npm) { $checks.Add((Add-Check "npm" "OK" $npm)) } else { $checks.Add((Add-Check "npm" "FAIL" "npm not found")) }

$psql = Get-CommandVersion "psql" @("--version")
if ($psql) { $checks.Add((Add-Check "PostgreSQL CLI" "OK" $psql)) } else { $checks.Add((Add-Check "PostgreSQL CLI" "WARN" "psql not found; DB init/seed commands need PostgreSQL CLI")) }

$envExample = Join-Path $repoRoot ".env.example"
if (Test-Path -LiteralPath $envExample) { $checks.Add((Add-Check ".env.example" "OK" "template exists")) } else { $checks.Add((Add-Check ".env.example" "FAIL" "template missing")) }

$envLocal = Join-Path $repoRoot ".env.local"
if (Test-Path -LiteralPath $envLocal) { $checks.Add((Add-Check ".env.local" "OK" "local env file exists and is gitignored")) } else { $checks.Add((Add-Check ".env.local" "WARN" "create from .env.example before DB commands")) }

$gitignore = Join-Path $repoRoot ".gitignore"
if ((Test-Path -LiteralPath $gitignore) -and (Select-String -LiteralPath $gitignore -Pattern "^\.env$|^\.env\.\*$" -Quiet)) {
    $checks.Add((Add-Check "Secret file ignore" "OK" ".env and .env.* are ignored"))
}
else {
    $checks.Add((Add-Check "Secret file ignore" "FAIL" ".env ignore rule missing"))
}

$checks | Format-Table -AutoSize

if ($checks.Status -contains "FAIL") {
    exit 1
}
