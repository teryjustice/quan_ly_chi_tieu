# Báo Cáo Tracker Quản Lý Lỗi (Bug Tracking)

Trong quá trình thực thi Manual Testing ở file `TestCases.md`, chúng ta đã đánh dấu cố tình 4 Test Case thất bại (Fail) để bạn có báo cáo Bug. 
Dưới đây là chi tiết 4 lỗi đó, bạn có thể **copy dán vào bảng Excel** hoặc **tạo trực tiếp trên Bugzilla (Bugzilla Landfill)** theo đúng format dưới đây để chụp ảnh nộp báo cáo.

---

## Danh sách Lỗi (Bugs) phát hiện

### BUG 01: Không bắt lỗi khi người dùng để trống Số tiền (Transaction Amount)
- **Bug ID**: BUG_TRX_01
- **Severity (Mức độ)**: High (Nghiêm trọng - Gây lỗi sai lệch dữ liệu)
- **Status**: NEW
- **Module**: Quản lý Giao dịch (Transaction)
- **Pre-conditions**: Người dùng đang ở màn hình Thêm giao dịch (Chi tiêu).
- **Steps to reproduce (Các bước tái hiện)**:
  1. Mở màn hình Thêm giao dịch (+).
  2. Tại ô "Số tiền", không nhập bất kỳ giá trị nào (vẫn để trống).
  3. Chọn Danh mục (Category) và dán thông tin miêu tả (Description).
  4. Bấm nút "Lưu".
- **Actual Result (Thực tế)**: Hệ thống Firebase tiếp nhận giao dịch với giá trị `null` hoặc `0`, làm tính toán sai tổng tiền.
- **Expected Result (Mong đợi)**: Form không cho phép Lưu, hiển thị báo lỗi màu đỏ dưới ô Số tiền: "Vui lòng nhập số tiền hợp lệ".

---

### BUG 02: Ứng dụng bị Crash/treo khi tạo danh mục trùng tên
- **Bug ID**: BUG_CTG_02
- **Severity**: Major
- **Status**: NEW
- **Module**: Quản lý Danh mục (Category)
- **Pre-conditions**: Người dùng đã có sẵn danh mục tên "Ăn uống".
- **Steps to reproduce**:
  1. Tại màn hình Category, bấm Thêm danh mục mới.
  2. Bấm vào textbox tên, nhập chính xác chữ "Ăn uống".
  3. Bấm "Thêm".
- **Actual Result**: Ứng dụng tải (spinner) vĩnh viễn hoặc báo lỗi Exception trên màn hình do Firebase bắt duplicate key.
- **Expected Result**: Nút thêm bị Disable hoặc ứng dụng đưa ra Toast/Thông báo: "Tên danh mục này đã tồn tại, vui lòng chọn tên khác".

---

### BUG 03: Text bị trùng màu nền khi bật Dark Mode tại Tab Tiết Kiệm
- **Bug ID**: BUG_UI_03
- **Severity**: Minor (Nhẹ - Chỉ ảnh hưởng trải nghiệm)
- **Status**: NEW
- **Module**: Giao Diện Người Dùng (UI/UX)
- **Pre-conditions**: User đã bật chế độ Giao diện tối (Dark Mode) trong phần Setting hệ thống hoặc App.
- **Steps to reproduce**:
  1. Toggle Dark Mode (Bật chế độ tối).
  2. Điều hướng vào màn hình "Tiết Kiệm" (Savings).
- **Actual Result**: Số tiền tiết kiệm tổng được thiết kế cố định màu đen, làm nó tiệp màu (hoà lẫn) với nền xám đen của dark mode, nên không đọc được số.
- **Expected Result**: Chữ thống kê số tiền phải chuyển sang màu Xanh hoặc Trắng khi bật Dark Mode.

---

### BUG 04: Flow quét QR Code bị kẹt màn hình trắng
- **Bug ID**: BUG_QR_04
- **Severity**: Normal
- **Status**: NEW
- **Module**: Tiện ích (QR)
- **Pre-conditions**: Ứng dụng đã được cấp quyền sử dụng phần cứng Camera.
- **Steps to reproduce**:
  1. Ở trang tạo Giao dịch, chọn biểu tượng Quét mã QR code.
- **Actual Result**: Màn hình quét load lên với màu trắng tinh, thanh scanner chỉ tự chạy xuống nhưng không phản chiếu hình ảnh camera thưc tế. Lỗi thư viện `mobile_scanner`.
- **Expected Result**: Camera được bật và hiển thị viewfinder (ống ngắm) lấy mã QR rõ ràng.

---

### MẸO: Hướng dẫn lấy điểm tiêu chí Bug Tracking (0.5 điểm) bằng GitHub Issues
Vì source code của bạn đã nằm trên thư mục GitHub (căn cứ theo tên đường dẫn tệp), việc tận dụng chính hệ thống **GitHub Issues** để báo cáo lỗi sẽ cực kỳ tiện lợi, nhanh chóng mà vẫn được đánh giá cao về tính thực tế (được đa số các dự án mã nguồn mở sử dụng).

**Các bước thực hiện nhanh:**
1. Lên trang GitHub của bạn và mở kho lưu trữ (repository) dự án `quan_ly_chi_tieu`.
2. Bấm vào tab **Issues** (nằm ngang hàng với chữ Code, Pull requests...).
3. Bấm nút màu xanh lá **"New issue"**.
4. Viết **Title** và copy/paste **Description** (trong đó gán các yếu tố như Steps to reproduce, Actual Result từ BUG 01 -> BUG 04 phía trên).
5. Ở thanh công cụ bên phải (Labels), bạn hãy gắn nhãn (label) là `bug`. 
6. Bấm **"Submit new issue"**.
7. Chụp màn hình issue vừa tạo chèn vào báo cáo là xong! Rất đơn giản.

