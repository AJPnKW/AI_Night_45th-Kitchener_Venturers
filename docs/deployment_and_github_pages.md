# Deployment And GitHub Pages

The site is ready for GitHub Pages because it is plain static content with no required build step.

Deployment notes:

- use `AI_Workshop_4_ventures/web/` as the standard editing/reference folder
- publish from the `github/` folder content, which mirrors `AI_Workshop_4_ventures/web/`
- ensure the configurable form endpoint in `AI_Workshop_4_ventures/web/assets/js/site.js` is updated before collecting live approvals
- test print output and the consent fallback before event use
- workflow file: `.github/workflows/deploy-pages.yml`
- expected deployment source: `main` branch via GitHub Actions, uploading the `github/` folder as the Pages artifact
- public README links remain limited to participant, parent / guardian, consent, and privacy
- current GitHub-side blocker: the repository returned `422 Your current plan does not support GitHub Pages for this repository` when Pages activation was attempted

Expected default live base URL if Pages is enabled without a custom domain:

- `https://ajpnkw.github.io/Scouter_Jenn/`

If the repository is later connected to Pages with a custom workflow, keep the output identical to the current static file structure.
