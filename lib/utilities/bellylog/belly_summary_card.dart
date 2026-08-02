import 'package:aletheia/utilities/bellylog/summary_chip.dart';
import 'package:flutter/material.dart';

class BellySummaryCard extends StatelessWidget {
  final int mealsToday;
  final int symptomsToday;
  final int bathroomVisitsToday;

  const BellySummaryCard({
    super.key,
    required this.mealsToday,
    required this.symptomsToday,
    required this.bathroomVisitsToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.surfaceContainerHighest, colors.surfaceContainerHigh],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Summary",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Everything recorded today.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: SummaryChip(
                  icon: Icons.restaurant,
                  label: "Meals",
                  value: mealsToday.toString(),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SummaryChip(
                  icon: Icons.monitor_heart,
                  label: "Symptoms",
                  value: symptomsToday.toString(),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SummaryChip(
                  icon: Icons.wc,
                  label: "Visits",
                  value: bathroomVisitsToday.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
