import 'package:flutter/material.dart';

import '../utils/expense_categories.dart';
import '../utils/finance_formatters.dart';

/// Per-category spend with a proportional bar. [totals] should already be
/// sorted largest-first (FinanceController.categoryTotalsForMonth does this).
class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> totals;

  const CategoryBreakdown({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        for (final entry in totals.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(
                    iconForCategory(entry.key),
                    size: 18,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.key} · '
                              '${grandTotal == 0 ? 0 : (entry.value / grandTotal * 100).round()}%',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            formatAmount(entry.value),
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: grandTotal == 0 ? 0 : entry.value / grandTotal,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
