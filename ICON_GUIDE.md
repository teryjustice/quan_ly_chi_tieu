# 📱 HƯỚNG DẪN THAY ĐỔI ICON APP

## **Bước 1: Chuẩn bị ảnh icon**
- Icon phải là file **PNG** (nền trong suốt)
- Kích thước tối thiểu: **1024x1024 pixels**
- Đặt file vào: `assets/icons/app_icon.png`

## **Bước 2: Cấu hình pubspec.yaml**
Phần `flutter_launcher_icons` đã được cấu hình sẵn:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"  # Thay đổi đường dẫn ảnh ở đây
  min_sdk_android: 21
```

## **Bước 3: Chạy lệnh tạo icon**
```bash
# Nếu cài pubspec_override.yaml
flutter pub run flutter_launcher_icons

# Hoặc
flutter pub global activate flutter_launcher_icons
flutter pub global run flutter_launcher_icons:main
```

## **Bước 4: Xóa app cũ & chạy lại**
```bash
flutter clean
flutter pub get
flutter run
```

## **Kết quả:**
- ✅ Android: Icon sẽ hiển thị ở home screen & app drawer
- ✅ iOS: Icon sẽ hiển thị ở home screen

---

## **💡 LƯU Ý QUAN TRỌNG**

### Yêu cầu ảnh:
1. **Format**: PNG (nền trong suốt)
2. **Kích thước**: Tối thiểu 1024x1024 pixels (vuông)
3. **Vị trí**: `assets/icons/app_icon.png`
4. **Thiết kế**: Đặt nội dung ở giữa, để khoảng cách ở mép

### Nếu dùng ảnh có nền:
- Trong `pubspec.yaml`, thêm:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  background_color: "#FFFFFF"  # Màu nền nếu cần
  min_sdk_android: 21
```

---

## **🎨 Tạo Icon Nhanh (Online)**
- **Figma**: https://figma.com (thiết kế miễn phí)
- **Canva**: https://canva.com (template icon app)
- **RemoveBG**: https://remove.bg (xóa nền ảnh)

---

## **❓ Nếu lỗi?**
```bash
# Xóa icon đã tạo
rm -r android/app/src/main/res
rm -r ios/Runner/Assets.xcassets/AppIcon.appiconset

# Thử lại
flutter pub run flutter_launcher_icons
```
