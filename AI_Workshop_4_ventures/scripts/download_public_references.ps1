#requires -version 5.1
$ErrorActionPreference = 'Stop'
$target_root = 'C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures'
$catalog_dir = Join-Path $target_root 'reference_catalog'
$download_dir = Join-Path $target_root 'downloaded_sources'
$log_dir = Join-Path $target_root 'logs'
New-Item -ItemType Directory -Force -Path $download_dir,$log_dir | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$log_path = Join-Path $log_dir "download_public_references_$timestamp.log.txt"
function Write-Log { param([string]$m) $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; $line | Tee-Object -FilePath $log_path -Append }
function Get-SafeFileName { param([string]$t) $invalid = [System.IO.Path]::GetInvalidFileNameChars(); foreach ($c in $invalid) { $t = $t.Replace($c, '_') }; return ($t -replace '\s+', '_') }
$manifest_path = Join-Path $catalog_dir 'official_sources_manifest.json'
if (-not (Test-Path $manifest_path)) { throw "Manifest not found: $manifest_path" }
$manifest = Get-Content -Path $manifest_path -Raw | ConvertFrom-Json
$results = @()
Write-Log "START"
foreach ($source in $manifest.sources) {
    $provider_folder = Join-Path $download_dir (Get-SafeFileName $source.provider)
    New-Item -ItemType Directory -Force -Path $provider_folder | Out-Null
    $resource_name = Get-SafeFileName $source.resource
    $url = [string]$source.url
    try {
        $head = $null
        try { $head = Invoke-WebRequest -Uri $url -Method Head -MaximumRedirection 5 -UseBasicParsing -TimeoutSec 45 } catch {}
        $extension = '.html'
        if ($url -match '\.pdf($|\?)') { $extension = '.pdf' }
        elseif ($head -and $head.Headers.'Content-Type' -match 'pdf') { $extension = '.pdf' }
        elseif ($head -and $head.Headers.'Content-Type' -match 'json') { $extension = '.json' }
        $out_file = Join-Path $provider_folder ($resource_name + $extension)
        if (Test-Path -LiteralPath $out_file) {
            Write-Log "skipped_existing=$url => $out_file"
        } else {
            Invoke-WebRequest -Uri $url -OutFile $out_file -MaximumRedirection 5 -UseBasicParsing -TimeoutSec 90 -Headers @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36" }
        }
        Write-Log "downloaded=$url => $out_file"
        $results += [pscustomobject]@{ provider=$source.provider; resource=$source.resource; url=$url; local_path=$out_file; status='downloaded' }
    } catch {
        Write-Log "failed=$url ; error=$($_.Exception.Message)"
        $results += [pscustomobject]@{ provider=$source.provider; resource=$source.resource; url=$url; local_path=''; status='failed' }
    }
}
$results | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $catalog_dir 'download_results.json') -Encoding UTF8
Write-Log "COMPLETE"



