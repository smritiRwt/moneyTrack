import 'package:expense/core/constants/constants.dart';
import 'package:expense/core/utils/category_utils.dart';
import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String?)? onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.categories,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory.isEmpty ? null : selectedCategory,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: const Icon(
            Icons.category_outlined,
            color: Color(0xFF4A90E2),
            size: 20,
          ),
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF4A90E2),
            size: 20,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF4A90E2),
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        icon: const SizedBox.shrink(),
        items: [
          // Add a placeholder item
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Select a category',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ),
          // Add category items
          ...categories.map((String category) {
            final categoryStyle = CategoryUtils.getCategoryStyle(category);
            return DropdownMenuItem<String>(
              value: category,
              child: Row(
                children: [
                  Icon(
                    categoryStyle['icon'],
                    color: categoryStyle['color'],
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
