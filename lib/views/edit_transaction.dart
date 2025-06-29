import 'package:expense/core/constants/constants.dart';
import 'package:expense/core/utils/category_utils.dart';
import 'package:expense/models/income_form.dart';
import 'package:expense/models/transaction_form.dart';
import 'package:expense/providers/income_form_notifier.dart';
import 'package:expense/providers/last_transaction_provider.dart';
import 'package:expense/providers/transaction_form_provider.dart';
import 'package:expense/providers/transaction_provider.dart';
import 'package:expense/services/firestore_service.dart';
import 'package:expense/views/components/category_dropdown.dart';
import 'package:expense/views/components/payment_type_selector.dart';
import 'package:expense/views/components/rounded_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionForm transaction;
  final bool isIncome;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.isIncome,
  });

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final List<String> categoryOptions = const [
    'Food',
    'Home',
    'Bill',
    'Shopping',
    'Transport',
    'Salary',
    'Investment',
    'Other',
  ];

  late TextEditingController amountController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.transaction.amount);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isIncome) {
        // Initialize income form
        ref
            .read(incomeFormProvider.notifier)
            .updateAmount(widget.transaction.amount);
        ref
            .read(incomeFormProvider.notifier)
            .updateCategory(widget.transaction.category);
        ref
            .read(incomeFormProvider.notifier)
            .updatePaymentType(widget.transaction.paymentType);
      } else {
        // Initialize transaction form
        ref
            .read(transactionFormProvider.notifier)
            .updateAmount(widget.transaction.amount);
        ref
            .read(transactionFormProvider.notifier)
            .updateCategory(widget.transaction.category);
        ref
            .read(transactionFormProvider.notifier)
            .updatePaymentType(widget.transaction.paymentType);
      }
    });

    amountController.addListener(() {
      if (widget.isIncome) {
        ref
            .read(incomeFormProvider.notifier)
            .updateAmount(amountController.text);
      } else {
        ref
            .read(transactionFormProvider.notifier)
            .updateAmount(amountController.text);
      }
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _updateTransaction() async {
    if (amountController.text.isEmpty ||
        (widget.isIncome
            ? ref.read(incomeFormProvider).category.isEmpty
            : ref.read(transactionFormProvider).category.isEmpty) ||
        (widget.isIncome
            ? ref.read(incomeFormProvider).paymentType.isEmpty
            : ref.read(transactionFormProvider).paymentType.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // Check if documentId is available
    if (widget.transaction.documentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Transaction ID not found")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final firestoreService = FirestoreService();

      if (widget.isIncome) {
        final incomeForm = ref.read(incomeFormProvider);
        final updatedIncome = IncomeForm(
          type: 'income',
          amount: incomeForm.amount,
          category: incomeForm.category,
          completeDate: widget.transaction.completeDate, // Keep original date
          paymentType: incomeForm.paymentType,
          date: widget.transaction.date, // Keep original date
          uid: FirebaseAuth.instance.currentUser?.uid ?? '',
          documentId: widget.transaction.documentId,
        );

        await firestoreService.updateIncome(
          widget.transaction.documentId!,
          updatedIncome,
        );
      } else {
        final transactionForm = ref.read(transactionFormProvider);
        final updatedTransaction = TransactionForm(
          type: 'expense',
          amount: transactionForm.amount,
          category: transactionForm.category,
          completeDate: widget.transaction.completeDate, // Keep original date
          paymentType: transactionForm.paymentType,
          date: widget.transaction.date, // Keep original date
          uid: FirebaseAuth.instance.currentUser?.uid ?? '',
          documentId: widget.transaction.documentId,
        );

        await firestoreService.updateTransaction(
          widget.transaction.documentId!,
          updatedTransaction,
        );
      }

      // Comprehensive provider invalidation for immediate refresh
      ref.invalidate(transactionDataProvider);
      ref.invalidate(incomeListProvider);
      ref.invalidate(last3ExpensesProvider);
      ref.invalidate(last3IncomesProvider);

      // Force refresh the main data providers
      ref.refresh(transactionDataProvider);
      ref.refresh(incomeListProvider);

      // Add a small delay to ensure the operation completes
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction updated successfully ✅")),
        );
        Navigator.pop(
          context,
          true,
        ); // Pass result to indicate successful update
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: Constants.blackColor),
          ),
          title: Text(
            'Edit ${widget.isIncome ? 'Income' : 'Expense'}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall!.copyWith(fontSize: 18),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    RoundedTextField(
                      label: 'Amount',
                      controller: amountController,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 20),
                    if (widget.isIncome) ...[
                      Consumer(
                        builder: (context, ref, child) {
                          final form = ref.watch(incomeFormProvider);
                          return CategoryDropdown(
                            selectedCategory: form.category,
                            categories: categoryOptions,
                            onChanged:
                                isLoading
                                    ? null
                                    : (val) {
                                      if (val != null) {
                                        ref
                                            .read(incomeFormProvider.notifier)
                                            .updateCategory(val);
                                      }
                                    },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Consumer(
                        builder: (context, ref, child) {
                          final form = ref.watch(incomeFormProvider);
                          return PaymentTypeSelector(
                            selectedType: form.paymentType,
                            onChanged:
                                isLoading
                                    ? null
                                    : (val) {
                                      ref
                                          .read(incomeFormProvider.notifier)
                                          .updatePaymentType(val);
                                    },
                          );
                        },
                      ),
                    ] else ...[
                      Consumer(
                        builder: (context, ref, child) {
                          final form = ref.watch(transactionFormProvider);
                          return CategoryDropdown(
                            selectedCategory: form.category,
                            categories: categoryOptions,
                            onChanged:
                                isLoading
                                    ? null
                                    : (val) {
                                      if (val != null) {
                                        ref
                                            .read(
                                              transactionFormProvider.notifier,
                                            )
                                            .updateCategory(val);
                                      }
                                    },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Consumer(
                        builder: (context, ref, child) {
                          final form = ref.watch(transactionFormProvider);
                          return PaymentTypeSelector(
                            selectedType: form.paymentType,
                            onChanged:
                                isLoading
                                    ? null
                                    : (val) {
                                      ref
                                          .read(
                                            transactionFormProvider.notifier,
                                          )
                                          .updatePaymentType(val);
                                    },
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.lavender,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Update ${widget.isIncome ? 'Income' : 'Expense'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
