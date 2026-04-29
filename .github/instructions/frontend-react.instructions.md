---
description: "Use when writing, editing, or reviewing React / TypeScript frontend code after the admin frontend scaffold exists."
applyTo: "**/*.{ts,tsx}"
---

# Frontend React / TypeScript Guidelines

## Response Language

Respond in Vietnamese for explanations, plans, reviews, and validation notes. Keep React/TypeScript terms, component/hook names, file paths, route paths, commands, package names, JSON keys, and exact errors in English.

## Greenfield Note

The admin frontend may not exist yet. If frontend code is absent, first follow the active scaffold phase and `docs/software-specs/` before assuming `apps/admin-web`, router type, package scripts, or generated client paths.

## Target Patterns

Use the frontend stack and folder structure selected by the active scaffold phase. Expected patterns may include:

- route-level pages;
- feature folders;
- API query/mutation hooks;
- schema-driven forms;
- shared UI primitives;
- generated API clients.

## Data Fetching

- Do not fetch data directly inside complex components.
- Put server-state access behind feature-level hooks.
- Mutations must invalidate or update relevant query cache on success.
- Keep query keys stable and typed.

## Dev Server Process Cleanup

Prefer finite commands such as typecheck, build, and test. If an agent must start `npm run dev`, Vite, Next, or Playwright web server, record the PID or start it with `tools/agent/Start-AgentOwnedProcess.ps1`, then stop it before final response with `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`. Never kill every `node` or `npm` process by name.

## Forms

- Derive TypeScript types from validation schemas where practical.
- Put form schemas near the feature that owns the form.
- Always handle required/optional fields according to the API contract.
- Avoid uncontrolled inputs for complex forms.

## API Client Usage

Use the generated or shared API client selected by the scaffold phase. Do not scatter raw HTTP calls across components.

After backend contract changes, regenerate/update frontend API types when frontend exists. If frontend is not scaffolded yet, document intended future consumers.

## Route Structure

- Keep route files predictable and feature-oriented.
- Use route loaders only for critical data needed before render.
- Always handle loading, error, empty, and permission-denied states.

## Immutability Rules

Do not mutate arrays or objects in-place in React state.

## Naming Conventions

- Components: `PascalCase`.
- Hooks: `use<Resource><Action>`.
- Route folders: stable and human-readable.
- Schemas: `<resource>FormSchema`, `<resource>FilterSchema`.

## Type Safety

- Avoid `any`.
- Use `unknown` plus type guards when shape is genuinely unknown.
- Avoid unsafe casts unless the shape has been verified.
- Do not duplicate API response types when generated/shared types exist.

## Accessibility

- Interactive elements must be keyboard navigable.
- Form inputs must have associated labels or `aria-label`.
- Use semantic HTML.
- Do not rely on color alone to convey meaning.
