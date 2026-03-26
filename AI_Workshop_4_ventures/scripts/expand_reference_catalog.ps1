
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
function Write-Log {
  param([string]$Message)
  $line = "[{0}] {1}" -f (Get-Date -Format 'u'), $Message
  $line | Tee-Object -FilePath $logPath -Append
}

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
$exerciseMd = Join-Path $referenceRoot 'exercises_and_activity_bank.md'
$codexMd = Join-Path $referenceRoot 'codex_beginner_segment.md'
$teenMd = Join-Path $referenceRoot 'teen_safe_use_and_parent_controls.md'
$limitsMd = Join-Path $referenceRoot 'what_beginners_are_not_told.md'

$claimRows | Export-Csv -Path $claimCsv -NoTypeInformation -Encoding UTF8
$slideRows | Export-Csv -Path $slideCsv -NoTypeInformation -Encoding UTF8
$claimMdBody = ($claimRows | ForEach-Object {
  "| $($_.claim_id) | $($_.claim_text) | $($_.source_1_title) | $($_.source_1_path_or_url) | $($_.source_2_title) | $($_.source_2_path_or_url) | $($_.validation_status) | $($_.notes) |"
}) -join "`r`n"
$claimMdContent = @"
# Source Claim Validation

This matrix tracks factual claims used in the expanded workshop learning system. Claims are validated against at least two credible local sources where possible.

| Claim ID | Claim | Source 1 | Source 1 Path | Source 2 | Source 2 Path | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
$claimMdBody

## Validation Notes

- Primary references favor local OpenAI Help, OpenAI Academy, Code.org, ISTE/ASCD, and the locally saved workshop pack.
- Claims used for youth safety, prompting, and session design were prioritized.
- This file should be extended rather than replaced when future workshop content is added.
"@
$claimMdContent | Set-Content -Path $claimMd -Encoding UTF8

$slideMdBody = ($slideRows | ForEach-Object {
  "| $($_.slide_id) | $($_.topic) | $($_.audience) | $($_.source_anchor) | $($_.reuse_type) | $($_.readiness) | $($_.notes) |"
}) -join "`r`n"
$slideMdContent = @"
# Slide Candidate Matrix

This matrix identifies slide-ready source material already cached locally and shows how it should be reused for the workshop system.

| Slide ID | Topic | Audience | Source Anchor | Reuse Type | Readiness | Notes |
| --- | --- | --- | --- | --- | --- | --- |
$slideMdBody

## Crosswalk Notes

- `workshop_pack\facilitator_slides.html` remains the strongest local base for participant-facing live teaching slides.
- `workshop_pack\learning_plan_ai_chatgpt_session.html` is the operational timing spine.
- `workshop_pack\parent_guardian_setup_flow.html` is the base source for parent slide and handout content.
- Local OpenAI references fill the gaps around ChatGPT settings, memory, projects, and Codex framing.
"@
$slideMdContent | Set-Content -Path $slideMd -Encoding UTF8

$learningPlanContent = @"
# Learning Plan Expansion

## Purpose

Expand the existing local 90-minute session outline into a workshop system that supports pre-work, live delivery, parent understanding, and facilitator adaptation.

## Existing File Crosswalk

| Existing File | What It Already Covers | What Is Outdated or Thin | How To Reuse It |
| --- | --- | --- | --- |
| `workshop_pack\learning_plan_ai_chatgpt_session.html` | 90-minute structure, learning goals, project time, closing reflection | Needs richer adaptive paths and clearer learner-facing checkpoints | Use as the master timing spine |
| `workshop_pack\facilitator_slides.html` | Slide topic order, AI basics, safety, prompts | Too general in places and needs stronger event-specific framing | Use as slide seed set |
| `workshop_pack\learner_worksheet.html` | Guided learner prompts and reflection | Needs tighter linkage to live project pathways | Use as first-task and reflection support |
| `workshop_pack\parent_guardian_setup_flow.html` | Parent awareness and setup support | Needs clearer age and permission-safe framing | Use as parent communication reference |
| `workshop_pack\tool_walkthroughs.html` | Practical starter use cases and examples | Needs stronger progression from demo to independent build | Use as activity bank source |

## Detailed Topic Expansion

### 1. Intro to AI: What AI Is and Is Not

- Purpose: remove hype, reduce confusion, and give the youth a stable mental model.
- Audience fit: mixed-ability Venturer learners with varied prior exposure.
- Delivery mode: 5-minute live explanation plus one concrete example.
- Time required: 5 minutes in the 90-minute model, 3 minutes in the 1-hour version.
- Facilitator preparation: choose one example of pattern-based generation and one limit case.
- Learner steps: listen, compare a normal tool vs AI helper, answer one short prompt like "what surprised you?"
- Exercise/task sequence: show example, ask what AI did well, ask what still needed human checking.
- Work effort: low.
- Expected outputs: shared understanding that AI is a helper, not a truth machine.
- Risks/misuse: overhype, anthropomorphism, fear-based framing.
- Validation notes: supported by Code.org intro materials plus OpenAI help references.
- Adaptation notes for scouts / youth group / parents: use practical language, not technical jargon.

### 2. Intro to ChatGPT: How to Use It Well

- Purpose: build the learner's first useful interaction pattern.
- Audience fit: beginners ages 15 to 18.
- Delivery mode: live demo followed by a same-task common first prompt.
- Time required: 10 minutes combined demo plus guided attempt.
- Facilitator preparation: preload one weak prompt and one improved prompt.
- Learner steps: copy the prompt recipe, run the task, compare results, improve once.
- Exercise/task sequence: ask -> check -> improve -> format.
- Work effort: low to medium.
- Expected outputs: one successful prompt/result pair per learner.
- Risks/misuse: copy-paste without understanding, assuming first output is final.
- Validation notes: aligned to OpenAI prompt guidance and Code.org interaction lessons.
- Adaptation notes: model exact steps, keep vocabulary concrete.
"@
$learningPlanContent | Set-Content -Path $learningPlanMd -Encoding UTF8
Add-Content -Path $learningPlanMd -Encoding UTF8 -Value @"

### 3. Teen-Safe Use / Parent Controls / Approvals

- Purpose: make safe supervised use explicit before independent making begins.
- Audience fit: participants, parents, leaders, facilitator.
- Delivery mode: pre-work page plus parent summary plus short spoken reminder.
- Time required: 5 minutes in-session plus pre-session review.
- Facilitator preparation: know the local approval path and what not to collect.
- Learner steps: avoid personal data, use first name only if needed, ask when unsure.
- Exercise/task sequence: quick examples of okay vs not-okay prompt content.
- Work effort: low.
- Expected outputs: fewer risky prompts and clearer parent confidence.
- Risks/misuse: drifting into legalistic language or vague safety warnings.
- Validation notes: anchored to Teen AI Literacy Blueprint and K-12 community guidance.
- Adaptation notes: keep it calm, specific, and non-alarmist.

### 4. Prompting, Rulesets, Personalization, and Settings

- Purpose: show that tool behavior changes when the learner gives better guidance.
- Audience fit: beginners who are ready for one layer deeper after first success.
- Delivery mode: guided mini-lesson plus optional extension card.
- Time required: 10 to 15 minutes.
- Facilitator preparation: prepare one example using role, audience, tone, and output format.
- Learner steps: add context, choose a format, optionally compare default vs guided output.
- Exercise/task sequence: baseline prompt, improved prompt, reflection on difference.
- Work effort: medium.
- Expected outputs: one improved prompt template learners can reuse later.
- Risks/misuse: too much settings detail too early.
- Validation notes: supported by custom instructions and memory references.
- Adaptation notes: optionalize settings depth for slower learners.

### 5. Hands-On Beginner Activities for Ages 15-18

- Purpose: make the session personal and practical.
- Audience fit: youth with mixed skill and confidence levels.
- Delivery mode: project menu with 3 to 4 choices.
- Time required: 35 to 45 minutes in the 90-minute version.
- Facilitator preparation: curate pathways such as trip planner, resume helper, scout activity idea bank, short story or script helper.
- Learner steps: choose a pathway, answer worksheet prompts, generate, improve, prepare one thing to share.
- Exercise/task sequence: choose -> prompt -> test -> refine -> share.
- Work effort: medium.
- Expected outputs: one personal mini-project and a share-back artifact.
- Risks/misuse: too many choices causing paralysis.
- Validation notes: supported by existing tool walkthroughs and writing-with-AI teaching examples.
- Adaptation notes: keep choices limited and labeled by difficulty.

### 6. Scout / Youth-Group Adaptation

- Purpose: make the workshop feel relevant to Venturer contexts without becoming childish.
- Audience fit: older youth in a volunteer-led scouting environment.
- Delivery mode: examples and project prompts tied to events, planning, badges, trips, service, and communication.
- Time required: integrated throughout rather than isolated.
- Facilitator preparation: prepare scout-relevant examples but avoid implying official organizational ownership.
- Learner steps: optionally choose a scouting-relevant project lane.
- Exercise/task sequence: reuse the standard prompt flow with scout-themed outputs.
- Work effort: low.
- Expected outputs: higher engagement and easier prompt ideas.
- Risks/misuse: over-branding or confusing unofficial vs official communication.
- Validation notes: based on workshop goals and parent confidence needs.
- Adaptation notes: keep the disclaimer model visible.
"@

Add-Content -Path $learningPlanMd -Encoding UTF8 -Value @"

### 7. Intro to Codex / Beginner Coding-Agent Awareness

- Purpose: explain that some AI tools can help with code and structured tasks.
- Audience fit: participants who ask about coding or are already experimenting.
- Delivery mode: optional short extension segment or facilitator side-note.
- Time required: 5 to 8 minutes.
- Facilitator preparation: have one example of asking for a simple HTML tweak or checklist automation.
- Learner steps: observe example, identify what the human still must check.
- Exercise/task sequence: ask, inspect, test, verify.
- Work effort: medium for facilitator, low for learners.
- Expected outputs: healthy mental model of AI coding help.
- Risks/misuse: magic-tool framing, overtrust, security/privacy blind spots.
- Validation notes: supported by local OpenAI agent and Codex help references.
- Adaptation notes: keep this optional unless the group is moving quickly.

### 8. What Beginners Usually Are Not Told

- Purpose: inoculate learners against overtrust and confusion.
- Audience fit: all participants, but keep language plain.
- Delivery mode: short talk woven through the session and a final recap.
- Time required: 5 minutes total in short bursts.
- Facilitator preparation: prepare concise examples of wrong-but-confident output, bias, and privacy mistakes.
- Learner steps: compare, question, verify, revise.
- Exercise/task sequence: spot one problem in an output and describe how to improve it.
- Work effort: low.
- Expected outputs: healthier caution and better habits.
- Risks/misuse: making the tool feel useless or unsafe to try.
- Validation notes: anchored to bias, truthfulness, and generated-links references.
- Adaptation notes: tone should be practical, not fear-based.

## Implied Needs Expansion

### Age / Permission-Safe Delivery
- Why implied: the workshop includes youth using ChatGPT, so supervision and plain-language parent awareness are required.
- Existing mapping: `workshop_pack\parent_guardian_setup_flow.html`.
- Missing: workshop-local validation and broader facilitator notes.
- Generated material: `teen_safe_use_and_parent_controls.md` plus claim validation entries.

### One-Hour Version
- Why implied: volunteer-led events often need a compressed fallback.
- Existing mapping: the local learning plan already sequences intro, demo, project, and reflection.
- Missing: explicit 60-minute compression guidance.
- Generated material:
  - 0-5 min arrival and setup
  - 5-10 min AI / ChatGPT safety intro
  - 10-18 min live demo
  - 18-28 min common first task
  - 28-48 min single build block
  - 48-57 min show/share
  - 57-60 min close and next steps

### Slide-Ready Source Material
- Why implied: the local pack already includes slides, but they need prioritization and reuse guidance.
- Existing mapping: `workshop_pack\facilitator_slides.html`.
- Missing: a selection matrix.
- Generated material: `slide_candidate_matrix.csv` and `slide_candidate_matrix.md`.

### Hands-On First, Theory Second
- Why implied: mixed-ability learners need quick wins more than extended lecture.
- Existing mapping: workshop plan and walkthroughs already bias toward doing.
- Missing: explicit rationale and facilitator reminder.
- Generated material: early-success requirement, same-task guided moment, and capped passive segments across this file and `exercises_and_activity_bank.md`.

### How to Make ChatGPT Work for You
- Why implied: the event is practical, not just informational.
- Existing mapping: `workshop_pack\tool_walkthroughs.html`.
- Missing: a single structured progression from prompt basics to project work.
- Generated material: topic sections 2, 4, and 5 in this file plus the activity bank.

### Safe Beginner Explanation of Codex
- Why implied: older teens will ask about coding and agentic tools.
- Existing mapping: local OpenAI agent/Codex references exist, but not workshop-local framing.
- Missing: youth-safe explanation and guardrails.
- Generated material: `codex_beginner_segment.md`.
"@
$exerciseContent = @"
# Exercises and Activity Bank

## Purpose

Provide activity-ready options that are detailed enough for a facilitator to run without reinventing the session during delivery.

## Activity 1: First Prompt Win

- Purpose: give everyone an early successful result.
- Audience fit: complete beginners.
- Delivery mode: whole-group guided task.
- Time required: 5 to 7 minutes.
- Facilitator preparation: choose one prompt example and one improved version.
- Learner steps:
  1. Open ChatGPT.
  2. Paste or type the common starter prompt.
  3. Read the first result.
  4. Add one improvement instruction.
  5. Compare versions.
- Exercise sequence: baseline -> refine -> compare.
- Work effort: low.
- Expected outputs: a successful output for every learner.
- Risks/misuse: jumping ahead before the group catches up.
- Validation notes: matches prompt-design guidance and early-success pedagogy.
- Adaptation notes: offer a printed fallback prompt card.

## Activity 2: Project Pathway Menu

### Pathway A: Event Planner Helper
- Purpose: use AI for structured planning.
- Learner steps: ask for a checklist, refine for budget or time constraints, convert to a shareable list.
- Expected outputs: a planning checklist.

### Pathway B: Scout Activity Idea Builder
- Purpose: connect AI to youth-group scenarios.
- Learner steps: ask for age-fit activity ideas, screen for realism, refine one chosen idea.
- Expected outputs: one usable activity concept.

### Pathway C: Short Script or Message Draft
- Purpose: show writing support use.
- Learner steps: ask for a short announcement or script, tune tone and audience, verify details.
- Expected outputs: one polished short draft.

### Pathway D: Learn-Something-Quick Research Helper
- Purpose: use AI to structure curiosity.
- Learner steps: ask for explanation, ask follow-up questions, verify one claim elsewhere.
- Expected outputs: one mini learning summary with one verified point.

## Activity 3: Stuck Recovery Ladder

- Purpose: keep learners moving when they freeze or get poor outputs.
- Audience fit: anyone stuck.
- Delivery mode: facilitator prompt card or screen reminder.
- Time required: 2 to 3 minutes.
- Facilitator preparation: post the ladder visibly.
- Learner steps:
  1. Say what you want in one sentence.
  2. Say who it is for.
  3. Say what format you want.
  4. Ask for three options instead of one.
  5. Ask a leader or facilitator for a reset prompt.
- Expected outputs: reduced stall-outs.
- Risks/misuse: learners repeating the same bad prompt without reframing it.
- Validation notes: built from prompt-guidance sources and local live-delivery needs.
- Adaptation notes: especially helpful for neurodivergent learners because the ladder is predictable.

## Activity 4: Fast Learner Extension

- Purpose: keep quicker learners engaged without splitting the room.
- Delivery mode: optional extension card.
- Time required: 5 to 15 extra minutes.
- Learner steps: add tone control, format control, compare two prompt styles, or convert output into a checklist, table, or script.
- Expected outputs: richer output without changing the main project.
- Risks/misuse: turning extension into a different workshop.

## Activity 5: Parent Co-Review Task

- Purpose: connect home awareness to workshop readiness.
- Delivery mode: pre-work.
- Time required: 5 minutes.
- Learner steps: show the parent page, confirm setup status, review the no-personal-data rule.
- Expected outputs: clearer permission and fewer setup surprises.
"@
$exerciseContent | Set-Content -Path $exerciseMd -Encoding UTF8

$codexContent = @"
# Codex Beginner Segment

## Purpose

Introduce Codex or coding-agent ideas safely to beginners without making it sound like magic or implying that coding judgment is unnecessary.

## Why This Is Implied

The workshop theme is AI / ChatGPT, one learner already has coding exposure, and older youth often ask whether AI can help write code. The session needs a safe answer ready.

## Existing Local Mapping

- Local OpenAI references cover ChatGPT agents and Codex usage.
- No beginner-safe workshop-local explanation existed in the catalog.

## Delivery Model

- Audience fit: optional extension for ages 15 to 18.
- Delivery mode: 5 to 8 minute side segment or extension card.
- Facilitator preparation: one simple example, such as asking for a tiny HTML snippet or checklist script.
- Learner steps:
  1. Describe the small task.
  2. Ask the tool for help.
  3. Read the result.
  4. Test it.
  5. Fix it if needed.
- Expected outputs: understanding that coding agents help with drafting, but humans still review and test.

## Safe Framing

- Codex is a helper, not an autopilot.
- It can produce useful drafts quickly.
- It can also produce errors, insecure patterns, or code that does not match the real need.
- You still need to inspect, test, and decide.

## Risks and Misuse

- Overtrust in untested code.
- Sharing secrets or private data in prompts.
- Copying code without understanding what it does.

## Scout / Youth Adaptation

Use examples like:
- a simple event checklist page
- a patrol duty reminder layout
- a tiny HTML badge-progress mock-up

Keep examples harmless, small, and easy to inspect.
"@
$codexContent | Set-Content -Path $codexMd -Encoding UTF8
$teenContent = @"
# Teen Safe Use and Parent Controls

## Purpose

Provide one workshop-local reference that explains how the event should handle age, supervision, privacy, and parent awareness.

## Why This Is Implied

The site already includes participant and parent flows, and the workshop involves youth using ChatGPT. Safe-use expectations and parent awareness must be clear, concise, and non-corporate.

## Core Model

- supervised use during the event
- no personal or sensitive information entered into AI tools
- minimal readiness data only
- parent review path visible before the event
- age-aware permission handling if required by tool or provider rules

## Audience Fit

- Participants: need simple do/don't guidance.
- Parents/guardians: need confidence and clarity.
- Leaders: need supervision cues.
- Facilitator: needs a practical rule set.

## Detailed Guidance

### What the Youth Should Hear
- AI can be helpful, but it can be wrong.
- Do not put private details into prompts.
- If you are unsure whether something is okay to enter, ask first.
- We are using the tool in a supervised, learning-focused way.

### What Parents Should Hear
- The activity is structured and supervised.
- The workshop is about learning how to use the tool responsibly, not unrestricted experimentation.
- Setup help may be needed at home before the event.
- Only minimal readiness information should be collected.

### What Leaders Should Watch For
- learners typing names, addresses, phone numbers, or other personal details
- learners getting stuck and becoming frustrated
- learners moving too fast and drifting off-task
- learners needing a predictable next step

### What the Facilitator Should Control
- the shared prompt examples
- the explanation of safe use
- the room tempo and transitions
- the escalation path when a learner is unsure

## Parent Controls and Approval Notes

- Review the participant pre-work and parent page together if possible.
- Confirm account readiness at home where needed.
- Keep approval wording plain: what the youth will do, what they should not share, and how the event is supervised.

## Validation Notes

Built from the local Teen AI Literacy Blueprint, OpenAI Academy K-12 community guidance, and the existing parent flow artifact.
"@
$teenContent | Set-Content -Path $teenMd -Encoding UTF8

$limitsContent = @"
# What Beginners Are Not Told

## Purpose

Capture the missing truths that often get skipped in first AI sessions so the workshop stays honest and practical.

## Why This Is Implied

Many beginner intros focus on novelty and speed. Youth need a more grounded model so they do not confuse smooth output with trustworthy output.

## The Gaps Beginners Usually Are Not Told About

### 1. AI Can Sound Sure and Still Be Wrong
- Meaning: a polished answer is not proof.
- What to teach: check important facts, dates, links, and claims.
- Validation basis: truthfulness and generated-links references.

### 2. AI Often Needs Iteration
- Meaning: the first answer is a draft, not a final product.
- What to teach: ask follow-up questions, tighten the request, and compare versions.
- Validation basis: prompt guidance and interaction references.

### 3. Bias and Gaps Still Show Up
- Meaning: outputs can reflect uneven or biased patterns.
- What to teach: compare perspectives and notice what is missing.
- Validation basis: bias and societal-impact references.

### 4. Privacy Is the User's Responsibility Too
- Meaning: the tool does not automatically know what is okay to share.
- What to teach: never enter sensitive or personal details.
- Validation basis: teen-safe-use references.

### 5. Convenience Can Create Overtrust
- Meaning: speed feels helpful, which can reduce careful checking.
- What to teach: use AI to support thinking, not replace it.
- Validation basis: teaching references and workshop goals.

## Delivery Notes

- Keep this section practical, not fear-heavy.
- Spread the warnings across the session instead of delivering one long warning speech.
- Pair every caution with a usable habit.

## Useful Habit Pairings

- wrong-but-confident -> verify one key claim
- weak prompt -> add goal, audience, and format
- privacy risk -> remove names and specifics
- biased answer -> ask for another perspective
- overtrust -> compare with another source
"@
$limitsContent | Set-Content -Path $limitsMd -Encoding UTF8

$generated = @($claimCsv,$claimMd,$slideCsv,$slideMd,$learningPlanMd,$exerciseMd,$codexMd,$teenMd,$limitsMd)
Write-Log "source_claim_validation_csv=$claimCsv"
Write-Log "source_claim_validation_md=$claimMd"
Write-Log "slide_candidate_matrix_csv=$slideCsv"
Write-Log "slide_candidate_matrix_md=$slideMd"
Write-Log "learning_plan_expansion_md=$learningPlanMd"
Write-Log "exercises_and_activity_bank_md=$exerciseMd"
Write-Log "codex_beginner_segment_md=$codexMd"
Write-Log "teen_safe_use_and_parent_controls_md=$teenMd"
Write-Log "what_beginners_are_not_told_md=$limitsMd"
Compress-Archive -Path (@($generated) + @($logPath)) -DestinationPath $zipPath -Force
Write-Log "zip_bundle=$zipPath"
Write-Log 'COMPLETE'
Write-Host "Reference catalog expansion complete.`nZIP: $zipPath" -ForegroundColor Green
if (-not $NoPause) {
  Write-Host "`nPress ENTER to exit..." -ForegroundColor Yellow
  [void][System.Console]::ReadLine()
}
