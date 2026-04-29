---
description: "Use when writing, editing, or reviewing Next.js website code after the website scaffold exists."
applyTo: "**/*.{ts,tsx,js}"
---

# Next.js Guidelines

## Response Language

Respond in Vietnamese for explanations, plans, reviews, and validation notes. Keep Next.js/React terms, route paths, component names, file paths, commands, package names, env keys, and exact errors in English.

## Greenfield Note

The website may not exist yet. If website code is absent, first follow the active scaffold phase and `docs/software-specs/` before assuming `apps/website`, package scripts, or routing structure.

## Default Architecture

- Prefer App Router and Server Components unless the accepted scaffold phase chooses otherwise.
- Add `"use client"` only for browser APIs, state, effects, or event handlers.
- Keep Client Components at leaves of the tree.
- Do not put operational business truth in the public website.

## Public Trace Boundary

Public pages and route handlers must follow canonical public trace field policy. Never expose internal supplier, personnel, costing, QC defect/loss, MISA, private customer, or internal recall fields.

## Data Fetching

- Prefer server-side fetching for public pages.
- Avoid client-side `useEffect` fetching when server rendering is practical.
- Use stable cache/revalidation choices appropriate to the data sensitivity.
- Do not hardcode API URLs; use configured environment variables.

## Route Handlers

Use Route Handlers only for public APIs, webhooks, or server-side form submissions. Validate all input and return structured JSON/error responses.

## Metadata and SEO

- Every public page should define metadata when website scaffold exists.
- Use sitemap/robots support where required by the phase.
- Provide useful image `alt` text.

## Performance

- Use optimized image and link components when available.
- Keep Core Web Vitals in mind.
- Avoid shipping large client bundles for static public content.

## Validation

Run typecheck/build/tests when website scaffold exists and changed. If not scaffolded, report `N/A - not scaffolded yet`.
