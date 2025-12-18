import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/statistics_provider.dart';
import '../utils/date_formatter.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(monthTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Giao Dịch Tháng Này'),
        centerTitle: true,
        elevation: 0,
      ),
      body: historyState.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Không có giao dịch nào trong tháng này'),
            );
          }

          // Tính tổng chi tiêu và thu nhập
          double totalExpense = 0;
          double totalIncome = 0;

          for (var item in items) {
            if (item.transaction.isExpense) {
              totalExpense += item.transaction.amount;
            } else {
              totalIncome += item.transaction.amount;
            }
          }

          return Column(
            children: [
              // Phần tóm tắt
              _buildSummaryCard(totalIncome, totalExpense),

              // Danh sách giao dịch
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final transaction = item.transaction;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.isExpense
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          child: Icon(
                            transaction.isExpense
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color:
                                transaction.isExpense ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text(
                          transaction.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.categoryName,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              DateFormatter.formatDateTime(transaction.date),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${transaction.isExpense ? '-' : '+'}${transaction.amount.toStringAsFixed(0)}đ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: transaction.isExpense
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        onTap: () {
                          // Có thể thêm chức năng edit/delete ở đây
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildSummaryCard(double totalIncome, double totalExpense) {
    final balance = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Thu Nhập', totalIncome, Colors.green),
              _buildSummaryItem('Chi Tiêu', totalExpense, Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Số Dư: ',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${balance.toStringAsFixed(0)}đ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)}đ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
