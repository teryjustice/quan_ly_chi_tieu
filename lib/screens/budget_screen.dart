import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/models/category.dart';
import 'package:quan_ly_chi_tieu/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_chi_tieu/providers/category_provider.dart';

// Provider để lấy stream các budgets của user hiện tại
final budgetStreamProvider = StreamProvider.autoDispose((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('budgets')
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

// Provider để lấy stream các transaction của user trong tháng hiện tại
final monthlyTransactionsProvider = StreamProvider.autoDispose((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return FirebaseFirestore.instance
      .collection('transactions')
      .where('userId', isEqualTo: user.uid)
      .where('isExpense', isEqualTo: true)
      .where('date', isGreaterThanOrEqualTo: startOfMonth)
      .where('date', isLessThanOrEqualTo: endOfMonth)
      .snapshots();
});

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref, List<CategoryModel> categories) {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm danh mục chi tiêu trước khi tạo ngân sách.')),
      );
      return;
    }

    String selectedCategoryId = categories[0].id!;
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Thêm Ngân Sách Mới',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Chọn danh mục',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 20, color: cat.color),
                          const SizedBox(width: 10),
                          Text(cat.title),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedCategoryId = value;
                    }
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hạn mức (VNĐ)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'đ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Số tiền không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final amount = double.parse(amountController.text);
                      _addNewBudget(ref, selectedCategoryId, amount);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Lưu Ngân Sách', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNewBudget(WidgetRef ref, String categoryId, double limit) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final budgetsRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('budgets');
    final querySnapshot = await budgetsRef.where('categoryId', isEqualTo: categoryId).get();

    if (querySnapshot.docs.isNotEmpty) {
      await budgetsRef.doc(querySnapshot.docs.first.id).update({'limit': limit});
    } else {
      await budgetsRef.add({
        'categoryId': categoryId,
        'limit': limit,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final allCategoriesAsync = ref.watch(categoryStreamProvider);
    final budgetsAsync = ref.watch(budgetStreamProvider);
    final transactionsAsync = ref.watch(monthlyTransactionsProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Ngân Sách'),
      ),
      body: allCategoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải danh mục: $err')),
        data: (allCategories) {
          return budgetsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi tải ngân sách: $err')),
            data: (budgetsDocs) {
              if (budgetsDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Chưa có ngân sách nào', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddBudgetDialog(context, ref, allCategories),
                        child: const Text('Thêm ngay'),
                      )
                    ],
                  ),
                );
              }

              return transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Lỗi tải giao dịch: $err')),
                data: (txSnapshot) {
                  Map<String, double> spendingByCategory = {};
                  if (txSnapshot != null) {
                    for (var doc in txSnapshot.docs) {
                      final data = doc.data();
                      final amount = (data['amount'] as num).toDouble();
                      final catId = data['categoryId'] as String?;
                      if (catId != null) {
                        spendingByCategory[catId] = (spendingByCategory[catId] ?? 0) + amount;
                      }
                    }
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: budgetsDocs.length,
                    itemBuilder: (context, index) {
                      final budgetData = budgetsDocs[index].data() as Map<String, dynamic>;
                      // Sửa lỗi: Kiểm tra null cho categoryId
                      final categoryId = budgetData['categoryId'] as String?;
                      if (categoryId == null) {
                        // Bỏ qua item này nếu không có categoryId
                        return const SizedBox.shrink(); 
                      }

                      final limit = (budgetData['limit'] as num).toDouble();
                      final category = allCategories.firstWhere((c) => c.id == categoryId, orElse: () => CategoryModel(id: categoryId, title: 'Không rõ', icon: Icons.help, color: Colors.grey));
                      final spent = spendingByCategory[categoryId] ?? 0.0;
                      final percent = (limit > 0) ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                      final isOverBudget = spent > limit;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: category.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(category.icon, color: category.color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category.title,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '${NumberFormat('#,##0', 'en_US').format(limit)} đ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Đã chi: ${NumberFormat('#,##0', 'en_US').format(spent)} đ',
                                        style: TextStyle(
                                          color: isOverBudget ? Colors.red : Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${(percent * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: isOverBudget ? Colors.red : Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: percent,
                                    backgroundColor: Colors.grey[200],
                                    color: isOverBudget ? Colors.red : category.color,
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  if (isOverBudget)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Cảnh báo: Bạn đã chi vượt quá ngân sách!',
                                        style: TextStyle(color: Colors.red[700], fontSize: 12, fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Sửa lỗi: Truy cập dữ liệu category từ AsyncValue đã được watch ở trên
          final categories = allCategoriesAsync.value ?? [];
          _showAddBudgetDialog(context, ref, categories);
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm Ngân Sách'),
      ),
    );
  }
}
