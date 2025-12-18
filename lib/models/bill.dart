import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  String? id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String userId; // Hóa đơn của user nào

  BillModel({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.userId,
  });

  factory BillModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] is int) ? (data['amount'] as int).toDouble() : data['amount'] ?? 0.0,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'userId': userId,
    };
  }
}
