# AI Workshop Codex Execution Standard

## Purpose

Prevent future root drift and mixed-authority edits when Codex continues work on this project.

## Execution Rules

1. Treat `AI_Workshop_4_ventures` as the workshop authority.
2. Keep workshop-specific docs and scripts inside the workshop root.
3. Treat `github\` as a static publish mirror only.
4. Use parent docs only for roll-up or boundary material.
5. Inventory local workshop sources before downloading anything new.
6. Prefer local cached references and existing workshop-pack artifacts.
7. Update in place and preserve useful files unless replacement is required.
8. Log workshop-local automation under the workshop root.

## Drift Prevention

Codex should reject any future change that tries to move workshop-local source material, reference catalogs, or learning-expansion assets into the parent root without an explicit parent-level roll-up purpose.
