import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart'; // Import provider danh mục
import '../providers/auth_provider.dart'; // Import auth provider

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  late bool _isExpense;
  late DateTime _selectedDate;
  String? _selectedCategoryId; // Biến lưu ID danh mục được chọn

  // Thêm biến để xác định đây là chế độ chỉnh sửa thực sự
  late bool isEditingMode;

  @override
  void initState() {
    super.initState();
    final tx = widget.transactionToEdit;

    // Chế độ chỉnh sửa chỉ được kích hoạt khi có ID
    isEditingMode = tx?.id != null;

    _titleController = TextEditingController(text: tx?.title ?? '');
    _amountController = TextEditingController(
        text: tx != null ? tx.amount.toStringAsFixed(0) : '');
    _isExpense = tx?.isExpense ?? true;
    _selectedDate = tx?.date ?? DateTime.now();
    _selectedCategoryId = tx?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      if (_isExpense && _selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn danh mục cho chi tiêu!')),
        );
        return;
      }

      final enteredTitle = _titleController.text;
      final enteredAmount = double.parse(_amountController.text);
      final service = ref.read(firestoreServiceProvider);
      final currentUser = ref.read(authStateChangesProvider).value;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để thực hiện!')),
        );
        return;
      }

      // Sửa logic: Chỉ update khi có ID, còn lại là add
      if (isEditingMode) {
        // --- CẬP NHẬT ---
        final updatedTx = TransactionModel(
          id: widget.transactionToEdit!.id,
          title: enteredTitle,
          amount: enteredAmount,
          date: _selectedDate,
          isExpense: _isExpense,
          categoryId: _isExpense ? _selectedCategoryId : null,
          userId: widget.transactionToEdit!.userId, 
        );
        service.updateTransaction(updatedTx);
      } else {
        // --- THÊM MỚI (bao gồm cả trường hợp Nạp tiền) ---
        final newTx = TransactionModel(
          title: enteredTitle,
          amount: enteredAmount,
          date: _selectedDate,
          isExpense: _isExpense,
          categoryId: _isExpense ? _selectedCategoryId : null,
          userId: currentUser.uid,
        );
        service.addTransaction(newTx);
      }

      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryStreamProvider);
    
    // Cách đơn giản nhất để test là check locale hiện tại:
    final currentLocale = Localizations.localeOf(context);
    final isEnglish = currentLocale.languageCode == 'en';

    final titleText = isEditingMode 
        ? (isEnglish ? 'Edit Transaction' : 'Chỉnh Sửa Giao Dịch')
        : (isEnglish ? 'Add Transaction' : 'Thêm Giao Dịch');
        
    final btnText = isEditingMode
        ? (isEnglish ? 'SAVE CHANGES' : 'LƯU THAY ĐỔI')
        : (isEnglish ? 'ADD TRANSACTION' : 'THÊM GIAO DỊCH');

    final expenseLabel = isEnglish ? 'EXPENSE' : 'CHI TIÊU';
    final incomeLabel = isEnglish ? 'INCOME' : 'NẠP TIỀN'; // Giữ nguyên nghĩa 'Nạp tiền' cho income context này
    final categoryLabel = isEnglish ? 'Select Category' : 'Chọn Danh mục';
    final noCategoryText = isEnglish ? 'No categories found.' : 'Chưa có danh mục nào.';
    final createCatText = isEnglish ? 'Please go to Admin menu to create categories.' : 'Vui lòng vào menu Admin để tạo danh mục trước.';
    final incomeInfo = isEnglish ? 'Income does not require a category' : 'Nạp tiền không cần chọn danh mục';
    final titleLabel = isEnglish ? 'Title / Note' : 'Tiêu đề / Ghi chú';
    final amountLabel = isEnglish ? 'Amount' : 'Số tiền';
    final dateLabel = isEnglish ? 'Date' : 'Ngày';
    final changeLabel = isEnglish ? 'Change' : 'Thay đổi';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: Colors.blue[100],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(expenseLabel),
                  selected: _isExpense,
                  selectedColor: Colors.redAccent,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: _isExpense ? Colors.white : Colors.black),
                  onSelected: (val) => setState(() => _isExpense = true),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: Text(incomeLabel),
                  selected: !_isExpense,
                  selectedColor: Colors.green,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: !_isExpense ? Colors.white : Colors.black),
                  onSelected: (val) => setState(() => _isExpense = false),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isExpense)
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
                data: (categories) {
                  if (categories.isEmpty) {
                    return ListTile(
                      title: Text(noCategoryText, style: const TextStyle(color: Colors.red)),
                      subtitle: Text(createCatText),
                    );
                  }
                  
                  if (_selectedCategoryId != null && 
                      !categories.any((c) => c.id == _selectedCategoryId)) {
                    _selectedCategoryId = null;
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: categoryLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    initialValue: _selectedCategoryId,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(category.icon, color: category.color),
                            const SizedBox(width: 10),
                            Text(category.title),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) => val == null ? (isEnglish ? 'Please select a category' : 'Vui lòng chọn danh mục') : null,
                  );
                },
              )
            else
               Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(incomeInfo, style: const TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: titleLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
              ),
              validator: (val) => val!.isEmpty ? (isEnglish ? 'Enter title' : 'Nhập tiêu đề') : null,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: amountLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'VNĐ',
              ),
              keyboardType: TextInputType.number,
              validator: (val) => val!.isEmpty ? (isEnglish ? 'Enter amount' : 'Nhập số tiền') : null,
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: _presentDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      '$dateLabel: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(changeLabel, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(btnText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
