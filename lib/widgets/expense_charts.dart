import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/statistics.dart';

class ExpenseCharts {
  // Ensure we never pass zero/NaN as an interval to fl_chart (which asserts non-zero)
  static double _safeInterval(double value, [double factor = 0.25]) {
    if (value.isNaN || value <= 0) return 1.0;
    return value * factor;
  }
  /// Pie chart for expense breakdown by category
  static Widget buildCategoryPieChart(List<CategoryStatistics> categoryStats, {double height = 300}) {
    if (categoryStats.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Không có dữ liệu chi tiêu')),
      );
    }

    // Get only expense categories and top 5
    final expenseStats = categoryStats.where((stat) => stat.isExpense).take(5).toList();
    
    if (expenseStats.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Không có chi tiêu trong tháng')),
      );
    }

    // Calculate total for percentages
    final total = expenseStats.fold<double>(0, (sum, stat) => sum + stat.totalAmount);
    
    // Create pie sections
    final sections = expenseStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final percentage = (stat.totalAmount / total * 100);
      
      final colors = [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
      ];

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: stat.totalAmount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: expenseStats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            final colors = [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
            ];
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: Text(
                    stat.categoryName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Bar chart for monthly expense trend (last 6 months) - Highlights current month
  static Widget buildMonthlyTrendChart(List<MonthlyStatistics> monthlyStats, {double height = 300}) {
    if (monthlyStats.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Không có dữ liệu tháng')),
      );
    }

    // Take last 6 months
    final last6Months = monthlyStats.length > 6
        ? monthlyStats.sublist(monthlyStats.length - 6)
        : monthlyStats;

    // Find max value for scaling
    final maxValue = last6Months.fold<double>(
        0, (max, stat) => stat.totalExpense > max ? stat.totalExpense : max);

    // Get current month for highlighting
    final currentMonthIndex = last6Months.length - 1; // Last month is current

    // Create bar groups
    final barGroups = last6Months.asMap().entries.map((entry) {
      final stat = entry.value;
      final isCurrentMonth = entry.key == currentMonthIndex;
      
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: stat.totalExpense,
            color: isCurrentMonth ? Colors.red.shade600 : Colors.red.shade400,
            width: isCurrentMonth ? 20 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            rodStackItems: isCurrentMonth 
              ? [BarChartRodStackItem(0, stat.totalExpense, Colors.red.shade600)]
              : [],
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          // Ensure maxY is never zero to avoid fl_chart assertions
          maxY: (maxValue <= 0) ? 1.0 : maxValue * 1.1,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < last6Months.length) {
                    return Text(
                      'T${last6Months[index].month}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _safeInterval((maxValue <= 0) ? 1.0 : maxValue * 1.1, 0.25),
          ),
        ),
      ),
    );
  }

  /// Comparison chart: Current month vs last 5 months
  static Widget buildCurrentMonthComparisonChart(List<MonthlyStatistics> monthlyStats, {double height = 350}) {
    if (monthlyStats.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Không có dữ liệu so sánh')),
      );
    }

    // Get last 6 months (5 previous + 1 current)
    final last6Months = monthlyStats.length > 6
        ? monthlyStats.sublist(monthlyStats.length - 6)
        : monthlyStats;

    // Current month is the last one
    final currentMonth = last6Months.last;
    final previousMonths = last6Months.sublist(0, last6Months.length - 1);

    // Calculate average of previous months
    final avgExpense = previousMonths.isEmpty 
        ? 0 
        : previousMonths.fold<double>(0, (sum, stat) => sum + stat.totalExpense) / previousMonths.length;

    // Find max value for scaling
    final maxValue = [currentMonth.totalExpense, avgExpense * 1.5].reduce((a, b) => a > b ? a : b);

    // Create bar groups for comparison
    final barGroups = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: currentMonth.totalExpense,
            color: const Color(0xFFD82D8B), // Momo pink
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: avgExpense.toDouble(),
            color: Colors.orange.shade400,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              // Ensure maxY is never zero
              maxY: (maxValue <= 0) ? 1.0 : maxValue * 1.2,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                    reservedSize: 45,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = [
                        'Tháng ${currentMonth.month}\n(Hiện tại)',
                        'Trung bình\n5 tháng trước'
                      ];
                      final index = value.toInt();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          index >= 0 && index < labels.length ? labels[index] : '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                    reservedSize: 60,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _safeInterval((maxValue <= 0) ? 1.0 : maxValue * 1.2, 0.2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Info cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD82D8B).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD82D8B), width: 1),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tháng Này',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentMonth.totalExpense.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD82D8B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade400, width: 1),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Trung Bình',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${avgExpense.toStringAsFixed(0)}đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (currentMonth.totalExpense >= avgExpense ? Colors.red : Colors.green).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentMonth.totalExpense >= avgExpense ? Colors.red : Colors.green,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Chênh Lệch',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(currentMonth.totalExpense - avgExpense).toStringAsFixed(0)}đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: currentMonth.totalExpense >= avgExpense ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Line chart for income vs expense comparison
  static Widget buildIncomeVsExpenseChart(List<MonthlyStatistics> monthlyStats, {double height = 300}) {
    if (monthlyStats.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Không có dữ liệu so sánh')),
      );
    }

    // Take last 6 months
    final last6Months = monthlyStats.length > 6
        ? monthlyStats.sublist(monthlyStats.length - 6)
        : monthlyStats;

    // Find max value
    final maxValue = last6Months.fold<double>(0, (max, stat) {
      final value = stat.totalIncome > stat.totalExpense ? stat.totalIncome : stat.totalExpense;
      return value > max ? value : max;
    });

    // Create line spots for income and expense
    final incomeSpots = last6Months.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalIncome);
    }).toList();

    final expenseSpots = last6Months.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalExpense);
    }).toList();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          maxY: (maxValue <= 0) ? 1.0 : maxValue * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < last6Months.length) {
                    return Text(
                      'T${last6Months[index].month}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
        ),
      ),
    );
  }
}
