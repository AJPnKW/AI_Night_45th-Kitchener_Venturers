# Form And Data Handling Decision Record

Decision: use a static-site-compatible third-party form handler pattern with a configurable endpoint in `AI_Workshop_4_ventures/web/assets/js/site.js`.

Current refinement: the live collection configuration is now separated into `AI_Workshop_4_ventures/web/assets/js/site-config.js` so the collection destination can be updated without editing the core workflow logic.

Why:

- works with GitHub Pages
- avoids building a backend
- supports minimal data collection
- can be disabled until ready
- supports a real organizer copy and a response list once the endpoint is set

Fallback:

- printable approval capture using the same minimum field set
- downloadable JSON copy from the browser
- local draft save on the current device

Controls:

- minimal fields only
- organizer-controlled contact details
- delete collected records after short event follow-up
- use one controlled inbox/dashboard so the facilitator can review who submitted
