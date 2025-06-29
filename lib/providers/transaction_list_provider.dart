import 'package:expense/models/category_group.dart';
import 'package:expense/models/transaction_form.dart';
import 'package:intl/intl.dart';

class DateGroup {
  final String date;
  final List<CategoryGroup> categoryGroups;
  DateGroup({required this.date, required this.categoryGroups});
  Map<String, Map<String, List<TransactionForm>>>
  groupTransactionsByDateAndCategory(List<TransactionForm> transactions) {
    Map<String, Map<String, List<TransactionForm>>> groupedData = {};

    for (var txn in transactions) {
      final parsedDate = DateTime.tryParse(txn.date);
      if (parsedDate == null) continue; // skip invalid date

      final dateKey = DateFormat('EEEE, d MMM').format(parsedDate);
      final categoryKey = txn.category;

      groupedData.putIfAbsent(dateKey, () => {});
      groupedData[dateKey]!.putIfAbsent(categoryKey, () => []);
      groupedData[dateKey]![categoryKey]!.add(txn);
    }

    return groupedData;
  }
}
