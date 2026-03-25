# Privacy And Consent Model

The privacy model is intentionally lightweight and volunteer-appropriate.

- Minimum default fields: first name, age, participant email, parent/guardian acknowledgement
- Optional field: parent/guardian email
- Not collected by default: last name, birthdate, unnecessary profile data
- Storage intent: event coordination only
- Access intent: organizer and leaders who need it
- Retention target: delete within 30 days after event follow-up

The consent page supports a static-site-compatible third-party form endpoint. Until configured, the site presents a printable fallback process using the same minimum field set.

Current collection model:

- participant sign-up and parent waiver forms can submit into one organizer-controlled inbox/dashboard once `assets/js/site-config.js` is configured
- until that happens, data is only kept locally in the browser unless the user downloads or prints it
- the organizer should use a single controlled collection destination so they can see who has submitted and review the entered readiness or approval details
