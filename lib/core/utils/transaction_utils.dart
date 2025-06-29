import 'package:expense/models/transaction_form.dart';

Map<String, Map<String, List<TransactionForm>>> groupByDateAndCategory(
  List<TransactionForm> transactions,
) {
  final Map<String, Map<String, List<TransactionForm>>> grouped = {};

  for (final txn in transactions) {
    final dateKey = txn.date;
    final categoryKey = txn.category;

    grouped.putIfAbsent(dateKey, () => {});
    grouped[dateKey]!.putIfAbsent(categoryKey, () => []);
    grouped[dateKey]![categoryKey]!.add(txn);
  }

  return grouped;
}

/// Calculate totals for a specific date
class DateTotals {
  final double totalExpenses;
  final double totalIncomes;
  final double net;

  DateTotals({required this.totalExpenses, required this.totalIncomes})
    : net = totalIncomes - totalExpenses;
}

DateTotals calculateDateTotals(Map<String, List<TransactionForm>> categories) {
  double totalExpenses = 0.0;
  double totalIncomes = 0.0;

  for (final transactions in categories.values) {
    for (final txn in transactions) {
      final amount = double.tryParse(txn.amount) ?? 0.0;
      if (txn.type == 'expense') {
        totalExpenses += amount;
      } else if (txn.type == 'income') {
        totalIncomes += amount;
      }
    }
  }

  return DateTotals(totalExpenses: totalExpenses, totalIncomes: totalIncomes);
}
