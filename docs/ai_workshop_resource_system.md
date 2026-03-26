# AI Workshop Resource System

## Purpose

This parent-level document is the roll-up summary for the workshop resource system. The authoritative workshop resource workstream lives under:

- `C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures`

## Boundary Model

- Parent project root:
  - repo container
  - shared docs
  - reports
  - logs
  - deployment mirror support
- Workshop root:
  - downloaded sources
  - reference catalog
  - workshop scripts
  - workshop packs
  - canonical editable workshop website
- Published site root:
  - static deployable mirror only
  - no workshop pack logic, no source cache, no reference-catalog working files

## Authoritative Workshop Resource Locations

- Local references: `AI_Workshop_4_ventures\downloaded_sources`
- Resource catalog: `AI_Workshop_4_ventures\reference_catalog`
- Workshop automation: `AI_Workshop_4_ventures\scripts`
- Workshop pack artifacts: `AI_Workshop_4_ventures\workshop_pack`
- Canonical site content: `AI_Workshop_4_ventures\web`

## Parent-Level Role

The parent root should only carry workshop-related roll-up documentation, not the workshop-local source cache or planning corpus. This avoids repeating the earlier drift where parent-level structures were mistaken for the workshop authority.
