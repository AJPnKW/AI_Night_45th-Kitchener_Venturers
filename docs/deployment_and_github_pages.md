# Deployment And GitHub Pages

The site is ready for GitHub Pages because it is plain static content with no required build step.

Deployment notes:

- use `AI_Workshop_4_ventures/web/` as the standard editing/reference folder
- publish from the `github/` folder content, which mirrors `AI_Workshop_4_ventures/web/`
- ensure the configurable form settings in `AI_Workshop_4_ventures/web/assets/js/site-config.js` match the current live collection setup
- test print output and the consent fallback before event use
- workflow file: `.github/workflows/deploy-pages.yml`
- expected deployment source: `main` branch via GitHub Actions, uploading the `github/` folder as the Pages artifact
- public README links remain limited to participant, parent / guardian, consent, and privacy
- GitHub Pages is currently enabled for the repository

Expected default live base URL if Pages is enabled without a custom domain:

- `https://ajpnkw.github.io/AI_Night_1st-Stanley-Park_Venture-Company/`

If the repository is later connected to Pages with a custom workflow, keep the output identical to the current static file structure.


