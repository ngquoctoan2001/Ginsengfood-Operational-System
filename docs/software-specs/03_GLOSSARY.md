# 03 - Glossary

## 1. Quy Ước

- Giải thích nghiệp vụ viết bằng tiếng Việt.
- Code identifier, enum, table, column, route, method giữ nguyên tiếng Anh.
- Nếu thuật ngữ lấy từ `HIST-SPECS`, phải ghi nhãn fallback ở file chi tiết tương ứng.

## 2. Domain & Data Ownership

| Thuật ngữ          | Identifier               | Định nghĩa                                                                                                          |
| ------------------ | ------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| Operational Domain | `Operational Domain`     | Phân hệ quản lý source origin, raw material, production, packaging, QC, warehouse, trace, recall, MISA integration. |
| External Domain    | `External Domain`        | Domain ngoài Operational như Catalog, Order, Customer, CRM, Notification, MISA.                                     |
| Source of truth    | `source_of_truth`        | Nguồn dữ liệu nghiệp vụ được phép coi là đúng nhất cho một loại dữ liệu.                                            |
| Reference key      | `*_id` external          | Khóa tham chiếu đến domain ngoài, ví dụ `customer_id`, `order_id`, `shipment_id`.                                   |
| Master data        | `ref_*`, `op_* master`   | Dữ liệu cấu hình/chủ, ví dụ SKU, ingredient, UOM, warehouse, source zone.                                           |
| Transaction data   | `op_*` transaction       | Dữ liệu nghiệp vụ phát sinh theo flow, ví dụ receipt, issue, batch, release.                                        |
| Ledger data        | `op_inventory_ledger`    | Log append-only của biến động tồn kho.                                                                              |
| Snapshot data      | `snapshot_*`             | Bản sao bất biến tại thời điểm nghiệp vụ, ví dụ production order recipe snapshot.                                   |
| Audit data         | `audit_log`, `*_history` | Dữ liệu lịch sử actor/time/reason/state change.                                                                     |

## 3. Source Origin & Raw Material

| Thuật ngữ                    | Identifier                      | Định nghĩa                                                                                                                                                         |
| ---------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Vùng trồng                   | `source_zone`                   | Vùng/địa điểm nguồn gốc nguyên liệu. Public trace có thể expose trường được duyệt.                                                                                 |
| Bản ghi nguồn gốc            | `source_origin`                 | Bản ghi nguồn cụ thể thuộc source zone, có evidence/verification.                                                                                                  |
| Xác minh nguồn               | `VERIFIED`                      | Trạng thái source origin đã đủ điều kiện cho lot `SELF_GROWN`.                                                                                                     |
| Tiếp nhận nguyên liệu        | `raw_material_intake`           | Phiếu/sự kiện nhập nguyên liệu đầu vào.                                                                                                                            |
| Lô nguyên liệu               | `raw_material_lot`              | Lot identity của nguyên liệu sau intake, QC và readiness.                                                                                                          |
| Tự trồng                     | `SELF_GROWN`                    | Procurement type cho nguyên liệu công ty tự trồng; cần source zone/source origin, không dùng supplier.                                                             |
| Mua ngoài                    | `PURCHASED`                     | Procurement type cho nguyên liệu mua từ supplier; cần `supplier_id`, không dùng source zone/source origin.                                                         |
| QC đầu vào                   | `incoming_qc`                   | Kiểm chất lượng raw material lot trước khi dùng cho production.                                                                                                    |
| Số lượng dự kiến             | `proposed_quantity`             | Số lượng nguyên liệu do supplier hoặc công ty khai báo trước khi hàng đến (Raw Material Receipt item).                                                             |
| UOM dự kiến                  | `proposed_uom_code`             | Đơn vị đo cho `proposed_quantity`.                                                                                                                                 |
| Số lượng thực nhận           | `received_quantity`             | Số lượng công ty xác nhận thực nhận khi hàng đến.                                                                                                                  |
| Số lượng đạt                 | `accepted_quantity`             | Số lượng được chấp nhận sau kiểm tra/QC theo policy.                                                                                                               |
| Số lượng không đạt           | `rejected_quantity`             | Số lượng không đạt/chưa được chấp nhận.                                                                                                                            |
| Số lượng trả hàng            | `returned_quantity`             | Số lượng trả lại supplier (`returned_quantity <= rejected_quantity`).                                                                                              |
| Trạng thái nhận hàng         | `raw_receipt_status`            | Trạng thái nghiệp vụ của Raw Material Receipt; xem enum `raw_receipt_status`.                                                                                      |
| Trạng thái cộng tác supplier | `supplier_collaboration_status` | Trạng thái tương tác giữa công ty và supplier trên phiếu `PURCHASED`; xem enum cùng tên.                                                                           |
| Trạng thái QC lot            | `lot_qc_status`                 | Trạng thái QC của raw material lot; khởi tạo `PENDING_QC`.                                                                                                         |
| Supplier user                | `SUPPLIER_USER`                 | External user thuộc nhà cung cấp (`user_type = SUPPLIER_USER`), gắn `supplier_id`, dùng role `R_SUPPLIER`.                                                         |
| Supplier Portal              | `supplier_portal`               | Giao diện riêng cho supplier truy cập Raw Material Receipt scope theo `supplier_id`; route family `/api/supplier/*`.                                               |
| Supplier-ingredient mapping  | `op_supplier_ingredient`        | Bảng M03A gán quyền cung cấp `ingredient_id` cho `supplier_id`, có `status`, `effective_from/to`, evidence policy fields, audit.                                   |
| Evidence URI                 | `evidence_uri`                  | Đường dẫn tới file evidence (ảnh/video/COA/lab/delivery/damage); blob KHÔNG lưu trong PostgreSQL, không expose qua public trace.                                   |
| Decline confirmation         | `SUPPLIER_DECLINED`             | Hành động supplier từ chối xác nhận phiếu công ty tạo trước; chuyển `supplier_collaboration_status = SUPPLIER_DECLINED`; supplier không được cancel phiếu công ty. |

## 4. SKU / Ingredient / Recipe

| Thuật ngữ              | Identifier                                                                                    | Định nghĩa                                                                                                                                                                     |
| ---------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| SKU                    | `sku_id`, `sku_code`                                                                          | Sản phẩm/đơn vị sản xuất-bán. 20 SKU là baseline go-live, không phải giới hạn vĩnh viễn.                                                                                       |
| Ingredient             | `ingredient_code`                                                                             | Nguyên liệu canonical, dùng prefix `HRB_*` hoặc `ING_*`.                                                                                                                       |
| Ingredient alias       | `material_alias`                                                                              | Alias lịch sử như `MAT-*`, chỉ dùng mapping/cross-check.                                                                                                                       |
| Công thức              | `recipe`, `formula`                                                                           | Công thức sản xuất theo SKU và version.                                                                                                                                        |
| Formula version        | `formula_version`                                                                             | Version như `G1`, `G2`, `G3`; G1 là baseline pilot đầu tiên, G2 là baseline production fixed-batch.                                                                            |
| Formula kind           | `formula_kind`                                                                                | Mô hình tính lượng: `PILOT_PERCENT_BASED` (anchor + ratio) hoặc `FIXED_QUANTITY_BATCH` (số lượng cố định cho mẻ chuẩn 400).                                                    |
| G0                     | `G0`                                                                                          | Baseline nghiên cứu/lịch sử; không dùng vận hành.                                                                                                                              |
| G1                     | `G1`                                                                                          | Pilot operational baseline cho go-live; mặc định `formula_kind = PILOT_PERCENT_BASED`.                                                                                         |
| G2                     | `G2`                                                                                          | Production operational baseline khi rời giai đoạn pilot; mặc định `formula_kind = FIXED_QUANTITY_BATCH`. Có thể coexist ACTIVE_OPERATIONAL với G1 trong giai đoạn chuyển giao. |
| Recipe status          | `DRAFT`, `APPROVED`, `ACTIVE_OPERATIONAL`, `RETIRED`                                          | Trạng thái tối thiểu cho quản trị version công thức.                                                                                                                           |
| Recipe line group      | `recipe_line_group_code`                                                                      | Một trong 4 group: `SPECIAL_SKU_COMPONENT`, `NUTRITION_BASE`, `BROTH_EXTRACT`, `SEASONING_FLAVOR`.                                                                             |
| Anchor ingredient      | `anchor_ingredient_id`, `anchor_baseline_quantity`, `anchor_uom_code`, `anchor_ratio_percent` | Nguyên liệu mỏ neo của PILOT recipe (ví dụ gạo 195kg ở 30%); dùng để recompute toàn bộ snapshot khi tạo PO.                                                                    |
| Anchor quantity input  | `anchor_quantity_input`                                                                       | Khối lượng anchor planner nhập khi tạo PILOT PO; quyết định `total_batch_quantity` và snapshot quantity từng line.                                                             |
| Total batch quantity   | `total_batch_quantity`                                                                        | Tổng khối lượng mẻ tính cho PILOT PO = `anchor_quantity_input × 100 / anchor_ratio_percent`.                                                                                   |
| Quantity per batch 400 | `quantity_per_batch_400`                                                                      | Lượng nguyên liệu cố định cho 1 mẻ chuẩn 400 ở `formula_kind = FIXED_QUANTITY_BATCH`; PILOT recipe để NULL trên line.                                                          |
| Snapshot quantity      | `snapshot_quantity`                                                                           | Lượng nguyên liệu đã compute và đóng băng vào PO item; PILOT = ratio × total / 100, FIXED = `quantity_per_batch_400 × batch_size`.                                             |
| Snapshot basis         | `snapshot_basis`                                                                              | `PILOT_RATIO_OF_ANCHOR` hoặc `FIXED_PER_BATCH_N`; phải khớp `formula_kind_snapshot`.                                                                                           |

## 5. Production & Material Flow

| Thuật ngữ                     | Identifier         | Định nghĩa                                                                             |
| ----------------------------- | ------------------ | -------------------------------------------------------------------------------------- |
| Production order              | `production_order` | Lệnh sản xuất theo SKU/formula/quantity, tạo recipe snapshot khi mở.                   |
| Work order                    | `work_order`       | Đơn vị thực thi gắn với production order.                                              |
| Material request              | `material_request` | Đề nghị cấp nguyên liệu theo snapshot.                                                 |
| Material issue execution      | `material_issue`   | Thực thi cấp nguyên liệu theo lot; là điểm decrement raw inventory.                    |
| Material receipt confirmation | `material_receipt` | Xưởng xác nhận đã nhận nguyên liệu; ghi variance nếu có, không decrement lần hai.      |
| Production process event      | `process_event`    | Event công đoạn như `PREPROCESSING`, `FREEZING`, `FREEZE_DRYING`.                      |
| Batch                         | `batch`            | Lô thành phẩm sinh từ production/work order.                                           |
| Genealogy                     | `batch_genealogy`  | Liên kết raw material lot → issue → production → batch → packaging/warehouse/shipment. |

## 6. Packaging / Printing / QR

| Thuật ngữ       | Identifier                                                      | Định nghĩa                                                                                                                                                                                                                                                                                                                                                                                     |
| --------------- | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Packaging job   | `packaging_job`                                                 | Lệnh đóng gói cho batch.                                                                                                                                                                                                                                                                                                                                                                       |
| Packaging level | `PACKET`, `BOX`, `CARTON`                                       | Cấp đóng gói/in: `PACKET` = cấp 1 gói nhỏ (chỉ SKU code/public name/NSX/HSD, không batch_code, không QR); `BOX` = cấp 2 hộp chứa N gói (mặc định 4 gói/hộp, full label + batch_code + identifier + QR public trace); `CARTON` = cấp 2.1 thùng chứa M hộp (optional theo quyết định vận hành tại thời điểm đóng gói; bắt buộc cấu hình `boxes_per_carton` trên trade item nếu chọn đóng thùng). |
| Trade item      | `trade_item`                                                    | Identity thương mại tách khỏi SKU.                                                                                                                                                                                                                                                                                                                                                             |
| GTIN/GS1        | `gtin`                                                          | Barcode thương mại cho trade item/packaging level.                                                                                                                                                                                                                                                                                                                                             |
| QR registry     | `qr_registry`                                                   | Registry quản lý vòng đời QR token.                                                                                                                                                                                                                                                                                                                                                            |
| QR lifecycle    | `GENERATED`, `QUEUED`, `PRINTED`, `FAILED`, `VOID`, `REPRINTED` | Các trạng thái QR tối thiểu.                                                                                                                                                                                                                                                                                                                                                                   |
| Reprint         | `REPRINTED`                                                     | In lại có link original token/payload và reason/audit.                                                                                                                                                                                                                                                                                                                                         |

## 7. QC / Release / Warehouse

| Thuật ngữ         | Identifier              | Định nghĩa                                                                |
| ----------------- | ----------------------- | ------------------------------------------------------------------------- |
| QC inspection     | `qc_inspection`         | Bản ghi kiểm chất lượng raw material/batch/finished goods.                |
| QC pass           | `QC_PASS`               | Kết quả QC đạt; chưa phải release.                                        |
| QC hold           | `QC_HOLD`               | Tạm giữ chờ xử lý/điều tra.                                               |
| QC reject         | `QC_REJECT`             | Không đạt; không được dùng/nhập kho/bán nếu chưa có exception được duyệt. |
| Batch release     | `batch_release`         | Record/action phê duyệt batch được nhập kho/bán.                          |
| Warehouse receipt | `warehouse_receipt`     | Nhập kho thành phẩm sau release.                                          |
| Inventory ledger  | `inventory_ledger`      | Append-only log của mọi biến động tồn kho.                                |
| Lot balance       | `inventory_lot_balance` | Projection số dư theo lot/batch/warehouse/location.                       |

## 8. Traceability / Recall

| Thuật ngữ         | Identifier                     | Định nghĩa                                                                                                 |
| ----------------- | ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| Internal trace    | `internal_trace`               | Truy vết đầy đủ cho nhân sự nội bộ/audit.                                                                  |
| Public trace      | `public_trace`                 | Truy vết cho consumer qua QR, field bị giới hạn.                                                           |
| Backward trace    | `backward_trace`               | Batch → production → material issue → raw material lot → source origin.                                    |
| Forward trace     | `forward_trace`                | Batch → warehouse → shipment/order/customer exposure.                                                      |
| Recall case       | `recall_case`                  | Hồ sơ thu hồi sản phẩm, gồm impact, hold, notification, recovery, disposition, CAPA và CAPA evidence sạch. |
| Hold              | `hold`                         | Khóa tạm batch/lot/inventory.                                                                              |
| Sale lock         | `sale_lock`                    | Khóa bán/khóa phân phối batch.                                                                             |
| Customer exposure | `customer_exposure`            | Snapshot khách/order/shipment có khả năng bị ảnh hưởng.                                                    |
| CAPA              | `corrective_preventive_action` | Hành động khắc phục/phòng ngừa sau sự cố; close cần evidence metadata đã scan sạch khi policy yêu cầu.     |

## 9. Integration / Governance

| Thuật ngữ              | Identifier         | Định nghĩa                                                     |
| ---------------------- | ------------------ | -------------------------------------------------------------- |
| MISA integration layer | `misa_integration` | Lớp sync chung sang MISA, có mapping/retry/reconcile/audit.    |
| MISA mapping           | `misa_mapping`     | Mapping entity/code Operational sang object/account/code MISA. |
| Sync event             | `sync_event`       | Sự kiện chờ đồng bộ.                                           |
| Reconcile              | `reconcile`        | Đối soát Operational với MISA.                                 |
| Idempotency key        | `idempotency_key`  | Key chống submit trùng/retry gây double posting.               |
| Outbox                 | `outbox`           | Pattern phát event đáng tin cậy sau transaction.               |
| Break-glass            | `break_glass`      | Override khẩn cấp có reason/actor/audit/approval.              |

## 10. Testing

| Thuật ngữ        | Identifier         | Định nghĩa                                                        |
| ---------------- | ------------------ | ----------------------------------------------------------------- |
| Unit test        | `unit_test`        | Test logic nhỏ.                                                   |
| Integration test | `integration_test` | Test service/database/integration boundary.                       |
| API test         | `api_test`         | Test endpoint, auth, permission, error.                           |
| UI test          | `ui_test`          | Test screen/form/table/action/validation.                         |
| Smoke test       | `smoke_test`       | Test happy path end-to-end quan trọng.                            |
| Seed validation  | `seed_validation`  | Test seed đủ 20 SKU, ingredient, G1 recipe, 4 group, idempotency. |
| Regression test  | `regression_test`  | Test chống phá các hard locks sau thay đổi.                       |
