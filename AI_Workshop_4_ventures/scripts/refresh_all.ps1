#requires -version 5.1
[CmdletBinding()]
param([switch]$NoPause)
$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot
$steps = @(
    (Join-Path $scriptRoot 'download_missing_public_references.ps1'),
    (Join-Path $scriptRoot 'inventory_local_sources.ps1'),
    (Join-Path $scriptRoot 'expand_reference_catalog.ps1'),
    (Join-Path $scriptRoot 'build_workshop_resource_bundle.ps1')
)
foreach ($step in $steps) {
    if (-not (Test-Path -LiteralPath $step)) { throw "Missing canonical step: $step" }
}
Write-Host "Deprecated wrapper: refresh_all.ps1 now runs the canonical workshop resource pipeline." -ForegroundColor Yellow
foreach ($step in $steps) { & $step -NoPause }
if (-not $NoPause) {
    Write-Host "`nPress ENTER to exit..." -ForegroundColor Yellow
    [void][System.Console]::ReadLine()
}
