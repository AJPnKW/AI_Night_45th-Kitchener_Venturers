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

## Current configured destination

The site is now configured to send form submissions to:

- `andrewjpearen@gmail.com`

using:

- FormSubmit

Configured file:

- [site-config.js](/C:/Users/andrew/PROJECTS/Scouter_Jenn/AI_Workshop_4_ventures/web/assets/js/site-config.js)

## One-time organizer action still required

FormSubmit usually sends a first-use activation email to the target inbox. The organizer must open that email and confirm activation before normal form delivery starts.

## Recommended organizer outcome

For this project, the practical goal is:

- one inbox or dashboard that receives both participant sign-up and parent waiver submissions
- a visible response list the facilitator can check before the session
- a copy of each submission for follow-up and record keeping

## After endpoint setup

The public workflow pages now submit directly to the configured FormSubmit destination, and the facilitator page shows the configured submission inbox label/value.
