param(
    [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Update-TextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Transform
    )

    $path = Join-Path $RepoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        Write-Output "SKIP missing: $RelativePath"
        return
    }

    $old = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $new = & $Transform $old
    if ($new -eq $old) {
        Write-Output "OK unchanged: $RelativePath"
        return
    }

    if ($CheckOnly) {
        Write-Output "WOULD update: $RelativePath"
        return
    }

    try {
        [System.IO.File]::WriteAllText($path, $new, $Utf8NoBom)
        Write-Output "UPDATED: $RelativePath"
    }
    catch {
        Write-Output "FAILED access denied or write error: $RelativePath"
        Write-Output $_.Exception.Message
    }
}

function Replace-Many {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [object[]]$Pairs
    )

    $value = $Text
    foreach ($pair in $Pairs) {
        $value = $value.Replace($pair[0], $pair[1])
    }
    return $value
}

function Get-NewLine {
    param([Parameter(Mandatory = $true)][string]$Text)
    if ($Text.Contains("`r`n")) {
        return "`r`n"
    }

    return "`n"
}

$VietnameseOutputBlock = @"
Response language:
- Write progress updates, validation reports, handoff notes, and final-response section headings in Vietnamese.
- Do not use English standalone headings such as Progress Report Update, Commands Run, Validation, Summary, Files Changed, or Process Cleanup Result.
- Use Vietnamese headings from root AGENTS.md: Tóm tắt, File đã sửa, Nguồn yêu cầu, Evidence đã dùng, Lệnh đã chạy, Kết quả test, Kết quả backend build, Kết quả frontend build, Kết quả cleanup process, Cập nhật Markdown, Cập nhật handoff, and Rủi ro còn lại.
"@

$HeadingPairs = @(
    @("Final output:", "Đầu ra cuối:"),
    @("Validation:", "Kiểm chứng:"),
    @("- Summary", "- Tóm tắt"),
    @("- Files changed", "- File đã sửa"),
    @("- Requirement source", "- Nguồn yêu cầu"),
    @("- Evidence used", "- Evidence đã dùng"),
    @("- Commands run", "- Lệnh đã chạy"),
    @("- Test result", "- Kết quả test"),
    @("- Backend build result", "- Kết quả backend build"),
    @("- Frontend build result", "- Kết quả frontend build"),
    @("- Database migration/update result, when applicable", "- Kết quả database migration/update, nếu áp dụng"),
    @("- Migration/update result, if applicable", "- Kết quả migration/update, nếu áp dụng"),
    @("- Seed validation result, when applicable", "- Kết quả seed validation, nếu áp dụng"),
    @("- Seed validation result, if applicable", "- Kết quả seed validation, nếu áp dụng"),
    @("- Smoke result, if applicable", "- Kết quả smoke, nếu áp dụng"),
    @("- Markdown/handoff update", "- Cập nhật Markdown/handoff"),
    @("- Process cleanup result", "- Kết quả cleanup process"),
    @("- Remaining risks", "- Rủi ro còn lại"),
    @("- Next recommended action", "- Hành động khuyến nghị tiếp theo")
)

Update-TextFile ".codex\AGENTS.md" {
    param([string]$Text)

    if ($Text.Contains("## Response Language")) {
        return $Text
    }

    $insert = @"
## Response Language

Codex responses, progress notes, validation reports, handoff notes, and final-response section headings must be in Vietnamese.

Do not use English final-response headings such as Progress Report Update, Commands Run, Validation, Summary, Files Changed, or Process Cleanup Result. Use Vietnamese headings such as Tóm tắt, Lệnh đã chạy, Kết quả test, Kết quả cleanup process, and Cập nhật handoff.

"@

    $newLine = Get-NewLine -Text $Text
    $needle = 'The repository root `AGENTS.md` remains the primary project instruction file.' + $newLine + $newLine
    return $Text.Replace(
        $needle,
        $needle + $insert
    )
}

Update-TextFile ".codex\config.toml" {
    param([string]$Text)

    $newLine = Get-NewLine -Text $Text
    if (-not $Text.Contains("Response language:")) {
        $Text = $Text.Replace(
            "Follow the repository root AGENTS.md first.$newLine$newLine",
            "Follow the repository root AGENTS.md first.$newLine$newLine$VietnameseOutputBlock$newLine$newLine"
        )
    }

    if (-not $Text.Contains("Use Vietnamese headings from root AGENTS.md")) {
        $Text = $Text.Replace(
            "Operate in greenfield Ginsengfood V2 Operational build mode.$newLine$newLine",
            "Operate in greenfield Ginsengfood V2 Operational build mode.$newLine$newLine$VietnameseOutputBlock$newLine$newLine"
        )
    }

    return $Text
}

$AgentFiles = Get-ChildItem -LiteralPath (Join-Path $RepoRoot ".codex\agents") -Filter "*.toml" -File
foreach ($file in $AgentFiles) {
    $relativePath = $file.FullName.Substring($RepoRoot.Length + 1)
    Update-TextFile $relativePath {
        param([string]$Text)

        $updated = Replace-Many -Text $Text -Pairs $HeadingPairs
        if ($updated.Contains("Write progress updates, validation reports")) {
            return $updated
        }

        $updated = $updated.Replace(
            "developer_instructions = """"`r`n",
            "developer_instructions = """"`r`n$VietnameseOutputBlock`r`n`r`n"
        )
        return $updated
    }
}

Update-TextFile ".agents\skills\ginsengfood-greenfield-build\SKILL.md" {
    param([string]$Text)

    $updated = $Text
    if (-not $updated.Contains("Final response section headings must also be Vietnamese.")) {
        $updated = $updated.Replace(
            "Write plans, progress notes, handoff, validation reports, risks, owner decisions, and final responses in Vietnamese unless the user asks otherwise.`r`n",
            "Write plans, progress notes, handoff, validation reports, risks, owner decisions, and final responses in Vietnamese unless the user asks otherwise.`r`n`r`nFinal response section headings must also be Vietnamese. Do not use English headings such as Progress Report Update, Commands Run, Validation, Summary, Files Changed, or Process Cleanup Result. Use Vietnamese headings from root AGENTS.md.`r`n"
        )
    }

    $updated = Replace-Many -Text $updated -Pairs $HeadingPairs
    $updated = $updated.Replace("After implementation, report in Vietnamese:", "After implementation, report in Vietnamese with Vietnamese headings:")
    return $updated
}




