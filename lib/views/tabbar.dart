import 'package:expense/core/constants/constants.dart';
import 'package:expense/views/add_expense.dart';
import 'package:expense/views/home.dart';
import 'package:expense/views/profile_screen.dart';
import 'package:expense/views/statistics.dart';
import 'package:expense/providers/bottom_nav_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabbarPage extends ConsumerStatefulWidget {
  const TabbarPage({super.key});

  @override
  ConsumerState<TabbarPage> createState() => _TabbarPageState();
}

class _TabbarPageState extends ConsumerState<TabbarPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    final currentIndex = ref.read(bottomnavProvider);
    if (currentIndex != index) {
      ref.read(bottomnavProvider.notifier).state = index;
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomnavProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  Icons.data_exploration_outlined,
                  color: const Color(0xFF4A90E2),
                  size: 35,
                ),
              );
            },
          ),
          centerTitle: true,
          surfaceTintColor: Constants.whiteColor,
          backgroundColor: Constants.whiteColor,
          elevation: 0,
        ),
        backgroundColor: Constants.whiteColor,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildPage(currentIndex),
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Constants.whiteColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedNavItem(Icons.home_rounded, 'Home', 0, currentIndex),
                _buildAnimatedNavItem(Icons.bar_chart_rounded, 'Stats', 1, currentIndex),
                _buildAnimatedNavItem(Icons.add_circle_outline_rounded, 'Add', 2, currentIndex),
                _buildAnimatedNavItem(Icons.person_rounded, 'Profile', 3, currentIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(key: ValueKey('home'));
      case 1:
        return const StatisticsScreen(key: ValueKey('stats'));
      case 2:
        return const AddExpenseScreen(key: ValueKey('add'));
      case 3:
        return const ProfileScreen(key: ValueKey('profile'));
      default:
        return const HomeScreen(key: ValueKey('home'));
    }
  }

  Widget _buildAnimatedNavItem(IconData icon, String label, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF4A90E2).withOpacity(0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                size: isSelected ? 28 : 24,
                color: isSelected 
                  ? const Color(0xFF4A90E2)
                  : Colors.grey.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected 
                  ? const Color(0xFF4A90E2)
                  : Colors.grey.withOpacity(0.6),
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
