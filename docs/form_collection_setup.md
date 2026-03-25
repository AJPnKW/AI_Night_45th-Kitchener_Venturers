# Form Collection Setup

This site can collect completed participant sign-up and parent waiver forms, but GitHub Pages cannot store submissions by itself.

## What "off device" means

Without a live submission inbox, the entered form data stays only in the participant or parent browser unless they print it or download it.

With a live submission inbox, the form sends a copy to an external destination you control so you can:

- see who submitted
- review the data they entered
- keep one organizer copy
- follow up with anyone who still has missing setup or approval items

## Current implementation pattern

The live collection switch is now centralized in:

- [site-config.js](/C:/Users/andrew/PROJECTS/Scouter_Jenn/AI_Workshop_4_ventures/web/assets/js/site-config.js)

Relevant fields:

- `formEndpoint`
- `formServiceName`
- `volunteerContactLabel`
- `volunteerContactValue`
- `submissionInboxLabel`
- `submissionInboxValue`
- `submissionInboxUrl`

## What still must be supplied

One real form destination is still required. The simplest options are:

1. a form endpoint URL from a service such as Formspree
2. an email-based form receiver such as FormSubmit
3. a Google Apps Script or similar endpoint that writes into a Google Sheet

Until one of those exists, the forms can only:

- save drafts on the current device
- download the entered details
- print or save as PDF

## Recommended organizer outcome

For this project, the practical goal is:

- one inbox or dashboard that receives both participant sign-up and parent waiver submissions
- a visible response list the facilitator can check before the session
- a copy of each submission for follow-up and record keeping

## After endpoint setup

Once the real endpoint is added to `site-config.js`, the public workflow pages will submit directly and the facilitator page will show the configured submission inbox label/value.
