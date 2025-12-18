import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart'; // For firestoreServiceProvider
import '../providers/auth_provider.dart'; // For authStateChangesProvider and userProvider

// A new provider for getting user by email, will be defined in auth_provider.dart
// final userByEmailProvider = FutureProvider.family<String?, String>((ref, email) async {
//   // This will be implemented in auth_provider.dart or a new user_service.dart
//   return null; // Placeholder
// });

class TransferScreen extends ConsumerStatefulWidget {
  final String? scannedCode; // QR code từ scanner

  const TransferScreen({super.key, this.scannedCode});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _recipientEmailController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Nếu có QR code, lấy email từ đó
    _recipientEmailController = TextEditingController(text: widget.scannedCode ?? '');
  }

  @override
  void dispose() {
    _recipientEmailController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _performTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final firestoreService = ref.read(firestoreServiceProvider);
    final currentUser = ref.read(authStateChangesProvider).value;
    final currentUserId = currentUser?.uid;
    final currentUserEmail = currentUser?.email;

    if (currentUserId == null || currentUserEmail == null) {
      _showSnackBar('Lỗi: Không thể xác định người gửi.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final recipientEmail = _recipientEmailController.text.trim();
    final amount = double.parse(_amountController.text);
    final message = _messageController.text.trim();

    if (recipientEmail == currentUserEmail) {
      _showSnackBar('Không thể chuyển tiền cho chính mình.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Check sender's balance (simplified, proper balance check would involve aggregating transactions)
      // For now, let's assume balance is checked on FirestoreService side or in a dedicated provider

      // This is a simplified check. A robust solution needs total balance calculation.
      final currentBalance = await firestoreService.getCurrentBalance(currentUserId);
      if (currentBalance < amount) {
        _showSnackBar('Số dư không đủ để thực hiện giao dịch.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Perform the transfer via FirestoreService
      final success = await firestoreService.transferMoney(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        recipientEmail: recipientEmail,
        amount: amount,
        message: message,
      );

      if (success) {
        _showSnackBar('Chuyển tiền thành công!');
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showSnackBar('Chuyển tiền thất bại. Vui lòng kiểm tra email người nhận và thử lại.');
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chuyển tiền: ${e.toString()}');
      // ignore: avoid_print
      print('Transfer error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển Tiền'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _recipientEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email người nhận',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email người nhận.';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          return 'Vui lòng nhập địa chỉ email hợp lệ.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        suffixText: 'VNĐ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số tiền.';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Số tiền không hợp lệ.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Lời nhắn (Tùy chọn)',
                        prefixIcon: Icon(Icons.message_outlined),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _performTransfer,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(_isLoading ? 'Đang chuyển...' : 'Chuyển Tiền'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
