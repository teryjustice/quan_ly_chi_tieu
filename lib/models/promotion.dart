import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  String? id;
  final String title;
  final String description;
  final String code;
  final DateTime expiryDate;
  final double discountAmount;

  PromotionModel({
    this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.expiryDate,
    required this.discountAmount,
  });

  factory PromotionModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PromotionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      code: data['code'] ?? '',
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      discountAmount: (data['discountAmount'] is int) ? (data['discountAmount'] as int).toDouble() : data['discountAmount'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'code': code,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'discountAmount': discountAmount,
    };
  }
}
