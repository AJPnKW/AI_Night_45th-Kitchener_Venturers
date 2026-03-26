#requires -version 5.1
<#
[CAPABILITY] ai_workshop_download_public_sources_v2=YES
Purpose:
- Read official_sources_manifest_v2.json
- Download publicly accessible source pages/files into downloaded_sources
- Skip files that already exist
- Log status cleanly
- Write download_results_v2.json
#>

$ErrorActionPreference = 'Stop'

$target_root = 'C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures'
$catalog_dir = Join-Path $target_root 'reference_catalog'
$download_dir = Join-Path $target_root 'downloaded_sources'
$log_dir = Join-Path $target_root 'logs'

New-Item -ItemType Directory -Force -Path $catalog_dir, $download_dir, $log_dir | Out-Null

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$log_path = Join-Path $log_dir "download_public_references_v2_$timestamp.log.txt"

function Write-Log {
    param([string]$message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $message
    $line | Tee-Object -FilePath $log_path -Append
}

function Get-SafeFileName {
    param([string]$text)
    $invalid = [System.IO.Path]::GetInvalidFileNameChars()
    foreach ($char in $invalid) {
        $text = $text.Replace($char, '_')
    }
    return ($text -replace '\s+', '_')
}

function Get-PreferredExtension {
    param(
        [string]$url,
        [string]$format_hint,
        $head_response
    )

    if ($url -match '\.pdf($|\?)') { return '.pdf' }
    if ($url -match '\.json($|\?)') { return '.json' }
    if ($format_hint -eq 'pdf') { return '.pdf' }
    if ($format_hint -eq 'json') { return '.json' }

    if ($null -ne $head_response) {
        $content_type = [string]$head_response.Headers.'Content-Type'
        if ($content_type -match 'pdf') { return '.pdf' }
        if ($content_type -match 'json') { return '.json' }
        if ($content_type -match 'text/plain') { return '.txt' }
    }

    return '.html'
}

$manifest_path = Join-Path $catalog_dir 'official_sources_manifest_v2.json'
if (-not (Test-Path -LiteralPath $manifest_path)) {
    throw "Manifest not found: $manifest_path"
}

$manifest = Get-Content -LiteralPath $manifest_path -Raw -Encoding UTF8 | ConvertFrom-Json
$results = @()

$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"
    "Accept-Language" = "en-US,en;q=0.9"
}

Write-Log "START"

foreach ($source in $manifest.sources) {
    $provider_folder = Join-Path $download_dir (Get-SafeFileName $source.provider)
    New-Item -ItemType Directory -Force -Path $provider_folder | Out-Null

    $resource_name = Get-SafeFileName $source.resource
    $url = [string]$source.url
    $head = $null

    try {
        try {
            $head = Invoke-WebRequest -Uri $url -Method Head -MaximumRedirection 5 -UseBasicParsing -TimeoutSec 45 -Headers $headers
        } catch {
            Write-Log "head_failed=$url ; trying_get"
        }

        $extension = Get-PreferredExtension -url $url -format_hint ([string]$source.format_hint) -head_response $head
        $out_file = Join-Path $provider_folder ($resource_name + $extension)

        if (Test-Path -LiteralPath $out_file) {
            Write-Log "skipped_existing=$url => $out_file"
            $status = 'skipped_existing'
        } else {
            Invoke-WebRequest -Uri $url -OutFile $out_file -MaximumRedirection 5 -UseBasicParsing -TimeoutSec 120 -Headers $headers
            Write-Log "downloaded=$url => $out_file"
            $status = 'downloaded'
        }

        $results += [pscustomobject]@{
            provider = $source.provider
            resource = $source.resource
            url = $url
            local_path = $out_file
            status = $status
        }
    }
    catch {
        Write-Log "failed=$url ; error=$($_.Exception.Message)"
        $results += [pscustomobject]@{
            provider = $source.provider
            resource = $source.resource
            url = $url
            local_path = ''
            status = 'failed'
        }
    }
}

$results_path = Join-Path $catalog_dir 'download_results_v2.json'
$results | ConvertTo-Json -Depth 6 | Set-Content -Path $results_path -Encoding UTF8
Write-Log "wrote=$results_path"
Write-Log "COMPLETE"
Write-Host ""
Write-Host "Press ENTER to exit..." -ForegroundColor Yellow
[void][System.Console]::ReadLine()
