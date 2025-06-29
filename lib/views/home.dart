import 'package:expense/core/constants/constants.dart';
import 'package:expense/core/utils/transaction_utils.dart';
import 'package:expense/core/utils/category_utils.dart';
import 'package:expense/core/utils/text_styles.dart';
import 'package:expense/providers/last_transaction_provider.dart';
import 'package:expense/providers/transaction_provider.dart';
import 'package:expense/views/components/skeleton_loader.dart';
import 'package:expense/views/edit_transaction.dart';
import 'package:expense/models/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
// import '../providers/task_provider.dart';
import '../core/constants/app_theme.dart';
import '../services/firestore_service.dart';
// import 'add_task_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(transactionDataProvider);
      ref.invalidate(incomeListProvider);
      ref.invalidate(last3ExpensesProvider);
      ref.invalidate(last3IncomesProvider);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward(from: 0.0);
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    ref.invalidate(transactionDataProvider);
    ref.invalidate(incomeListProvider);
    ref.invalidate(last3ExpensesProvider);
    ref.invalidate(last3IncomesProvider);
    ref.read(transactionRefreshProvider.notifier).state++;
    ref.refresh(transactionDataProvider);
    ref.refresh(incomeListProvider);
    ref.refresh(last3ExpensesProvider);
    ref.refresh(last3IncomesProvider);
    
    // Wait a bit to show the shimmer effect
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _isRefreshing = false;
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isDarkMode = ref.watch(themeModeProvider);
    final isSelected = _selectedIndex == index;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _onItemTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? (isDarkMode
                          ? Constants.lavender.withOpacity(0.2)
                          : Constants.lavender.withOpacity(0.1))
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: isSelected ? 1.0 + (_animation.value * 0.2) : 1.0,
                  child: Icon(
                    icon,
                    size: isSelected ? 28 : 24,
                    color:
                        isSelected
                            ? Constants.lavender
                            : (isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? Constants.lavender
                            : (isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final tasks = ref.watch(taskProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final asyncTransactionData = ref.watch(transactionDataProvider);
    final incomeAsync = ref.watch(incomeListProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
        body: asyncTransactionData.when(
          data: (data) {
            return RefreshIndicator(
              onRefresh: () async {
                await _refreshData();
              },
              color: const Color(0xFFFC9F03),
              backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width / 2.3,
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
                                        Icons.trending_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Total Expenses",
                                      style: AppTextStyles.withColor(
                                        AppTextStyles.label,
                                        Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "₹${data.totalExpenses.toStringAsFixed(2)}",
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.amount,
                                    Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "₹${data.totalIncomes - data.totalExpenses} remaining",
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.caption,
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width / 2.3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFC9F03),
                                  const Color(0xFFFC9F03).withOpacity(0.8),
                                  const Color(0xFFFC9F03).withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFC9F03).withOpacity(0.3),
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
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Total Income",
                                      style: AppTextStyles.withColor(
                                        AppTextStyles.label,
                                        Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "₹${data.totalIncomes.toStringAsFixed(2)}",
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.amount,
                                    Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "₹${data.totalIncomes - data.totalExpenses} remaining",
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.caption,
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Filter Button - Simple Icon
                          IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: const Color(0xFF4A90E2),
                              size: 20,
                            ),
                            onPressed: () => showFilterBottomSheet(context),
                          ),

                          // Month Filter - Simple Text
                          Row(
                            children: [
                              Text(
                                DateFormat.yMMM().format(selectedMonth),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFFFC9F03),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.calendar_month_outlined, 
                                size: 16,
                                color: const Color(0xFFFC9F03),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _isRefreshing 
                        ? SkeletonLoader(
                            type: SkeletonType.list,
                            itemCount: 3,
                          )
                        : asyncTransactionData.when(
                        data: (transactions) {
                          if (transactions.transactions.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(40),
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF4A90E2).withOpacity(0.1),
                                          const Color(0xFF4A90E2).withOpacity(0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_outlined,
                                      size: 48,
                                      color: const Color(0xFF4A90E2),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "No transactions found",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF2C3E50),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Pull down to refresh or add a new transaction",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          final groupedData = groupByDateAndCategory(
                            transactions.transactions,
                          );
                          return ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children:
                                groupedData.entries.map((dateEntry) {
                                  final date = dateEntry.key;
                                  final categories = dateEntry.value;

                                  // Calculate totals for this specific date
                                  final dateTotals = calculateDateTotals(
                                    categories,
                                  );

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            // Date header
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    const Color(0xFF4A90E2).withOpacity(0.1),
                                                    const Color(0xFF4A90E2).withOpacity(0.05),
                                                  ],
                                                ),
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                                border: Border.all(
                                                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    date,
                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : const Color(0xFF2C3E50),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        "-₹${dateTotals.totalExpenses.toStringAsFixed(2)}",
                                                        style: theme.textTheme.titleMedium?.copyWith(
                                                          color: isDarkMode
                                                              ? const Color(0xFF4A90E2)
                                                              : const Color(0xFF4A90E2),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        "+₹${dateTotals.totalIncomes.toStringAsFixed(2)}",
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          color: isDarkMode
                                                              ? const Color(0xFFFC9F03)
                                                              : const Color(0xFFFC9F03),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Transactions
                                            ...categories.entries.map((categoryEntry) {
                                              final category = categoryEntry.key;
                                              final transactions = categoryEntry.value;

                                              return Column(
                                                children: transactions.map((txn) {
                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 16,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.grey.withOpacity(0.1),
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        // Category icon
                                                        Container(
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                              colors: [
                                                                _getColorForCategory(txn.category),
                                                                _getColorForCategory(txn.category).withOpacity(0.8),
                                                              ],
                                                            ),
                                                            borderRadius: BorderRadius.circular(12),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: _getColorForCategory(txn.category).withOpacity(0.3),
                                                                blurRadius: 8,
                                                                offset: const Offset(0, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Icon(
                                                            _getIconForCategory(txn.category),
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 16),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                txn.category,
                                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                                  color: isDarkMode
                                                                      ? Colors.white
                                                                      : const Color(0xFF2C3E50),
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                txn.date,
                                                                style: theme.textTheme.bodySmall?.copyWith(
                                                                  color: isDarkMode
                                                                      ? Colors.white.withOpacity(0.7)
                                                                      : Colors.grey[600],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              "${txn.type == 'expense' ? '-' : '+'}₹${txn.amount}",
                                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                                color: (txn.type == 'expense')
                                                                    ? const Color(0xFF4A90E2)
                                                                    : const Color(0xFFFC9F03),
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              txn.paymentType,
                                                              style: theme.textTheme.bodySmall?.copyWith(
                                                                color: isDarkMode
                                                                    ? Colors.white.withOpacity(0.5)
                                                                    : Colors.grey[500],
                                                                fontSize: 11,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(width: 8),
                                                        // Edit and Delete buttons
                                                        PopupMenuButton<String>(
                                                          icon: Icon(
                                                            Icons.more_vert,
                                                            color: isDarkMode
                                                                ? Colors.white.withOpacity(0.7)
                                                                : Colors.grey[600],
                                                            size: 20,
                                                          ),
                                                          onSelected: (value) {
                                                            if (value == 'edit') {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => EditTransactionScreen(
                                                                    transaction: txn,
                                                                    isIncome: txn.type == 'income',
                                                                  ),
                                                                ),
                                                              );
                                                            } else if (value == 'delete') {
                                                              _showDeleteDialog(context, txn);
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              value: 'edit',
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.edit,
                                                                    size: 18,
                                                                    color: Colors.blue,
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  const Text('Edit'),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'delete',
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.delete,
                                                                    size: 18,
                                                                    color: Colors.red,
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  const Text('Delete'),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          );
                        },
                        loading: () => SkeletonLoader(
                          type: SkeletonType.list,
                          itemCount: 3,
                        ),
                        error: (error, stack) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Error loading transactions",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Pull down to try again",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => SkeletonLoader(
            type: SkeletonType.card,
            itemCount: 1,
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  "Error loading data",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pull down to try again",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: Container(
        //   margin: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        //     borderRadius: BorderRadius.circular(24),
        //     boxShadow: [
        //       BoxShadow(
        //         color:
        //             isDarkMode
        //                 ? Colors.black.withOpacity(0.2)
        //                 : Colors.grey.withOpacity(0.1),
        //         blurRadius: 10,
        //         offset: const Offset(0, 4),
        //       ),
        //     ],
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
        //       children: [
        //         _buildNavItem(Icons.home_rounded, 'Home', 0),
        //         _buildNavItem(Icons.add_circle_outline_rounded, 'Add', 1),
        //         _buildNavItem(Icons.pie_chart_rounded, 'Stats', 2),
        //         _buildNavItem(Icons.person_rounded, 'Profile', 3),
        //       ],
        //     ),
        //   ),
        // ),
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
          // Legend bar
          Row(
            children: List.generate(5, (_) {
              return Expanded(
                child: Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Category cards (2 per row)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(4, (index) {
              return Container(
                width: 160,
                height: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    // Store initial state
    final initialDateFilter = ref.read(selectedDateFilterProvider);
    final initialCategory = ref.read(selectedCategoryProvider);
    final initialSortOrder = ref.read(selectedSortOrderProvider);
    final initialtype = ref.read(selectedTypeProvider);

    // Local variables for temporary state
    String tempDateFilter = initialDateFilter;
    String tempCategory = initialCategory;
    String tempSortOrder = initialSortOrder;
    String tempType = initialtype;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Filters",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(selectedDateFilterProvider.notifier).state = "This Month";
                                ref.read(selectedCategoryProvider.notifier).state = "All";
                                ref.read(selectedSortOrderProvider.notifier).state = "This Month";
                                ref.read(selectedTypeProvider.notifier).state = "Both";
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Clear All",
                                style: TextStyle(
                                  color: const Color(0xFFFC9F03),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Filter
                              buildFilterChips<String>(
                                label: "Type",
                                selectedValue: tempType,
                                options: ["Expense", "Income", "Both"],
                                onSelected: (val) {
                                  setState(() {
                                    tempType = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // Date Filter
                              buildFilterChips<String>(
                                label: "Date",
                                selectedValue: tempDateFilter,
                                options: ["Today", "This Week", "This Month"],
                                onSelected: (val) {
                                  setState(() {
                                    tempDateFilter = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // Category Filter
                              buildFilterChips<String>(
                                label: "Category",
                                selectedValue: tempCategory,
                                options: [
                                  "All",
                                  "Food",
                                  "Bills",
                                  "Shopping",
                                  "Travel",
                                  "Rent",
                                  "Other",
                                ],
                                onSelected: (val) {
                                  setState(() {
                                    tempCategory = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // Sort Filter
                              buildFilterChips<String>(
                                label: "Sort By",
                                selectedValue: tempSortOrder,
                                options: [
                                  "Newest First",
                                  "Oldest First",
                                  "Amount: High to Low",
                                  "Amount: Low to High",
                                ],
                                onSelected: (val) {
                                  setState(() {
                                    tempSortOrder = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      
                      // Apply Button
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                ref.read(selectedDateFilterProvider.notifier).state = tempDateFilter;
                                ref.read(selectedCategoryProvider.notifier).state = tempCategory;
                                ref.read(selectedSortOrderProvider.notifier).state = tempSortOrder;
                                ref.read(selectedTypeProvider.notifier).state = tempType;
                                Navigator.pop(context);
                              },
                              child: Center(
                                child: Text(
                                  "Apply Filters",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget buildFilterChips<T>({
    required String label,
    required T selectedValue,
    required List<T> options,
    required void Function(T) onSelected,
    String Function(T)? displayBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            final label = displayBuilder != null
                ? displayBuilder(option)
                : option.toString();

            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4A90E2) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4A90E2)
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              Text(
                amount,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TransactionForm transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text(
            'Are you sure you want to delete this ${transaction.type}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteTransaction(transaction);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTransaction(TransactionForm transaction) async {
    try {
      final firestoreService = FirestoreService();
      
      if (transaction.type == 'income') {
        await firestoreService.deleteIncome(transaction.documentId!);
      } else {
        await firestoreService.deleteTransaction(transaction.documentId!);
      }

      // Refresh data
      ref.invalidate(transactionDataProvider);
      ref.invalidate(incomeListProvider);
      ref.invalidate(last3ExpensesProvider);
      ref.invalidate(last3IncomesProvider);
      ref.read(transactionRefreshProvider.notifier).state++;
      ref.refresh(transactionDataProvider);
      ref.refresh(incomeListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting transaction: $e')),
        );
      }
    }
  }
}

class Expense {
  final String category;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color iconColor;

  Expense({
    required this.category,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });
}

class ExpenseGroup {
  final String date;
  final String totalAmount;
  final List<Expense> expenses;

  ExpenseGroup({
    required this.date,
    required this.totalAmount,
    required this.expenses,
  });
}

final List<ExpenseGroup> groupedExpenses = [
  ExpenseGroup(
    date: "Tuesday, 14",
    totalAmount: "-\₹1380",
    expenses: [
      Expense(
        category: "Shop",
        subtitle: "Buy new clothes",
        amount: "-\$90",
        icon: Icons.shopping_cart_outlined,
        iconColor: const Color(0xFFDDE3FF),
      ),
      Expense(
        category: "Electronic",
        subtitle: "Buy new iPhone 14",
        amount: "-\$1290",
        icon: Icons.phone_iphone,
        iconColor: const Color(0xFFFFECD4),
      ),
    ],
  ),
  ExpenseGroup(
    date: "Monday, 13",
    totalAmount: "-\$60",
    expenses: [
      Expense(
        category: "Transportation",
        subtitle: "Trip to Malang",
        amount: "-\$60",
        icon: Icons.directions_car,
        iconColor: const Color(0xFFFFD6D6),
      ),
      Expense(
        category: "Shop",
        subtitle: "Buy Books",
        amount: "-\$80",
        icon: Icons.book,
        iconColor: const Color(0xFFFFD6D6),
      ),
    ],
  ),
];

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Constants.whiteColor,
      elevation: 0.2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: expense.iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(expense.icon, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    expense.subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              expense.amount,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _getIconForCategory(String category) {
  return CategoryUtils.getIconForCategory(category);
}

Color _getColorForCategory(String category) {
  return CategoryUtils.getColorForCategory(category);
}
