class MonthlyStatistics {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;

  MonthlyStatistics({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });

  // Tính % chi tiêu
  double get expensePercentage {
    double total = totalIncome + totalExpense;
    return total > 0 ? (totalExpense / total * 100) : 0;
  }

  // Tính % thu nhập
  double get incomePercentage {
    double total = totalIncome + totalExpense;
    return total > 0 ? (totalIncome / total * 100) : 0;
  }
}

class CategoryStatistics {
  final String categoryId;
  final String categoryName;
  final double totalAmount;
  final int transactionCount;
  final bool isExpense;

  CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.transactionCount,
    required this.isExpense,
  });
}

class ComparisonData {
  final MonthlyStatistics currentMonth;
  final MonthlyStatistics previousMonth;

  ComparisonData({
    required this.currentMonth,
    required this.previousMonth,
  });

  // % thay đổi chi tiêu
  double get expenseChangePercent {
    if (previousMonth.totalExpense == 0) return 0;
    return ((currentMonth.totalExpense - previousMonth.totalExpense) / previousMonth.totalExpense * 100);
  }

  // % thay đổi thu nhập
  double get incomeChangePercent {
    if (previousMonth.totalIncome == 0) return 0;
    return ((currentMonth.totalIncome - previousMonth.totalIncome) / previousMonth.totalIncome * 100);
  }

  // Chênh lệch số tiền chi tiêu
  double get expenseDifference => currentMonth.totalExpense - previousMonth.totalExpense;

  // Chênh lệch số tiền thu nhập
  double get incomeDifference => currentMonth.totalIncome - previousMonth.totalIncome;
}
