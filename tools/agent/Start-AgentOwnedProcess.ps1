param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [string[]]$ArgumentList = @(),

    [string]$WorkingDirectory = (Get-Location).Path,

    [string]$ProcessLedger = ".artifacts/agent-processes/agent-owned-pids.jsonl"
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$resolvedWorkingDirectory = (Resolve-Path $WorkingDirectory).Path
$ledgerPath = Join-Path $repoRoot $ProcessLedger
$ledgerDirectory = Split-Path -Parent $ledgerPath

if (-not $resolvedWorkingDirectory.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "WorkingDirectory must stay under repo root: $repoRoot"
}

if (-not (Test-Path -LiteralPath $ledgerDirectory)) {
    New-Item -ItemType Directory -Path $ledgerDirectory -Force | Out-Null
}

$process = Start-Process -FilePath $FilePath `
    -ArgumentList $ArgumentList `
    -WorkingDirectory $resolvedWorkingDirectory `
    -PassThru `
    -WindowStyle Hidden

$record = [ordered]@{
    pid = $process.Id
    filePath = $FilePath
    arguments = ($ArgumentList -join " ")
    workingDirectory = $resolvedWorkingDirectory
    startedAt = (Get-Date).ToString("o")
    owner = "agent"
}

($record | ConvertTo-Json -Compress) | Add-Content -LiteralPath $ledgerPath -Encoding UTF8

Write-Output "Started agent-owned process PID $($process.Id): $FilePath $($ArgumentList -join ' ')"
Write-Output "Ledger: $ledgerPath"
