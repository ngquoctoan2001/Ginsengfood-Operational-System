# 04 - Business Context

## 1. Bối Cảnh

Ginsengfood vận hành sản xuất thực phẩm bổ dưỡng/chức năng từ dược liệu và nguyên liệu thực phẩm. Chuỗi vận hành cần quản lý:

- Vùng trồng/source origin cho nguyên liệu tự trồng.
- Supplier cho nguyên liệu mua ngoài.
- Raw material intake, QC, lot readiness.
- Recipe G1 baseline cho 20 SKU.
- Production order theo recipe snapshot.
- Material issue/receipt theo lot.
- Batch, packaging, QR, QC, release.
- Warehouse receipt và inventory ledger.
- Traceability, public trace, recall.
- MISA integration qua một lớp chung.

Nguồn chính: `SRC-FILE01`, `SRC-FILE02`, `SRC-FILE03`, `SRC-RECIPE-NEW`, `SRC-FORM-AUTO`.

## 2. Vấn Đề Kinh Doanh Cần Giải

| Vấn đề | Hệ quả nếu không giải | Yêu cầu hệ thống |
| --- | --- | --- |
| Không có lot/batch/genealogy rõ | Không truy vết/recall được | Mọi raw material và finished batch phải có identity và link genealogy. |
| QC và release bị gộp | Batch có thể nhập kho/bán khi chưa release | Tách `QC_PASS` và `RELEASED`. |
| Inventory tăng/giảm sai checkpoint | Tồn kho lệch thực tế | Chỉ ledger checkpoints được phép thay tồn. |
| Recipe thay đổi làm mất lịch sử | Không biết batch cũ dùng công thức nào | Snapshot recipe vào production order. |
| MISA sync trực tiếp từng module | Drift, khó retry/reconcile | Mọi sync đi qua integration layer chung. |
| Public trace lộ dữ liệu nội bộ | Rủi ro bảo mật/uy tín | Public trace field policy bắt buộc. |
| Recall thủ công | Chậm khóa bán/thông báo | Recall case dùng trace/exposure snapshot. |

## 3. Stakeholder

| Stakeholder | Nhu cầu |
| --- | --- |
| Owner / Ban điều hành | Biết hệ thống bao phủ đúng chuỗi sản xuất, trace, recall, MISA. |
| Quản lý nhà máy | Theo dõi lệnh sản xuất, gate, batch, tiến độ và exception. |
| Kho nguyên liệu | Nhập, quản lý lot, cấp phát theo `QC_PASS`. |
| QC | Kiểm nguyên liệu, bán thành phẩm, thành phẩm; ghi evidence và disposition. |
| Xưởng sản xuất | Nhận nguyên liệu, thực hiện sơ chế/cấp đông/sấy thăng hoa, tạo batch. |
| Đóng gói/in | Thực thi packaging, print payload, QR lifecycle. |
| Kho thành phẩm | Chỉ nhận batch `RELEASED`; quản lý tồn theo batch/warehouse/location. |
| Kế toán/MISA | Nhận dữ liệu đã đủ điều kiện hạch toán qua integration layer. |
| Compliance/Audit | Xem audit trail, internal trace, recall record. |
| Khách hàng cuối | Quét QR để xem public trace đã giới hạn field. |

## 4. Business Capabilities

| Capability | Mô tả | Module owner |
| --- | --- | --- |
| Source governance | Quản lý source zone, source origin, verification. | M05 |
| Raw material control | Intake, lot, incoming QC, readiness. | M06 |
| SKU/recipe governance | 20 SKU baseline, ingredient master, G1 recipe, future versions. | M04 |
| Manufacturing execution | Production order, work order, process events, batch. | M07 |
| Material issue/receipt | Issue theo snapshot/lot, decrement inventory, receipt confirmation. | M08 |
| Packaging/printing/QR | Packaging level, print job, QR registry, GTIN/trade item. | M10 |
| QC/release | QC inspection, disposition, batch release. | M09 |
| Warehouse/inventory | Warehouse receipt, ledger, lot balance, allocation reference. | M11 |
| Traceability | Internal trace, public trace, genealogy. | M12 |
| Recall | Incident, hold, sale lock, notification, recovery, CAPA. | M13 |
| Integration/accounting | MISA mapping, sync, retry, reconcile. | M14 |
| Governance/admin | RBAC, audit, UI, dashboard, override, monitoring. | M01, M02, M15, M16 |

## 5. Operational Flow Tổng Quát

```text
Source zone / source origin
→ Raw material intake
→ Incoming QC
→ Raw material lot ready
→ Production order with G1 snapshot
→ Material issue execution
→ Material receipt confirmation
→ PREPROCESSING
→ FREEZING
→ FREEZE_DRYING
→ Batch create
→ Packaging level 1
→ Packaging level 2 + GTIN/QR
→ Finished goods QC
→ Batch release
→ Warehouse receipt
→ Inventory ledger / lot balance
→ Trace / recall / MISA sync
```

## 6. Business Rules Ưu Tiên

| Rule | Nội dung |
| --- | --- |
| BR-001 | An toàn thực phẩm và recall readiness ưu tiên hơn tốc độ thao tác. |
| BR-002 | Raw material lot phải có QC trước khi issue. |
| BR-003 | Production order phải snapshot recipe version; không đọc live recipe để suy ra lịch sử. |
| BR-004 | Không issue material ngoài snapshot, trừ exception flow được owner duyệt ở tài liệu chi tiết. |
| BR-005 | Material Receipt Confirmation không giảm tồn kho lần hai. |
| BR-006 | Production output không tự thành inventory. |
| BR-007 | Packaging/printing không tự release batch. |
| BR-008 | Warehouse receipt không nhận batch chưa `RELEASED`. |
| BR-009 | Public trace không expose dữ liệu nội bộ. |
| BR-010 | Recall phải reuse traceability chain, không tạo dữ liệu trace song song. |
| BR-011 | MISA không điều khiển business truth của Operational. |

## 7. Owner Decisions Đã Đưa Vào Nền

Các quyết định owner đã được ghi ở [09_CONFLICT_AND_OWNER_DECISIONS.md](09_CONFLICT_AND_OWNER_DECISIONS.md) và được dùng trong Part 2:

- `ING_THIT_HEO_NAC` là ingredient riêng theo lot.
- Multi-warehouse theo `warehouse_type`: `RAW_MATERIAL`, `FINISHED_GOODS`.
- GTIN dùng fake fixture cho dev khi chưa có GTIN thật.
- MISA AMIS, retry 3x exponential backoff.
- Public trace expose source zone ở mức `source_zone_name`, `province`, `ward`, `address_detail`.
- Mobile/PWA-first.
- Source origin verification policy là block.
- Recall business SLA: phát hiện → khóa batch + gửi notification < 4 giờ.
- Operator auth phase 1: local account + RBAC, SSO mapping nếu có.
- `SELF_GROWN` vs `PURCHASED`.
- Sản xuất bắt buộc `PREPROCESSING → FREEZING → FREEZE_DRYING`.
- 20 SKU/G1 là baseline, không phải giới hạn vĩnh viễn.

