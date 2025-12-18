# 🎯 HƯỚNG DẪN CHI TIẾT THAY ĐỔI ICON APP

## **BƯỚC 1: CHUẨN BỊ ICON**

### Tùy chọn 1️⃣: Tạo icon trực tuyến (ĐỀ NGHỊ)
1. Truy cập: https://www.figma.com (miễn phí)
2. Đăng ký/Đăng nhập
3. Tạo file mới
4. Vẽ icon ví tiền/tiền tệ (1024x1024px)
5. Sử dụng màu: **#D82D8B** (Momo Pink)
6. Export PNG → Lưu vào `assets/icons/app_icon.png`

### Tùy chọn 2️⃣: Dùng template
1. https://www.canva.com
2. Tìm: "app icon template"
3. Thiết kế theo ý thích
4. Download PNG → `assets/icons/app_icon.png`

### Tùy chọn 3️⃣: Dùng ảnh có sẵn
- Nếu có ảnh ví tiền/tiền tệ, dùng tool xóa nền:
- https://remove.bg
- Upload ảnh → Xóa nền → Download PNG
- Lưu vào `assets/icons/app_icon.png`

---

## **BƯỚC 2: ĐẶT FILE ICON**

Sau khi có file PNG (1024x1024), đặt tại:
```
quan_ly_chi_tieu/
└── assets/
    └── icons/
        ├── my_logo.jpg          (Cũ)
        └── app_icon.png         (MỚI) ← Đặt file đây
```

---

## **BƯỚC 3: CHẠY LỆNH TẠO ICON**

Mở **Terminal/PowerShell** trong folder project:

```bash
# Cập nhật pubspec
flutter pub get

# Tạo icon cho cả Android & iOS
flutter pub run flutter_launcher_icons

# Hoặc
dart run flutter_launcher_icons
```

**Kết quả:**
- ✅ Thư mục `android/app/src/main/res` được cập nhật
- ✅ iOS icon được cập nhật (nếu có)

---

## **BƯỚC 4: REBUILD APP**

```bash
# Xóa build cũ
flutter clean

# Lấy dependencies
flutter pub get

# Chạy app
flutter run
```

---

## **BƯỚC 5: KIỂM TRA KẾT QUẢ**

✅ Mở app → Icon trên home screen sẽ thay đổi  
✅ Icon trong app drawer sẽ cập nhật  
✅ Nếu chạy trên emulator, có thể phải khởi động lại  

---

## **🚨 CẢNHbáo/TROUBLESHOOT**

### ❌ Icon không thay đổi?
**Giải pháp:**
```bash
# 1. Xóa cache
flutter clean

# 2. Xóa icon cũ (Android)
rm -r android/app/src/main/res/mipmap-*

# 3. Chạy lại
flutter pub run flutter_launcher_icons
flutter run
```

### ❌ Lỗi "Image not found"?
- Kiểm tra đường dẫn: `assets/icons/app_icon.png`
- File phải là PNG (không JPG)
- Tên file phải chính xác (case-sensitive)

### ❌ Icon bị méo/không rõ?
- Ảnh phải 1024x1024 (vuông)
- Nên để khoảng trắng quanh hình (safe zone)
- Dùng PNG với nền trong suốt

---

## **📝 PUBSPEC.yaml (đã được cấu hình)**

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"  # ← Thay đổi ở đây
  background_color: "#FFFFFF"
  min_sdk_android: 21
```

---

## **✨ KẾT QUẢ CUỐI**

🎉 App sẽ hiển thị icon riêng của bạn thay vì Flutter default!

---

## **💡 MẸO THÊM**

### Nếu muốn icon khác nhau trên Android/iOS:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path_android: "assets/icons/app_icon_android.png"
  image_path_ios: "assets/icons/app_icon_ios.png"
```

### Nếu muốn icon theo theme:
```yaml
flutter_launcher_icons:
  android: "adaptive"  # Dùng adaptive icon (Android 8.0+)
  ios: false
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
```

---

**Chúc thành công! 🚀**
