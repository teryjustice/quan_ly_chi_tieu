# Phác Thảo Gợi Ý Slide Thuyết Trình Đồ Án Cuối Kỳ
*Đây là dàn ý các Slide (trang trình chiếu) để bạn làm báo cáo PowerPoint.*

---

## Slide 1: Tiêu đề
- **Tên đề tài:** Đồ án môn học Kiểm thử Phần mềm (Software Testing).
- **Ứng dụng được chọn:** Quản lý Chi tiêu Cá nhân (Expense Management App).
- **Họ tên sinh viên:** [Tên của bạn]
- **MSSV:** [Mã sinh viên]

## Slide 2: Giới thiệu ứng dụng & Lý do chọn đề tài
- **Ứng dụng là gì:** Một app di động (Flutter) hỗ trợ ghi chép thu chi hàng ngày, thống kê biểu đồ trực quan, giúp người dùng theo dõi và lên ngân sách tiết kiệm tài chính hiệu quả.
- **Lý do chọn để test:** Chức năng đa dạng (hơn 20 UI/Features), liên đới nhiều tới các phép toán phức tạp (trừ tiền, hạch toán số dư) rất phù hợp với việc rèn luyện chuyên môn Kiểm thử (đòi hỏi sự chính xác tuyệt đối).

## Slide 3: Tổng quan Kiến trúc Hệ thống
- **Công nghệ Frontend:** Flutter (Cross-platform cho iOS / Android)
- **Công nghệ Backend:** Hệ sinh thái Firebase (Firestore DB, Firebase Auth để mã hóa và phân quyền, Storage).
- **Tích hợp mở rộng:** Camera quét QR và Google Generative AI hỗ trợ tư vấn tài chính.

## Slide 4: Yêu cầu & Test Plan
- **Yêu cầu (SRS) cốt lõi:**
  1. Bảo mật: Login Auth xác thực phân vùng dữ liệu cá nhân.
  2. Bất biến: Số liệu Total Balance luôn tương đương Tổng Thu - Tổng Chi.
- **Môi trường Test:** Trình giả lập Android.
- **Kỹ thuật Manual Test:** Kiểm thử phân vùng tương đương (Tiền > 0, Tiền < 0, Email sai format).

## Slide 5: Tổng hợp Manual Testing (Test Case & Execution)
- *Chèn một tấm ảnh chụp một phần File Excel Test Case vào slide này cho đẹp.*
- **Tổng số kịch bản Kiểm thử:** 22 Test Cases.
- **Tỷ lệ Pass/Fail:** Pass (18 kịch bản) - Failed (4 kịch bản).
- Phát hiện một số lỗi xử lý ngoại lệ (Exception handling) khi không điền dữ liệu lúc tạo giao dịch mới.

## Slide 6: Log Bug & Theo Dõi (Bug Tracking)
- *Chèn tấm hình chụp màn hình trang GitHub Issues đã tạo bug vào Slide này.*
- Cấu trúc quản lý vòng đời lỗi tuân thủ nghiêm ngặt chuẩn (NEW -> ASSIGNED -> RESOLVED).
- Các bug nghiêm trọng (High) ảnh hưởng tính đúng đắn sẽ ưu tiên phát hành bản vá trước.

## Slide 7: Tự động hóa Automation Testing & Unit Testing 
- **Công cụ:** Appium (Client SDK) & Engine phần lõi với JUnit5 trong môi trường Java.
- **Mục tiêu:** Chạy tự động luồng Mở App và check tính khả dụng của Screen đăng nhập. Xử lý kịch bản test lõi format số bằng Unit Test chuyên biệt.
- *Có thể chèn Video / Gif demo ngắn Appium tự mở app lên điện thoại nếu muốn điểm tối đa.*

## Slide 8: Kết luận và Hướng phát triển
- Đồ án đã vận hành qua chuỗi quy trình: Phân tích -> Xây dựng Kịch bản -> Thực thi bằng tay + Tự động hóa -> Ghi nhận lỗi báo cáo thành công. Hệ thống cơ bản đáp ứng kỳ vọng.
- **Hướng phát triển:** Thêm Load Testing với JMeter để xem Firebase chịu được bao nhiêu traffic thực, thiết lập CI/CD tích hợp GitHub Action nhằm test ngay phiên bản khi commit.

## Slide 9: Q/A & Cảm ơn
- Lời cảm ơn dành cho giảng viên hướng dẫn.
- Mời câu hỏi chất vấn.

---
*(Xem folder ứng dụng để tham khảo thêm)*
