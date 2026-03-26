#requires -version 5.1

$ErrorActionPreference = 'Stop'

$target_root = 'C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures'
$script_dir = Join-Path $target_root 'scripts'
$log_dir = Join-Path $target_root 'logs'
New-Item -ItemType Directory -Force -Path $log_dir | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$log_path = Join-Path $log_dir "refresh_all_$timestamp.log.txt"

function Write-Log {
    param([string]$message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $message
    $line | Tee-Object -FilePath $log_path -Append
}

Write-Log "START"

$download_script = Join-Path $script_dir 'download_public_references.ps1'
$manifest_script = Join-Path $script_dir 'generate_folder_manifest.ps1'

if (-not (Test-Path -LiteralPath $download_script)) {
    throw "Missing script: $download_script"
}

if (-not (Test-Path -LiteralPath $manifest_script)) {
    throw "Missing script: $manifest_script"
}

Write-Log "running=$download_script"
& powershell -ExecutionPolicy Bypass -File $download_script

Write-Log "running=$manifest_script"
& powershell -ExecutionPolicy Bypass -File $manifest_script

$start_page = Join-Path $target_root 'start_here.html'
if (Test-Path -LiteralPath $start_page) {
    Start-Process $start_page
    Write-Log "opened=$start_page"
}

Write-Log "COMPLETE"
Write-Host ""
Write-Host "Press ENTER to exit..." -ForegroundColor Yellow
[void][System.Console]::ReadLine()
