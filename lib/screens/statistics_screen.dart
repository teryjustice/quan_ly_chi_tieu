import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/statistics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../models/statistics.dart';
import '../widgets/expense_charts.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonState = ref.watch(monthComparisonProvider);
    final categoryStatsState = ref.watch(categoryStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Chi Tiêu'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Tạo dữ liệu mẫu',
            onPressed: () => _generateSampleData(context, ref),
          ),
        ],
      ),
      body: comparisonState.when(
        data: (comparison) {
          final currentExpense = comparison.currentMonth.totalExpense;
          final previousExpense = comparison.previousMonth.totalExpense;
          final percentChange = comparison.expenseChangePercent;
          final diff = comparison.expenseDifference;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thống kê chi tiêu tháng này
                _buildTotalExpenseCard(currentExpense, previousExpense, percentChange, diff),
                
                const SizedBox(height: 24),
                
                // 2. Mục đích sử dụng (Danh mục)
                const Text(
                  'Mục Đích Chi Tiêu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                categoryStatsState.when(
                  data: (categories) => _buildCategoryBreakdown(categories, currentExpense),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Lỗi tải dữ liệu: $e'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildTotalExpenseCard(double current, double previous, double percent, double diff) {
    final currencyFormat = NumberFormat.decimalPattern('vi_VN');
    final isIncrease = diff > 0;
    // Xử lý trường hợp tháng trước là 0
    final isInfinite = previous == 0 && current > 0; 
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tổng Chi Tiêu Tháng Này',
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            '${currencyFormat.format(current)}đ',
            style: const TextStyle(
              fontSize: 36, 
              fontWeight: FontWeight.bold,
              color: Colors.pink, // Đổi sang màu hồng
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (isIncrease ? Colors.pink : Colors.green).withAlpha(20), // Đổi sang màu hồng
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIncrease ? Icons.trending_up : Icons.trending_down,
                  color: isIncrease ? Colors.pink : Colors.green, // Đổi sang màu hồng
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isInfinite 
                      ? 'Mới phát sinh'
                      : '${percent.abs().toStringAsFixed(1)}% so với tháng trước',
                  style: TextStyle(
                    color: isIncrease ? Colors.pink : Colors.green, // Đổi sang màu hồng
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(${isIncrease ? "Tăng" : "Giảm"} ${currencyFormat.format(diff.abs())}đ)',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<CategoryStatistics> categories, double totalExpense) {
    if (categories.isEmpty) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("Chưa có dữ liệu chi tiêu trong tháng này."),
            ),
        );
    }
    
    // Lọc chỉ lấy expense và sắp xếp giảm dần
    final expenseCategories = categories.where((c) => c.isExpense).toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      
    if (expenseCategories.isEmpty) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("Không có khoản chi nào."),
            ),
        );
    }

    return Column(
      children: [
        // Biểu đồ tròn
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExpenseCharts.buildCategoryPieChart(categories, height: 250),
          ),
        ),
        const SizedBox(height: 24),
        
        // Danh sách chi tiết
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenseCategories.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = expenseCategories[index];
            final percent = totalExpense > 0 ? (item.totalAmount / totalExpense) : 0.0;
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.pink.withAlpha(20), // Đổi sang màu hồng
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.category_outlined, size: 24, color: Colors.pink), // Đổi sang màu hồng
              ),
              title: Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[200],
                      color: Colors.pink, // Đổi sang màu hồng
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat.decimalPattern('vi_VN').format(item.totalAmount)}đ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '${(percent * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Hàm tạo dữ liệu mẫu
  Future<void> _generateSampleData(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator())
    );

    try {
      final categories = await ref.read(categoryStreamProvider.future);
      await ref.read(statisticsServiceProvider).generateSampleData(user.uid, categories);
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo dữ liệu mẫu thành công!')),
        );
        ref.invalidate(monthComparisonProvider);
        ref.invalidate(lastMonthsStatsProvider);
        ref.invalidate(categoryStatsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo dữ liệu: $e')),
        );
      }
    }
  }
}
