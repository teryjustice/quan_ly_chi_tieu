import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firestore_service.dart';
import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/promotion.dart';
import 'auth_provider.dart';

// 1. Service Provider
final firestoreServiceProvider = Provider((ref) => FirestoreService());

// 2. Transactions Stream Provider
final transactionStreamProvider = StreamProvider.autoDispose<List<TransactionModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authState = ref.watch(authStateChangesProvider);

  final user = authState.value;
  
  if (user == null) {
    return const Stream.empty();
  }

  return firestoreService.getTransactions(user.uid);
});

// 3. Bills Stream Provider (Thêm mới)
final billsStreamProvider = StreamProvider.autoDispose<List<BillModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  
  if (user == null) {
    return const Stream.empty();
  }

  return firestoreService.getBills(user.uid);
});

// 4. Promotions Stream Provider (Thêm mới)
final promotionsStreamProvider = StreamProvider.autoDispose<List<PromotionModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  // Ưu đãi thường chung cho mọi người, không cần userId
  return firestoreService.getPromotions();
});
