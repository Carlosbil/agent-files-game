[CmdletBinding()]
param(
    [string]$TargetRoot = 'D:\test\agent-files-game'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$syncScript = Join-Path $repoRoot 'scripts\Sync-MarkdownToObsidian.ps1'
$logPath = Join-Path $repoRoot '.codex\obsidian-sync-hook.log'

function Write-HookLog {
    param([Parameter(Mandatory = $true)][string]$Message)

    $timestamp = (Get-Date).ToString('s')
    Add-Content -LiteralPath $logPath -Value "[$timestamp] $Message"
}

function ConvertTo-SourcePath {
    param([Parameter(Mandatory = $true)][string]$InputPath)

    $trimmed = $InputPath.Trim().Trim('"')
    if ([System.IO.Path]::IsPathRooted($trimmed)) {
        return [System.IO.Path]::GetFullPath($trimmed)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $trimmed))
}

function Add-MarkdownPath {
    param([Parameter(Mandatory = $true)][string]$InputPath)

    if (-not $InputPath.EndsWith('.md', [System.StringComparison]::OrdinalIgnoreCase)) {
        return
    }

    $fullPath = ConvertTo-SourcePath $InputPath
    if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
        [void]$script:MarkdownPaths.Add($fullPath)
    }
}

try {
    $stdin = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($stdin)) {
        exit 0
    }

    $payload = $stdin | ConvertFrom-Json -ErrorAction Stop
    $command = ''

    if ($payload.PSObject.Properties.Name -contains 'tool_input' -and
        $payload.tool_input.PSObject.Properties.Name -contains 'command') {
        $command = [string]$payload.tool_input.command
    }

    if ([string]::IsNullOrWhiteSpace($command)) {
        exit 0
    }

    $script:MarkdownPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($line in ($command -split "`r?`n")) {
        if ($line -match '^\*\*\* (Add|Update) File:\s+(.+)$') {
            Add-MarkdownPath -InputPath $Matches[2]
            continue
        }

        if ($line -match '^\*\*\* Move to:\s+(.+)$') {
            Add-MarkdownPath -InputPath $Matches[1]
        }
    }

    if ($script:MarkdownPaths.Count -eq 0) {
        exit 0
    }

    if (-not (Test-Path -LiteralPath $syncScript -PathType Leaf)) {
        Write-HookLog "Sync script not found: $syncScript"
        exit 0
    }

    & $syncScript -SourceRoot $repoRoot -TargetRoot $TargetRoot -Path @($script:MarkdownPaths) -Quiet
    Write-HookLog "Synced $($script:MarkdownPaths.Count) Markdown file(s) to $TargetRoot"
}
catch {
    Write-HookLog "Error: $($_.Exception.Message)"
}

exit 0
