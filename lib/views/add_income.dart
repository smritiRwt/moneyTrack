import 'package:expense/core/constants/constants.dart';
import 'package:expense/core/utils/category_utils.dart';
import 'package:expense/models/income_form.dart';
import 'package:expense/providers/income_form_notifier.dart';
import 'package:expense/providers/last_transaction_provider.dart';
import 'package:expense/providers/transaction_provider.dart';
import 'package:expense/services/firestore_service.dart';
import 'package:expense/views/components/action_buttons.dart';
import 'package:expense/views/components/category_dropdown.dart';
import 'package:expense/views/components/payment_type_selector.dart';
import 'package:expense/views/components/rounded_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  late TextEditingController amountController;
  bool isLoading = false;

  final List<String> incomeCategories = [
    'Salary',
    'Freelancing',
    'Gift',
    'Bonus',
    'Investment',
  ];

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset the form to ensure it starts blank
      ref.read(incomeFormProvider.notifier).reset();
    });

    amountController.addListener(() {
      ref.read(incomeFormProvider.notifier).updateAmount(amountController.text);
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _handleAddIncome() async {
    setState(() => isLoading = true);
    final snapshot = ref.read(incomeFormProvider);

    final txn = IncomeForm(
      type: 'income',
      amount: snapshot.amount,
      category: snapshot.category,
      completeDate: DateTime.now().toString(),
      paymentType: snapshot.paymentType,
      date: DateFormat('d MMMM y').format(DateTime.now()),
      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
    );

    try {
      await FirestoreService().addIncome(txn);

      // Comprehensive provider invalidation for immediate refresh
      ref.invalidate(transactionDataProvider);
      ref.invalidate(incomeListProvider);
      ref.invalidate(last3ExpensesProvider);
      ref.invalidate(last3IncomesProvider);

      // Force refresh the main data providers
      ref.refresh(transactionDataProvider);
      ref.refresh(incomeListProvider);

      // Trigger refresh
      ref.read(transactionRefreshProvider.notifier).state++;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Income added successfully ✅"),
            backgroundColor: Colors.green[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        // Reset form after successful submission
        ref.read(incomeFormProvider.notifier).reset();
        Navigator.pop(
          context,
          true,
        ); // Pass result to indicate successful addition
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(incomeFormProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              ref.read(incomeFormProvider.notifier).reset();
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          title: Text(
            'Add Income',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ListView(
                    children: [
                      // Amount Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4A90E2).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: amountController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A90E2),
                              ),
                              decoration: InputDecoration(
                                hintText: '₹0.00',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                ),
                                prefixIcon: const Icon(
                                  Icons.currency_rupee,
                                  color: Color(0xFF4A90E2),
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Category Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CategoryDropdown(
                            selectedCategory: form.category,
                            categories: incomeCategories,
                            onChanged: isLoading
                                ? null
                                : (val) {
                                    if (val != null) {
                                      ref
                                          .read(incomeFormProvider.notifier)
                                          .updateCategory(val);
                                    }
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Payment Type Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PaymentTypeSelector(
                            selectedType: form.paymentType,
                            onChanged: isLoading 
                                ? null 
                                : (val) {
                                    ref.read(incomeFormProvider.notifier).updatePaymentType(val);
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4A90E2),
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLoading ? null : () {
                      if (form.amount.isEmpty ||
                          form.category.isEmpty ||
                          form.paymentType.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Please fill in all fields"),
                            backgroundColor: Colors.red[400],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                        return;
                      }
                      _handleAddIncome();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Income',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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
