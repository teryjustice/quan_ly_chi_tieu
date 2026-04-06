# Báo Cáo Tracker Quản Lý Lỗi (Bug Tracking)

Dưới đây là 4 lỗi đã được lập trình sẵn và định dạng chuẩn Markdown dành riêng cho hệ thống **GitHub Issues**. 
Bạn chỉ cần mở trang GitHub của dự án, bấm nút tạo Issue đỏ/xanh, sau đó **COPY & PASTE** y hệt hai ô Tiêu đề (Title) và Mô tả (Description) dưới đây là thành công 100%!

---

## 🐞 BUG 01: Lỗi để trống số tiền
**🏷️ Title (Chép/Copy bỏ vào ô Tiêu đề):**
```text
[BUG_TRX_01] Không bắt lỗi khi người dùng để trống Số tiền lúc tạo giao dịch
```

**📝 Description (Chép toàn bộ đoạn dưới bỏ vào ô Mô tả lớn):**
```markdown
**Severity (Mức độ):** High (Nghiêm trọng - Gây lỗi dữ liệu)
**Module:** Quản lý Giao dịch (Transaction)

**Pre-conditions:**
Người dùng đang ở màn hình Thêm giao dịch (Chi tiêu).

**Steps to reproduce (Các bước tái hiện):**
1. Nhấn nút Thêm giao dịch (icon dấu +).
2. Tại trường nhập "Số tiền", bỏ qua, không nhập bất kỳ số nào.
3. Chọn Danh mục (Category) là "Ăn uống".
4. Nhấn nút "Lưu".

**Actual Result (Kết quả thực tế):**
Hệ thống Firebase chấp nhận giao dịch mang giá trị `null` hoặc tự mặc định gán lỗi. Tiền tổng bị hiển thị sai số.

**Expected Result (Kết quả kỳ vọng):**
Màn hình chặn lại không cho Lưu. Xuất hiện cảnh báo màu đỏ bên dưới ô nhập: `Vui lòng nhập số tiền hợp lệ`.
```

---

## 🐞 BUG 02: Ứng dụng Crash tạo trùng danh mục
**🏷️ Title (Chép/Copy bỏ vào ô Tiêu đề):**
```text
[BUG_CTG_02] Ứng dụng bị Crash/treo khi tạo danh mục trùng tên
```

**📝 Description (Chép toàn bộ đoạn dưới bỏ vào ô Mô tả lớn):**
```markdown
**Severity:** Major 
**Module:** Quản lý Danh mục (Category)

**Pre-conditions:**
Người dùng đã thêm thành công danh mục có tên là "Ăn uống" trước đó.

**Steps to reproduce:**
1. Tại khu vực Danh mục, nhấn nút "Thêm danh mục mới".
2. Khung Text hiển thị ra, nhập chính xác từ khóa "Ăn uống".
3. Nhấn "Bấm Lưu".

**Actual Result:**
Ứng dụng tải (spinner quay) vĩnh viễn không dừng. Báo console trên ứng dụng throw Exception Duplicate Key từ Firebase Database.

**Expected Result:**
Ứng dụng phải đưa ra Dialog Toast: `Tên danh mục này đã tồn tại, vui lòng chọn tên khác!` và giữ nguyên màn hình cũ.
```

---

## 🐞 BUG 03: Chữ thống kê bị trùng màu trong Dark Mode
**🏷️ Title (Chép/Copy bỏ vào ô Tiêu đề):**
```text
[BUG_UI_03] Chữ hiển thị tổng tiền bị tiệp với màu nền trong chế độ Dark Mode
```

**📝 Description (Chép toàn bộ đoạn dưới bỏ vào ô Mô tả lớn):**
```markdown
**Severity:** Minor (Ảnh hưởng tới UI/UX đồ họa)
**Module:** Giao Diện Người Dùng / Cài đặt

**Pre-conditions:**
Máy đã cài đặt bật tính năng Dark Mode. Cấp độ Settings thành công.

**Steps to reproduce:**
1. Mở Cài đặt máy > Bật Dark Mode.
2. Điều hướng mở App, vào màn hình "Tiết Kiệm" (Savings).
3. Nhìn vào khu vực Thống kê tổng số dư.

**Actual Result:**
Màu chữ con số dư bị cố định thành màu `Color.Black` nên khi nền Dark Mode đổi sang màu xám đen, chữ hoàn toàn bị chìm mất và không thấy gì.

**Expected Result:**
Màu text chữ phải tự chuyển sang các màu tương phản như trắng hoặc neon để nhìn thấu chữ tại chế độ nền tối.
```

---

## 🐞 BUG 04: Lỗi API quét mã QR Code bị treo màn hình trắng
**🏷️ Title (Chép/Copy bỏ vào ô Tiêu đề):**
```text
[BUG_QR_04] Flow quét hình ảnh bằng QR Code bị hiển thị màn hình trắng xóa
```

**📝 Description (Chép toàn bộ đoạn dưới bỏ vào ô Mô tả lớn):**
```markdown
**Severity:** Normal
**Module:** Tiện ích (QR Scanner)

**Pre-conditions:**
Ứng dụng đã xin quyền truy cập Camera Permission thành công ban đầu.

**Steps to reproduce:**
1. Điều hướng qua màn hình Tạo Giao Dịch tiện ích QR.
2. Bật biểu tượng Icon Scan QR Code.

**Actual Result:**
Trang màn hình tự mở khung load Scanner màu trắng tinh. Thanh quét điện tử vẫn quét nhưng back-ground ống ngắm Camera đằng sau không preview được camera vật lý hiện hữu. (Thiếu thư viện controller stream `mobile_scanner`).

**Expected Result:**
Đồng bộ mở lên là thấy ống ngắm Camera đời thực để quét Code liền tiếp nhận giá trị.
```

*(Sau khi tạo xong mỗi Issue trên trang web Github Issue, bạn hãy nhớ chụp màn hình lại và nhét 4 tấm ảnh đó vào Word nhé!)*
