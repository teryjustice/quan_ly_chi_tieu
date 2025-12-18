import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

// Tiện ích mở rộng để tính toán nhanh
extension TransactionListExtension on List<TransactionModel> {
  // Tổng Chi (Expense)
  double get totalExpense => fold(0.0, (sum, tx) => sum + (tx.isExpense ? tx.amount : 0.0));

  // Tổng Thu (Income)
  double get totalIncome => fold(0.0, (sum, tx) => sum + (tx.isExpense ? 0.0 : tx.amount));

  // Số dư còn lại
  double get remainingBalance => totalIncome - totalExpense;
}

// Widget hiển thị Tổng quan
class SummaryCard extends ConsumerWidget {
  final List<TransactionModel> transactions;

  const SummaryCard({super.key, required this.transactions});

  // Định dạng số tiền
  String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalExpense = transactions.totalExpense;
    final totalIncome = transactions.totalIncome;
    final remainingBalance = transactions.remainingBalance;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Số Dư Hiện Tại
            const Text(
              'Số Dư Còn Lại',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              '${formatCurrency(remainingBalance)} đ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: remainingBalance >= 0 ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const Divider(height: 25),

            // 2. Chi tiết Thu và Chi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Tổng Thu
                _buildSummaryItem(
                  'Tổng Thu',
                  totalIncome,
                  Colors.green,
                  Icons.arrow_upward,
                ),

                // Tổng Chi
                _buildSummaryItem(
                  'Tổng Chi',
                  totalExpense,
                  Colors.red,
                  Icons.arrow_downward,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget con cho Thu/Chi
  Widget _buildSummaryItem(
      String title, double amount, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${formatCurrency(amount)} đ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}