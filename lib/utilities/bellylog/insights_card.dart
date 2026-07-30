import 'package:flutter/material.dart';

class InsightsCard extends StatelessWidget {
  final VoidCallback onTap;

  const InsightsCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colors.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Row(
            children: [
              Icon(
                Icons.dashboard_rounded,
                color: colors.onPrimaryContainer,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Go to Dashboard",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: colors.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
