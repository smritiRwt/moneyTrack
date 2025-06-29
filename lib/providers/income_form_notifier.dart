import 'package:expense/models/income_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class IncomeFormNotifier extends StateNotifier<IncomeForm> {
  IncomeFormNotifier()
    : super(
        IncomeForm(
          date: '',
          amount: '',
          category: '',
          type: 'income',
          paymentType: '',
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

  void reset() {
    state = IncomeForm(
      date: '',
      amount: '',
      category: '',
      type: 'income',
      paymentType: '',
      completeDate: '',
      uid: '',
      documentId: null,
    );
  }
}

// Riverpod provider for the notifier
final incomeFormProvider =
    StateNotifierProvider<IncomeFormNotifier, IncomeForm>((ref) {
      return IncomeFormNotifier();
    });
