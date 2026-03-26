# GitHub Pages Publish Audit

Date: 2026-03-24

## Files Reviewed

- `.github/workflows/deploy-pages.yml`
- `github/index.html`
- `github/404.html`
- `github/participant/index.html`
- `github/parent/index.html`
- `github/legal/consent.html`
- `github/legal/privacy.html`
- `README.md`
- `docs/deployment_and_github_pages.md`
- `scripts/qa_site.ps1`

## Files Changed

- `.github/workflows/deploy-pages.yml`
- `github/.nojekyll`
- `github/participant/index.html`
- `github/leader/index.html`
- `github/facilitator/index.html`
- `docs/deployment_and_github_pages.md`

## Workflow / Config Added Or Updated

- added `.github/workflows/deploy-pages.yml`
- workflow triggers on pushes to `main` when the `github/` mirror changes, or by manual dispatch
- workflow uploads the `github/` directory as the GitHub Pages artifact and deploys it with `actions/deploy-pages`
- added `github/.nojekyll` as a safe static-site publish marker

## Expected GitHub Pages Publish Path

- branch: `main`
- uploaded artifact path: `github/`
- deployment method: GitHub Actions Pages workflow

## Expected Public Base URL

- `https://ajpnkw.github.io/AI_Night_1st-Stanley-Park_Venture-Company/`

This base URL is inferred from the current repository owner and repository name, assuming no custom domain is added later.

## Public URL Map

- participant: `https://ajpnkw.github.io/AI_Night_1st-Stanley-Park_Venture-Company/participant/`
- parent / guardian: `https://ajpnkw.github.io/AI_Night_1st-Stanley-Park_Venture-Company/parent/`
- consent: `https://ajpnkw.github.io/AI_Night_1st-Stanley-Park_Venture-Company/legal/consent.html`
- privacy: `https://ajpnkw.github.io/AI_Night_1st-Stanley-Park_Venture-Company/legal/privacy.html`

## Leader / Facilitator Discovery Policy

- leader and facilitator pages remain functional at direct URLs
- they are intentionally not linked from the README
- they remain low-profile and unadvertised to the public audience

## Manual GitHub-Side Setting

- current blocker: GitHub API returned `422 Your current plan does not support GitHub Pages for this repository`
- if the repository is kept private, GitHub Pages must first be supported by the account plan
- if you switch the repository to public and GitHub Pages becomes available, set **Settings > Pages > Source** to **GitHub Actions** only if the automatic enablement step still has not completed it for you

## Readiness

- repo-side workflow is ready
- publish mirror structure is ready
- README policy is preserved
- 404 file remains in the publish mirror root
- live activation is blocked by current GitHub Pages availability for this repository


