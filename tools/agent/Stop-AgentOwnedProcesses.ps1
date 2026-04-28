param(
    [int[]]$Pids = @(),

    [string]$ProcessLedger = ".artifacts/agent-processes/agent-owned-pids.jsonl",

    [switch]$IncludeDescendants,

    [switch]$ListRepoProcesses,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$ledgerPath = Join-Path $repoRoot $ProcessLedger
$trackedPids = New-Object System.Collections.Generic.HashSet[int]

foreach ($trackedPid in $Pids) {
    [void]$trackedPids.Add([int]$trackedPid)
}

if (Test-Path -LiteralPath $ledgerPath) {
    Get-Content -LiteralPath $ledgerPath | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object {
        $record = $_ | ConvertFrom-Json
        if ($record.owner -eq "agent" -and $record.pid) {
            [void]$trackedPids.Add([int]$record.pid)
        }
    }
}

$allProcesses = @()
$cimAvailable = $true
try {
    $allProcesses = Get-CimInstance Win32_Process
} catch {
    $cimAvailable = $false
    Write-Output "Win32_Process query unavailable: $($_.Exception.Message)"
}

if ($ListRepoProcesses) {
    if ($cimAvailable) {
        $allProcesses |
            Where-Object { $_.CommandLine -and $_.CommandLine.IndexOf($repoRoot, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 } |
            Select-Object ProcessId, ParentProcessId, Name, CommandLine |
            Format-Table -AutoSize
    } else {
        Write-Output "Cannot list repo process command lines because Win32_Process query is unavailable."
    }
}

if ($trackedPids.Count -eq 0) {
    Write-Output "No tracked agent-owned PIDs found. No process was stopped."
    Write-Output "Use -ListRepoProcesses to inspect repo-related processes without stopping them."
    exit 0
}

if ($IncludeDescendants -and $cimAvailable) {
    $queue = [System.Collections.Generic.Queue[int]]::new()
    foreach ($trackedPid in $trackedPids) {
        $queue.Enqueue($trackedPid)
    }

    while ($queue.Count -gt 0) {
        $parentPid = $queue.Dequeue()
        $children = $allProcesses | Where-Object { $_.ParentProcessId -eq $parentPid }
        foreach ($child in $children) {
            if ($trackedPids.Add([int]$child.ProcessId)) {
                $queue.Enqueue([int]$child.ProcessId)
            }
        }
    }
} elseif ($IncludeDescendants) {
    Write-Output "Cannot discover descendant processes because Win32_Process query is unavailable. Stopping tracked PIDs only."
}

$currentPid = $PID
$stopped = @()
$missing = @()

foreach ($trackedPid in $trackedPids) {
    if ($trackedPid -eq $currentPid) {
        continue
    }

    $process = Get-Process -Id $trackedPid -ErrorAction SilentlyContinue
    if (-not $process) {
        $missing += $trackedPid
        continue
    }

    $cim = if ($cimAvailable) { $allProcesses | Where-Object { $_.ProcessId -eq $trackedPid } | Select-Object -First 1 } else { $null }
    $summary = if ($cim) { "$($cim.Name) PID $trackedPid $($cim.CommandLine)" } else { "$($process.ProcessName) PID $trackedPid" }

    if ($DryRun) {
        Write-Output "Would stop: $summary"
        continue
    }

    Stop-Process -Id $trackedPid -Force
    $stopped += $summary
}

if ($DryRun) {
    Write-Output "Dry run complete. No process was stopped."
} else {
    foreach ($item in $stopped) {
        Write-Output "Stopped: $item"
    }

    if (Test-Path -LiteralPath $ledgerPath) {
        Clear-Content -LiteralPath $ledgerPath
    }
}

if ($missing.Count -gt 0) {
    Write-Output "Already exited: $($missing -join ', ')"
}
