<#
.SYNOPSIS
Synchronizes GitHub Copilot skill folders into the Codex skills directory.

.DESCRIPTION
Creates directory junctions in the user's Codex skills directory that point to
the canonical skill folders in this repository. This keeps the repository as
the single source of truth while making the same skills available to Codex and
Codex CLI.

.PARAMETER SourceRoot
Root directory containing Copilot skills. Defaults to features/skills under the
repository root.

.PARAMETER CodexHome
Codex home directory. Defaults to $env:CODEX_HOME when set, otherwise
$HOME\.codex.

.PARAMETER Prune
Removes previously-created junctions in the Codex skills directory whose source
skill no longer exists in the repository.

.EXAMPLE
pwsh -File .\scripts\sync-codex-skills.ps1

.EXAMPLE
pwsh -File .\scripts\sync-codex-skills.ps1 -Prune
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$SourceRoot = (Join-Path $PSScriptRoot "..\features\skills"),

    [Parameter()]
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),

    [Parameter()]
    [switch]$Prune
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-NormalizedPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    return [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).Path)
}

function Test-Junction {
    param(
        [Parameter(Mandatory)]
        [System.IO.DirectoryInfo]$Item
    )

    return ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
}

function Get-JunctionTargetPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $item = Get-Item -LiteralPath $Path -Force
    if (-not ($item.LinkType -eq "Junction" -or $item.LinkType -eq "SymbolicLink")) {
        return $null
    }

    $target = $item.Target
    if ($target -is [System.Array]) {
        $target = $target[0]
    }

    if (-not $target) {
        return $null
    }

    return [System.IO.Path]::GetFullPath($target)
}

$sourceRootPath = Resolve-NormalizedPath -Path $SourceRoot
if (-not (Test-Path -LiteralPath $sourceRootPath -PathType Container)) {
    throw "Skill source root not found: $sourceRootPath"
}

$codexHomePath = [System.IO.Path]::GetFullPath($CodexHome)
$codexSkillsPath = Join-Path $codexHomePath "skills"

if (-not (Test-Path -LiteralPath $codexSkillsPath -PathType Container)) {
    New-Item -ItemType Directory -Path $codexSkillsPath | Out-Null
}

$sourceSkills = Get-ChildItem -LiteralPath $sourceRootPath -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf } |
    Sort-Object -Property Name

if (-not $sourceSkills) {
    throw "No SKILL.md folders found under $sourceRootPath"
}

$created = [System.Collections.Generic.List[string]]::new()
$updated = [System.Collections.Generic.List[string]]::new()
$unchanged = [System.Collections.Generic.List[string]]::new()
$skipped = [System.Collections.Generic.List[string]]::new()
$pruned = [System.Collections.Generic.List[string]]::new()

foreach ($skill in $sourceSkills) {
    $targetPath = Join-Path $codexSkillsPath $skill.Name
    $sourcePath = [System.IO.Path]::GetFullPath($skill.FullName)

    if (-not (Test-Path -LiteralPath $targetPath)) {
        New-Item -ItemType Junction -Path $targetPath -Target $sourcePath | Out-Null
        $created.Add($skill.Name)
        continue
    }

    $existingItem = Get-Item -LiteralPath $targetPath -Force
    $existingTarget = Get-JunctionTargetPath -Path $targetPath

    if ($existingTarget -and ($existingTarget -ieq $sourcePath)) {
        $unchanged.Add($skill.Name)
        continue
    }

    if (Test-Junction -Item $existingItem) {
        Remove-Item -LiteralPath $targetPath -Force
        New-Item -ItemType Junction -Path $targetPath -Target $sourcePath | Out-Null
        $updated.Add($skill.Name)
        continue
    }

    $skipped.Add($skill.Name)
}

if ($Prune) {
    $expectedTargets = @{}
    foreach ($skill in $sourceSkills) {
        $expectedTargets[$skill.Name] = [System.IO.Path]::GetFullPath($skill.FullName)
    }

    Get-ChildItem -LiteralPath $codexSkillsPath -Directory | ForEach-Object {
        if ($_.Name -eq ".system") {
            return
        }

        $existingTarget = Get-JunctionTargetPath -Path $_.FullName
        if (-not $existingTarget) {
            return
        }

        if ($expectedTargets.ContainsKey($_.Name)) {
            return
        }

        if ($existingTarget.StartsWith($sourceRootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $_.FullName -Force
            $pruned.Add($_.Name)
        }
    }
}

Write-Host "Codex skills directory: $codexSkillsPath"
Write-Host "Skill source root: $sourceRootPath"
Write-Host ""
Write-Host ("Created : {0}" -f ($(if ($created.Count) { $created -join ", " } else { "-" })))
Write-Host ("Updated : {0}" -f ($(if ($updated.Count) { $updated -join ", " } else { "-" })))
Write-Host ("Unchanged: {0}" -f ($(if ($unchanged.Count) { $unchanged -join ", " } else { "-" })))
Write-Host ("Skipped : {0}" -f ($(if ($skipped.Count) { $skipped -join ", " } else { "-" })))
if ($Prune) {
    Write-Host ("Pruned  : {0}" -f ($(if ($pruned.Count) { $pruned -join ", " } else { "-" })))
}

if ($skipped.Count -gt 0) {
    Write-Warning "Skipped entries already exist as normal directories or files in the Codex skills path. Review them manually before re-running."
}
