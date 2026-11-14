import 'package:flutter/material.dart';

/// One labelled figure shown inside a [FinanceSummaryCard].
class FinanceStat {
  final String label;
  final String value;
  final Color? valueColor;

  const FinanceStat({
    required this.label,
    required this.value,
    this.valueColor,
  });
}

/// Tappable card used on the Finances homepage for each sub-module.
class FinanceSummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FinanceStat> stats;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const FinanceSummaryCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.stats,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: foregroundColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: foregroundColor.withOpacity(0.7),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final stat in stats)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.label,
                            style: textTheme.bodySmall?.copyWith(
                              color: foregroundColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              stat.value,
                              style: textTheme.headlineSmall?.copyWith(
                                color: stat.valueColor ?? foregroundColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
