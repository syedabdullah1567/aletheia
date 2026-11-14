import 'package:flutter/material.dart';

import '../utils/finance_formatters.dart';

/// Month selector with a total underneath. Reused by Income and Expenses.
/// Pass [onNext] as null to disable the forward arrow (e.g. current month).
class MonthHeader extends StatelessWidget {
  final DateTime month;
  final String totalLabel; // e.g. "Total earned"
  final double total;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final Color? accentColor;

  const MonthHeader({
    super.key,
    required this.month,
    required this.totalLabel,
    required this.total,
    required this.onPrevious,
    required this.onNext,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    formatMonth(month),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatAmount(total),
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor ?? colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    totalLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
