import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import 'savings_history_screen.dart'; // Import màn hình lịch sử

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  final _amountController = TextEditingController();
  final _interestRate = 0.05; // 5% per year

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateInterest() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final interest = amount * _interestRate;
    final total = amount + interest;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tính toán lãi suất (1 năm)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số tiền gửi: ${NumberFormat('#,##0', 'en_US').format(amount)} đ'),
            const SizedBox(height: 8),
            Text('Lãi suất: ${(_interestRate * 100).toInt()}% / năm'),
            const SizedBox(height: 8),
            Text('Tiền lãi dự kiến: ${NumberFormat('#,##0', 'en_US').format(interest)} đ'),
            const Divider(),
            Text(
              'Tổng nhận được: ${NumberFormat('#,##0', 'en_US').format(total)} đ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmSaving(amount);
            },
            child: const Text('Xác nhận Gửi'),
          ),
        ],
      ),
    );
  }

  void _confirmSaving(double amount) {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final service = ref.read(firestoreServiceProvider);

    // Create an expense transaction for the saving amount
    final tx = TransactionModel(
      title: 'Gửi tiết kiệm (1 năm - 5%)',
      amount: amount,
      date: DateTime.now(),
      isExpense: true, // Treated as expense from main balance
      categoryId: null, // Or a specific category if available
      userId: user.uid,
    );

    service.addTransaction(tx);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi tiết kiệm thành công!')),
    );
    
    // Điều hướng sang màn hình lịch sử gửi tiết kiệm thay vì pop về màn hình chính
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SavingsHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi Tiết Kiệm'),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView( // Đã sửa lỗi bottom overflow
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gửi tiết kiệm tích lũy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                color: Colors.pink.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.percent, size: 40, color: Colors.pink),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lãi suất hấp dẫn', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${(_interestRate * 100).toInt()}% / năm', style: const TextStyle(fontSize: 24, color: Colors.pink, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Nhập số tiền muốn gửi:'),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: 10,000,000',
                  border: OutlineInputBorder(),
                  suffixText: 'VNĐ',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateInterest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Tính lãi & Gửi ngay', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
