# ĐẶC TẢ NGHIỆP VỤ
## Supplier Collaboration Extension for Raw Material Receipt
### Luồng nhà cung cấp tham gia phiếu nguyên liệu đầu vào

---

## 1. Mục tiêu nghiệp vụ

Hệ thống cần mở rộng nghiệp vụ **Raw Material Receipt / Phiếu nguyên liệu đầu vào** để cho phép nhà cung cấp tham gia trực tiếp vào quy trình mua ngoài.

Thay vì chỉ để nhân viên công ty nhập phiếu khi hàng đã về, hệ thống cho phép:

- công ty tạo phiếu trước cho nhà cung cấp;
- nhà cung cấp đăng nhập vào Supplier Portal để xác nhận phiếu;
- nhà cung cấp bổ sung hình ảnh/video/tài liệu minh chứng hàng hóa trước khi giao;
- hoặc nhà cung cấp tự tạo phiếu giao nguyên liệu;
- công ty nhận hàng thực tế;
- công ty QC;
- phần đạt mới tạo raw material lot;
- raw lot sau đó vẫn phải đi qua QC/mark-ready để thành `READY_FOR_PRODUCTION` trước khi cấp phát sản xuất.

Nguyên tắc quan trọng:

```text
Raw Material Receipt có thể được tạo trước khi hàng đến.
Raw Material Lot chỉ được tạo sau khi công ty xác nhận đã nhận hàng thực tế.
```

---

## 2. Phạm vi áp dụng

| Loại nguyên liệu | Cách xử lý |
|---|---|
| Nguyên liệu tự trồng | Công ty tạo Raw Material Receipt, chọn `procurement_type = SELF_GROWN`, chọn source origin/vùng trồng. |
| Nguyên liệu mua ngoài | Công ty hoặc nhà cung cấp tạo Raw Material Receipt, chọn hoặc set cứng `procurement_type = PURCHASED`, gắn supplier. |
| Nguyên liệu mua ngoài do supplier tạo | Supplier tạo phiếu qua Supplier Portal, chỉ chọn nguyên liệu được công ty gán. |
| Nguyên liệu mua ngoài do công ty tạo trước | Công ty tạo phiếu trước, supplier phải đăng nhập xác nhận và upload evidence trước khi giao. |

---

## 3. Tư duy mô hình nghiệp vụ mới

### 3.1. Không tạo bảng nghiệp vụ song song

Không tạo nghiệp vụ riêng kiểu:

```text
Supplier Delivery
```

nếu nó chỉ đại diện cho phiếu giao nguyên liệu.

Thay vào đó, dùng chung:

```text
op_raw_material_receipt
op_raw_material_receipt_item
```

và bổ sung các trường/trạng thái phục vụ supplier collaboration.

Lý do:

| Lý do | Giải thích |
|---|---|
| Tránh duplicate truth | Không để `supplier_delivery` và `raw_material_receipt` cùng mô tả một phiếu nguyên liệu. |
| Đúng module owner | M06 Raw Material vẫn là owner của luồng nguyên liệu đầu vào. |
| Dễ nối với lot/QC | Receipt item là nguồn tạo raw material lot sau khi công ty nhận hàng. |
| Dễ trace | Trace đi từ receipt → item → lot → QC → material issue. |
| Dễ dùng chung cho tự trồng và mua ngoài | Chỉ khác `procurement_type`, supplier/source origin và quyền thao tác. |

---

## 4. Khái niệm nghiệp vụ

### 4.1. Raw Material Receipt

Là **phiếu nguyên liệu đầu vào thống nhất**.

Phiếu này có thể ở nhiều giai đoạn:

1. Phiếu dự kiến / chờ supplier xác nhận.
2. Phiếu chờ giao hàng.
3. Phiếu công ty đã nhận hàng.
4. Phiếu chờ QC.
5. Phiếu đã nhận toàn bộ / nhận một phần / từ chối / trả hàng.
6. Phiếu đóng hồ sơ.

### 4.2. Raw Material Receipt Item

Là dòng nguyên liệu trong phiếu.

Mỗi dòng thể hiện:

- nguyên liệu nào;
- số lượng supplier/công ty khai báo;
- UOM;
- supplier lot code nếu có;
- số lượng công ty thực nhận;
- số lượng đạt;
- số lượng không đạt;
- số lượng trả;
- lý do không đạt.

### 4.3. Raw Material Lot

Là lot nguyên liệu thật được hệ thống ghi nhận sau khi công ty xác nhận đã nhận hàng.

Raw Material Lot **không được tạo** khi supplier chỉ mới khai báo phiếu.

### 4.4. Supplier Portal

Là giao diện riêng cho nhà cung cấp.

Nhà cung cấp chỉ thấy:

- phiếu nguyên liệu liên quan đến chính supplier đó;
- nguyên liệu được công ty cho phép cung cấp;
- trạng thái xử lý phiếu;
- ghi chú/phản hồi từ công ty;
- hình ảnh/video/tài liệu do họ hoặc công ty đính kèm.

---

## 5. Vai trò tham gia

| Vai trò | Bên | Quyền/trách nhiệm |
|---|---|---|
| Admin công ty | Công ty | Tạo supplier, tạo account supplier, reset mật khẩu, khóa/mở tài khoản. |
| Kế toán/Account | Công ty | Có thể tạo phiếu mua ngoài trước cho supplier; theo dõi phiếu. |
| Supplier Manager | Công ty | Gán nguyên liệu supplier được phép cung cấp. |
| Kho nguyên liệu | Công ty | Xác nhận hàng đến, nhập số lượng thực nhận, tạo receipt actual. |
| QC/QA | Công ty | Kiểm hàng, ghi đạt/không đạt, đính kèm ảnh/video lỗi. |
| Nhà cung cấp | Supplier | Đăng nhập portal, tạo/xác nhận phiếu, upload evidence, theo dõi trạng thái. |
| Quản lý vận hành | Công ty | Theo dõi, xử lý exception, nhận một phần/trả hàng/hủy phiếu. |

---

## 6. Phân quyền nhà cung cấp

### 6.1. Supplier user là external user

Nhà cung cấp có account nhưng không phải nhân viên nội bộ.

Nên có:

```text
user_type = SUPPLIER_USER
```

hoặc role:

```text
R_SUPPLIER
```

### 6.2. Supplier chỉ thấy dữ liệu của mình

Hard lock:

```text
HL-SUP-001
Supplier user chỉ được xem và thao tác Raw Material Receipt có supplier_id thuộc supplier của chính họ.
```

Nhà cung cấp không được thấy:

- supplier khác;
- tồn kho;
- giá/costing nội bộ;
- công thức G1/G2/G3;
- batch sản xuất;
- MISA;
- trace nội bộ;
- QC internal note không được công bố;
- dữ liệu khách hàng/order/shipment.

### 6.3. Supplier chỉ được chọn nguyên liệu được công ty gán

Cần mapping:

```text
supplier_id → ingredient_id
```

Hard lock:

```text
HL-SUP-002
Supplier chỉ được tạo hoặc cập nhật receipt item với ingredient đã được công ty gán quyền cung cấp.
```

---

## 7. Quản lý tài khoản nhà cung cấp

### 7.1. Công ty tạo account cho supplier

Công ty quản lý:

- supplier master;
- tài khoản supplier;
- người liên hệ;
- nguyên liệu supplier được cung cấp;
- trạng thái account;
- reset mật khẩu;
- khóa/mở account.

### 7.2. Chính sách mật khẩu

Không nên cho xem lại mật khẩu thật.

Quy tắc:

| Tình huống | Cách xử lý |
|---|---|
| Tạo account mới | Hệ thống sinh mật khẩu tạm. |
| Hiển thị mật khẩu | Chỉ hiển thị một lần khi tạo/reset. |
| Xem lại mật khẩu cũ | Không cho phép. |
| Supplier quên mật khẩu | Admin reset mật khẩu mới. |
| Lưu mật khẩu | Hash, không lưu plaintext. |

Hard lock:

```text
HL-SUP-008
Supplier password không được lưu plaintext. Admin chỉ được thấy mật khẩu tạm một lần khi tạo/reset.
```

---

## 8. Hai luồng tạo phiếu

## 8.1. Luồng A — Supplier tự tạo phiếu

### Diễn giải

Nhà cung cấp đăng nhập Supplier Portal và tự tạo Raw Material Receipt cho nguyên liệu mua ngoài.

### Luồng

```text
Supplier đăng nhập
→ Tạo Raw Material Receipt
→ procurement_type được set cứng PURCHASED
→ supplier_id set cứng theo account
→ Chọn nguyên liệu được phép cung cấp
→ Nhập số lượng dự kiến và UOM
→ Nhập ngày dự kiến giao
→ Upload hình ảnh/video/tài liệu
→ Submit phiếu cho công ty
→ Công ty review
→ Chờ giao hàng
→ Công ty nhận hàng
→ QC
→ Nhận / nhận một phần / từ chối / trả hàng
```

### Trạng thái

Khi supplier tạo nháp:

```text
DRAFT
```

Khi supplier gửi:

```text
SUPPLIER_SUBMITTED
```

Tên hiển thị:

| Bên xem | Hiển thị |
|---|---|
| Supplier | Đã gửi cho công ty |
| Công ty | Nhà cung cấp đã gửi phiếu |

---

## 8.2. Luồng B — Công ty tạo phiếu trước

### Diễn giải

Công ty tạo Raw Material Receipt trước cho supplier. Phiếu này tự động hiển thị trong Supplier Portal. Supplier bắt buộc đăng nhập để xác nhận và upload evidence trước khi giao.

### Luồng

```text
Công ty tạo Raw Material Receipt
→ procurement_type = PURCHASED
→ chọn supplier
→ nhập dòng nguyên liệu/số lượng dự kiến nếu có
→ trạng thái: chờ supplier xác nhận
→ Supplier đăng nhập
→ Supplier kiểm tra phiếu
→ Supplier upload hình ảnh/video/tài liệu minh chứng
→ Supplier xác nhận sẽ giao
→ Phiếu chuyển sang chờ giao hàng
→ Hàng đến công ty
→ Công ty nhận hàng
→ QC
→ Nhận / nhận một phần / từ chối / trả hàng
```

### Trạng thái khi công ty tạo phiếu trước

```text
COMPANY_CREATED_PENDING_SUPPLIER_CONFIRMATION
```

Tên hiển thị:

| Bên xem | Hiển thị |
|---|---|
| Công ty | Đã tạo phiếu - chờ nhà cung cấp xác nhận |
| Supplier | Công ty đã tạo phiếu - vui lòng xác nhận |

### Nếu supplier chưa upload đủ evidence

```text
SUPPLIER_EVIDENCE_REQUIRED
```

Tên hiển thị:

| Bên xem | Hiển thị |
|---|---|
| Công ty | Chờ nhà cung cấp bổ sung minh chứng |
| Supplier | Cần bổ sung hình ảnh/video/tài liệu trước khi giao |

### Khi supplier xác nhận đủ

```text
SUPPLIER_CONFIRMED_WAITING_DELIVERY
```

Tên hiển thị:

| Bên xem | Hiển thị |
|---|---|
| Công ty | Nhà cung cấp đã xác nhận - chờ giao hàng |
| Supplier | Đã xác nhận - chờ giao hàng |

Hard lock:

```text
HL-SUP-005
Phiếu do công ty tạo trước không được chuyển sang WAITING_DELIVERY nếu supplier chưa xác nhận và chưa upload đủ evidence bắt buộc.
```

---

## 9. Trạng thái đề xuất cho Raw Material Receipt

Nên tách thành hai nhóm trạng thái để không làm `receipt_status` quá tải.

### 9.1. `receipt_status`

Dùng cho trạng thái nhận hàng thực tế:

```text
DRAFT
WAITING_DELIVERY
DELIVERED_PENDING_RECEIPT
RECEIVED_PENDING_QC
QC_IN_PROGRESS
ACCEPTED
PARTIALLY_ACCEPTED
REJECTED
RETURNED
CANCELLED
CLOSED
```

| Trạng thái | Ý nghĩa |
|---|---|
| `DRAFT` | Phiếu nháp. |
| `WAITING_DELIVERY` | Đã đủ điều kiện chờ giao hàng. |
| `DELIVERED_PENDING_RECEIPT` | Hàng đã báo giao/đến nơi, chờ công ty xác nhận. |
| `RECEIVED_PENDING_QC` | Công ty đã nhận hàng vật lý, chờ QC. |
| `QC_IN_PROGRESS` | Công ty đang QC. |
| `ACCEPTED` | Nhận toàn bộ. |
| `PARTIALLY_ACCEPTED` | Nhận một phần. |
| `REJECTED` | Không nhận. |
| `RETURNED` | Đã/đang trả hàng. |
| `CANCELLED` | Đã hủy. |
| `CLOSED` | Hồ sơ hoàn tất. |

### 9.2. `supplier_collaboration_status`

Dùng cho luồng supplier portal:

```text
NOT_REQUIRED
PENDING_SUPPLIER_CONFIRMATION
EVIDENCE_REQUIRED
SUPPLIER_SUBMITTED
SUPPLIER_CONFIRMED
SUPPLIER_CANCELLED
```

| Trạng thái | Ý nghĩa |
|---|---|
| `NOT_REQUIRED` | Không cần supplier xác nhận, thường là `SELF_GROWN`. |
| `PENDING_SUPPLIER_CONFIRMATION` | Công ty tạo phiếu, chờ supplier xác nhận. |
| `EVIDENCE_REQUIRED` | Supplier cần bổ sung evidence. |
| `SUPPLIER_SUBMITTED` | Supplier tự tạo/gửi phiếu. |
| `SUPPLIER_CONFIRMED` | Supplier đã xác nhận phiếu. |
| `SUPPLIER_CANCELLED` | Supplier hủy/từ chối phiếu nếu policy cho phép. |

### 9.3. Vì sao nên tách hai trạng thái?

| Lý do | Giải thích |
|---|---|
| Dễ hiểu nghiệp vụ | Receipt status thể hiện hàng đến đâu; supplier status thể hiện tương tác supplier. |
| Áp dụng được cho self-grown | Self-grown không cần supplier collaboration, set `NOT_REQUIRED`. |
| Tránh enum quá dài | Không dồn mọi trạng thái vào một field duy nhất. |
| Dễ làm UI filter | Công ty có thể lọc theo “chờ supplier xác nhận” hoặc “chờ QC”. |

---

## 10. Thông tin trên Raw Material Receipt

### 10.1. Header phiếu

Cần bổ sung/duy trì các trường:

| Trường | Ý nghĩa |
|---|---|
| `receipt_no` | Mã phiếu. |
| `procurement_type` | `SELF_GROWN` hoặc `PURCHASED`. |
| `supplier_id` | Bắt buộc nếu `PURCHASED`. |
| `source_origin_id` | Bắt buộc nếu `SELF_GROWN` theo policy. |
| `warehouse_id` | Có thể chưa có khi pre-receipt, bắt buộc khi company receive. |
| `created_by_party` | `COMPANY` hoặc `SUPPLIER`. |
| `created_by_user_id` | Người tạo. |
| `purchase_request_ref` | Mã phiếu đề xuất mua hàng bên ngoài nếu có. |
| `expected_delivery_date` | Ngày dự kiến giao. |
| `delivered_at` | Thời điểm báo giao/đến. |
| `received_at` | Thời điểm công ty xác nhận nhận. |
| `received_by` | Người nhận. |
| `receipt_status` | Trạng thái nhận hàng. |
| `supplier_collaboration_status` | Trạng thái tương tác supplier. |
| `evidence_required_flag` | Có bắt buộc evidence không. |
| `evidence_status` | Trạng thái evidence. |
| `supplier_note` | Ghi chú supplier. |
| `company_note` | Ghi chú công ty. |
| `closed_at` | Ngày đóng. |
| `cancel_reason` | Lý do hủy nếu có. |

### 10.2. Dòng phiếu `op_raw_material_receipt_item`

| Trường | Ý nghĩa |
|---|---|
| `ingredient_id` | Nguyên liệu. |
| `proposed_quantity` | Số lượng supplier/công ty khai báo ban đầu. |
| `proposed_uom_code` | UOM khai báo. |
| `received_quantity` | Số lượng công ty thực nhận. |
| `accepted_quantity` | Số lượng đạt. |
| `rejected_quantity` | Số lượng không đạt. |
| `returned_quantity` | Số lượng trả. |
| `uom_code` | UOM chuẩn ghi nhận. |
| `supplier_lot_code` | Mã lô bên supplier nếu có. |
| `manufacture_date` | Ngày sản xuất/thu hoạch nếu có. |
| `expiry_date` | Hạn dùng nếu có. |
| `line_status` | Trạng thái từng dòng. |
| `rejection_reason` | Lý do không đạt. |
| `notes` | Ghi chú. |

---

## 11. Evidence cho phiếu

### 11.1. Bảng evidence đề xuất

```text
op_raw_material_receipt_evidence
```

| Trường | Ý nghĩa |
|---|---|
| `evidence_id` | ID evidence. |
| `raw_material_receipt_id` | Gắn với phiếu. |
| `raw_material_receipt_item_id` | Gắn với dòng nếu có. |
| `uploaded_by_party` | `COMPANY` hoặc `SUPPLIER`. |
| `evidence_type` | PHOTO, VIDEO, COA, LAB_REPORT, DELIVERY_DOC, DAMAGE_PHOTO, OTHER. |
| `evidence_uri` | Đường dẫn file. |
| `evidence_hash` | Hash file. |
| `mime_type` | Loại file. |
| `file_size_bytes` | Dung lượng. |
| `original_filename` | Tên file gốc. |
| `storage_provider` | LOCAL_FS hoặc COMPANY_FILE_SERVER. |
| `scan_status` | Trạng thái scan nếu có. |
| `evidence_status` | ACTIVE hoặc VOID. |
| `note` | Ghi chú. |
| `uploaded_by` | Người upload. |
| `uploaded_at` | Thời điểm upload. |

### 11.2. Evidence supplier upload trước khi giao

Supplier có thể/bắt buộc upload:

- ảnh hàng hóa;
- video hàng hóa;
- COA;
- lab report;
- giấy chứng nhận;
- delivery document;
- ghi chú.

### 11.3. Evidence công ty upload khi nhận/QC

Công ty có thể upload:

- ảnh hàng khi nhận;
- ảnh bao bì hư hỏng;
- video mở hàng/kiểm hàng;
- ảnh nguyên liệu không đạt;
- biên bản QC;
- biên bản trả hàng.

---

## 12. Khi nào tạo Raw Material Lot?

### 12.1. Không tạo lot ở giai đoạn supplier/công ty mới tạo phiếu

Không tạo lot khi phiếu ở các trạng thái:

```text
DRAFT
PENDING_SUPPLIER_CONFIRMATION
EVIDENCE_REQUIRED
SUPPLIER_SUBMITTED
SUPPLIER_CONFIRMED
WAITING_DELIVERY
DELIVERED_PENDING_RECEIPT
```

### 12.2. Tạo lot khi công ty xác nhận nhận hàng

Khi công ty chuyển phiếu sang:

```text
RECEIVED_PENDING_QC
```

hệ thống có thể tạo `op_raw_material_lot` cho phần hàng được công ty xác nhận đã nhận thực tế.

Lot tạo ra ở trạng thái:

```text
PENDING_QC
```

hoặc:

```text
IN_QC
```

tùy enum cuối cùng.

### 12.3. Nếu nhận một phần

Nếu supplier giao 100kg nhưng công ty chỉ nhận 80kg:

```text
proposed_quantity = 100kg
received_quantity = 100kg
accepted_quantity = 80kg
rejected_quantity = 20kg
```

Chỉ phần đủ điều kiện mới tạo lot để đi tiếp.

Nếu QC reject toàn bộ:

```text
Không tạo lot usable cho sản xuất.
```

Nếu đã tạo lot để QC rồi reject, lot phải ở trạng thái reject/hold, không được cấp phát.

---

## 13. QC và mark-ready sau khi nhận hàng

Raw Material Receipt không thay thế QC/mark-ready.

Luồng vẫn giữ:

```text
Company Receive
→ Create Raw Material Lot
→ Incoming QC
→ QC_PASS / QC_HOLD / QC_REJECT
→ RAW_LOT_MARK_READY
→ READY_FOR_PRODUCTION
→ Material Issue
```

Hard lock giữ nguyên:

```text
QC_PASS chưa đủ để cấp phát.
Chỉ lot_status = READY_FOR_PRODUCTION mới được material issue.
```

---

## 14. Supplier Portal form

Supplier dùng form cùng nghiệp vụ Raw Material Receipt nhưng bị khóa trường.

| Trường | Supplier được thao tác? | Ghi chú |
|---|---:|---|
| `procurement_type` | Không | Set cứng `PURCHASED`. |
| `supplier_id` | Không | Set theo account. |
| `ingredient_id` | Có giới hạn | Chỉ chọn ingredient được công ty gán. |
| `proposed_quantity` | Có | Số lượng dự kiến giao. |
| `proposed_uom_code` | Có | Theo UOM cho phép. |
| `expected_delivery_date` | Có | Ngày dự kiến giao. |
| `supplier_lot_code` | Có | Nếu có. |
| `manufacture_date` | Có | Nếu có. |
| `expiry_date` | Có | Nếu có. |
| `supplier_note` | Có | Ghi chú. |
| `evidence` | Có/bắt buộc | Theo policy. |
| `received_quantity` | Không | Công ty nhập. |
| `accepted_quantity` | Không | QC/công ty nhập. |
| `rejected_quantity` | Không | QC/công ty nhập. |
| `qc_result` | Không | Công ty/QC xử lý. |
| `warehouse_id` | Không hoặc chỉ xem | Công ty xử lý. |
| `raw_material_lot_code` | Không | Hệ thống/công ty tạo sau receive. |

---

## 15. Admin Web form phía công ty

Công ty dùng cùng Raw Material Receipt nhưng có quyền rộng hơn.

| Chức năng | Mô tả |
|---|---|
| Tạo phiếu tự trồng | `procurement_type = SELF_GROWN`, chọn source origin. |
| Tạo phiếu mua ngoài | `procurement_type = PURCHASED`, chọn supplier. |
| Tạo phiếu trước cho supplier | Supplier vào xác nhận/evidence. |
| Review phiếu supplier gửi | Xem evidence, note, line item. |
| Yêu cầu bổ sung evidence | Chuyển supplier collaboration status về `EVIDENCE_REQUIRED`. |
| Xác nhận nhận hàng | Nhập số lượng thực nhận. |
| Start QC | Chuyển sang QC. |
| Ghi kết quả QC | Nhận toàn bộ/nhận một phần/từ chối/trả hàng. |
| Tạo lot | Chỉ từ phần hàng được nhận/QC theo policy. |
| Gửi phản hồi supplier | Ghi chú, ảnh/video, lý do reject/return. |

---

## 16. API route family đề xuất

### 16.1. Admin API

Dùng canonical route raw material:

```text
GET  /api/admin/raw-material/intakes
POST /api/admin/raw-material/intakes
GET  /api/admin/raw-material/intakes/{receiptId}
PUT  /api/admin/raw-material/intakes/{receiptId}
POST /api/admin/raw-material/intakes/{receiptId}/submit
POST /api/admin/raw-material/intakes/{receiptId}/request-supplier-evidence
POST /api/admin/raw-material/intakes/{receiptId}/supplier-confirmation
POST /api/admin/raw-material/intakes/{receiptId}/receive
POST /api/admin/raw-material/intakes/{receiptId}/start-qc
POST /api/admin/raw-material/intakes/{receiptId}/qc-result
POST /api/admin/raw-material/intakes/{receiptId}/return
POST /api/admin/raw-material/intakes/{receiptId}/cancel
POST /api/admin/raw-material/intakes/{receiptId}/evidence
```

### 16.2. Supplier API

Nên tách route supplier để rõ security boundary:

```text
GET  /api/supplier/raw-material/intakes
POST /api/supplier/raw-material/intakes
GET  /api/supplier/raw-material/intakes/{receiptId}
PUT  /api/supplier/raw-material/intakes/{receiptId}
POST /api/supplier/raw-material/intakes/{receiptId}/submit
POST /api/supplier/raw-material/intakes/{receiptId}/confirm
POST /api/supplier/raw-material/intakes/{receiptId}/evidence
POST /api/supplier/raw-material/intakes/{receiptId}/cancel
```

Supplier API vẫn thao tác cùng bảng `op_raw_material_receipt`, nhưng luôn scope theo `supplier_id` của account.

---

## 17. Feedback cho supplier

Có thể dùng bảng riêng:

```text
op_raw_material_receipt_feedback
```

Trường đề xuất:

| Trường | Ý nghĩa |
|---|---|
| `feedback_id` | ID. |
| `raw_material_receipt_id` | Phiếu. |
| `raw_material_receipt_item_id` | Dòng nếu có. |
| `feedback_type` | COMPANY_NOTE, QC_REJECT_REASON, RETURN_NOTE, DAMAGE_EVIDENCE. |
| `note` | Nội dung. |
| `visible_to_supplier` | Có hiển thị cho supplier không. |
| `created_by` | Người tạo. |
| `created_at` | Thời điểm. |

Nếu không muốn thêm bảng MVP, có thể dùng `company_note` + evidence. Nhưng về lâu dài, bảng feedback sẽ rõ hơn.

---

## 18. Supplier nhìn thấy gì?

Supplier Portal list nên hiển thị:

| Cột | Ý nghĩa |
|---|---|
| Mã phiếu | Receipt no. |
| Trạng thái | Đã gửi, chờ xác nhận, chờ giao, đã nhận, đang QC, đã nhận, trả hàng. |
| Ngày dự kiến giao | Expected delivery date. |
| Nguyên liệu | Các dòng nguyên liệu. |
| Số lượng khai báo | Proposed quantity. |
| Số lượng công ty nhận | Received quantity. |
| Số lượng đạt | Accepted quantity. |
| Số lượng không đạt | Rejected quantity. |
| Lý do không đạt | Nếu có. |
| Ghi chú công ty | Nếu visible. |
| Evidence công ty | Nếu visible. |
| Cập nhật cuối | Last updated. |

---

## 19. Company nhìn thấy gì?

Admin Web Raw Material Intake nên có filter:

| Filter | Ý nghĩa |
|---|---|
| Tất cả phiếu | All. |
| Tự trồng | `procurement_type = SELF_GROWN`. |
| Mua ngoài | `procurement_type = PURCHASED`. |
| Chờ supplier xác nhận | `supplier_collaboration_status = PENDING_SUPPLIER_CONFIRMATION`. |
| Chờ supplier bổ sung evidence | `supplier_collaboration_status = EVIDENCE_REQUIRED`. |
| Supplier đã gửi | `supplier_collaboration_status = SUPPLIER_SUBMITTED`. |
| Chờ giao hàng | `receipt_status = WAITING_DELIVERY`. |
| Đã nhận - chờ QC | `receipt_status = RECEIVED_PENDING_QC`. |
| Đang QC | `receipt_status = QC_IN_PROGRESS`. |
| Nhận một phần/trả hàng | `PARTIALLY_ACCEPTED`, `RETURNED`. |

---

## 20. State transition đề xuất

### 20.1. Supplier tự tạo

```text
DRAFT
→ SUPPLIER_SUBMITTED
→ COMPANY_REVIEWING
→ WAITING_DELIVERY
→ DELIVERED_PENDING_RECEIPT
→ RECEIVED_PENDING_QC
→ QC_IN_PROGRESS
→ ACCEPTED / PARTIALLY_ACCEPTED / REJECTED
→ RETURNED nếu có
→ CLOSED
```

### 20.2. Công ty tạo trước

```text
DRAFT
→ PENDING_SUPPLIER_CONFIRMATION
→ EVIDENCE_REQUIRED nếu thiếu evidence
→ SUPPLIER_CONFIRMED
→ WAITING_DELIVERY
→ DELIVERED_PENDING_RECEIPT
→ RECEIVED_PENDING_QC
→ QC_IN_PROGRESS
→ ACCEPTED / PARTIALLY_ACCEPTED / REJECTED
→ RETURNED nếu có
→ CLOSED
```

### 20.3. Tự trồng

```text
DRAFT
→ WAITING_DELIVERY hoặc RECEIVED_PENDING_QC
→ QC_IN_PROGRESS
→ ACCEPTED / PARTIALLY_ACCEPTED / REJECTED
→ CLOSED
```

Với tự trồng:

```text
supplier_collaboration_status = NOT_REQUIRED
```

---

## 21. Hard locks mới

```text
HL-SUP-001
Supplier user chỉ thấy Raw Material Receipt thuộc supplier_id của mình.

HL-SUP-002
Supplier chỉ được chọn ingredient được công ty gán.

HL-SUP-003
Supplier hoặc công ty tạo Raw Material Receipt trước không tạo raw material lot usable.

HL-SUP-004
Raw material lot chỉ được tạo sau khi công ty xác nhận nhận hàng thực tế.

HL-SUP-005
Company-created purchased receipt phải được supplier xác nhận và upload evidence bắt buộc trước khi chuyển WAITING_DELIVERY.

HL-SUP-006
Evidence không lưu blob trong PostgreSQL.

HL-SUP-007
Supplier không được thấy cost, inventory, formula, MISA, internal trace, supplier khác.

HL-SUP-008
Supplier password không lưu plaintext; chỉ hiển thị mật khẩu tạm một lần khi tạo/reset.

HL-SUP-009
Supplier-created receipt luôn set procurement_type = PURCHASED và supplier_id theo account, không cho supplier tự đổi.

HL-SUP-010
Phần nguyên liệu bị rejected/returned không được tạo lot usable cho sản xuất.
```

---

## 22. Acceptance criteria

| AC | Tiêu chí |
|---|---|
| AC-SUP-001 | Công ty tạo được supplier account. |
| AC-SUP-002 | Supplier login chỉ thấy phiếu của chính supplier đó. |
| AC-SUP-003 | Supplier chỉ chọn được ingredient được gán. |
| AC-SUP-004 | Supplier tự tạo Raw Material Receipt với `PURCHASED`. |
| AC-SUP-005 | Công ty tạo Raw Material Receipt trước, supplier thấy và xác nhận. |
| AC-SUP-006 | Phiếu công ty tạo trước không chuyển `WAITING_DELIVERY` nếu supplier chưa xác nhận/evidence chưa đủ. |
| AC-SUP-007 | Supplier upload ảnh/video/tài liệu vào receipt evidence. |
| AC-SUP-008 | Công ty review và yêu cầu bổ sung evidence. |
| AC-SUP-009 | Công ty xác nhận nhận hàng và nhập `received_quantity`. |
| AC-SUP-010 | Công ty QC từng dòng và ghi accepted/rejected/returned quantity. |
| AC-SUP-011 | Chỉ phần đạt mới tạo raw material lot. |
| AC-SUP-012 | Lot vẫn phải QC/mark-ready trước material issue. |
| AC-SUP-013 | Supplier thấy trạng thái, ghi chú và evidence công ty cho phép hiển thị. |
| AC-SUP-014 | Supplier không truy cập được dữ liệu nội bộ. |
| AC-SUP-015 | Audit ghi đầy đủ bên tạo phiếu, bên xác nhận, upload evidence, receive, QC, return. |

---

## 23. Tác động đến tài liệu hiện tại

Cần cập nhật các nhóm file sau:

| Nhóm | Nội dung cần cập nhật |
|---|---|
| Business | Supplier không còn là master đơn giản; purchased raw material có supplier collaboration. |
| Functional | Thêm use case supplier tạo/xác nhận Raw Material Receipt. |
| Database | Mở rộng `op_raw_material_receipt`, `op_raw_material_receipt_item`, thêm evidence/feedback/mapping supplier user/ingredient. |
| API | Mở rộng `/api/admin/raw-material/intakes`; thêm `/api/supplier/raw-material/intakes`. |
| UI | Thêm Supplier Portal và filter trong Raw Material Intake. |
| Workflow | Bổ sung pre-receipt → supplier confirm → evidence → receive → QC → lot. |
| Testing | Thêm test supplier scope, evidence required, no lot before receive, accepted quantity creates lot. |
| Dev handoff | Ghi rõ không tạo `op_supplier_delivery` riêng trong MVP. |
| AI agent | Prompt phải khóa: reuse raw material receipt, không tạo duplicate business truth. |

---

## 24. Kết luận nghiệp vụ

Chốt theo hướng mới:

> `Raw Material Receipt` là phiếu nguyên liệu đầu vào thống nhất cho cả tự trồng và mua ngoài. Với nguyên liệu mua ngoài, nhà cung cấp có thể tạo hoặc xác nhận phiếu qua Supplier Portal. Nếu công ty tạo phiếu trước, supplier bắt buộc phải đăng nhập để xác nhận và upload evidence trước khi giao. Supplier dùng cùng nghiệp vụ phiếu nhưng bị giới hạn quyền: `procurement_type = PURCHASED`, `supplier_id` theo account, chỉ chọn ingredient được công ty gán. Phiếu supplier/công ty tạo trước không tạo raw material lot usable. Raw material lot chỉ sinh sau khi công ty xác nhận nhận hàng thực tế; phần đạt QC mới đi tiếp vào quy trình QC/mark-ready và chỉ lot `READY_FOR_PRODUCTION` mới được cấp phát sản xuất.
