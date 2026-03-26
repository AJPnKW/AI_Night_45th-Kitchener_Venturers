# AI Workshop Parent Vs Workshop Boundary Model

## Correct Boundary

### Parent Project Root

`C:\Users\andrew\PROJECTS\Scouter_Jenn`

Use this for:

- git repo container
- shared project documentation
- reports
- logs
- parent-level scripts
- `github\` static publish mirror

Do not use it for:

- workshop-local downloaded references
- workshop-local learning expansion docs
- workshop-local packs
- workshop-local source validation artifacts

### Workshop Root

`C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures`

Use this for:

- downloaded sources
- reference catalog
- workshop scripts
- workshop packs
- canonical workshop website source

### Published Mirror

`C:\Users\andrew\PROJECTS\Scouter_Jenn\github`

Use this only for deployable static site output mirrored from approved workshop web content.

## Drift Correction

The parent project remains the git repository root, but the workshop root is the authoritative workshop workstream. The existence of `.git` at the parent level does not make the parent the workshop-content authority.
