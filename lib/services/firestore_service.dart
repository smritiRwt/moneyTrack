import 'package:expense/models/income_form.dart';
import 'package:expense/models/transaction_form.dart';
import 'package:expense/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    } else {
      return null;
    }
  }

  Future<void> addTransaction(TransactionForm transaction) async {
    await _firestore.collection('transactions').add(transaction.toMap());
  }

  Future<void> addIncome(IncomeForm transaction) async {
    await _firestore.collection('income').add(transaction.toMap());
  }

  // Delete transaction by document ID
  Future<void> deleteTransaction(String documentId) async {
    await _firestore.collection('transactions').doc(documentId).delete();
  }

  // Delete income by document ID
  Future<void> deleteIncome(String documentId) async {
    await _firestore.collection('income').doc(documentId).delete();
  }

  // Update transaction by document ID
  Future<void> updateTransaction(
    String documentId,
    TransactionForm transaction,
  ) async {
    await _firestore
        .collection('transactions')
        .doc(documentId)
        .update(transaction.toMap());
  }

  // Update income by document ID
  Future<void> updateIncome(String documentId, IncomeForm income) async {
    await _firestore
        .collection('income')
        .doc(documentId)
        .update(income.toMap());
  }

  Future<List<TransactionForm>> fetchLastTransactions({
    required String uid,
    required String collectionName,
    required int limit,
  }) async {
    final snapshot =
        await _firestore
            .collection(collectionName)
            .where('uid', isEqualTo: uid)
            .orderBy('completeDate', descending: true)
            .limit(limit)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TransactionForm.fromMap(data, documentId: doc.id);
    }).toList();
  }
}
