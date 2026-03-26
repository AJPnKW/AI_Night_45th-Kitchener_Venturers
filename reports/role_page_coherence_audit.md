# Role Page Coherence Audit

Date: 2026-03-24

## Files Reviewed

- `AI_Workshop_4_ventures/web/participant/index.html`
- `AI_Workshop_4_ventures/web/leader/index.html`
- `AI_Workshop_4_ventures/web/facilitator/index.html`
- `github/participant/index.html`
- `github/leader/index.html`
- `github/facilitator/index.html`

## Files Changed

- `AI_Workshop_4_ventures/web/participant/index.html`
- `AI_Workshop_4_ventures/web/leader/index.html`
- `AI_Workshop_4_ventures/web/facilitator/index.html`

## Mismatches Found

- participant, leader, and facilitator pages did not present one shared session snapshot
- facilitator used a separate minute-by-minute framing while participant and leader were more generic
- role pages lacked a consistent before / during / after task structure
- logistical assumptions were implied in some pages and absent in others
- terminology drift existed between “prompt practice,” “project build time,” and more general wording

## Fixes Applied

- normalized all three pages to one shared five-step session flow
- added the same workshop framing, support model, and logistical assumptions to each page
- added role-specific task lists for before, during, and after the session
- kept audience-specific responsibilities separate by page
- preserved existing layout, page classes, and navigation patterns

## Assumptions Made

- no newer explicit date, time, or location values were found in the tracked site files
- the final reminder from AI Night is therefore the consistent source for date, time, and location
- the baseline operational assumptions from the request were used: 6 participants, 3 scouters, Wi-Fi available, participant laptops or Chromebooks, optional pre-homework, mixed ability, beginner-friendly structure

## Final Consistency Check

- the same workshop purpose now appears across participant, leader, and facilitator pages
- the same five-step sequence now appears across participant, leader, and facilitator pages
- task ownership is now clearly separated by role
- no conflicting session instructions remain in the three reviewed role pages

