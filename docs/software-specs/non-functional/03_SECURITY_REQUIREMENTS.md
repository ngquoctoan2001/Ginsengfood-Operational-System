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
| SEC-RATE-001 | Public trace, login/admin command, PWA submit and integration callback endpoints must have mandatory abuse/rate-limit protection. | M02, M10, M12, M14, M16 | `/api/public/trace/{qrCode}`, `/api/admin/*` commands, `/api/supplier/*`, MISA/device callbacks | PF-02 default thresholds configurable per route family; absence of rate limiting blocks public/integration release. | P0 | TC-M12-PTRACE-RATE |
| SEC-DEVICE-001 | Device/printer callbacks must authenticate device identity and never bypass business approval. | M10, M15 | Device registry, print callback, heartbeat/error ingest | Unregistered/inactive device or invalid HMAC callback is rejected; callback cannot directly mark inventory, QC or release. | P0 | TC-M10-DEVICE-SEC |
| SEC-EVIDENCE-001 | Evidence upload must use allowlist MIME/size validation, storage adapter indirection and malware scan before the file can satisfy verify/close gates. | M05, M06, M13 | Source origin evidence, raw receipt evidence, CAPA evidence, storage adapter | Dev/test stores binary on local filesystem `DEV_TEST_ONLY`; production stores binary on company storage server by configuration; DB stores metadata only. `PENDING_SCAN`, `SCAN_FAILED` and `INFECTED` evidence cannot verify source origin, satisfy supplier receive policy or close CAPA/recall. | P0 | TC-NFR-SEC-EVIDENCE |

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
- Evidence uploads validate MIME/size, never accept binary inline into DB, and require clean malware scan before source verification or CAPA/recall close.
- Audit/state logs exist for approval, release, hold, recall, MISA retry/reconcile and override.
- Append-only tables cannot be edited through normal UI/API.

## 5. PF-02 Security Config Closure

| decision | PF-02 status |
|---|---|
| Auth session/token implementation detail | Stack-level detail remains implementation choice; security invariant unchanged: authenticated `/api/admin/*` and scoped `/api/supplier/*`, no production password/secret in seed. |
| Rate limit thresholds | RESOLVED_PF02 as configurable defaults: public trace 60/min/IP + 600/hour/IP; login/supplier login 10/min/IP; admin commands 120/min/user; PWA submit 300/min/device/user; MISA/device callbacks 600/min/source with signature required. |
| Secret manager/tooling | RESOLVED_PF02: real values live in environment/platform secret manager; repo stores only `*SecretRef`/config key names. |
| Security scan/SBOM process | Required before production release; tooling can be selected by DevOps without changing domain/API contracts. |
| Evidence scan engine | RESOLVED_PF02: scan provider is pluggable worker; production can use ClamAV/Defender/storage antivirus equivalent; scan retry records result and does not make infected evidence valid. |
| Device onboarding/credential rotation | RESOLVED_PF02: device registry + HMAC-SHA256 callback auth; `DeviceSecretRef` rotated by DevOps, physical model owned by Packaging Ops. |

PF-02 secret/config rule: production values for MISA, printer/device, evidence storage, DB/JWT/session and backup encryption must be references or environment-injected values. No literal secret, token, private key, endpoint credential or password hash seed intended for production may be committed.
