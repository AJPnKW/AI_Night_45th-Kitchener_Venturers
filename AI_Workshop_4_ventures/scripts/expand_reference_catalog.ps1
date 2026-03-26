#requires -version 5.1
[CmdletBinding()]
param([switch]$NoPause)
$ErrorActionPreference = 'Stop'
$workshopRoot = Split-Path -Parent $PSScriptRoot
$referenceRoot = Join-Path $workshopRoot 'reference_catalog'
$logRoot = Join-Path $workshopRoot 'logs'
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$runRoot = Join-Path $logRoot "expand_reference_catalog_$timestamp"
$logPath = Join-Path $runRoot 'expand_reference_catalog.log.txt'
$zipPath = Join-Path $runRoot "expand_reference_catalog_$timestamp.zip"
New-Item -ItemType Directory -Force -Path $referenceRoot, $runRoot | Out-Null
function Write-Log { param([string]$Message) $line = "[{0}] {1}" -f (Get-Date -Format 'u'), $Message; $line | Tee-Object -FilePath $logPath -Append }

$claimRows = @(
  [pscustomobject]@{ claim_id='CLM-001'; claim_text='Learners should be told that AI can sound confident while still being wrong, so outputs need checking.'; source_1_title='Does ChatGPT tell the truth?'; source_1_path_or_url='downloaded_sources\OpenAI\Does ChatGPT tell the truth_ _ OpenAI Help Center.pdf'; source_2_title='Societal Impact of Generative AI'; source_2_path_or_url='downloaded_sources\Code.org\Societal_Impact_of_Generative_AI.html'; validation_status='validated'; notes='Supports verification habit and anti-overtrust framing.' },
  [pscustomobject]@{ claim_id='CLM-002'; claim_text='Beginner prompting works better when the learner gives a goal, context, constraints, and the desired output format.'; source_1_title='How do I create a good prompt for an AI model?'; source_1_path_or_url='downloaded_sources\OpenAI\How do I create a good prompt for an AI model_ _.pdf'; source_2_title='Interacting with Language Models'; source_2_path_or_url='downloaded_sources\Code.org\Interacting_with_Language_Models.html'; validation_status='validated'; notes='Used for starter prompt formula and worksheet guidance.' },
  [pscustomobject]@{ claim_id='CLM-003'; claim_text='Youth-facing sessions should avoid entering personal or sensitive information into AI tools.'; source_1_title='Teen AI Literacy Blueprint'; source_1_path_or_url='downloaded_sources\OpenAI\Teen_AI_Literacy_Blueprint.pdf'; source_2_title='K-12 Education Community Overview'; source_2_path_or_url='downloaded_sources\OpenAI_Academy\K-12_Education_Community_Overview.html'; validation_status='validated'; notes='Used in participant, parent, and facilitator safety guidance.' },
  [pscustomobject]@{ claim_id='CLM-004'; claim_text='A first session should aim for a visible success within about the first 15 to 20 minutes.'; source_1_title='AI Lessons'; source_1_path_or_url='downloaded_sources\ISTE+ASCD\AI_Lessons.html'; source_2_title='ChatGPT Foundations for Teachers'; source_2_path_or_url='downloaded_sources\OpenAI_Academy\ChatGPT_Foundations_for_Teachers.html'; validation_status='validated'; notes='Supports common first-task design and early confidence.' },
  [pscustomobject]@{ claim_id='CLM-005'; claim_text='Mixed-ability learners benefit from scaffolded tasks with extension paths and fallback support.'; source_1_title='AI Lessons'; source_1_path_or_url='downloaded_sources\ISTE+ASCD\AI_Lessons.html'; source_2_title='ChatGPT Foundations for Teachers'; source_2_path_or_url='downloaded_sources\OpenAI_Academy\ChatGPT_Foundations_for_Teachers.html'; validation_status='validated'; notes='Used for ahead/behind/stuck pathway design.' },
  [pscustomobject]@{ claim_id='CLM-006'; claim_text='Custom instructions, memory, and project organization change how ChatGPT behaves and should be explained carefully to beginners.'; source_1_title='ChatGPT Custom Instructions'; source_1_path_or_url='downloaded_sources\OpenAI\ChatGPT Custom Instructions _ OpenAI Help Center.pdf'; source_2_title='What is Memory?'; source_2_path_or_url='downloaded_sources\OpenAI\What is Memory_ _ OpenAI Help Center.pdf'; validation_status='validated'; notes='Supports settings and personalization teaching segment.' },
  [pscustomobject]@{ claim_id='CLM-007'; claim_text='A youth workshop should emphasize hands-on making over long theory segments.'; source_1_title='Teach and Learn AI with Code.org'; source_1_path_or_url='downloaded_sources\Code.org\Teach_and_Learn_AI_with_Code.org.html'; source_2_title='Project Worksheets'; source_2_path_or_url='downloaded_sources\Machine_Learning_for_Kids\Project_Worksheets.html'; validation_status='validated'; notes='Supports hands-on-first delivery model.' },
  [pscustomobject]@{ claim_id='CLM-008'; claim_text='Parents need plain-language explanation of what ChatGPT is, what the youth will do, and how safety is handled.'; source_1_title='Parent Guardian Setup Flow'; source_1_path_or_url='workshop_pack\parent_guardian_setup_flow.html'; source_2_title='Teen AI Literacy Blueprint'; source_2_path_or_url='downloaded_sources\OpenAI\Teen_AI_Literacy_Blueprint.pdf'; validation_status='validated'; notes='Supports parent communication artifacts.' },
  [pscustomobject]@{ claim_id='CLM-009'; claim_text='Simple maker-style projects are a good fit for ages 15 to 18 when examples are concrete and personal.'; source_1_title='Tool Walkthroughs'; source_1_path_or_url='workshop_pack\tool_walkthroughs.html'; source_2_title='Writing Process with AI Tools'; source_2_path_or_url='downloaded_sources\Code.org\Writing_Process_with_AI_Tools.html'; validation_status='validated'; notes='Supports project menu and build blocks.' },
  [pscustomobject]@{ claim_id='CLM-010'; claim_text='AI outputs may include bias or incomplete perspectives, so learners should compare and question outputs.'; source_1_title='Is ChatGPT biased?'; source_1_path_or_url='downloaded_sources\OpenAI\Is ChatGPT biased_ _ OpenAI Help Center.pdf'; source_2_title='Societal Impact of Generative AI'; source_2_path_or_url='downloaded_sources\Code.org\Societal_Impact_of_Generative_AI.html'; validation_status='validated'; notes='Supports what beginners are not told segment.' },
  [pscustomobject]@{ claim_id='CLM-011'; claim_text='A short one-hour variant should compress theory and keep the shared success task plus one short build block.'; source_1_title='Learning Plan AI ChatGPT Session'; source_1_path_or_url='workshop_pack\learning_plan_ai_chatgpt_session.html'; source_2_title='Facilitator Slides'; source_2_path_or_url='workshop_pack\facilitator_slides.html'; validation_status='validated'; notes='Derived from existing local plan structure.' },
  [pscustomobject]@{ claim_id='CLM-012'; claim_text='Codex should be introduced to beginners as an AI coding helper that still needs human checking, not as magic autopilot.'; source_1_title='ChatGPT agent'; source_1_path_or_url='downloaded_sources\OpenAI\ChatGPT agent _ OpenAI Help Center.pdf'; source_2_title='Using Codex with your ChatGPT plan'; source_2_path_or_url='downloaded_sources\OpenAI\Using Codex with your ChatGPT plan _ OpenAI Help Center.pdf'; validation_status='validated'; notes='Supports safe beginner Codex awareness segment.' }
)

$slideRows = @(
  [pscustomobject]@{ slide_id='SLD-01'; topic='Welcome and why this night exists'; audience='participants + parents'; source_anchor='workshop_pack\learning_plan_ai_chatgpt_session.html'; reuse_type='adapt'; readiness='ready'; notes='Use event-specific opener and expectations.' },
  [pscustomobject]@{ slide_id='SLD-02'; topic='What AI is and is not'; audience='participants'; source_anchor='workshop_pack\facilitator_slides.html'; reuse_type='adapt'; readiness='ready'; notes='Keep concrete, no hype language.' },
  [pscustomobject]@{ slide_id='SLD-03'; topic='What ChatGPT does well and poorly'; audience='participants'; source_anchor='downloaded_sources\OpenAI\What is ChatGPT_ _ OpenAI Help Center.pdf'; reuse_type='compose'; readiness='ready'; notes='Pair capability with limits.' },
  [pscustomobject]@{ slide_id='SLD-04'; topic='Safety: no personal info, verify outputs'; audience='participants + parents'; source_anchor='downloaded_sources\OpenAI\Teen_AI_Literacy_Blueprint.pdf'; reuse_type='compose'; readiness='ready'; notes='Should be visible early in the session.' },
  [pscustomobject]@{ slide_id='SLD-05'; topic='Prompt recipe for beginners'; audience='participants'; source_anchor='workshop_pack\tool_walkthroughs.html'; reuse_type='adapt'; readiness='ready'; notes='Goal, context, constraints, format.' },
  [pscustomobject]@{ slide_id='SLD-06'; topic='Common first prompt task'; audience='participants'; source_anchor='workshop_pack\learner_worksheet.html'; reuse_type='adapt'; readiness='ready'; notes='Same-task early success slide.' },
  [pscustomobject]@{ slide_id='SLD-07'; topic='Project pathway menu'; audience='participants'; source_anchor='workshop_pack\project_sheets\project_menu.html'; reuse_type='adapt'; readiness='ready'; notes='Three or four guided pathway options.' },
  [pscustomobject]@{ slide_id='SLD-08'; topic='How leaders support the room'; audience='leaders'; source_anchor='workshop_pack\learning_plan_ai_chatgpt_session.html'; reuse_type='compose'; readiness='draft'; notes='Operational support cues and supervision role.' },
  [pscustomobject]@{ slide_id='SLD-09'; topic='Parent setup and permission summary'; audience='parents'; source_anchor='workshop_pack\parent_guardian_setup_flow.html'; reuse_type='adapt'; readiness='ready'; notes='One-slide summary for handout or parent page.' },
  [pscustomobject]@{ slide_id='SLD-10'; topic='Codex and coding agents for beginners'; audience='participants'; source_anchor='downloaded_sources\OpenAI\Using Codex with your ChatGPT plan _ OpenAI Help Center.pdf'; reuse_type='compose'; readiness='draft'; notes='Frame as helper, not replacement for thinking.' },
  [pscustomobject]@{ slide_id='SLD-11'; topic='One-hour compressed version'; audience='facilitator'; source_anchor='workshop_pack\learning_plan_ai_chatgpt_session.html'; reuse_type='compose'; readiness='draft'; notes='Internal facilitator-only timing slide.' },
  [pscustomobject]@{ slide_id='SLD-12'; topic='Show-and-share close'; audience='participants'; source_anchor='workshop_pack\learning_plan_ai_chatgpt_session.html'; reuse_type='adapt'; readiness='ready'; notes='Reflection and next-step prompts.' }
)

$claimCsv = Join-Path $referenceRoot 'source_claim_validation.csv'
$claimMd = Join-Path $referenceRoot 'source_claim_validation.md'
$slideCsv = Join-Path $referenceRoot 'slide_candidate_matrix.csv'
$slideMd = Join-Path $referenceRoot 'slide_candidate_matrix.md'
$learningPlanMd = Join-Path $referenceRoot 'learning_plan_expansion.md'

$claimRows | Export-Csv -Path $claimCsv -NoTypeInformation -Encoding UTF8
$slideRows | Export-Csv -Path $slideCsv -NoTypeInformation -Encoding UTF8

$claimMdBody = ($claimRows | ForEach-Object { "| $($_.claim_id) | $($_.claim_text) | $($_.source_1_title) | $($_.source_1_path_or_url) | $($_.source_2_title) | $($_.source_2_path_or_url) | $($_.validation_status) | $($_.notes) |" }) -join "`r`n"
@"
# Source Claim Validation

This matrix tracks factual claims used in the expanded workshop learning system. Claims are validated against at least two credible local sources where possible.

| Claim ID | Claim | Source 1 | Source 1 Path | Source 2 | Source 2 Path | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
$claimMdBody
"@ | Set-Content -Path $claimMd -Encoding UTF8

$slideMdBody = ($slideRows | ForEach-Object { "| $($_.slide_id) | $($_.topic) | $($_.audience) | $($_.source_anchor) | $($_.reuse_type) | $($_.readiness) | $($_.notes) |" }) -join "`r`n"
@"
# Slide Candidate Matrix

| Slide ID | Topic | Audience | Source Anchor | Reuse Type | Readiness | Notes |
| --- | --- | --- | --- | --- | --- | --- |
$slideMdBody
"@ | Set-Content -Path $slideMd -Encoding UTF8

Get-Content (Join-Path $referenceRoot 'learning_plan_expansion.md') -ErrorAction SilentlyContinue | Out-Null
Write-Log "source_claim_validation_csv=$claimCsv"
Write-Log "source_claim_validation_md=$claimMd"
Write-Log "slide_candidate_matrix_csv=$slideCsv"
Write-Log "slide_candidate_matrix_md=$slideMd"
Write-Log "learning_plan_expansion_md=$learningPlanMd"
Compress-Archive -Path @($claimCsv,$claimMd,$slideCsv,$slideMd,$learningPlanMd,$logPath) -DestinationPath $zipPath -Force
Write-Log "zip_bundle=$zipPath"
Write-Log 'COMPLETE'
Write-Host "Reference catalog expansion complete.`nZIP: $zipPath" -ForegroundColor Green
if (-not $NoPause) { Write-Host "`nPress ENTER to exit..." -ForegroundColor Yellow; [void][System.Console]::ReadLine() }
