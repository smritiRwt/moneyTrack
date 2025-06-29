import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AppTextStyles {
  // Page titles and main headings
  static TextStyle get pageTitle => const TextStyle(
    fontSize: AppTheme.fontSizeXxl,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get mainHeading => const TextStyle(
    fontSize: AppTheme.fontSizeXl,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get subHeading => const TextStyle(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: FontWeight.w600,
  );

  // Card titles and section headers
  static TextStyle get cardTitle => const TextStyle(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get sectionHeader => const TextStyle(
    fontSize: AppTheme.fontSizeMd,
    fontWeight: FontWeight.w600,
  );

  // Body text
  static TextStyle get bodyText => const TextStyle(
    fontSize: AppTheme.fontSizeMd,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get bodyTextSmall => const TextStyle(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: FontWeight.normal,
  );

  // Labels and captions
  static TextStyle get label => const TextStyle(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get caption => const TextStyle(
    fontSize: AppTheme.fontSizeXs,
    fontWeight: FontWeight.normal,
  );

  // Buttons
  static TextStyle get buttonText => const TextStyle(
    fontSize: AppTheme.fontSizeMd,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get buttonTextSmall => const TextStyle(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: FontWeight.w500,
  );

  // Amount and numbers
  static TextStyle get amount => const TextStyle(
    fontSize: AppTheme.fontSizeLg,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get amountSmall => const TextStyle(
    fontSize: AppTheme.fontSizeMd,
    fontWeight: FontWeight.w600,
  );

  // Category and transaction details
  static TextStyle get categoryName => const TextStyle(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get transactionDate => const TextStyle(
    fontSize: AppTheme.fontSizeXs,
    fontWeight: FontWeight.normal,
  );

  // Form elements
  static TextStyle get formLabel => const TextStyle(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get formHint => const TextStyle(
    fontSize: AppTheme.fontSizeSm,
    fontWeight: FontWeight.normal,
  );

  // Navigation and tabs
  static TextStyle get navLabel => const TextStyle(
    fontSize: AppTheme.fontSizeXs,
    fontWeight: FontWeight.w500,
  );

  // Status and badges
  static TextStyle get statusText => const TextStyle(
    fontSize: AppTheme.fontSizeXs,
    fontWeight: FontWeight.w500,
  );

  // Helper method to get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  // Helper method to get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  // Helper method to get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
