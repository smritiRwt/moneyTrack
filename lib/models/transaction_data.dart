import 'package:expense/models/transaction_form.dart' show TransactionForm;

class TransactionData {
  final List<TransactionForm> transactions;
  final double totalExpenses;
  final double totalIncomes;

  TransactionData({
    required this.transactions,
    required this.totalExpenses,
    required this.totalIncomes,
  });
}
