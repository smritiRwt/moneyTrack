import 'package:expense/core/constants/constants.dart';
import 'package:expense/core/utils/category_utils.dart';
import 'package:expense/providers/statistic_provider.dart';
import 'package:expense/providers/transaction_provider.dart' as transaction_provider;
import 'package:expense/views/components/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  final List<double> weeklyExpenses = [640, 850, 622, 960, 732];
  final List<double> weeklyIncome = [600, 1000, 922, 1060, 7132];
  final double weeklyLimit = 900;
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> categories = [
    {
      'label': 'Shop',
      'color': const Color.fromARGB(255, 96, 113, 211),
      'value': -1190,
      'icon': Icons.shopping_bag,
    },
    {
      'label': 'Transport',
      'color': const Color.fromARGB(255, 40, 37, 37),
      'value': -867,
      'icon': Icons.directions_car,
    },
  ];

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    final selectedMonth = ref.read(selectedMonthProvider);
    ref.invalidate(monthlyIncomeExpenseProvider);
    ref.invalidate(monthlyCategoryWiseExpenseProvider(selectedMonth));
    ref.invalidate(monthlyTransactionCountProvider(selectedMonth));
    ref.invalidate(transaction_provider.transactionDataProvider);
    ref.invalidate(transaction_provider.incomeListProvider);
    ref.read(transaction_provider.transactionRefreshProvider.notifier).state++;
    ref.refresh(monthlyIncomeExpenseProvider);
    ref.refresh(monthlyCategoryWiseExpenseProvider(selectedMonth));
    ref.refresh(monthlyTransactionCountProvider(selectedMonth));
    ref.refresh(transaction_provider.transactionDataProvider);
    ref.refresh(transaction_provider.incomeListProvider);
    
    // Wait a bit to show the shimmer effect
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final countAsync = ref.watch(
      monthlyTransactionCountProvider(selectedMonth),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.whiteColor,
        body: RefreshIndicator(
          onRefresh: () async {
            await _refreshData();
          },
          color: const Color(0xFFFC9F03),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Expense Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4A90E2),
                          const Color(0xFF4A90E2).withOpacity(0.8),
                          const Color(0xFF4A90E2).withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Total Expense",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ref
                            .watch(monthlyIncomeExpenseProvider)
                            .when(
                              data:
                                  (total) => RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: "₹",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: total.$2.toStringAsFixed(2),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "\n₹${total.$1.toStringAsFixed(2)} per month",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              loading: () => _buildSkeletonLoader(),
                              error: (e, _) => Text(
                                "Error: $e",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Expense Breakdown Section
                  _isRefreshing 
                    ? SkeletonLoader(
                        type: SkeletonType.card,
                        itemCount: 1,
                      )
                    : ref
                        .watch(weeklyIncomeExpenseProvider(selectedMonth))
                        .when(
                          data: (data) {
                            final expenses = data.expense;
                            final income = data.income;
                            
                            if (expenses.isEmpty && income.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    Icon(
                                      Icons.bar_chart_outlined,
                                      size: 48,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "No transactions to analyze",
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return _buildExpenseBreakdown(
                              weeklyExpenses: expenses,
                              weeklyIncome: income,
                            ); // pass lists
                          },
                          loading: () => SkeletonLoader(
                            type: SkeletonType.card,
                            itemCount: 1,
                          ),
                          error: (e, _) => Text("Error: $e"),
                        ),

                  const SizedBox(height: 20),

                  // Spending Details Section
                  _isRefreshing 
                    ? SkeletonLoader(
                        type: SkeletonType.card,
                        itemCount: 3,
                      )
                    : _buildSpendingDetails(ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdown({
    required List<double> weeklyExpenses,
    required List<double> weeklyIncome,
  }) {
    // Find the max value across both lists to scale bars properly
    final double maxValue = [
      ...weeklyExpenses,
      ...weeklyIncome,
    ].reduce((a, b) => a > b ? a : b);
    final double scaleMax =
        maxValue < 1200 ? 1200 : (maxValue / 200).ceil() * 200;
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Income & Expense",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Constants.blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                decoration: BoxDecoration(
                  color: Constants.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    DropdownButton<DateTime>(
                      value: selectedMonth,
                      underline: SizedBox(),
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.calendar_month_outlined, size: 15),
                      onChanged: (newDate) {
                        if (newDate != null) {
                          ref.read(selectedMonthProvider.notifier).state =
                              newDate;
                        }
                      },
                      items: List.generate(12, (index) {
                        final now = DateTime.now();
                        final date = DateTime(now.year, index + 1);
                        final label = DateFormat.yMMM().format(
                          date,
                        ); // e.g., Jun 2025
                        return DropdownMenuItem(
                          value: date,
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Bar Chart With Y-Axis Labels
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    final label = scaleMax - i * (scaleMax / 5).round();
                    return SizedBox(
                      height: 24,
                      width: 40,
                      child: Text(
                        '\$${label.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Constants.blackColor.withOpacity(0.7),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),

                // Bars: Grouped Expense + Income
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(weeklyExpenses.length, (index) {
                      final expense = weeklyExpenses[index];
                      final income = weeklyIncome[index];

                      final expenseRatio = expense / scaleMax;
                      final incomeRatio = income / scaleMax;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Values on Top
                          Row(
                            children: [
                              Text(
                                '\$${expense.toInt()}',
                                style: const TextStyle(fontSize: 9),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '\$${income.toInt()}',
                                style: const TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Bars
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Expense Bar
                              Container(
                                height: 120,
                                width: 14,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  height: (120 * expenseRatio.clamp(0.0, 1.0)),
                                  width: 14,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xFF4A90E2),
                                        const Color(0xFF4A90E2).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4A90E2).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Income Bar
                              Container(
                                height: 120,
                                width: 14,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  height: (120 * incomeRatio.clamp(0.0, 1.0)),
                                  width: 14,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xFFFC9F03),
                                        const Color(0xFFFC9F03).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFC9F03).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Week Label
                          Text(
                            'W${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Constants.blackColor,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Container(
            height: 20,
            width: 150,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Subtitle
          Container(
            height: 14,
            width: 200,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpendingDetails(WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final categoryExpensesAsync = ref.watch(
      monthlyCategoryWiseExpenseProvider(selectedMonth),
    );

    return categoryExpensesAsync.when(
      data: (data) {
        final total = data.values.fold(0.0, (sum, val) => sum + val);
        
        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  "No spending data available",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }
        
        final sortedCategories =
            data.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)); // Descending

        IconData getIcon(String category) {
          return CategoryUtils.getIconForCategory(category);
        }

        Color getColor(String category) {
          return CategoryUtils.getColorForCategory(category);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFC9F03).withOpacity(0.1),
                    const Color(0xFFFC9F03).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFC9F03).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFC9F03),
                          const Color(0xFFFC9F03).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pie_chart,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Spending Details",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFFC9F03),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Your expenses are divided into ${data.length} categories",
                          style: TextStyle(
                            fontSize: 12, 
                            color: const Color(0xFFFC9F03).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFC9F03).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<DateTime>(
                      value: selectedMonth,
                      underline: const SizedBox(),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.calendar_month_outlined, 
                        size: 16,
                        color: const Color(0xFFFC9F03),
                      ),
                      onChanged: (newDate) {
                        if (newDate != null) {
                          ref.read(selectedMonthProvider.notifier).state = newDate;
                        }
                      },
                      items: List.generate(12, (index) {
                        final now = DateTime.now();
                        final date = DateTime(now.year, index + 1);
                        final label = DateFormat.yMMM().format(date);
                        return DropdownMenuItem(
                          value: date,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFFC9F03),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Legend Bar (dynamic segments)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category Distribution",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: sortedCategories.map((entry) {
                      final percentage = (entry.value / total * 100).round();
                      final color = getColor(entry.key);
                      return Expanded(
                        flex: percentage > 0 ? percentage : 1,
                        child: Container(
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, color.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Cards
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: sortedCategories.map((entry) {
                final color = getColor(entry.key);
                final icon = getIcon(entry.key);
                return Container(
                  width: MediaQuery.of(context).size.width * 0.44,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color,
                              color.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key[0].toUpperCase() +
                                  entry.key.substring(1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹${entry.value.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => _buildSkeletonLoader(),
      error: (e, _) => Text('Error loading spending details: $e'),
    );
  }

  final Map<String, Map<String, dynamic>> categoryMeta = {
    'food': {
      'label': 'Food', 
      'icon': CategoryUtils.getIconForCategory('food'), 
      'color': CategoryUtils.getColorForCategory('food')
    },
    'shopping': {
      'label': 'Shopping',
      'icon': CategoryUtils.getIconForCategory('shopping'),
      'color': CategoryUtils.getColorForCategory('shopping'),
    },
    'home': {
      'label': 'Home', 
      'icon': CategoryUtils.getIconForCategory('home'), 
      'color': CategoryUtils.getColorForCategory('home')
    },
    'bills': {
      'label': 'Bills',
      'icon': CategoryUtils.getIconForCategory('bills'),
      'color': CategoryUtils.getColorForCategory('bills'),
    },
    'entertainment': {
      'label': 'Entertainment',
      'icon': CategoryUtils.getIconForCategory('entertainment'),
      'color': CategoryUtils.getColorForCategory('entertainment'),
    },
    'others': {
      'label': 'Others',
      'icon': CategoryUtils.getIconForCategory('other'),
      'color': CategoryUtils.getColorForCategory('other'),
    },
  };
}

