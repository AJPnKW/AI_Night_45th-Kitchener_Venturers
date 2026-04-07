[CmdletBinding()]
param(
  [string]$ProjectRoot = "C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures"
)

$ErrorActionPreference = "Stop"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logsRoot = Join-Path $ProjectRoot "logs"
$reportsRoot = Join-Path $ProjectRoot "reports"
$artifactsRoot = Join-Path $ProjectRoot "artifacts"
$logPath = Join-Path $logsRoot "validate_delivery_system_$timestamp.log.txt"
$reportDir = Join-Path $reportsRoot "validation_$timestamp"
$artifactDir = Join-Path $artifactsRoot "validation_$timestamp"

foreach ($path in @($logsRoot, $reportsRoot, $artifactsRoot, $reportDir, $artifactDir)) {
  New-Item -ItemType Directory -Force -Path $path | Out-Null
}

function Write-Log {
  param([string]$Message)
  $line = "[{0}] {1}" -f (Get-Date -Format "u"), $Message
  $line | Tee-Object -FilePath $logPath -Append | Out-Null
}

$requiredDocs = @(
  "docs\project_coordination_dashboard.html",
  "docs\current_state_validated_vs_unvalidated.html",
  "docs\repo_rationalization_plan.html",
  "docs\workshop_delivery_architecture.html",
  "docs\platform_compatibility_matrix.html",
  "docs\participant_pathways.html",
  "docs\parent_information_pack.html",
  "docs\youth_prework_and_takeaway_pack.html",
  "docs\leader_operations_pack.html",
  "docs\presenter_operations_pack.html",
  "docs\readiness_checker_spec.html",
  "docs\install_launch_cleanup_lifecycle.html",
  "docs\browser_first_environment_plan.html",
  "docs\local_vm_optional_path_plan.html",
  "docs\apple_silicon_and_nonstandard_device_path.html",
  "docs\risk_and_fallback_matrix.html",
  "docs\codex_rules_and_guardrails_examples.html",
  "docs\example_prompt_and_ruleset_takeaway.html",
  "docs\completed_vs_blocked_vs_next_actions.html",
  "docs\final_packaging_and_release_plan.html",
  "docs\facilitator_talking_points.html",
  "docs\facilitator_answer_key.html",
  "docs\session_run_of_show_90_minutes.html",
  "docs\session_slide_content_and_speaker_notes.html",
  "docs\demo_prompt_bank_chatgpt.html",
  "docs\demo_prompt_bank_images.html",
  "docs\demo_prompt_bank_codex_facilitator_only.html",
  "docs\backup_facilitator_pack.html",
  "docs\exercise_system_overview.html",
  "docs\exercise_cards_guided_build_remix_stretch.html",
  "docs\reflection_and_takeaway_pack.html",
  "docs\pre_event_communications_plan.html",
  "docs\pre_event_parent_message.html",
  "docs\pre_event_participant_message.html",
  "docs\pre_event_readiness_and_homework.html",
  "docs\pre_event_survey_and_feedback_plan.html",
  "docs\youth_participant_pack.html",
  "docs\leader_support_pack.html",
  "docs\kb_index.html",
  "docs\kb_article_template.html",
  "docs\platform_capabilities_and_limits.html",
  "docs\forms_and_backend_supplement_plan.html",
  "docs\optional_submission_and_email_workflow.html",
  "docs\project_right_sizing_approach.html",
  "docs\project_charter_and_success_measures.html",
  "docs\project_phase_delivery_thread.html",
  "docs\project_decision_risk_issue_change_log.html",
  "docs\project_management_case_study.html",
  "docs\participant_workbook_and_forms_solution.html",
  "docs\codex_prompt_project_management_backfill_template.html"
)

$requiredPages = @(
  "web\index.html",
  "web\participant\index.html",
  "web\participant\before.html",
  "web\participant\day-of.html",
  "web\participant\after.html",
  "web\participant\exercises.html",
  "web\participant\reflections.html",
  "web\parent\index.html",
  "web\leader\index.html",
  "web\facilitator\index.html",
  "web\facilitator\run-of-show.html",
  "web\shared\faq.html",
  "web\shared\resources.html",
  "web\shared\examples.html",
  "web\shared\forms-feedback.html",
  "web\project\index.html",
  "web\project\case-study.html",
  "web\project\right-sizing.html",
  "web\project\status.html",
  "web\project\workbook-solution.html",
  "web\project\codex-prompt.html",
  "web\access\index.html",
  "web\kb\index.html",
  "web\kb\what-is-chatgpt.html",
  "web\kb\good-prompts.html",
  "web\kb\image-prompts.html",
  "web\kb\truth-and-mistakes.html",
  "web\kb\free-account-and-access.html",
  "web\kb\teen-ai-literacy.html"
)

$contentChecks = @(
  @{ path = "web\index.html"; pattern = "Browser-first AI night for Scouts and Venturers"; message = "Landing page is missing the browser-first workshop heading." },
  @{ path = "web\index.html"; pattern = "Not needed by default"; message = "Landing page is missing the no-install-by-default guidance." },
  @{ path = "web\participant\index.html"; pattern = "You do not need to be a coder"; message = "Youth page is missing the low-pressure browser-first reassurance." },
  @{ path = "web\participant\exercises.html"; pattern = "Guided"; message = "Exercises page is missing the Guided level." },
  @{ path = "web\participant\exercises.html"; pattern = "Build"; message = "Exercises page is missing the Build level." },
  @{ path = "web\participant\exercises.html"; pattern = "Remix"; message = "Exercises page is missing the Remix level." },
  @{ path = "web\participant\exercises.html"; pattern = "Stretch"; message = "Exercises page is missing the Stretch level." },
  @{ path = "web\participant\exercises.html"; pattern = "Practice report"; message = "Exercises page is missing the practice report section." },
  @{ path = "web\participant\reflections.html"; pattern = "Reflection prompts"; message = "Reflection page is missing the reflection prompts section." },
  @{ path = "web\parent\index.html"; pattern = "Browser-first by default"; message = "Parent page is missing the browser-first trust heading." },
  @{ path = "web\parent\index.html"; pattern = "What your child will not be required to do"; message = "Parent page is missing the reassurance section." },
  @{ path = "web\leader\index.html"; pattern = "Do not push VM setup as the main route"; message = "Leader page is missing the anti-derail guidance." },
  @{ path = "web\facilitator\run-of-show.html"; pattern = "Minute-by-minute run of show"; message = "Facilitator page is missing the run-of-show section." },
  @{ path = "web\facilitator\run-of-show.html"; pattern = "Closing remarks"; message = "Facilitator page is missing the closing remarks." },
  @{ path = "web\shared\examples.html"; pattern = "Weak vs strong demo cards"; message = "Examples page is missing the demo cards heading." },
  @{ path = "web\shared\resources.html"; pattern = "Demo prompt bank"; message = "Resources page is missing the demo prompt bank." },
  @{ path = "web\shared\forms-feedback.html"; pattern = "Google Forms"; message = "Forms and feedback page is missing the canonical forms platform wording." },
  @{ path = "web\project\index.html"; pattern = "project-light"; message = "Project overview page is missing the project-light positioning." },
  @{ path = "web\project\case-study.html"; pattern = "Recommended interview framing"; message = "Project case study page is missing the interview framing section." },
  @{ path = "web\project\workbook-solution.html"; pattern = "Google Forms with section branching"; message = "Public workbook solution page is missing the Forms branching guidance." },
  @{ path = "web\project\codex-prompt.html"; pattern = "project-light PM support"; message = "Public Codex prompt page is missing the PM backfill prompt content." },
  @{ path = "web\kb\index.html"; pattern = "Knowledge and reference articles"; message = "KB index is missing the knowledge index heading." },
  @{ path = "docs\presenter_operations_pack.html"; pattern = "Keep the Codex demo short and clearly secondary"; message = "Presenter operations pack is missing the browser-first presenter reminder." },
  @{ path = "docs\backup_facilitator_pack.html"; pattern = "10-minute rescue plan"; message = "Backup facilitator pack is missing the rescue plan." },
  @{ path = "docs\session_slide_content_and_speaker_notes.html"; pattern = "Slide-content equivalent"; message = "Slide notes pack is missing the slide-content structure." },
  @{ path = "docs\facilitator_answer_key.html"; pattern = "Likely learner misunderstandings"; message = "Facilitator answer key is missing the coaching/answer-key details." },
  @{ path = "docs\pre_event_parent_message.html"; pattern = "No VM is required by default"; message = "Parent pre-event message is missing the no-VM-by-default wording." },
  @{ path = "docs\pre_event_participant_message.html"; pattern = "No VM is required by default"; message = "Participant pre-event message is missing the no-VM-by-default wording." },
  @{ path = "docs\pre_event_survey_and_feedback_plan.html"; pattern = "How survey responses affect planning"; message = "Survey plan is missing the planning-use section." },
  @{ path = "docs\exercise_cards_guided_build_remix_stretch.html"; pattern = "Weak starter prompt"; message = "Exercise card pack is missing the card prompt structure." },
  @{ path = "docs\platform_capabilities_and_limits.html"; pattern = "What GitHub Pages can do"; message = "Platform capabilities doc is missing the GitHub Pages capabilities section." },
  @{ path = "docs\forms_and_backend_supplement_plan.html"; pattern = "Google Forms"; message = "Forms plan is missing the canonical Google Forms wording." },
  @{ path = "docs\optional_submission_and_email_workflow.html"; pattern = "Google Apps Script"; message = "Optional submission workflow doc is missing the Apps Script path." },
  @{ path = "docs\project_right_sizing_approach.html"; pattern = "right-sized"; message = "Project right-sizing doc is missing the right-sized methodology wording." },
  @{ path = "docs\project_charter_and_success_measures.html"; pattern = "Success measures"; message = "Project charter doc is missing the success measures section." },
  @{ path = "docs\project_phase_delivery_thread.html"; pattern = "Delivery thread summary"; message = "Project phase delivery thread is missing the delivery summary." },
  @{ path = "docs\project_decision_risk_issue_change_log.html"; pattern = "Key decisions"; message = "Project decision/risk log is missing the decision section." },
  @{ path = "docs\project_management_case_study.html"; pattern = "Recommended interview framing"; message = "Project management case study is missing the interview framing section." },
  @{ path = "docs\participant_workbook_and_forms_solution.html"; pattern = "Recommended tool pattern"; message = "Participant workbook/forms solution doc is missing the tool-pattern section." },
  @{ path = "docs\codex_prompt_project_management_backfill_template.html"; pattern = "Prompt text"; message = "Codex PM backfill prompt doc is missing the prompt block." }
)

$placeholderPatterns = @(
  "TODO",
  "TBD",
  "lorem ipsum",
  "coming soon",
  "insert here",
  "to be added"
)

$issues = New-Object System.Collections.Generic.List[string]
Write-Log "Validation started"

foreach ($doc in $requiredDocs) {
  if (-not (Test-Path (Join-Path $ProjectRoot $doc))) {
    $issues.Add("Missing doc: $doc")
  }
}

foreach ($page in $requiredPages) {
  if (-not (Test-Path (Join-Path $ProjectRoot $page))) {
    $issues.Add("Missing page: $page")
  }
}

$htmlFiles = @()
$htmlFiles += Get-ChildItem -Path (Join-Path $ProjectRoot "web") -Recurse -Filter *.html -ErrorAction SilentlyContinue
$htmlFiles += Get-ChildItem -Path (Join-Path $ProjectRoot "docs") -Filter *.html -ErrorAction SilentlyContinue

foreach ($file in $htmlFiles) {
  $raw = Get-Content $file.FullName -Raw
  if ($raw -notmatch "<title>.+?</title>") { $issues.Add("Missing title: $($file.FullName)") }
  if ($raw -notmatch "<h1[\s>]") { $issues.Add("Missing h1: $($file.FullName)") }
}

foreach ($check in $contentChecks) {
  $target = Join-Path $ProjectRoot $check.path
  if (Test-Path $target) {
    $raw = Get-Content $target -Raw
    if ($raw -notmatch [regex]::Escape($check.pattern)) {
      $issues.Add($check.message)
    }
  }
}

foreach ($file in $htmlFiles) {
  $raw = Get-Content $file.FullName -Raw
  foreach ($pattern in $placeholderPatterns) {
    if ($raw -match "(?i)\b$([regex]::Escape($pattern))\b") {
      $issues.Add("Placeholder language found in $($file.FullName): $pattern")
    }
  }
}

$siteJsPath = Join-Path $ProjectRoot "web\assets\js\site.js"
if (Test-Path $siteJsPath) {
  $siteJs = Get-Content $siteJsPath -Raw
  if ($siteJs -match "accessPasswords") {
    $issues.Add("Public client script still exposes access password logic.")
  }
  if ($siteJs -match "FormSubmit|formsubmit") {
    $issues.Add("Public client script still references FormSubmit instead of the locked Forms-based strategy.")
  }
}

$siteConfigPath = Join-Path $ProjectRoot "web\assets\js\site-config.js"
if (Test-Path $siteConfigPath) {
  $siteConfig = Get-Content $siteConfigPath -Raw
  if ($siteConfig -match "FormSubmit|formsubmit") {
    $issues.Add("Public site config still references FormSubmit.")
  }
}

$repoRoot = Split-Path $ProjectRoot -Parent
$readmePath = Join-Path $repoRoot "README.md"
if (Test-Path $readmePath) {
  $readme = Get-Content $readmePath -Raw
  if ($readme -match "blob/main|blob/") {
    $issues.Add("README still contains stale GitHub blob links.")
  }
  if ($readme -notmatch "browser-first") {
    $issues.Add("README is missing browser-first wording.")
  }
}

$publishMirrorRoot = Join-Path $repoRoot "github"
foreach ($mirrorPath in @("index.html", "participant\exercises.html", "participant\reflections.html", "kb\index.html")) {
  if (-not (Test-Path (Join-Path $publishMirrorRoot $mirrorPath))) {
    $issues.Add("Publish mirror missing required route: github\$mirrorPath")
  }
}

$docCount = (Get-ChildItem -Path (Join-Path $ProjectRoot "docs") -Filter *.html -ErrorAction SilentlyContinue | Measure-Object).Count
if ($docCount -lt $requiredDocs.Count) {
  $issues.Add("Expected at least $($requiredDocs.Count) HTML docs, found $docCount")
}

$kbCount = (Get-ChildItem -Path (Join-Path $ProjectRoot "web\kb") -Filter *.html -ErrorAction SilentlyContinue | Measure-Object).Count
if ($kbCount -lt 7) {
  $issues.Add("Expected at least 7 KB HTML pages, found $kbCount")
}

$browserFirstPages = @(
  "web\index.html",
  "web\participant\index.html",
  "web\parent\index.html",
  "web\leader\index.html",
  "web\facilitator\run-of-show.html",
  "docs\workshop_delivery_architecture.html",
  "docs\browser_first_environment_plan.html"
)
foreach ($path in $browserFirstPages) {
  $target = Join-Path $ProjectRoot $path
  if (Test-Path $target) {
    $raw = Get-Content $target -Raw
    if ($raw -notmatch "browser-first") {
      $issues.Add("Browser-first wording missing from $path")
    }
  }
}

$status = if ($issues.Count -eq 0) { "PASS" } else { "FAIL" }
$json = [ordered]@{
  timestamp = $timestamp
  status = $status
  webHtmlCount = (Get-ChildItem -Path (Join-Path $ProjectRoot "web") -Recurse -Filter *.html -ErrorAction SilentlyContinue | Measure-Object).Count
  docsHtmlCount = $docCount
  kbHtmlCount = $kbCount
  issues = $issues
}

($json | ConvertTo-Json -Depth 5) | Set-Content -Path (Join-Path $artifactDir "validation_result.json") -Encoding UTF8
$issueHtml = if ($issues.Count -eq 0) { "<li>None</li>" } else { ($issues | ForEach-Object { "<li>$($_)</li>" }) -join "" }
$html = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Delivery System Validation</title>
  <style>
    body { margin: 0; background: #f4f7fb; color: #1f2937; font: 16px/1.6 "Segoe UI", Arial, sans-serif; }
    .wrap { max-width: 980px; margin: 0 auto; padding: 28px 18px 44px; }
    .hero { background: linear-gradient(135deg, #123152, #0f4c81, #1d7a85); color: #fff; border-radius: 22px; padding: 24px; }
    .section { margin-top: 22px; background: #fff; border: 1px solid #d8e0ea; border-radius: 18px; padding: 20px; }
  </style>
</head>
<body>
  <div class="wrap">
    <section class="hero">
      <h1>Delivery System Validation</h1>
      <p>Status: $status</p>
      <p>Web HTML checked: $($json.webHtmlCount)</p>
      <p>Docs HTML checked: $docCount</p>
      <p>KB HTML checked: $kbCount</p>
    </section>
    <section class="section">
      <h2>Issues</h2>
      <ul>$issueHtml</ul>
    </section>
  </div>
</body>
</html>
"@
$html | Set-Content -Path (Join-Path $reportDir "validation_result.html") -Encoding UTF8
Write-Log "Validation completed with status $status"
if ($status -ne "PASS") { throw "Validation failed" }
