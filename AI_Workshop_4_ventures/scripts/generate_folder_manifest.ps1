#requires -version 5.1
$ErrorActionPreference = 'Stop'
$target_root = 'C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures'
$dashboard_dir = Join-Path $target_root 'dashboard'
$log_dir = Join-Path $target_root 'logs'
New-Item -ItemType Directory -Force -Path $dashboard_dir,$log_dir | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$log_path = Join-Path $log_dir "generate_folder_manifest_$timestamp.log.txt"
function Write-Log { param([string]$m) $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; $line | Tee-Object -FilePath $log_path -Append }
Write-Log "START"
$items = Get-ChildItem -Path $target_root -Recurse -File | Where-Object { $_.FullName -notmatch '\\logs\\' }
$manifest_items = foreach ($item in $items) {
    $relative = $item.FullName.Substring($target_root.Length).TrimStart('\')
    [pscustomobject]@{
        type = 'file'
        name = $item.Name
        extension = $item.Extension.ToLowerInvariant()
        size_bytes = $item.Length
        relative_path = $relative
        modified_local = $item.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
    }
}
$manifest = [ordered]@{
    generated = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss UTC')
    generated_local = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    root = $target_root
    items = $manifest_items
}
("window.folderManifest = " + ($manifest | ConvertTo-Json -Depth 6) + ";") | Set-Content -Path (Join-Path $dashboard_dir 'manifest.js') -Encoding UTF8
Write-Log "files_scanned=$($manifest_items.Count)"
Write-Log "COMPLETE"


