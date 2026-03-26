#requires -version 5.1
$ErrorActionPreference = 'Stop'
$target_root = 'C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures'
$script_root = Split-Path -Parent $MyInvocation.MyCommand.Path
$overlay_root = Split-Path -Parent $script_root
$log_root = Join-Path $overlay_root 'logs'
New-Item -ItemType Directory -Force -Path $log_root | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$log_path = Join-Path $log_root "apply_overlay_$timestamp.log.txt"
function Write-Log { param([string]$m) $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; $line | Tee-Object -FilePath $log_path -Append }
Write-Log "START"
$folders = @('workshop_pack','reference_catalog','dashboard','scripts','downloaded_sources','logs')
foreach ($folder in $folders) {
    $dest = Join-Path $target_root $folder
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $source = Join-Path $overlay_root $folder
    if (Test-Path $source) {
        Copy-Item -Path (Join-Path $source '*') -Destination $dest -Recurse -Force
        Write-Log "copied=$source => $dest"
    }
}
$start_src = Join-Path $overlay_root 'start_here.html'
if (Test-Path $start_src) {
    Copy-Item -LiteralPath $start_src -Destination (Join-Path $target_root 'start_here.html') -Force
}
Write-Log "COMPLETE"
Write-Host ""
Write-Host "Press ENTER to exit..." -ForegroundColor Yellow
[void][System.Console]::ReadLine()

