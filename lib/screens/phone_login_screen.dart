import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isCodeSent = false;
  String? _verificationId;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyPhoneNumber() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final authService = ref.read(authServiceProvider);
    final phoneNumber = _phoneController.text.trim();

    // Basic validation for Vietnam phone numbers
    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập số điện thoại';
        _isLoading = false;
      });
      return;
    }

    String formattedPhone = phoneNumber;
    if (phoneNumber.startsWith('0')) {
      formattedPhone = '+84${phoneNumber.substring(1)}';
    } else if (!phoneNumber.startsWith('+')) {
       formattedPhone = '+84$phoneNumber';
    }

    try {
      await authService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android-only: Auto verification
          final error = await authService.signInWithCredential(credential);
          if (error != null) {
            setState(() {
              _errorMessage = error;
              _isLoading = false;
            });
          } else {
             if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            if (e.code == 'invalid-phone-number') {
               _errorMessage = 'Số điện thoại không hợp lệ.';
            } else if (e.code == 'too-many-requests') {
               _errorMessage = 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
            } else if (e.message != null && e.message!.contains('BILLING_NOT_ENABLED')) {
               _errorMessage = 'Lỗi: Dự án Firebase chưa kích hoạt thanh toán (gói Blaze) để gửi SMS thật. Vui lòng thêm số điện thoại vào danh sách "Phone numbers for testing" trên Console để kiểm tra.';
            } else {
               _errorMessage = 'Lỗi xác thực: ${e.message ?? e.code}';
            }
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
           _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: $e';
        _isLoading = false;
      });
    }
  }

  void _verifyOTP() async {
     setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final smsCode = _otpController.text.trim();
    if (smsCode.isEmpty) {
       setState(() {
        _errorMessage = 'Vui lòng nhập mã OTP';
        _isLoading = false;
      });
      return;
    }

    if (_verificationId != null) {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final authService = ref.read(authServiceProvider);
      final error = await authService.signInWithCredential(credential);

       if (error != null) {
        setState(() {
           if (error == 'invalid-verification-code') {
              _errorMessage = 'Mã OTP không đúng.';
           } else {
              _errorMessage = error;
           }
          _isLoading = false;
        });
      } else {
        // Success
         if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập bằng SĐT')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            if (!_isCodeSent) ...[
              const Text('Nhập số điện thoại của bạn:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',                  
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyPhoneNumber,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Gửi mã xác thực'),
              ),
            ] else ...[
               Text('Đã gửi mã OTP đến ${_phoneController.text}', style: const TextStyle(fontSize: 16)),
               const SizedBox(height: 10),
               TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã OTP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
               ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Xác thực OTP'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isCodeSent = false;
                    _otpController.clear();
                  });
                },
                child: const Text('Nhập lại số điện thoại'),
              )
            ]
          ],
        ),
      ),
    );
  }
}
