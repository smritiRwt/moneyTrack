import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final monthlyTransactionCountProvider =
    FutureProvider.family<Map<String, int>, DateTime>((
      ref,
      selectedMonth,
    ) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return {"income": 0, "expense": 0};

      final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endOfMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      final expenseQuery = FirebaseFirestore.instance
          .collection('transactions')
          .where('uid', isEqualTo: uid)
          .where(
            'completeDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'completeDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          );

      final incomeQuery = FirebaseFirestore.instance
          .collection('income')
          .where('uid', isEqualTo: uid)
          .where(
            'completeDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'completeDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          );

      final expenseSnapshot = await expenseQuery.get();
      final incomeSnapshot = await incomeQuery.get();

      return {"expense": expenseSnapshot.size, "income": incomeSnapshot.size};
    });

Future<double> getMonthlyExpenseTotal(
  String uid,
  DateTime selectedMonth,
) async {
  final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
  final endOfMonth = DateTime(
    selectedMonth.year,
    selectedMonth.month + 1,
    0,
    23,
    59,
    59,
  );

  print('Start of month: $startOfMonth');
  print('End of month: $endOfMonth');

  double total = 0;

  final snapshot =
      await FirebaseFirestore.instance
          .collection('transactions')
          .where('uid', isEqualTo: uid)
          .get();

  for (var doc in snapshot.docs) {
    final dateStr = doc['completeDate'];
    final amount = doc['amount'];

    if (dateStr == null || amount == null) continue;

    try {
      final parsedDate = DateTime.parse(dateStr);
      if (parsedDate.isAfter(
            startOfMonth.subtract(const Duration(seconds: 1)),
          ) &&
          parsedDate.isBefore(endOfMonth.add(const Duration(seconds: 1)))) {
        final parsedAmount =
            amount is num
                ? amount.toDouble()
                : double.tryParse(amount.toString());
        if (parsedAmount != null) {
          total += parsedAmount;
        }
      }
    } catch (e) {
      print('Error parsing or processing: $dateStr, $amount');
    }
  }

  print('Total: $total');
  return total;
}

final monthlyExpenseTotalProvider = FutureProvider.family<double, DateTime>((
  ref,
  selectedMonth,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 0;

  return await getMonthlyExpenseTotal(uid, selectedMonth);
});

Future<double> getMonthlyIncomeTotal(String uid, DateTime selectedMonth) async {
  final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
  final endOfMonth = DateTime(
    selectedMonth.year,
    selectedMonth.month + 1,
    0,
    23,
    59,
    59,
  );

  print('Start of month: $startOfMonth');
  print('End of month: $endOfMonth');

  double total = 0;

  final snapshot =
      await FirebaseFirestore.instance
          .collection('income')
          .where('uid', isEqualTo: uid)
          .get();

  for (var doc in snapshot.docs) {
    final dateStr = doc['completeDate'];
    final amount = doc['amount'];

    if (dateStr == null || amount == null) continue;

    try {
      final parsedDate = DateTime.parse(dateStr);
      if (parsedDate.isAfter(
            startOfMonth.subtract(const Duration(seconds: 1)),
          ) &&
          parsedDate.isBefore(endOfMonth.add(const Duration(seconds: 1)))) {
        final parsedAmount =
            amount is num
                ? amount.toDouble()
                : double.tryParse(amount.toString());
        if (parsedAmount != null) {
          total += parsedAmount;
        }
      }
    } catch (e) {
      print('Error parsing or processing: $dateStr, $amount');
    }
  }

  print('Total: $total');
  return total;
}

final monthlyIncomeTotalProvider = FutureProvider.family<double, DateTime>((
  ref,
  selectedMonth,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 0;

  return await getMonthlyIncomeTotal(uid, selectedMonth);
});

final monthlyIncomeExpenseProvider =
    FutureProvider<(double income, double expense)>((ref) async {
      final income = await ref.watch(
        monthlyIncomeTotalProvider(ref.watch(selectedMonthProvider)).future,
      );
      final expense = await ref.watch(
        monthlyExpenseTotalProvider(ref.watch(selectedMonthProvider)).future,
      );
      return (income, expense);
    });

final weeklyIncomeExpenseProvider = FutureProvider.family<
  ({List<double> income, List<double> expense}),
  DateTime
>((ref, selectedMonth) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return (income: <double>[], expense: <double>[]);

  final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
  final daysInMonth =
      DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
  final endOfMonth = DateTime(
    selectedMonth.year,
    selectedMonth.month,
    daysInMonth,
    23,
    59,
    59,
  );

  List<double> weeklyExpenses = List.filled(5, 0.0);
  List<double> weeklyIncome = List.filled(5, 0.0);

  final transactions =
      await FirebaseFirestore.instance
          .collection('transactions')
          .where('uid', isEqualTo: uid)
          .get();

  for (var doc in transactions.docs) {
    final data = doc.data();
    final dateStr = data['completeDate'];
    final amount = data['amount'];

    if (dateStr == null || amount == null) continue;

    try {
      final date = DateTime.parse(dateStr);
      if (date.isBefore(startOfMonth) || date.isAfter(endOfMonth)) continue;

      final weekIndex = ((date.day - 1) ~/ 7).clamp(0, 4);
      final parsedAmount =
          amount is num
              ? amount.toDouble()
              : double.tryParse(amount.toString());
      if (parsedAmount != null) {
        weeklyExpenses[weekIndex] += parsedAmount;
      }
    } catch (_) {}
  }

  final incomes =
      await FirebaseFirestore.instance
          .collection('income')
          .where('uid', isEqualTo: uid)
          .get();

  for (var doc in incomes.docs) {
    final data = doc.data();
    final dateStr = data['completeDate'];
    final amount = data['amount'];

    if (dateStr == null || amount == null) continue;

    try {
      final date = DateTime.parse(dateStr);
      if (date.isBefore(startOfMonth) || date.isAfter(endOfMonth)) continue;

      final weekIndex = ((date.day - 1) ~/ 7).clamp(0, 4);
      final parsedAmount =
          amount is num
              ? amount.toDouble()
              : double.tryParse(amount.toString());
      if (parsedAmount != null) {
        weeklyIncome[weekIndex] += parsedAmount;
      }
    } catch (_) {}
  }

  return (income: weeklyIncome, expense: weeklyExpenses);
});

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final monthlyCategoryWiseExpenseProvider =
    FutureProvider.family<Map<String, double>, DateTime>((
      ref,
      selectedMonth,
    ) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return {};

      final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endOfMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      final snapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('uid', isEqualTo: uid)
              .get();

      Map<String, double> categoryTotals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dateStr = data['completeDate'];
        final amount = data['amount'];
        final category = data['category'];

        if (dateStr == null || amount == null || category == null) continue;

        try {
          final date = DateTime.parse(dateStr);
          if (date.isBefore(startOfMonth) || date.isAfter(endOfMonth)) continue;

          final parsedAmount =
              amount is num
                  ? amount.toDouble()
                  : double.tryParse(amount.toString());

          if (parsedAmount != null) {
            // Normalize category name to prevent duplicates
            final normalizedCategory = category.toString().trim().toLowerCase();
            final displayCategory = category.toString().trim();
            
            // Use the normalized category as key for aggregation
            categoryTotals[normalizedCategory] =
                (categoryTotals[normalizedCategory] ?? 0.0) + parsedAmount;
          }
        } catch (_) {
          continue;
        }
      }

      // Convert back to display format with proper capitalization
      Map<String, double> displayCategoryTotals = {};
      categoryTotals.forEach((key, value) {
        // Capitalize first letter for display
        final displayName = key.isNotEmpty 
            ? key[0].toUpperCase() + key.substring(1)
            : key;
        displayCategoryTotals[displayName] = value;
      });

      return displayCategoryTotals;
    });
