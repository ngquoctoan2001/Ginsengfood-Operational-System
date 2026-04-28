# 06 - API Example Fixtures

## Mục Lục

- [1. Mục đích](#1-mục-đích)
- [2. Quy ước](#2-quy-ước)
- [3. Command examples](#3-command-examples)
- [4. Public trace response policy](#4-public-trace-response-policy)

## 1. Mục Đích

File này cung cấp JSON fixture tối thiểu để backend, frontend và QA dùng chung khi implement API contract.

Các payload dưới đây là ví dụ triển khai theo API catalog, không thay thế schema validation trong code.

## 2. Quy Ước

| item | rule |
|---|---|
| Auth | Admin command endpoint cần bearer token và permission tương ứng. |
| Idempotency | Mọi command tạo giao dịch hoặc đổi state phải gửi `Idempotency-Key`. |
| Reference key | Dùng business code trong fixture; implementation có thể resolve sang UUID nội bộ. |
| Formula | Smoke baseline dùng `formula_version = G1`; API/schema vẫn phải hỗ trợ active approved recipe version tương lai. |
| Batch size | `planned_batch_size = 400` là quantity-per-batch basis theo recipe, không mặc định là 400 kg thành phẩm. |
| Route source | Route examples follow `docs/software-specs/api/02_API_ENDPOINT_CATALOG.md`; không tạo adapter route song song từ tài liệu cũ. |

## 3. Command Examples

### 3.0 Raw Material Intake Examples

```json
{
  "self_grown_request": {
    "method": "POST",
    "path": "/api/admin/raw-material/intakes",
    "headers": {
      "Idempotency-Key": "idem-raw-self-grown-smoke-001"
    },
    "body": {
      "receipt_no": "RM-SMOKE-SELF-GROWN-001",
      "procurement_type": "SELF_GROWN",
      "warehouse_code": "WH_RAW_MAIN",
      "source_origin_code": "SRC_ORIGIN_SMOKE_001",
      "lines": [
        {
          "ingredient_code": "HRB_SAM_SAVIGIN",
          "quantity": 9.00,
          "uom_code": "kg"
        }
      ]
    }
  },
  "self_grown_expected_response": {
    "receipt_no": "RM-SMOKE-SELF-GROWN-001",
    "procurement_type": "SELF_GROWN",
    "source_origin_status": "VERIFIED",
    "raw_lots_created": true
  },
  "purchased_request": {
    "method": "POST",
    "path": "/api/admin/raw-material/intakes",
    "headers": {
      "Idempotency-Key": "idem-raw-purchased-smoke-001"
    },
    "body": {
      "receipt_no": "RM-SMOKE-PURCHASED-001",
      "procurement_type": "PURCHASED",
      "warehouse_code": "WH_RAW_MAIN",
      "supplier_code": "SUP_SMOKE_001",
      "coa_reference": "COA-SMOKE-001",
      "lines": [
        {
          "ingredient_code": "ING_GAO",
          "quantity": 195.00,
          "uom_code": "kg"
        }
      ]
    }
  },
  "purchased_expected_response": {
    "receipt_no": "RM-SMOKE-PURCHASED-001",
    "procurement_type": "PURCHASED",
    "source_zone_required": false,
    "raw_lots_created": true
  }
}
```

### 3.0b Mark Raw Lot Ready For Production

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/raw-material/lots/{lotId}/readiness",
    "headers": {
      "Idempotency-Key": "idem-raw-lot-ready-smoke-001"
    },
    "body": {
      "targetLotStatus": "READY_FOR_PRODUCTION",
      "actionCode": "RAW_LOT_MARK_READY",
      "qc_result_required": "QC_PASS",
      "reason": "Smoke fixture mark-ready after incoming QC pass"
    }
  },
  "expected_response": {
    "lotStatus": "READY_FOR_PRODUCTION",
    "qcStatus": "QC_PASS",
    "isReadyForIssue": true,
    "emittedEvent": "RAW_LOT_READY_FOR_PRODUCTION"
  }
}
```

### 3.1 Create Production Order

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/production/orders",
    "headers": {
      "Idempotency-Key": "idem-po-smoke-g1-a1-001"
    },
    "body": {
      "production_order_no": "PO-SMOKE-G1-A1-001",
      "sku_code": "A1/CS/DM/HS",
      "formula_version": "G1",
      "planned_batch_size": 400,
      "planned_quantity": 400,
      "planned_start_at": "2026-04-27T08:00:00+07:00",
      "note": "Smoke PO uses G1 immutable recipe snapshot; batch size 400 is recipe basis, not kg."
    }
  },
  "expected_response": {
    "production_order_no": "PO-SMOKE-G1-A1-001",
    "sku_code": "A1/CS/DM/HS",
    "formula_code": "FML-A1-G1",
    "formula_version": "G1",
    "status": "DRAFT",
    "snapshot_line_count": 23
  }
}
```

### 3.2 Create Material Request

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/production/material-requests",
    "headers": {
      "Idempotency-Key": "idem-mr-smoke-g1-a1-001"
    },
    "body": {
      "material_request_no": "MR-SMOKE-G1-A1-001",
      "production_order_no": "PO-SMOKE-G1-A1-001",
      "request_mode": "FROM_RECIPE_SNAPSHOT",
      "requested_by": "R-PROD-OP"
    }
  },
  "expected_response": {
    "material_request_no": "MR-SMOKE-G1-A1-001",
    "status": "SUBMITTED",
    "source": "PRODUCTION_ORDER_RECIPE_SNAPSHOT"
  }
}
```

### 3.3 Execute Material Issue

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/production/material-issues/{materialIssueId}/execute",
    "headers": {
      "Idempotency-Key": "idem-mi-smoke-g1-a1-001"
    },
    "body": {
      "material_issue_no": "MI-SMOKE-G1-A1-001",
      "warehouse_code": "WH_RAW_MAIN",
      "production_order_no": "PO-SMOKE-G1-A1-001",
      "issue_mode": "FROM_APPROVED_MATERIAL_REQUEST",
      "lines_source": "SNAPSHOT",
      "raw_lot_status_required": "READY_FOR_PRODUCTION",
      "lot_selection_policy": "QC_PASS alone is insufficient; lot must have mark-ready transition",
      "operator_note": "Smoke material issue; this is the real raw inventory decrement point."
    }
  },
  "expected_response": {
    "material_issue_no": "MI-SMOKE-G1-A1-001",
    "status": "EXECUTED",
    "inventory_ledger_created": true
  }
}
```

### 3.4 Confirm Material Receipt

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/production/material-receipts",
    "headers": {
      "Idempotency-Key": "idem-mrc-smoke-g1-a1-001"
    },
    "body": {
      "material_receipt_no": "MRC-SMOKE-G1-A1-001",
      "material_issue_no": "MI-SMOKE-G1-A1-001",
      "production_order_no": "PO-SMOKE-G1-A1-001",
      "receipt_mode": "WORKSHOP_CONFIRMATION",
      "variance_policy": "REASON_REQUIRED_IF_DIFFERENT"
    }
  },
  "expected_response": {
    "material_receipt_no": "MRC-SMOKE-G1-A1-001",
    "status": "CONFIRMED"
  }
}
```

### 3.5 Record Required Process Events

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/production/process-events",
    "headers": {
      "Idempotency-Key": "idem-proc-smoke-g1-a1-001"
    },
    "body": {
      "batch_no": "BATCH-SMOKE-G1-A1-001",
      "work_order_no": "WO-SMOKE-G1-A1-001",
      "events": [
        {
          "process_step": "PREPROCESSING",
          "process_status": "COMPLETED",
          "completed_at": "2026-04-27T10:00:00+07:00"
        },
        {
          "process_step": "FREEZING",
          "process_status": "COMPLETED",
          "completed_at": "2026-04-27T12:00:00+07:00"
        },
        {
          "process_step": "FREEZE_DRYING",
          "process_status": "COMPLETED",
          "completed_at": "2026-04-27T18:00:00+07:00"
        }
      ]
    }
  },
  "expected_response": {
    "batch_no": "BATCH-SMOKE-G1-A1-001",
    "required_process_chain_complete": true,
    "next_allowed_action": "FINISHED_QC"
  }
}
```

### 3.6 Batch Release

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/qc/releases",
    "headers": {
      "Idempotency-Key": "idem-rel-smoke-g1-a1-001"
    },
    "body": {
      "release_no": "REL-SMOKE-G1-A1-001",
      "batch_no": "BATCH-SMOKE-G1-A1-001",
      "qc_result_required": "QC_PASS",
      "decision": "RELEASE"
    }
  },
  "expected_response": {
    "release_no": "REL-SMOKE-G1-A1-001",
    "release_status": "RELEASED"
  }
}
```

### 3.7 Warehouse Receipt

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/warehouse/receipts",
    "headers": {
      "Idempotency-Key": "idem-wr-smoke-g1-a1-001"
    },
    "body": {
      "warehouse_receipt_no": "WR-SMOKE-G1-A1-001",
      "warehouse_code": "WH_FG_MAIN",
      "batch_no": "BATCH-SMOKE-G1-A1-001",
      "batch_release_no": "REL-SMOKE-G1-A1-001",
      "received_quantity": 400,
      "uom_code": "hộp"
    }
  },
  "expected_response": {
    "warehouse_receipt_no": "WR-SMOKE-G1-A1-001",
    "receipt_status": "CONFIRMED",
    "inventory_ledger_created": true
  }
}
```

### 3.8 Public Trace

```json
{
  "request": {
    "method": "GET",
    "path": "/api/public/trace/QR-SMOKE-G1-A1-001"
  },
  "expected_response": {
    "qr_code": "QR-SMOKE-G1-A1-001",
    "product_name": "Cháo Sâm – Diêm mạch & Hạt sen",
    "batch_public_code": "BATCH-SMOKE-G1-A1-001",
    "release_public_status": "RELEASED",
    "source": {
      "source_zone_name": "SRC_ZONE_SMOKE_001",
      "province": "OWNER_SAMPLE_PROVINCE",
      "ward": "OWNER_SAMPLE_WARD",
      "address_detail": "OWNER_SAMPLE_ADDRESS"
    }
  }
}
```

### 3.9 MISA Missing Mapping Negative Case

```json
{
  "request": {
    "method": "POST",
    "path": "/api/admin/integrations/misa/sync-events/{syncEventId}/retry",
    "headers": {
      "Idempotency-Key": "idem-misa-missing-map-001"
    },
    "body": {
      "internal_object_type": "NEGATIVE_TEST",
      "internal_object_key": "MISSING_MAPPING_FIXTURE",
      "retry_reason": "Smoke negative case"
    }
  },
  "expected_response": {
    "sync_status": "RECONCILE_PENDING",
    "error_code": "MISA_MAPPING_MISSING",
    "manual_action_required": true
  }
}
```

## 4. Public Trace Response Policy

Public response must fail test if it contains any of these keys:

```json
[
  "supplier_id",
  "supplier_name",
  "operator_user_id",
  "cost_amount",
  "qc_defect_detail",
  "loss_quantity",
  "misa_external_id",
  "internal_batch_id",
  "raw_material_lot_internal_code"
]
```
