#requires -version 5.1
[CmdletBinding()]
param([switch]$NoPause)
$ErrorActionPreference = 'Stop'
$workshopRoot = Split-Path -Parent $PSScriptRoot
$referenceRoot = Join-Path $workshopRoot 'reference_catalog'
$downloadRoot = Join-Path $workshopRoot 'downloaded_sources'
$logRoot = Join-Path $workshopRoot 'logs'
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$runRoot = Join-Path $logRoot "download_missing_public_references_$timestamp"
$logPath = Join-Path $runRoot 'download_missing_public_references.log.txt'
$resultPath = Join-Path $runRoot 'download_missing_public_references_results.csv'
$zipPath = Join-Path $runRoot "download_missing_public_references_$timestamp.zip"
New-Item -ItemType Directory -Force -Path $runRoot | Out-Null
function Write-Log { param([string]$Message) $line = "[{0}] {1}" -f (Get-Date -Format 'u'), $Message; $line | Tee-Object -FilePath $logPath -Append }
function Get-SafeName { param([string]$Text) $name = $Text -replace '[\\/:*?""<>|]', '_'; $name = $name -replace '\s+', '_'; $name }
$manifestPath = Join-Path $referenceRoot 'official_sources_manifest_v2.json'
if (-not (Test-Path $manifestPath)) { throw "Missing manifest: $manifestPath" }
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$headers = @{ 'User-Agent' = 'Mozilla/5.0'; 'Accept-Language' = 'en-US,en;q=0.9' }
$results = foreach ($source in $manifest.sources) {
  $providerDir = Join-Path $downloadRoot (Get-SafeName $source.provider)
  New-Item -ItemType Directory -Force -Path $providerDir | Out-Null
  $resourceName = Get-SafeName $source.resource
  $expectedMatches = Get-ChildItem -Path $providerDir -File -ErrorAction SilentlyContinue | Where-Object { $_.BaseName -like "$resourceName*" }
  if ($expectedMatches) {
    Write-Log "existing=$($source.url)"
    [pscustomobject]@{ provider = $source.provider; resource = $source.resource; url = $source.url; status = 'existing'; local_path = $expectedMatches[0].FullName.Substring($workshopRoot.Length + 1) }
  } else {
    try {
      $extension = if ($source.url -match '\.pdf($|\?)' -or $source.format_hint -eq 'pdf') { '.pdf' } else { '.html' }
      $targetPath = Join-Path $providerDir ($resourceName + $extension)
      Invoke-WebRequest -Uri $source.url -OutFile $targetPath -Headers $headers -UseBasicParsing -TimeoutSec 120
      Write-Log "downloaded=$($source.url)"
      [pscustomobject]@{ provider = $source.provider; resource = $source.resource; url = $source.url; status = 'downloaded'; local_path = $targetPath.Substring($workshopRoot.Length + 1) }
    } catch {
      Write-Log "failed=$($source.url) ; error=$($_.Exception.Message)"
      [pscustomobject]@{ provider = $source.provider; resource = $source.resource; url = $source.url; status = 'failed'; local_path = '' }
    }
  }
}
$results | Export-Csv -Path $resultPath -NoTypeInformation -Encoding UTF8
Compress-Archive -Path $resultPath, $logPath -DestinationPath $zipPath -Force
Write-Log "results_csv=$resultPath"
Write-Log "zip_bundle=$zipPath"
Write-Log "existing_count=$((($results | Where-Object status -eq 'existing')).Count)"
Write-Log "downloaded_count=$((($results | Where-Object status -eq 'downloaded')).Count)"
Write-Log "failed_count=$((($results | Where-Object status -eq 'failed')).Count)"
Write-Log 'COMPLETE'
Write-Host "Missing-reference check complete.`nResults: $resultPath`nZIP    : $zipPath" -ForegroundColor Green
if (-not $NoPause) { Write-Host "`nPress ENTER to exit..." -ForegroundColor Yellow; [void][System.Console]::ReadLine() }
