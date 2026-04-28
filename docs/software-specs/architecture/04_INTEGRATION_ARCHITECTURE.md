# Integration Architecture

> Mục đích: mô tả boundary tích hợp MISA, printer/device, public trace, commerce/notification references.

## 1. Integration Principles

| principle_id | Principle |
| --- | --- |
| INT-001 | Business modules emit events; integration layer performs external sync. |
| INT-002 | External systems never write operational tables directly. |
| INT-003 | Mapping, retry, reconcile and audit are mandatory for MISA. |
| INT-004 | Printer/device adapters cannot bypass QC/release/QR lifecycle. |
| INT-005 | Public trace API is read-only and field-whitelisted. |

## 2. Integration Map

| Integration | Direction | Owner module | Data | Pattern | Failure behavior |
| --- | --- | --- | --- | --- | --- |
| MISA AMIS | Outbound | M14 | Material issue accounting document, warehouse receipt, inventory/accounting relevant events, mapping status | Outbox -> mapper -> sync -> log -> reconcile | Retry, then MISA sync `FAILED_NEEDS_REVIEW`; business truth remains in Operational |
| Printer/QR | Outbound/callback | M10 | Print job, QR code, print status, GTIN/trade item mapping | Print queue -> adapter -> callback log | `FAILED` state, QR state history, reprint flow with audit |
| Public Trace | Inbound public read | M12 | QR public trace payload | Public API -> public view/policy | Invalid QR safe response, no private leak |
| Commerce/Order/Shipment | Reference/read downstream | M11/M12/M13 | `order_id`, `order_item_id`, `shipment_id`, `customer_id` | Reference keys only | Missing external reference detail does not block local issue/receipt/release; Operational stores reference key as-is and marks downstream detail unresolved |
| Notification/CRM | Outbound/reference | M13 | `notification_job_id`, recall communication reference | Recall case -> notification request/reference | Store reference/status, not notification owner data |
| Dashboard/Monitoring | Internal | M15 | Events, metrics, health | Event/metric projection | Unknown telemetry is not success |

## 3. MISA Integration Contract

```text
Business event committed
  -> outbox_event PENDING
  -> misa_sync_event created
  -> mapping resolved in misa_mapping
  -> outbound request to MISA
  -> misa_sync_log appended
  -> status SYNCED or FAILED_RETRYABLE/FAILED_NEEDS_REVIEW
  -> reconcile record if mismatch
```

Required data tables:

- `misa_mapping`
- `misa_sync_event`
- `misa_sync_log`
- `misa_reconcile_record`
- `outbox_event`
- `audit_log`

Status mapping:

| Layer | Terminal/review state | Meaning |
| --- | --- | --- |
| Outbox | `FAILED_DEAD_LETTER` | Event dispatcher cannot deliver after retry policy; manual replay/review needed. |
| MISA sync | `FAILED_NEEDS_REVIEW` | MISA mapping/remote sync needs accounting/integration review. |
| Mapping | `FAILED_DEAD_LETTER` -> `FAILED_NEEDS_REVIEW` | A dead-lettered MISA-bound outbox event creates/updates MISA sync review state; these are not the same enum. |

## 4. Printer/QR Boundary

| Rule | Detail |
| --- | --- |
| Queue first | Print request creates `op_print_job`; adapter consumes job. |
| QR lifecycle | QR state changes through `op_qr_state_history`. |
| Reprint | Reprint links original QR/print job, reason and actor. |
| Callback | Callback updates print job/QR technical status, not batch/release/inventory directly. `FAILED` writes QR/print failure history and audit; `REPRINTED` links original print job. |
| GTIN guard | Commercial print requires active GTIN mapping for the trade item/package level; production printer must block `is_test_fixture=true` mappings and must not fallback to SKU code. |
| No DB direct | Device/printer has no direct DB access. |

## 5. Integration Open Decisions

| decision | Impact |
| --- | --- |
| MISA tenant/credential production | Required for production sync; dev can use fake/placeholder secret references. |
| Printer model/driver/protocol | Required for device adapter finalization. |
| Retry/backoff final policy | Open technical decision `OTD-007`; no implementation should treat an unapproved retry count as final. |
