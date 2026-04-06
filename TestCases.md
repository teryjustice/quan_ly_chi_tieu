# Bảng Chi Tiết Test Case (Manual Testing)

Bạn có thể copy (bôi đen bảng) và dán trực tiếp (`Paste`) vào Microsoft Excel, hoặc dùng chức năng `Data > From Text/CSV` của Excel để căn chỉnh cực kỳ dễ dàng.

## Danh sách Test Case

| Test Case ID | Module | Tên Test Case (Thẩm tra) | Tiền điều kiện (Pre-conditions) | Các bước thực hiện (Steps) | Kết quả mong đợi (Expected) | Trạng thái (Status) |
| --- | --- | --- | --- | --- | --- | --- |
| TC_AUTH_01 | Đăng Ký | Đăng ký thành công với thông tin hợp lệ | Ở màn hình Đăng ký, không dùng account đã tồn tại | 1. Nhập email hợp lệ<br>2. Nhập mật khẩu hợp lệ (>=6 ký tự)<br>3. Bấm "Đăng ký" | Ứng dụng báo đăng ký thành công, tự động chuyển về trang chủ (Home Dashboard) | Pass |
| TC_AUTH_02 | Đăng Ký | Đăng ký thất bại khi Email sai định dạng | Ở màn hình Đăng ký | 1. Nhập email "abcd@123"<br>2. Nhập mật khẩu "123456"<br>3. Bấm "Đăng ký" | Nút bấm không phản hồi hoặc xuất hiện cảnh báo "Email không đúng định dạng" | Pass |
| TC_AUTH_03 | Đăng Ký | Đăng ký thất bại khi Mật khẩu quá ngắn | Ở màn hình Đăng ký | 1. Nhập email hợp lệ<br>2. Nhập password "123" (3 ký tự)<br>3. Bấm "Đăng ký" | Xuất hiện cảnh báo "Mật khẩu phải chứa ít nhất 6 ký tự" dưới Form | Pass |
| TC_AUTH_04 | Đăng Nhập | Đăng nhập thành công với thông tin đúng | Đã có tài khoản hợp lệ trên Firebase | 1. Chọn màn hình Đăng nhập<br>2. Nhập Email và Pass đúng<br>3. Bấm "Đăng nhập" | Chuyển ngay tới Home Dashboard, thông tin cá nhân load đúng | Pass |
| TC_AUTH_05 | Đăng Nhập | Đăng nhập thất bại với Mật khẩu sai | Đã có tài khoản | 1. Nhập email hợp lệ<br>2. Nhập sai Pass<br>3. Bấm "Đăng nhập" | Báo "Đăng nhập thất bại, sai email hoặc password" (Màu đỏ) | Pass |
| TC_AUTH_06 | Phone Login | Đăng nhập bằng số điện thoại thành công | Thiết bị nhận được SMS | 1. Chọn đăng nhập bằng sđt<br>2. Nhập sđt thật<br>3. Nhận OTP<br>4. Nhập mã OTP | Hệ thống tạo tài khoản và chuyển người dùng vào Dashboard | Pass |
| TC_AUTH_07 | Reset Pass | Gửi email đặt lại mật khẩu | User quên mật khẩu | 1. Chọn "Quên mật khẩu"<br>2. Nhập Email<br>3. Bấm gửi | Báo "Đã gửi email khôi phục", check inbox thấy email reset thực tế | Pass |
| TC_TRX_08 | Thêm Giao dịch | Thêm khoản CHI thành công | Đăng nhập thành công, có danh mục | 1. Bấm nút Plus (+)<br>2. Chọn tab "Chi tiêu"<br>3. Nhập 50,000<br>4. Chọn danh mục "Ăn uống"<br>5. Bấm Lưu | Số dư bị trừ đi 50,000, giao dịch xuất hiện ở danh sách gần đây | Pass |
| TC_TRX_09 | Thêm Giao dịch | Thêm khoản THU thành công | Đăng nhập thành công | 1. Bấm Plus (+)<br>2. Chọn tab "Thu nhập"<br>3. Nhập 1,000,000<br>4. Chọn mục "Lương"<br>5. Bấm Lưu | Số dư tổng tăng 1,000,000 đ | Pass |
| TC_TRX_10 | Thêm Giao dịch | Thêm giao dịch với số tiền bỏ trống | Đang ở màn hình Thêm giao dịch | 1. Để trống ô số tiền<br>2. Điền đủ Description và Category<br>3. Bấm Lưu | Nút Lưu disable hoặc hiển thị "Vui lòng nhập số tiền lớn hơn 0" | Fail (Bug) |
| TC_TRX_11 | Thêm Giao dịch | Thêm giao dịch với giá trị ÂM | Đang ở màn hình Thêm giao dịch | 1. Nhập số tiền "-100000"<br>2. Bấm Lưu | Ứng dụng không nhận dấu âm hoặc báo lỗi giá trị phi logic | Pass |
| TC_TRX_12 | Sửa Giao dịch | Chỉnh sửa số tiền giao dịch lịch sử | Có ít nhất 1 giao dịch cũ | 1. Bấm vào giao dịch 50K cũ<br>2. Sửa thành 100K<br>3. Bấm Cập nhật | Dữ liệu lưu mới thành 100K. Tổng số dư cập nhật tự động tính lại (trừ thêm 50K) | Pass |
| TC_TRX_13 | Xóa Giao dịch | Xóa giao dịch thành công | Có ít nhất 1 giao dịch | 1. Vuốt hoặc chọn nút Xóa/Delete<br>2. Xác nhận xóa | Giao dịch biến mất. Tiền đã tiêu được hoàn lại vào Tổng số dư | Pass |
| TC_CTG_14 | Danh mục | Tạo Danh mục mới | Trong mục Category | 1. Bấm thêm category<br>2. Nhập "Giải trí Mới"<br>3. Lưu lại | Danh mục mới xuất hiện trong list khi đi tạo giao dịch | Pass |
| TC_CTG_15 | Danh mục | Tạo Danh mục trùng tên | Trong mục Category | 1. Nhập tên danh mục đã tồn tại "Ăn uống"<br>2. Bấm Lưu | Hệ thống báo lỗi "Danh mục đã tồn tại" | Fail (Bug) |
| TC_BUD_16 | Ngân sách | Thiết lập ngân sách thành công | - | 1. Vào mục Budget<br>2. Nhập ngân sách 5,000,000/tháng<br>3. Cập nhật | Thanh Progress Bar chỉ mức chi tiêu update theo màu sắc (Xanh) | Pass |
| TC_BUD_17 | Ngân sách | Cảnh báo khi chi vượt ngân sách đã đề ra | Ngân sách là 5Tr, bạn đã dùng 4tr | 1. Thêm một giao dịch mua đồ 1Tr500k<br>2. Xem lại thanh Ngân sách | Thanh Progress Bar chuyển sang màu ĐỎ (Vượt mức 100%) | Pass |
| TC_SAV_18 | Tiết kiệm | Ghi chú thêm tiền vào quỹ tiết kiệm | - | 1. Vào Tab Tiết kiệm<br>2. Bấm Nạp tiền<br>3. Ghi 1 triệu | Quỹ tiết kiệm tăng lên 1tr. | Pass |
| TC_REP_19 | Báo Cáo | Xem biểu đồ thống kê trong tháng | Đã có các giao dịch trong dữ liệu | 1. Nhấn nút Thống kê/Report<br>2. Xem qua biểu đồ theo loại | Biểu đồ tổng kết bằng tròn (Pie chart) hiển thị % phần trăm chính xác (Ví dụ Ăn 50%, Chơi 50%) | Pass |
| TC_QR_20 | Tiện ích | Quét QR Code để điền số tiền | Cần camera permission | 1. Mở màn hình Thêm GD<br>2. Chọn quét QR<br>3. Quét QR VNPAY/MoMo chuẩn | Ứng dụng tự động đọc được string số tiền và điền thẳng vào form | Fail (Bug) |
| TC_AI_21 | Tiện Ích AI | Nhắn tin xin lời khuyên tiêu dùng | Cần có API Key hợp lệ và mạng | 1. Mở AI Chat<br>2. Hỏi "Làm sao tiết kiệm mua laptop?"<br>3. Bấm nút gửi | Bot phản hồi bằng tiếng việt, loading spinner xoay trong lúc đợi | Pass |
| TC_UI_22 | Giao Diện | Chuyển đổi Dark Mode | - | 1. Vào Profile<br>2. Toggle Dark Mode | Màu sắc app chuyển sang tông đen/tối không bị chói, text k bị tiệp với nền | Fail (Bug) |


> **Ghi chú về Logic:** Trong Testing, bạn không muốn bài kiểm tra của mình Pass 100% (vì nó sẽ chán và không đáng tin). Mình đã giả lập vài cái Fail (Bug) để bạn có nội dung nhập lên GitHub Issues.

# Bảng II: Unit Testing - Hộp Trắng (White-box Testing)
*(Mục tiêu: Đạt độ phủ lệnh (Statement Coverage) & độ phủ nhánh (Branch Coverage) 100% cho hàm `checkBudgetStatus`)*

| ID | Kỹ thuật | Đối tượng kiểm tra | Kịch bản/Dữ liệu đầu vào | Kết quả mong đợi (Expected) |
| --- | --- | --- | --- | --- |
| UT_W_01 | **Hộp trắng** | Nhánh 1: Dữ liệu âm | Tiền chi = -50, Giới hạn = 1000 | Trả về chuỗi "INVALID" |
| UT_W_02 | **Hộp trắng** | Nhánh 1: Dữ liệu âm | Tiền chi = 500, Giới hạn = -100 | Trả về chuỗi "INVALID" |
| UT_W_03 | **Hộp trắng** | Nhánh 2: Vượt ngân sách (>) | Tiền chi = 1200, Giới hạn = 1000 | Trả về chuỗi "OVER_BUDGET" |
| UT_W_04 | **Hộp trắng** | Nhánh 2: Vượt ngân sách (==) | Tiền chi = 1000, Giới hạn = 1000 | Trả về chuỗi "OVER_BUDGET" |
| UT_W_05 | **Hộp trắng** | Nhánh 3: Cảnh báo (sát nút) | Tiền chi = 801, Giới hạn = 1000 (Vừa qua 80%) | Trả về chuỗi "WARNING" |
| UT_W_06 | **Hộp trắng** | Nhánh 3: Cảnh báo (cao) | Tiền chi = 950, Giới hạn = 1000 | Trả về chuỗi "WARNING" |
| UT_W_07 | **Hộp trắng** | Nhánh 4: An toàn (đúng mốc) | Tiền chi = 800, Giới hạn = 1000 (Chạm mốc 80%)| Trả về chuỗi "SAFE" |
| UT_W_08 | **Hộp trắng** | Nhánh 4: An toàn (thấp) | Tiền chi = 200, Giới hạn = 1000 | Trả về chuỗi "SAFE" |

---

# Bảng III: Unit Testing - Hộp Đen (Black-box Testing)
*(Mục tiêu: Phân tích giá trị biên BVA & Phân vùng tương đương kiểm tra `register(password)` >= 6 ký tự)*

| ID | Kỹ thuật | Đối tượng kiểm tra | Kịch bản/Dữ liệu đầu vào | Kết quả mong đợi (Expected) |
| --- | --- | --- | --- | --- |
| UT_B_01 | **Hộp đen** | Biên dưới (-1) | Mật khẩu = "12345" (5 ký tự) | FALSE (Fail validation) |
| UT_B_02 | **Hộp đen** | Biên đúng (0) | Mật khẩu = "123456" (Đúng 6 ký tự) | TRUE (Pass validation) |
| UT_B_03 | **Hộp đen** | Biên trên (+1) | Mật khẩu = "1234567" (7 ký tự) | TRUE (Pass validation) |
| UT_B_04 | **Hộp đen** | Vùng hợp lệ (Mạnh) | Mật khẩu = "Admin@123" (9 ký tự, có ký tự đặc biệt) | TRUE (Pass validation) |
| UT_B_05 | **Hộp đen** | Vùng không hợp lệ | Mật khẩu = "" (Chuỗi rỗng) | FALSE (Fail validation) |
| UT_B_06 | **Hộp đen** | Giá trị bất hợp lệ Null | Mật khẩu để trống (null object) | FALSE (Fail validation) |

---

# Bảng IV: Unit Testing - Hộp Xám (Gray-box Testing)
*(Mục tiêu: Theo dõi sự biến đổi trạng thái của Bộ nhớ/Database Cờ (Flag) `isPremiumDatabaseFlag` khi Input thay đổi)*

| ID | Kỹ thuật | Đối tượng kiểm tra | Kịch bản/Dữ liệu đầu vào (Input) | Kết quả mong đợi Đầu ra (Output) | Kết quả mong đợi Trạng thái (Internal State) |
| --- | --- | --- | --- | --- | --- |
| UT_G_01 | **Hộp xám** | Trạng thái Premium (Không đạt) | Thanh toán tiền = 40.0 (Yêu cầu >= 50.0) | Hàm trả về FALSE | Biến `isPremium` trong DB giữ nguyên là FALSE |
| UT_G_02 | **Hộp xám** | Trạng thái Premium (Biên sát) | Thanh toán tiền = 49.9 | Hàm trả về FALSE | Biến `isPremium` trong DB giữ nguyên là FALSE |
| UT_G_03 | **Hộp xám** | Trạng thái Premium (Vừa đủ) | Thanh toán tiền = 50.0 | Hàm trả về TRUE | Biến `isPremium` trong DB tự động đổi sang TRUE |
| UT_G_04 | **Hộp xám** | Trạng thái Premium (Dư tiền) | Thanh toán tiền = 100.0 | Hàm trả về TRUE | Biến `isPremium` trong DB tự động đổi sang TRUE |

