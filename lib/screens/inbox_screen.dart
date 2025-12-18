import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/bill.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hộp thư đến'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Giao dịch'),
              Tab(text: 'Hóa đơn'),
              Tab(text: 'Ưu đãi'),
            ],
          ),
        ),
        body: Container(
          color: Colors.grey[100],
          child: TabBarView(
            children: [
              _buildTransactionTab(context, ref),
              _buildBillTab(context, ref),
              _buildPromotionTab(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  // --- Tab 1: Giao dịch (Lấy dữ liệu thực từ Firestore) ---
  Widget _buildTransactionTab(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionStreamProvider);

    return transactionsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(child: Text('Chưa có thông báo giao dịch nào.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            
            // Xây dựng nội dung thông báo dựa trên giao dịch
            String title = tx.isExpense ? 'Giao dịch chi tiêu' : 'Giao dịch thu nhập';
            if (tx.transferId != null) {
               title = tx.isExpense ? 'Chuyển tiền thành công' : 'Nhận tiền thành công';
            }
            
            String body = '${tx.title} - Số tiền: ${NumberFormat('#,##0', 'en_US').format(tx.amount)} đ';

            return _buildNotificationItem(
              icon: tx.isExpense ? Icons.arrow_outward : Icons.arrow_downward, // Expense: Out, Income: In
              iconColor: tx.isExpense ? Colors.red : Colors.green,
              title: title,
              body: body,
              time: tx.date,
            );
          },
        );
      },
    );
  }

  // --- Tab 2: Hóa đơn (Lấy dữ liệu thực từ Firestore) ---
  Widget _buildBillTab(BuildContext context, WidgetRef ref) {
    final billsAsyncValue = ref.watch(billsStreamProvider);

    return billsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (bills) {
        if (bills.isEmpty) {
          return const Center(child: Text('Chưa có hóa đơn nào.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            final bill = bills[index];
            final isPaid = bill.isPaid;
            final dueDateStr = DateFormat('dd/MM/yyyy').format(bill.dueDate);
            final amountStr = NumberFormat('#,##0', 'en_US').format(bill.amount);

            return _buildNotificationItem(
              icon: Icons.receipt_long,
              iconColor: isPaid ? Colors.green : Colors.amber,
              title: bill.title,
              body: 'Số tiền: $amountStr đ\nHạn chót: $dueDateStr',
              time: bill.dueDate, 
              trailing: isPaid
                  ? const Text('Đã xong', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                  : ElevatedButton(
                      onPressed: () {
                         _showPaymentDialog(context, ref, bill);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Thanh toán'),
                    ),
            );
          },
        );
      },
    );
  }

  // Hàm hiển thị Dialog xác nhận thanh toán
  void _showPaymentDialog(BuildContext context, WidgetRef ref, BillModel bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: Text('Bạn có chắc chắn muốn thanh toán hóa đơn "${bill.title}" với số tiền ${NumberFormat('#,##0', 'en_US').format(bill.amount)} đ không?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Thanh toán'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              
              // 1. Cập nhật trạng thái hóa đơn thành Đã thanh toán
              final firestoreService = ref.read(firestoreServiceProvider);
              if (bill.id != null) {
                await firestoreService.updateBillStatus(bill.id!, true);
              }

              // 2. Tự động tạo một giao dịch chi tiêu tương ứng
              final transaction = TransactionModel(
                title: 'Thanh toán hóa đơn: ${bill.title}',
                amount: bill.amount,
                date: DateTime.now(),
                isExpense: true,
                categoryId: null, // Hoặc có thể thêm logic chọn Category "Hóa đơn"
                userId: bill.userId,
              );
              await firestoreService.addTransaction(transaction);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thanh toán thành công! Đã tạo giao dịch chi tiêu.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }


  // --- Tab 3: Ưu đãi (Lấy dữ liệu thực từ Firestore) ---
  Widget _buildPromotionTab(BuildContext context, WidgetRef ref) {
    final promotionsAsyncValue = ref.watch(promotionsStreamProvider);

    return promotionsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (promotions) {
        if (promotions.isEmpty) {
          return const Center(child: Text('Chưa có ưu đãi nào.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: promotions.length,
          itemBuilder: (context, index) {
            final promo = promotions[index];
            final expiryStr = DateFormat('dd/MM/yyyy').format(promo.expiryDate);

            return _buildNotificationItem(
              icon: Icons.local_offer,
              iconColor: Colors.purple,
              title: promo.title,
              body: '${promo.description}\nMã: ${promo.code} (HSD: $expiryStr)',
              time: DateTime.now(),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.grey),
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Đã sao chép mã: ${promo.code}')),
                   );
                },
              )
            );
          },
        );
      },
    );
  }

  // --- Helper Widget cho từng dòng thông báo ---
  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required DateTime time,
    Widget? trailing,
  }) {
    final timeStr = DateFormat('HH:mm dd/MM').format(time);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(timeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: trailing,
        onTap: () {
          // Xử lý khi bấm vào thông báo (chi tiết)
        },
      ),
    );
  }
}
