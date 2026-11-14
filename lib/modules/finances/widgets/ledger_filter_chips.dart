import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../utils/finance_formatters.dart';

/// Two pills: red (people I owe) and green (people who owe me).
/// Tapping the active pill again clears the filter back to everyone.
class LedgerFilterChips extends StatelessWidget {
  final LedgerFilter selected;
  final ValueChanged<LedgerFilter> onChanged;
  final double iOweTotal;
  final double owedToMeTotal;
  final Color red;
  final Color green;

  const LedgerFilterChips({
    Key? key,
    required this.selected,
    required this.onChanged,
    required this.iOweTotal,
    required this.owedToMeTotal,
    required this.red,
    required this.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterPill(
            label: 'I owe',
            amount: iOweTotal,
            color: red,
            isSelected: selected == LedgerFilter.iOwe,
            onTap: () => onChanged(
              selected == LedgerFilter.iOwe
                  ? LedgerFilter.all
                  : LedgerFilter.iOwe,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FilterPill(
            label: 'Owed to me',
            amount: owedToMeTotal,
            color: green,
            isSelected: selected == LedgerFilter.owedToMe,
            onTap: () => onChanged(
              selected == LedgerFilter.owedToMe
                  ? LedgerFilter.all
                  : LedgerFilter.owedToMe,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.amount,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? color.withOpacity(0.18) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(label, style: textTheme.labelLarge),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatAmount(amount),
                  style: textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
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
