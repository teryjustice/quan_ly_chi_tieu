import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart'; // Cho firestoreServiceProvider
import '../data/firestore_service.dart'; // <<< THÊM: Cần để gọi hàm xóa
import 'category_add_screen.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  // Hàm hiển thị hộp thoại xác nhận xóa (Giúp code clean hơn)
  void _showDeleteConfirmation(
      BuildContext context, FirestoreService service, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận XÓA'),
        content: Text('Bạn có chắc muốn xóa danh mục "${category.title}"?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            onPressed: () {
              // Gọi hàm xóa
              if (category.id != null) {
                service.deleteCategory(category.id!);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe stream danh mục
    final categoriesAsyncValue = ref.watch(categoryStreamProvider);
    final firestoreService = ref.read(firestoreServiceProvider); // Đọc Service

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Danh Mục'),
        backgroundColor: Colors.indigo[100],
      ),
      body: categoriesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),

        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Chưa có danh mục nào. Hãy thêm mới!'));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: Icon(category.icon, color: category.color),
                title: Text(category.title),

                // --- CHỨC NĂNG SỬA (UPDATE) ---
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // Mở màn hình Add/Edit và truyền dữ liệu cũ vào
                      builder: (context) => CategoryAddScreen(categoryToEdit: category),
                    ),
                  );
                },

                // --- NÚT XÓA (DELETE) ---
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent), // Đổi màu để nổi bật
                  onPressed: () {
                    // Gọi hàm xác nhận xóa
                    _showDeleteConfirmation(context, firestoreService, category);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mở màn hình THÊM DANH MỤC
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CategoryAddScreen(), // Mặc định không truyền tham số
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}