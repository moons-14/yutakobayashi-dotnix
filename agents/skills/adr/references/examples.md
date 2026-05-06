# ADR Framing Examples

These are not copy-paste templates. Use them to choose the right decision shape.

## Architecture and boundaries

- "Adopt a modular monolith instead of splitting into services at the current scale."
- "Keep write ownership for billing data inside the billing service and expose read models to other domains."

## Dependencies and frameworks

- "Standardize on Drizzle for new database access and require explicit approval for any second ORM."
- "Use Vitest as the default test runner and treat Jest as legacy-only during migration."

## API and contract design

- "Publish external HTTP APIs as REST + OpenAPI and block undocumented contract changes."
- "Version domain events additively and prohibit breaking field removals without a migration plan."

## Security and data handling

- "Encrypt temporary files that contain personal data and delete them after processing completes."
- "Terminate invalid environment configuration at startup instead of allowing partial boot."

## Process and governance

- "Require an ADR before implementation for cross-team platform changes."
- "Route production schema changes through a migration review checklist owned by the platform team."

## Good framing prompts

- "Capture this as an ADR with explicit rejected alternatives."
- "Write a short ADR draft for this dependency decision."
- "Turn this architecture choice into an ADR and include rollout and exception handling."

## What good output looks like

- The decision is visible in the first screenful.
- The losing alternatives are present only if they help explain the choice.
- The consequences include real costs, not just benefits.
- Adoption is operationalized through reviews, CI, ownership, or runbooks.
