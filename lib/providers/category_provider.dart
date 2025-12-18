import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'transaction_provider.dart'; // Import để lấy firestoreServiceProvider
import 'auth_provider.dart'; // Để biết trạng thái đăng nhập

// StreamProvider cung cấp danh sách Category
// NOTE: Nếu chưa đăng nhập, trả về stream rỗng để tránh gọi Firestore và gây lỗi permission-denied
final categoryStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  final user = authState.value; // User? nếu đã có dữ liệu
  if (user == null) {
    // Trả về stream chứa danh sách rỗng khi chưa đăng nhập
    return Stream.value(<CategoryModel>[]);
  }

  return firestoreService.getCategoriesStream();
});

