import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String? categoryId;
  final String? userId; // Added userId
  final String? transferId; // Added transferId for linking transfer transactions

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.categoryId,
    this.userId, // Added to constructor
    this.transferId, // Added to constructor
  });

  // Hàm chuyển đổi từ DocumentSnapshot của Firestore về Model của Flutter
  factory TransactionModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? 'Không tiêu đề',
      amount: (data['amount'] is int) ? (data['amount'] as int).toDouble() : data['amount'] ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isExpense: data['isExpense'] ?? true,
      categoryId: data['categoryId'] as String?,
      userId: data['userId'] as String?, // Parse userId
      transferId: data['transferId'] as String?, // Parse transferId
    );
  }

  // Hàm chuyển đổi từ Model Flutter sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
      'categoryId': categoryId,
      'userId': userId, // Include userId in map
      'transferId': transferId, // Include transferId in map
    };
  }
}