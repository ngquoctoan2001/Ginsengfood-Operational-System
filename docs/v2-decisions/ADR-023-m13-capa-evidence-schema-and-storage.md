# ADR-023 - M13 CAPA Evidence Schema And Storage

## Status

Accepted - owner approved 2026-04-29.

## Context

`modules/13_RECALL.md` requires CAPA evidence before CAPA/recall close, but the previous database shape only defined `op_recall_capa` and did not define where evidence metadata lives.

There was also a conflict: `modules/13_RECALL.md` mentioned `op_recall_capa_item`, while `diagrams/06_ERD_DIAGRAM.md` said `op_recall_capa` is the canonical CAPA table and not to introduce parallel `op_recall_capa_item` unless database spec changes.

Owner also clarified storage deployment:

- dev/test stores uploaded image/video evidence on local filesystem;
- production stores uploaded image/video evidence on the company's storage server;
- code should use configuration so production storage can be plugged in later.

## Decision

Use `op_recall_capa` as the canonical CAPA action/task table for M13 baseline.

Do not create `op_recall_capa_item` in M13 baseline. If CAPA sub-task detail is required later, create a new ADR and formally update database/API/UI specs first.

Create `op_recall_capa_evidence` as the append-only CAPA evidence metadata table:

```text
op_recall_capa_evidence
- evidence_id uuid PK
- capa_id uuid FK -> op_recall_capa.capa_id
- evidence_type text
- evidence_uri text
- evidence_hash text null
- mime_type text
- file_size_bytes bigint
- original_filename text null
- scan_status text
- scanned_at timestamptz null
- scan_result_ref text null
- uploaded_by uuid/text
- notes text null
- created_at timestamptz
```

Evidence binary storage is behind a storage adapter:

- `local` / `dev` / test: local filesystem storage.
- `staging` / `production`: company storage server configured by DevOps.

The Operational DB stores metadata only. It must not store image/video blobs.

CAPA evidence must follow the same MIME/size policy as M05 source-origin evidence:

- images: `image/jpeg`, `image/png`, `image/webp`, max 10MB;
- videos: `video/mp4`, `video/quicktime`, max 100MB.

Evidence scan status uses:

```text
PENDING_SCAN
CLEAN
INFECTED
SCAN_FAILED
```

Source verification and CAPA/recall close accept only `scan_status = CLEAN`. Dev/test may use a mock/dev-skip scanner to produce `CLEAN`; production must use a real AV/malware scanner.

## Consequences

Backend/API must provide:

- `POST /api/admin/source-origins/{sourceOriginId}/evidence`;
- `POST /api/admin/recall/capas/{capaId}/evidence`;
- clean-evidence validation before source verification and recall close.

Frontend must display evidence scan status and block/disable close actions until backend reports at least one clean evidence row.

Backup/restore must include both DB metadata and the configured storage path/server for evidence binaries.

## Source Updates

- `docs/software-specs/modules/13_RECALL.md`
- `docs/software-specs/modules/05_SOURCE_ORIGIN.md`
- `docs/software-specs/database/03_TABLE_SPECIFICATION.md`
- `docs/software-specs/database/04_ENUM_REFERENCE.md`
- `docs/software-specs/database/05_INDEX_CONSTRAINT_REFERENCE.md`
- `docs/software-specs/api/02_API_ENDPOINT_CATALOG.md`
- `docs/software-specs/api/03_API_REQUEST_RESPONSE_SPEC.md`
- `docs/software-specs/api/04_API_ERROR_CODE_SPEC.md`
- `docs/software-specs/ui/05_FORM_FIELD_SPECIFICATION.md`
- `docs/software-specs/non-functional/03_SECURITY_REQUIREMENTS.md`
