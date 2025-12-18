import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _emailController = TextEditingController();
  String? _message;
  Color _messageColor = Colors.grey;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = 'Vui lòng nhập địa chỉ email hợp lệ.';
        _messageColor = Colors.red;
      });
      return;
    }

    final authService = ref.read(authServiceProvider);
    final result = await authService.resetPassword(email: email);

    setState(() {
      if (result == 'success') {
        _message = 'Đã gửi liên kết đặt lại mật khẩu đến email của bạn. Vui lòng kiểm tra hộp thư!';
        _messageColor = Colors.green;
      } else {
        _message = 'Lỗi: Tài khoản không tồn tại hoặc lỗi khác.';
        _messageColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên Mật Khẩu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Nhập email của bạn để nhận liên kết đặt lại mật khẩu.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Nhập Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // Thông báo
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(color: _messageColor, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),

            // Nút Gửi
            ElevatedButton(
              onPressed: _submitReset,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('Gửi Yêu Cầu Đặt Lại'),
            ),
            const SizedBox(height: 20),

            // Nút quay lại Login
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lại Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}