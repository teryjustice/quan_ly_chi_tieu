import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';
import '../models/statistics.dart';
import '../models/category.dart';
import 'package:flutter/material.dart'; // Import for Colors and Icons
import 'dart:math'; // Import for Random

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy thống kê tháng cụ thể
  Future<MonthlyStatistics> getMonthStatistics(String userId, int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .get();

      double totalIncome = 0;
      double totalExpense = 0;

      for (var doc in querySnapshot.docs) {
        final transaction = TransactionModel.fromSnapshot(doc);
        if (transaction.isExpense) {
          totalExpense += transaction.amount;
        } else {
          totalIncome += transaction.amount;
        }
      }

      return MonthlyStatistics(
        year: year,
        month: month,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        transactionCount: querySnapshot.docs.length,
      );
    } catch (e) {
      // ignore: avoid_print
      // print('Error getting month statistics: $e');
      return MonthlyStatistics(
        year: year,
        month: month,
        totalIncome: 0,
        totalExpense: 0,
        balance: 0,
        transactionCount: 0,
      );
    }
  }

  /// So sánh tháng hiện tại với tháng trước
  Future<ComparisonData> compareWithPreviousMonth(String userId) async {
    final now = DateTime.now();
    final currentMonth = await getMonthStatistics(userId, now.year, now.month);

    int previousYear = now.year;
    int previousMonth = now.month - 1;
    if (previousMonth < 1) {
      previousMonth = 12;
      previousYear--;
    }

    final prevMonth = await getMonthStatistics(userId, previousYear, previousMonth);

    return ComparisonData(
      currentMonth: currentMonth,
      previousMonth: prevMonth,
    );
  }

  /// Lấy danh sách giao dịch theo tháng
  Future<List<TransactionModel>> getMonthTransactions(String userId, int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting month transactions: $e');
      return [];
    }
  }

  /// Lấy thống kê chi tiêu theo danh mục (tháng hiện tại)
  Future<List<CategoryStatistics>> getCategoryStatistics(
      String userId, int year, int month, List<CategoryModel> categories) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .get();

      Map<String, CategoryStatistics> categoryMap = {};

      for (var doc in querySnapshot.docs) {
        final transaction = TransactionModel.fromSnapshot(doc);

        // Only include expenses with a category
        if (transaction.isExpense && transaction.categoryId != null) {
          final String currentCategoryId = transaction.categoryId!;

          // Tìm tên danh mục
          final category = categories.firstWhere(
            (c) => c.id == currentCategoryId,
            orElse: () => CategoryModel(
              id: currentCategoryId,
              title: 'Khác',
              icon: Icons.category,
              color: Colors.grey,
            ),
          );

          if (categoryMap.containsKey(currentCategoryId)) {
            final existing = categoryMap[currentCategoryId]!;
            categoryMap[currentCategoryId] = CategoryStatistics(
              categoryId: currentCategoryId,
              categoryName: category.title,
              totalAmount: existing.totalAmount + transaction.amount,
              transactionCount: existing.transactionCount + 1,
              isExpense: transaction.isExpense,
            );
          } else {
            categoryMap[currentCategoryId] = CategoryStatistics(
              categoryId: currentCategoryId,
              categoryName: category.title,
              totalAmount: transaction.amount,
              transactionCount: 1,
              isExpense: transaction.isExpense,
            );
          }
        }
      }

      return categoryMap.values.toList()..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    } catch (e) {
      // ignore: avoid_print
      print('Error getting category statistics: $e');
      return [];
    }
  }

  /// Lấy dữ liệu thống kê các tháng gần đây (12 tháng) - Optimized single query
  Future<List<MonthlyStatistics>> getLastMonthsStatistics(String userId, int months) async {
    try {
      final now = DateTime.now();
      
      // Calculate start date (12 months ago)
      int startMonth = now.month - months + 1;
      int startYear = now.year;
      
      if (startMonth < 1) {
        startMonth += 12;
        startYear--;
      }
      
      final startDate = DateTime(startYear, startMonth, 1);
      final endDate = DateTime(now.year, now.month + 1, 1); // Next month 1st
      
      // ignore: avoid_print
      print('[DEBUG] Query transactions from $startDate to $endDate for userId: $userId');
      
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .get();
      
      // ignore: avoid_print
      print('[DEBUG] Got ${querySnapshot.docs.length} transactions');
      
      // Group by month
      Map<String, MonthlyStatistics> monthlyMap = {};
      
      for (var doc in querySnapshot.docs) {
        final transaction = TransactionModel.fromSnapshot(doc);
        final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
        
        if (monthlyMap.containsKey(monthKey)) {
          final existing = monthlyMap[monthKey]!;
          monthlyMap[monthKey] = MonthlyStatistics(
            year: transaction.date.year,
            month: transaction.date.month,
            totalIncome: existing.totalIncome + (transaction.isExpense ? 0 : transaction.amount),
            totalExpense: existing.totalExpense + (transaction.isExpense ? transaction.amount : 0),
            balance: existing.balance + (transaction.isExpense ? -transaction.amount : transaction.amount),
            transactionCount: existing.transactionCount + 1,
          );
        } else {
          monthlyMap[monthKey] = MonthlyStatistics(
            year: transaction.date.year,
            month: transaction.date.month,
            totalIncome: transaction.isExpense ? 0 : transaction.amount,
            totalExpense: transaction.isExpense ? transaction.amount : 0,
            balance: transaction.isExpense ? -transaction.amount : transaction.amount,
            transactionCount: 1,
          );
        }
      }
      
      // Fill missing months with zero stats
      List<MonthlyStatistics> result = [];
      for (int i = 0; i < months; i++) {
        int month = startMonth + i;
        int year = startYear;
        
        if (month > 12) {
          month -= 12;
          year++;
        }
        
        final monthKey = '$year-${month.toString().padLeft(2, '0')}';
        result.add(monthlyMap[monthKey] ?? MonthlyStatistics(
          year: year,
          month: month,
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 0,
        ));
      }
      
      // ignore: avoid_print
      print('[DEBUG] Returning ${result.length} months of statistics');
      return result;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting last months statistics: $e');
      return [];
    }
  }

  /// Hàm tạo dữ liệu mẫu (Sample Data)
  Future<void> generateSampleData(String userId, List<CategoryModel> categories) async {
    final random = Random();
    final batch = _firestore.batch();
    
    // Sử dụng danh mục hiện có hoặc danh mục mặc định nếu chưa có
    final sourceCategories = categories.isNotEmpty ? categories : [
      CategoryModel(id: 'food', title: 'Ăn Uống', icon: Icons.fastfood, color: Colors.orange),
      CategoryModel(id: 'transport', title: 'Di Chuyển', icon: Icons.directions_car, color: Colors.blue),
      CategoryModel(id: 'shopping', title: 'Mua Sắm', icon: Icons.shopping_bag, color: Colors.purple),
      CategoryModel(id: 'entertainment', title: 'Giải Trí', icon: Icons.movie, color: Colors.teal),
    ];

    // Tạo khoảng 30-50 giao dịch trong 6 tháng gần đây
    final int count = 30 + random.nextInt(20);
    
    for (int i = 0; i < count; i++) {
      final docRef = _firestore.collection('transactions').doc();
      
      // Random ngày trong 180 ngày qua
      final daysAgo = random.nextInt(180);
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      
      // Random loại giao dịch (20% là thu nhập, 80% là chi tiêu)
      final isIncome = random.nextInt(10) < 2;
      
      double amount;
      String title;
      String? categoryId;
      
      if (isIncome) {
        amount = (5000 + random.nextInt(20000)) * 1000.0; // 5tr - 25tr
        title = 'Lương/Thưởng tháng ${date.month}';
        // Thu nhập thường ko cần categoryId hoặc category riêng, ở đây để null
        categoryId = null;
      } else {
        amount = (20 + random.nextInt(500)) * 1000.0; // 20k - 520k
        final cat = sourceCategories[random.nextInt(sourceCategories.length)];
        title = '${cat.title} ${random.nextInt(100)}';
        categoryId = cat.id;
      }

      batch.set(docRef, {
        'title': title,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'isExpense': !isIncome,
        'categoryId': categoryId,
        'userId': userId,
      });
    }

    await batch.commit();
  }
}
