import 'package:expense/models/transaction_form.dart';

class CategoryGroup {
  final String category;
  final List<TransactionForm> transactions;

  CategoryGroup({required this.category, required this.transactions});
}

class DateGroup {
  final String date; // e.g., '2025-06-01'
  final List<CategoryGroup> categoryGroups;

  DateGroup({required this.date, required this.categoryGroups});
}
