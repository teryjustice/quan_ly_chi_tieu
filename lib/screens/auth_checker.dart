import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lắng nghe trạng thái đăng nhập từ Firebase Auth
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      // KHI ĐÃ CÓ KẾT QUẢ TRẠNG THÁI
      data: (user) {
        if (user != null) {
          // USER ĐÃ ĐĂNG NHẬP (user != null)
          // Chuyển đến Trang chủ (nơi sẽ kiểm tra tiếp vai trò Admin/User)
          return const HomeScreen();
        }
        // USER CHƯA ĐĂNG NHẬP (user == null)
        return const LoginScreen();
      },

      // KHI ĐANG KIỂM TRA (Ví dụ: lúc khởi động app lần đầu)
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Đang kiểm tra trạng thái đăng nhập...")
            ],
          ),
        ),
      ),

      // KHI CÓ LỖI XẢY RA
      error: (e, st) => Scaffold(body: Center(child: Text('Lỗi xác thực: $e'))),
    );
  }
}