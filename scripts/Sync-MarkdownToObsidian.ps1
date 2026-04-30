[CmdletBinding()]
param(
    [string]$SourceRoot = '',
    [string]$TargetRoot = 'D:\test\agent-files-game',
    [string[]]$Path,
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SourceRoot)) {
    $SourceRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
}

function Normalize-Root {
    param([Parameter(Mandatory = $true)][string]$InputPath)

    return [System.IO.Path]::GetFullPath($InputPath).TrimEnd([char[]]'\/')
}

function Resolve-SourcePath {
    param([Parameter(Mandatory = $true)][string]$InputPath)

    if ([System.IO.Path]::IsPathRooted($InputPath)) {
        return [System.IO.Path]::GetFullPath($InputPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $SourceRoot $InputPath))
}

function Get-RelativeSourcePath {
    param([Parameter(Mandatory = $true)][string]$FullPath)

    $normalizedPath = [System.IO.Path]::GetFullPath($FullPath)
    $sourcePrefix = "$SourceRoot\"

    if (-not $normalizedPath.StartsWith($sourcePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside SourceRoot: $FullPath"
    }

    return $normalizedPath.Substring($SourceRoot.Length).TrimStart([char[]]'\/')
}

function Test-ExcludedRelativePath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $excludedNames = @('.git', '.codex', 'node_modules', '.next', 'dist', 'build', 'coverage')
    foreach ($segment in ($RelativePath -split '[\\\/]+')) {
        if ($excludedNames -contains $segment) {
            return $true
        }
    }

    return $false
}

function Get-MarkdownFilesToSync {
    if ($Path -and $Path.Count -gt 0) {
        foreach ($inputPath in $Path) {
            $fullPath = Resolve-SourcePath $inputPath
            if (-not $fullPath.EndsWith('.md', [System.StringComparison]::OrdinalIgnoreCase)) {
                continue
            }

            if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
                Get-Item -LiteralPath $fullPath
            }
        }

        return
    }

    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Filter '*.md'
}

$SourceRoot = Normalize-Root $SourceRoot
$TargetRoot = Normalize-Root $TargetRoot

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "SourceRoot does not exist: $SourceRoot"
}

if (-not (Test-Path -LiteralPath $TargetRoot -PathType Container)) {
    New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null
}

$copied = 0
foreach ($file in @(Get-MarkdownFilesToSync)) {
    $relativePath = Get-RelativeSourcePath $file.FullName
    if (Test-ExcludedRelativePath $relativePath) {
        continue
    }

    $destinationPath = Join-Path $TargetRoot $relativePath
    $destinationDirectory = Split-Path -Parent $destinationPath

    if (-not (Test-Path -LiteralPath $destinationDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    }

    Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
    $copied++

    if (-not $Quiet) {
        Write-Host "Synced: $relativePath"
    }
}

if (-not $Quiet) {
    Write-Host "Markdown sync complete. Files copied: $copied. Target: $TargetRoot"
}
