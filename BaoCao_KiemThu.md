---
title: Báo cáo Đồ án Môn học Kiểm thử Phần mềm
author: [Tên Sinh Viên]
date: [Ngày báo cáo]
---

# BÁO CÁO ĐỒ ÁN MÔN HỌC KIỂM THỬ PHẦN MỀM

**Mục tiêu báo cáo:** Mô tả toàn bộ quá trình kiểm thử phần mềm cho ứng dụng Quản lý chi tiêu (Expense Management App) theo tiêu chuẩn và kỹ thuật được hướng dẫn trong môn học, bao gồm các bước phân tích, lập kế hoạch, và thực thi kiểm thử.

---

## 1. Giới thiệu đề tài

### 1.1 Khái quát về ứng dụng Quản lý chi tiêu
Ứng dụng **"Quản lý chi tiêu" (Expense Management)** ra đời nhằm giải quyết vấn đề quản lý tài chính cá nhân. Thay vì sử dụng sổ tay hay bảng tính (Excel), ứng dụng cung cấp giao diện trực quan ngay trên điện thoại di động (Android/iOS) để ghi chép thu nhập, chi tiêu, phân loại hóa đơn, và xem báo cáo dưới dạng biểu đồ số liệu.

### 1.2 Lý do chọn đề tài
Trong thời đại số, việc quản lý dòng tiền cá nhân đã trở thành yếu tố bắt buộc để có nền tảng tài chính vững chắc. Ứng dụng "Quản lý chi tiêu" không chỉ là một hệ thống phổ biến thu hút sự quan tâm lớn của người dùng di động, mà còn có tính nghiệp vụ cao (liên quan đến tính toán tiền bạc, số dư, lịch sử giao dịch). Đây là một hệ thống lý tưởng để áp dụng các chiến lược kiểm thử nhằm đảm bảo:
- **Độ tin cậy:** Các phép toán cộng trừ số dư phải chính xác tuyệt đối.
- **Bảo mật:** Dữ liệu cá nhân của người dùng được bảo vệ an toàn (chứng thực qua Firebase Auth).
- **Tính khả dụng:** UI/UX cần mượt mà trên nền tảng di động (Flutter).

---

## 2. Mô tả hệ thống

### 2.1 Kiến trúc hệ thống
Hệ thống là một Ứng dụng di động Client-Server Architecture, bao gồm:
- **Client App:** Được xây dựng bằng **Flutter (hỗ trợ nền tảng iOS & Android)** và sử dụng kiến trúc State Management **Riverpod**.
- **Backend Services:** Tích hợp với hệ sinh thái **Firebase** (Cloud Firestore cho cơ sở dữ liệu, Firebase Auth để xử lý đăng nhập, Firebase Storage để lưu hình ảnh, Firebase Messaging cho tính năng thông báo).
- **Tiện ích mở rộng:** Hỗ trợ tính năng đọc mã QR (Mobile Scanner), Chat với AI tư vấn (Google Generative AI).

### 2.2 Các Module Chính (Với >= 20 chức năng)
Hệ thống bao gồm các Module và chức năng sau:
1. **Module Xác thực & Người dùng:** 
   1) Đăng ký tài khoản (Email/Password)
   2) Đăng nhập (Email/Password)
   3) Đăng nhập / Xác thực OTP bằng số điện thoại (Phone Login)
   4) Quên mật khẩu / Reset mã
   5) Xem thông tin cá nhân (Profile)
   6) Cập nhật ảnh đại diện (Avatar)
2. **Module Quản lý Giao dịch:**
   7) Thêm giao dịch (Chi tiêu/Thu nhập)
   8) Sửa thông tin giao dịch lịch sử
   9) Xóa giao dịch
   10) Quét mã QR thanh toán (QR Scanner)
3. **Module Quản lý Danh mục (Category):**
   11) Xem danh sách danh mục
   12) Thêm mới danh mục người dùng tự tạo
   13) Chỉnh sửa tên/icon danh mục
   14) Chuyển tiền (Transfer) giữa các ví
4. **Module Ngân sách & Tiết kiệm:**
   15) Thiết lập Ngân sách chi tiêu theo tháng (Budget Management)
   16) Theo dõi Mục tiêu Tiết kiệm (Savings)
   17) Xem Lịch sử giao dịch tiền tiết kiệm
5. **Module Thống kê & Báo cáo:**
   18) Màn hình Tổng quan (Home Dashboard)
   19) Báo cáo Thống kê (Biểu đồ tròn, Biểu đồ cột qua `fl_chart`)
   20) So sánh thu chi (Comparison Detail)
6. **Module Tiện ích Mở rộng:**
   21) Chat AI Tư vấn (Tích hợp Google Generative AI)
   22) Hộp thư thông báo (Inbox/Notification)

---

## 3. SRS (Software Requirement Specification)

Tài liệu Đặc tả Yêu cầu Phần mềm của ứng dụng.

### 3.1 Yêu cầu chức năng (Functional Requirements)
- **FR_AUTH_01:** Hệ thống phải cho phép người dùng tạo tài khoản mới bằng Email hợp lệ.
- **FR_AUTH_02:** Mật khẩu đăng nhập phải chứa ít nhất 6 ký tự.
- **FR_TRX_01:** Hệ thống phải cho phép người dùng thêm khoản chi cùng với con số tiền mặt hợp lệ (Lớn hơn 0).
- **FR_TRX_02:** Khi người dùng thêm khoản chi, số dư tài khoản tổng sẽ giảm xuống tương ứng.
- **FR_BUD_01:** Nếu tổng chi tiêu vượt quá mức Ngân sách đã thiết lập, hệ thống phải hiển thị Cảnh báo dưới dạng Text màu Đỏ.
- **FR_CTG_01:** Người dùng không thể xóa một Danh mục (Category) đang được sử dụng trong bất kỳ Giao dịch nào.

### 3.2 Yêu cầu phi chức năng (Non-Functional Requirements)
- **NFR_PERF_01:** Thời gian đăng nhập thao tác không được vượt quá 3 giây (với kết nối mạng trung bình).
- **NFR_UI_01:** Giao diện cần tương thích trên cả điện thoại màn hình nhỏ và tablet mà không bị tràn khung hình (Responsive Design).
- **NFR_SEC_01:** Dữ liệu cá nhân (tài khoản, chi tiêu) không được chia sẻ giữa các User, và được phân quyền thông qua Firestore Security Rules.

---

## 4. Test Plan (Kế Hoạch Kiểm Thử)

### 4.1 Phạm vi kiểm thử (In-scope)
- Kiểm thử các chức năng Giao diện người dùng (Thêm, Sửa, Xóa giao dịch).
- Kiểm thử tích hợp luồng Xác thực đăng nhập Firebase.
- Kiểm thử các logic tính toán số dư và xác thực nhập liệu (Unit Test cho Validation).
- Kiểm thử hồi quy sau mỗi bản cập nhật sửa lỗi trong thời gian thực hiện đồ án.

### 4.2 Phương pháp và Chiến lược kiểm thử (Testing Strategy)
- **Manual Testing (Test Thủ công):** 
  - Kỹ thuật phân vùng tương đương (Equivalence Partitioning).
  - Phân tích giá trị biên (Boundary Value Analysis) đối với số tiền.
  - Đoán lỗi (Error Guessing) với những định dạng email phổ biến/ký tự đặc biệt.
- **Unit Testing:**
  - Thực hiện trên core rules/validation bằng **JUnit 5** dựa trên mô hình code Java (theo yêu cầu môn học). 
- **Automation Testing:**
  - Đánh giá tự động hệ thống Mobile với **Appium** (Sử dụng Java client và JUnit 5 làm engine). Cài đặt Appium Server chạy giả lập Android (hoặc thiết bị thực).

### 4.3 Môi trường kiểm thử
- **Thiết bị:** Trình giả lập Android Studio (Pixel 4 API 33) & Điện thoại thực (Samsung S21).
- **Phần cứng:** CPU Core i7, RAM 16GB.
- **Phần mềm (Công cụ):** Appium (v2.x), JUnit 5, Android SDK, Android Inspector (để bóc tách XPath/ID UI elements), Bugzilla (Log Bug).

---

## 5. Test Case (Manual Testing)
*(Chi tiết các Test Cases được xuất trong file `TestCases.md` & `TestCases.csv` đính kèm).*

- Khởi tạo 20+ kịch bản đi từ Màn hình Xác Thực (Auth) đến Thêm Xóa Giao dịch (Transactions).
- Các mức ưu tiên Test Case được gán: **Critical** (Chức năng cốt lõi), **High** (Chức năng ảnh hưởng trải nghiệm), **Medium** (UI/UX).

---

## 6. Unit Testing (Kiểm thử đơn vị - JUnit 5)
*(Xem file code tại thư mục `appium_junit5_tests/src/test/java/com/quanlychitieu/tests/JUnitTestingTiers.java`)*
Trong kỹ thuật kiểm thử mức đơn vị, dự án sử dụng Framework JUnit 5 chia thành 3 cơ chế kiểm thử như sau:

### 6.1 Kiểm thử Hộp trắng (White-box testing)
- **Mục tiêu:** Tập trung vào kiểm tra đường dẫn luồng xử lý (Path/Branch coverage) bên trong cấu trúc mã nguồn. Người viết test biết rõ logic `if-else` của hàm.
- **Thực thi:** Kiểm tra hàm `checkBudgetStatus(spent, limit)`. Các Test Cases bao quát toàn bộ 4 nhánh điều kiện nội bộ (Số âm Exception, Vượt ngân sách, Cảnh báo 80%, và An toàn).

### 6.2 Kiểm thử Hộp đen (Black-box testing)
- **Mục tiêu:** Không can thiệp hoặc không biết cấu trúc mã nguồn bên trong, chỉ nhập Input (đầu vào) và Output (đầu ra) theo Đặc tả (Requirement).
- **Thực thi:** Khảo sát hàm tạo Mật khẩu `register(password)`. Các Test Cases đẩy vào chuỗi đúng (>= 6 ký tự), chuỗi sai (< 6 ký tự) và giá trị biên Null để kiểm chứng kết quả Bool (True/False) mà hệ thống nhả ra mà không xét luồng đi bên trong hàm đăng kí Firebase.

### 6.3 Kiểm thử Hộp xám (Gray-box testing)
- **Mục tiêu:** Kết hợp hai phương pháp trên. Người test có một phần kiến thức về cấu trúc dữ liệu / trạng thái State nội bộ của hệ thống (Ví dụ: trạng thái Flag trong DB).
- **Thực thi:** Test hàm dịch vụ `upgradePremium`. Truyền tham số 60K (Black box Input chuẩn), check kết quả trả về True (Black box Output), đồng thời check chéo biến trạng thái cơ sở dữ liệu `isPremiumDatabaseFlag` nội bộ xem có đổi sang True không (White box knowledge).

*(Cập nhật thêm: Các Annotations của JUnit5 như `@Test` và `@DisplayName` cùng với các API xác nhận (`assertEquals`, `assertTrue`) được sử dụng linh hoạt xuyên suốt quá trình này.)*

---

## 7. Automation Testing
*(Xem file script Automation tại `appium_junit5_tests/src/test/java/com/quanlychitieu/tests/AppiumLoginTest.java`)*
- Khai báo Capabilities kết nối thiết bị Android (UiAutomator2Options).
- Khai báo đường dẫn trỏ thẳng đến `app-debug.apk` trong output của Flutter Build.
- Khởi chạy phiên (session), đảm bảo ứng dụng load lên đúng giao diện đầu tiên.
- *Lưu ý:* Việc test tự động với Flutter có thể yêu cầu truy xuất `accessibilityId` hoặc dùng XPath theo cấu trúc mã nguồn được cấp.

---

## 8. Bug Tracking (Theo dõi và Báo cáo Yêu Cầu)

Quy trình quản lý vòng đời lỗi tuân thủ mô hình chuẩn: **NEW -> ASSIGNED -> RESOLVED -> VERIFIED -> CLOSED**.
Công cụ sử dụng: **GitHub Issues** (Dễ dàng tiếp cận vì mã nguồn đang được quản lý trên GitHub).

**Một số lỗi phát hiện trong quá trình test:**
*(Tham khảo và lấy ảnh thẻ Bug trên bảng Github Issues)*

Ví dụ Cấu trúc 1 Bug điển hình để tải lên Github Issues:
- **Summary:** [Signup] Đăng ký thành công dù Email bị thiếu ký tự '@'
- **Status:** NEW
- **Severity:** Major
- **Steps to reproduce:**
  1. Mở app, chọn Đăng ký
  2. Tại ô Email, nhập "nguyenvana123gmail.com" (không có @)
  3. Mật khẩu nhập "123456"
  4. Bấm "Đăng ký"
- **Actual Result:** Hệ thống tiếp nhận và thông báo Đăng ký thành công.
- **Expected Result:** Hệ thống phải báo lỗi đỏ ở ô text "Email không đúng định dạng".

---

## 9. Test Report (Báo Cáo Kết Quả Kiểm Thử)

**Chi tiết tổng hợp:**
- Số lượng Test Case được soạn thảo: 22
- Số lượng Test Case Execution: 22
- Số lượng Pass: 18 (81%)
- Số lượng Failed: 4 (19%)
- Tổng số Bug phát hiện: 4 Bug (Trong đó có 1 Critical, 1 Major, 2 Minor về UI ảnh hưởng đến UX hiển thị chữ nhỏ giọt).

*Đánh giá năng lực phần mềm:*
Phần mềm đã hoàn thiện đa số tính năng xương sống: Người dùng có thể Đăng nhập, Ghi chi tiêu, và Xem biểu đồ bình thường. Một số lỗi Validation nhỏ tại form đăng ký/đăng nhập cần được team Dev sửa và chuyển lại để Tester re-test lại (Regression Testing).

---

## 10. Conclusion (Kết Luận)

Thông qua quá trình triển khai việc phân tích yêu cầu (SRS), lên Test Plan, khởi tạo Manual Test, và viết Script Tự động hóa bằng Appium + JUnit5, dự án ứng dụng Mobile Quản lý chi tiêu đã được rà soát kỹ lưỡng. Đồ án rút ra kết luận hệ thống đã đạt mức trạng thái ổn định cho việc trải nghiệm chức năng chính, tuy nhiên vẫn cần phải khắc phục bugs trong Sprint tiếp theo. Qua đề tài này, người thực hiện nắm vững tư duy kiểm thử xuyên suốt từ Requirement Verification cho đến Bug Retesting.
