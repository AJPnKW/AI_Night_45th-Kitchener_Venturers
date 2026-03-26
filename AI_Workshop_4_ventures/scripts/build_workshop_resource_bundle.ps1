#requires -version 5.1
[CmdletBinding()]
param([switch]$NoPause)
$ErrorActionPreference = 'Stop'
$workshopRoot = Split-Path -Parent $PSScriptRoot
$referenceRoot = Join-Path $workshopRoot 'reference_catalog'
$scriptRoot = Join-Path $workshopRoot 'scripts'
$packRoot = Join-Path $workshopRoot 'workshop_pack'
$logRoot = Join-Path $workshopRoot 'logs'
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$runRoot = Join-Path $logRoot "build_workshop_resource_bundle_$timestamp"
$logPath = Join-Path $runRoot 'build_workshop_resource_bundle.log.txt'
$zipPath = Join-Path $runRoot "workshop_resource_bundle_$timestamp.zip"
$manifestPath = Join-Path $runRoot 'bundle_manifest.txt'
New-Item -ItemType Directory -Force -Path $runRoot | Out-Null
function Write-Log { param([string]$Message) $line = "[{0}] {1}" -f (Get-Date -Format 'u'), $Message; $line | Tee-Object -FilePath $logPath -Append }
$pathsToBundle = @(
  (Join-Path $referenceRoot 'detailed_resource_inventory.csv'),
  (Join-Path $referenceRoot 'detailed_resource_inventory.md'),
  (Join-Path $referenceRoot 'source_claim_validation.csv'),
  (Join-Path $referenceRoot 'source_claim_validation.md'),
  (Join-Path $referenceRoot 'slide_candidate_matrix.csv'),
  (Join-Path $referenceRoot 'slide_candidate_matrix.md'),
  (Join-Path $referenceRoot 'learning_plan_expansion.md'),
  (Join-Path $referenceRoot 'exercises_and_activity_bank.md'),
  (Join-Path $referenceRoot 'codex_beginner_segment.md'),
  (Join-Path $referenceRoot 'teen_safe_use_and_parent_controls.md'),
  (Join-Path $referenceRoot 'what_beginners_are_not_told.md'),
  (Join-Path $scriptRoot 'inventory_local_sources.ps1'),
  (Join-Path $scriptRoot 'expand_reference_catalog.ps1'),
  (Join-Path $scriptRoot 'download_missing_public_references.ps1'),
  (Join-Path $scriptRoot 'build_workshop_resource_bundle.ps1'),
  (Join-Path $packRoot 'learning_plan_ai_chatgpt_session.html'),
  (Join-Path $packRoot 'facilitator_slides.html'),
  (Join-Path $packRoot 'learner_worksheet.html'),
  (Join-Path $packRoot 'parent_guardian_setup_flow.html'),
  (Join-Path $packRoot 'tool_walkthroughs.html')
)
$existingPaths = $pathsToBundle | Where-Object { Test-Path $_ }
$manifest = $existingPaths | ForEach-Object { $_.Substring($workshopRoot.Length + 1) }
$manifest | Set-Content -Path $manifestPath -Encoding UTF8
Write-Log "bundle_item_count=$($existingPaths.Count)"
Write-Log "manifest=$manifestPath"
Compress-Archive -Path (@($existingPaths) + @($manifestPath, $logPath)) -DestinationPath $zipPath -Force
Write-Log "zip_bundle=$zipPath"
Write-Log 'COMPLETE'
Write-Host "Workshop resource bundle complete.`nZIP: $zipPath" -ForegroundColor Green
if (-not $NoPause) { Write-Host "`nPress ENTER to exit..." -ForegroundColor Yellow; [void][System.Console]::ReadLine() }
