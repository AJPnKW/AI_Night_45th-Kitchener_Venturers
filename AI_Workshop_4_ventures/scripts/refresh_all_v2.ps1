#requires -version 5.1
[CmdletBinding()]
param([switch]$NoPause)
$ErrorActionPreference = 'Stop'
$wrapper = Join-Path $PSScriptRoot 'refresh_all.ps1'
if (-not (Test-Path -LiteralPath $wrapper)) { throw "Missing wrapper: $wrapper" }
Write-Host "Deprecated wrapper: refresh_all_v2.ps1 -> refresh_all.ps1" -ForegroundColor Yellow
& $wrapper -NoPause:$NoPause
if (-not $NoPause) {
    Write-Host "`nPress ENTER to exit..." -ForegroundColor Yellow
    [void][System.Console]::ReadLine()
}
