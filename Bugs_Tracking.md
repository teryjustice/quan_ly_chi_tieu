# Báo Cáo Tracker Quản Lý Lỗi (Bug Tracking) - GitHub Issues

Dưới đây là 7 lỗi được phát hiện qua quá trình kiểm thử, định dạng chuẩn Markdown dành riêng cho hệ thống **GitHub Issues**. Bạn chỉ cần COPY & PASTE tiêu đề và mô tả vào GitHub.

---

## 🐞 BUG 01: Số tiền bỏ trống không báo lỗi
**🏷️ Title:** `[BUG_TRX_10] Thêm giao dịch với số tiền bỏ trống không hiển thị cảnh báo`

**📝 Description:**
```markdown
**Severity:** High (Nghiêm trọng)
**Module:** Thêm Giao Dịch (Transaction)

**Pre-conditions:** Người dùng đã đăng nhập thành công.

**Steps to reproduce:**
1. Nhấn nút (+) để thêm giao dịch.
2. Để TRỐNG ô "Số tiền".
3. Điền mô tả và chọn danh mục bất kỳ.
4. Nhấn nút "Lưu".

**Actual Result:** Giao dịch được lưu với giá trị null/0 hoặc ứng dụng không phản hồi gì, không báo lỗi.
**Expected Result:** Nút Lưu bị disable hoặc hiển thị cảnh báo "Vui lòng nhập số tiền lớn hơn 0".
```

---

## 🐞 BUG 02: Tạo danh mục trùng tên
**🏷️ Title:** `[BUG_CTG_15] Cho phép tạo danh mục trùng tên - Không báo lỗi tồn tại`

**📝 Description:**
```markdown
**Severity:** Medium
**Module:** Danh Mục (Category)

**Steps to reproduce:**
1. Vào mục Danh mục.
2. Bấm "Thêm danh mục mới".
3. Nhập tên "Ăn uống" (tên này đã có sẵn trong list).
4. Nhấn "Lưu".

**Actual Result:** Hệ thống tạo thêm một danh mục mới trùng hoàn toàn tên với danh mục cũ.
**Expected Result:** Hệ thống báo lỗi "Danh mục đã tồn tại" và không cho phép lưu trùng.
```

---

## 🐞 BUG 03: Lỗi hiển thị Dark Mode (Text bị tiệp màu)
**🏷️ Title:** `[BUG_UI_22] Các con số thống kê bị tàng hình khi bật Dark Mode`

**📝 Description:**
```markdown
**Severity:** High (Ảnh hưởng trải nghiệm người dùng)
**Module:** Giao Diện (UI/UX)

**Steps to reproduce:**
1. Vào màn hình Profile.
2. Gạt Switch "Dark Mode" sang ON.
3. Quay lại màn hình Dashboard hoặc Tiết kiệm.

**Actual Result:** Màu nền chuyển sang đen/xám tối nhưng text số dư vẫn là màu đen, khiến người dùng không đọc được số tiền.
**Expected Result:** Toàn bộ Text phải tự động chuyển sang màu trắng hoặc màu tương phản khi ở chế độ nền tối.
```

---

## 🐞 BUG 04: QR Code không parse được số tiền
**🏷️ Title:** `[BUG_QR_20] Tính năng quét QR Code không tự động điền số tiền`

**📝 Description:**
```markdown
**Severity:** Low/Medium
**Module:** Tiện ích (QR Scanner)

**Steps to reproduce:**
1. Mở màn hình Thêm giao dịch.
2. Chọn biểu tượng Quét QR.
3. Quét một mã QR chuẩn (VNPAY/MoMo).

**Actual Result:** Ứng dụng mở camera quét thành công nhưng ô "Số tiền" vẫn trống không.
**Expected Result:** Ứng dụng phải đọc được chuỗi số tiền từ mã QR và điền tự động vào form.
```

---

## 🐞 BUG 05: Tìm kiếm phân biệt hoa thường (Case Sensitive)
**🏷️ Title:** `[BUG_SRCH_05] Tính năng tìm kiếm không trả về kết quả nếu viết sai định dạng hoa thường`

**📝 Description:**
```markdown
**Severity:** Low
**Module:** Tìm kiếm (Search)

**Steps to reproduce:**
1. Có một giao dịch tên là "Ăn Uống".
2. Vào ô tìm kiếm nhập "ăn uống" (viết thường hết).

**Actual Result:** Hệ thống báo "Không tìm thấy kết quả".
**Expected Result:** Hệ thống phải trả về kết quả bất kể người dùng viết hoa hay viết thường.
```

---

## 🐞 BUG 06: Logic ngày tháng sai (Cho phép chi cho tương lai)
**🏷️ Title:** `[BUG_DATE_06] Cho phép chọn ngày tương lai cho các khoản chi tiêu`

**📝 Description:**
```markdown
**Severity:** Medium
**Module:** Date Picker

**Steps to reproduce:**
1. Vào Thêm giao dịch chi tiêu.
2. Chọn ngày giao dịch là một ngày trong tương lai (ví dụ: ngày mai).
3. Nhấn Lưu.

**Actual Result:** App vẫn cho phép lưu và trừ tiền vào số dư hiện tại.
**Expected Result:** Cảnh báo "Không thể chi tiêu cho ngày tương lai" hoặc disable các ngày tương lai trong lịch.
```

---

## 🐞 BUG 07: Ứng dụng bị Crash khi xuất PDF
**🏷️ Title:** `[BUG_RPT_07] App bị văng (Crash) ngay lập tức khi nhấn nút xuất báo cáo PDF`

**📝 Description:**
```markdown
**Severity:** Critical (Nghiêm trọng nhất)
**Module:** Báo Cáo (Report)

**Steps to reproduce:**
1. Vào màn hình Thống kê/Báo cáo.
2. Nhấn vào biểu tượng PDF (Export).

**Actual Result:** Ứng dụng dừng đột ngột và thoát ra màn hình chính của điện thoại.
**Expected Result:** Hệ thống xử lý và hiển thị thông báo "Đã xuất file PDF thành công".
```

---
*(Hãy copy từng cặp Title/Description này lên GitHub Issues của bạn để hoàn tất bài nộp!)*
