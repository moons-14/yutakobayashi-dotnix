# Dependency Choices

Use this file when the user asks about package selection, modernization, dependency cleanup, or “what should we stop using by default?”.

This is a preference guide, not a literal npm deprecation list. Several packages here are still maintained. The point is to prefer standard APIs, open-code UI patterns, or lighter modern tooling when they fit the project.

## Preferred replacements

| Avoid by default          | Prefer                                       | Why                                                                                                                                                                   |
| ------------------------- | -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `dayjs`                   | `Temporal` / polyfill first, then `date-fns` | Prefer the emerging standard date/time model first; if that is not practical, prefer pure modular utilities with strong TypeScript support.                           |
| `axios`                   | `fetch`                                      | Prefer the platform standard when browser and Node already provide it. Fewer dependencies and less wrapper code.                                                      |
| `@chakra-ui/react`        | `shadcn/ui`                                  | Prefer open-code components you own and edit directly instead of a large packaged component library by default.                                                       |
| `lodash`                  | `es-toolkit` or remove entirely              | Prefer native JS first; if helpers are still needed, prefer a modern utility library with smaller footprint and a Lodash compatibility path.                          |
| `remark` / `remark-parse` | `micromark`                                  | If the task is mainly markdown parsing/rendering rather than AST transforms, prefer the lower-level parser the unified ecosystem itself recommends for that use case. |

## Guidance by package

## `dayjs` -> `Temporal` / polyfill first, then `date-fns`

Prefer checking whether `Temporal` can solve the problem first.

If the runtime does not provide `Temporal` yet, consider a supported polyfill path. If `Temporal` is still not practical for the project, prefer `date-fns` for new code.

What matters:

- `Temporal` is the TC39 date/time direction and already at Stage 3
- there is an official polyfill ecosystem around it
- modular function-based API
- pure and immutable operations
- native `Date` usage instead of wrapper instances
- modern TypeScript support
- first-class time zone support in v4

Suggested order:

1. native `Temporal` if the target runtime supports it
2. `@js-temporal/polyfill` or another appropriate Temporal polyfill if the project benefits from the Temporal model
3. `date-fns` if the team wants simpler incremental adoption or function-style helpers around `Date`

This is not because `dayjs` is formally deprecated. It is a project preference toward the standard Temporal model first, and then function-based date utilities with strong tree-shaking and timezone support.

## `axios` -> `fetch`

Prefer `fetch` unless the project has a concrete need for Axios-specific features.

Default reasons:

- Node now ships a stable, browser-compatible global `fetch`
- browsers already provide `fetch`
- fewer dependencies and fewer adapter choices
- shared mental model across frontend, backend, tests, and Route Handlers

Axios is still reasonable if the repo truly depends on its interceptors, request/response transforms, or existing instance/middleware architecture. But the burden of proof should be on keeping it, not adding it.

## `@chakra-ui/react` -> `shadcn/ui`

Prefer `shadcn/ui` for new app-level UI work when the team wants component ownership and easy customization.

What matters:

- `shadcn/ui` is explicitly “not a component library”; it is a code distribution approach
- the component code is open and intended to be modified directly
- this reduces wrapper layers and design-system lock-in
- it tends to work better with local customization and AI/codegen workflows

Chakra UI is still actively maintained and not “bad”. This preference is about owning the UI code by default, not about Chakra being obsolete.

## `lodash` -> `es-toolkit` or remove

Prefer removing the helper entirely if modern JavaScript already covers the need.

If a utility library is still justified, prefer `es-toolkit`.

What matters:

- `es-toolkit` positions itself as a seamless Lodash replacement
- it documents smaller bundle size
- it documents modern implementation and strong types

For small one-off helpers, prefer no dependency at all.

## `remark` / `remark-parse` -> `micromark`

Use `remark` when the project actually needs unified plugins and markdown AST transforms.

Use `micromark` when the main job is parsing markdown or turning markdown into HTML.

What matters:

- unified’s own `remark-parse` docs say to prefer `micromark` when you just want HTML
- `micromark` is the lower-level parser underneath much of the ecosystem
- it is smaller and closer to the parsing problem itself

So the rule is:

- parsing/rendering focused work: `micromark`
- plugin/AST transformation workflows: `remark`

## How to review a repo

When reviewing dependencies, classify each one like this:

- `Keep`: there is a clear reason and the project is already shaped around it
- `Avoid in new code`: existing use can remain, but do not spread it further
- `Replace`: the project should actively migrate away

Do not recommend churn just for ideology. Prefer replacements when at least one of these is true:

- the platform now provides the capability
- the replacement reduces dependency surface significantly
- the replacement improves code ownership and customization
- the replacement matches the actual use case more directly

## Source notes

These preferences are based on a mix of official package documentation and ecosystem inference.

- `fetch`: Node.js documents `fetch` as a stable, browser-compatible global.
- `axios`: Axios documents itself as a separate HTTP client with its own API/features, which is why it should only be kept when those features are actually needed.
- `Temporal`: TC39 documents Temporal as the standard direction for working with dates and times, and the official ecosystem points to production polyfills.
- `date-fns`: the project documents modularity, pure functions, TypeScript support, and first-class time zone support.
- `es-toolkit`: the project documents smaller bundle size, Lodash compatibility, modern implementation, and strong types.
- `shadcn/ui`: the project explicitly describes itself as open code rather than a traditional component library.
- `remark-parse`: unified explicitly recommends `micromark` when the goal is turning markdown into HTML rather than plugin-driven transforms.

## Primary sources

- Node.js globals / `fetch`: https://nodejs.org/api/globals.html
- Temporal proposal: https://github.com/tc39/proposal-temporal
- Temporal polyfill: https://github.com/js-temporal/temporal-polyfill
- Axios docs: https://axios-http.com/docs/intro
- date-fns: https://github.com/date-fns/date-fns
- es-toolkit: https://es-toolkit.dev/
- shadcn/ui: https://ui.shadcn.com/docs
- Chakra UI: https://chakra-ui.com/docs/components/concepts/overview
- remark-parse: https://unifiedjs.com/explore/package/remark-parse/
- micromark: https://unifiedjs.com/explore/package/micromark/
