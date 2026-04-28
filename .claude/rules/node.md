# Frontend & npm Tooling

> Applies to `apps/admin-web/` (React + Vite) and `apps/website/` (Next.js 16).
> Replaces ECC-specific Node.js rules that do not apply to this project.

## Package Management

- Use `npm` consistently across all frontend apps — do not mix `yarn` or `pnpm`.
- Commit `package-lock.json`. Use `npm ci` in CI, not `npm install`.
- Keep `package.json` scripts aligned with CI tasks and completion gate commands.

## admin-web Scripts (React + Vite)

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `npm run dev` | Local dev server (Vite) | Development only |
| `npm run build` | Production build | CI Gate 3 |
| `npm run gen:api` | Regenerate OpenAPI client | After backend contract change |
| `npx tsc -b --noEmit` | Type-check without emit | CI Gate 3 |
| `npm run lint` | ESLint check | Before commit |
| `npm run e2e:smoke` | Playwright smoke tests | CI Gate 7 |

## website Scripts (Next.js 16)

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `npm run dev` | Local dev (Turbopack) | Development only |
| `npm run build` | Production build | CI + deployment |
| `npm run start` | Start production build locally | Local validation |
| `npm run lint` | Next.js ESLint | Before commit |

## Environment Variables

- Local: `.env.local` (gitignored). Production: injected by environment or secret manager.
- Never commit `.env` files containing real credentials.
- Validate required env vars at app startup — fail fast with a clear error.
- Backend URL in frontend: `VITE_API_BASE_URL` (admin-web) / `NEXT_PUBLIC_API_URL` (website).

## TypeScript Requirements

- `strict: true` is required in all `tsconfig.json`.
- No `any` — use `unknown` for external input and narrow it.
- All exported functions must have explicit parameter and return types.
- Run `npx tsc -b --noEmit` before every commit on the frontend apps.

## Agent Process Lifecycle

- Prefer finite commands: `npm run build`, `npx tsc -b --noEmit` over long-lived dev servers.
- If a dev server must be started, record PID with `tools/agent/Start-AgentOwnedProcess.ps1`.
- Stop before final response: `tools/agent/Stop-AgentOwnedProcesses.ps1 -IncludeDescendants`.
- Never kill all `node` or `npm` processes by name — user terminals may be running the same binaries.
