import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense/models/income_form.dart';
import 'package:expense/models/transaction_data.dart' show TransactionData;
import 'package:expense/models/transaction_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final transactionDataProvider = FutureProvider<TransactionData>((ref) async {
  // Watch the refresh counter to trigger updates
  ref.watch(transactionRefreshProvider);
  
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return TransactionData(
      transactions: [],
      totalExpenses: 0.0,
      totalIncomes: 0.0,
    );
  }

  // 🧠 Watch filters
  final selectedMonth = ref.watch(selectedMonthProvider);
  final selectedDateFilter = ref.watch(selectedDateFilterProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedSortOrder = ref.watch(selectedSortOrderProvider);
  final selectedType = ref.watch(selectedTypeProvider); // 👈 NEW

  final month = selectedMonth.month;
  final year = selectedMonth.year;
  final now = DateTime.now();

  final shouldFetchExpenses =
      selectedType == "Expense" || selectedType == "Both";
  final shouldFetchIncomes = selectedType == "Income" || selectedType == "Both";

  // 👇 Conditionally fetch based on type
  final expenseSnapshot =
      shouldFetchExpenses
          ? await FirebaseFirestore.instance
              .collection('transactions')
              .where('uid', isEqualTo: uid)
              .get()
          : null;

  final incomeSnapshot =
      shouldFetchIncomes
          ? await FirebaseFirestore.instance
              .collection('income')
              .where('uid', isEqualTo: uid)
              .get()
          : null;

  List<TransactionForm> parseAndFilter(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];

    return snapshot.docs
        .map(
          (doc) => TransactionForm.fromMap(
            doc.data() as Map<String, dynamic>,
            documentId: doc.id,
          ),
        )
        .where((txn) {
          try {
            final txnDate = DateFormat('d MMMM yyyy').parse(txn.date);
            final matchesMonth = txnDate.month == month && txnDate.year == year;

            // ✅ Date Filter
            bool matchesDateFilter = true;
            if (selectedDateFilter == "Today") {
              matchesDateFilter =
                  txnDate.year == now.year &&
                  txnDate.month == now.month &&
                  txnDate.day == now.day;
            } else if (selectedDateFilter == "This Week") {
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              final endOfWeek = startOfWeek.add(const Duration(days: 6));
              matchesDateFilter =
                  txnDate.isAfter(
                    startOfWeek.subtract(const Duration(seconds: 1)),
                  ) &&
                  txnDate.isBefore(endOfWeek.add(const Duration(days: 1)));
            } else if (selectedDateFilter == "This Month") {
              matchesDateFilter =
                  txnDate.month == now.month && txnDate.year == now.year;
            }

            // ✅ Category Filter
            final matchesCategory =
                selectedCategory == "All" || txn.category == selectedCategory;

            return matchesMonth && matchesDateFilter && matchesCategory;
          } catch (_) {
            return false;
          }
        })
        .toList();
  }

  final expenses = parseAndFilter(expenseSnapshot);
  final incomes = parseAndFilter(incomeSnapshot);

  List<TransactionForm> combined = [];
  if (selectedType == "Expense") {
    combined = expenses;
  } else if (selectedType == "Income") {
    combined = incomes;
  } else {
    combined = [...expenses, ...incomes];
  }

  // ✅ Apply sorting
  combined.sort((a, b) {
    final aAmount = double.tryParse(a.amount) ?? 0.0;
    final bAmount = double.tryParse(b.amount) ?? 0.0;
    final aDate = DateFormat('d MMMM yyyy').parse(a.date);
    final bDate = DateFormat('d MMMM yyyy').parse(b.date);

    switch (selectedSortOrder) {
      case "Oldest First":
        return aDate.compareTo(bDate);
      case "Amount: High to Low":
        return bAmount.compareTo(aAmount);
      case "Amount: Low to High":
        return aAmount.compareTo(bAmount);
      default:
        return bDate.compareTo(aDate); // Newest First
    }
  });

  double getTotalAmount(List<TransactionForm> list) {
    return list.fold(
      0.0,
      (sum, txn) => sum + (double.tryParse(txn.amount) ?? 0.0),
    );
  }

  return TransactionData(
    transactions: combined,
    totalExpenses: getTotalAmount(expenses),
    totalIncomes: getTotalAmount(incomes),
  );
});

final incomeListProvider = FutureProvider<List<IncomeForm>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  final snapshot =
      await FirebaseFirestore.instance
          .collection('income')
          .where('uid', isEqualTo: uid)
          .get();

  return snapshot.docs
      .map((doc) => IncomeForm.fromMap(doc.data(), documentId: doc.id))
      .toList();
});

double getTotalTransactionAmount(List<TransactionForm> transactions) {
  double total = 0.0;

  for (final txn in transactions) {
    final amount = double.tryParse(txn.amount) ?? 0.0;
    total += amount;
  }

  return total;
}

double getTotalIncomeAmount(List<IncomeForm> income) {
  double total = 0.0;

  for (final txn in income) {
    final amount = double.tryParse(txn.amount) ?? 0.0;
    total += amount;
  }

  return total;
}

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Date filter: "Today", "This Week", "This Month", "Custom"
final selectedDateFilterProvider = StateProvider<String>((ref) => "This Month");

/// Category filter: "All", "Food", "Bills", etc.
final selectedCategoryProvider = StateProvider<String>((ref) => "All");

/// Sort filter: "Newest First", "Amount: High to Low", etc.
final selectedSortOrderProvider = StateProvider<String>(
  (ref) => "Newest First",
);
final selectedTypeProvider = StateProvider<String>((ref) => "Both");

// Add this at the end of the file
final transactionRefreshProvider = StateProvider<int>((ref) => 0);
