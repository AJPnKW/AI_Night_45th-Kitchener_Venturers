#requires -version 5.1
$ErrorActionPreference = 'Stop'
$target_root = 'C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures'
$dashboard_url = 'http://127.0.0.1:8765/dashboard/index.html'
$log_dir = Join-Path $target_root 'logs'
New-Item -ItemType Directory -Force -Path $log_dir | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$log_path = Join-Path $log_dir "start_dashboard_$timestamp.log.txt"
function Write-Log { param([string]$m) $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; $line | Tee-Object -FilePath $log_path -Append }
Write-Log "START"
Push-Location $target_root
try {
    $python = Get-Command python -ErrorAction Stop
    Start-Process -FilePath $python.Source -ArgumentList '-m','http.server','8765' -WorkingDirectory $target_root
    Start-Sleep -Seconds 2
    Start-Process $dashboard_url
    Write-Log "opened=$dashboard_url"
    Write-Log "COMPLETE"
} finally {
    Pop-Location
}
Write-Host ""
Write-Host "Press ENTER to exit..." -ForegroundColor Yellow
[void][System.Console]::ReadLine()

