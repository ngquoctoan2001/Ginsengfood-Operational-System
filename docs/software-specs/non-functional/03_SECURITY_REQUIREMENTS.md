# 03 - Security Requirements

## 1. Mục tiêu

Định nghĩa yêu cầu bảo mật cho authentication, authorization, public/private data boundary, secret handling, destructive operations, input validation, dependency risk và privacy.

## 2. Security Requirement Matrix

| security_id | requirement | module | affected API/UI/data | validation | priority | test case |
|---|---|---|---|---|---|---|
| SEC-AUTHN-001 | Admin/internal API requires authenticated user/session/token. | M02 | All `/api/admin/*`, admin UI | Unauthenticated returns `401`; no side effect. | P0 | TC-NFR-SEC-003 |
| SEC-AUTHZ-001 | Sensitive actions require backend permission/action check. | M02 | Protected endpoints, action buttons | User without action receives `403`; UI hidden/disabled does not replace backend check. | P0 | TC-M02-PERM-002 |
| SEC-APPROVAL-001 | Approval/reject/release/override actions require actor, reason where applicable and audit. | M01, M02, M09, M13 | Approval Queue, release, hold, recall | Reject without reason fails; audit/action rows exist. | P0 | TC-M02-APP-003 |
| SEC-PUBLIC-001 | Public trace must use whitelist response policy. | M12 | `/api/public/trace/{qrCode}`, Public Trace UI | No supplier/personnel/cost/QC defect/loss/MISA/private field in response/UI. | P0 | TC-M12-PTRACE-002 |
| SEC-QR-001 | QR `VOID`/`FAILED` must not resolve as valid public trace. | M10, M12 | QR registry, public trace | Public-safe invalid/not found response; no internal reason leak. | P0 | TC-M12-PTRACE-003 |
| SEC-SECRET-001 | Secrets must not be committed or seeded as literal values. | M14, M15 | MISA, DB, JWT/session, printer/device token | Config references only; real values in secret manager/environment. | P0 | TC-NFR-SEC-003 |
| SEC-INPUT-001 | All external/admin inputs must be validated at API boundary and domain layer. | All | API forms, public QR, MISA callbacks | Invalid enum, state, quantity, idempotency conflict and forbidden fields reject cleanly; issue when lot is not `READY_FOR_PRODUCTION` and warehouse receipt when batch is not `RELEASED` are explicit negative tests. | P0 | API negative tests |
| SEC-DESTRUCT-001 | Destructive/correction actions require permission, reason, audit and must not mutate append-only history. | M01, M11, M13 | Adjustment, correction, recall, override | Direct update/delete blocked; correction/reversal used. | P0 | TC-M11-INV-002 |
| SEC-MISA-001 | Business modules must not call MISA directly. | M14, M01 | Outbox, MISA sync | Events go through integration layer; missing mapping becomes review/reconcile pending. | P0 | TC-M14-MISA-001, TC-M14-MISA-002 |
| SEC-BREAKGLASS-001 | Break-glass override is a time-bound security control, not a permanent permission. | M01, M02, M15 | Override console, high-risk command middleware | Level 3 break-glass requires reason, scope, dual approval, expiry timestamp <= 15 minutes and append-only audit; expired override cannot be used. | P0 | TC-APP-OVR-001 |
| SEC-GTIN-001 | Commercial barcode integrity must enforce GTIN/trade item uniqueness. | M10 | Trade item config, print payload, packaging UI | One active commercial barcode/GTIN per trade item/package level; no fallback to SKU code or user-entered second barcode. | P0 | TC-M10-GTIN-002 |
| SEC-RATE-001 | Public trace endpoint must have mandatory abuse/rate-limit protection. | M12 | `/api/public/trace/{qrCode}` | Exact threshold is owner decision, but absence of rate limiting blocks public release. | P0 | TC-M12-PTRACE-RATE |
| SEC-DEVICE-001 | Device/printer callbacks must authenticate device identity and never bypass business approval. | M10, M15 | Device registry, print callback, heartbeat/error ingest | Unregistered/inactive device or invalid token is rejected; callback cannot directly mark inventory, QC or release. | P0 | TC-M10-DEVICE-SEC |

## 3. Public/Internal Field Policy

| field class | Public trace | Admin/internal |
|---|---|---|
| SKU public name/status | Allowed if policy permits | Allowed |
| Batch public code/status | Allowed if policy permits | Allowed |
| Source summary/public origin fields | Allowed if policy permits | Allowed |
| Supplier internal code/name | Denied | Allowed by permission |
| Personnel/operator/approver | Denied | Allowed by permission/audit |
| Cost/cost variance/loss | Denied | Allowed by finance/admin permission if implemented |
| QC defect detail | Denied | Allowed by QA permission |
| MISA mapping/log/status | Denied | Allowed by integration/admin permission |
| Private note/internal id/debug payload | Denied | Allowed only if role and purpose allow |

## 4. Security Review Checklist

- Admin endpoints enforce authentication.
- Sensitive endpoints enforce backend permission.
- Public trace uses dedicated DTO/API, not admin trace DTO.
- Secret values are not committed, logged, seeded or returned by API.
- Input validation rejects invalid state transition, invalid enum, negative quantity, missing reason and conflicting idempotency key.
- Break-glass has scoped dual approval, expiry <= 15 minutes and audit.
- Public trace has rate limiting before public release.
- GTIN/trade item uniqueness is enforced before commercial print.
- Device/printer callbacks require registered device credentials and cannot bypass service validation.
- Audit/state logs exist for approval, release, hold, recall, MISA retry/reconcile and override.
- Append-only tables cannot be edited through normal UI/API.

## 5. Owner Decisions

| decision | Needed for |
|---|---|
| Auth session/token implementation detail | Exact token/cookie/SSO strategy if current stack is not fixed |
| Rate limit thresholds | Exact thresholds for public trace, admin command, login, MISA callback; rate limiting itself is mandatory |
| Secret manager/tooling | Production secret storage and rotation |
| Security scan/SBOM process | Dependency and CVE governance |
| Device onboarding/credential rotation | Printer/device registration, token rotation and callback trust boundary |
