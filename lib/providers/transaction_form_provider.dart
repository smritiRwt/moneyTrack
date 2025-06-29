import 'package:expense/models/transaction_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final transactionFormProvider =
    StateNotifierProvider<TransactionFormNotifier, TransactionForm>((ref) {
      return TransactionFormNotifier();
    });

class TransactionFormNotifier extends StateNotifier<TransactionForm> {
  TransactionFormNotifier()
    : super(
        TransactionForm(
          amount: '',
          category: '',
          type: 'expense',
          paymentType: '',
          date: '',
          completeDate: '',
          uid: '',
          documentId: null,
        ),
      );

  void updateAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void updatePaymentType(String paymentType) {
    state = state.copyWith(paymentType: paymentType);
  }

  void updateDate(String date) {
    state = state.copyWith(date: date);
  }

  void updateUid(String uid) {
    state = state.copyWith(uid: uid);
  }

  void reset() {
    state = TransactionForm(
      completeDate: '',
      amount: '',
      category: '',
      paymentType: '',
      date: '',
      type: 'expense',
      uid: '',
      documentId: null,
    );
  }
}
