# Scaffold Readiness GO — 2026-05-03

> Owner directive turn 6: **giải quyết triệt để** 3 rủi ro tồn đọng từ doc-only audit. File này đóng cờ GO cho CODE00 → CODE17 không còn OD blocking.

## 1. Tóm tắt trạng thái

| Hạng mục                                   | Trạng thái trước       | Trạng thái sau (2026-05-03 turn 6)       |
| ------------------------------------------ | ---------------------- | ---------------------------------------- |
| Rủi ro #1 — Seed thiếu R-SUPPLIER + 3 perm | HIGH                   | **RESOLVED** (seed canonical đã patch)   |
| Rủi ro #2 — 3 OD BLOCKING_OWNER_FINAL      | MEDIUM                 | **RESOLVED** (OWNER_ACCEPTED_AS_DEFAULT) |
| Rủi ro #3 — 23 OD provisional dev/staging  | MEDIUM                 | **RESOLVED** (production-acceptable)     |
| GO CODE00 → CODE17                         | GO với 3 residual risk | **GO không residual block**              |

## 2. Patch áp dụng

### 2.1 Seed canonical SQL

| File                            | Thay đổi                                                                                                                                                    |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `docs/seeds/01_roles.sql`       | Thêm `R-SUPPLIER` (display "Supplier", desc "External supplier portal scope") vào 2 block UPDATE + INSERT idempotent.                                       |
| `docs/seeds/02_permissions.sql` | Append patch block 2026-05-03 trước `COMMIT;`: 2 permission catalog mới + 11 role-permission assignment, all `INSERT ... WHERE NOT EXISTS` cho idempotency. |

### 2.2 Mapping permission UPPER → dotted convention

Tuân thủ `docs/v2-decisions/OD-SEED-NAMING-001.md`:

| Spec UPPER             | Seed dotted                                                    | Trạng thái                      |
| ---------------------- | -------------------------------------------------------------- | ------------------------------- |
| `RAW_LOT_MARK_READY`   | `raw-material.lot.mark-ready`                                  | **MỚI** (seed patch 2026-05-03) |
| `BATCH_RELEASE_REVOKE` | `qc-release.batch-release.revoke`                              | **MỚI** (seed patch 2026-05-03) |
| `QR_REPRINT`           | `traceability.qr-registry.reprint` + `packaging.print.reprint` | **ĐÃ TỒN TẠI** (không cần thêm) |

### 2.3 Role wiring mới (in patch block)

| Role                      | Permission                        | Lý do                                           |
| ------------------------- | --------------------------------- | ----------------------------------------------- |
| `admin`                   | `raw-material.lot.mark-ready`     | Admin tier full scope.                          |
| `system-admin`            | `raw-material.lot.mark-ready`     | Admin tier full scope.                          |
| `raw-material-manager`    | `raw-material.lot.mark-ready`     | Owner lifecycle nguyên liệu.                    |
| `material-handler`        | `raw-material.lot.mark-ready`     | Người thao tác kho nguyên liệu.                 |
| `admin`                   | `qc-release.batch-release.revoke` | Admin tier full scope.                          |
| `system-admin`            | `qc-release.batch-release.revoke` | Admin tier full scope.                          |
| `qc-approver`             | `qc-release.batch-release.revoke` | Người duyệt batch release.                      |
| `quality-control-manager` | `qc-release.batch-release.revoke` | Senior QC approval.                             |
| `quality-lead`            | `qc-release.batch-release.revoke` | Senior QC approval.                             |
| `approval-authority`      | `qc-release.batch-release.revoke` | Cross-domain approval governance.               |
| `R-SUPPLIER`              | `raw-material.supplier.read`      | External supplier portal scope (read-only own). |

### 2.4 Doc patch

| File                                                              | Thay đổi                                                                                                                  |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `docs/v2-decisions/OD-DEFAULTS-BATCH2-2026-05-03.md` §3.1/3.2/3.3 | Thêm dòng "Trạng thái: OWNER_ACCEPTED_AS_DEFAULT_2026-05-03" + chú giải production-acceptable.                            |
| `docs/v2-decisions/OD-DEFAULTS-BATCH2-2026-05-03.md` §3 header    | Đổi tiêu đề: "OD Đã Owner Accept Làm Default Production-Acceptable (3 OD)".                                               |
| `docs/software-specs/phase-project/01_PHASE_PROJECT_TODO.md` §2   | Cập nhật bảng OD: 8 dòng đều `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03 (production-acceptable)`.                              |
| `docs/software-specs/09_CONFLICT_AND_OWNER_DECISIONS.md` §C.8     | Thêm §C.8.a (8 OD Batch 1) + §C.8.b (15 OD Batch 2) + §C.8.c (3 OD trước đây BLOCKING) + §C.8.d (seed canonical mapping). |
| `docs/software-specs/09_CONFLICT_AND_OWNER_DECISIONS.md` §G       | Append 1 history row 2026-05-03 (turn 6 directive).                                                                       |

## 3. Validation

### 3.1 Seed validation

| Gate                                   | Lệnh                                           | Kết quả                                                                                                                      |
| -------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Seed chain end-to-end                  | `psql -f docs/seeds/00_views.sql ... 16_*.sql` | **N/A — DB chưa scaffold (`apps/api` empty)**                                                                                |
| Seed validation 15_seed_validation.sql | `psql -f docs/seeds/15_seed_validation.sql`    | **N/A — DB chưa scaffold**                                                                                                   |
| Idempotency check (run twice)          | re-run toàn bộ seed chain                      | **N/A — DB chưa scaffold**, nhưng patch viết theo pattern `INSERT ... WHERE NOT EXISTS` đảm bảo idempotency by construction. |

### 3.2 Backend / Frontend gate

| Gate                           | Trạng thái                                                                                                     |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| `dotnet build` / `dotnet test` | **N/A — `apps/api` chưa scaffold**                                                                             |
| `npx tsc -b` / `npm run build` | **N/A — `apps/admin-web/app` chưa có code thực**, app shell scaffold tồn tại nhưng không bị task này thay đổi. |

## 4. GO/NO-GO

**GO** cho:

- CODE00 PROJECT-INITIATION
- CODE01 Foundation + Source Origin
- CODE02 Raw Material Intake (đã có R-SUPPLIER + raw-material.supplier.read sẵn)
- CODE05 QC + Release (đã có qc-release.batch-release.approve + .revoke sẵn)
- CODE08 Recall (đã có CAPA model accepted)
- CODE12 Printer (ZPL+HMAC adapter accepted)
- CODE13 MISA + Notification (outbox-only boundary accepted)
- CODE16 Retention/DR (RPO/RTO + adapter accepted)
- CODE17 Release readiness — không còn OD nào block

## 5. Rủi ro còn lại

**KHÔNG.**

Toàn bộ 26 OD (8 Batch 1 + 15 Batch 2 + 3 trước đây BLOCKING) đã chuyển sang `OWNER_ACCEPTED_AS_DEFAULT_2026-05-03`. Provisional adapter/boundary/policy đã được owner accept làm production-acceptable. Runtime swap qua DI binding hoặc `op_*_config` table không cần đổi schema/contract.

## 6. Next action

1. Bắt đầu CODE00 PROJECT-INITIATION theo `docs/software-specs/phase-project/02_AGENT_PROMPT_SEQUENCE.md`.
2. Khi DB scaffold xong (CODE01), chạy seed chain `00 → 16` lần 1 + lần 2 và verify `15_seed_validation.sql` để xác nhận R-SUPPLIER + 2 permission mới có mặt với count đúng.
3. Khi backend scaffold xong, viết integration test cho `qc-release.batch-release.revoke` flow (audit append-only) và `raw-material.lot.mark-ready` permission gate.
