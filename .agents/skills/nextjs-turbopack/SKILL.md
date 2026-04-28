---
name: nextjs-turbopack
description: Next.js 16 App Router — Server Components, Client Components, data fetching, metadata/SEO, routing, Turbopack, and Docker deployment. Use for apps/website/ development.
origin: project
---

# Next.js 16 — App Router & Turbopack

## When to Use

- Writing or reviewing code in `apps/website/`
- Adding pages, layouts, route groups, or API routes
- Implementing data fetching, metadata/SEO, or image optimization
- Diagnosing slow dev startup, HMR, or production bundle issues
- Setting up or debugging Docker standalone builds

## How It Works

### Server vs Client Components

Next.js 16 App Router renders **Server Components by default**. This means:

- Zero JS sent to the browser for server-only components.
- Direct async data access in the component body (`await fetch(...)`, service calls).
- Add `"use client"` only when the component needs interactivity, `useState`, `useEffect`, or browser APIs.

```tsx
// Server Component — default, no directive
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params; // Next.js 15+ async params
  const product = await fetchProduct(id);
  return (
    <article>
      <h1>{product.name}</h1>
    </article>
  );
}

// Client Component — interactive leaf
("use client");
export function AddToCartButton({ id }: { id: string }) {
  const [busy, setBusy] = useState(false);
  return (
    <button onClick={() => setBusy(true)} disabled={busy}>
      Add to Cart
    </button>
  );
}
```

Keep Client Components as **leaves** — never wrap a Server Component inside a Client Component.

### Data Fetching Patterns

```tsx
// Static (CDN-cacheable)
fetch(url, { cache: "force-cache" });

// ISR — background revalidate every N seconds
fetch(url, { next: { revalidate: 3600 } });

// On-demand revalidation by tag
fetch(url, { next: { tags: ["products"] } });
revalidateTag("products"); // called from Server Action or Route Handler

// Dynamic — fresh on every request (opt-out of all caching)
fetch(url, { cache: "no-store" });

// Parallel fetches in Server Component
const [products, categories] = await Promise.all([
  fetchProducts(),
  fetchCategories(),
]);
```

### Routing Conventions

```
app/
├── layout.tsx           # Root layout (HTML shell, fonts, global providers)
├── page.tsx             # / (Home)
├── loading.tsx          # Suspense fallback — enables streaming
├── error.tsx            # Error boundary
├── not-found.tsx        # 404
├── (marketing)/         # Route group — shared layout, no URL impact
│   ├── about/page.tsx   # /about
│   └── layout.tsx
├── products/
│   ├── page.tsx         # /products
│   └── [id]/page.tsx    # /products/[id]
├── api/health/route.ts  # Route Handler — GET /api/health
├── sitemap.ts           # Dynamic sitemap
└── robots.ts            # robots.txt
```

### Metadata / SEO

```tsx
// Static
export const metadata: Metadata = {
  title: "Page Title",
  description: "...",
  openGraph: { images: [{ url: "/og.png", width: 1200, height: 630 }] },
};

// Dynamic (data-dependent)
export async function generateMetadata({ params }): Promise<Metadata> {
  const { id } = await params;
  const p = await fetchProduct(id);
  return { title: p.name };
}
```

Every `page.tsx` **must** export `metadata` or `generateMetadata`.

### Images and Links

```tsx
import Image from "next/image";
import Link from "next/link";

// Hero image (LCP candidate — use priority)
<Image src="/hero.webp" alt="..." width={1200} height={630} priority />

// Below fold
<Image src="/thumb.webp" alt="..." width={400} height={300} />

// Internal navigation
<Link href="/products">View Products</Link>
```

Never use raw `<img>` or `<a>` for internal content.

### Performance

- `output: "standalone"` in `next.config.ts` — required for Docker.
- Wrap slow components in `<Suspense>` for streaming.
- Lazy-load heavy client-only packages: `dynamic(() => import("./Heavy"), { ssr: false })`.
- Analyze with `@next/bundle-analyzer` before release.
- Core Web Vitals targets: LCP < 2.5s, INP < 200ms, CLS < 0.1.

### Turbopack (Dev)

- `next dev` uses Turbopack by default in Next.js 16 — no flag needed.
- Cache under `.next/cache` — do not delete unless debugging a corrupted cache.
- `next build` uses Webpack (stable). Turbopack production build is experimental and opt-in.
- If dev is slow: confirm Turbopack is active (`turbopack` appears in terminal), check for excessively large watched directories.

### Docker Standalone Build

```typescript
// next.config.ts
const config: NextConfig = {
  output: "standalone",
  reactStrictMode: true,
  images: {
    formats: ["image/avif", "image/webp"],
  },
};
```

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system nodejs && adduser --system nextjs
COPY --from=build --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=build --chown=nextjs:nodejs /app/public ./public
USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
```

## Examples

### Route Handler with validation

```tsx
// app/api/contact/route.ts
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";

const schema = z.object({
  email: z.string().email(),
  message: z.string().min(1),
});

export async function POST(request: NextRequest) {
  const body = await request.json();
  const result = schema.safeParse(body);
  if (!result.success) {
    return NextResponse.json(
      { error: result.error.flatten() },
      { status: 400 },
    );
  }
  // ... handle valid data
  return NextResponse.json({ ok: true }, { status: 201 });
}
```

### Streaming with Suspense

```tsx
// page.tsx
import { Suspense } from "react";
import { ProductList } from "./ProductList";

export default function Page() {
  return (
    <main>
      <h1>Products</h1>
      <Suspense fallback={<p>Loading products…</p>}>
        <ProductList /> {/* async Server Component */}
      </Suspense>
    </main>
  );
}
```

## Best Practices

- Default to Server Components; move to Client only for interactivity.
- Fetch data in the component that needs it — avoid prop drilling fetch results.
- Use `revalidateTag` for on-demand ISR instead of maxing out `revalidate: 0`.
- Export `metadata` on every page — required for SEO.
- Run `npm run build` before every Docker image build.
- Use `strict: true` in `tsconfig.json` — no `any`.

## When to Use

- **Turbopack (default dev)**: Use for day-to-day development. Faster cold start and HMR, especially in large apps.
- **Webpack (legacy dev)**: Use only if you hit a Turbopack bug or rely on a webpack-only plugin in dev. Disable with `--webpack` (or `--no-turbopack` depending on your Next.js version; check the docs for your release).
- **Production**: Production build behavior (`next build`) may use Turbopack or webpack depending on Next.js version; check the official Next.js docs for your version.

Use when: developing or debugging Next.js 16+ apps, diagnosing slow dev startup or HMR, or optimizing production bundles.

## How It Works

- **Turbopack**: Incremental bundler for Next.js dev. Uses file-system caching so restarts are much faster (e.g. 5–14x on large projects).
- **Default in dev**: From Next.js 16, `next dev` runs with Turbopack unless disabled.
- **File-system caching**: Restarts reuse previous work; cache is typically under `.next`; no extra config needed for basic use.
- **Bundle Analyzer (Next.js 16.1+)**: Experimental Bundle Analyzer to inspect output and find heavy dependencies; enable via config or experimental flag (see Next.js docs for your version).

## Examples

### Commands

```bash
next dev
next build
next start
```

### Usage

Run `next dev` for local development with Turbopack. Use the Bundle Analyzer (see Next.js docs) to optimize code-splitting and trim large dependencies. Prefer App Router and server components where possible.

## Best Practices

- Stay on a recent Next.js 16.x for stable Turbopack and caching behavior.
- If dev is slow, ensure you're on Turbopack (default) and that the cache isn't being cleared unnecessarily.
- For production bundle size issues, use the official Next.js bundle analysis tooling for your version.
