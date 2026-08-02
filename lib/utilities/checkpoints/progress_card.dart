import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final double progress;

  const ProgressCard({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  totalTasks == 0
                      ? 'A fresh start'
                      : '$completedTasks of $totalTasks completed',

                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),

              Icon(
                completedTasks == totalTasks && totalTasks > 0
                    ? Icons.celebration_rounded
                    : Icons.incomplete_circle,

                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,

              backgroundColor: colorScheme.onPrimaryContainer.withValues(
                alpha: 0.12,
              ),

              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            totalTasks == 0
                ? 'What would make today meaningful?'
                : progress == 1
                ? 'Everything is done. Well done.'
                : 'Keep moving at your own pace.',

            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
