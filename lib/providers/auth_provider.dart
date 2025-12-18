import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/auth_service.dart';

// 1. Service Provider
final authServiceProvider = Provider((ref) => AuthService());

// 2. Stream theo dõi trạng thái đăng nhập (đã đăng nhập/chưa)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// 3. Stream lấy thông tin vai trò (Role) của người dùng hiện tại
final userRoleProvider = StreamProvider<String>((ref) {
  final user = ref.watch(authStateChangesProvider).value;

  if (user == null) {
    return Stream.value('guest'); // Nếu chưa đăng nhập, trả về guest
  }

  // Lấy document user từ Firestore dựa trên UID
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      // Lấy vai trò (role) đã lưu trong Firestore
      return snapshot.data()!['role'] as String? ?? 'user';
    }
    return 'user'; // Mặc định là user nếu không tìm thấy
  });
});