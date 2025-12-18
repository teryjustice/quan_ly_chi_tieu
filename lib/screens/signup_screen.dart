import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _errorMessage = null);

      final authService = ref.read(authServiceProvider);
      // LƯU BIẾN NAVIGATOR TRƯỚC KHI AWAIT
      final navigator = Navigator.of(context);

      final error = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // KIỂM TRA mounted: Đảm bảo Widget vẫn đang hoạt động
      if (!mounted) return;

      if (error != null) {
        // Xử lý lỗi
        setState(() {
          _errorMessage = error;
        });
      } else {
        // --- XỬ LÝ THÀNH CÔNG AN TOÀN ---
        // 1. Hiện thông báo (Context an toàn)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
            duration: Duration(seconds: 3),
          ),
        );

        // 2. Tự động đóng màn hình bằng biến navigator đã lưu
        navigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Ký Tài Khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('Tạo tài khoản mới', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    // Có thể dịch mã lỗi Firebase sang tiếng Việt nếu cần
                    'Lỗi: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty || !val.contains('@') ? 'Nhập email hợp lệ!' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
                validator: (val) => val!.length < 6 ? 'Mật khẩu phải từ 6 ký tự trở lên!' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submitSignUp,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text('Đăng Ký'),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đã có tài khoản? Đăng nhập ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}