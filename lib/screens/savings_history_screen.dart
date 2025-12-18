import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class SavingsHistoryScreen extends ConsumerWidget {
  const SavingsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter transactions that look like savings (title contains "Gửi tiết kiệm")
    final transactionsAsyncValue = ref.watch(transactionStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Gửi Tiết Kiệm'),
        backgroundColor: Colors.pink,
      ),
      body: transactionsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Lỗi: $e')),
        data: (transactions) {
          final savings = transactions.where((tx) {
            return tx.isExpense == true && (tx.title.contains('Gửi tiết kiệm'));
          }).toList();

          if (savings.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có khoản tiết kiệm nào.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: savings.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (ctx, i) {
              final tx = savings[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink.shade50,
                    child: const Icon(Icons.savings, color: Colors.pink),
                  ),
                  title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.date)),
                  trailing: Text(
                    '-${NumberFormat('#,##0', 'en_US').format(tx.amount)} đ',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
