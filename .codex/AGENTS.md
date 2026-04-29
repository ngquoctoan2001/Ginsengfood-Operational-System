# .codex/AGENTS.md - Codex local supplement

This file applies only when Codex works inside `.codex/`.

The repository root `AGENTS.md` remains the primary project instruction file.

## Ngôn ngữ phản hồi / Response Language

**Tất cả phản hồi phải viết bằng tiếng Việt** — bao gồm kế hoạch, tiến độ, kết quả review, validation, handoff, blocker, rủi ro và báo cáo cuối.

Giữ nguyên tiếng Anh cho các thành phần kỹ thuật cụ thể:

- code identifier, class name, function name, variable name;
- file path, folder path, route path, API method, DTO/table/column/enum name;
- command line, package name, migration name, branch name, commit message;
- JSON/YAML/TOML key, HTTP status code, framework/library/tool name;
- nội dung log/error gốc và code fence.

Không dịch code fence, câu lệnh, schema name, route name, hoặc error message. Giải thích bằng tiếng Việt xung quanh thuật ngữ gốc khi cần.

## Local Codex Assets

- `.codex/config.toml`
  - Sets GPT-5.5, xhigh reasoning, VS Code file opener, sandbox/approval behavior, web search, GitNexus MCP, and multi-agent runtime.
- `.codex/agents/*.toml`
  - Custom subagents for greenfield source mapping, scaffold planning, implementation, testing, and review.
- `.agents/skills/ginsengfood-greenfield-build/SKILL.md`
  - Reusable workflow for building Ginsengfood Operational from `docs/software-specs/`.

## Current Repository State

This repo is greenfield. Application code is not scaffolded yet.

Do not require current-code route mapping, migration-delta audit, seed-delta audit, or GitNexus graph exploration before the initial scaffold exists. For initial work, map canonical requirements to intended files and modules, then create the first implementation in bounded phases.

After code exists, use normal impact mapping and GitNexus before broad repository exploration.

## Skill Routing

`ginsengfood-greenfield-build` is the primary skill for Ginsengfood V2 greenfield work.

Codex may also use companion skills when the current bounded task crosses a specialized area:

- Use `api-design` for API route shape, request/response DTO, envelope, pagination, error response, OpenAPI, or FE/BE contract sync.
- Use `backend-patterns` for .NET domain model, EF Core entity/configuration, repository, service, command handler, transaction boundary, outbox, or background worker.
- Use `frontend-patterns` for admin web API clients, hooks, forms, tables, page state, filters, pagination, or UI validation.
- Use `nextjs-turbopack` for `apps/website/` when the website is scaffolded.
- Use `security-review` for authentication, authorization, public trace, internal trace, token/session/cookie/CORS/CSRF, or sensitive field exposure.
- Use `e2e-testing` for workflow smoke tests, end-to-end validation, or cross-layer regression tests.
- Use `tdd-workflow` when writing tests first on new features or bug fixes.
- Use `verification-loop` for build/test/fix loops and repeated validation.
- Use `documentation-lookup` when official framework/package documentation is required.

Do not load unrelated skills. Prefer one primary skill plus one or two companion skills.

## Agent Loading

Custom agent files must define:

- `name`
- `description`
- `developer_instructions`

Do not place full project instructions inside each subagent. Keep durable project rules in the root `AGENTS.md` and canonical specs.

## GitNexus Usage

GitNexus is optional until application code exists and an index can provide useful graph evidence.

Example commands after scaffold:

```powershell
gitnexus query --repo ginsengfood-operational-system "<workflow or concept>"
gitnexus context --repo ginsengfood-operational-system "<symbol>"
gitnexus impact --repo ginsengfood-operational-system "<symbol or file>"
```
