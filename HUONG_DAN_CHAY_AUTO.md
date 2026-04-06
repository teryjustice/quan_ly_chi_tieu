# Hướng Dẫn Chạy Automation Testing (Appium + JUnit5)

Tài liệu này giúp bạn chạy và quay phim Video Demo tự động hóa cho đồ án.

## 1. Chuẩn bị (Prerequisites)
1.  **Cài đặt Appium Server:** Bạn cần cài đặt [Appium Desktop](http://appium.io/) hoặc cài qua lệnh `npm install -g appium`. Sau đó **khởi động Server** (mặc định tại cổng `4723`).
2.  **Mở Giả lập (Emulator/Simulator):** Mở trình giả lập Android Studio hoặc kết nối điện thoại Android thật đã bật "Gỡ lỗi USB".
3.  **Xây dựng File APK:** Mở terminal trong thư mục chính và chạy lệnh:
    ```bash
    flutter build apk --debug
    ```
    *Mục tiêu:* Tạo file `app-debug.apk` tại `/build/app/outputs/flutter-apk/` để Appium nạp vào.

## 2. Các bước khởi chạy Script
1.  **Mở mã nguồn Test:** Mở thư mục `appium_junit5_tests` bằng IDE (IntelliJ, VS Code, hoặc Eclipse).
2.  **Khởi chạy Maven:** Bạn có thể chạy qua dòng lệnh hoặc bấm nút Run trong IDE:
    - **Trong IDE:** Phải chuột vào file `AppiumAutomationTest.java` > Chọn **Run 'AppiumAutomationTest'**.
    - **Bằng Dòng lệnh:** Chạy lệnh `mvn test` trong thư mục `appium_junit5_tests`.

## 3. Điều gì sẽ xảy ra?
- Bạn sẽ thấy điện thoại/giả lập **tự động** được mở lên.
- Ứng dụng tự động được cài đặt.
- Các ô **Email** và **Mật khẩu** tự động được điền chữ.
- Nút **Đăng nhập** tự động được nhấn.
- Trên màn hình máy tính của bạn, kết quả sẽ hiện **`Tests passed: 2`**.

## 4. Quay phim Video Demo để nộp (Yêu cầu số 7)
- Bạn nên dùng phần mềm quay màn hình (như OBS hoặc Screen Recorder).
- Quay cả màn hình máy tính có cửa sổ code bên trái và màn hình giả lập điện thoại bên phải.
- Lúc bấm nút **Run**, bạn thuyết minh: *"Hệ thống đang tự động hóa quá trình đăng nhập sử dụng Appium Client và framework JUnit 5 dựa trên kiến trúc Page Object Model cơ bản."*

## 5. Quay phim Unit Test (Yêu cầu số 6)
- Tương tự, bạn mở file `JUnitTestingTiers.java` và chọn Run.
- Quay màn hình khi các tích xanh (Pass) hiện lên ở các kỹ thuật **Hộp trắng, Hộp đen, Hộp xám**.
- Giải thích: *"Đây là phần kiểm thử đơn vị, chúng tôi đã bao phủ toàn bộ logic rẽ nhánh cho hàm tính toán ngân sách (Hộp trắng) và kiểm tra biên cho đăng ký (Hộp đen)."*
