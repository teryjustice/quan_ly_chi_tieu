import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/models/bill.dart';
import 'package:quan_ly_chi_tieu/providers/transaction_provider.dart';

class PaymentListScreen extends ConsumerWidget {
  const PaymentListScreen({super.key});

  void _showPaymentConfirmationDialog(BuildContext context, WidgetRef ref, BillModel bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: Text('Bạn có chắc chắn muốn thanh toán cho hóa đơn "${bill.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _handlePayment(ref, bill);
              Navigator.of(ctx).pop();
            },
            child: const Text('Thanh toán'),
          ),
        ],
      ),
    );
  }

  void _handlePayment(WidgetRef ref, BillModel bill) {
    ref.read(firestoreServiceProvider).updateBillStatus(bill.id!, true);
    // You might want to add a corresponding transaction as well
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Hóa Đơn'),
      ),
      body: billsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải hóa đơn: $err')),
        data: (bills) {
          if (bills.isEmpty) {
            return const Center(
              child: Text('Không có hóa đơn nào cần thanh toán.'),
            );
          }
          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (ctx, index) {
              final bill = bills[index];
              final isPaid = bill.isPaid;
              final isOverdue = !isPaid && bill.dueDate.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isPaid ? Colors.green[50] : (isOverdue ? Colors.red[50] : Colors.white),
                child: ListTile(
                  leading: Icon(
                    isPaid ? Icons.check_circle : (isOverdue ? Icons.warning : Icons.receipt_long),
                    color: isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
                  ),
                  title: Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số tiền: ${NumberFormat('#,##0', 'en_US').format(bill.amount)} đ'),
                      Text('Ngày hết hạn: ${DateFormat('dd/MM/yyyy').format(bill.dueDate)}'),
                    ],
                  ),
                  trailing: isPaid
                      ? const Text('Đã thanh toán', style: TextStyle(color: Colors.green))
                      : ElevatedButton(
                          onPressed: () => _showPaymentConfirmationDialog(context, ref, bill),
                          child: const Text('Thanh toán'),
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
