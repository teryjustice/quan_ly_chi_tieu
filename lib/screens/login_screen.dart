import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'password_reset_screen.dart';
import 'phone_login_screen.dart'; // Import màn hình đăng nhập bằng số điện thoại (sẽ tạo)

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _errorMessage = null);

      final authService = ref.read(authServiceProvider);
      final error = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (error != null) {
        setState(() {
          _errorMessage = error;
        });
      } else {
        // Thành công, AuthChecker sẽ tự động chuyển hướng
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Nhập')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('Chào mừng trở lại', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Thông báo lỗi
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

              // 1. NHẬP EMAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập email!' : null,
              ),
              const SizedBox(height: 15),

              // 2. NHẬP MẬT KHẨU
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Vui lòng nhập mật khẩu!' : null,
              ),
              const SizedBox(height: 20),

              // Nút Quên mật khẩu
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PasswordResetScreen()),
                    );
                  },
                  child: const Text('Quên mật khẩu?'),
                ),
              ),

              // 3. NÚT ĐĂNG NHẬP
              ElevatedButton(
                onPressed: _submitLogin,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text('Đăng Nhập'),
              ),
              const SizedBox(height: 15),

              // Nút Đăng nhập bằng SĐT
              OutlinedButton.icon(
                onPressed: () {
                   Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
                    );
                },
                icon: const Icon(Icons.phone),
                label: const Text('Đăng nhập bằng số điện thoại'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              ),
              const SizedBox(height: 20),

              // Chuyển sang Đăng ký
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text('Chưa có tài khoản? Đăng ký ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
