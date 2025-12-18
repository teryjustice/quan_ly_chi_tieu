import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/statistics_provider.dart';
import '../models/statistics.dart'; // Added import for ComparisonData

class ComparisonDetailScreen extends ConsumerWidget {
  const ComparisonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonState = ref.watch(monthComparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('So Sánh Chi Tiêu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: comparisonState.when(
        data: (comparison) {
          final current = comparison.currentMonth;
          final previous = comparison.previousMonth;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần tổng quát
                _buildOverviewCard(context, comparison),
                const SizedBox(height: 24),

                // Phần chi tiết thu nhập
                _buildDetailSection(
                  'THU NHẬP',
                  current.totalIncome,
                  previous.totalIncome,
                  Colors.green,
                ),
                const SizedBox(height: 16),

                // Phần chi tiết chi tiêu
                _buildDetailSection(
                  'CHI TIÊU',
                  current.totalExpense,
                  previous.totalExpense,
                  Colors.red,
                ),
                const SizedBox(height: 16),

                // Phần chi tiết số dư
                _buildDetailSection(
                  'SỐ DƯ',
                  current.balance,
                  previous.balance,
                  Colors.blue,
                ),
                const SizedBox(height: 24),

                // Phần nhận xét
                _buildInsightsCard(comparison),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, ComparisonData comparison) {
    final current = comparison.currentMonth;
    final previous = comparison.previousMonth;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tháng Này', style: TextStyle(color: Colors.grey)),
                    Text(
                      'Tháng ${current.month}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.compare_arrows, size: 32, color: Colors.blue),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Tháng Trước', style: TextStyle(color: Colors.grey)),
                    Text(
                      'Tháng ${previous.month}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Giao Dịch: ${current.transactionCount} vs ${previous.transactionCount}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    double currentAmount,
    double previousAmount,
    Color color,
  ) {
    final difference = currentAmount - previousAmount;
    final percentChange = previousAmount != 0
        ? ((difference / previousAmount) * 100)
        : 0;
    final isIncrease = difference > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isIncrease ? Colors.red : Colors.green).withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isIncrease ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isIncrease ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tháng Này', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${currentAmount.toStringAsFixed(0)}đ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Tháng Trước', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${previousAmount.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chênh Lệch', style: TextStyle(fontSize: 12)),
                  Text(
                    '${isIncrease ? '+' : ''}${difference.toStringAsFixed(0)}đ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncrease ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(ComparisonData comparison) {
    final current = comparison.currentMonth;
    final previous = comparison.previousMonth;

    String insight = '';
    Color insightColor = Colors.blue;

    if (current.totalExpense > previous.totalExpense) {
      final increase = ((current.totalExpense - previous.totalExpense) / previous.totalExpense * 100);
      insight = '⚠️ Chi tiêu tăng ${increase.toStringAsFixed(1)}% so với tháng trước. Cần kiểm soát chi tiêu!';
      insightColor = Colors.red;
    } else if (current.totalExpense < previous.totalExpense) {
      final decrease = ((previous.totalExpense - current.totalExpense) / previous.totalExpense * 100);
      insight = '✅ Tốt! Chi tiêu giảm ${decrease.toStringAsFixed(1)}% so với tháng trước.';
      insightColor = Colors.green;
    } else {
      insight = '➡️ Chi tiêu bằng tháng trước. Giữ nguyên tình trạng hiện tại.';
    }

    if (current.balance > previous.balance) {
      insight += '\n💰 Số dư tăng, tài chính đang cải thiện!';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insightColor.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: insightColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhận Xét',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            insight,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
