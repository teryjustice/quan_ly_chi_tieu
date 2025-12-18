import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/bill.dart'; // Import model Bill
import '../models/promotion.dart'; // Import model Promotion
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ----------------------------------------------------
  // 1. KHAI BÁO COLLECTION REFERENCES
  // ----------------------------------------------------

  final CollectionReference transactionsRef =
      FirebaseFirestore.instance.collection('transactions');

  final CollectionReference categoriesRef =
      FirebaseFirestore.instance.collection('categories');

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // Thêm tham chiếu đến bills và promotions
  final CollectionReference billsRef = FirebaseFirestore.instance.collection('bills');
  final CollectionReference promotionsRef = FirebaseFirestore.instance.collection('promotions');

  // ----------------------------------------------------
  // 2. CRUD CHO GIAO DỊCH (TRANSACTION)
  // ----------------------------------------------------

  Stream<List<TransactionModel>> getTransactions(String userId) {
    return transactionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromSnapshot(doc);
      }).toList();
    });
  }

  // Hàm lấy danh sách giao dịch gần đây (Future) dùng cho AI
  Future<List<TransactionModel>> getRecentTransactions(String userId, {int limit = 20}) async {
    final snapshot = await transactionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => TransactionModel.fromSnapshot(doc)).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await transactionsRef.add(transaction.toMap());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;
    await transactionsRef.doc(transaction.id!).update(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await transactionsRef.doc(id).delete();
  }

  // ----------------------------------------------------
  // 3. CHỨC NĂNG CHUYỂN TIỀN
  // ----------------------------------------------------

  Future<DocumentSnapshot?> _getUserDocByEmail(String email) async {
    final querySnapshot = await usersRef.where('email', isEqualTo: email).limit(1).get();
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
  }

  Future<double> getCurrentBalance(String userId) async {
    final querySnapshot = await transactionsRef.where('userId', isEqualTo: userId).get();
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
    return totalIncome - totalExpense;
  }

  Future<bool> transferMoney({
    required String senderId,
    required String senderEmail,
    required String recipientEmail,
    required double amount,
    String message = '',
  }) async {
    try {
      final recipientUserDoc = await _getUserDocByEmail(recipientEmail);
      if (recipientUserDoc == null) return false;

      final recipientId = recipientUserDoc.id;
      if (senderId == recipientId) return false;

      final senderBalance = await getCurrentBalance(senderId);
      if (senderBalance < amount) return false;

      final batch = _firestore.batch();
      final String transferId = _uuid.v4();

      final senderTransaction = TransactionModel(
        title: 'Chuyển tiền đến $recipientEmail',
        amount: amount,
        date: DateTime.now(),
        isExpense: true,
        categoryId: null,
        userId: senderId,
        transferId: transferId,
      );
      batch.set(transactionsRef.doc(), senderTransaction.toMap());

      final recipientTransaction = TransactionModel(
        title: 'Nhận tiền từ $senderEmail',
        amount: amount,
        date: DateTime.now(),
        isExpense: false,
        categoryId: null,
        userId: recipientId,
        transferId: transferId,
      );
      batch.set(transactionsRef.doc(), recipientTransaction.toMap());

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ----------------------------------------------------
  // 4. CRUD CHO DANH MỤC (CATEGORY)
  // ----------------------------------------------------

  Stream<List<CategoryModel>> getCategoriesStream() {
    return categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            return CategoryModel.fromMap(data, doc.id);
          }
          return CategoryModel(id: doc.id, title: 'Lỗi dữ liệu', icon: Icons.error, color: Colors.grey);
        } catch (e) {
          return CategoryModel(id: doc.id, title: 'Lỗi hiển thị', icon: Icons.error, color: Colors.red);
        }
      }).toList();
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    await categoriesRef.add(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (category.id == null) return;
    await categoriesRef.doc(category.id!).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await categoriesRef.doc(id).delete();
  }

  // ----------------------------------------------------
  // 5. CHỨC NĂNG BÁO CÁO
  // ----------------------------------------------------

  Future<double> getExpensesInDateRange(String userId, DateTime startDate, DateTime endDate) async {
    double totalExpense = 0;
    final querySnapshot = await transactionsRef
        .where('userId', isEqualTo: userId)
        .where('isExpense', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    for (var doc in querySnapshot.docs) {
      final transaction = TransactionModel.fromSnapshot(doc);
      totalExpense += transaction.amount;
    }
    return totalExpense;
  }

  Future<Map<String, double>> compareMonthlyExpenses(String userId) async {
    final now = DateTime.now();
    final startOfCurrentMonth = DateTime(now.year, now.month, 1);
    final endOfCurrentMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPreviousMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

    double currentMonthExpense = 0;
    double previousMonthExpense = 0;

    final currentMonthSnapshot = await transactionsRef
        .where('userId', isEqualTo: userId)
        .where('isExpense', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: startOfCurrentMonth)
        .where('date', isLessThanOrEqualTo: endOfCurrentMonth)
        .get();
    for (var doc in currentMonthSnapshot.docs) {
      currentMonthExpense += TransactionModel.fromSnapshot(doc).amount;
    }

    final previousMonthSnapshot = await transactionsRef
        .where('userId', isEqualTo: userId)
        .where('isExpense', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: startOfPreviousMonth)
        .where('date', isLessThanOrEqualTo: endOfPreviousMonth)
        .get();
    for (var doc in previousMonthSnapshot.docs) {
      previousMonthExpense += TransactionModel.fromSnapshot(doc).amount;
    }

    return {'currentMonth': currentMonthExpense, 'previousMonth': previousMonthExpense};
  }

  Future<Map<String, double>> compareAnnualExpenses(String userId) async {
    final now = DateTime.now();
    final startOfCurrentYear = DateTime(now.year, 1, 1);
    final endOfCurrentYear = DateTime(now.year, 12, 31, 23, 59, 59);
    final startOfPreviousYear = DateTime(now.year - 1, 1, 1);
    final endOfPreviousYear = DateTime(now.year - 1, 12, 31, 23, 59, 59);

    double currentYearExpense = 0;
    double previousYearExpense = 0;

    final currentYearSnapshot = await transactionsRef
        .where('userId', isEqualTo: userId)
        .where('isExpense', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: startOfCurrentYear)
        .where('date', isLessThanOrEqualTo: endOfCurrentYear)
        .get();
    for (var doc in currentYearSnapshot.docs) {
      currentYearExpense += TransactionModel.fromSnapshot(doc).amount;
    }

    final previousYearSnapshot = await transactionsRef
        .where('userId', isEqualTo: userId)
        .where('isExpense', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: startOfPreviousYear)
        .where('date', isLessThanOrEqualTo: endOfPreviousYear)
        .get();
    for (var doc in previousYearSnapshot.docs) {
      previousYearExpense += TransactionModel.fromSnapshot(doc).amount;
    }

    return {'currentYear': currentYearExpense, 'previousYear': previousYearExpense};
  }

  // ----------------------------------------------------
  // 6. CRUD CHO HÓA ĐƠN (BILLS)
  // ----------------------------------------------------

  Stream<List<BillModel>> getBills(String userId) {
    // Tạm thời bỏ orderBy để tránh lỗi index, user sẽ tự sort ở client nếu cần
    // Hoặc user phải tạo composite index trên Firestore
    return billsRef
        .where('userId', isEqualTo: userId)
        //.orderBy('dueDate') // Tạm comment lại để fix lỗi "FAILED_PRECONDITION"
        .snapshots()
        .map((snapshot) {
          final bills = snapshot.docs.map((doc) => BillModel.fromSnapshot(doc)).toList();
          // Sort thủ công ở client
          bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return bills;
    });
  }

  Future<void> addBill(BillModel bill) async {
    await billsRef.add(bill.toMap());
  }

  Future<void> updateBillStatus(String id, bool isPaid) async {
    await billsRef.doc(id).update({'isPaid': isPaid});
  }

  // ----------------------------------------------------
  // 7. CRUD CHO ƯU ĐÃI (PROMOTIONS)
  // ----------------------------------------------------
  
  // Ưu đãi thường là chung cho mọi user, hoặc filter theo điều kiện
  Stream<List<PromotionModel>> getPromotions() {
    return promotionsRef
        .orderBy('expiryDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PromotionModel.fromSnapshot(doc)).toList();
    });
  }
}
