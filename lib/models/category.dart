import 'package:flutter/material.dart';


class CategoryModel {
  String? id;
  final String title;
  final IconData icon;
  final Color color;

  CategoryModel({
    this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  // Chuyển từ Model sang Map (lưu lên Firebase)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      // Lưu icon và color dưới dạng số nguyên (integer)
      'iconCodePoint': icon.codePoint,
      'colorValue': color.toARGB32(), // Updated to use toARGB32()
    };
  }

  // Chuyển từ Firebase Map về Model
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    // Hàm hỗ trợ lấy int an toàn
    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value); // Cố gắng parse từ String nếu cần
      }
      return null;
    }

    return CategoryModel(
      id: id,
      // Sử dụng toString() để an toàn hơn, thay vì ép kiểu as String
      title: map['title']?.toString() ?? 'Chưa đặt tên',
      // Chuyển lại từ số nguyên về IconData và Color
      icon: IconData(
          toInt(map['iconCodePoint']) ?? Icons.category.codePoint, // Dùng icon mặc định nếu lỗi
          fontFamily: 'MaterialIcons'),
      color: Color(toInt(map['colorValue']) ?? Colors.grey.toARGB32()), // Updated to use toARGB32()
    );
  }
}

// Danh sách Category mặc định (chỉ dùng để tham khảo)
final defaultCategories = [
  CategoryModel(title: 'Ăn Uống', icon: Icons.fastfood, color: Colors.orange),
  CategoryModel(title: 'Di Chuyển', icon: Icons.directions_car, color: Colors.blue),
  CategoryModel(title: 'Lương', icon: Icons.work, color: Colors.green),
  CategoryModel(title: 'Quần Áo', icon: Icons.shopping_bag, color: Colors.purple),
  CategoryModel(title: 'Giải Trí', icon: Icons.movie, color: Colors.pink),
];
