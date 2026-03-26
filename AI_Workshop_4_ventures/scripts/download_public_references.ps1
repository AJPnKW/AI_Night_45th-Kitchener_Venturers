#requires -version 5.1
[CmdletBinding()]
param([switch]$NoPause)
$ErrorActionPreference = 'Stop'
$canonicalScript = Join-Path $PSScriptRoot 'download_missing_public_references.ps1'
if (-not (Test-Path -LiteralPath $canonicalScript)) {
    throw "Missing canonical script: $canonicalScript"
}
Write-Host "Deprecated wrapper: download_public_references.ps1 -> download_missing_public_references.ps1" -ForegroundColor Yellow
& $canonicalScript -NoPause:$NoPause
if (-not $NoPause) {
    Write-Host "`nPress ENTER to exit..." -ForegroundColor Yellow
    [void][System.Console]::ReadLine()
}
