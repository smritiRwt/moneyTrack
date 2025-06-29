import 'package:expense/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_form.dart';

// Provide current user UID
final currentUserUidProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

// Provide FirestoreTransactionService instance
final firestoreTransactionServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Last 3 Expenses
final last3ExpensesProvider = FutureProvider.autoDispose<List<TransactionForm>>(
  (ref) async {
    final uid = ref.watch(currentUserUidProvider);
    if (uid == null) return [];

    final service = ref.read(firestoreTransactionServiceProvider);
    return await service.fetchLastTransactions(
      uid: uid,
      collectionName: 'transactions',
      limit: 3,
    );
  },
);

// Last 3 Incomes
final last3IncomesProvider = FutureProvider.autoDispose<List<TransactionForm>>((
  ref,
) async {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) return [];

  final service = ref.read(firestoreTransactionServiceProvider);
  return await service.fetchLastTransactions(
    uid: uid,
    collectionName: 'income',
    limit: 3,
  );
});
