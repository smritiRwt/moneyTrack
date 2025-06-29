import 'package:expense/core/constants/constants.dart';
import 'package:flutter/material.dart';

class PaymentTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String)? onChanged;

  const PaymentTypeSelector({
    super.key,
    required this.selectedType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PaymentTypeButton(
            type: 'Cash',
            icon: Icons.money,
            isSelected: selectedType == 'Cash',
            onTap: onChanged == null ? null : () => onChanged?.call('Cash'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PaymentTypeButton(
            type: 'Card',
            icon: Icons.credit_card,
            isSelected: selectedType == 'Card',
            onTap: onChanged == null ? null : () => onChanged?.call('Card'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PaymentTypeButton(
            type: 'UPI',
            icon: Icons.payment,
            isSelected: selectedType == 'UPI',
            onTap: onChanged == null ? null : () => onChanged?.call('UPI'),
          ),
        ),
      ],
    );
  }
}

class _PaymentTypeButton extends StatelessWidget {
  final String type;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PaymentTypeButton({
    required this.type,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90E2)
                : const Color(0xFF4A90E2).withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF4A90E2),
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                color: const Color(0xFF4A90E2),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
