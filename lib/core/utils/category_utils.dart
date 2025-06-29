import 'package:flutter/material.dart';
import 'package:expense/core/constants/constants.dart';

class CategoryUtils {
  // Centralized category icons
  static IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      // Food & Dining
      case 'food':
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'groceries':
        return Icons.shopping_cart_rounded;
      case 'coffee':
        return Icons.local_cafe_rounded;

      // Transportation
      case 'transport':
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'travel':
        return Icons.flight_rounded;

      // Housing & Utilities
      case 'home':
      case 'housing':
        return Icons.home_rounded;
      case 'utilities':
        return Icons.power_rounded;
      case 'rent':
        return Icons.home_rounded;

      // Bills & Payments
      case 'bill':
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'subscription':
        return Icons.subscriptions_rounded;
      case 'insurance':
        return Icons.security_rounded;
      case 'taxes':
        return Icons.account_balance_rounded;

      // Shopping & Personal
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'personal':
        return Icons.person_rounded;
      case 'gift':
      case 'gifts':
        return Icons.card_giftcard_rounded;

      // Health & Education
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;

      // Entertainment
      case 'entertainment':
        return Icons.movie_rounded;

      // Income Categories
      case 'salary':
        return Icons.work_rounded;
      case 'freelancing':
        return Icons.computer_rounded;
      case 'investment':
      case 'investments':
        return Icons.trending_up_rounded;
      case 'bonus':
        return Icons.star_rounded;

      // Other
      case 'charity':
        return Icons.favorite_rounded;
      case 'other':
        return Icons.more_horiz_rounded;

      default:
        return Icons.monetization_on_rounded;
    }
  }

  // Centralized category colors
  static Color getColorForCategory(String category) {
    // Define the new color theme
    const Color primaryBlue = Color(0xFF0360FC);
    const Color primaryOrange = Color(0xFFFC9F03);
    const Color secondaryBlue = Color(0xFF4A90E2);
    const Color secondaryOrange = Color(0xFFFFB74D);
    const Color accentPurple = Color(0xFF9C27B0);
    const Color accentGreen = Color(0xFF4CAF50);
    const Color accentRed = Color(0xFFF44336);
    const Color accentTeal = Color(0xFF009688);
    
    switch (category.toLowerCase()) {
      // Food & Dining - Orange theme
      case 'food':
      case 'restaurant':
        return primaryOrange;
      case 'groceries':
        return secondaryOrange;
      case 'coffee':
        return primaryOrange;

      // Transportation - Blue theme
      case 'transport':
      case 'transportation':
        return primaryBlue;
      case 'travel':
        return secondaryBlue;

      // Housing & Utilities - Blue theme
      case 'home':
      case 'housing':
        return const Color(0xFF4A90E2);
      case 'utilities':
        return secondaryBlue;
      case 'rent':
        return primaryBlue;

      // Bills & Payments - Purple theme
      case 'bill':
      case 'bills':
        return accentPurple;
      case 'subscription':
        return accentPurple;
      case 'insurance':
        return primaryBlue;
      case 'taxes':
        return secondaryBlue;

      // Shopping & Personal - Orange theme
      case 'shopping':
        return primaryOrange;
      case 'personal':
        return secondaryOrange;
      case 'gift':
      case 'gifts':
        return primaryOrange;

      // Health & Education - Green/Teal theme
      case 'health':
        return accentGreen;
      case 'education':
        return accentTeal;

      // Entertainment - Orange theme
      case 'entertainment':
        return primaryOrange;

      // Income Categories - Green/Blue theme
      case 'salary':
        return accentGreen;
      case 'freelancing':
        return primaryOrange;
      case 'investment':
      case 'investments':
        return primaryBlue;
      case 'bonus':
        return accentGreen;

      // Other - Red theme
      case 'charity':
        return accentRed;
      case 'other':
        return accentRed;

      default:
        return primaryBlue;
    }
  }

  // Get category style (icon and color) as a map
  static Map<String, dynamic> getCategoryStyle(String category) {
    return {
      'icon': getIconForCategory(category),
      'color': getColorForCategory(category),
    };
  }

  // Get all available categories
  static List<String> getAllCategories() {
    return [
      // Expense categories
      'Food',
      'Groceries',
      'Transport',
      'Travel',
      'Home',
      'Utilities',
      'Rent',
      'Bill',
      'Subscription',
      'Insurance',
      'Taxes',
      'Shopping',
      'Personal',
      'Gift',
      'Health',
      'Education',
      'Entertainment',
      'Other',
      // Income categories
      'Salary',
      'Freelancing',
      'Investment',
      'Bonus',
    ];
  }

  // Get expense categories only
  static List<String> getExpenseCategories() {
    return [
      'Food',
      'Groceries',
      'Transport',
      'Travel',
      'Home',
      'Utilities',
      'Rent',
      'Bill',
      'Subscription',
      'Insurance',
      'Taxes',
      'Shopping',
      'Personal',
      'Gift',
      'Health',
      'Education',
      'Entertainment',
      'Other',
    ];
  }

  // Get income categories only
  static List<String> getIncomeCategories() {
    return ['Salary', 'Freelancing', 'Investment', 'Bonus'];
  }
}
