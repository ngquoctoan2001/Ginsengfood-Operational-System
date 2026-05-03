# Deployment Guidelines

> Covers Docker builds, health checks, environment config, and CI/CD conventions.
> Applies to: `apps/api/` (.NET 10), `apps/admin-web/` (React + Vite), `apps/public-trace/` (Next.js 16), `apps/shopfloor-pwa/` (Next.js 16 PWA), background workers, PostgreSQL 18.

## Deployment Targets

| App                   | Technology              | Container base                         |
| --------------------- | ----------------------- | -------------------------------------- |
| `apps/api/`           | .NET 10 / ASP.NET Core  | `mcr.microsoft.com/dotnet/aspnet:10.0` |
| `apps/workers/`       | .NET 10 Worker Service  | `mcr.microsoft.com/dotnet/aspnet:10.0` |
| `apps/admin-web/`     | React + Vite (SPA)      | `nginx:alpine`                         |
| `apps/public-trace/`  | Next.js 16 (standalone) | `node:20-alpine`                       |
| `apps/shopfloor-pwa/` | Next.js 16 PWA          | `node:20-alpine`                       |
| Database              | PostgreSQL 18           | `postgres:18-alpine`                   |

> Lưu ý: canonical spec `docs/software-specs/architecture/07_DEPLOYMENT_VIEW.md` liệt kê 3 frontend app (`admin-web`, `public-trace`, `shopfloor-pwa`) plus API/backend and workers. Toolchain rule này chỉ phản ánh top-level container topology; chi tiết build/runtime cho `public-trace` và `shopfloor-pwa` follow Next.js 16 standalone sections bên dưới.

## .NET Backend — Multi-stage Dockerfile

```dockerfile
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY *.slnx .
COPY src/ src/
RUN dotnet restore
RUN dotnet publish src/Api/Ginsengfood.Operational.Api \
    -c Release -o /app/publish --no-restore /p:UseAppHost=false

# Stage 2: Runtime (non-root)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
RUN addgroup --system appgroup && adduser --system appuser --ingroup appgroup
USER appuser
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "Ginsengfood.Operational.Api.dll"]
```

### Rules

- Always use multi-stage builds — do not ship the SDK in the runtime image.
- Always run as a non-root user.
- Use `.dockerignore` to exclude `bin/`, `obj/`, `.env*`, `*.user`, `*.suo`.
- `ASPNETCORE_URLS=http://+:8080` — do not bind to port 443 inside the container (terminate TLS at the load balancer).

## Health Checks (Mandatory)

Every API **must** expose health endpoints:

```csharp
// In Program.cs
builder.Services.AddHealthChecks()
    .AddNpgsql(connectionString, tags: ["ready"])
    .AddCheck("self", () => HealthCheckResult.Healthy(), tags: ["live"]);

app.MapHealthChecks("/health/live",  new HealthCheckOptions { Predicate = c => c.Tags.Contains("live") });
app.MapHealthChecks("/health/ready", new HealthCheckOptions { Predicate = c => c.Tags.Contains("ready") });
```

In `docker-compose.yml`:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health/live"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 15s
```

## React SPA (admin-web) — Dockerfile

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
RUN npm run build

FROM nginx:alpine AS runtime
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

`nginx.conf` must include `try_files $uri /index.html;` for SPA routing.

## Next.js 16 — Standalone Dockerfile

```dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
RUN addgroup --system nodejs && adduser --system nextjs
COPY --from=build --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nextjs:nodejs /app/public ./public
USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
```

Requires `output: "standalone"` in `next.config.ts`.

## docker-compose.yml (Local Dev)

```yaml
version: "3.9"
services:
  db:
    image: postgres:18-alpine
    environment:
      POSTGRES_DB: ginsengfood_dev
      POSTGRES_USER: app
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?set-in-local-env}
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app -d ginsengfood_dev"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    build:
      context: ./apps/api
    environment:
      ConnectionStrings__DefaultConnection: "Host=db;Database=ginsengfood_dev;Username=app;Password=${POSTGRES_PASSWORD:?set-in-local-env}"
      ASPNETCORE_ENVIRONMENT: Development
      ASPNETCORE_URLS: "http://+:8080"
    ports:
      - "5000:8080"
    depends_on:
      db:
        condition: service_healthy

  admin-web:
    build:
      context: ./apps/admin-web
      args:
        VITE_API_BASE_URL: http://localhost:5000
    ports:
      - "4173:80"
    depends_on:
      - api

volumes:
  pgdata:
```

## Environment Variables

### Mandatory Rules

- **Never** hardcode secrets, connection strings, or API keys in Dockerfiles, source code, or docker-compose.
- Local dev: `.env.local` (gitignored). CI: injected as GitHub Secrets / pipeline vars.
- Production: mount as secrets, inject as environment variables, or use a secret manager (Azure Key Vault, AWS Secrets Manager, HashiCorp Vault).

### Backend Required Variables

```
ConnectionStrings__DefaultConnection=...
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:8080
JWT__SecretKey=...
JWT__Issuer=...
JWT__Audience=...
```

### PF-02 Production Config Refs

```
MisaSyncOptions__Mode=Production
MisaSyncOptions__BaseUrl=...
MisaSyncOptions__TenantId=...
MisaSyncOptions__ClientId=...
MisaSyncOptions__ClientSecretRef=...
MisaSyncOptions__WebhookSecretRef=...

PrinterOptions__Protocol=HTTP_ZPL
PrinterOptions__CallbackAuth=HMAC_SHA256
PrinterOptions__DeviceSecretRef=...

EvidenceStorage__Provider=COMPANY_SERVER
EvidenceStorage__BasePathOrBucket=...
EvidenceStorage__EncryptionKeyRef=...
EvidenceStorage__AccessLogSinkRef=...

BackupOptions__DatabaseRpoMinutes=15
BackupOptions__DatabaseRtoHours=4
BackupOptions__EvidenceRpoMinutes=60
BackupOptions__EvidenceRtoHours=8
```

These are refs/config keys, not literal secret values. Local/dev may use `DEV_TEST_ONLY` fixture values and local filesystem storage; production must use platform secret injection or an approved secret manager.

### Frontend Required Variables

```
# admin-web (build-time)
VITE_API_BASE_URL=https://api.example.com

# public-trace (Next.js — runtime)
NEXT_PUBLIC_TRACE_API_URL=https://api.example.com

# shopfloor-pwa (Next.js — runtime)
NEXT_PUBLIC_API_URL=https://api.example.com
```

## CI/CD Rules

- Build Docker images in CI — never push pre-built local images.
- Run `dotnet test` **before** building the API image.
- Run `npm run build` + `npx tsc -b --noEmit` **before** building frontend images.
- Tag every image with the git commit SHA: `image:$GITHUB_SHA`
- Use health check `condition: service_healthy` in `depends_on`.
- Pull request builds: build but do not push. Only merge into main triggers push.

## Security Checklist

- [ ] Non-root user in all Dockerfiles
- [ ] No secrets in Dockerfiles or `docker-compose.yml` (use `.env` locally, platform secrets in CI)
- [ ] PF-02 refs configured for MISA, printer/device, evidence storage, backup/DR, notification outbox consumer, and production user assignment source
- [ ] Dev/test fixtures are marked `DEV_TEST_ONLY` and blocked from production print/sync paths
- [ ] TLS terminated at load balancer / reverse proxy — not inside containers
- [ ] Health check endpoints exposed and tested
- [ ] `.dockerignore` in every app directory
- [ ] `output: "standalone"` in `next.config.ts` for Next.js Docker builds
- [ ] Database credentials rotated after any accidental exposure
