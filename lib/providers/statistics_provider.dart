import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/statistics_service.dart';
import '../models/statistics.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'auth_provider.dart';
import 'category_provider.dart';
import 'transaction_provider.dart'; // Import for transactionStreamProvider
import 'package:flutter/material.dart'; // Import for Colors and Icons

final statisticsServiceProvider = Provider((ref) => StatisticsService());

/// Provider lấy tháng hiện tại
final currentMonthProvider = FutureProvider<MonthlyStatistics>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final service = ref.watch(statisticsServiceProvider);

  final user = authState.value;
  if (user == null) return Future.error('No user');

  final now = DateTime.now();
  // Re-evaluate this provider whenever the transaction stream changes
  ref.watch(transactionStreamProvider);
  return service.getMonthStatistics(user.uid, now.year, now.month);
});

/// Provider so sánh tháng này với tháng trước
final monthComparisonProvider = FutureProvider<ComparisonData>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final service = ref.watch(statisticsServiceProvider);

  final user = authState.value;
  if (user == null) return Future.error('No user');

  // Re-evaluate when transactions change so comparison stays up-to-date
  ref.watch(transactionStreamProvider);
  return service.compareWithPreviousMonth(user.uid);
});

/// Provider lấy danh sách giao dịch tháng này
final monthTransactionsProvider = FutureProvider<List<TransactionHistoryItem>>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final service = ref.watch(statisticsServiceProvider);
  final categoriesState = ref.watch(categoryStreamProvider);

  final user = authState.value;
  if (user == null) return Future.error('No user');

  // Ensure this provider refreshes when transactions update
  ref.watch(transactionStreamProvider);

  final now = DateTime.now();
  final transactions = await service.getMonthTransactions(user.uid, now.year, now.month);
  
  return categoriesState.when(
    data: (categories) {
      return transactions.map((t) {
        final category = categories.firstWhere(
          (c) => c.id == t.categoryId,
          orElse: () => CategoryModel(
            id: t.categoryId,
            title: 'Khác', // Changed from name to title
            icon: Icons.category, // Changed from String to IconData
            color: Colors.grey, // Added missing required argument
          ),
        );
        return TransactionHistoryItem(
          transaction: t,
          categoryName: category.title, // Changed from name to title
          categoryIcon: category.icon.codePoint.toString(), // Convert IconData to String
        );
      }).toList();
    },
    loading: () => throw 'Loading categories',
    error: (err, stack) => throw err,
  );
});

/// Provider lấy thống kê theo danh mục
final categoryStatsProvider = FutureProvider<List<CategoryStatistics>>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final service = ref.watch(statisticsServiceProvider);
  final categoriesState = ref.watch(categoryStreamProvider);

  final user = authState.value;
  if (user == null) return Future.error('No user');

  // Re-evaluate when transactions change
  ref.watch(transactionStreamProvider);

  final now = DateTime.now();

  return categoriesState.when(
    data: (categories) {
      return service.getCategoryStatistics(user.uid, now.year, now.month, categories);
    },
    loading: () => throw 'Loading categories',
    error: (err, stack) => throw err,
  );
});

/// Provider lấy 12 tháng gần đây
final lastMonthsStatsProvider = FutureProvider<List<MonthlyStatistics>>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final service = ref.watch(statisticsServiceProvider);

  final user = authState.value;
  if (user == null) return Future.error('No user');

  // Re-evaluate when transactions change
  ref.watch(transactionStreamProvider);
  return service.getLastMonthsStatistics(user.uid, 12);
});

/// Model trợ giúp để hiển thị lịch sử giao dịch
class TransactionHistoryItem {
  final TransactionModel transaction;
  final String categoryName;
  final String categoryIcon;

  TransactionHistoryItem({
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
  });
}
