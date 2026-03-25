# qa_site.ps1
# Version: 1.0.0
# Purpose: Run repeatable QA checks for the static GitHub Pages site, write timestamped logs/reports, and zip outputs.

[CmdletBinding()]
param(
  [string]$SiteFolder = "AI_Workshop_4_ventures\\web"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$siteRoot = Join-Path $projectRoot $SiteFolder
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
$logDir = Join-Path $projectRoot "logs\$timestamp"
$reportDir = Join-Path $projectRoot "reports\runs\$timestamp"
$outDir = Join-Path $projectRoot "out\$timestamp"
$zipPath = Join-Path $outDir "qa_bundle_$timestamp.zip"
$logPath = Join-Path $logDir "qa_site.log.txt"
$reportPath = Join-Path $reportDir "qa_results.md"
$repoPagesPrefix = "AI_Night_45th-Kitchener_Venturers"

New-Item -ItemType Directory -Force -Path $logDir, $reportDir, $outDir | Out-Null

function Write-Log {
  param([string]$Message)
  $line = "[{0}] {1}" -f (Get-Date -Format "u"), $Message
  $line | Tee-Object -FilePath $logPath -Append
}

function Resolve-SiteTarget {
  param(
    [string]$CurrentFile,
    [string]$Target
  )

  if ([string]::IsNullOrWhiteSpace($Target)) { return $null }
  if ($Target.StartsWith("http://") -or $Target.StartsWith("https://") -or $Target.StartsWith("mailto:") -or $Target.StartsWith("tel:") -or $Target.StartsWith("#")) { return $null }

  $clean = $Target.Split("#")[0].Split("?")[0]
  if ([string]::IsNullOrWhiteSpace($clean)) { return $null }

  if ($clean.StartsWith("/")) {
    $trimmed = $clean.TrimStart("/")
    if ($trimmed.StartsWith("$repoPagesPrefix/")) {
      $trimmed = $trimmed.Substring($repoPagesPrefix.Length + 1)
    }
    elseif ($trimmed -eq $repoPagesPrefix) {
      $trimmed = ""
    }
    return Join-Path $siteRoot $trimmed.Replace("/", "\")
  }

  $currentDir = Split-Path -Parent $CurrentFile
  return Join-Path $currentDir $clean.Replace("/", "\")
}

Write-Log "QA start"
Write-Log "Project root: $projectRoot"
Write-Log "Site root: $siteRoot"

if (-not (Test-Path $siteRoot)) {
  throw "Site root not found: $siteRoot"
}

$htmlFiles = Get-ChildItem -Path $siteRoot -Filter *.html -Recurse | Sort-Object FullName
$missingLinks = New-Object System.Collections.Generic.List[string]
$contentIssues = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$requiredDisclaimerFiles = @(
  "index.html",
  "parent\index.html",
  "leader\index.html",
  "facilitator\index.html",
  "legal\privacy.html",
  "legal\disclaimer.html",
  "legal\consent.html"
)

foreach ($file in $htmlFiles) {
  Write-Log "Checking $($file.FullName)"
  $raw = Get-Content $file.FullName -Raw

  if ($raw -notmatch "<title>.+?</title>") {
    $contentIssues.Add("Missing title: $($file.FullName)")
  }

  if ($raw -notmatch "<h1[\s>]") {
    $contentIssues.Add("Missing h1: $($file.FullName)")
  }

  $relative = $file.FullName.Substring($siteRoot.Length + 1)
  if ($requiredDisclaimerFiles -contains $relative -and $raw -notmatch "independent volunteer") {
    $contentIssues.Add("Missing disclaimer language: $relative")
  }

  if ($raw -match "lorem ipsum") {
    $contentIssues.Add("Placeholder text found: $relative")
  }

  if ($raw -match "(?i)\b24th\b") {
    $contentIssues.Add("Stale 24th reference found: $relative")
  }

  $matches = [regex]::Matches($raw, '(?:href|src)="([^"]+)"')
  foreach ($match in $matches) {
    $target = $match.Groups[1].Value
    $resolved = Resolve-SiteTarget -CurrentFile $file.FullName -Target $target
    if ($null -eq $resolved) { continue }
    if (-not (Test-Path $resolved)) {
      $missingLinks.Add("$relative -> $target")
    }
  }
}

$docs = @(
  "docs\project_overview.md",
  "docs\solution_architecture.md",
  "docs\information_architecture.md",
  "docs\qa_strategy.md"
)

foreach ($doc in $docs) {
  if (-not (Test-Path (Join-Path $projectRoot $doc))) {
    $warnings.Add("Missing expected documentation file: $doc")
  }
}

$printCss = Join-Path $siteRoot "assets\css\print.css"
if (-not (Test-Path $printCss)) {
  $contentIssues.Add("Missing print stylesheet")
}

$status = if ($missingLinks.Count -eq 0 -and $contentIssues.Count -eq 0) { "PASS" } else { "FAIL" }

$report = @()
$report += "# QA Results"
$report += ""
$report += "- Timestamp: $timestamp"
$report += "- Status: $status"
$report += "- HTML files checked: $($htmlFiles.Count)"
$report += "- Missing links: $($missingLinks.Count)"
$report += "- Content issues: $($contentIssues.Count)"
$report += "- Warnings: $($warnings.Count)"
$report += ""
$report += "## Missing Links"
$report += ""
if ($missingLinks.Count -eq 0) { $report += "- None" } else { $report += ($missingLinks | ForEach-Object { "- $_" }) }
$report += ""
$report += "## Content Issues"
$report += ""
if ($contentIssues.Count -eq 0) { $report += "- None" } else { $report += ($contentIssues | ForEach-Object { "- $_" }) }
$report += ""
$report += "## Warnings"
$report += ""
if ($warnings.Count -eq 0) { $report += "- None" } else { $report += ($warnings | ForEach-Object { "- $_" }) }

$report -join "`r`n" | Set-Content -Path $reportPath -Encoding UTF8
Write-Log "Report written to $reportPath"

$artifactPaths = @($logDir, $reportDir)
Compress-Archive -Path $artifactPaths -DestinationPath $zipPath -Force
Write-Log "Zip bundle written to $zipPath"
Write-Log "QA complete with status $status"

if ($status -eq "FAIL") {
  throw "QA failed. See $reportPath"
}
